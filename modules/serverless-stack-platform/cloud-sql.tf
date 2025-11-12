data "google_compute_network" "main" {
  project = var.network_project_id
  name    = var.vpc_name
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = data.google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [var.private_ip_allocation_name]
}

resource "google_sql_database_instance" "postgres" {
  count            = var.enable_cloud_sql ? 1 : 0
  name             = "${var.name}-pg"
  database_version = "POSTGRES_14"
  region           = var.region
  project          = var.project_id

  settings {
    tier              = local.config.cloudsql_tier
    availability_type = local.config.cloudsql_ha ? "REGIONAL" : "ZONAL"
    ip_configuration {
      ipv4_enabled    = false
      private_network = data.google_compute_network.main.id
      ssl_mode        = "ENCRYPTED_ONLY"
    }
    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
    user_labels = local.labels
  }

  deletion_protection = !var.force_destroy

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_user" "iam_user" {
  count    = var.enable_cloud_sql && var.enable_cloud_run_backend ? 1 : 0
  name     = replace(google_service_account.backend[0].email, ".gserviceaccount.com", "")
  instance = google_sql_database_instance.postgres[0].name
  project  = var.project_id
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}