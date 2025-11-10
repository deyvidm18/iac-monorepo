resource "google_pubsub_topic" "main_topic" {
  count   = var.enable_pubsub_topics ? 1 : 0
  name    = "${var.name}-topic"
  project = var.project_id
  labels  = local.labels
}