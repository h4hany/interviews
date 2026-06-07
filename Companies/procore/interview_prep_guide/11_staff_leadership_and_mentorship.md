# Staff Leadership, Code Reviews & Mentorship

> Staff engineers are evaluated on how they scale their impact beyond themselves.

---

## 1. Navigating Architectural Tradeoffs

### The Core Philosophy
> "Architectural decisions are business decisions. Sometimes shipping quickly is the right choice, but it should be a conscious tradeoff, not accidental debt."

### How to Handle "Ship It Fast vs Build It Right"
If Product needs a feature in 2 weeks but the ideal design takes 6 weeks:

1. **Acknowledge the business need** — don't block delivery blindly
2. **Propose a phased approach**:
   - Deliver a safe minimal version now (e.g., logic inside existing service)
   - Put clear boundaries around the shortcut
   - Add tests to protect behavior
3. **Document the debt (ADR)**
4. **Agree on a payback plan** — reserve time in the next iteration

### Communicating Technical Debt to Non-Technical Stakeholders
Do not use abstract terms like "coupling" or "code smell." Translate to business risk:
- "Slower future delivery for this area"
- "Higher chance of bugs during the busy season"
- "More difficult onboarding for new engineers"
- "Performance risk as customer usage grows"

---

## 2. Code Reviews & Mentorship

### Reviewing a Junior Engineer's Flawed PR
**Scenario:** A PR works technically, but violates architectural principles (e.g., adds N+1 query, bypasses authorization).

**Approach:**
1. **Acknowledge what works:** *"The feature behavior is correct and the tests cover the happy path."*
2. **Explain the risk concretely:** *"I think we need to adjust the design before merging because this query runs inside a loop and will create an N+1 issue as project data grows."*
3. **Propose a path forward:** *"Let's use eager loading or move this logic into the domain service."*
4. **Offer to pair:** *"If you have 15 minutes, I'd love to pair on this to show you how to use `includes` safely here."*

### Scaling Mentorship
> "Good mentorship is not only helping one person; it is improving the system so the whole team makes better decisions by default."

- For repeated patterns, don't just leave the same PR comment 10 times
- Create examples, documentation, lint rules (`rubocop`), templates, or shared libraries

---

## 3. TDD & Code Quality at Scale

### Championing TDD Without Slowing Teams Down
> "I see TDD as a design tool, not just a testing technique. The purpose is to create fast feedback, better boundaries, and safer change."

- **Don't force rigid processes:** Not every single line must be test-first
- **Focus on risk-based testing:** Complex business rules, permissions, billing, workflows
- **Be pragmatic on CRUD:** For simple Rails CRUD, standard request specs are often enough

### Test Strategy Hierarchy
1. **Unit tests** — pure domain logic
2. **Request specs** — API behavior and routing
3. **Contract tests** — between distributed services
4. **Integration tests** — important cross-domain workflows
5. **End-to-End (E2E) tests** — ONLY for the most critical user journeys (e.g., creating a project, submitting an RFI)

### Testing Distributed Systems
- Mocking can drift from reality in SOA
- Use **contract testing** (e.g., Pact) where services publish expected API shapes
- Test async systems for: idempotency, retries, out-of-order events, dead-letters

### Test Suite Health
A slow test suite becomes a bottleneck. Track:
- Test runtime
- Flaky tests
- Split fast tests from slower integration tests

---

## 4. Handling Disagreements

### Disagreeing with a Principal Engineer / Architect
1. Treat it as a design discussion, not a defense
2. Explain the constraints you optimized for
3. Acknowledge the tradeoffs of your approach
4. Ask what specific risk they are most concerned about

**Example Answer:**
> "I chose the simpler greedy implementation because it satisfies the current constraints and is easy to reason about. The tradeoff is that it may not be globally optimal. If 'minimum days' is a strict requirement, I would replace this with bipartite matching. I would add tests to demonstrate the failure case before changing the algorithm."

### Handling Product Pushback on Technical Work
- Always tie technical work to product metrics (uptime, latency, feature velocity)
- Negotiate percentage allocations (e.g., 20% of sprint for tech debt)
- Show the cost of doing nothing

---

## 5. Staff-Level Interview Quick Reference

| Concept | Your Answer Strategy |
|---------|----------------------|
| **Technical Debt** | Translate to business risk (velocity, bugs). Use ADRs. Phase the delivery. |
| **Code Reviews** | Validate effort, point out risk concretely, offer to pair, codify into linters/patterns. |
| **Testing** | TDD as design tool. Risk-based testing. Avoid E2E bloat. Use contract testing for SOA. |
| **Disagreements** | Optimize for the same constraints. Ask about their risk tolerance. No ego. |
| **Scaling Impact** | Move from 1:1 mentorship to 1:N impact (tooling, documentation, architectural standards). |
