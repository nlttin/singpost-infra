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

variable "github_repo" {
  type = string
}

variable "github_branch" {
  type    = string
  default = "main"
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
  type    = string
  default = null
}

variable "project_roles" {
  type = list(string)
  default = [
    "roles/artifactregistry.writer",
    "roles/run.admin",
    "roles/container.admin",
  ]
}

variable "labels" {
  type    = map(string)
  default = {}
}
