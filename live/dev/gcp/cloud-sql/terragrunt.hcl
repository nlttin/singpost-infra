include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/cloud-sql"
}

dependency "vpc" {
  config_path = "../vpc"
  
  mock_outputs = {
    vpc_self_link = "projects/singpost/global/networks/singpost-dev-vpc"
  }
}

inputs = {
  # VPC configuration
  network_self_link = dependency.vpc.outputs.vpc_self_link

  # Database configuration
  db_engine  = "POSTGRES"
  db_version = "POSTGRES_18"

  db_tier  = "db-f1-micro"
  disk_size = 20

  db_name = "singpost_db"
  db_user = "singpost_user"
}