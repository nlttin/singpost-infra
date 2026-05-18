output "cluster_name" {
  value = google_container_cluster.gke.name
}

output "cluster_self_link" {
  value = google_container_cluster.gke.self_link
}

output "cluster_endpoint" {
  value = google_container_cluster.gke.endpoint
}

output "cluster_ca_certificate" {
  value     = google_container_cluster.gke.master_auth[0].cluster_ca_certificate
  sensitive = true
}

output "workload_identity_pool" {
  value = "${var.project_name}.svc.id.goog"
}

output "gke_app_service_account_email" {
  value       = google_service_account.gke_workload_sa.email
  description = "Email of the GKE application service account"
}

output "gke_app_service_account_name" {
  value       = google_service_account.gke_workload_sa.name
  description = "Name of the GKE application service account"
}
