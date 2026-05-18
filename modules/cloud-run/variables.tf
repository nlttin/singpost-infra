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

# Feature flags
variable "enable_vpc_connector" {
  type    = bool
  default = false
}

variable "enable_cloud_sql" {
  type    = bool
  default = false
}

variable "enable_apigee_invoker" {
  type    = bool
  default = false
}

# VPC
variable "vpc_network_self_link" {
  type    = string
  default = ""
}

# VPC Access Connector
variable "vpc_connector_cidr" {
  type    = string
  default = "10.0.100.0/28"
}

variable "connector_min_instances" {
  type    = number
  default = 2
}

variable "connector_max_instances" {
  type    = number
  default = 3
}

variable "connector_machine_type" {
  type    = string
  default = "e2-micro"
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
  type    = number
  default = 0
}

variable "max_instance_count" {
  type    = number
  default = 1
}

variable "image" {
  type    = string
  default = "docker.io/library/nginx:latest"
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "cpu" {
  type    = string
  default = "1"
}

variable "memory" {
  type    = string
  default = "512Mi"
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
  type    = string
  default = ""
}

# Secret Manager
variable "db_password_secret_id" {
  type    = string
  default = ""
}

variable "db_password_secret_version" {
  type    = string
  default = ""
}
