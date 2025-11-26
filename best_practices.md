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


## Linting, Formatting, and Testing

To ensure high code quality and security, we recommend the following practices and tools.

### 1. Formatting (`terraform fmt` / `terragrunt fmt`)
Always format your code before committing. This ensures a consistent style across the codebase.
- **Tool**: `terraform fmt` (for modules), `terragrunt fmt` (for live config)
- **Usage**: `terragrunt hclfmt` or `terraform fmt -recursive`

### 2. Linting (`tflint` / `terragrunt validate`)
Use `tflint` to catch errors and enforce best practices. Use `terragrunt validate` to ensure your configuration is valid.
- **Tool**: [TFLint](https://github.com/terraform-linters/tflint)
- **Usage**: `tflint`

### 3. Security Scanning (`trivy`)
Scan your code for security vulnerabilities (e.g., open firewalls, public buckets, missing encryption). `tfsec` is deprecated, so we use `trivy`.
- **Tool**: [Trivy](https://github.com/aquasecurity/trivy)
- **Usage**: `trivy config .`

### 4. Integration Testing (`terratest`)
For critical modules, write automated tests using Terratest (Go). This allows you to deploy real infrastructure, validate it, and tear it down.
- **Tool**: [Terratest](https://terratest.gruntwork.io/)
- **Best Practice**: Create a `test/` directory in your module and write Go tests to verify inputs/outputs and side effects.

### 5. Pre-commit Hooks
We have configured `pre-commit` to automate these checks, including `terragrunt fmt` and `terragrunt validate`.

**Setup:**
1.  Install pre-commit: `brew install pre-commit`
2.  Install hooks: `pre-commit install`

**Workflow:**
Every time you run `git commit`, these hooks will run automatically. If any check fails (e.g., code not formatted), the commit will be blocked until you fix the issue (or the hook fixes it for you).

### 6. Pre-commit Security & Risks
Since we are using third-party pre-commit hooks (e.g., from `github.com/antonbabenko/pre-commit-terraform`), there are some considerations:

-   **Supply Chain Risk**: You are trusting the maintainer of the hook repository. If their repository is compromised, malicious code could theoretically run on your machine.
-   **Mitigation**: We **pin** the version of the hooks (e.g., `rev: v1.88.0`) in `.pre-commit-config.yaml`. This ensures that even if the upstream repository changes, we continue using the known, safe version. Never use `rev: master` or `rev: latest`.
-   **Enterprise/Strict Option**: If your organization forbids third-party hooks, you can configure `pre-commit` to use **local** hooks. This requires every developer to install the tools (`tflint`, `trivy`, etc.) manually, and the hook simply calls the local binary. This removes the dependency on external repositories but increases setup complexity.

