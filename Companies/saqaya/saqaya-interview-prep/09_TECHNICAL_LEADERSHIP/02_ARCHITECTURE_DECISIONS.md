# Architecture Decisions

## 1. Overview
Making architectural decisions is arguably the highest-impact activity for a Technical Lead. A bad decision here compounds over years, resulting in technical debt, slow velocity, and scaling limits.

## 2. Decision Frameworks

### 2.1 One-Way vs. Two-Way Doors (Reversible vs. Irreversible)
- **One-Way Door (Irreversible):** Hard to change later (e.g., choosing a core database technology like Postgres vs. MongoDB, choosing a cloud provider). *Requires deep analysis, proof of concepts (PoCs), consensus, and time.*
- **Two-Way Door (Reversible):** Easy to roll back or change (e.g., tweaking a caching strategy, choosing an internal utility library). *Move fast, decide quickly, iterate.*

### 2.2 Build vs. Buy
- **Core Philosophy:** Only build what differentiates your business. 
- **Buy/Rent:** Identity management (Auth0), logging (Datadog), payments (Stripe).
- **Build:** Your core domain logic, algorithms that provide competitive advantage.
- *Beware of "Not Invented Here" syndrome where engineers want to build everything.*

## 3. The Process: RFCs and ADRs

### Request for Comments (RFC)
Used *before* a decision is made. It's a proposal document outlining a problem, proposed solutions, trade-offs, and estimated costs. It invites peer review from other TLs and Staff engineers to catch blind spots.

### Architecture Decision Record (ADR)
Used *after* a decision is made. Stored in the repository alongside the code.
- **Context:** What is the problem?
- **Options Considered:** What alternatives were evaluated?
- **Decision:** What did we choose and *why*?
- **Consequences:** What are the positive and negative impacts (trade-offs) of this choice?

## 4. Evaluating Technologies
1. **Community and Ecosystem:** Is the project actively maintained? (Check GitHub stars, open PRs, commit frequency).
2. **Talent Pool:** Can we hire engineers who know this technology? (e.g., Rust is fast, but hiring Senior Go/Java engineers might be easier).
3. **Operational Burden:** Do we have the DevOps capability to run this? (Managed services vs. self-hosted).

## 5. Getting Buy-In
Architecture decisions require alignment. 
- **Engineers:** Need to know it solves their pain points and is enjoyable to work with.
- **Product:** Needs to know it enables future features and doesn't halt delivery.
- **Leadership:** Needs to know the cost (ROI) and risk profile.

## 6. Interview Questions

### Question 1: Walk me through a time you had to make a major architectural decision. How did you approach it?
**What they are testing:** Structured thinking, use of frameworks (RFCs, PoCs), stakeholder management, and evaluating trade-offs.
**Short Answer:** I define the problem, evaluate 2-3 options via an RFC, run a time-boxed Proof of Concept for the top contenders, gather feedback from stakeholders, and document the final choice in an ADR.
**Detailed Answer:** (Use a STAR format example). *Situation:* We needed to implement a real-time notification system. *Task:* Choose between WebSockets, Server-Sent Events (SSE), or long-polling. *Action:* I wrote an RFC outlining our requirements (one-way server-to-client vs two-way). I evaluated SSE as the simplest for our one-way requirement, but WebSockets as more future-proof. Since this was a core infrastructural change (one-way door), I assigned two engineers to do a 3-day PoC on SSE and WebSockets to test load limits. The PoC showed WebSockets introduced too much operational complexity for our current DevOps maturity. I presented this to the engineering team and product. *Result:* We aligned on SSE, implemented it, and documented the choice in an ADR noting that if we ever need bi-directional data, we will need to re-evaluate.
**Strong TL Answer:** Highlights the *process* of decision making (RFC -> PoC -> ADR) rather than just defending the specific technology chosen. Mentions operational capability as a constraint.

### Question 2: Your team wants to rewrite a working microservice in a shiny new language (e.g., Rust). How do you handle this?
**What they are testing:** Pragmatism, managing "Resume Driven Development", Build vs Buy, business alignment.
**Strong TL Answer:** I love enthusiasm for new tech, but I have to act as the pragmatic filter. I would ask the team to define the *business problem* this rewrite solves. Is the current service failing SLA? Are compute costs too high? If the only reason is "it's cool," I will say no. If there is a legitimate bottleneck, I will ask them to write an RFC detailing the cost of the rewrite (time not spent building features), the risk of maintaining a new language (who else in the company knows Rust?), and the expected ROI. Usually, forcing engineers to quantify the business value of a rewrite cools the "Resume Driven Development" urge. If the math makes sense, we'll do a PoC.
