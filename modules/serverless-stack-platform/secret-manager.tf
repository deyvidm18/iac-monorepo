resource "google_secret_manager_secret" "secret" {
  count     = var.enable_secret_manager ? 1 : 0
  secret_id = "${var.name}-secret"
  project   = var.project_id
  labels    = local.labels

  replication {
    auto {}
  }
}
