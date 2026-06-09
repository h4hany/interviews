# 30-Day Procore Staff RoR Preparation Plan

> A practical plan using your uploaded guide files and the job description.

## Master Deep-Dive Prompt

```text
Create a 60-minute mock interview for Procore Staff Software Engineer - RoR.
Use my focus area: [Rails / OTel / System Design / Performance / AI / Leadership].
Ask one question at a time.
After each answer, grade me as Junior/Senior/Staff/Principal and tell me exactly how to improve.
```

---

# Week 1 — Foundation and Role Alignment

## Day 1: Procore Domain
Study RFIs, submittals, punch lists, daily logs, drawings/document versioning, and multi-company project collaboration.

Deliverable:
- Explain each domain concept in 2 minutes.
- Design a small data model for each.

## Day 2: Ruby Fundamentals
Study symbols vs strings, blocks/procs/lambdas, modules/include/extend/prepend, exceptions, OOP, duck typing.

Deliverable:
- Answer 20 basic Ruby questions quickly.

## Day 3: Rails Core
Study request lifecycle, ActiveRecord query methods, transactions, validations/constraints, service objects, callbacks, safe migrations.

Deliverable:
- Explain `includes/preload/eager_load/joins` with SQL examples.

## Day 4: Database and PostgreSQL
Study indexes, composite/partial indexes, EXPLAIN ANALYZE, transactions, locking, connection pools, safe migrations.

Deliverable:
- Given a slow task query, propose indexes and explain tradeoffs.

## Day 5: Coding/Refactoring
Study Worker Allocation, Punch List, WorkScheduler risks/refactor/tests.

Deliverable:
- Re-implement WorkScheduler without notes.

---

# Week 2 — Runtime, Performance, Observability

## Day 6: Performance
Study N+1 detection, payload optimization, memory bloat, caching, query optimization.

Deliverable:
- Prepare a STAR story about reducing p95 latency.

## Day 7: OpenTelemetry
Study traces/metrics/logs, spans, context propagation, sampling, dashboards/SLOs, Sidekiq propagation.

Deliverable:
- Give a 5-minute answer: “Roll out OTel in Rails monolith moving to SOA.”

## Day 8: Ruby Runtime
Study GVL, GC, Puma workers/threads, Sidekiq concurrency, memory profiling, Ractors/Fibers basics.

Deliverable:
- Explain how a DB query releases the GVL.

## Day 9: Production Debugging
Study intermittent 500s, queue latency, DB pool exhaustion, memory growth, deploy regressions.

Deliverable:
- Practice: “p95 jumped from 300ms to 2s after deployment. What do you do?”

## Day 10: Testing Strategy
Study unit/request/integration/contract/E2E, TDD at scale, mocks drift, flaky tests.

Deliverable:
- Create test strategy for webhook delivery system.

---

# Week 3 — Architecture and SOA

## Day 11: System Design Framework
Practice clarify, assumptions, requirements, capacity, HLD, LLD, APIs, DB, async, caching, observability, security, tradeoffs.

## Day 12: RFI + Task/Punch List
Whiteboard both systems in 45 minutes each.

## Day 13: Documents/Drawings + Search
Design direct upload, versioning, OCR/search, signed URLs, audit.

## Day 14: Notifications + Activity Feed
Design event-driven feed, WebSocket updates, outbox, read model.

## Day 15: Platform Extensibility
Design webhook/API system with signatures, retries, rate limits, replay.

## Day 16: SOA Extraction
Explain extracting Permissions from monolith to service.

## Day 17: Datastore Tradeoffs
PostgreSQL vs Redis vs Search vs Graph DB answer.

---

# Week 4 — Staff-Level Polish

## Day 18: AI and Agentic Workflows
Design Daily Log Assistant or RFI Resolution Agent.

## Day 19: Leadership and Mentorship
Prepare code review story, mentoring story, disagreement story.

## Day 20: Business Tradeoffs
Prepare “ship fast vs build right” story using ADR.

## Day 21: Mock Specialized Technical
60 minutes: Rails performance, OTel, runtime, refactoring, TDD.

## Day 22: Mock Architecture
60 minutes: choose one: RFI / docs / notifications / platform API.

## Day 23: Hiring Manager Prep
Prepare tell me about yourself, why Procore, why Staff, biggest project, production incident.

## Day 24: Values Prep
Prepare STAR stories for openness, optimism, ownership.

## Day 25-30: Repeat Weak Areas
Use this loop:
1. Pick one weak question.
2. Answer aloud.
3. Record yourself.
4. Improve structure.
5. Add code/example.
6. Practice final 90-second version.

---

# Final Night Emergency Plan

If you only have 2 hours:
1. Review OTel rollout.
2. Review includes/preload/eager_load/joins.
3. Review slow endpoint debugging.
4. Review WorkScheduler refactor risks.
5. Review RFI system design.
6. Review webhook architecture.
7. Review AI agentic workflow.
8. Prepare “Tell me about yourself.”
