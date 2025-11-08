# This root file is included by all applications in the 'live' directory.
# It performs the configuration merge logic automatically.

# 1. Automatically load and merge all environment variables
locals {
  # Load the global defaults from the root env.hcl
  # Use read_hcl instead of the deprecated read_terragrunt_file
  global_defaults = read_terragrunt_config("${get_repo_root()}//env.hcl")

  # Find and load the nearest environment-specific env.hcl
  # Use read_hcl here as well
  environment_defaults = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  gcp_region             = local.global_defaults.locals.region
  gcp_zone               = local.global_defaults.locals.zone
  gcp_iac_project_id     = local.global_defaults.locals.gcp_iac_project_id
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
    provider = google.tokegen
    target_service_account = "${local.environment_defaults.impersonate_service_account}"
    lifetime = "1000s"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  provider "google" {
    region  = "${local.gcp_region}"
    zone    = "${local.gcp_zone}" 
    project = "${local.gcp_iac_project_id}"
    access_token = data.google_service_account_access_token.default.access_token
  }

  terraform {
    backend "gcs" {
      bucket   = "tf-iac-state-dmartinez"
      prefix   = "${path_relative_to_include()}/terraform.tfstate"
      impersonate_service_account = "${local.environment_defaults.impersonate_service_account}"
      project  = "${local.gcp_iac_project_id}"
      location = "${local.gcp_region}"
    }
  }

  EOF
  }

# 3. Define the base 'inputs' block
#  This block will be inherited and merged by every application.
inputs = merge(
  local.global_defaults.locals,
  local.environment_defaults.locals
  name = basename(get_terragrunt_dir()),
  application_label = basename(get_terragrunt_dir())
)