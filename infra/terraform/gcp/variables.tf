variable "project_id" {
  type        = string
  description = "Google Cloud project ID."
}

variable "region" {
  type        = string
  description = "Primary Google Cloud region."
  default     = "asia-south1"
}

variable "artifact_registry_repository_id" {
  type        = string
  description = "Artifact Registry repository ID for backend images."
  default     = "pakapakaya"
}

variable "backend_service_name" {
  type        = string
  description = "Cloud Run service name for the backend."
  default     = "pakapakaya-backend"
}

variable "backend_image" {
  type        = string
  description = "Full container image URL for the backend."
}

variable "cloud_sql_instance_name" {
  type        = string
  description = "Cloud SQL instance name."
  default     = "pakapakaya-postgres"
}

variable "cloud_sql_database_name" {
  type        = string
  description = "Application database name."
  default     = "pakapakaya"
}

variable "cloud_sql_tier" {
  type        = string
  description = "Cloud SQL machine tier."
  default     = "db-custom-1-3840"
}

variable "db_user_name" {
  type        = string
  description = "Application database user name."
  default     = "pakapakaya_app"
}

variable "db_user_password_secret_name" {
  type        = string
  description = "Secret Manager secret name that stores the DB password."
  default     = "pakapakaya-db-password"
}

variable "database_url_secret_name" {
  type        = string
  description = "Secret Manager secret name that stores the full DATABASE_URL."
  default     = "pakapakaya-database-url"
}

variable "storage_bucket_name" {
  type        = string
  description = "Cloud Storage bucket name for app uploads."
}

variable "client_origin" {
  type        = string
  description = "Allowed frontend origin for CORS."
}

variable "persistence_mode" {
  type        = string
  description = "Backend persistence mode."
  default     = "prisma"
}

variable "github_owner" {
  type        = string
  description = "GitHub organization or user that owns the repo."
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name."
}

variable "github_branch" {
  type        = string
  description = "GitHub branch allowed to deploy."
  default     = "main"
}
