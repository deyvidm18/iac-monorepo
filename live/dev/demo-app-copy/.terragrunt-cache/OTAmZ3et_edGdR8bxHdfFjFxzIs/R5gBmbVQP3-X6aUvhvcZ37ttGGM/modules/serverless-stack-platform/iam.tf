resource "google_service_account" "frontend" {
  count        = var.enable_cloud_run_frontend ? 1 : 0
  account_id   = "${var.name}-frontend-sa"
  display_name = "Service Account for ${var.name} frontend"
  project      = var.project_id
}

resource "google_service_account" "backend" {
  count        = var.enable_cloud_run_backend ? 1 : 0
  account_id   = "${var.name}-backend-sa"
  display_name = "Service Account for ${var.name} backend"
  project      = var.project_id
}

resource "google_cloud_run_v2_service_iam_member" "frontend_invoker" {
  count    = var.enable_cloud_run_frontend && var.enable_cloud_run_backend ? 1 : 0
  project  = google_cloud_run_v2_service.backend[0].project
  location = google_cloud_run_v2_service.backend[0].location
  name     = google_cloud_run_v2_service.backend[0].name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.frontend[0].email}"
}

resource "google_project_iam_member" "backend_memorystore" {
  count   = var.enable_cloud_run_backend && var.enable_memorystore ? 1 : 0
  project = var.project_id
  role    = "roles/redis.editor"
  member  = "serviceAccount:${google_service_account.backend[0].email}"
}

resource "google_project_iam_member" "backend_pubsub" {
  count   = var.enable_cloud_run_backend && var.enable_pubsub_topics ? 1 : 0
  project = var.project_id
  role    = "roles/pubsub.editor"
  member  = "serviceAccount:${google_service_account.backend[0].email}"
}

resource "google_project_iam_member" "backend_firestore" {
  count   = var.enable_cloud_run_backend && var.enable_firestore ? 1 : 0
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.backend[0].email}"
}

resource "google_project_iam_member" "backend_cloudsql" {
  count   = var.enable_cloud_run_backend && var.enable_cloud_sql ? 1 : 0
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.backend[0].email}"
}

resource "google_project_iam_member" "backend_cloudsql_iam_user" {
  count   = var.enable_cloud_run_backend && var.enable_cloud_sql ? 1 : 0
  project = var.project_id
  role    = "roles/cloudsql.instanceUser"
  member  = "serviceAccount:${google_service_account.backend[0].email}"
}