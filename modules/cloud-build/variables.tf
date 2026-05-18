variable "project_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "repo_name" {
  type        = string
  description = "Short repo name used in resource naming (e.g. app-ingestion)"
}

variable "github_owner" {
  type = string
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name (without owner)"
}

variable "github_branch" {
  type    = string
  default = "main"
}

variable "ghcr_pat_secret_id" {
  type        = string
  description = "Secret Manager secret ID holding the GitHub PAT"
  default     = "github-pat"
}

variable "substitutions" {
  type        = map(string)
  description = "Cloud Build substitution variables passed to cloudbuild.yaml"
  default     = {}
}

variable "labels" {
  type    = map(string)
  default = {}
}
