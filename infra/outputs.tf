output "service_account_email" {
  description = "Service account email for GitHub Actions (use as GCP_SERVICE_ACCOUNT_EMAIL)"
  value       = google_service_account.github_deployer.email
}

output "workload_identity_provider" {
  description = "Full Workload Identity Provider resource name (use as GCP_WORKLOAD_IDENTITY_PROVIDER)"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "artifact_registry_repository" {
  description = "Artifact Registry repository resource"
  value       = google_artifact_registry_repository.franken.name
}

output "cloud_sql_instance_connection_name" {
  description = "Cloud SQL instance connection name (use as CLOUD_SQL_INSTANCE)"
  value       = google_sql_database_instance.mysql.connection_name
}

output "database_url_example" {
  description = "Example DATABASE_URL for Cloud Run using Unix socket"
  value       = "mysql://${google_sql_user.symfony.name}:${random_password.db_password.result}@localhost:3306/${google_sql_database.app.name}?serverVersion=8.0&charset=utf8mb4&unix_socket=/cloudsql/${google_sql_database_instance.mysql.connection_name}"
  sensitive   = true
}

