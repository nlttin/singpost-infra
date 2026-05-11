include "root" {
  path = find_in_parent_folders()
}

locals {
  root = read_terragrunt_config(find_in_parent_folders())
  env  = local.root.locals.env
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_self_link = "projects/singpost/global/networks/singpost-dev-vpc"
  }
}

dependency "cloud_sql" {
  config_path = "../cloud-sql"

  mock_outputs = {
    cloudsql_connection_name = "singpost-dev:us-central1:singpost-db"
  }
}

dependency "secret_manager" {
  config_path = "../secret-manager"

  mock_outputs = {
    db_password_secret_id = "mock-db-password-secret-id"
    db_password_secret_version = "mock-db-password-secret-version"
  }
}

terraform {
  source = "../../../../modules/cloud-run"
}

inputs = {
  # VPC configuration
  vpc_network_self_link = dependency.vpc.outputs.vpc_self_link

  # VPC Access Connector settings
  vpc_connector_cidr    = "10.0.100.0/24"
  connector_min_instances = 1
  connector_max_instances = 2
  connector_machine_type  = "e2-micro"

  # Cloud Run Service settings
  ingress               = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  vpc_egress            = "PRIVATE_RANGES_ONLY"

  min_instance_count = 0
  max_instance_count = 1

  image        = "docker.io/library/nginx:latest"
  container_port = 80
  cpu            = "1"
  memory         = "512Mi"
  timeout_seconds    = 300

  env_vars = {
    ENV   = local.env
    PORT  = "80"
    DB_HOST = "10.0.0.0"
  }

  # Allow unauthenticated access to the Cloud Run service
  allow_unauthenticated = true

  # Database configuration
  cloudsql_connection_name = dependency.cloud_sql.outputs.cloudsql_connection_name

  # Secret Manager settings
  db_password_secret_id = dependency.secret_manager.outputs.db_password_secret_id
  db_password_secret_version = dependency.secret_manager.outputs.db_password_secret_version
}