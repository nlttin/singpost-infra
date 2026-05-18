include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/secret-manager"
}

dependency "cloud_sql" {
  config_path = "../cloud-sql"
  
  mock_outputs = {
    db_password = "mock-db-password"
  }
}

inputs = {
  # Database configuration
  db_password = dependency.cloud_sql.outputs.db_password
}