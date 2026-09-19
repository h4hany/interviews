# CI/CD Deep Dive

## CI/CD Philosophy and Principles
Continuous Integration (CI) is the practice of merging all developers' working copies to a shared mainline several times a day. Continuous Delivery (CD) ensures that the software can be released reliably at any time. Continuous Deployment automatically deploys every change that passes the automated tests to production.

**Core Principles:**
- **Single Source of Truth:** Version control for code, configuration, and infrastructure.
- **Automate Everything:** Builds, tests, deployments, and rollbacks.
- **Keep the Build Fast:** Fast feedback loop for developers.
- **Build Once, Deploy Anywhere:** Artifacts should be immutable across environments.
- **Fail Fast:** Detect issues as early in the pipeline as possible.

## GitHub Actions Deep Dive
GitHub Actions (GHA) provides powerful event-driven workflows natively integrated into GitHub.

**Concepts:**
- **Workflows:** YAML files defining the automated process, triggered by events (push, pull_request, schedule, workflow_dispatch).
- **Jobs:** A set of steps that execute on the same runner. Jobs run in parallel by default.
- **Steps:** Individual tasks (run a script, use an action) executed sequentially.
- **Runners:** Servers that run your workflows (GitHub-hosted or self-hosted).
- **Actions:** Reusable units of code (JavaScript or Docker container).

### Reusable Workflows vs Composite Actions
- **Reusable Workflows:** `workflow_call` trigger. Good for standardizing entire pipelines across multiple repositories.
- **Composite Actions:** Groups multiple steps into a single action. Good for standardizing specific tasks (e.g., setup node, install deps, run linter) within a job.

### Matrix Strategies
Used to run jobs across multiple combinations (e.g., node versions, operating systems).
```yaml
strategy:
  matrix:
    node-version: [18.x, 20.x]
    os: [ubuntu-latest, windows-latest]
```

## GitLab CI Comparison
- **Configuration:** GHA uses `.github/workflows/*.yml`, GitLab uses a single `.gitlab-ci.yml` (can include others).
- **Execution:** GitLab uses Runners with Executors (Docker, Shell, Kubernetes). GHA uses Runners (hosted VMs or self-hosted).
- **Ecosystem:** GHA has the Marketplace; GitLab relies heavily on docker images and CI templates.

## Pipeline Design Patterns
- **Trunk-Based Development:** Short-lived feature branches, frequent merges to main. CI runs on every commit to main and PRs.
- **GitFlow:** Strict branching model (main, develop, feature, release, hotfix). Complex pipelines tied to specific branches.
- **Monorepos:** Use path filtering to only trigger pipelines for changed services.
  ```yaml
  on:
    push:
      paths:
        - 'services/auth/**'
  ```

## Testing in CI
1. **Unit Tests:** Run first, must be extremely fast. Fail immediately.
2. **Integration Tests:** Test interactions between components (requires databases, caching layers).
3. **E2E Tests:** Run against a fully deployed (often ephemeral) environment.
4. **Performance Tests:** Load testing (e.g., k6) before production deployment.

## Static Analysis and Security Scanning
- **Linting & Type Checking:** ESLint, Prettier, MyPy, TypeScript compiler.
- **SAST (Static Application Security Testing):** CodeQL, SonarQube, Bandit (Python).
- **DAST (Dynamic Application Security Testing):** OWASP ZAP.
- **Dependency Scanning:** Dependabot, Snyk.

## Artifact Management
Build artifacts (Docker images, binaries, tarballs) should be built once, hashed, and stored in an artifact repository (GHCR, AWS ECR, Artifactory).

## Environment Promotion
Build -> Staging (manual/auto deploy) -> Production (manual gate).
Use GitHub Environments to require manual approval before deploying to production.

## Pipeline Security
- **Supply Chain Attacks:** Pin actions to commit SHAs instead of tags.
- **SLSA:** Supply-chain Levels for Software Artifacts framework to ensure provenance and integrity.
- **OIDC:** Use OpenID Connect to authenticate with AWS/GCP instead of long-lived secrets.

## Interview Questions
**Q: How do you handle secrets in CI/CD?**
A: Use native secret stores (GitHub Secrets), inject them at runtime. Better yet, use OIDC for cloud provider authentication to avoid storing static credentials. For application secrets, use a secrets manager (AWS Secrets Manager, HashiCorp Vault) and pull them during deployment or at app startup, never burning them into the artifact.

**Q: How do you optimize a slow CI pipeline?**
A: 
1. Caching: Cache dependencies (node_modules, pip cache) and docker layers.
2. Parallelization: Split tests across multiple runners using matrix strategies or sharding.
3. Fail Fast: Run linters and fast unit tests first.
4. Resource Sizing: Use larger runners for heavy jobs.
5. Selective execution: Only run tests for changed modules in a monorepo.
