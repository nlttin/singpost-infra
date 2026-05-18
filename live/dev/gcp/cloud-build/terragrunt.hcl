include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/cloud-build"
}

inputs = {
  repo_name    = "app-ingestion"
  github_owner = "nlttin"
  github_repo  = "singpost-app-ingestion"
  github_branch = "main"

  ghcr_pat_secret_id = "github-pat"

  labels = {
    service = "cloud-build"
    repo    = "app-ingestion"
  }
}
