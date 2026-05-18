include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_self_link = "projects/singpost/global/networks/singpost-dev-vpc"
  }
}

terraform {
  source = "../../../../modules/apigee"
}

inputs = {
  vpc_network_self_link   = dependency.vpc.outputs.vpc_self_link
  apigee_org_display_name = "SingPost Apigee"
  runtime_cidr_range      = "10.10.0.0/22"
}