# Procore Staff RoR Final Interview Cheat Sheet

> Use this in the last 24 hours before the interview.

## Master Deep-Dive Prompt

```text
I have an interview in 24 hours for Staff Software Engineer - RoR at Procore.
Drill me on this cheat sheet. Ask fast follow-up questions like a Principal Engineer.
Be strict and correct my answer.
Focus topic: [PASTE SECTION NAME]
```

---

# 1. Your Best Repeated Line

> I usually start with the simplest architecture that protects correctness and gives us observability. Then I evolve it based on measured bottlenecks, team ownership, and product needs.

---

# 2. Tell Me About Yourself

> I am a backend-focused Ruby on Rails engineer with strong experience in scalable SaaS systems, PostgreSQL optimization, async processing, and technical leadership. Recently, I worked on AI-powered recommendation and search systems where performance, cost control, and reliability mattered. What interests me about Procore is the combination of Rails at scale, construction project management domain complexity, observability, platform extensibility, and AI-enabled workflows. I like building pragmatic systems that help both customers and engineering teams move faster safely.

---

# 3. OTel Rollout Answer in 60 Seconds

> I would instrument the Rails monolith before extracting services. First, configure service name, environment, version, and OTLP exporter. Then enable auto-instrumentation for Rails, ActiveRecord, Sidekiq, Redis, and HTTP clients. After that, add custom spans around domain workflows such as permission checks, document processing, task scheduling, and notification delivery. I would propagate W3C TraceContext across HTTP and inject/extract context through Sidekiq or message headers for async work. I would avoid PII and high-cardinality attributes, define sampling rules that keep errors and slow traces, and build SLO dashboards around p95/p99 latency, errors, DB time, queue latency, and cache hit rate.

---

# 4. Slow Endpoint Answer in 60 Seconds

> I would start with production telemetry, not guessing. I would check p95/p99 latency, traces, logs, errors, recent deploys, and compare slow traces with normal traces. Then I would isolate whether time is spent in DB queries, serialization, permission checks, cache, external calls, or Ruby CPU. For Rails, I would look for N+1 queries, missing indexes, loading too many records, payload size, and memory allocation. Then I would make the smallest safe fix, verify before/after metrics, and add regression coverage.

---

# 5. `includes` vs `preload` vs `eager_load` vs `joins`

- `preload`: separate queries, good for display and avoiding huge joins.
- `eager_load`: `LEFT OUTER JOIN`, good when filtering/ordering by association.
- `includes`: Rails decides between preload/eager_load.
- `joins`: joins for filtering only, does not eager load association objects.

Staff line:

> I choose based on query shape and verify generated SQL and query plan for high-volume endpoints.

---

# 6. Monolith to SOA Answer in 60 Seconds

> I would not extract immediately. I would first instrument the domain, map callers, and modularize it inside the monolith behind an explicit interface. Then I would introduce the new service behind an internal client, use shadow traffic or dual-write only temporarily, backfill and verify data, gradually shift reads with feature flags, then cut over writes. For zero downtime, I would use expand-and-contract migrations and API versioning. For security-sensitive domains like permissions, I would fail closed and use short-lived caches carefully.

---

# 7. RFI System Design Core

Architecture:
```text
Rails modular monolith
PostgreSQL for RFIs/responses/comments/audit
S3 for attachments
Redis for cache
Sidekiq for notifications/search/reminders
Outbox for reliable events
Search index when full-text grows
```

Must mention:
- project/company scoping
- status lifecycle
- official response strong consistency
- attachments
- permissions
- audit logs
- due dates/escalation
- async notifications/search

---

# 8. Webhook Platform Core

Must include:
- outbox pattern
- delivery table
- HMAC signature
- event_id and delivery_id
- retries with exponential backoff + jitter
- dead-letter queue
- circuit breaker
- per-tenant rate limits
- replay dashboard
- isolation from core request path

---

# 9. AI / Agentic Workflow Core

AI feature:
- user asks, AI answers.

Agentic workflow:
- understands goal,
- retrieves context,
- plans,
- uses tools,
- asks approval,
- executes,
- audits.

Construction example:
- Daily Log Assistant
- RFI Resolution Agent
- Drawing Change Impact Agent

Guardrails:
- permission-filtered RAG
- human-in-the-loop
- audit trail
- no unsafe auto-actions
- cost/latency monitoring
- evaluation metrics

---

# 10. Staff-Level Behavioral Lines

## Technical debt
> Technical debt is acceptable when it is conscious, documented, bounded, and has a payback plan.

## Code review
> I protect the codebase and the relationship. I explain the risk concretely, propose a path forward, and pair when needed.

## TDD
> I treat TDD as a design tool. I focus on risk-based testing rather than forcing every line to be written test-first.

## Disagreement
> I explain the constraints I optimized for, acknowledge tradeoffs, and ask what risk the other person is most concerned about.

---

# 11. Questions To Ask Them

1. What are the biggest architecture challenges for the Project Management team today: domain boundaries, performance, extensibility, or developer velocity?
2. How does Procore decide when to keep functionality in Rails versus extracting a service?
3. For this role, what would great Staff-level impact look like in the first six months?
4. How mature is OpenTelemetry adoption today: coverage, signal quality, or team enablement?
5. What are the most common performance issues you see in Project Management tools?
