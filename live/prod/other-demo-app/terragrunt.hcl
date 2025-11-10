include "root" {
  path = "${get_repo_root()}//root.hcl"
  merge_strategy = "deep"
}

terraform {
  source = "${get_repo_root()}//modules/serverless-stack-platform"
}

inputs = {
  cloud_run_cpu       = 2 # app1 in dev needs 2 CPUs
  team_label          = "my-team"
  enable_memorystore  = false
}