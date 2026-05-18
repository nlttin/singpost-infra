include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/cloud-build"
}

inputs = {
  repo_name     = "app-tracking"
  github_owner  = "nlttin"
  github_repo   = "singpost-app-tracking"
  github_branch = "dev"

  ghcr_pat_secret_id = "github-pat"

  labels = {
    service = "cloud-build"
    repo    = "app-tracking"
  }
}
