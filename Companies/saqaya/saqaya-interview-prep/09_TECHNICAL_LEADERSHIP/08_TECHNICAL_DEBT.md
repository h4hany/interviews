# Technical Debt

## 1. Overview
Technical debt is the implied cost of additional rework caused by choosing an easy (limited) solution now instead of using a better approach that would take longer. It is not inherently bad; like financial debt, it can be leveraged for business growth. The TL's job is to manage the "interest payments."

## 2. Types of Technical Debt
1. **Deliberate Debt:** "We know we should use a message queue here, but we will use a direct HTTP call to hit the Friday deadline. We will fix it next month." (Good, conscious choice).
2. **Inadvertent/Bit Rot:** The code was written perfectly 3 years ago, but the business domain changed, the framework upgraded, and now the architecture doesn't fit. (Unavoidable, requires maintenance).
3. **Reckless Debt:** "I don't know how to write tests for this, so I won't." (Bad, unacceptable).

## 3. Prioritizing Technical Debt
You cannot fix all tech debt. You must prioritize based on ROI (Return on Investment).
- **High Priority:** Debt in the critical path (checkout flow) or debt that is actively slowing down feature development (a monolithic file that causes merge conflicts daily).
- **Low Priority:** Messy code in a module that works perfectly, has good test coverage, and hasn't been touched in 2 years. *Leave it alone.*

## 4. Communicating Debt to Stakeholders
Never use the term "Technical Debt" with executives or Product Managers without attaching a business metric.
- **Bad:** "We need 2 weeks to refactor the billing service."
- **Good:** "The current billing service structure causes 3 high-severity bugs per month and adds 3 days of development time to every new pricing tier feature. If we spend 2 weeks fixing it now, we will save roughly 6 days of engineering time per month going forward."

## 5. Refactoring Strategies
- **The Boy Scout Rule:** Leave the campground cleaner than you found it. If you are adding a feature to a messy file, clean up the function you touch. This provides continuous, incremental improvement.
- **Strangler Fig Pattern:** For major rewrites (e.g., replacing a legacy system). Do not do a "Big Bang" rewrite. Build a proxy that routes specific endpoints to the new system one by one until the old system is starved of traffic and can be deleted.

## 6. Interview Questions

### Question 1: How do you balance delivering new features with paying down technical debt?
**What they are testing:** Business acumen, negotiation skills, continuous improvement processes.
**Short Answer:** I negotiate a continuous allocation (usually 20% of sprint capacity) dedicated to tech debt, and I frame the debt strictly in terms of how it slows down future feature delivery.
**Detailed Answer:** I avoid "stop the world" refactoring sprints. Instead, I advocate for the 80/20 rule: 80% product features, 20% engineering health in every sprint. To get PM buy-in, I keep a backlog of tech debt tickets, but I prioritize them based on Developer Friction. If a specific legacy module is slowing down our current feature roadmap, I point to the tech debt and say, "To deliver Feature X quickly, we must spend 2 days refactoring this module first." I also enforce the Boy Scout rule within the team, so we are constantly making micro-improvements during normal feature work.
**Strong TL Answer:** Rejects the "Tech Debt Sprint" anti-pattern. Focuses on continuous, incremental improvement and tying debt repayment directly to product velocity.

### Question 2: Your team has inherited a legacy codebase with zero tests and massive technical debt. You need to add new features to it. How do you approach this safely?
**What they are testing:** Legacy code management, risk mitigation, testing strategies.
**Strong TL Answer:** I use the strategy outlined in Michael Feathers' "Working Effectively with Legacy Code." First, I do not rewrite it. I identify the "seams" where the new feature needs to interact with the old code. I write high-level Integration or E2E tests for the existing critical paths to establish a baseline (characterization tests). Once I have a safety net proving I haven't broken the current behavior, I refactor just enough of the legacy code to inject the new feature cleanly. Any new code I write is heavily unit-tested and decoupled from the legacy monolith, often using adapters or the Strangler pattern.
