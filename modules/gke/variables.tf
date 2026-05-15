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
variable "network_self_link" {
  type = string
}

variable "subnetwork_self_link" {
  type = string
}

variable "pods_secondary_range_name" {
  type = string
}

variable "services_secondary_range_name" {
  type = string
}

# GKE Cluster
variable "release_channel" {
  type    = string
  default = "STABLE"
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "enable_private_nodes" {
  type    = bool
  default = true
}

variable "enable_private_endpoint" {
  type    = bool
  default = false
}

variable "master_ipv4_cidr_block" {
  type    = string
  default = "172.16.0.0/28"
}

variable "master_authorized_networks" {
  type = list(object({
    cidr_block   = string
    display_name = optional(string)
  }))
  default = []
}

variable "labels" {
  type    = map(string)
  default = {}
}

# Secret Manager
variable "db_password_secret_id" {
  type = string
}

# Workload Identity — required to allow GKE pods to authenticate to GCP without key files.
# The K8s SA named here must exist in the cluster and be annotated with:
#   iam.gke.io/gcp-service-account: {gke_workload_sa_email}
# Docs: https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity#authenticating_to
variable "k8s_namespace" {
  type        = string
  description = "Kubernetes namespace where the workload service account lives"
  default     = "default"
}

variable "k8s_service_account_name" {
  type        = string
  description = "Kubernetes service account name to bind to the Google SA via Workload Identity"
}
