locals {
  cluster_name = "${var.project_name}-${var.env}-gke"

  common_labels = merge(
    var.labels,
    {
      project = var.project_name
      env     = var.env
      managed = "terraform"
    }
  )
}

resource "google_container_cluster" "gke" {
  name     = local.cluster_name
  location = var.region

  enable_autopilot    = true
  deletion_protection = var.deletion_protection

  network    = var.network_self_link
  subnetwork = var.subnetwork_self_link

  release_channel {
    channel = var.release_channel
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  dynamic "master_authorized_networks_config" {
    for_each = length(coalesce(var.master_authorized_networks, [])) > 0 && !var.enable_private_endpoint ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = coalesce(var.master_authorized_networks, [])
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = try(cidr_blocks.value.display_name, cidr_blocks.value.cidr_block)
        }
      }
    }
  }

  resource_labels = local.common_labels
}

# Service Account for workloads in GKE to access Cloud SQL and Secret Manager
resource "google_service_account" "gke_workload_sa" {
  account_id   = "${var.project_name}-${var.env}-gke-workload"
  display_name = "GKE Workload Service Account"
  description  = "Service account for GKE workloads to access Cloud SQL and Secret Manager"
}

# IAM role for Cloud SQL Client
resource "google_project_iam_member" "gke_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.gke_workload_sa.email}"
}

# Secret Manager access role for GKE workloads
resource "google_secret_manager_secret_iam_member" "gke_secret_access" {
  secret_id = var.db_password_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.gke_workload_sa.email}"
}

# Workload Identity binding — links a Kubernetes SA to this Google SA.
# This allows pods running under the K8s SA to call GCP APIs (Cloud SQL, Secret Manager)
# using the Google SA's credentials, without mounting any key files.
# The member format "project.svc.id.goog[namespace/k8s-sa]" is GKE-specific.
# Docs: https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
# Terraform: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam
resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = google_service_account.gke_workload_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_service_account_name}]"
}
