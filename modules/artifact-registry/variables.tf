# Global
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

# Repository
variable "repository_name" {
  type = string
}

variable "format" {
  type    = string
  default = "DOCKER"
}

variable "immutable_tags" {
  type    = bool
  default = true
}

# IAM
variable "writer_members" {
  type    = list(string)
  default = []
}

variable "reader_members" {
  type    = list(string)
  default = []
}

# Labels
variable "labels" {
  type    = map(string)
  default = {}
}

# GHCR proxy remote repository
variable "enable_ghcr_proxy" {
  type    = bool
  default = false
}

variable "ghcr_username" {
  type    = string
  default = ""
}

variable "ghcr_pat_secret_version" {
  type    = string
  default = ""
}

# CMEK — set to a KMS key resource name to enable encryption at rest
variable "kms_key_name" {
  type    = string
  default = null
}
