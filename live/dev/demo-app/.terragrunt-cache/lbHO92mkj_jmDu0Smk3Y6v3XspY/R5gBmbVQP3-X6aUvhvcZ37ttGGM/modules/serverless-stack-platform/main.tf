terraform {
  backend "gcs" {}
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.9.0"
    }
  }
}

locals {
  config      = var.t_shirt_sizes[var.sizing]
  name_prefix = var.name

  enabled_apis = {
    "run.googleapis.com"               = var.enable_cloud_run_frontend || var.enable_cloud_run_backend
    "sqladmin.googleapis.com"          = var.enable_cloud_sql
    "firestore.googleapis.com"         = var.enable_firestore
    "redis.googleapis.com"             = var.enable_memorystore
    "pubsub.googleapis.com"            = var.enable_pubsub_topics
    "compute.googleapis.com"           = var.enable_load_balancer
    "iam.googleapis.com"               = true // Always needed
    "vpcaccess.googleapis.com"         = var.enable_cloud_run_frontend || var.enable_cloud_run_backend
    "iap.googleapis.com"               = var.enable_iap
    "servicenetworking.googleapis.com" = var.enable_cloud_sql || var.enable_memorystore
  }
}

resource "google_project_service" "apis" {
  for_each = {
    for api, enabled in local.enabled_apis : api => enabled if enabled
  }

  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}