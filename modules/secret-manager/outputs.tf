output "db_password_secret_id" {
  value = google_secret_manager_secret.secret_db_password.secret_id
}

output "db_password_secret_name" {
  value = google_secret_manager_secret.secret_db_password.name
}

output "db_password_secret_version" {
  value = google_secret_manager_secret_version.secret_db_password_version.version
}
