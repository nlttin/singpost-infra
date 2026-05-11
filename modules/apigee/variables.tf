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

# Network
variable "vpc_network_self_link" {
  type = string
}

# Apigee
variable "apigee_org_display_name" {
  type    = string
  default = "Apigee Organization"
}

variable "runtime_cidr_range" {
  type = string
}

# Backend
variable "cloud_run_url" {
  type = string
}
