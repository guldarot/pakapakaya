locals {
  github_repository = "${var.github_owner}/${var.github_repo}"
  github_subject    = "repo:${local.github_repository}:ref:refs/heads/${var.github_branch}"
}

resource "google_project_service" "services" {
  for_each = toset([
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
    "iamcredentials.googleapis.com",
    "storage.googleapis.com",
  ])

  service            = each.value
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "backend" {
  location      = var.region
  repository_id = var.artifact_registry_repository_id
  description   = "Backend container images for PakaPakaya"
  format        = "DOCKER"

  depends_on = [google_project_service.services]
}

resource "google_storage_bucket" "uploads" {
  name                        = var.storage_bucket_name
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  depends_on = [google_project_service.services]
}

resource "google_secret_manager_secret" "db_password" {
  secret_id = var.db_user_password_secret_name

  replication {
    auto {}
  }

  depends_on = [google_project_service.services]
}

resource "google_secret_manager_secret" "database_url" {
  secret_id = var.database_url_secret_name

  replication {
    auto {}
  }

  depends_on = [google_project_service.services]
}

resource "google_sql_database_instance" "postgres" {
  name             = var.cloud_sql_instance_name
  region           = var.region
  database_version = "POSTGRES_16"

  settings {
    tier = var.cloud_sql_tier

    ip_configuration {
      ipv4_enabled    = false
      private_network = null
    }

    backup_configuration {
      enabled = true
    }
  }

  deletion_protection = true

  depends_on = [google_project_service.services]
}

resource "google_sql_database" "app" {
  name     = var.cloud_sql_database_name
  instance = google_sql_database_instance.postgres.name
}

data "google_secret_manager_secret_version" "db_password" {
  secret  = google_secret_manager_secret.db_password.id
  version = "latest"
}

resource "google_sql_user" "app" {
  name     = var.db_user_name
  instance = google_sql_database_instance.postgres.name
  password = data.google_secret_manager_secret_version.db_password.secret_data
}

resource "google_service_account" "backend_runtime" {
  account_id   = "pakapakaya-backend-runtime"
  display_name = "PakaPakaya backend runtime"
}

resource "google_project_iam_member" "backend_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.backend_runtime.email}"
}

resource "google_project_iam_member" "backend_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.backend_runtime.email}"
}

resource "google_storage_bucket_iam_member" "backend_storage_admin" {
  bucket = google_storage_bucket.uploads.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.backend_runtime.email}"
}

resource "google_cloud_run_v2_service" "backend" {
  name     = var.backend_service_name
  location = var.region

  template {
    service_account = google_service_account.backend_runtime.email

    volumes {
      name = "cloudsql"

      cloud_sql_instance {
        instances = [google_sql_database_instance.postgres.connection_name]
      }
    }

    containers {
      image = var.backend_image

      ports {
        container_port = 4000
      }

      env {
        name  = "PORT"
        value = "4000"
      }

      env {
        name  = "CLIENT_ORIGIN"
        value = var.client_origin
      }

      env {
        name  = "PERSISTENCE_MODE"
        value = var.persistence_mode
      }

      env {
        name  = "STORAGE_DRIVER"
        value = "gcs"
      }

      env {
        name  = "GCS_BUCKET_NAME"
        value = google_storage_bucket.uploads.name
      }

      env {
        name  = "GCS_PUBLIC_BASE_URL"
        value = "https://storage.googleapis.com/${google_storage_bucket.uploads.name}"
      }

      env {
        name = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.database_url.secret_id
            version = "latest"
          }
        }
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }
  }

  ingress = "INGRESS_TRAFFIC_ALL"

  depends_on = [
    google_project_service.services,
    google_project_iam_member.backend_sql_client,
    google_project_iam_member.backend_secret_accessor,
  ]
}

resource "google_cloud_run_service_iam_member" "public_invoker" {
  location = google_cloud_run_v2_service.backend.location
  project  = var.project_id
  service  = google_cloud_run_v2_service.backend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions pool"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub provider"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  attribute_condition = "assertion.repository == \"${local.github_repository}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account" "github_deployer" {
  account_id   = "pakapakaya-github-deployer"
  display_name = "GitHub deployer for PakaPakaya"
}

resource "google_project_iam_member" "github_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_project_iam_member" "github_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_project_iam_member" "github_service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_service_account_iam_member" "github_wif_user" {
  service_account_id = google_service_account.github_deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${local.github_repository}"
}
