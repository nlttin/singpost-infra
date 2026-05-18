include "root" {
  path = find_in_parent_folders()
}

locals {
  root = read_terragrunt_config(find_in_parent_folders())
  env  = local.root.locals.env
}

dependency "vpc" {
  config_path = "../networking"

  mock_outputs = {
    vpc_self_link = "projects/singpost/global/networks/singpost-prod-vpc"
  }
}

dependency "cloud_sql" {
  config_path = "../database"

  mock_outputs = {
    cloudsql_connection_name = "singpost-prod:asia-southeast1:singpost-db"
  }
}

dependency "secret_manager" {
  config_path = "../secret-manager"

  mock_outputs = {
    db_password_secret_id      = "mock-db-password-secret-id"
    db_password_secret_version = "mock-db-password-secret-version"
  }
}

terraform {
  source = "../../../../modules/cloud-run"
}

inputs = {
  vpc_network_self_link = dependency.vpc.outputs.vpc_self_link

  vpc_connector_cidr      = "10.4.100.0/24"
  connector_min_instances = 2
  connector_max_instances = 3
  connector_machine_type  = "e2-standard-2"

  ingress    = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  vpc_egress = "PRIVATE_RANGES_ONLY"

  min_instance_count = 1
  max_instance_count = 10

  image          = "docker.io/library/nginx:latest"
  container_port = 80
  cpu            = "2"
  memory         = "1Gi"
  timeout_seconds = 300

  env_vars = {
    ENV  = local.env
    PORT = "80"
  }

  allow_unauthenticated = false

  cloudsql_connection_name   = dependency.cloud_sql.outputs.cloudsql_connection_name
  db_password_secret_id      = dependency.secret_manager.outputs.db_password_secret_id
  db_password_secret_version = dependency.secret_manager.outputs.db_password_secret_version
}
