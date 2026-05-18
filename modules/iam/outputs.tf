output "service_account_email" {
  value = google_service_account.github_actions.email
}

output "workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github_actions.name
}

output "workload_identity_pool_name" {
  value = google_iam_workload_identity_pool.github_actions.name
}

output "github_actions_members" {
  description = "Allowed GitHub repository principalSets"
  value = [
    for repo in var.github_repositories :
    "principalSet://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_actions.workload_identity_pool_id}/attribute.repository/${var.github_owner}/${repo}"
  ]
}
