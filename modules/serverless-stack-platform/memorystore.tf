resource "google_redis_instance" "cache" {
  count              = var.enable_memorystore ? 1 : 0
  name               = "${var.name}-redis"
  tier               = local.config.memorystore_tier
  memory_size_gb     = local.config.memorystore_size_gb
  labels             = local.labels
  location_id        = var.zone
  project            = var.project_id
  authorized_network = data.google_compute_network.main.id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"

  depends_on = [google_service_networking_connection.private_vpc_connection]
}