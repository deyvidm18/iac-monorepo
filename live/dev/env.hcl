locals {
  // --- Environment-level Variables ---
  project_id         = "dev-iac-demo"
  environment        = "dev"
  vpc_name           = "my-dev-vpc"
  network_project_id = "sha-dmartinez-network"
  subnet_name        = "dev-us-central1"
  private_ip_allocation_name = "dev-private-services-access"
  proxy_only_subnet_name   = "dev-proxy-subnet"
  environment_label = local.environment
}