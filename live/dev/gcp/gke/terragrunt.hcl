include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/gke"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_self_link                 = "projects/singpost/global/networks/singpost-dev-vpc"
    app_subnet_self_link          = "mock-subnet"
    pods_secondary_range_name     = "mock-pods-range"
    services_secondary_range_name = "mock-services-range"
  }
}

# dependency "cloud_sql" {
#   config_path = "../cloud-sql"

#   mock_outputs = {
#     cloudsql_connection_name = "singpost-dev:us-central1:singpost-db"
#   }
# }

dependency "secret_manager" {
  config_path = "../secret-manager"

  mock_outputs = {
    db_password_secret_id = "mock-db-password-secret-id"
    # db_password_secret_version = "mock-db-password-secret-version"
  }
}

inputs = {
  # VPC configuration
  network_self_link             = dependency.vpc.outputs.vpc_self_link
  subnetwork_self_link          = dependency.vpc.outputs.app_subnet_self_link
  pods_secondary_range_name     = dependency.vpc.outputs.pods_secondary_range_name
  services_secondary_range_name = dependency.vpc.outputs.services_secondary_range_name

  # GKE Cluster settings
  release_channel = "STABLE"
  deletion_protection = false # Set to true for other environments

  enable_private_nodes    = true
  enable_private_endpoint = false # Set to true for other environments

  master_ipv4_cidr_block = "172.16.0.0/28"

  master_authorized_networks = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "temporary-access"
    }
  ]

  labels = {
    service = "gke"
  }

  # Secret Manager settings
  db_password_secret_id = dependency.secret_manager.outputs.db_password_secret_id
}