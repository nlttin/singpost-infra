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
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "routing_mode" {
  type    = string
  default = "REGIONAL"
}

variable "app_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "pods_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "services_cidr" {
  type    = string
  default = "10.0.3.0/24"
}

variable "subnet_log_aggregation_interval" {
  type = string
}

variable "subnet_log_metadata" {
  type = string
}
