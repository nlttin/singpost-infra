include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/artifact-registry"
}

dependency "gke" {
  config_path = "../gke"

  mock_outputs_allowed_terraform_commands = ["apply", "plan", "destroy", "validate"]
  mock_outputs = {
    gke_app_service_account_email = "mock@developer.gserviceaccount.com"
  }
}

inputs = {
  repository_name = "app"
  format          = "DOCKER"
  immutable_tags  = false

  writer_members = []
  reader_members = []

  # GHCR remote proxy — GKE pulls via Artifact Registry which proxies ghcr.io
  enable_ghcr_proxy       = true
  ghcr_username           = "nlttin"
  ghcr_pat_secret_version = "projects/project-a8a37a94-04a7-44bf-a2c/secrets/github-pat/versions/latest"

  labels = {
    service = "artifact-registry"
  }
}
