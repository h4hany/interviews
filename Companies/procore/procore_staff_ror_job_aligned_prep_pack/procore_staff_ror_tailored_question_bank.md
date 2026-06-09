# Procore Staff RoR Tailored Interview Question Bank

> Questions organized by the role signals in the job description.

## Master Deep-Dive Prompt

```text
Act as a Principal Engineer at Procore interviewing me for Staff Software Engineer - Ruby on Rails.
Ask me one question from this guide, wait for my answer, then grade it on:
- correctness,
- Staff-level tradeoff thinking,
- Rails depth,
- production reliability,
- observability,
- communication clarity.
Then give me a stronger answer and 3 follow-up questions.
Question: [PASTE QUESTION]
```

---

# Category: Ruby on Rails Core

## Q1. Explain the Rails request lifecycle.
**Interview level:** Junior / Mid / Senior  
**Answer:** A request flows from web server/Puma into Rack middleware, then router, controller, service/domain layer, ActiveRecord/database, serializer/view, and response. Middleware handles cross-cutting concerns like sessions, request IDs, logging, authentication, CORS, and tracing.  
**Staff addition:** Every request should have a request ID and trace ID propagated into downstream services and background jobs.

```ruby
Rails.logger.info(
  message: "task_created",
  request_id: request.request_id,
  trace_id: OpenTelemetry::Trace.current_span.context.hex_trace_id
)
```

## Q2. What are `includes`, `preload`, `eager_load`, and `joins`?
**Interview level:** Senior / Staff  
**Answer:** `preload` always uses separate queries. `eager_load` always uses a `LEFT OUTER JOIN`. `includes` lets Rails decide; it often preloads unless the associated table is referenced. `joins` creates SQL joins for filtering but does not load association objects.  
**Real example:** In a task list, preload assignees for display; use joins/eager_load if filtering by assignee company.

```ruby
Task.preload(:assignees).where(project_id: project.id)
Task.joins(:assignees).where(users: { company_id: company.id })
```

**Tradeoff:** Eager loading huge associations can increase memory. Measure SQL count and memory before/after.

## Q3. How do Rails transactions interact with background jobs?
**Interview level:** Senior / Staff  
**Answer:** Data changes inside a transaction are not visible until commit. If you enqueue a job before commit, the job may run and fail because it cannot find committed data. Use `after_commit` or the outbox pattern.

```ruby
ActiveRecord::Base.transaction do
  task.update!(status: "completed")
  ActivityLog.create!(task:, actor:, action: "completed")
  OutboxEvent.create!(event_type: "task.completed", aggregate_id: task.id)
end
```

## Q4. Validation vs database constraint?
**Interview level:** Junior / Senior  
**Answer:** Validation is for UX; constraints are for correctness under concurrency.

```ruby
validates :email, presence: true, uniqueness: true
add_index :users, :email, unique: true
```

## Q5. How do you structure a large Rails application?
**Interview level:** Staff / Principal  
**Answer:** Organize around domain boundaries, not just MVC folders. Use packages/engines or `app/domains`, explicit interfaces, no circular dependencies, and boundary enforcement like Packwerk.

```text
app/domains/project_management/
app/domains/permissions/
app/domains/notifications/
app/domains/documents/
```

---

# Category: Performance and Optimization

## Q6. How do you debug a slow Rails endpoint in production?
**Interview level:** Senior / Staff  
**Answer:** Start with production signals: p95/p99, traces, logs, errors, deployment markers. Compare fast and slow traces. Break time into controller, DB, cache, serialization, external calls, and queueing. Fix the smallest high-impact bottleneck, then verify with metrics.

## Q7. How do you reduce payload size?
**Interview level:** Staff  
**Answer:** Return only fields needed, avoid deep nesting, paginate, separate list/detail endpoints, use sparse fieldsets, compression, and optimized serializers.

```ruby
render json: tasks,
  only: [:id, :title, :status, :due_date],
  methods: [:assignee_summary]
```

## Q8. What causes memory bloat in Rails?
**Interview level:** Senior / Staff  
**Answer:** Loading too many AR objects, huge serializers, unbounded arrays, large exports, eager loading too much, and global caches. Fix with `find_each`, `pluck`, streaming, pagination, smaller batches, and profiling.

```ruby
Task.where(project_id: project.id).find_each(batch_size: 1000) do |task|
  ProcessTask.call(task)
end
```

## Q9. How do you choose database indexes?
**Interview level:** Senior / Staff  
**Answer:** Based on query patterns and `EXPLAIN ANALYZE`, not guesses. Consider WHERE, JOIN, ORDER BY, uniqueness, partial indexes, and write overhead.

```ruby
add_index :tasks, [:project_id, :status, :due_date], algorithm: :concurrently
add_index :tasks, :due_date, where: "status != 'closed'", algorithm: :concurrently
```

---

# Category: OpenTelemetry / Runtime

## Q10. How would you roll out OpenTelemetry in a Rails monolith moving to SOA?
**Interview level:** Staff / Principal  
**Answer:** Instrument the monolith first, define service/env/version attributes, enable Rails/ActiveRecord/Sidekiq/Redis/HTTP auto-instrumentation, add custom business spans, propagate W3C trace context across HTTP and async jobs, define sampling, and create SLO dashboards.

```ruby
tracer.in_span("permissions.evaluate") do |span|
  span.set_attribute("project.id", project.id)
  span.set_attribute("permission.action", action)
  PermissionEvaluator.call(user:, project:, action:)
end
```

## Q11. Logs vs metrics vs traces?
**Interview level:** Senior  
**Answer:** Metrics tell whether something is wrong, traces show where time went, logs explain details. Correlate logs with trace IDs.

## Q12. What is high cardinality and why does it matter?
**Interview level:** Staff  
**Answer:** High cardinality means many unique values like user emails, raw URLs, or request IDs. It increases cost and can break metric backends. Use route templates and approved stable IDs; avoid PII.

## Q13. How does Ruby GVL affect Puma?
**Interview level:** Senior / Staff  
**Answer:** Only one Ruby thread executes Ruby bytecode at a time, but threads help with I/O because Ruby releases the GVL during DB/HTTP/file I/O. For CPU-bound work, use processes or external workers; for I/O-bound Rails requests, Puma threads are useful.

---

# Category: SOA / Architecture

## Q14. How would you extract Permissions from a Rails monolith?
**Interview level:** Staff / Principal  
**Answer:** Instrument first, modularize in place, create an internal interface, stop direct table access, introduce the new service behind a client, use shadow reads/dual writes temporarily, backfill and verify data, gradually shift traffic with feature flags, and fail closed for security-sensitive decisions.

## Q15. What is the outbox pattern?
**Interview level:** Senior / Staff  
**Answer:** Write business data and an event record in the same DB transaction. A worker later publishes side effects. This avoids losing events when DB commit succeeds but event publishing fails.

## Q16. Monolith vs microservices?
**Interview level:** Staff / Principal  
**Answer:** Start with modular monolith when domain boundaries are still evolving and transactions matter. Extract services when team ownership, independent scaling, deployment independence, or data lifecycle justify the distributed systems cost.

---

# Category: Project Management System Design

## Q17. Design an RFI management system.
**Interview level:** Staff  
**Answer outline:** Clarify users and workflow. Model RFIs, responses, comments, attachments, audit logs, outbox events. Use Rails modular monolith, PostgreSQL, S3, Redis, Sidekiq, search index. Strong consistency for status/official responses; eventual consistency for notifications/search.

## Q18. Design a document/drawing management system.
**Interview level:** Staff  
**Answer outline:** Direct-to-S3 uploads, PostgreSQL metadata/versioning, background virus scan/OCR/preview, search indexing, audit logs, signed URLs, version correctness, warning for outdated drawings.

## Q19. Design a notification system.
**Interview level:** Senior / Staff  
**Answer outline:** Domain event → outbox → notification processor → in-app/email/push queues. Idempotency, preferences, permissions, retries, dead-letter queue, grouping/digests.

## Q20. Design platform webhooks.
**Interview level:** Staff / Principal  
**Answer outline:** Event bus/outbox, isolated dispatch service, HMAC signatures, delivery table, retry with backoff+jitter, circuit breaker, rate limits, replay, developer dashboard.

---

# Category: AI / Agentic Workflows

## Q21. AI feature vs agentic workflow?
**Interview level:** Staff  
**Answer:** AI feature is a one-shot output like summarization. Agentic workflow understands a goal, retrieves context, plans steps, uses tools, asks for approval, executes safely, and leaves audit trail.

## Q22. Design a Daily Log Assistant.
**Interview level:** Staff / Principal  
**Answer outline:** Context retrieval from schedule/weather/photos/RFIs/notes, LLM planner, tool layer, policy/permission layer, human approval, audit log, evaluation metrics, cost/latency controls.

---

# Category: Leadership / Staff Behavior

## Q23. How do you review a junior engineer's PR that works but is risky?
**Interview level:** Staff / Team Lead  
**Answer:** Acknowledge what works, explain concrete risk, propose path forward, pair if needed, and codify repeated patterns into docs/lint/templates.

## Q24. How do you champion TDD without slowing teams?
**Interview level:** Staff / Manager  
**Answer:** Treat TDD as a design tool. Use risk-based testing: unit tests for domain logic, request specs for APIs, contract tests for SOA, integration tests for core workflows, E2E only for critical journeys. Track flaky tests and CI time.

## Q25. How do you communicate technical debt to product?
**Interview level:** Staff / Manager  
**Answer:** Translate it into business risk: slower delivery, bugs, onboarding cost, performance risk. Offer phased delivery with ADR and payback plan.
