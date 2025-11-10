# Gemini Guidelines for IAC Monorepo

This document provides guidelines for Gemini when working with this IAC (Infrastructure as Code) monorepo. The primary goal is to ensure that all infrastructure deployed through this repository follows Google Cloud's best practices, as outlined in the [Google Cloud Architecture Framework](https://docs.cloud.google.com/architecture/framework).

## Core Principles

When making changes to this repository, Gemini must adhere to the following core principles:

1.  **Security by Design:** Security is the top priority. All infrastructure changes must be designed with security in mind, following the principle of least privilege and defense in depth.
2.  **Cost Optimization:** All resources should be configured to be cost-effective, using the appropriate machine types, storage classes, and scaling policies.
3.  **Reliability and Resilience:** Infrastructure should be designed to be reliable and resilient, with appropriate redundancy, failover mechanisms, and disaster recovery plans.
4.  **Operational Excellence:** All changes should be automated, monitored, and logged to ensure operational excellence.
5.  **Performance Optimization:** Services should be configured for optimal performance, considering factors such as latency, throughput, and resource utilization.

## Google Cloud Architecture Framework

Gemini must be familiar with and apply the principles from the [Google Cloud Architecture Framework](https://docs.cloud.google.com/architecture/framework) in all its work. The framework consists of six pillars:

1.  **System Design:** Follow the recommended best practices for designing and building systems on Google Cloud.
2.  **Operational Excellence:** Implement best practices for automating and managing your Google Cloud environment.
3.  **Security, Privacy, and Compliance:** Ensure that your architecture and implementation meet your security, privacy, and compliance requirements.
4.  **Reliability:** Build reliable and resilient applications on Google Cloud.
5.  **Cost Optimization:** Optimize the cost of your Google Cloud resources.
6.  **Performance Optimization:** Optimize the performance of your Google Cloud resources.

## Working with Terraform and Terragrunt

-   **Use Existing Modules:** Before creating new modules, check if there are existing modules in the `modules` directory that can be reused.
-   **Keep it DRY:** Follow the "Don't Repeat Yourself" (DRY) principle by using Terragrunt's hierarchical configuration to avoid duplicating code.
-   **Centralized Configuration:** Use the root `env.hcl` file for organizational standards and the module's `variables.tf` for technical defaults.
-   **Security Best Practices:**
    -   Use dedicated service accounts with the least privilege.
    -   Enable private networking for all services.
    -   Use IAM database authentication for Cloud SQL.
    -   Protect load balancers with IAP.
    -   Disable default public URLs for Cloud Run services.
-   **Consistent Labeling:** Ensure that all resources are consistently labeled with `environment`, `application`, and `team`.

## Committing Changes

-   **Conventional Commits:** All commit messages must follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification.
-   **Clear and Concise:** Commit messages should be clear, concise, and explain the "why" behind the change.
-   **Run `terraform fmt`:** Before committing any Terraform files, run `terraform fmt` to ensure they are properly formatted.
