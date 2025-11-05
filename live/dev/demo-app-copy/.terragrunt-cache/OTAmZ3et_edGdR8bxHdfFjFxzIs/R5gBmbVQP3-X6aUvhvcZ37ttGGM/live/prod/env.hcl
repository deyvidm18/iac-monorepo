locals {
  // --- Environment-level Variables ---
  project_id   = "prod-iac-demo"
  environment  = "prod"
  vpc_name = "my-prod-vpc"
  network_project_id = "sha-dmartinez-network"
  subnet_name        = "prod-us-central1"
  private_ip_allocation_name = "dev-private-services-access"
  proxy_only_subnet_name   = "dev-proxy-subnet"
  environment_label = local.environment
}