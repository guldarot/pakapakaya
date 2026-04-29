output "artifact_registry_repository" {
  value       = google_artifact_registry_repository.backend.id
  description = "Artifact Registry repository resource ID."
}

output "cloud_run_service_url" {
  value       = google_cloud_run_v2_service.backend.uri
  description = "Deployed backend URL."
}

output "cloud_sql_connection_name" {
  value       = google_sql_database_instance.postgres.connection_name
  description = "Cloud SQL connection name for the Postgres instance."
}

output "storage_bucket_name" {
  value       = google_storage_bucket.uploads.name
  description = "Uploads bucket name."
}

output "github_workload_identity_provider" {
  value       = google_iam_workload_identity_pool_provider.github.name
  description = "Workload identity provider resource name for GitHub Actions."
}

output "github_service_account_email" {
  value       = google_service_account.github_deployer.email
  description = "GitHub deployer service account email."
}
