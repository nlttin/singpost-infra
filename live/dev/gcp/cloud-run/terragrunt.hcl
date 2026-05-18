include "root" {
  path = find_in_parent_folders()
}

locals {
  root = read_terragrunt_config(find_in_parent_folders())
  env  = local.root.locals.env
}

terraform {
  source = "../../../../modules/cloud-run"
}

inputs = {
  # No VPC connector or Cloud SQL for dev testing
  enable_vpc_connector = false
  enable_cloud_sql     = false

  ingress            = "INGRESS_TRAFFIC_ALL"
  min_instance_count = 0
  max_instance_count = 1

  # Placeholder — CI/CD will update this via gcloud run deploy
  # hello-app reads $PORT env var, works with any port
  image           = "gcr.io/google-samples/hello-app:1.0"
  container_port  = 8080
  cpu             = "1"
  memory          = "512Mi"
  timeout_seconds = 300

  allow_unauthenticated = true

  env_vars = {
    ENV = local.env
  }
}