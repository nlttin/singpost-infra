# remote_state {
#   backend = "gcs"

#   config = {
#     bucket  = "singpost-tfstate"
#     prefix  = "${path_relative_to_include()}"
#     project = "your-gcp-project-id"
#     location = "asia-southeast1"
#   }
# }

generate "provider_gcp" {
  path      = "provider.tf"
  if_exists = "overwrite"

  contents = <<EOF
terraform {
  required_version = "~> 1.14.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.30"
    }
  }
}

provider "google" {
  project = var.project_name
  region  = var.region
}
EOF
}

locals {
  project_id     = "xxxxxxx" # Replace with your actual GCP project ID
  project_number = "123456789012" # Replace with your actual GCP project number
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