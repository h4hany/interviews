# Procore Staff Software Engineer – RoR Interview Prep Guide

---

## About Procore Technologies

**What they do:** Procore is the leading cloud-based construction management platform (NYSE: PCOR, ~$1.37B trailing revenue as of 2026). They connect owners, general contractors, specialty contractors, architects, and engineers on a single global platform covering project management, financials, BIM, field productivity, and analytics.

**Tech DNA:** The core platform is built on Ruby on Rails — they've been a Rails shop since 2002 and actively contribute to the open-source Rails ecosystem (they even open-sourced [Blueprinter](https://github.com/procore/blueprinter), their declarative Ruby JSON serializer). They are mid-journey from a Rails monolith toward a Service-Oriented Architecture (SOA).

**Engineering culture signals (from their blog & JD):**
- Decisions are made at the appropriate level, not strictly top-down
- Observability is a first-class concern as they scale microservices
- Strong emphasis on TDD, code quality, and developer experience
- AI is being treated as a **core workflow**, not just a feature — their intelligence layer is called **Procore Helix**, and their AI assistant is **Procore Assist** (photo analysis for safety, multilingual, mobile-first)
- New CEO Ajei Gopal (ex-Ansys) is pushing "AI as the next meaningful catalyst" for construction

**Your angle:** You architected a production AI recommendation engine, drove sub-100ms vector search, reduced API costs ~80% via semantic caching, and optimized PostgreSQL at scale. That story maps directly to what Procore is building with Helix.

---

## Interview 1: Specialized Technical Interview (60 min)

### Q1 — Distributed Tracing & OpenTelemetry in a Rails Monolith → SOA Migration

**The question:** Walk me through rolling out OpenTelemetry in an existing Rails monolith transitioning to SOA. What telemetry data is most critical, and how do you handle trace context propagation across service boundaries?

**How to answer:**

**Phase 1 — Instrument the monolith first (don't wait for SOA)**

Start by adding the OTel SDK to the Rails app before any service extraction. This baseline gives you a performance map you'll need to make safe extraction decisions.

```ruby
# Gemfile
gem 'opentelemetry-sdk'
gem 'opentelemetry-instrumentation-all'   # covers Rails, ActiveRecord, Sidekiq, Redis, Net::HTTP, etc.
gem 'opentelemetry-exporter-otlp'

# config/initializers/opentelemetry.rb
require 'opentelemetry/sdk'
require 'opentelemetry/instrumentation/all'

OpenTelemetry::SDK.configure do |c|
  c.resource = OpenTelemetry::SDK::Resources::Resource.create(
    'service.name'    => ENV.fetch('OTEL_SERVICE_NAME', 'procore-monolith'),
    'service.version' => ENV.fetch('APP_VERSION', 'unknown'),
    'deployment.environment' => Rails.env
  )
  c.use_all   # auto-instruments Rails, AR, Sidekiq, Faraday, etc.
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::OTLP::Exporter.new(endpoint: ENV['OTEL_EXPORTER_OTLP_ENDPOINT'])
    )
  )
end
```

**Critical telemetry signals to capture:**

| Signal | What to capture | Why |
|--------|-----------------|-----|
| **Traces** | HTTP request → controller → AR queries → external calls | Full request lineage across future service boundaries |
| **Spans** | DB query duration, N+1 patterns, serialization time | Identify bottlenecks before and after extraction |
| **Metrics** | Request rate, error rate, p95/p99 latency per endpoint | SLO baselines before you extract a service |
| **Logs (correlated)** | `trace_id` + `span_id` injected in every log line | Correlate logs with traces in Datadog/Grafana |

**Phase 2 — Trace context propagation across service boundaries**

When a Rails monolith calls an extracted service (e.g., over HTTP or gRPC), W3C TraceContext headers (`traceparent`, `tracestate`) must be propagated. The `opentelemetry-instrumentation-faraday` and `opentelemetry-instrumentation-net_http` gems handle this automatically for outbound calls. For async boundaries (Sidekiq jobs, Kafka messages), you must manually propagate:

```ruby
# Injecting context into a Sidekiq job payload
class ProjectUpdateWorker
  include Sidekiq::Worker

  def self.perform_later(project_id)
    carrier = {}
    OpenTelemetry.propagation.inject(carrier)   # injects traceparent into hash
    perform_async(project_id, carrier)
  end

  def perform(project_id, carrier)
    context = OpenTelemetry.propagation.extract(carrier)
    OpenTelemetry::Context.with_current(context) do
      OpenTelemetry.tracer_provider.tracer('worker').in_span('project_update') do |span|
        span.set_attribute('project.id', project_id)
        # ... actual work
      end
    end
  end
end
```

**Phase 3 — Custom spans for business context**

Generic instrumentation is not enough for a domain as complex as construction project management. Add custom spans for high-value operations:

```ruby
tracer = OpenTelemetry.tracer_provider.tracer('procore.project_management')

tracer.in_span('budget.recalculate', attributes: {
  'project.id'       => project.id.to_s,
  'budget.line_items' => line_items.count,
  'user.id'          => current_user.id.to_s
}) do |span|
  result = BudgetCalculator.new(project).recalculate
  span.set_attribute('budget.change_pct', result.change_percentage)
  result
end
```

**Procore-specific answer angle:** Mention that at Procore scale — thousands of concurrent construction projects — the most valuable traces are around **permission checks** (usually the most expensive AR-heavy operation in construction SaaS), **document/drawing versioning queries**, and **aggregation queries across project hierarchies**. Tracing these before extraction lets you set SLOs and detect regressions in the extracted service immediately.

---

### Q2 — Performance & Payload Optimization (Rails Bottleneck Story)

**Use your Escape Ventures story but frame it for Procore scale.**

**Example STAR answer:**

**Situation:** Our AI recommendation engine had a `/recommendations` endpoint that degraded to 800ms p95 under moderate load on our PostgreSQL+pgvector setup. We were also seeing our OpenAI API bill balloon as traffic grew.

**Task:** Bring p95 below 100ms and reduce API costs without degrading recommendation quality.

**Action (three layers):**
1. **N+1 elimination** — Used `rack-mini-profiler` + `bullet` gem in development to identify that our serializer was triggering 1 AR query per recommended item to load associated tags. Added `includes(:tags, :category)` and custom serialization with Blueprinter (coincidentally Procore's own open-source gem).
2. **Semantic caching** — Built a cache layer: before hitting OpenAI for embeddings, we query pgvector for semantically similar cached prompts (cosine similarity > 0.92 threshold). Cache hit rate reached ~68%, cutting API costs ~80%.
3. **Payload size** — Audit response payloads with `rack-mini-profiler`. Removed unused fields from JSON responses (cut payload size 40%), introduced cursor-based pagination instead of offset, and added `fields` query parameter for sparse fieldsets.

**Result:** p95 dropped from 800ms to sub-100ms, API costs down ~80%, and the caching layer became a reusable service.

**Rails-specific techniques to name-drop:**
- `bullet` gem for N+1 detection
- `rack-mini-profiler` for request profiling
- `db:explain` / `EXPLAIN ANALYZE` for query plans
- `eager_load` vs `includes` vs `preload` — know the difference
- `counter_cache` for reducing aggregate queries
- Database indexes on foreign keys and composite indexes for common filter patterns
- `select` to avoid `SELECT *` and reduce memory allocation

---

### Q3 — AI & Agentic Workflows

**The question:** How are you using generative tools daily, and as a Staff Engineer, how would you design features that move a product from "using AI" to providing "agentic workflows" for construction users?

**Daily usage (be honest and specific):**
- GitHub Copilot / Cursor for code generation and refactoring
- Claude/ChatGPT for architecture brainstorming, PR descriptions, and breaking down complex system design problems
- AI-assisted code review (catching issues I might miss after hours of context-switching)
- Building internal tooling with AI (career-ops repo, automated job matching, etc.)

**The architecture answer — moving from AI to Agentic:**

The key distinction:
- **AI features** = the user asks a question, the AI answers, the user acts. Human in the loop for every step.
- **Agentic workflows** = the AI perceives state, plans multi-step actions, executes them, and only surfaces to the human for decisions, approvals, or exceptions.

**Construction-specific agentic workflow design — Example: "RFI Resolution Agent"**

An RFI (Request for Information) is a formal question a contractor sends to an architect during construction. Today it's manual: someone drafts it, routes it, waits, follows up. An agentic version:

```
Trigger: New RFI created with drawings attached
  → Agent parses RFI + extracts relevant drawing sections (vision model)
  → Agent searches historical RFIs in vector store for similar past resolutions
  → Agent drafts a suggested response with references
  → Agent checks if resolution requires design change (→ routes to architect)
     or is a clarification (→ auto-sends with review flag)
  → Agent monitors response deadline; escalates if SLA breached
  → Agent updates project log automatically
```

**Technical architecture for this:**

```
[Procore Event Stream] → [Agent Orchestrator (Rails + Sidekiq)]
       ↓
[Tool Registry]
  - search_historical_rfis(embedding_query) → pgvector
  - fetch_drawing_section(drawing_id, region) → S3/CDN
  - draft_response(context) → LLM (Claude/GPT-4o)
  - send_rfi_response(rfi_id, response) → Procore API
  - escalate_to_user(rfi_id, reason) → notification service
       ↓
[Human Approval Queue] (only when confidence < threshold or design change detected)
```

**Key engineering considerations for agentic systems at Procore scale:**
- **Observability is critical** — every agent action must be a traced span with the prompt, tool call, and output logged. This is why OTel setup matters so much.
- **Idempotency** — agents will retry on failure; tool calls must be idempotent.
- **Human-in-the-loop gates** — never auto-approve financial commitments or safety-related actions.
- **Cost controls** — rate limit LLM calls, use semantic caching, fall back to smaller models for routine classifications.

---

### Q4 — TDD & Code Quality at Scale

**The question:** How do you champion TDD across multiple teams without it becoming a bottleneck?

**Answer framework:**

**The bottleneck myth:** TDD slows teams down only when it's treated as a rule rather than a design tool. The slowdown comes from writing tests for the wrong things — testing implementation details instead of behavior.

**What I do as a Staff Engineer:**

1. **Lead by example in PR reviews** — When I review a PR that has no tests, I don't reject it. I pair with the author to write one test together. That 15-minute investment teaches more than any document.

2. **Define a test strategy hierarchy** (communicate as a team norm, not a mandate):
    - **Unit tests** → pure business logic, service objects, value objects. Fast, deterministic, no DB.
    - **Integration tests** → AR models with actual DB queries (use `DatabaseCleaner`, test real SQL).
    - **Request specs** → happy path + error path for each API endpoint. Use `VCR` or `WebMock` for external services.
    - **No controller tests** — test controllers through request specs.

3. **Contract tests for SOA drift** — The biggest risk in a distributed system is mocks diverging from reality. Use **Pact** (consumer-driven contract testing) between services. The consumer defines what it expects; the provider verifies it. This replaces fragile stub-based integration tests.

   ```ruby
   # Consumer (Project Service) defines its expectation
   Pact.service_consumer "ProjectService" do
     has_pact_with "PermissionsService" do
       mock_service :permissions_service do
         port 1234
       end
     end
   end
   ```

4. **Golden path templates** — Ship a Rails generator that scaffolds a service object + spec file with the correct structure. Reduces friction to test.

5. **Metrics, not mandates** — Track test coverage trends in CI (SimpleCov), but set a floor (say 85%) rather than requiring 100%. Call out regressions in retros.

**On mocks drifting from reality:** The answer is not "mock less" but "verify contracts." VCR cassettes expire. Pact contracts break builds when providers change. Both force you to keep mocks honest.

---

### Q5 — Mentorship & Code Reviews (Architectural Violation in a PR)

**The question:** A junior engineer submits a PR that technically works but violates core architectural principles or introduces severe performance risks. How do you handle it?

**Answer:**

My approach has three layers: **protect the codebase, protect the relationship, create a learning moment.**

**First: never reject a PR without a conversation.** I leave a comment like: "This works! Before we merge, I want to walk through something with you — can we do a quick 15-min call?" That tone matters. Public shaming in PR comments is the fastest way to make junior engineers stop taking risks.

**In the conversation:**
1. Acknowledge what works — be specific ("your approach to handling the edge case in line 47 is clean")
2. Explain the *principle* being violated, not just the violation — "We separate data access from business logic in service objects because when we had fat models, adding a feature in one place broke three unrelated workflows. Here's a real incident where that happened."
3. Ask them to fix it — don't fix it for them unless there's a hard deadline. "How would you restructure this given what we discussed?"

**For performance risks specifically:** I add a comment with the projected impact. "This query will work on our current data set, but at 10x our current project volume — which we hit every 18 months — this will degrade to 8s. Here's why: [EXPLAIN ANALYZE output]. Let's fix this now while the code is fresh."

**Systemic fix:** If I'm seeing the same violation repeatedly across PRs from multiple engineers, it's a documentation problem, not a people problem. I write an Architecture Decision Record (ADR) and link it from the PR.

---

## Interview 2: Software Architecture Interview (60 min)

### Q1 — System Design: Real-Time Activity Feed / Collaborative Daily Log

**The question:** Design a real-time activity feed or collaborative daily log for a high-traffic construction site.

**Clarify first (1-2 min):**
- Read-heavy or write-heavy? (Activity feeds are read-heavy, ~10:1)
- Real-time required or near-real-time (a few seconds acceptable)?
- How many concurrent users per project? Per site?
- Does every event go to every subscriber, or filtered by role/permissions?

**Architecture:**

```
[Mobile/Web Clients]
       ↓ write
[API Gateway (Rails)]
       ↓
[Event Bus — Kafka or AWS SNS/SQS]
  ↓ topic: project.{project_id}.events
[Activity Fan-Out Service]
  → writes to: Activity Feed Store (Redis Sorted Set per project)
  → writes to: PostgreSQL (durable audit log)
  → pushes to: WebSocket Hub (ActionCable / Pusher)
       ↓ read
[Feed Read API — cached in Redis]
       ↓
[Clients via WebSocket or HTTP polling fallback]
```

**Key design decisions:**

**Storage:** Redis Sorted Set keyed by `project:{id}:feed`, scored by timestamp. `ZREVRANGE` gives paginated feed in O(log N + M). Keep only last 1000 events in Redis; older events served from PostgreSQL with cursor pagination.

**Fan-out strategy:** At Procore's scale, a project can have hundreds of active users. Use **fan-out on write** for projects with < 500 subscribers (write to each subscriber's personal feed cache). Use **fan-out on read** for larger projects (compute the feed at read time from the project stream). This hybrid approach (used by Twitter/Instagram) avoids massive write amplification for large projects.

**Real-time delivery:** ActionCable for same-datacenter clients. For cross-region, use a pub/sub layer (Pusher or Ably) that handles WebSocket connections at scale so Rails doesn't hold 100k open connections.

**Consistency:** Events are idempotent with a UUID. Clients deduplicate on `event_id`. Accepted eventual consistency (seconds-level) for activity feeds — a construction daily log doesn't need millisecond consistency.

**Fault tolerance:** Event bus buffers writes if the fan-out service is down. WebSocket reconnect with last-seen event ID; server replays missed events from PostgreSQL.

---

### Q2 — Monolith to SOA: Extracting a Heavily Coupled Domain

**The question:** Extract a heavily coupled domain (like Permissions or Project Scheduling) from a Rails monolith.

**My framework — the Strangler Fig pattern:**

**Phase 0: Don't extract until you can trace it.** Install OTel first (see Interview 1, Q1). Map all callers of the domain using code analysis (`grep`/`ast-grep` for Ruby) + trace data.

**Phase 1: Modularize in place first**

Before extracting, isolate the domain within the monolith using a Rails Engine or a bounded context module:
```
app/
  domains/
    permissions/
      models/
      services/
      api/  ← internal Ruby interface — no cross-domain AR associations allowed
```
Enforce the boundary with `packwerk` (Shopify's Ruby gem for modular monoliths). This step alone often reveals hidden dependencies you didn't know existed.

**Phase 2: Dual-write to new service (shadow mode)**

Deploy the new service but don't route any reads to it yet. Write to both the monolith DB and the new service DB. Compare outputs. This catches data divergence before any user is impacted.

```ruby
class PermissionsService
  def can?(user, action, resource)
    monolith_result = LegacyPermission.check(user, action, resource)

    # Shadow call — async, non-blocking, errors swallowed
    ShadowCallJob.perform_later(:permissions_service, :can,
                                { user: user.id, action:, resource: resource.id },
                                expected: monolith_result)
    monolith_result
  end
end
```

**Phase 3: Read migration (dark launch)**

Route a small % of read traffic to the new service using a feature flag. Compare results. Gradually increase to 100%.

**Phase 4: Cut over and deprecate**

Once reads are 100% on new service, writes become the source of truth in the new service, and the monolith reads via internal API. Remove the legacy code after one release cycle.

**Database splitting:** Use logical replication from PostgreSQL to stream the domain's tables to the new service's DB during migration. This avoids downtime. After cutover, drop the FK constraints that tied it to the monolith schema.

**Zero-downtime deployment:** Every API change is versioned (`/v1/permissions/check`). Old callers keep working. New behavior introduced in `/v2`. Monolith pinned to `v1` until all callers are updated.

---

### Q3 — Balancing Short-Term vs Long-Term (Architectural Trade-offs)

**The question:** Tell me about a time you balanced immediate business needs with strategic architectural health.

**STAR answer:**

**Situation:** At Escape Ventures, we were building the AI recommendation engine. The product team needed a demo-ready feature in 3 weeks for an investor presentation. The "right" architecture was a proper ML pipeline with a feature store, async embedding generation, and a semantic cache layer. Building it correctly would take 8 weeks.

**Task:** Ship something investor-demo-ready in 3 weeks without making the 8-week version impossible.

**Action:**
1. **Agreed on the interface first** — We defined the API contract (`POST /recommendations` with the response schema) and committed it in an ADR before writing a line of code. This meant the front-end and the ML work could happen in parallel, and replacing the backend implementation wouldn't break callers.
2. **Shipped a synchronous stub** — Week 1-3: synchronous OpenAI call, no cache, results stored in PostgreSQL. Worked fine for the investor demo (10 concurrent users).
3. **Documented the debt explicitly** — Created a technical debt ticket with the projected failure mode: "This will fail at ~50 concurrent users; estimated 6 weeks post-funding to replace with async pipeline + cache."
4. **Communicated to PM in business language** — "We're borrowing 6 weeks of future engineering time. Here's what will break if we hit 50 users before repaying it: [specific user-facing symptoms]. We need to start repayment 4 weeks after launch."

**Result:** Demo succeeded, funding closed. We began the proper rebuild 3 weeks post-launch as agreed.

**Key principle to state:** Technical debt isn't bad if it's *chosen consciously* and *documented with a repayment plan*. The failure mode is when it's accidental and invisible.

---

### Q4 — Datastore Selection: Graph Database vs PostgreSQL

**The question:** When would you choose a Graph database instead of PostgreSQL for a construction platform feature?

**Answer framework:**

PostgreSQL is the right default. Choose a graph database when **the query is about traversing relationships of unknown depth, and the number of joins required would make a relational query exponentially slower.**

**Construction domain example — where graphs win:**

Imagine modeling a construction project's responsibility chain:
```
Company A (GC)
  → SubcontractorB (electrical)
      → IndividualUser C (foreman)
          → Task D (panel installation)
              → Drawing E (electrical plan, version 3)
                  → RFI F (clarification on panel spec)
```

Query: "Find all RFIs that are blocked because the responsible user reports to a subcontractor that has an expired insurance certificate."

In PostgreSQL, this requires 5-6 JOINs across `companies`, `subcontractors`, `users`, `tasks`, `rfis`, `insurance_docs`. If the hierarchy is variable depth (GC → Sub → Sub-sub → user), you need recursive CTEs, which become slow and hard to maintain.

In Neo4j/Amazon Neptune (Gremlin/Cypher):
```cypher
MATCH (rfi:RFI)-[:BLOCKED_BY]->(task)-[:ASSIGNED_TO]->(user)
      -[:REPORTS_TO*1..5]->(sub:Subcontractor)
      -[:HAS]->(cert:InsuranceCert {status: 'expired'})
RETURN rfi, sub, cert
```

The `*1..5` traversal handles variable-depth hierarchies natively and efficiently.

**When to stay with PostgreSQL:**
- The relationship depth is bounded and known (e.g., always project → user, never more than 2 hops)
- You need strong ACID transactions across the relationship
- Your team doesn't have graph DB expertise (operational cost is real)
- The queries can be solved with a materialized view or recursive CTE in <50ms

**Verdict for Procore:** PostgreSQL with `ltree` extension or a closure table pattern handles most construction hierarchy queries. Reach for a graph DB only for compliance/audit trail queries that traverse unknown-depth org charts or complex "who is responsible for what" permission models.

---

### Q5 — Platform Extensibility: Webhook & API Architecture

**The question:** Design a robust, secure webhook or API architecture for massive volume that doesn't degrade the core system.

**Architecture:**

```
[Core Procore Rails App]
       ↓ publishes events
[Internal Event Bus (Kafka)]
       ↓
[Webhook Dispatch Service] (dedicated, isolated from core)
  - Subscribes to event topics
  - Loads registered webhook subscriptions from DB
  - Dispatches HTTP POST to subscriber URLs
  - Handles retries with exponential backoff
       ↓
[Third-Party Developer Endpoints]
```

**Key design decisions:**

**1. Isolation from core:** The webhook dispatch service is a separate process/service. If a third-party endpoint is slow or down, it never blocks or slows down the Rails app. The event bus decouples the two.

**2. Reliability — guaranteed delivery:**
- Persist every outbound webhook attempt to a `webhook_deliveries` table with status (`pending`, `delivered`, `failed`)
- Retry with exponential backoff: 1m → 5m → 30m → 2h → 24h (max 5 attempts, then alert developer)
- Idempotency key in every payload (`X-Procore-Delivery-ID` header) so receivers can safely deduplicate retries

**3. Security:**
- Sign every payload with HMAC-SHA256 using a per-subscription secret: `X-Procore-Signature: sha256=<hex>`
- Developers verify the signature before processing. Reject unverified requests.
- Rotate secrets without downtime: support two active secrets per subscription during rotation window

**4. Backpressure & rate limiting:**
- Per-subscriber rate limit (e.g., 1000 events/min) to protect both Procore and the developer's endpoint
- Circuit breaker per subscriber URL: if 5 consecutive failures, pause delivery and notify developer
- Dead letter queue for permanently failed events — developers can replay from dashboard

**5. Observability:**
- Trace every dispatch event with OTel: delivery latency, retry count, error type
- Developer-facing delivery log in dashboard (what was sent, when, response code)

**API extensibility (beyond webhooks):**
- Public REST API versioned at URL path (`/v1/`, `/v2/`)
- Rate limited by API key tier (free/partner/enterprise)
- OAuth 2.0 for third-party app authorization
- Webhooks + API are complementary: webhooks push events, API allows pull/read

---

## Additional Questions They May Ask

### Behavioral / Leadership

**"Tell me about a time you influenced an architectural decision without direct authority."**
Use: The OTel/observability push before the SOA migration — convinced the team by showing concrete data (latency distributions from profiling) rather than arguing in the abstract.

**"Describe a situation where you had to say no to a stakeholder request."**
Prepare a story where you pushed back on a scope expansion or an "easy shortcut" by articulating the long-term cost in their terms (business risk, not tech jargon).

**"How do you onboard to a large, unfamiliar codebase?"**
Answer: Read the ADRs first (if they exist). Then trace a critical user request end-to-end using the profiler or APM tool. Talk to the person who's been there the longest. Don't optimize anything for the first 30 days.

---

### Ruby / Rails Deep Dives

**"Explain the difference between `includes`, `preload`, and `eager_load` in ActiveRecord."**
- `preload` → always 2 queries (SELECT * FROM posts, then SELECT * FROM comments WHERE post_id IN (...))
- `eager_load` → always 1 query with LEFT OUTER JOIN (needed when filtering on the associated table)
- `includes` → picks `preload` by default, switches to `eager_load` if you reference the association in a `where` or `order`

**"How does Rails handle database connection pooling, and what can go wrong?"**
- Puma threads each need a DB connection; pool size should match `puma.rb` thread count × worker count
- Common production issue: `ActiveRecord::ConnectionTimeoutError` when threads exceed pool size
- Fix: `pool: ENV['RAILS_MAX_THREADS']` in `database.yml`, match Puma config

**"What is the difference between optimistic and pessimistic locking in Rails, and when would you use each?"**
- **Optimistic** (`lock_version` column): No DB lock; raises `StaleObjectError` if another process updated the record since you read it. Best for low-contention scenarios (user editing their profile).
- **Pessimistic** (`with_lock` / `lock!`): Issues `SELECT ... FOR UPDATE`; other processes block until lock released. Best for high-contention scenarios (inventory decrement, budget allocation).

**"How do you handle background job failures in a distributed system? What's your retry strategy?"**
- Sidekiq with `sidekiq-pro` for reliable scheduled retries
- Exponential backoff with jitter to avoid thundering herd
- Dead job queue for forensics
- Idempotent job design — jobs must be safe to run twice (use `unique` middleware for critical jobs)
- Monitor dead queue size as a leading indicator of systemic failure

---

### OpenTelemetry Deep Dives

**"What's the difference between a Trace, a Span, and a Metric in OTel?"**
- **Trace** = a directed acyclic graph of spans representing a single request's journey
- **Span** = a single unit of work within a trace (e.g., one DB query, one HTTP call) with start/end time and attributes
- **Metric** = an aggregated measurement over time (e.g., `http.server.request.duration` as a histogram) — not tied to individual requests

**"How do you handle sampling in production without losing critical trace data?"**
- **Head-based sampling** (at trace start): simple but may drop error traces. Use `TraceIdRatioBased(0.1)` for normal traffic.
- **Tail-based sampling** (at trace end, in the OTel Collector): keeps 100% of error traces and slow traces, samples down the rest. Best for production.
- For Procore: keep 100% of traces for any span with `error=true` or `duration > 2s`

---

### System Design Edge Cases

**"How would you design the permissions system for Procore, where a user can have different roles on different projects?"**
This is a classic RBAC (Role-Based Access Control) + project scope problem. Key: roles are project-scoped, not global. Model: `user_project_roles(user_id, project_id, role_id)`. Cache permission checks aggressively (Redis, keyed by `user:{id}:project:{id}:permissions`, invalidated on role change event).

**"How would you approach database migrations with zero downtime on a large PostgreSQL table (50M+ rows)?"**
- Never run `ALTER TABLE ADD COLUMN NOT NULL DEFAULT` on a large table in production — it locks the table
- Use the `strong_migrations` gem to catch dangerous migrations at deploy time
- Three-step process: (1) Add nullable column, (2) backfill in batches with `UPDATE ... WHERE id BETWEEN`, (3) Add NOT NULL constraint using `NOT VALID` then `VALIDATE CONSTRAINT` separately
- For index creation: `CREATE INDEX CONCURRENTLY` — builds without locking writes

---

## Quick Reference: Procore-Specific Angle for Every Answer

| Topic | Tie it back to Procore |
|-------|----------------------|
| OTel / Observability | Procore is mid-SOA migration — observability is how you make service extraction safe and measurable |
| Performance | Construction SaaS has large hierarchical data (projects → companies → users → tasks) — N+1s are common and expensive |
| AI / Agentic | Procore Helix / Procore Assist — they're already building this; show you understand the domain (RFIs, submittals, daily logs, drawings) |
| Graph DB | Construction has rich relationship graphs; know when PostgreSQL + `ltree` is enough vs. Neptune/Neo4j |
| Permissions | Project-scoped RBAC is a core, tricky domain at Procore — it's literally one of the extraction candidates in the JD |
| TDD | They use Blueprinter (their own gem) — familiarity signals you've done your homework |
| Platform extensibility | Procore has a public API and marketplace — webhook reliability is a real product concern |

---

*Last updated: June 2026 — Tailored for Procore Staff Software Engineer – RoR, Cairo*
