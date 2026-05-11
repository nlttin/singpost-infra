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

# # CMEK
# variable "kms_key_name" {
#   type    = string
#   default = null
# }
