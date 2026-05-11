include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/artifact-registry"
}

dependency "gke" {
  config_path = "../gke"

  mock_outputs = {
    gke_app_service_account_email = "mock@developer.gserviceaccount.com"
  }
}

dependency "cloud-run" {
  config_path = "../cloud-run"

  mock_outputs = {
    cloud_run_service_account_email = "mock-cloud-run@developer.gserviceaccount.com"
  }
}

inputs = {
  repository_name = "app"
  description = "Main Docker repository"
  format = "DOCKER"
  immutable_tags = true

  writer_members = [
    "serviceAccount:${dependency.gke.outputs.gke_app_service_account_email}",
    "serviceAccount:${dependency.cloud-run.outputs.cloud_run_service_account_email}",
  ]

  reader_members = [
    "serviceAccount:${dependency.gke.outputs.gke_app_service_account_email}",
    "serviceAccount:${dependency.cloud-run.outputs.cloud_run_service_account_email}",
  ]

  labels = {
    service = "artifact-registry"
  }
}