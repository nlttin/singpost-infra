# Global
variable "project_id" {
  type = string
}

variable "project_number" {
  type = string
}

variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "env" {
  type = string
}

# GitHub configuration for Workload Identity Federation
variable "github_owner" {
  type = string
}

variable "github_repositories" {
  type        = list(string)
  description = "List of GitHub repository names (without owner) allowed to use this WIF"
}

variable "github_branch" {
  type        = string
  description = "Branch that is allowed to use WIF (e.g. dev, main)"
}

# Workload Identity Federation configuration
variable "workload_identity_pool_id" {
  type    = string
  default = "github-actions-pool"
}

variable "workload_identity_pool_provider_id" {
  type    = string
  default = "github-actions-provider"
}

variable "service_account_id" {
  type        = string
  description = "SA account_id — must be ≤30 chars (GCP limit)"
}

variable "project_roles" {
  type = list(string)
  default = [
    "roles/cloudbuild.builds.editor",
    "roles/artifactregistry.writer",
    "roles/run.admin",
    "roles/iam.serviceAccountUser",
    "roles/storage.admin",
    "roles/logging.logWriter",
  ]
}

variable "cloudbuild_sa_emails" {
  type        = list(string)
  description = "Emails of Cloud Build user-specified SAs that need iam.serviceAccountTokenCreator for the Cloud Build service agent"
  default     = []
}

variable "labels" {
  type    = map(string)
  default = {}
}
