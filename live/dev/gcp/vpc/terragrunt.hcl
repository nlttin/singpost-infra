include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/vpc"
}

inputs = {
  # VPC configuration
  vpc_cidr           = "10.0.0.0/16"
  routing_mode       = "REGIONAL"

  app_subnet_cidr    = "10.0.1.0/24"
  pods_cidr          = "10.0.2.0/24"
  services_cidr      = "10.0.3.0/24"

  subnet_log_aggregation_interval = "INTERVAL_1_MIN"
  subnet_log_metadata             = "INCLUDE_ALL_METADATA"
}