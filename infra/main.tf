terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

provider "random" {}

locals {
  sa_roles = [
    "roles/run.admin",
    "roles/cloudbuild.builds.editor",
    "roles/artifactregistry.writer",
    "roles/cloudsql.client",
    "roles/serviceusage.serviceUsageConsumer",
    "roles/storage.admin", 
    "roles/viewer",
  ]
}

# Artifact Registry repository for Docker images
resource "google_artifact_registry_repository" "franken" {
  location      = var.region
  repository_id = var.artifact_repo
  format        = "DOCKER"
  description   = "FrankenPHP images for ${var.service_name}"

  cleanup_policies {
    id     = "keep-last-10"
    action = "KEEP"

    most_recent_versions {
      keep_count = 10
    }
  }
}

# Service account used by GitHub Actions to deploy
resource "google_service_account" "github_deployer" {
  account_id   = "github-deployer"
  display_name = "GitHub Actions deployer for ${var.service_name}"
}

resource "google_project_iam_member" "github_deployer_roles" {
  for_each = toset(local.sa_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

# Workload Identity Pool & Provider for GitHub
resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = var.wi_pool_id
  display_name              = "GitHub Actions pool"
  description               = "OIDC identities from GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = var.wi_provider_id
  display_name                       = "GitHub Actions provider"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"              = "assertion.sub"
    "attribute.repository"        = "assertion.repository"
    "attribute.repository_owner"  = "assertion.repository_owner"
    "attribute.ref"               = "assertion.ref"
  }

  # Only allow this specific repo
  attribute_condition = "attribute.repository == \"${var.github_owner}/${var.github_repo}\""
}

# Allow identities from the GitHub provider to impersonate the deployer service account
resource "google_service_account_iam_member" "github_workload_identity_user" {
  service_account_id = google_service_account.github_deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_owner}/${var.github_repo}"
}

# Cloud SQL instance (MySQL)
resource "google_sql_database_instance" "mysql" {
  name             = var.db_instance_name
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier = var.db_tier
  }

  deletion_protection = false
}

resource "google_sql_database" "app" {
  name     = var.db_name
  instance = google_sql_database_instance.mysql.name
}

resource "random_password" "db_password" {
  length  = 24
  special = true
}

resource "google_sql_user" "symfony" {
  instance = google_sql_database_instance.mysql.name
  name     = var.db_user
  password = random_password.db_password.result
}

resource "google_project_service" "artifact_registry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "cloud_build" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"
}

resource "google_project_service" "sql_admin" {
  project = var.project_id
  service = "sqladmin.googleapis.com"
}

resource "google_project_iam_member" "github_sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_project_service" "cloud_run" {
  project = var.project_id
  service = "run.googleapis.com"
}