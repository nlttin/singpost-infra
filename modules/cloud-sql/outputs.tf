output "instance_name" {
  value = google_sql_database_instance.db.name
}

output "connection_name" {
  value = google_sql_database_instance.db.connection_name
}

output "private_ip" {
  value = google_sql_database_instance.db.private_ip_address
}

output "db_name" {
  value = google_sql_database.database.name
}

output "db_user" {
  value = google_sql_user.user.name
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}
