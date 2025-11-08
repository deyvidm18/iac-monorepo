# This root file is included by all applications in the 'live' directory.
# It performs the configuration merge logic automatically.

# 1. Automatically load and merge all environment variables
locals {
  # Load the global defaults from the root env.hcl
  # Use read_hcl instead of the deprecated read_terragrunt_file
  global_defaults = read_terragrunt_config("${get_repo_root()}//env.hcl").locals

  # Find and load the nearest environment-specific env.hcl
  # Use read_hcl here as well
  environment_defaults = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals

  # Extract the variables we need for easy access
  gcp_region             = local.global_defaults.region
  gcp_zone               = local.global_defaults.zone
  gcp_iac_project_id     = local.global_defaults.gcp_iac_project_id
}

# 2. Generate the GCP provider block
#    This dynamically inserts the correct project and region into the provider.tf
#    file for every application.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
  
  provider "google" {
    alias = "tokegen"
    region  = "${local.gcp_region}"
    zone    = "${local.gcp_zone}"
    project = "${local.gcp_iac_project_id}"
  }

  data "google_client_config" "default" {
    provider = google.tokegen
  }

  data "google_service_account_access_token" "default" {
    provider               = google.tokegen
    target_service_account = "${local.environment_defaults.impersonate_service_account}"
    lifetime               = "1000s"
    scopes                 = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  provider "google" {
    region  = "${local.gcp_region}"
    zone    = "${local.gcp_zone}" 
    project = "${local.gcp_iac_project_id}"
    access_token = data.google_service_account_access_token.default.access_token
  }

  EOF
  }

# Remote State GCS
 remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket                      = local.global_defaults.tf_bucket
    prefix                      = "${path_relative_to_include()}/terraform.tfstate"
    project                     = local.gcp_iac_project_id
    location                    = local.gcp_region
    impersonate_service_account = "${local.environment_defaults.impersonate_service_account}"
  }
} 

#  4. Define the base 'inputs' block
#  This block will be inherited and merged by every application.
inputs = merge(
  local.global_defaults,
  local.environment_defaults,
  {
    name = basename(get_terragrunt_dir())
    application_label = basename(get_terragrunt_dir())
  }
)