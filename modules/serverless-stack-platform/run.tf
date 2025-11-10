data "google_compute_subnetwork" "main" {
  project = var.network_project_id
  name    = var.subnet_name
  region  = var.region
}

locals {
  frontend_ingress = var.frontend_load_balancer_type == "EXTERNAL" ? "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER" : "INGRESS_TRAFFIC_INTERNAL_ONLY"
}

resource "google_cloud_run_v2_service" "frontend" {
  count    = var.enable_cloud_run_frontend ? 1 : 0
  name     = "${var.name}-frontend"
  location = var.region
  project  = var.project_id
  ingress  = local.frontend_ingress
  labels   = local.labels
  default_uri_disabled = var.disable_default_url
  template {
    service_account = google_service_account.frontend[0].email
    scaling {
      min_instance_count = local.config.cloud_run_min_instances
      max_instance_count = local.config.cloud_run_max_instances
    }
    containers {
      image = var.frontend_container_image
      resources {
        limits = { cpu = local.config.cloud_run_cpu, memory = local.config.cloud_run_memory }
      }
    }
    vpc_access {
      network_interfaces {
        network    = data.google_compute_network.main.id
        subnetwork = data.google_compute_subnetwork.main.id
      }
      egress = var.frontend_vpc_egress
    }
  }
}



resource "google_cloud_run_v2_service" "backend" {
  count    = var.enable_cloud_run_backend ? 1 : 0
  name     = "${var.name}-backend"
  location = var.region
  project  = var.project_id
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  labels   = local.labels
  default_uri_disabled = var.disable_default_url
  template {
    service_account = google_service_account.backend[0].email
    scaling {
      min_instance_count = local.config.cloud_run_min_instances
      max_instance_count = local.config.cloud_run_max_instances
    }
    containers {
      image = var.backend_container_image
      resources {
        limits = { cpu = local.config.cloud_run_cpu, memory = local.config.cloud_run_memory }
      }
    }
    vpc_access {
      network_interfaces {
        network    = data.google_compute_network.main.id
        subnetwork = data.google_compute_subnetwork.main.id
      }
      egress = var.backend_vpc_egress
    }
  }
}