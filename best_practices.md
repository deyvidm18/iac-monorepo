# Module Versioning Best Practices

To ensure stability and predictability in your infrastructure, it is recommended to version your Terraform modules and consume them via Git tags rather than local paths.

## Why Version Modules?

1.  **Isolation**: Changes to a module do not immediately affect all environments. You can release a new version and upgrade environments one by one.
2.  **Predictability**: You know exactly what code is running in production. It won't change unless you explicitly update the version tag.
3.  **Rollback**: If a new version introduces a bug, you can easily revert to the previous version tag.

## How to Version Modules

1.  **Separate Repository (Recommended)**: Move your `modules/` directory to a dedicated Git repository (e.g., `infrastructure-modules`).
2.  **Tagging**: When you make changes to a module, tag the commit with a semantic version (e.g., `v1.0.0`, `v1.1.0`).

## How to Consume Versioned Modules

In your `terragrunt.hcl` files, update the `terraform { source = ... }` block to point to the Git repository with a specific tag.

### Example

**Before (Local Path):**

```hcl
terraform {
  source = "${get_repo_root()}//modules/serverless-stack-platform"
}
```

**After (Git URL with Tag):**

```hcl
terraform {
  source = "git::https://github.com/my-org/infrastructure-modules.git//serverless-stack-platform?ref=v1.0.0"
}
```

## Workflow for Updates

1.  **Update Module**: Make changes in the modules repository.
2.  **Release**: Tag a new version (e.g., `v1.1.0`).
3.  **Test**: Update `live/dev/app1/terragrunt.hcl` to use `ref=v1.1.0`. Run `terragrunt plan` and `apply`.
4.  **Promote**: Once tested, update `live/prod/app1/terragrunt.hcl` to use `ref=v1.1.0`.

This workflow prevents accidental breakage of production environments when modifying shared modules.
