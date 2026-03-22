# DevOps Interview Questions

## 1. What is DevOps?

**Answer:**
DevOps is a culture and set of practices that combines software development (Dev) and IT operations (Ops) to shorten the development lifecycle and deliver high-quality software continuously.

## 2. What are the main principles of DevOps?

**Answer:**
- Collaboration between Dev and Ops
- Automation of processes
- Continuous Integration/Continuous Deployment
- Infrastructure as Code
- Monitoring and logging
- Rapid feedback loops

## 3. What is the difference between DevOps and Agile?

**Answer:**
- **Agile**: Development methodology focusing on iterative development.
- **DevOps**: Culture and practices focusing on collaboration, automation, and continuous delivery.

## 4. What is Infrastructure as Code (IaC)?

**Answer:**
IaC manages and provisions infrastructure through machine-readable definition files.
- *Example*: Writing a **Terraform** script that defines a Virtual Private Cloud (VPC), two subnets, and a database. Running `terraform apply` creates all these resources in AWS automatically.

## 5. What is the difference between Configuration Management and Infrastructure Provisioning?

**Answer:**
- **Infrastructure Provisioning**: Creates the hardware/cloud resources. *Example*: **Terraform** creates an EC2 instance (a "empty" server).
- **Configuration Management**: Configures the software on that resource. *Example*: **Ansible** logs into that EC2 instance and installs Nginx and Node.js.

## 6. What is Containerization?

**Answer:**
Containerization packages applications and dependencies into lightweight, portable containers (Docker).

## 7. What is Container Orchestration?

**Answer:**
Container Orchestration automates deployment, scaling, and management of containers (Kubernetes, Docker Swarm).

## 8. What is the difference between Docker and Kubernetes?

**Answer:**
- **Docker**: Containerization platform.
- **Kubernetes**: Container orchestration platform.

## 9. What is Continuous Integration (CI)?

**Answer:**
CI is the practice of frequently integrating code changes into a shared repository, with automated builds and tests.

## 10. What is Continuous Deployment (CD)?

**Answer:**
CD automatically deploys code changes to production after passing automated tests.

## 11. What is the difference between Continuous Deployment and Continuous Delivery?

**Answer:**
- **Continuous Delivery**: Code is always deployable, but deployment is manual.
- **Continuous Deployment**: Code is automatically deployed to production.

## 12. What is Version Control?

**Answer:**
Version Control tracks changes to code over time, enabling collaboration and rollback (Git, SVN).

## 13. What is Git branching strategy?

**Answer:**
Branching strategies organize code development:
- **Git Flow**: Feature, develop, release, hotfix branches (Structured, good for scheduled releases).
- **GitHub Flow**: Simple, main branch + feature branches (Fast, good for CI/CD).
- **Trunk-based**: Developers merge small updates to a single "trunk" (Main) multiple times a day (Highest speed, requires high test coverage).

## 14. What is Blue-Green Deployment?

**Answer:**
Blue-Green Deployment maintains two identical environments, switching traffic from old (blue) to new (green) version.

## 15. What is Canary Deployment?

**Answer:**
Canary Deployment gradually rolls out new version to a small percentage of users before full deployment.

## 16. What is Rolling Deployment?

**Answer:**
Rolling Deployment updates instances gradually, replacing old instances with new ones incrementally.

## 17. What is Infrastructure Monitoring?

**Answer:**
Infrastructure Monitoring tracks system health, performance, and availability (CPU, memory, disk, network).

## 18. What is Application Monitoring?

**Answer:**
Application Monitoring tracks application performance, errors, and user experience (APM tools).

## 19. What is Logging?

**Answer:**
Logging records application events and errors for debugging and auditing (centralized logging, ELK stack).

## 20. What is the difference between Logging and Monitoring?

**Answer:**
- **Logging**: Records events and errors (detailed, historical).
- **Monitoring**: Tracks metrics and alerts (real-time, aggregated).

## 21. What is Alerting?

**Answer:**
Alerting notifies teams when metrics exceed thresholds or errors occur.

## 22. What is Incident Management?

**Answer:**
Incident Management handles and resolves system outages and issues (on-call, escalation, post-mortems).

## 23. What is Post-Mortem?

**Answer:**
Post-Mortem is a review meeting after an incident to understand what happened and prevent recurrence.

## 24. What is Infrastructure Automation?

**Answer:**
Infrastructure Automation uses scripts and tools to provision and manage infrastructure automatically.

## 25. What is Configuration Management?

**Answer:**
Configuration Management maintains consistency of system configuration across environments (Ansible, Puppet, Chef).

## 26. What is the difference between Ansible, Puppet, and Chef?

**Answer:**
- **Ansible**: Agentless, YAML-based, push model.
- **Puppet**: Agent-based, declarative, pull model.
- **Chef**: Agent-based, Ruby-based, pull model.

## 27. What is Terraform?

**Answer:**
Terraform is an IaC tool for provisioning and managing cloud infrastructure using declarative configuration.

## 28. What is the difference between Terraform and Ansible?

**Answer:**
- **Terraform**: Infrastructure provisioning (creates resources).
- **Ansible**: Configuration management (configures existing resources).

## 29. What is Cloud Computing?

**Answer:**
Cloud Computing delivers computing services over the internet (IaaS, PaaS, SaaS).

## 30. What is the difference between IaaS, PaaS, and SaaS?

**Answer:**
- **IaaS**: Infrastructure (servers, storage, networking).
- **PaaS**: Platform (runtime, databases, development tools).
- **SaaS**: Software (complete applications).

## 31. What is Serverless?

**Answer:**
Serverless is a cloud computing model where cloud provider manages servers, and you only pay for execution time.

## 32. What is the difference between Containers and Serverless?

**Answer:**
- **Containers**: You manage containers, always running.
- **Serverless**: Provider manages execution, pay per use, event-driven.

## 33. What is Microservices?

**Answer:**
Microservices is an architectural style where applications are built as independent, deployable services.

## 34. What is Service Mesh?

**Answer:**
Service Mesh provides infrastructure layer for service-to-service communication (Istio, Linkerd).

## 35. What is DevOps Culture?

**Answer:**
DevOps Culture emphasizes collaboration, shared responsibility, automation, and continuous improvement.

## 36. What is Shift-Left?

**Answer:**
Shift-Left means moving testing, security, and quality checks earlier in the development process.

## 37. What is GitOps?

**Answer:**
GitOps uses Git as the single source of truth for infrastructure and application deployment.

## 38. What is the difference between DevOps and SRE?

**Answer:**
- **DevOps**: Culture and practices for collaboration.
- **SRE**: Engineering discipline focusing on reliability and automation.

## 39. What is Chaos Engineering?

**Answer:**
Chaos Engineering tests system resilience by intentionally introducing failures.
- *Example*: **Netflix's Chaos Monkey** randomly shuts down production servers during business hours to ensure the system can handle unexpected failures without impacting users.

## 40. What is DevOps Best Practices?

**Answer:**
- Automate everything
- Version control everything
- Monitor and log
- Implement CI/CD
- Use Infrastructure as Code
- Practice blameless post-mortems
- Foster collaboration
- Measure everything
- Security as code
- Continuous learning


