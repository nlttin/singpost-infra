include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_self_link = "projects/singpost/global/networks/singpost-dev-vpc"
  }
}

dependency "cloud_run" {
  config_path = "../cloud-run"

  mock_outputs = {
    vpc_self_link = "projects/singpost/global/networks/singpost-dev-vpc"
    service_uri = "https://mock.run.app"
  }
}

terraform {
  source = "../../../../modules/apigee"
}

inputs = {
  # VPC configuration
  vpc_network_self_link = dependency.vpc.outputs.vpc_self_link
  
  # Apigee configuration
  apigee_org_display_name = "SingPost Apigee"
  runtime_cidr_range = "10.10.0.0/22"
  cloud_run_url = dependency.cloud_run.outputs.service_uri
}