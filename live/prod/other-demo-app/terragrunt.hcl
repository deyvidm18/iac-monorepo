# 1. Include the root configuration.
# This automatically brings in the 'remote_state' block and the
# 'inputs' block containing the merged dev environment config.
include "root" {
  path = "${get_repo_root()}//root.hcl"
}

# 2. Point to the Terraform Module this application uses.
terraform {
  source = "${get_repo_root()}//modules/serverless-stack-platform"
}

# 3. Define local overrides specific to THIS application.
#    This block is optional. If you have no overrides, you can delete it.
locals {
  # Example: Override the CPU for the 'small' size
  t_shirt_overrides = {
    t_shirt_sizes = {
      small = {
        cloud_run_cpu = 2 # app1 in dev needs 2 CPUs
      }
    }
  }
}

# 4. Define the final 'inputs'.
#    Terragrunt automatically deep-merges this block with the 'inputs'
#    from the 'include' block.
inputs = merge(
  local.t_shirt_overrides, # Your app-specific overrides
  {
    team_label        = "my-team"
  }
)