# The Technical Lead Role

## 1. Role Definition
A Technical Lead (TL) is a software engineer who is responsible for the technical direction, quality, and execution of a specific team or domain. They act as the bridge between engineering (how we build it) and product/business (what we build and why).

**Core Mandate:** A TL's primary job is to multiply the effectiveness of their team. 

## 2. TL vs. Senior Engineer vs. Engineering Manager (EM)

| Attribute | Senior Engineer | Technical Lead | Engineering Manager |
| :--- | :--- | :--- | :--- |
| **Primary Focus** | Complex technical implementation | Team technical output & direction | Team health, growth, & delivery |
| **Output** | Code, system design, PRs | Architecture, standards, unblocking | 1-on-1s, hiring, performance reviews |
| **Scope** | Individual tasks/features | Project/Domain technical success | People and process success |
| **Coding Time** | 70-90% | 30-50% (Focus on scaffolding/critical paths) | 0-10% |

*Note: In some organizations, a TL also acts as the EM (Tech Lead Manager / TLM), but the roles require different skill sets.*

## 3. Day-to-Day Responsibilities
- **Architecture & Design:** Reviewing RFCs, writing ADRs, and guiding system design.
- **Unblocking:** Proactively identifying technical risks and resolving dependencies with other teams.
- **Code Review & Standards:** Upholding engineering standards, reviewing critical PRs, and setting CI/CD rules.
- **Mentoring:** Pairing with junior/mid-level engineers, guiding their technical growth, and delegating effectively.
- **Product Partnership:** Working closely with Product Managers to translate business requirements into technical roadmaps. Estimating effort and pushing back on scope creep.

## 4. Scope of Influence & Technical Vision
A strong TL doesn't just react to Jira tickets; they proactively shape the future.
- **Technical Vision:** Where should this system be in 1-2 years? (e.g., "We need to migrate off this monolith to domain-specific services to support 10x scale").
- **Roadmap Contribution:** Pushing for technical debt repayment and infrastructure improvements to be included alongside product features.

## 5. Interview Questions

### Question 1: How do you balance coding versus your leadership responsibilities?
**What they are testing:** Time management, delegation, understanding of the TL role.
**Short Answer:** I target about 30-40% of my time on coding. I focus my coding time on critical infrastructure, difficult proofs-of-concept, or unblocking the team, while delegating standard feature work to empower my engineers.
**Detailed Answer:** If a TL codes too much, they become a bottleneck and fail to lead. If they code too little, they lose touch with the codebase and lose the team's respect. I aim for 30-40%. I specifically avoid taking on time-sensitive, critical-path product features because my schedule is often interrupted by meetings or emergent issues. Instead, I take on tasks like setting up the initial architecture skeleton, resolving complex technical debt, or building developer tooling. I delegate the feature work because that's how the team grows. My primary metric for success is not how many lines of code I write, but how productive and autonomous my team is.
**Strong TL Answer:** Clearly articulates the danger of being on the "critical path" for product delivery and emphasizes *delegation as a tool for team growth*.

### Question 2: Describe a time you transitioned from Senior Engineer to Tech Lead. What was the hardest part?
**What they are testing:** Self-awareness, behavioral adaptation, shifting from individual contributor (IC) to multiplier.
**Strong TL Answer:** The hardest part was letting go of the need to have my hands on every piece of code. As a Senior, my value was my output. As a TL, I had to realize my value was the *team's* output. Initially, I was micromanaging PRs and rewriting people's code if it wasn't exactly how I would have done it. I had to learn the difference between "wrong" and "different." I started focusing on the API boundaries and system behavior, rather than implementation details. I learned to use 1-on-1s and design documents to align on the approach *before* the code was written, which saved time and empowered the engineers.
