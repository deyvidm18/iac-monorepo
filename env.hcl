locals {
  // Global Defaults
  region = "us-central1"
  zone   = "us-central1-a"
  gcp_iac_project_id = "dev-iac-demo"
  tf_bucket = "tf-iac-state-dmartinez"

  // T-Shirt Sizing
    small = {
      cloud_run_cpu           = 1
      cloud_run_memory        = "512Mi"
      cloud_run_min_instances = 0
      cloud_run_max_instances = 5
      cloud_run_concurrency   = 20
      cloudsql_tier           = "db-standard-2"
      cloudsql_edition        = "ENTERPRISE"
      cloudsql_ha             = false
      cloudsql_data_cache     = false
      cloudsql_disk_size      = 25
      memorystore_size_gb     = 1
      memorystore_tier        = "BASIC"
      memorystore_replica_count = 0
      pubsub_retention        = "604800s" # 7 days
    }
    medium = {
      cloud_run_cpu           = 2
      cloud_run_memory        = "4Gi"
      cloud_run_min_instances = 5
      cloud_run_max_instances = 20 # Assuming max > min
      cloud_run_concurrency   = 20
      cloudsql_tier           = "db-perf-optimized-8"
      cloudsql_edition        = "ENTERPRISE_PLUS"
      cloudsql_ha             = true
      cloudsql_data_cache     = true
      cloudsql_disk_size      = 200
      memorystore_size_gb     = 10
      memorystore_tier        = "STANDARD_HA"
      memorystore_replica_count = 1
      pubsub_retention        = "604800s"
    }
    large = {
      cloud_run_cpu           = 4
      cloud_run_memory        = "8Gi"
      cloud_run_min_instances = 10
      cloud_run_max_instances = 20 # Assuming max > min
      cloud_run_concurrency   = 20
      cloudsql_tier           = "db-perf-optimized-16"
      cloudsql_edition        = "ENTERPRISE_PLUS"
      cloudsql_ha             = true
      cloudsql_data_cache     = true
      cloudsql_disk_size      = 500
      memorystore_size_gb     = 20
      memorystore_tier        = "STANDARD_HA"
      memorystore_replica_count = 2
      pubsub_retention        = "604800s"
    }
  }
  sizing = "small"

  // DNS Configuration
  dns_project_id        = "sha-dmartinez-network"
  public_dns_zone_name  = "dmartinezg-demodmartinezg"
  private_dns_zone_name = "mydomain"
  base_domain           = "demo.altostrat.com"
  iap_support_email     = "gemini-cli-dev-sa@google.com"

  iam_profiles = {
    viewer = [
      "roles/cloudsql.viewer",
      "roles/datastore.viewer",
      "roles/run.viewer",
      "roles/redis.viewer",
      "roles/pubsub.viewer",
      "roles/iap.viewer",
    ]
    developer = [
      "roles/run.developer",
      "roles/cloudsql.client",
      "roles/datastore.user",
      "roles/redis.editor",
      "roles/pubsub.editor",
    ]
    web_user = [
      "roles/iap.httpsResourceAccessor",
    ]
  }
}