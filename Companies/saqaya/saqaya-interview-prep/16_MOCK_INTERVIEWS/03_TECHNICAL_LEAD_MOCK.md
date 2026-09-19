# Technical Lead Mock Interview

This mock focuses on the core competencies of a Technical Lead: architecture decisions, team leadership, technical debt, and incident handling.

## Question 1: Architecture Decision Scenario (Monolith vs. Microservices)
**Scenario:**
"Your team is maintaining a 5-year-old monolithic application. Deployment takes 45 minutes, and developers are stepping on each other's toes. The team is begging to rewrite everything into microservices. How do you proceed?"

**Ideal Answer:**
1. **Push back on a full rewrite:** Explain that a "big bang rewrite" usually stalls feature development for months and introduces massive risk.
2. **Strangler Fig Pattern:** Propose incrementally extracting bounded contexts. Start with the most isolated or most frequently changed module.
3. **Prerequisites:** Before extracting, ensure we have robust CI/CD, solid observability (tracing, logging), and automated testing in place. Microservices shift complexity from the code to the infrastructure.
4. **Evaluate Modulith:** Ask if we can just enforce modularity within the monolith first (e.g., using Nx workspaces or strict module boundaries) to solve the developer experience issue without distributed system pain.

## Question 2: Mentoring and Leveling Up the Team
**Scenario:**
"You have a junior engineer who is highly enthusiastic but consistently writes code that is hard to maintain and lacks tests. How do you manage their growth?"

**Ideal Answer:**
1. **Pair Programming:** Spend time pairing with them to demonstrate *how* to write testable code, not just telling them to do it.
2. **Constructive Code Reviews:** Use PR reviews as teaching moments. Instead of saying "This is bad," say "What happens if this API fails here? Let's add a test for that."
3. **Clear Expectations:** Define what 'Good' looks like (e.g., creating a checklist for the Definition of Done).
4. **Praise the Effort:** Channel their enthusiasm positively. "I love how fast you built this feature; now let's make it bulletproof."

## Question 3: Prioritizing Technical Debt
**Scenario:**
"The backlog has 50 tech debt tickets. Product wants 5 new features this quarter. How do you manage tech debt?"

**Ideal Answer:**
1. **Categorize and Quantify:** Not all tech debt is equal. I classify it by impact: Is it causing production incidents? Slowing down dev velocity? Or is it just "ugly code"?
2. **The 20% Rule:** Negotiate with Product to allocate 20% of every sprint's capacity to technical health.
3. **Tie to Business Value:** Translate tech debt into business terms. "Upgrading the database will prevent the weekly outages that cost us $X."
4. **Opportunistic Refactoring:** Encourage developers to clean up code as they work on related features (Boy Scout Rule).

## Question 4: Cross-Team Dependencies
**Scenario:**
"Your feature depends on an API from the Platform team, but they are delayed by two sprints. Your deadline is approaching. What do you do?"

**Ideal Answer:**
1. **Mock the Dependency:** Establish an API contract (e.g., OpenAPI spec) with the Platform team immediately. Build and test against a mock server based on that contract.
2. **Escalate with Solutions:** Talk to the Platform team lead to understand the bottleneck. Offer to have one of your engineers contribute to their repo to speed it up (InnerSourcing).
3. **Communicate Risk:** Inform stakeholders of the risk early and adjust the rollout plan if necessary.

## Question 5: Production Incident Commander
**Scenario:**
"You are the incident commander for a Sev-1 outage where users cannot log in. The database CPU is at 100%. Walk me through your actions."

**Ideal Answer:**
1. **Stabilize (Mitigation):** My immediate goal is to restore service, not fix the root cause. I would check for recent deployments and roll back if one just occurred. If it's a spike in traffic, implement rate limiting or scale the database read replicas.
2. **Communicate:** Delegate someone to update the status page and internal stakeholders.
3. **Investigate:** Once stabilized, look at slow query logs or APM tools to find the offending query.
4. **Post-Mortem:** After resolution, schedule a blameless post-mortem. Write action items (e.g., add missing indexes, implement caching).
