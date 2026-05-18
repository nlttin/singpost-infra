generate "provider_gcp" {
  path      = "provider.tf"
  if_exists = "overwrite"

  contents = <<EOF
terraform {
  required_version = ">= 1.14.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.30"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
EOF
}

locals {
  project_id     = "project-a8a37a94-04a7-44bf-a2c"
  project_number = "743479429318"
  project_name   = "sp-logistic"
  region         = "asia-southeast1"
  env            = basename(dirname(dirname(get_terragrunt_dir())))
  db_port        = 5432
}

inputs = {
  project_id     = local.project_id
  project_number = local.project_number
  project_name   = local.project_name
  region         = local.region
  env            = local.env
  db_port        = local.db_port
}