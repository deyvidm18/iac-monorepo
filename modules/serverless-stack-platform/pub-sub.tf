resource "google_pubsub_topic" "main_topic" {
  count   = var.enable_pubsub_topics ? 1 : 0
  name                       = "${var.name}-topic"
  project                    = var.project_id
  labels                     = local.labels
  message_retention_duration = local.config.pubsub_retention
}

resource "google_pubsub_subscription" "sub_1" {
  count   = var.enable_pubsub_topics ? 1 : 0
  name    = "${var.name}-sub-1"
  topic   = google_pubsub_topic.main_topic[0].name
  project = var.project_id
  labels  = local.labels
}

resource "google_pubsub_subscription" "sub_2" {
  count   = var.enable_pubsub_topics ? 1 : 0
  name    = "${var.name}-sub-2"
  topic   = google_pubsub_topic.main_topic[0].name
  project = var.project_id
  labels  = local.labels
}