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

# VPC 
variable "vpc_network_self_link" {
  type = string
}

# VPC Access Connector
variable "vpc_connector_cidr" {
  type = string
}

variable "connector_min_instances" {
  type = number
}

variable "connector_max_instances" {
  type = number
}

variable "connector_machine_type" {
  type = string
}

# Cloud Run Service
variable "ingress" {
  type    = string
  default = "INGRESS_TRAFFIC_ALL"
}

variable "vpc_egress" {
  type    = string
  default = "PRIVATE_RANGES_ONLY"
}

variable "min_instance_count" {
  type = number
}

variable "max_instance_count" {
  type = number
}

variable "image" {
  type    = string
  default = "docker.io/library/nginx:latest"
}

variable "container_port" {
  type    = number
  default = 80
}

variable "cpu" {
  type = string
}

variable "memory" {
  type = string
}

variable "timeout_seconds" {
  type    = number
  default = 300
}

variable "env_vars" {
  type    = map(string)
  default = {}
}

# Allow unauthenticated access to the Cloud Run service
variable "allow_unauthenticated" {
  type    = bool
  default = true
}

# Database configuration
variable "cloudsql_connection_name" {
  type = string
}

# Secret Manager
variable "db_password_secret_id" {
  type = string
}

variable "db_password_secret_version" {
  type = string
}
