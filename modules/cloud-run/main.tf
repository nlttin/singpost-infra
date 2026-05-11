resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "vpcaccess.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com",
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
  ])

  service            = each.value
  disable_on_destroy = false
}

resource "google_service_account" "cloudrun_sa" {
  account_id   = "${var.project_name}-${var.env}-cloudrun-sa"
  display_name = "${var.project_name}-${var.env}-cloud-run-service-account"
}

resource "google_vpc_access_connector" "connector" {
  name          = "${var.project_name}-${var.env}-cr-connector"
  region        = var.region
  network       = var.vpc_network_self_link
  ip_cidr_range = var.vpc_connector_cidr

  min_instances = var.connector_min_instances
  max_instances = var.connector_max_instances
  machine_type  = var.connector_machine_type
}

resource "google_project_iam_member" "cloudrun_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "cloudrun_secret_access" {
  secret_id = var.db_password_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}

resource "google_cloud_run_v2_service" "cloudrun_app" {
  name     = "${var.project_name}-${var.env}-cloudrun-app"
  location = var.region

  deletion_protection = false
  ingress             = var.ingress
  client              = "terraform"

  template {
    service_account = google_service_account.cloudrun_sa.email

    scaling {
      min_instance_count = var.min_instance_count
      max_instance_count = var.max_instance_count
    }

    vpc_access {
      connector = google_vpc_access_connector.connector.id
      egress    = var.vpc_egress
    }

    volumes {
      name = "cloudsql"

      cloud_sql_instance {
        instances = [var.cloudsql_connection_name]
      }
    }

    containers {
      image = var.image

      ports {
        container_port = var.container_port
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }

      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
      }

      dynamic "env" {
        for_each = var.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }

      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = var.db_password_secret_id
            version = var.db_password_secret_version
          }
        }
      }

      env {
        name  = "DB_HOST"
        value = "/cloudsql/${var.cloudsql_connection_name}"
      }

      env {
        name  = "DB_PORT"
        value = "5432"
      }
    }

    timeout = "${var.timeout_seconds}s"
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
      template[0].containers[0].env,
    ]
  }

  depends_on = [
    google_project_service.apis,
    google_project_iam_member.cloudrun_sql_client,
    google_secret_manager_secret_iam_member.cloudrun_secret_access,
  ]
}

resource "google_cloud_run_v2_service_iam_member" "apigee_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.cloudrun_app.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:service-${var.project_id}@gcp-sa-apigee.iam.gserviceaccount.com"
}
