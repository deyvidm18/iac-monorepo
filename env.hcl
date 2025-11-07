locals {
  // Global Defaults
  region = "us-central1"
  zone   = "us-central1-a"
  gcp_iac_project_id = "dev-iac-demo"

  // T-Shirt Sizing
  t_shirt_sizes = {
    small = {
      cloud_run_cpu           = 1
      cloud_run_memory        = "512Mi"
      cloud_run_min_instances = 0
      cloud_run_max_instances = 1
      cloudsql_tier           = "db-g1-small"
      cloudsql_ha             = false
      memorystore_size_gb     = 1
      memorystore_tier        = "BASIC"
    }
    medium = {
      cloud_run_cpu           = 2
      cloud_run_memory        = "1Gi"
      cloud_run_min_instances = 1
      cloud_run_max_instances = 5
      cloudsql_tier           = "db-custom-8-32768"
      cloudsql_ha             = true
      memorystore_size_gb     = 5
      memorystore_tier        = "STANDARD_HA"
    }
    large = {
      cloud_run_cpu           = 4
      cloud_run_memory        = "2Gi"
      cloud_run_min_instances = 2
      cloud_run_max_instances = 10
      cloudsql_tier           = "db-perf-optimized-N-16"
      cloudsql_ha             = true
      memorystore_size_gb     = 10
      memorystore_tier        = "STANDARD_HA"
    }
  }
  sizing = "small"

  // DNS Configuration
  dns_project_id        = "sha-dmartinez-network"
  public_dns_zone_name  = "dmartinezg-demodmartinezg"
  private_dns_zone_name = "mydomain"
  base_domain           = "demo.altostrat.com"
  iap_support_email     = "gemini-cli-dev-sa@google.com"
}
