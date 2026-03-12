variable "project_id" {
  description = "GCP project ID to deploy into"
  type        = string
  default     = "text-to-speech-408318"
}

variable "region" {
  description = "Region for regional resources (Cloud Run, Cloud SQL, Artifact Registry)"
  type        = string
  default     = "asia-east1"
}

variable "service_name" {
  description = "Cloud Run service name and image name prefix"
  type        = string
  default     = "franken-php"
}

variable "artifact_repo" {
  description = "Artifact Registry Docker repository ID"
  type        = string
  default     = "franken-repo"
}

variable "github_owner" {
  description = "GitHub owner (user or org)"
  type        = string
  default     = "ferdinandfly"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "franken"
}

variable "wi_pool_id" {
  description = "Workload Identity Pool ID (short ID, not full name)"
  type        = string
  default     = "github-pool-2"
}

variable "wi_provider_id" {
  description = "Workload Identity Provider ID (short ID, not full name)"
  type        = string
  default     = "github-provider"
}

variable "db_instance_name" {
  description = "Cloud SQL instance name"
  type        = string
  default     = "franken-mysql"
}

variable "db_name" {
  description = "Application database name"
  type        = string
  default     = "app"
}

variable "db_user" {
  description = "Database user for Symfony"
  type        = string
  default     = "symfony"
}

variable "db_tier" {
  description = "Cloud SQL machine tier"
  type        = string
  default     = "db-f1-micro"
}
