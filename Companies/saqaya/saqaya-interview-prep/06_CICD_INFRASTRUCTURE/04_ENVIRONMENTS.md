# Environment Strategy

## Environment Pipeline
A standard pipeline consists of progression through isolated environments to ensure quality and reliability before hitting users.

1. **Development (Dev):** Unstable, bleeding-edge. Where developers test their merged code. Often ephemeral or frequently wiped.
2. **Staging / Pre-Production:** Must be as identical to production as possible (Environment Parity). Used for final QA, load testing, and UAT (User Acceptance Testing).
3. **Production:** Live user traffic. Highly restricted access.

## Environment Parity
Keeping dev, staging, and prod as similar as possible (Twelve-Factor App methodology).
- **Why:** "It works on my machine" or "It worked in dev" are solved by parity.
- **How:** Use Docker to ensure the runtime is identical. Use Terraform to ensure infrastructure configurations are identical (only differing in scale, e.g., instance sizes).

## Configuration Management
Externalize configuration from code.
- Use environment variables (via ECS Task Definitions, K8s ConfigMaps, or `.env` files).
- Keep code immutable; change the behavior by promoting the same artifact across environments and injecting different configs.

## Preview / Ephemeral Environments
Spawn a completely new, isolated environment for every Pull Request.
- **How:** When a PR is opened, a CI action provisions a lightweight namespace (e.g., in Kubernetes) or AWS ECS cluster, deploys the code, seeds a minimal DB, and comments the unique URL on the PR. When closed, it destroys it.
- **Value:** Enables product managers and QA to test features before they are merged to main.

## Secrets Management Per Environment
- Staging and Production secrets MUST be strictly separated.
- Devs should not have access to Production secrets.
- Use IAM roles and KMS to strictly control which environment (running in which AWS account/VPC) can access which secrets.

## Cost Optimization for Non-Prod
- **Instance Types:** Use t3.micro/small in dev, m5.large in prod.
- **Spot Instances:** Run non-critical dev/staging workloads on AWS Spot Instances to save up to 90%.
- **Schedules:** Shut down dev/staging environments outside of working hours (e.g., stop EC2/RDS at 7 PM, start at 7 AM) using AWS Instance Scheduler.
- **Single-AZ:** Do not use Multi-AZ for RDS in non-prod.

## Interview Questions
**Q: How do you manage database connections across different environments?**
A: The application should read the database connection string (host, port, user, password) from environment variables or a secrets manager at runtime. The deployment pipeline injects the correct values based on the target environment. The application code never knows which environment it is in.

**Q: Staging works perfectly, but Production is failing. What are the common culprits?**
A: 
1. **Data differences:** Production has vastly more data, leading to slow queries/timeouts not seen in staging.
2. **Configuration drift:** A missing environment variable in the prod deployment config.
3. **Scale/Load:** Concurrency issues or rate limits hit only under prod traffic.
4. **Third-party integrations:** Prod hits real APIs (Stripe, Twilio) while staging hits sandboxes.
5. **Permissions:** The IAM role in Prod lacks permissions granted in Staging.
