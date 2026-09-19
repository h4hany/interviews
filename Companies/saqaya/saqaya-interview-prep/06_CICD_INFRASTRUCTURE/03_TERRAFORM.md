# Terraform Deep Dive

## Terraform Fundamentals
Infrastructure as Code (IaC) tool by HashiCorp to provision and manage any cloud, infrastructure, or service. It is declarative.

- **Providers:** Plugins (e.g., AWS, GCP, GitHub) that understand API interactions.
- **Resources:** The fundamental units in Terraform (e.g., `aws_instance`). Defines infrastructure objects.
- **Data Sources:** Allows Terraform to fetch data computed elsewhere or by a separate configuration (e.g., fetching an existing AMI ID).

## State Management
State (`terraform.tfstate`) maps real-world resources to your configuration, keeps track of metadata, and improves performance.
- **Remote State:** State must be stored remotely in a team environment (S3 + DynamoDB, Terraform Cloud).
- **State Locking:** Prevents concurrent runs from corrupting the state file. DynamoDB is often used with S3 for this.
- **Workspaces:** Allows multiple states associated with a single configuration directory. Useful for identical dev/staging/prod environments, but separate directories/repos are often safer for production.

## Modules
Containers for multiple resources that are used together.
- **Design:** Keep them small, reusable, and versioned. Pass variables in, export outputs.
- **Registry:** Publish modules to Terraform Registry or private Git repositories.

## Best Practices
- **Code Organization:** Separate state by environment and domain (e.g., `prod/network/`, `prod/app/`) to limit the blast radius.
- **Naming & Tagging:** Standardize resource naming and apply consistent tags (Environment, Owner, CostCenter) using `default_tags` at the provider level.

## CI/CD for Terraform
1. **PR Created:** Run `terraform fmt -check`, `tflint`, `tfsec` (SAST), and `terraform plan`.
2. **PR Review:** Reviewers check the plan output to see exactly what will change.
3. **Merge to Main:** Run `terraform apply -auto-approve`.

## Terraform vs Alternatives
- **CloudFormation:** AWS only, JSON/YAML, slower updates, native AWS integration.
- **CDK:** Imperative (TypeScript/Python), generates CloudFormation. Great for developers, harder for Ops pure-play.
- **Pulumi:** Imperative, supports many languages, uses state file like Terraform.
- **Terraform:** Declarative (HCL), multi-cloud, massive ecosystem.

## Drift Detection
Drift occurs when manual changes are made in the AWS console, diverging from the Terraform state.
- **Detection:** Running `terraform plan` will identify drift.
- **Resolution:** Re-apply the Terraform (overwrites manual changes) or update the Terraform code to match the manual change if it was an intentional hotfix.

## Interview Questions
**Q: How do you handle secrets in Terraform?**
A: Never hardcode them. Never commit them. Use external secret managers (AWS Secrets Manager, HashiCorp Vault). Use Terraform data sources to pull them at apply time, and mark the variables/outputs as `sensitive = true` so they aren't printed to the console logs. Note that they *will* still be stored in the state file in plain text, which is why the remote state backend (S3) must be strictly access-controlled and encrypted at rest.

**Q: You get a "state lock error" when running terraform plan. What happened and how do you fix it?**
A: Another pipeline or team member is currently running an operation that locks the state (e.g., applying). If the previous process crashed or lost network connection, a stale lock might be left behind. You can force-unlock it using `terraform force-unlock <LOCK_ID>`, but only after strictly verifying no other process is actively modifying infrastructure.

**Q: Explain "Blast Radius" in Terraform.**
A: The impact if a terraform apply goes horribly wrong. If you put all your AWS infrastructure (VPC, RDS, ECS, IAM) in one giant state file, a mistake could destroy everything. By breaking state into smaller, logical pieces (e.g., base network, database, app tier), you minimize the blast radius.
