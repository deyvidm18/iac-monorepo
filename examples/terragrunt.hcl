include "root" {
  path = "${get_repo_root()}//root.hcl"
  merge_strategy = "deep"
}

terraform {
  source = "${get_repo_root()}//modules/serverless-stack-platform"
}

inputs = {
  # The team responsible for the application. This is a required label.
  team_label = "my-team"

  # --- Overriding Module Variables ---
  # You can override any variable from the serverless-stack-platform module here.
  # For example, to enable the backend service and change its machine type:
  #
  # enable_cloud_run_backend = true
  # sizing = "medium"
  # cloud_run_cpu = 4
  # cloud_run_memory = "8Gi"
}
