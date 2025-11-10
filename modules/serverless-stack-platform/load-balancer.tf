// --- External Load Balancer Resources (for Frontend) ---

resource "google_compute_global_address" "external_ip" {
  count   = var.enable_load_balancer && var.frontend_load_balancer_type == "EXTERNAL" ? 1 : 0
  name    = "${local.name_prefix}-external-lb-ip"
  project = var.project_id
  labels  = local.labels
}

resource "google_compute_region_network_endpoint_group" "frontend_neg" {
  count                 = var.enable_cloud_run_frontend && var.frontend_load_balancer_type == "EXTERNAL" ? 1 : 0
  name                  = "${local.name_prefix}-frontend-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  project               = var.project_id
  cloud_run { service = google_cloud_run_v2_service.frontend[0].name }
}

resource "google_compute_backend_service" "frontend_backend" {
  count                 = var.enable_load_balancer && var.enable_cloud_run_frontend && var.frontend_load_balancer_type == "EXTERNAL" ? 1 : 0
  name                  = "${local.name_prefix}-frontend-backend"
  project               = var.project_id
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  backend { group = google_compute_region_network_endpoint_group.frontend_neg[0].id }
  dynamic "iap" {
    for_each = var.enable_iap ? [1] : []
    content {
      enabled              = true
      oauth2_client_id     = google_iap_client.default[0].client_id
      oauth2_client_secret = google_iap_client.default[0].secret
    }
  }
}

resource "google_project_service_identity" "iap_sa" {
  provider = google-beta
  project  = var.project_id
  service  = "iap.googleapis.com"
}

resource "google_iap_brand" "default" {
  count                = var.enable_iap ? 1 : 0
  project              = var.project_id
  support_email        = var.iap_support_email
  application_title    = var.name
}

resource "google_iap_client" "default" {
  count        = var.enable_iap ? 1 : 0
  display_name = var.name
  brand        = google_iap_brand.default[0].name
}

resource "google_iap_web_iam_member" "iap_access" {
  for_each = var.enable_iap ? toset(var.iap_members) : []
  project  = var.project_id
  role     = "roles/iap.httpsResourceAccessor"
  member   = each.key
}

resource "google_compute_managed_ssl_certificate" "default" {
  count   = var.enable_load_balancer && local.load_balancer_domain != "" && var.frontend_load_balancer_type == "EXTERNAL" ? 1 : 0
  name    = "${var.name}-ssl-cert"
  project = var.project_id
  managed { domains = [local.load_balancer_domain] }
}

resource "google_compute_url_map" "external" {
  count           = var.enable_load_balancer && var.frontend_load_balancer_type == "EXTERNAL" ? 1 : 0
  name            = "${var.name}-external-url-map"
  project         = var.project_id
  default_service = google_compute_backend_service.frontend_backend[0].id
}

resource "google_compute_target_https_proxy" "external" {
  count            = var.enable_load_balancer && local.load_balancer_domain != "" && var.frontend_load_balancer_type == "EXTERNAL" ? 1 : 0
  name             = "${var.name}-https-proxy"
  project          = var.project_id
  url_map          = google_compute_url_map.external[0].id
  ssl_certificates = [google_compute_managed_ssl_certificate.default[0].id]
}

resource "google_compute_global_forwarding_rule" "external" {
  count                 = var.enable_load_balancer && local.load_balancer_domain != "" && var.frontend_load_balancer_type == "EXTERNAL" ? 1 : 0
  name                  = "${var.name}-forwarding-rule"
  project               = var.project_id
  ip_protocol           = "TCP"
  port_range            = "443"
  ip_address            = google_compute_global_address.external_ip[0].address
  target                = google_compute_target_https_proxy.external[0].id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

// --- Internal Load Balancer Resources (for Frontend) ---

resource "google_compute_region_network_endpoint_group" "frontend_internal_neg" {
  count                 = var.enable_cloud_run_frontend && var.frontend_load_balancer_type == "INTERNAL" ? 1 : 0
  name                  = "${local.name_prefix}-frontend-internal-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  project               = var.project_id
  cloud_run { service = google_cloud_run_v2_service.frontend[0].name }
}

resource "google_compute_region_backend_service" "frontend_internal_backend" {
  count                 = var.enable_load_balancer && var.enable_cloud_run_frontend && var.frontend_load_balancer_type == "INTERNAL" ? 1 : 0
  name                  = "${local.name_prefix}-frontend-internal-backend"
  project               = var.project_id
  protocol              = "HTTPS"
  load_balancing_scheme = "INTERNAL_MANAGED"
  backend { group = google_compute_region_network_endpoint_group.frontend_internal_neg[0].id }
}

resource "google_compute_managed_ssl_certificate" "frontend_internal" {
  count   = var.enable_load_balancer && var.internal_load_balancer_domain != "" && var.frontend_load_balancer_type == "INTERNAL" ? 1 : 0
  name    = "${var.name}-frontend-internal-ssl-cert"
  project = var.project_id
  managed { domains = [var.internal_load_balancer_domain] }
}

resource "google_compute_region_url_map" "frontend_internal" {
  count           = var.enable_load_balancer && var.frontend_load_balancer_type == "INTERNAL" ? 1 : 0
  name            = "${var.name}-frontend-internal-url-map"
  project         = var.project_id
  region          = var.region
  default_service = google_compute_region_backend_service.frontend_internal_backend[0].id
}

resource "google_compute_region_target_https_proxy" "frontend_internal" {
  count            = var.enable_load_balancer && var.internal_load_balancer_domain != "" && var.frontend_load_balancer_type == "INTERNAL" ? 1 : 0
  name             = "${var.name}-frontend-internal-https-proxy"
  project          = var.project_id
  region           = var.region
  url_map          = google_compute_region_url_map.frontend_internal[0].id
  ssl_certificates = [google_compute_managed_ssl_certificate.frontend_internal[0].id]
}

resource "google_compute_forwarding_rule" "frontend_internal" {
  count                 = var.enable_load_balancer && var.internal_load_balancer_domain != "" && var.frontend_load_balancer_type == "INTERNAL" ? 1 : 0
  name                  = "${var.name}-frontend-internal-forwarding-rule"
  project               = var.project_id
  ip_protocol           = "TCP"
  port_range            = "443"
  network               = data.google_compute_network.main.id
  subnetwork            = data.google_compute_subnetwork.main.id
  target                = google_compute_region_target_https_proxy.frontend_internal[0].id
  load_balancing_scheme = "INTERNAL_MANAGED"
}

// --- Internal Load Balancer Resources (for Backend) ---

resource "google_compute_region_network_endpoint_group" "backend_neg" {
  count                 = var.enable_cloud_run_backend ? 1 : 0
  name                  = "${var.name}-backend-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  project               = var.project_id
  cloud_run { service = google_cloud_run_v2_service.backend[0].name }
}

resource "google_compute_region_backend_service" "backend_backend" {
  count                 = var.enable_cloud_run_backend ? 1 : 0
  name                  = "${var.name}-backend-internal"
  protocol              = "HTTPS"
  load_balancing_scheme = "INTERNAL_MANAGED"
  region                = var.region
  project               = var.project_id
  backend { group = google_compute_region_network_endpoint_group.backend_neg[0].id }
}

resource "google_compute_managed_ssl_certificate" "backend_internal" {
  count   = var.enable_load_balancer && var.internal_load_balancer_domain != "" ? 1 : 0
  name    = "${var.name}-backend-internal-ssl-cert"
  project = var.project_id
  managed { domains = [var.internal_load_balancer_domain] }
}

resource "google_compute_region_url_map" "internal" {
  count           = var.enable_cloud_run_backend ? 1 : 0
  name            = "${var.name}-internal-url-map"
  region          = var.region
  project         = var.project_id
  default_service = google_compute_region_backend_service.backend_backend[0].id
}

resource "google_compute_region_target_https_proxy" "internal" {
  count            = var.enable_cloud_run_backend && var.internal_load_balancer_domain != "" ? 1 : 0
  name             = "${var.name}-internal-https-proxy"
  project          = var.project_id
  region           = var.region
  url_map          = google_compute_region_url_map.internal[0].id
  ssl_certificates = [google_compute_managed_ssl_certificate.backend_internal[0].id]
}

resource "google_compute_forwarding_rule" "internal" {
  count                 = var.enable_cloud_run_backend && var.internal_load_balancer_domain != "" ? 1 : 0
  name                  = "${var.name}-internal-fwd-rule"
  ip_protocol           = "TCP"
  port_range            = "443"
  network               = data.google_compute_network.main.id
  subnetwork            = data.google_compute_subnetwork.main.id
  target                = google_compute_region_target_https_proxy.internal[0].id
  load_balancing_scheme = "INTERNAL_MANAGED"
  project               = var.project_id
  region                = var.region
}
