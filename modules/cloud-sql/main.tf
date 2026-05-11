resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "!#$%*-_=+"
}

resource "google_sql_database_instance" "db" {
  name             = "${var.project_name}-${var.env}-db"
  region           = var.region
  database_version = var.db_version

  deletion_protection = true

  settings {
    tier              = var.db_tier
    disk_size         = var.disk_size
    disk_autoresize   = true
    availability_type = "ZONAL"

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_self_link
    }

    backup_configuration {
      enabled = true
    }

    maintenance_window {
      day  = 7
      hour = 3
    }
  }
}

resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.db.name
}

resource "google_sql_user" "user" {
  name     = var.db_user
  instance = google_sql_database_instance.db.name
  password = random_password.db_password.result
}
