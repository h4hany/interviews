# Interview Structure, Known Questions & Behavioral Prep

---

## Interview Rounds Overview

### 1. General Coding Interview (CoderPad) — 60 min ✅ PASSED
- **Format:** CoderPad with function skeleton and predefined test cases
- **Domain:** Construction-related, object-oriented design
- **Known Problems:** Worker Allocation, Punch List Management, Budget/Blueprint Tracking
- **Key:** Adapt to changing requirements mid-interview, communicate clearly

### 2. Specialized Technical Interview — 60 min
- **Focus:** Ruby on Rails, runtime engineering, OpenTelemetry, performance, TDD, AI workflows
- **Format:** Deep technical discussion, may include code review or live refactoring
- **Likely Topics:** OTel rollout, performance bottleneck stories, testing strategy, AI/agentic design
- **May revisit:** WorkScheduler from coding round — refactoring, instrumentation, production readiness

### 3. Software Architecture Interview — 60 min
- **Focus:** System design, SOA, distributed systems, datastore tradeoffs, platform extensibility
- **Format:** Whiteboarding / system design tool exercise
- **Domain:** Enterprise SaaS, multi-tenant data modeling, construction workflows
- **Key:** Clarify requirements, discuss tradeoffs, propose phased delivery

### 4. Hiring Manager Interview — 45 min
- **Focus:** Background, experience, career aspirations, team fit
- **Format:** Conversational

### 5. Values Interview — 45 min
- **Focus:** Openness, Optimism, Ownership
- **Format:** Behavioral ("Tell me about a time when...")

---

## Known Specialized Technical Questions

### OpenTelemetry & Observability
- Walk through rolling out OTel in a Rails monolith transitioning to SOA
- What telemetry data is most critical to capture?
- How do you handle trace context propagation across service boundaries?
- Difference between Trace, Span, and Metric in OTel
- How do you handle sampling in production?

### Performance & Code Quality
- Describe a specific instance where you identified and resolved a severe bottleneck
- How do you write highly performant code that minimizes payload size?
- How do you champion TDD across multiple teams without it becoming a bottleneck?

### AI & Agentic Workflows
- How are you using generative tools daily?
- How would you design features that move from "using AI" to "agentic workflows"?

### Mentorship & Code Reviews
- How do you handle a junior engineer's PR that violates architectural principles?

### Rails Deep Dives
- Difference between `includes`, `preload`, `eager_load`
- Database connection pooling in Rails — what can go wrong?
- Optimistic vs pessimistic locking — when to use each?
- Background job failures and retry strategy

---

## Known Architecture Questions

### System Design
- Design a real-time activity feed / collaborative daily log
- Design an RFI management system
- Design a document & drawing management system
- Design a task / punch list management system
- Design a notification system
- Design a permission system for multi-party collaboration

### SOA & Migration
- Extract a heavily coupled domain from a Rails monolith
- Strangler Fig pattern, dual-write, shadow mode
- Database splitting strategies
- Zero-downtime deployment

### Tradeoffs
- Monolith vs microservices — when to extract
- Graph DB vs PostgreSQL for construction data
- Strong consistency vs eventual consistency
- Synchronous vs asynchronous processing

### Platform Extensibility
- Design webhook & API architecture for massive volume
- Reliability, security, rate limiting, backpressure

---

## Known Hiring Manager Questions

| Question | How to Prepare |
|----------|----------------|
| Summarize the background and experiences you bring to this role | Prepare 2-min career narrative → why Procore, why Runtime team |
| What aspirations do you have for this role at Procore? | Staff-level impact: technical direction, mentorship, platform thinking |
| Describe a decision you regret. What did you learn? | Show self-awareness, concrete lesson, how you changed behavior |
| A time you received feedback you disagreed with. How did you handle it? | Show openness, ability to listen, eventual resolution |

---

## Known Values Interview Questions

Procore values: **Openness, Optimism, Ownership**

### Openness
- Tell me about collaborating with a difficult team member
- Communicating a complex technical issue to a non-technical audience
- How do you express openness in your work?

### Optimism
- A project was failing — how did you maintain morale and turn it around?
- Adapting to a major change in scope or requirements

### Ownership
- You identified a problem outside your direct responsibilities and took initiative
- You made a mistake that impacted a project — how did you take responsibility?

### General
- Which of the 3 values resonates most/least with you? Why?
- Give specific examples of how you live each value

---

## STAR Method Template

Use this for every behavioral answer:

| Component | Description |
|-----------|-------------|
| **S** — Situation | Set the context (project, team, challenge) |
| **T** — Task | What was your specific responsibility? |
| **A** — Action | What did YOU do? (be specific, use "I" not "we") |
| **R** — Result | Quantifiable outcome + what you learned |

### Tips
- Prepare 2-3 specific stories for each value
- Include impact numbers where possible
- Focus on YOUR actions, not just the team's
- End with what you learned or how you'd do it differently
