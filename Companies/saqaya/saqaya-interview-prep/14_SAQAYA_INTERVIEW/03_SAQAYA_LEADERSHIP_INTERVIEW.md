# SAQAYA Leadership Interview Guide

As a Technical Lead, SAQAYA will evaluate your ability to establish standards, mentor engineers, and drive technical decisions in a fast-paced, AI-native environment.

## 1. Establishing Engineering Standards

### Question: "You're joining a fast-moving team that currently lacks strict engineering standards. How do you implement standards without slowing down product delivery?"
- **Detailed Answer**: "I introduce standards incrementally, focusing first on high-value, automated checks. I would start by enforcing formatting (Prettier/Black) and linting (ESLint/Ruff) in CI, preventing basic arguments in PRs. Then, I introduce templates for PRs and issues. Standards shouldn't be a 50-page document; they should be codified in the tooling."
- **Strong TL Answer**: "Standards must be an enabler of velocity, not a bottleneck. My approach is 'Paved Roads'. I build robust, automated pipelines (CI/CD, IaC templates) that make doing the *right* thing the *easiest* thing. For architectural decisions, I implement lightweight RFCs (Request for Comments) or ADRs (Architecture Decision Records) so we have a history of *why* decisions were made. I aim for consensus but am prepared to make the final call to maintain momentum."

## 2. Leading the TypeScript/Python Decision

### Question: "How do you navigate a team where half the engineers prefer Python and the other half prefer TypeScript?"
- **Detailed Answer**: "I map the language choice to the domain problem. Python is excellent for data pipelines, AI integrations, and scripting. TypeScript is superior for highly concurrent API gateways, shared domain models with the frontend, and strict typing. I would facilitate a workshop to define these boundaries, ensuring everyone understands *why* a language is chosen for a specific service."
- **Strong TL Answer**: "I separate personal preference from technical pragmatism. I would establish a microservices architecture bounded by domain contexts. We use Python for the 'Intelligence AI Layer' and TypeScript for the 'Core Application Layer'. To bridge the gap, I mandate strict API contracts using OpenAPI specifications. This allows the TS engineers to generate typed clients for the Python services, and vice versa. It turns a potential conflict into a strength."

## 3. Building Production Infrastructure from Scratch

### Question: "We have a working prototype, but no real production infrastructure. How do you lead the team in building this out?"
- **Detailed Answer**: "I start by mapping out the critical path: source control -> CI/CD -> compute -> database -> monitoring. I'd assign tasks based on strengths, but ensure we pair-program on critical pieces like Terraform setups to avoid silos. We prioritize a 'walking skeleton'—a basic, secure pipeline deploying a 'hello world' app to production—before porting the complex logic."
- **Strong TL Answer**: "I approach this through Risk Mitigation and Infrastructure as Code. Phase 1 is Security & Foundation: AWS VPCs, IAM roles, and Terraform state management. Phase 2 is Automation: CI/CD via GitHub Actions for building containers. Phase 3 is Observability: Centralized logging and APM before real traffic hits. As a leader, I don't just build this; I write the runbooks and conduct 'Game Days' with the team to simulate outages, ensuring everyone knows how to operate the infrastructure."

## 4. Working with Domain Teams (Palladium Context)

### Question: "How do you handle changing requirements from non-technical domain experts?"
- **Detailed Answer**: "I focus on active listening and asking 'why' to uncover the root business problem, rather than just accepting a feature request. I use prototypes and wireframes to validate understanding early. I also practice agile iterations, delivering small vertical slices of functionality so stakeholders can see progress and pivot if needed."
- **Strong TL Answer**: "I act as the translator between business intent and technical execution. When working with domain experts like those at Palladium, I establish a ubiquitous language—ensuring engineers use the same terminology in the code as the domain experts use in meetings. I implement tight feedback loops, demonstrating working software bi-weekly. If requirements change, I quantify the technical trade-offs (cost/time) so stakeholders can make informed priority decisions."

## 5. Mentoring and Code Review Standards

### Question: "What is your philosophy on code reviews, especially in an era of AI-generated code?"
- **Detailed Answer**: "Code reviews are for sharing context and ensuring architecture alignment, not for finding missing semicolons—linters do that. With AI-generated code, reviews become more about validating the logic and checking for edge cases that AI misses."
- **Strong TL Answer**: "My code review philosophy is 'Nitpicks are automated; humans review architecture and intent.' I enforce small, single-purpose PRs. For AI-generated code, I mandate that the author must fully understand and be able to explain every line. In reviews, I focus on security, performance, and test coverage. Furthermore, I use PRs as a mentoring tool, asking questions like 'Have you considered how this scales if the database grows 10x?' rather than just dictating solutions."
