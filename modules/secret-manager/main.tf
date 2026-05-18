resource "google_project_service" "secretmanager" {
  project = var.project_id
  service = "secretmanager.googleapis.com"

  disable_on_destroy = false
}

# Secret Manager for database password
resource "google_secret_manager_secret" "secret_db_password" {
  secret_id = "${var.project_name}-${var.env}-secret-db-password"

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "secret_db_password_version" {
  secret      = google_secret_manager_secret.secret_db_password.id
  secret_data = var.db_password
}
