# 1. Include the root configuration.
# This automatically brings in the 'remote_state' block and the
# base 'inputs' block (with all merged dev environment config).
include "root" {
  path = "${get_repo_root()}//root.hcl"
  merge_strategy = "deep"

}

# 2. Point to the Terraform Module this application uses.
terraform {
  source = "${get_repo_root()}//modules/serverless-stack-platform"
}

# 3. Define ONLY your overrides and dynamic values.
# Terragrunt will automatically deep-merge this with the
# 'inputs' block from your root.hcl.
inputs = {
  # Automatically get the directory name ("app1") and pass it
  # to the module's 'name' variable.
  name = basename(get_terragrunt_dir())
  application_label = basename(get_terragrunt_dir())
  team_label        = "my-team"
  force_destroy     = true
  sizing = "medium"
  t_shirt_sizes = {
    medium = {
      cloud_run_cpu = 4
      cloud_run_memory = "8Gi"
    }
  }
}