# System Design Patterns — Architecture Framework, SOA, Consistency, Async

> Reusable patterns for any architecture question at Procore.

---

## 1. Architecture Interview Structure

Use this framework for every design question:

```text
1.  Clarify requirements (users, workflow, scale, consistency, UX, security)
2.  State assumptions
3.  Define functional requirements
4.  Define non-functional requirements
5.  Capacity estimation (quick math)
6.  High-level design
7.  Low-level design (Rails components)
8.  API design
9.  Database design + indexes
10. Async processing
11. Caching strategy
12. Observability
13. Security
14. Tradeoffs and evolution
```

### Opening Statement
> "Before jumping to architecture, I'd clarify the users, scale, consistency requirements, and whether this is internal or customer-facing. My default would be to start with a modular Rails monolith backed by PostgreSQL, Redis, and Sidekiq, then extract services only if team ownership, scale, or deployment independence requires it."

---

## 2. Modular Monolith First

### Why Start Here
- Construction domain entities are highly relational and transactional
- Strong transaction boundaries are easier in a monolith
- Teams move faster without distributed-system overhead
- Domain boundaries can be enforced with modules/packages

### When to Extract a Service
- Independent scaling requirements
- Independent deployment needs
- Clear team ownership boundary
- Different data lifecycle or reliability requirements
- The domain is fully understood and boundaries are clean

### Tools for Modular Monolith
- **`packwerk`** (Shopify's gem) — enforce module boundaries
- **Rails Engines** — isolated namespaces within the monolith
- **Domain directories** — `app/domains/permissions/`, `app/domains/notifications/`

> "A modular monolith gives many benefits of service boundaries without immediately paying the full distributed systems tax."

---

## 3. Monolith → SOA Extraction (Strangler Fig Pattern)

### Phase 0: Instrument Before Extracting
Install OTel. Map all callers using code analysis + trace data. You can't safely extract what you can't measure.

### Phase 1: Modularize in Place
```text
app/domains/permissions/
  models/
  services/
  api/  ← internal Ruby interface — no cross-domain AR associations
```
Enforce with `packwerk`. Reveals hidden dependencies.

### Phase 2: Dual-Write (Shadow Mode)
Deploy new service but route nothing to it yet. Write to both old and new DB. Compare outputs.

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

### Phase 3: Read Migration (Dark Launch)
Route small % of reads via feature flag. Compare results. Gradually increase to 100%.

### Phase 4: Cut Over
Writes become source of truth in new service. Monolith reads via internal API. Remove legacy code after one release cycle.

### Database Splitting
- Use PostgreSQL logical replication during migration
- After cutover, drop FK constraints tying to monolith schema
- Never maintain long-term shared database ownership

### Zero-Downtime Deployment
- Every API change is versioned (`/v1/permissions/check`)
- Old callers keep working → new behavior in `/v2`
- Expand-and-contract migrations (add new, backfill, switch, remove old)

---

## 4. Data Consistency Patterns

### Classification Framework

| Operation | Consistency Needed | Pattern |
|-----------|-------------------|---------|
| Task creation, status changes | Strong | Database transaction |
| Financial ledger entries | Strong | Transaction + append-only |
| Notifications | Eventual | Async Sidekiq job |
| Search indexing | Eventual | Async worker |
| Analytics/dashboards | Eventual | Materialized views or data warehouse |
| Email delivery | Eventual | Background job with retry |

### Outbox Pattern
Write business data + event record in the same transaction. Worker reads outbox and publishes side effects.

```text
DB transaction:
  1. Create RFI
  2. Create activity_log
  3. Create outbox_event(type: "rfi.created")

Worker picks up outbox_event:
  → Send notification
  → Update search index
  → Publish webhook
```

**Why:** Avoids losing events when DB commit succeeds but event publishing fails.

### Idempotency
Repeating the same operation doesn't create duplicate side effects.

```ruby
# Idempotency key storage
idempotency_keys
  key          VARCHAR UNIQUE
  request_hash VARCHAR
  response_body JSONB
  status       VARCHAR  # processing, completed, failed
```

For background jobs:
- Use unique job keys or external event IDs
- Add database-level unique constraints
- Check state before acting

> "I do not rely only on application checks. I prefer database-level unique constraints for final protection."

---

## 5. Async Processing Design

### What to Move Async
- Notifications (email, push, in-app)
- Search indexing
- Document processing (virus scan, OCR, thumbnails)
- Analytics events
- Audit log fan-out
- Expensive aggregations

### Sidekiq Job Design
```ruby
class DeliverWebhookJob
  include Sidekiq::Worker

  def perform(delivery_id)
    delivery = WebhookDelivery.find_by(id: delivery_id)
    return unless delivery
    return if delivery.delivered?

    response = WebhookClient.post(delivery)
    delivery.mark_delivered!(response) if response.success?
  end
end
```

### Retry Strategy
- Exponential backoff with jitter (avoid thundering herd)
- Limited retries (max 5-10)
- Dead-letter queue for permanent failures
- Monitor dead queue size as leading indicator

### Job Failure Handling
- **Transient failures** (timeout, 503) → retry with backoff
- **Permanent failures** (404, invalid data) → don't retry, send to dead queue
- **Always** → make jobs idempotent

---

## 6. Permission Design for Multi-Tenant SaaS

### Hybrid RBAC + ABAC

**RBAC (Role-Based):**
```text
Role: Project Admin → full control
Role: Project Manager → assign/update/complete
Role: Member → create/comment/update own
Role: Viewer → read only
```

**ABAC (Attribute-Based) conditions:**
```text
User can edit task IF:
  - user belongs to project
  - role has edit_task permission
  - task belongs to same project
  - task is not locked/closed
  - user's company has access
```

### Storage Model
```text
user_project_roles(user_id, project_id, role_id)
```

### Caching Permissions
```text
Redis key: user:{id}:project:{id}:permissions
Invalidate: on role change event
TTL: short (1-5 minutes)
```

### Critical Rule
Always scope by `company_id` and `project_id`. Centralize authorization policy — don't scatter permission logic across controllers.

---

## 7. Datastore Selection

### When PostgreSQL Is Enough (Most of the Time)
- Bounded relationship depth (project → user, max 2-3 hops)
- Need ACID transactions
- Team has PostgreSQL expertise
- Queries solvable with materialized views or recursive CTEs in <50ms

### When to Consider Graph DB (Neo4j / Neptune)
- Traversing relationships of **unknown depth**
- Permission inheritance across companies → projects → roles → resources
- Impact analysis: "If this drawing changes, what tasks/teams/approvals are affected?"
- Complex "who is responsible for what" queries

```cypher
MATCH (rfi:RFI)-[:BLOCKED_BY]->(task)-[:ASSIGNED_TO]->(user)
      -[:REPORTS_TO*1..5]->(sub:Subcontractor)
      -[:HAS]->(cert:InsuranceCert {status: 'expired'})
RETURN rfi, sub, cert
```

### Practical Approach for Procore
> "PostgreSQL with `ltree` extension or closure table pattern handles most construction hierarchy queries. Reach for a graph DB only for compliance/audit trail queries traversing unknown-depth org charts."

---

## 8. API Design Principles

### REST API Conventions
```http
POST /projects/:project_id/tasks
GET  /projects/:project_id/tasks?status=open&assignee_id=123&page=1
GET  /tasks/:id
PATCH /tasks/:id
POST /tasks/:id/comments
POST /tasks/:id/attachments/presign
GET  /tasks/:id/activity
```

### API Essentials
- **Pagination** — cursor-based for large datasets
- **Filtering** — by status, assignee, date ranges
- **Sorting** — by due_date, priority, created_at
- **Idempotency keys** — for create/update operations
- **API versioning** — `/v1/`, `/v2/` for external clients
- **Rate limiting** — per API key/tenant
- **Sparse fieldsets** — `?fields=id,title,status`

---

## 9. Webhook & Platform Extensibility

### Architecture
```text
Core Rails App → Internal Event Bus (Kafka) → Webhook Dispatch Service → Third-Party Endpoints
```

### Key Design Decisions
1. **Isolation** — webhook dispatch is separate from core; slow endpoints don't affect Rails
2. **Guaranteed delivery** — persist attempts, retry with exponential backoff
3. **Security** — HMAC-SHA256 signature per payload, per-subscription secret
4. **Backpressure** — per-subscriber rate limit, circuit breaker after consecutive failures
5. **Dead letter queue** — permanently failed events for developer replay

### Delivery Table
```sql
webhook_deliveries(id, subscription_id, event_id, status, attempt_count, 
                   next_retry_at, response_code, created_at)
```

---

## 10. Design Tradeoffs Cheat Sheet

| Tradeoff | When Left | When Right |
|----------|-----------|------------|
| Monolith vs Microservices | Start monolith | Extract when team/scale demands |
| SQL vs NoSQL | Default to PostgreSQL | Consider for specific access patterns |
| Sync vs Async | User needs result now | Side effects, notifications, indexing |
| Strong vs Eventual consistency | Status changes, financial data | Notifications, search, analytics |
| Cache vs Fresh data | Read-heavy, stable data | Frequently changing, permission-sensitive |
| Eager load vs Lazy load | Display pages, known associations | Large/conditional associations |
| Offset vs Cursor pagination | Simple UIs, small datasets | Large datasets, high performance |
