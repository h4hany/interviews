# Cloud Native Application Delivery

# Application Delivery Fundamentals

Every application begins with source code. That code is more than an implementation detail—it represents intellectual property and core business value. To manage this effectively, developers rely on version control systems, which track changes over time and allow teams to collaborate safely without overwriting each other's work.

The dominant system today is Git, first created by Linus Torvalds in 2005. Git is a distributed version control system, meaning every contributor has a complete copy of the repository, including its history. Developers typically work in branches or forks, making changes in isolation before merging them back into a main branch for release. Git has become a universal industry standard used daily by developers, platform engineers, SREs, and administrators. To deepen your knowledge, visit the official Git documentation at [_git-scm.com_](http://git-scm.com).

Once the code is stored and managed in Git, the next step is building the application. In modern environments, this often includes compiling code, running dependency pipelines, and producing container images as described in an earlier chapter. The goal of this step is to produce an artifact that can be deployed consistently across environments.

Before deployment, applications are validated through automated testing. Tests verify functionality, prevent regressions, and ensure that new changes don't break existing behavior. Automated testing is essential for scaling collaboration and enabling rapid release cycles.

After the code is built and tested, it must be deployed. If the target platform is Kubernetes, the application is packaged into a container and described using YAML manifests. The container image is pushed to a registry, and Kubernetes pulls and runs that image based on the configuration defined in Deployment or other controller objects. This ensures a consistent deployment process across clusters and environments.

Modern DevOps workflows don’t stop at application code. Increasingly, infrastructure and operational configurations are also managed through version control. This approach, known as [_Infrastructure as Code (IaC)_](https://en.wikipedia.org/wiki/Infrastructure_as_code), allows teams to define infrastructure—networks, compute resources, storage, security policies—as configuration files rather than a manual, ad-hoc setup. IaC makes environments reproducible, reduces human error, and enables developers to participate directly in provisioning through cloud APIs rather than relying solely on operations teams.

Together, version-controlled source code, automated builds, testing pipelines, containerization, and IaC form the foundation for automated delivery processes like CI/CD and GitOps—enabling faster, safer, and more scalable software releases.