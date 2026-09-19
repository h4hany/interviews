# Technical Trade-offs

## 1. Overview
Engineering is the art of making trade-offs. There is rarely a "perfect" solution; there are only solutions optimized for specific constraints. A Technical Lead must be able to identify, evaluate, and communicate these trade-offs to both technical and non-technical stakeholders.

## 2. Common Trade-off Vectors

### 2.1 Speed to Market vs. Code Quality (Tech Debt)
- **Context:** Product needs a feature next week to close a major deal.
- **Trade-off:** Do you hack it together (incurring technical debt) or push back on the deadline to build it robustly?
- **TL Approach:** It depends on the business context. For a prototype or a startup finding product-market fit, speed wins. For a financial ledger, quality wins. The key is *conscious* tech debt—documenting the shortcuts and scheduling time to fix them.

### 2.2 Consistency vs. Availability (CAP Theorem)
- **Context:** Distributed systems under network partitions.
- **Trade-off:** Do you return the most recent data (but maybe fail the request) or return potentially stale data (but guarantee a response)?
- **TL Approach:** Financial transactions require Consistency. Social media feeds require Availability.

### 2.3 Monolith vs. Microservices
- **Monolith:** High coupling, easy deployment, simple debugging, low latency (in-memory calls). Hard to scale teams independently.
- **Microservices:** Loose coupling, complex deployment (k8s), hard debugging (distributed tracing), network latency. Easy to scale teams independently.
- **TL Approach:** Default to a modular monolith. Extract microservices only when organizational scale (communication overhead) or specific scaling bottlenecks demand it.

### 2.4 Custom vs. Off-the-Shelf (Build vs. Buy)
- **Trade-off:** Capital Expenditure (CapEx) of building it vs. Operational Expenditure (OpEx) of paying a SaaS vendor. Vendor lock-in vs. maintenance burden.

## 3. Presenting Trade-offs to Stakeholders
Never present a single option to Product/Business. Present a menu with costs:
- **Option A (The Hack):** Takes 1 week. Won't scale past 10k users. We will have to rewrite it in 3 months.
- **Option B (The Solid Path):** Takes 3 weeks. Handles expected load for the next 2 years.
- **Option C (The Over-Engineered Path):** Takes 8 weeks. Built for global scale. (Usually present this to show why it's a bad idea right now).

## 4. Interview Questions

### Question 1: Tell me about a time you had to sacrifice code quality or architecture to meet a business deadline.
**What they are testing:** Pragmatism, business acumen, conscious technical debt management.
**Short Answer:** I deliberately took on technical debt to meet a critical launch, but I documented it in an ADR and negotiated with Product to allocate 20% of the next sprint to refactor it.
**Detailed Answer:** We had a hard regulatory deadline to launch a compliance reporting feature. The "correct" architectural approach required migrating a core database table, which would take a month. The deadline was in two weeks. I met with the Product Manager and proposed a trade-off: We could meet the deadline by building a cron-job that aggregates the data into a temporary cache. I explicitly stated the risks: it would be brittle and require manual intervention if it failed. The PM agreed to the risk. We hit the deadline. Crucially, I immediately created Jira tickets for the "correct" database migration and got agreement that this would be our top priority in the following cycle before the hacky solution buckled under scale.
**Strong TL Answer:** Shows they don't treat architecture as a religion. They understand that if the business fails, the perfect code doesn't matter. But they also show discipline in *repaying* the debt.

### Question 2: How do you decide between a Monolith and Microservices for a new project?
**What they are testing:** Understanding of distributed systems complexity, avoiding hype-driven development.
**Strong TL Answer:** I almost always advocate starting with a Modular Monolith. Microservices solve organizational scaling problems, not necessarily technical ones. If you have a small team of 5 engineers, the operational overhead of microservices (CI/CD, distributed tracing, network failures, API versioning) will destroy your velocity. I enforce strict logical boundaries (using namespaces or modules) within the monolith. We only break out a microservice when we have a compelling reason: either a specific component needs to scale independently (e.g., heavy video processing), or the team has grown so large that they are stepping on each other's toes during deployments.
