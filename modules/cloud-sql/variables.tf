# Global
variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "region" {
  type = string
}

# VPC
variable "network_self_link" {
  type = string
}

# Database
variable "db_engine" {
  type = string
}

variable "db_version" {
  type = string
}

variable "db_tier" {
  type = string
}

variable "disk_size" {
  type = number
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}
