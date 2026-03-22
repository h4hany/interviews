# CI/CD Interview Questions

## 1. What is CI/CD?

**Answer:**
CI/CD stands for Continuous Integration and Continuous Deployment/Delivery. It automates the process of integrating code changes and deploying applications.

## 2. What is Continuous Integration (CI)?

**Answer:**
CI is the practice of frequently integrating code changes into a shared repository, with automated builds and tests.
- *Example*: Every time a developer pushes code to GitHub, a "Build" action is triggered that runs 500 unit tests. If any test fails, the team is notified immediately.

## 3. What is Continuous Delivery?

**Answer:**
Continuous Delivery ensures code is always in a deployable state, with automated testing and deployment to staging, but production deployment is manual.

## 4. What is Continuous Deployment?

**Answer:**
Continuous Deployment automatically deploys code changes to production after passing automated tests.
- *Example*: Merging a Pull Request to the `main` branch automatically triggers a deployment that updates the live website at `myapp.com` without any human clicking "Deploy".

## 5. What is the difference between Continuous Delivery and Continuous Deployment?

**Answer:**
- **Continuous Delivery**: Code is deployable, but deployment is manual.
- **Continuous Deployment**: Code is automatically deployed to production.

## 6. What are the benefits of CI/CD?

**Answer:**
- Faster time to market
- Early bug detection
- Reduced manual errors
- Consistent deployments
- Faster feedback loops
- Improved code quality

## 7. What is a CI/CD Pipeline?

**Answer:**
A CI/CD Pipeline is an automated sequence of steps that code goes through from commit to deployment (build, test, deploy).

## 8. What are the typical stages of a CI/CD Pipeline?

**Answer:**
- Source control (Git)
- Build (compile, package)
- Test (unit, integration, e2e)
- Security scanning
- Deploy to staging
- Deploy to production

## 9. What is Build Automation?

**Answer:**
Build Automation compiles source code, runs tests, and packages applications automatically.

## 10. What is the difference between Build and Deploy?

**Answer:**
- **Build**: Compiles and packages code into artifacts.
- **Deploy**: Installs and runs artifacts in an environment.

## 11. What is Artifact Repository?

**Answer:**
Artifact Repository stores build artifacts (Docker images, JAR files, npm packages) for deployment (Nexus, Artifactory, Docker Registry).

## 12. What is Pipeline as Code?

**Answer:**
Pipeline as Code defines CI/CD pipelines using code (Jenkinsfile, GitHub Actions YAML, GitLab CI YAML).

## 13. What is the difference between Declarative and Scripted Pipeline?

**Answer:**
- **Declarative**: Structured syntax, easier to read, recommended.
- **Scripted**: Groovy-based, more flexible, complex.

## 14. What is Blue-Green Deployment?

**Answer:**
Blue-Green Deployment maintains two identical environments, switching traffic from old (blue) to new (green) version for zero downtime.
- *Example*: You have v1 running on "Blue". You deploy v2 to "Green". After testing, you switch your AWS Route53 DNS to point to "Green". If v2 has a bug, you switch DNS back to "Blue" in seconds.

## 15. What is Canary Deployment?

**Answer:**
Canary Deployment gradually rolls out new version to a small percentage of users before full deployment.
- *Example*: Netflix might roll out a new recommendation algorithm to only 1% of users in Brazil to monitor its performance before giving it to the other 99%.

## 16. What is Rolling Deployment?

**Answer:**
Rolling Deployment updates instances gradually, replacing old instances with new ones incrementally.

## 17. What is Feature Flags?

**Answer:**
Feature Flags enable toggling features without code deployment, allowing gradual rollouts and A/B testing.
- *Example*: An "Under Maintenance" banner that you can turn ON or OFF via a dashboard (like LaunchDarkly) without having to rebuild or redeploy your code.

## 18. What is the difference between Staging and Production?

**Answer:**
- **Staging**: Pre-production environment for final testing.
- **Production**: Live environment serving real users.

## 19. What is Smoke Testing?

**Answer:**
Smoke Testing runs basic tests after deployment to verify the system is working (health checks, critical paths).

## 20. What is Rollback?

**Answer:**
Rollback reverts to a previous version when deployment fails or issues are detected.

## 21. What is the difference between Rollback and Rollforward?

**Answer:**
- **Rollback**: Revert to previous version.
- **Rollforward**: Fix issues and deploy new version.

## 22. What is Deployment Strategy?

**Answer:**
Deployment Strategy defines how new versions are deployed (blue-green, canary, rolling, recreate).

## 23. What is CI/CD Tool?

**Answer:**
CI/CD Tools automate the pipeline (Jenkins, GitHub Actions, GitLab CI, CircleCI, Azure DevOps, AWS CodePipeline).

## 24. What is the difference between Jenkins and GitHub Actions?

**Answer:**
- **Jenkins**: Self-hosted, highly configurable, plugin ecosystem.
- **GitHub Actions**: Cloud-hosted, integrated with GitHub, simpler setup.

## 25. What is Docker in CI/CD?

**Answer:**
Docker containerizes applications, ensuring consistent environments across development, testing, and production.

## 26. What is the difference between Build and Runtime in Containers?

**Answer:**
- **Build**: Creates container image with application and dependencies.
- **Runtime**: Runs container in target environment.

## 27. What is Multi-Stage Build?

**Answer:**
Multi-Stage Build uses multiple stages in Dockerfile to create smaller final images by copying artifacts from build stage.

## 28. What is CI/CD Security?

**Answer:**
CI/CD Security includes:
- Secret management
- Dependency scanning
- Code scanning
- Container scanning
- Infrastructure scanning

## 29. What is Secret Management in CI/CD?

**Answer:**
Secret Management securely stores and retrieves sensitive data (API keys, passwords) in CI/CD pipelines (Vault, AWS Secrets Manager).

## 30. What is Dependency Scanning?

**Answer:**
Dependency Scanning identifies vulnerable dependencies in code (OWASP, Snyk, Dependabot).

## 31. What is Code Quality Gates?

**Answer:**
Code Quality Gates enforce quality standards before deployment (test coverage, code complexity, security scans).

## 32. What is the difference between Unit Tests and Integration Tests in CI?

**Answer:**
- **Unit Tests**: Test individual components in isolation (fast, run first).
- **Integration Tests**: Test component interactions (slower, run after unit tests).

## 33. What is Parallel Execution in CI/CD?

**Answer:**
Parallel Execution runs multiple jobs/stages simultaneously to reduce pipeline execution time.

## 34. What is Pipeline Caching?

**Answer:**
Pipeline Caching stores build artifacts and dependencies to speed up subsequent pipeline runs.

## 35. What is the difference between Pipeline and Workflow?

**Answer:**
- **Pipeline**: Complete CI/CD process (build, test, deploy).
- **Workflow**: Specific sequence of jobs within a pipeline.

## 36. What is CI/CD Best Practices?

**Answer:**
- Keep pipelines fast
- Run tests in parallel
- Use caching
- Implement quality gates
- Secure secrets
- Version control pipelines
- Monitor pipeline health
- Implement rollback strategy
- Use feature flags
- Document pipelines

## 37. What is the difference between Manual and Automated Deployment?

**Answer:**
- **Manual**: Human intervention required, error-prone, slow.
- **Automated**: No human intervention, consistent, fast.

## 38. What is Deployment Pipeline?

**Answer:**
Deployment Pipeline is the automated process that takes code from version control to production.

## 39. What is CI/CD Metrics?

**Answer:**
CI/CD Metrics track pipeline performance:
- Build time
- Deployment frequency
- Lead time
- Mean time to recovery (MTTR)
- Change failure rate

## 40. What is GitOps?

**Answer:**
GitOps uses Git as the single source of truth for infrastructure and application deployment.
- *Example*: To increase your web server count from 2 to 5, you edit a `replicas: 5` value in a YAML file in your Git repo. A tool like **ArgoCD** sees this change and automatically scales up your cluster.


