resource "google_firestore_database" "database" {
  name        = "${var.name}-firestore"
  count       = var.enable_firestore ? 1 : 0
  project     = var.project_id
  location_id = var.region
  type        = "FIRESTORE_NATIVE"
}