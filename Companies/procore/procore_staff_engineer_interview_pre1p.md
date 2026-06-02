# Procore Staff Software Engineer Interview Preparation Guide

**Candidate:** Hany Sayed Ahmed  
**Target role:** Staff Software Engineer - Ruby on Rails  
**Company:** Procore Technologies  
**Interview date:** Tuesday, June 2, 2026  
**Timezone:** EEST / GMT+3  

## Interview Schedule

| Time | Interviewer | Role | Interview |
|---|---|---|---|
| 7:00 PM - 8:00 PM | Dennis Heckman | Principal Software Engineer | Software Architecture |
| 9:00 PM - 10:00 PM | Matt Harris | Staff Software Engineer | Specialized Technical Interview - Ruby on Rails Backend / Runtime |

---

# 1. Research Summary

## What I found from public interview signals

Public Procore interview reports point to a structured process with coding, system design, technical depth, leadership/values, and project discussion. A Staff Software Engineer interview report specifically mentions a 1-hour coding round based on a real-life style problem with a function skeleton and tests, which matches exactly what you already passed.

Signals from public interview reports:

- General coding interview is often not a pure LeetCode problem. It is usually a practical business/domain problem with skeleton code and tests.
- Staff/Senior loops commonly include coding, system design, managerial/leadership, and values.
- Questions may include past projects, debugging, bugs, algorithms, and system design.
- Procore publicly emphasizes values: **Openness, Optimism, Ownership**.
- Procore Project Management product involves construction workflows such as RFIs, submittals, drawings, document management, punch lists, schedules, correspondence, emails, budget/cost visibility, integrations, mobile/offline field work, and permissions.
- Procore’s platform is used by owners, general contractors, specialty contractors, and other project collaborators, so architecture questions may involve multi-tenancy, collaboration, permissions, audit logs, document control, notifications, and real-time visibility.
- Procore publicly highlights AI-powered construction capabilities and unified project data, which makes your AI/vector search experience useful but should not dominate unless asked.

## Sources consulted

- Procore careers pages and culture pages
- Procore Project Management product pages
- Public Glassdoor-style interview summaries for Procore Staff/Senior/Software Engineer roles
- Public reports of Procore coding and system design rounds
- OpenTelemetry official Ruby documentation and Ruby/Rails instrumentation material
- Rails official ActiveRecord and instrumentation guides
- Rails performance and architecture resources
- Large Rails monolith/modular-monolith references, including Shopify-style modular monolith discussions

---

# 2. How to Position Yourself

## Your strongest positioning

> “I am a Staff-level Rails/backend engineer with production experience in scalable SaaS systems, PostgreSQL optimization, async processing, AI/semantic search, and engineering leadership. I care about pragmatic architecture, measurable performance, observability, and helping teams ship safely.”

## What to emphasize

Use these themes repeatedly:

1. **Pragmatism**
   - Do not over-engineer.
   - Start simple.
   - Add complexity only when there is evidence.

2. **Staff-level ownership**
   - You do not only implement features.
   - You clarify requirements, align teams, identify risks, design tradeoffs, and create long-term technical direction.

3. **Rails at scale**
   - Rails can scale very far with good boundaries, PostgreSQL discipline, caching, background jobs, and observability.
   - Avoid saying “I would immediately split into microservices.”

4. **Observability**
   - Tie every performance answer to metrics, traces, logs, and business impact.
   - Especially for the Runtime interview, mention OpenTelemetry naturally.

5. **Customer/business context**
   - Procore is construction SaaS. Every technical decision should protect project delivery, collaboration, correctness, and customer trust.

---

# 3. Architecture Interview with Dennis Heckman

## What the Principal Engineer will evaluate

A Principal Engineer will probably focus on:

- Can you clarify ambiguous requirements?
- Can you model a complex domain?
- Can you make tradeoffs?
- Can you design for scale without over-engineering?
- Can you explain migration strategy?
- Can you identify failure modes?
- Can you communicate clearly to technical and non-technical stakeholders?
- Can you operate at Staff level, not just Senior Engineer level?

## Your architecture answer structure

Use this structure for every design question:

1. **Clarify requirements**
2. **Define users and scale**
3. **List core entities**
4. **Start with a simple architecture**
5. **Explain APIs and data model**
6. **Add async workflows**
7. **Discuss scaling**
8. **Discuss consistency**
9. **Discuss observability**
10. **Discuss tradeoffs and future evolution**

Example opening:

> “Before jumping to architecture, I’d clarify the users, scale, consistency requirements, and whether this is an internal Procore platform capability or a customer-facing product feature. My default would be to start with a modular Rails monolith backed by PostgreSQL, Redis, and Sidekiq, then extract services only if team ownership, scale, or deployment independence requires it.”

---

# 4. Architecture Question Bank with Descriptive Answers

## Q1. Design a construction task management system for Procore projects.

### What they may ask

> “Design a system where construction teams can create, assign, track, and complete project tasks.”

### Strong answer

I would start by clarifying:

- Who creates tasks? Project managers, field engineers, subcontractors?
- Can a task have multiple assignees?
- Do tasks require approvals?
- Do we need comments, attachments, audit history?
- What scale do we expect per project?
- Is offline mobile support required?
- Are tasks visible across companies or only inside one company?

Core entities:

```text
Company
Project
User
ProjectMembership
Task
TaskAssignment
TaskComment
TaskAttachment
TaskStatusHistory
ActivityLog
Notification
```

Basic architecture:

```text
Web/Mobile Client
  |
API / Rails App
  |
Task Domain
Permission Domain
Notification Domain
File Domain
Search Domain
  |
PostgreSQL
Redis
Sidekiq
Object Storage
Search Index
```

I would start with a modular monolith because the domain is highly relational and transactional. For example, creating a task, assigning users, writing an audit log, and checking permissions should be strongly consistent. A monolith also makes it easier to evolve the domain early.

For scaling:

- Use `project_id` and `company_id` on core tables.
- Add composite indexes such as `(project_id, status)`, `(assignee_id, status)`, `(project_id, due_date)`.
- Use pagination/cursor pagination for task lists.
- Use Sidekiq for notifications, search indexing, and audit fan-out.
- Cache read-heavy project metadata.
- Use read replicas only after query optimization and indexing.

For consistency:

- Task creation and assignment should happen in a transaction.
- Notifications should be async and idempotent.
- Audit logs should be append-only.
- Use an outbox pattern if we need reliable event delivery.

Staff-level tradeoff:

> “I would not start with separate microservices for tasks, comments, notifications, and permissions unless there is already organizational pressure or independent scaling need. The first win is clear domain boundaries inside the Rails codebase.”

---

## Q2. Design a notification system for Procore.

### Strong answer

Requirements:

- In-app notifications
- Email notifications
- Push notifications
- User preferences
- Mention notifications
- Digest notifications
- Retry/failure handling
- Avoid duplicate notifications

Architecture:

```text
Domain action
  |
Event: TaskAssigned / CommentMentioned / RFIUpdated
  |
Notification Processor
  |
Notification DB
  |
Sidekiq Workers
  |       |       |
Email   Push    In-app
```

Tables:

```text
notifications
- id
- recipient_id
- actor_id
- project_id
- event_type
- entity_type
- entity_id
- status
- read_at
- created_at

notification_preferences
- user_id
- event_type
- channel
- enabled
```

Flow:

1. User creates a comment and mentions another user.
2. The application writes the comment in a transaction.
3. The system records a domain event or outbox row.
4. A worker processes the event.
5. It checks permissions and preferences.
6. It creates in-app notification rows.
7. It sends email/push asynchronously.

Important details:

- Make workers idempotent using a unique event key.
- Use retries with exponential backoff.
- Use dead-letter queues for repeated failures.
- Avoid sending notifications before the database transaction commits.
- Use batched digests for noisy events.
- Track delivery status.

Staff-level point:

> “Notification systems look simple, but the hard parts are idempotency, user preferences, permissions, transaction boundaries, and noisy fan-out.”

---

## Q3. Design a document upload and drawing management system.

### Strong answer

In construction, documents and drawings are critical because teams must work from the latest version. I would clarify:

- File size limits
- Versioning requirements
- Access control
- Offline access
- Preview/thumbnail generation
- OCR/search requirements
- Audit requirements

Architecture:

```text
Client
  |
Rails API: request upload
  |
Generate pre-signed object storage URL
  |
Client uploads directly to S3/object storage
  |
UploadCompleted Event
  |
Workers:
- virus scan
- metadata extraction
- thumbnail generation
- OCR
- search indexing
- version linking
```

Data model:

```text
documents
- id
- project_id
- current_version_id
- title
- folder_id
- created_by_id

document_versions
- id
- document_id
- storage_key
- version_number
- checksum
- file_size
- status
- uploaded_by_id

document_permissions
- document_id
- principal_type
- principal_id
- permission
```

Key design decisions:

- Do not stream large files through Rails.
- Use pre-signed URLs.
- Store metadata in PostgreSQL and binary objects in S3/object storage.
- Use background processing for thumbnails/OCR.
- Use versioning so users can see history and avoid stale drawings.
- Use audit logs for compliance.

Failure handling:

- If upload succeeds but processing fails, mark document version as `processing_failed`.
- Allow retry.
- Keep previous version available.
- Emit metrics for processing latency and failure rate.

---

## Q4. Design a permission system for construction collaboration.

### Strong answer

Procore is multi-party collaboration: owners, GCs, subcontractors, consultants, and internal users may all collaborate on the same project. So permissions must support both roles and context.

I would use a hybrid of RBAC and ABAC:

RBAC:

```text
Role: Project Admin
Role: Project Manager
Role: Subcontractor
Role: Viewer
```

ABAC conditions:

```text
User can edit task if:
- user belongs to project
- role has edit_task permission
- task belongs to same project
- task is not locked/closed
- user’s company has access to that package
```

Tables:

```text
users
companies
projects
project_memberships
roles
permissions
role_permissions
resource_access_rules
```

Important:

- Always scope by `company_id` and `project_id`.
- Avoid permission logic scattered across controllers.
- Centralize authorization policy.
- Cache permission lookups carefully.
- Invalidate cache when membership changes.
- Audit permission changes.

Tradeoff:

> “Pure RBAC is simple but often too rigid for construction workflows. Pure ABAC is flexible but harder to reason about. A hybrid model gives structure plus contextual rules.”

---

## Q5. Design an RFI system.

### Strong answer

RFI means Request For Information. It is common in construction when a contractor needs clarification from an architect, owner, or consultant.

Core states:

```text
Draft
Open
Answered
Closed
Void
```

Entities:

```text
RFI
RFIQuestion
RFIResponse
RFIAssignee
RFIReviewer
Attachment
ActivityLog
Notification
```

Important requirements:

- Due dates
- Responsible contractor
- Ball-in-court user/company
- Attachments
- Official responses
- Audit trail
- Permissions
- Search
- Notifications

Architecture:

```text
Rails API
PostgreSQL for transactional RFI data
Sidekiq for notifications/reminders/search indexing
Object storage for attachments
Search index for full-text search
```

Consistency:

- State transitions should be validated.
- Closing an RFI should be transactional.
- Audit log should be append-only.
- Notifications can be eventual.

Good Staff-level phrase:

> “The most important part is modeling the lifecycle clearly. A poor state machine creates bugs in permissions, notifications, reporting, and customer trust.”

---

## Q6. Design submittals workflow.

### Strong answer

A submittal is a construction workflow where contractors submit materials, drawings, or product data for review/approval.

Clarify:

- How many review steps?
- Sequential or parallel approvals?
- Can reviewers request revisions?
- Are due dates required?
- Can approvals be delegated?

Data model:

```text
submittals
submittal_items
submittal_review_steps
submittal_reviewers
submittal_responses
attachments
activity_logs
```

Architecture:

- Transactional workflow state in PostgreSQL.
- Background jobs for reminders and notifications.
- Search index for finding submittals.
- Audit trail for every transition.

State machine:

```text
Draft -> Submitted -> In Review -> Revise and Resubmit -> Approved -> Closed
```

Tradeoff:

> “I would model the workflow as explicit states and transitions rather than ad-hoc boolean columns. That makes it testable, observable, and easier to evolve.”

---

## Q7. Design a punch list system.

### Strong answer

A punch list tracks work items that must be completed before project closeout.

Important requirements:

- Create item
- Assign responsible contractor
- Attach photo
- Track status
- Verify completion
- Mobile/offline support
- Location/area tagging
- Bulk update

Entities:

```text
PunchItem
Project
Location
Assignee
Attachment
Comment
StatusHistory
```

Scaling considerations:

- Punch lists may have many photos, so use direct object storage upload.
- Use pagination and filtering by location/status/assignee.
- Use mobile sync for field usage.
- Use background jobs for image processing and notifications.

Offline challenge:

- Mobile app may create items offline.
- Use client-generated IDs.
- Sync later.
- Resolve conflicts based on item version or updated_at.
- Avoid destructive overwrites.

---

## Q8. Design offline mobile sync for field teams.

### Strong answer

Construction field teams may have poor connectivity. I would design offline support around local-first writes and conflict-aware synchronization.

Client:

```text
Local DB
Pending operation queue
Sync token
```

Server:

```text
Sync API
Change log table
Conflict resolution logic
```

Flow:

1. Client stores changes locally.
2. Each change gets a client operation ID.
3. Client syncs when online.
4. Server applies operations idempotently.
5. Server returns changes since last sync token.
6. Client updates local state.

Important:

- Use server-generated version numbers.
- Use idempotency keys.
- Use soft deletes.
- Make conflicts explicit.
- Some operations may require server validation.

Tradeoff:

> “Offline sync increases complexity. I would only support offline for high-value field workflows and carefully limit which operations can be done offline.”

---

## Q9. Design audit logging.

### Strong answer

Audit logs are essential in construction because decisions, approvals, and document changes may have contractual impact.

Requirements:

- Who did what?
- When?
- On which project/resource?
- Old and new values?
- Immutable history?
- Search/reporting?

Data model:

```text
audit_events
- id
- company_id
- project_id
- actor_id
- action
- entity_type
- entity_id
- previous_values jsonb
- new_values jsonb
- request_id
- ip_address
- created_at
```

Implementation:

- Record audit events in the same transaction for critical changes.
- Use append-only design.
- Avoid updating/deleting audit rows.
- For high-volume events, stream to analytics/log storage.
- Include request ID and trace ID for debugging.

Staff answer:

> “I separate product activity logs from compliance-grade audit logs. Activity feeds can be optimized for UX, but audit logs should prioritize integrity and traceability.”

---

## Q10. Design search across Procore project data.

### Strong answer

Search requirements:

- Search tasks, RFIs, submittals, documents, users.
- Project-scoped search.
- Permission-aware results.
- Full-text and maybe semantic search.
- Low latency.

Architecture:

```text
Rails API
  |
Search Service / Search Module
  |
Search Index
  |
PostgreSQL source of truth
```

Indexing flow:

```text
Domain event -> Indexing worker -> Search index update
```

Permission handling options:

1. Filter at query time by allowed project/resource IDs.
2. Store access metadata in search index.
3. Hybrid approach.

Tradeoff:

- Query-time permission filtering is safer but can be slower.
- Index-time permissions are faster but harder to keep consistent.
- For sensitive data, I prefer correctness first.

Tie to your experience:

> “At Escape Ventures, I worked on hybrid search combining SQL filters, vector similarity, business ranking, caching, and async indexing. I would apply the same thinking here: PostgreSQL remains the source of truth, search index is eventually consistent, and permissions must be enforced.”

---

## Q11. Design real-time collaboration comments.

### Strong answer

Requirements:

- Users comment on tasks/RFIs/documents.
- Mentions.
- Attachments.
- Real-time updates.
- Notifications.
- Permissions.

Architecture:

```text
POST /comments
  |
Transaction:
- create comment
- create mention records
- create activity log
  |
After commit:
- broadcast websocket event
- enqueue notifications
- update search index
```

Technology:

- Rails ActionCable or separate websocket service.
- Redis pub/sub for fan-out.
- Sidekiq for async notifications.

Failure mode:

- If websocket broadcast fails, comment still exists.
- Client can refresh.
- Notifications retry.

---

## Q12. Design a project activity feed.

### Strong answer

Approach:

- Source feed from domain events.
- Store denormalized activity events.
- Keep them project-scoped.
- Add pagination.

Data model:

```text
activity_events
- project_id
- actor_id
- verb
- entity_type
- entity_id
- metadata jsonb
- created_at
```

Optimization:

- Composite index `(project_id, created_at desc)`.
- Cursor pagination.
- Precompute display metadata where appropriate.
- Use async fan-out for high-volume events.

---

## Q13. Design Procore integrations/API platform.

### Strong answer

Procore has many integrations and marketplace-style workflows. For an API platform:

Requirements:

- API authentication
- Rate limits
- Webhooks
- Versioning
- Idempotency
- Audit logs
- Developer docs
- Backward compatibility

Architecture:

```text
API Gateway
  |
Auth / OAuth
Rate Limiter
  |
Rails API
  |
Domain modules
  |
Webhook dispatcher
```

Important API concerns:

- Version APIs.
- Use pagination.
- Use idempotency keys for POST operations.
- Use webhook retries and signatures.
- Provide clear error codes.
- Add rate limits per client/application.

---

## Q14. Design webhook delivery.

### Strong answer

Flow:

```text
Domain event
  |
Outbox table
  |
Webhook dispatcher worker
  |
HTTP delivery
  |
Retry / backoff / dead letter
```

Webhook delivery table:

```text
webhook_deliveries
- id
- subscription_id
- event_id
- status
- attempt_count
- next_retry_at
- response_code
```

Important:

- Sign payloads.
- Retry only safe failures.
- Avoid infinite retries.
- Support replay.
- Make delivery idempotent with event IDs.

---

## Q15. Design budget/cost tracking.

### Strong answer

Construction cost data requires correctness.

Entities:

```text
Budget
CostCode
Commitment
Invoice
ChangeOrder
Forecast
ActualCost
```

Key design:

- Use ledger-style append-only financial events.
- Avoid overwriting financial history.
- Derive balances from transactions or materialized summaries.
- Use strong transactional integrity.
- Use background jobs for reports.

Tradeoff:

> “For money-like data, I prefer correctness and auditability over eventual consistency. Derived summaries can be eventually consistent, but source ledger events must be reliable.”

---

## Q16. Design reports/dashboard system.

### Strong answer

Requirements:

- Project dashboards
- Filters
- Export CSV/PDF
- Large data volume
- Near real-time vs daily reports

Architecture:

```text
OLTP PostgreSQL
  |
CDC / scheduled ETL
  |
Analytics store / materialized views
  |
Reporting API
```

Short-term:

- Optimized SQL
- Materialized views
- Caching
- Background export jobs

Long-term:

- Data warehouse
- Event streaming
- Pre-aggregated metrics

Your story:

> “At Nabda Care and IdeaRating, I optimized report generation by reducing expensive queries and using better data access patterns. For Procore, I would avoid running heavy reporting queries directly against critical transactional tables during peak usage.”

---

## Q17. How would you evolve a Rails monolith?

### Strong answer

I would avoid jumping directly to microservices. My approach:

1. Identify bounded contexts.
2. Make ownership clear.
3. Add package/module boundaries.
4. Reduce cross-domain coupling.
5. Introduce explicit APIs internally.
6. Add tests around boundaries.
7. Extract services only when necessary.

Reasons to extract:

- Independent scaling
- Independent deployment
- Clear team ownership
- Different data lifecycle
- Different reliability requirements

Reasons not to extract:

- Distributed transactions
- Operational complexity
- Harder debugging
- Higher latency
- More infrastructure cost

Best phrase:

> “A modular monolith gives many benefits of service boundaries without immediately paying the full distributed systems tax.”

---

## Q18. How do you handle data consistency in distributed systems?

### Strong answer

First, classify the operation:

- Does it need strong consistency?
- Can it be eventually consistent?
- What happens if it is duplicated?
- What happens if it is delayed?

Examples:

- Task creation: strong consistency.
- Email notification: eventual consistency.
- Search indexing: eventual consistency.
- Financial ledger: strong consistency.
- Analytics dashboard: eventual consistency.

Patterns:

- Database transactions
- Outbox pattern
- Idempotency keys
- Retry with backoff
- Dead-letter queues
- Reconciliation jobs

---

## Q19. How do you design for idempotency?

### Strong answer

Idempotency means repeating the same operation does not create duplicate side effects.

Example:

```text
POST /tasks with Idempotency-Key
```

Store:

```text
idempotency_keys
- key
- user_id
- request_hash
- response_body
- status
```

For background jobs:

- Use unique job keys.
- Store processed event IDs.
- Add unique database constraints.

Staff point:

> “I do not rely only on application checks. I prefer database-level unique constraints for final protection.”

---

## Q20. How would you design a migration from old notifications to new notification system?

### Strong answer

I would use a strangler pattern:

1. Define new notification domain model.
2. Write new system alongside old system.
3. Dual-write or emit events from old code.
4. Shadow-read and compare output.
5. Gradually route a small percentage of events.
6. Monitor correctness and latency.
7. Migrate all traffic.
8. Remove old system.

Risk controls:

- Feature flags
- Rollback plan
- Metrics
- Data reconciliation
- Backfill scripts

---

# 5. Architecture Rapid-Fire Questions

## Q21. When would you choose synchronous vs asynchronous processing?

Use synchronous when the user needs the result immediately and correctness depends on it. Use asynchronous processing for notifications, indexing, image processing, emails, analytics, and expensive operations that can be eventually consistent.

## Q22. How would you scale a slow API?

Measure first. Use tracing and metrics to identify the bottleneck. Then optimize queries, add indexes, reduce N+1 queries, cache stable data, move non-critical work async, paginate responses, and only then consider replicas or service extraction.

## Q23. How would you design rate limiting?

Use Redis token bucket or leaky bucket. Scope limits by user, company, API client, and endpoint. Return standard 429 responses. Add allowlists for internal services. Monitor rejected requests.

## Q24. How would you handle feature flags?

Use flags for gradual rollout, kill switches, risky migrations, and A/B experiments. Avoid leaving flags forever. Track ownership and cleanup dates.

## Q25. How would you design tenant isolation?

Use shared database with `company_id`/`project_id` for most SaaS cases, strict authorization scopes, composite indexes, and possibly row-level security for extra protection. Use separate databases only for very large or regulated tenants.

## Q26. How would you design auditability?

Use append-only audit events, record actor/action/entity/old/new values, attach request ID and trace ID, and protect audit data from mutation.

## Q27. How would you handle background job retries?

Use exponential backoff, idempotent jobs, limited retries, dead-letter queue, and alerts. Make side effects safe to repeat.

## Q28. How would you handle search index inconsistency?

Treat PostgreSQL as source of truth. Use async indexing, reconciliation jobs, retry failed indexing events, and fall back to DB search for critical workflows if needed.

## Q29. How would you handle large exports?

Generate exports asynchronously. Store result in object storage. Notify user when ready. Apply permissions at export generation time. Expire downloads.

## Q30. What is your approach to API versioning?

Avoid breaking changes. Add fields instead of changing existing fields. Use versioned endpoints only when necessary. Deprecate with clear timelines.

---

# 6. Specialized Technical Interview with Matt Harris

## What this interview is likely to evaluate

Based on the recruiter email, this interview is specifically about:

- Ruby/Rails backend proficiency
- Runtime engineering
- OpenTelemetry
- Performance visibility
- Production debugging
- Code quality
- High-level language reasoning
- Possibly discussion around the coding round

Expect Matt to go deeper than normal Rails questions.

---

# 7. Ruby on Rails Question Bank with Descriptive Answers

## Q1. Explain the Rails request lifecycle.

### Answer

A Rails request usually flows through:

```text
Web server
Rack middleware
Rails router
Controller action
Service/domain layer
ActiveRecord models
Database/external services
View/serializer
Response
```

Middleware may handle sessions, cookies, request IDs, logging, authentication hooks, and tracing. In a production system, I care about where instrumentation exists in this lifecycle because it tells us whether latency is coming from routing/controller logic, database calls, background dependencies, or serialization.

Staff-level addition:

> “For observability, every request should have a request ID and ideally a trace ID propagated through downstream services and background jobs.”

---

## Q2. What is the difference between `includes`, `preload`, `eager_load`, and `joins`?

### Answer

`joins` creates SQL joins but does not eager load records. It is useful for filtering or ordering based on associated tables.

```ruby
User.joins(:posts).where(posts: { published: true })
```

`preload` always uses separate queries:

```ruby
User.preload(:posts)
```

This avoids N+1 queries without creating a large join.

`eager_load` uses `LEFT OUTER JOIN` and loads everything in one query:

```ruby
User.eager_load(:posts)
```

`includes` lets Rails decide between preload and eager_load depending on whether the associated table is referenced.

```ruby
User.includes(:posts)
```

Staff-level answer:

> “I choose based on query shape. For simple display pages, preload is often safer. If I need filtering/order on joined tables, I use joins or eager_load carefully. I always check the generated SQL and query plan for high-volume endpoints.”

---

## Q3. How do you debug an N+1 query?

### Answer

Symptoms:

- Endpoint latency grows with number of records.
- Logs show repeated similar queries.
- APM trace shows many small DB spans.

Steps:

1. Reproduce locally or staging with realistic data.
2. Inspect Rails logs or APM trace.
3. Identify repeated association queries.
4. Add `includes`, `preload`, or a custom query.
5. Add tests or monitoring to avoid regression.
6. Check memory impact after eager loading.

Example:

```ruby
tasks = Task.includes(:assignee, :project).where(project_id: project.id)
```

Staff-level point:

> “Fixing N+1 is not always just adding includes. Sometimes eager loading too much data increases memory and makes things worse.”

---

## Q4. How do you optimize a slow ActiveRecord query?

### Answer

My process:

1. Look at metrics/traces to confirm the slow query.
2. Capture the SQL.
3. Run `EXPLAIN ANALYZE`.
4. Check indexes and cardinality.
5. Reduce selected columns if needed.
6. Avoid unnecessary joins.
7. Use pagination.
8. Add or adjust indexes.
9. Consider denormalization/materialized views for heavy reports.
10. Add tests/monitoring.

Example index:

```ruby
add_index :tasks, [:project_id, :status, :due_date]
```

Staff-level point:

> “I avoid adding indexes blindly because they slow writes and increase storage. I add indexes based on actual query patterns.”

---

## Q5. What is the difference between `pluck`, `select`, and `map`?

### Answer

`map` loads ActiveRecord objects and then extracts fields in Ruby.

```ruby
User.all.map(&:email)
```

`pluck` asks the database to return only the selected columns.

```ruby
User.pluck(:email)
```

`select` controls which fields are loaded into ActiveRecord objects.

```ruby
User.select(:id, :email)
```

Use `pluck` when you only need raw values. Use `select` when you still need model instances but not all columns.

---

## Q6. Explain Rails transactions.

### Answer

Transactions ensure a group of database operations either all succeed or all fail.

```ruby
ActiveRecord::Base.transaction do
  task.update!(status: "closed")
  ActivityLog.create!(task: task, action: "closed")
end
```

Important:

- Use bang methods inside transactions.
- Be careful with external API calls inside transactions.
- Do not enqueue jobs that rely on committed data before commit.
- Use `after_commit` for side effects.

Staff-level point:

> “A common bug is sending notifications or enqueuing jobs inside a transaction before the data is committed. I prefer after_commit or outbox patterns.”

---

## Q7. How do you handle race conditions in Rails?

### Answer

Options:

1. Database constraints
2. Optimistic locking
3. Pessimistic locking
4. Unique indexes
5. Idempotency keys
6. Transaction isolation where needed

Optimistic locking:

```ruby
class Task < ApplicationRecord
  # lock_version column
end
```

Pessimistic locking:

```ruby
task.with_lock do
  task.update!(status: "closed")
end
```

Database uniqueness:

```ruby
add_index :assignments, [:task_id, :user_id], unique: true
```

Staff-level point:

> “Application-level checks are not enough under concurrency. I want the database to protect critical invariants.”

---

## Q8. How do you design a Sidekiq job?

### Answer

Principles:

- Jobs should be small.
- Jobs should be idempotent.
- Pass IDs, not full objects.
- Use retries.
- Handle missing records.
- Avoid unbounded work.
- Add logging and metrics.

Example:

```ruby
class SendNotificationJob
  include Sidekiq::Worker

  def perform(notification_id)
    notification = Notification.find_by(id: notification_id)
    return unless notification
    return if notification.sent?

    NotificationMailer.send_notification(notification).deliver_now
    notification.update!(sent_at: Time.current)
  end
end
```

Better idempotency:

- Use unique delivery record.
- Store provider message ID.
- Use unique constraints.

---

## Q9. What happens if a Sidekiq job runs twice?

### Answer

It can happen because distributed job systems usually provide at-least-once execution. The job must be idempotent.

Bad:

```ruby
user.increment!(:credits)
```

Better:

```ruby
CreditTransaction.create!(
  user_id: user.id,
  external_event_id: event_id,
  amount: 10
)
```

with unique index on `external_event_id`.

Staff-level phrase:

> “I assume any job can run zero, one, or multiple times, so I design side effects accordingly.”

---

## Q10. What is the difference between service objects, models, and interactors?

### Answer

Models should own data invariants and domain behavior close to the entity. Service objects are useful for workflows that coordinate multiple models or external systems.

Example:

```ruby
TaskCloser.call(task:, actor:)
```

This may:

- validate permission
- update task status
- write activity log
- enqueue notification

Staff-level point:

> “I avoid service-object dumping grounds. Services should represent clear use cases, not become procedural replacements for domain modeling.”

---

## Q11. How do you structure a large Rails app?

### Answer

For a large Rails app, I would organize around domain boundaries:

```text
app/domains/project_management
app/domains/permissions
app/domains/notifications
app/domains/documents
```

Or use packages/modules with explicit dependencies.

Principles:

- Clear ownership
- Explicit interfaces
- Avoid circular dependencies
- Keep controllers thin
- Keep business logic out of views/jobs
- Use tests around domain boundaries

Staff-level point:

> “The goal is not folder structure. The goal is reducing cognitive load and preventing accidental coupling.”

---

## Q12. What is a Rails concern and when can it be harmful?

### Answer

Concerns are modules used to share behavior between models/controllers.

Good use:

- Small, cohesive behavior reused in multiple places.

Bad use:

- Hiding large business logic.
- Creating implicit dependencies.
- Making models harder to reason about.

Staff-level answer:

> “I use concerns carefully. If a concern becomes a business workflow, I usually move it to a domain object or service.”

---

## Q13. What is the difference between `dependent: :destroy` and `dependent: :delete_all`?

### Answer

`destroy` instantiates each record and runs callbacks/validations.

`delete_all` deletes directly in SQL and skips callbacks.

Use `destroy` when callbacks matter. Use `delete_all` for performance when callbacks are not required.

Risk:

> “Using delete_all can bypass important cleanup logic, audit logs, or external side effects.”

---

## Q14. How do you handle large database migrations?

### Answer

Use safe, incremental migrations:

1. Add nullable column.
2. Deploy code that writes both old and new fields.
3. Backfill in batches.
4. Add indexes concurrently.
5. Validate data.
6. Enforce NOT NULL/check constraints later.
7. Remove old code/columns later.

PostgreSQL index example:

```ruby
add_index :tasks, :project_id, algorithm: :concurrently
```

Staff-level point:

> “For large production tables, schema changes must be treated as deployable projects, not simple code changes.”

---

## Q15. How do you handle validations vs database constraints?

### Answer

Rails validations give user-friendly errors. Database constraints protect data integrity under concurrency and from non-Rails writes.

Use both:

```ruby
validates :email, presence: true, uniqueness: true
```

and:

```ruby
add_index :users, :email, unique: true
```

Staff-level point:

> “Validation is UX. Constraint is correctness.”

---

## Q16. How do you approach caching in Rails?

### Answer

Levels:

- HTTP caching
- Fragment caching
- Low-level Rails cache
- Redis caching
- Query/result caching
- CDN caching for assets

Principles:

- Cache read-heavy, stable data.
- Use explicit keys and versions.
- Plan invalidation before adding cache.
- Avoid caching permission-sensitive data incorrectly.
- Measure hit rate.

Example:

```ruby
Rails.cache.fetch(["project-summary", project.id, project.updated_at], expires_in: 10.minutes) do
  ProjectSummaryBuilder.call(project)
end
```

Staff-level point:

> “Caching is easy to add and hard to invalidate. I only cache after I understand the data freshness requirement.”

---

## Q17. How do you secure a Rails API?

### Answer

Key areas:

- Authentication
- Authorization
- Strong parameters
- CSRF protection where needed
- SQL injection prevention
- XSS protection
- Rate limiting
- Secure secrets management
- Audit logging
- Dependency scanning
- Multi-tenant scoping

Staff-level point:

> “In multi-tenant SaaS, authorization bugs are often more dangerous than authentication bugs. Every query must be tenant-aware.”

---

## Q18. How do you handle memory issues in Ruby/Rails?

### Answer

Investigate:

- Memory growth over time
- Large object allocations
- Loading too many records
- Inefficient serialization
- Background jobs processing too much data
- Caches growing without bounds

Tools/approaches:

- APM memory metrics
- Object allocation tracing
- Batch processing
- `find_each`
- Avoid loading full AR objects when not needed
- Use pagination

Example:

```ruby
Task.where(project_id: project.id).find_each(batch_size: 1000) do |task|
  ProcessTask.call(task)
end
```

---

## Q19. How does garbage collection affect Ruby performance?

### Answer

Ruby GC pauses can contribute to latency. High allocation rates increase GC pressure.

Ways to reduce:

- Avoid unnecessary object creation.
- Use `pluck` instead of loading models.
- Reduce serialization overhead.
- Batch work.
- Monitor GC time and heap growth.

Staff-level answer:

> “I do not optimize Ruby allocations blindly, but if p99 latency correlates with GC time, I investigate allocation hotspots.”

---

## Q20. What is Rack middleware?

### Answer

Rack middleware sits between the web server and Rails application. It can inspect/modify requests and responses.

Examples:

- Logging
- Authentication
- Sessions
- Request IDs
- Error handling
- Tracing

In observability, middleware is a good place to start/finish request spans.

---

# 8. OpenTelemetry and Runtime Question Bank

## Q1. What is OpenTelemetry?

### Answer

OpenTelemetry is a vendor-neutral standard and set of tools for collecting telemetry data from applications. It focuses on signals such as:

- Traces
- Metrics
- Logs

The goal is to instrument applications consistently and export data to observability backends using standard protocols like OTLP.

Staff-level answer:

> “OpenTelemetry is valuable because it decouples instrumentation from the vendor. The application emits standard telemetry, and the organization can route it to different backends.”

---

## Q2. What is the difference between logs, metrics, and traces?

### Answer

Metrics answer:

> “Is something wrong?”

Examples:

- error rate
- p95 latency
- request count
- queue depth

Logs answer:

> “What happened?”

Examples:

- error details
- request context
- business events

Traces answer:

> “Where did time go across the request path?”

Examples:

- controller span
- DB span
- external API span
- Sidekiq job span

Staff-level phrase:

> “Metrics detect the problem, traces localize the problem, logs explain the details.”

---

## Q3. What is a trace?

### Answer

A trace represents the full journey of a request or operation across services and components.

Example:

```text
Trace: POST /tasks
  Span: Rails controller - 40ms
  Span: Permission check - 10ms
  Span: ActiveRecord query - 120ms
  Span: Redis cache - 3ms
  Span: Notification enqueue - 5ms
```

The trace helps identify which part of the request is slow or failing.

---

## Q4. What is a span?

### Answer

A span is a single timed operation inside a trace. It has:

- name
- start time
- end time
- duration
- attributes
- status
- parent span
- trace ID

Example:

```ruby
tracer.in_span("recommendation.rank") do |span|
  span.set_attribute("project.id", project.id)
  RankingService.call(project)
end
```

---

## Q5. How would you instrument a Rails app with OpenTelemetry?

### Answer

Start with auto-instrumentation:

- Rails
- Rack
- ActiveRecord
- Redis
- HTTP clients
- Sidekiq

Then add manual spans for business-critical operations.

Example configuration conceptually:

```ruby
OpenTelemetry::SDK.configure do |c|
  c.use "OpenTelemetry::Instrumentation::Rails"
  c.use "OpenTelemetry::Instrumentation::ActiveRecord"
  c.use "OpenTelemetry::Instrumentation::Sidekiq"
  c.use "OpenTelemetry::Instrumentation::Redis"
  c.use "OpenTelemetry::Instrumentation::Net::HTTP"
end
```

Then export through OTLP to a collector/backend.

Staff-level point:

> “Auto-instrumentation gives coverage, but manual instrumentation gives business meaning. I would add custom spans around expensive domain workflows.”

---

## Q6. What custom spans would you add in Procore?

### Answer

For a Procore task workflow:

```text
task.create
permission.check
task.assign
activity_log.write
notification.enqueue
search.index.enqueue
```

For document upload:

```text
document.presign_url
document.version.create
document.scan
document.thumbnail.generate
document.ocr
document.index
```

For reports:

```text
report.query
report.aggregate
report.export
report.upload
```

The goal is to expose the parts that matter to users and engineers.

---

## Q7. What attributes should you add to spans?

### Answer

Useful attributes:

- request ID
- company ID
- project ID
- endpoint/action
- job class
- queue name
- cache hit/miss
- database operation
- external service name
- feature flag state

Avoid:

- PII
- secrets
- full SQL with sensitive values
- high-cardinality fields like raw user email or unique document names

Staff-level point:

> “Good attributes make traces searchable. Bad attributes create cost, cardinality, and privacy problems.”

---

## Q8. What is high cardinality and why does it matter?

### Answer

High cardinality means a field has many unique values, such as user email, request ID, document ID, or raw URL with IDs.

Problem:

- Expensive storage
- Slow queries
- Noisy dashboards
- Backend limits

Better:

- Use route template `/projects/:id/tasks`
- Use project/company IDs carefully depending on backend policy
- Avoid raw names/emails

---

## Q9. How do you propagate trace context to Sidekiq jobs?

### Answer

When a web request enqueues a job, trace context should be injected into the job payload. When Sidekiq performs the job, it extracts the context and creates child spans.

Conceptually:

```text
HTTP request trace
  |
enqueue job span
  |
Sidekiq perform span
```

This allows us to connect the user request to async work.

Staff-level point:

> “Without context propagation, async workflows become disconnected and debugging is much harder.”

---

## Q10. What is sampling?

### Answer

Sampling controls how many traces are collected.

Why:

- Reduce cost
- Reduce storage
- Avoid overwhelming observability backend

Types:

- Head-based sampling: decide at start of trace.
- Tail-based sampling: decide after seeing full trace, useful for keeping errors/slow traces.

Staff-level answer:

> “For production, I want to keep all errors and slow traces while sampling normal successful traffic. Tail sampling is often better for that.”

---

## Q11. What are RED and USE metrics?

### Answer

RED is good for request-driven services:

- Rate
- Errors
- Duration

USE is good for resources:

- Utilization
- Saturation
- Errors

For Rails:

RED:

- requests/sec
- error rate
- p95/p99 latency

USE:

- CPU
- memory
- DB connection pool usage
- Sidekiq queue latency
- Redis saturation

---

## Q12. What are the golden signals?

### Answer

Common golden signals:

- Latency
- Traffic
- Errors
- Saturation

For Procore Rails backend, I would monitor:

- endpoint latency
- error rate
- request throughput
- DB query latency
- DB connection pool saturation
- Sidekiq queue depth and latency
- Redis latency
- external API latency
- memory and GC time

---

## Q13. How do you debug a slow endpoint using OpenTelemetry?

### Answer

Process:

1. Start with alert: p95 latency increased.
2. Open traces for affected endpoint.
3. Compare slow traces vs normal traces.
4. Identify dominant span.
5. If DB span: inspect SQL and query plan.
6. If external API span: check dependency latency and timeouts.
7. If app span: inspect code and allocations.
8. Fix bottleneck.
9. Add regression test/monitoring.

Example answer:

> “If `/projects/:id/tasks` p95 jumps from 300ms to 2s, I would filter traces by route, find whether time is in ActiveRecord, serialization, permission checks, or external calls, and then optimize the specific span rather than guessing.”

---

## Q14. How do you debug high Sidekiq latency?

### Answer

Check:

- queue depth
- queue latency
- worker concurrency
- job duration
- retries
- dead jobs
- Redis latency
- DB connection pool
- noisy job classes
- deployment changes

Actions:

- Split queues by priority.
- Add workers if resource allows.
- Optimize slow job.
- Reduce job payload.
- Batch carefully.
- Add idempotency.
- Avoid long DB transactions.

---

## Q15. How do you debug high error rate after deployment?

### Answer

1. Check deployment timeline.
2. Compare errors before/after.
3. Look at traces/logs grouped by endpoint and exception class.
4. Identify whether error is code, DB migration, config, dependency, or data issue.
5. Roll back or feature flag off if needed.
6. Add regression test.
7. Write postmortem if customer impact.

Staff-level phrase:

> “The first priority is reducing customer impact, not proving the root cause.”

---

## Q16. How do you design dashboards for engineering teams?

### Answer

Dashboards should be actionable, not decorative.

For a Rails service:

- request rate
- error rate
- p50/p95/p99 latency
- top slow endpoints
- DB query latency
- DB pool usage
- Sidekiq queue latency
- job failures
- Redis latency
- external API latency
- deploy markers

For business workflows:

- task creation success rate
- document processing latency
- notification delivery latency
- search indexing lag

---

## Q17. How do you define SLOs?

### Answer

An SLO is a reliability target based on user expectations.

Example:

```text
99.9% of task creation requests succeed over 30 days.
95% of task list requests complete under 500ms.
99% of notification jobs are processed within 2 minutes.
```

Staff-level point:

> “SLOs should be tied to user experience, not only infrastructure metrics.”

---

## Q18. How do you reduce observability noise?

### Answer

- Alert on symptoms, not every cause.
- Use SLO-based alerts.
- Avoid alerting on transient low-impact issues.
- Add severity levels.
- Group alerts by service and impact.
- Add runbooks.
- Review noisy alerts regularly.

---

## Q19. How would you add OpenTelemetry to a legacy Rails app?

### Answer

Plan:

1. Start with low-risk auto-instrumentation.
2. Export to collector in non-production.
3. Validate overhead.
4. Roll out to small production percentage.
5. Add custom spans for critical workflows.
6. Define naming conventions and attributes.
7. Add dashboards and alerts.
8. Train teams on usage.

Risks:

- Performance overhead
- Too much telemetry
- High cardinality
- Sensitive data
- Duplicate instrumentation

---

## Q20. What mistakes should teams avoid with OpenTelemetry?

### Answer

Common mistakes:

- Instrumenting everything without a goal.
- Adding high-cardinality attributes.
- Logging PII.
- No sampling strategy.
- No naming conventions.
- No dashboards/runbooks.
- Not connecting traces to business workflows.
- Not propagating context to background jobs.

Staff-level phrase:

> “Instrumentation is a product for engineers. It needs design, standards, and maintenance.”

---

# 9. Ruby Language Deep-Dive Questions

## Q1. Symbol vs String?

Symbols are immutable identifiers. Strings are mutable objects used for text. Symbols are often used as keys or method names.

Important:

- Modern Ruby garbage collects symbols, but creating unbounded dynamic symbols can still be risky.
- Strings are better for user input.

## Q2. Proc vs Lambda?

Both are callable objects.

Differences:

- Lambda checks argument count strictly.
- Proc is more lenient.
- `return` behaves differently.

Example:

```ruby
l = ->(x) { x + 1 }
p = Proc.new { |x| x + 1 }
```

## Q3. include vs extend vs prepend?

`include` adds module methods as instance methods.

`extend` adds module methods as class methods.

`prepend` puts module before the class in method lookup chain, useful for wrapping/overriding behavior.

## Q4. What is Ruby method lookup path?

Ruby looks in:

1. Singleton class
2. Prepended modules
3. Class
4. Included modules
5. Superclass chain
6. Object/Kernel/BasicObject

## Q5. What are blocks?

Blocks are chunks of code passed to methods. They are common in Ruby iterators and DSLs.

Example:

```ruby
[1, 2, 3].each do |n|
  puts n
end
```

## Q6. What is `yield`?

`yield` calls the block passed to a method.

```ruby
def around
  puts "before"
  yield
  puts "after"
end
```

## Q7. What is metaprogramming?

Metaprogramming is writing code that defines or modifies code at runtime.

Examples:

- `define_method`
- `method_missing`
- dynamic modules

Staff-level warning:

> “Metaprogramming can reduce repetition but can also reduce clarity. I use it when the abstraction is stable and well-tested.”

## Q8. What is `method_missing` and when is it dangerous?

It catches calls to undefined methods. It can be used for dynamic APIs but is dangerous because it hides errors and hurts discoverability. If used, implement `respond_to_missing?`.

## Q9. What is immutability and why does it matter?

Immutable objects reduce accidental mutation and are easier to reason about, especially in concurrent or shared code.

## Q10. How does Ruby handle concurrency?

MRI Ruby has a Global VM Lock, so CPU-bound Ruby threads do not run truly in parallel. Threads are still useful for IO-bound work. For CPU-bound work, use processes, native extensions, or external services.

---

# 10. PostgreSQL / Database Question Bank

## Q1. How do indexes work?

Indexes help the database find rows faster without scanning the whole table. They speed reads but add overhead to writes and storage.

## Q2. What indexes would you add for tasks?

Depends on queries. Examples:

```ruby
add_index :tasks, [:project_id, :status]
add_index :tasks, [:assignee_id, :status]
add_index :tasks, [:project_id, :due_date]
```

## Q3. What is a composite index?

An index on multiple columns. Order matters.

Index:

```text
(project_id, status, due_date)
```

Useful for queries filtering by project and status and sorting/filtering by due date.

## Q4. What is a partial index?

An index on a subset of rows.

Example:

```sql
CREATE INDEX index_open_tasks
ON tasks(project_id, due_date)
WHERE status = 'open';
```

Good when most queries target active/open rows.

## Q5. What is `EXPLAIN ANALYZE`?

It shows the query plan and actual execution time. It helps identify sequential scans, bad joins, missing indexes, and expensive sorts.

## Q6. What causes slow queries?

- Missing indexes
- Bad joins
- Large result sets
- N+1 queries
- Sorting without index
- Poor statistics
- Lock contention
- Inefficient pagination

## Q7. Offset pagination vs cursor pagination?

Offset pagination:

```sql
LIMIT 50 OFFSET 50000
```

Gets slower for deep pages.

Cursor pagination uses a stable cursor like ID or timestamp:

```sql
WHERE created_at < last_seen_created_at
ORDER BY created_at DESC
LIMIT 50
```

Better for large datasets.

## Q8. How do you handle database locking?

Use:

- shorter transactions
- proper indexes
- optimistic locking
- pessimistic locking only when needed
- avoid long-running migrations
- monitor lock waits

## Q9. How do you handle read replicas?

Use for read-heavy workloads. Be aware of replication lag. Do not use replicas for read-after-write critical paths unless lag is acceptable.

## Q10. When would you partition tables?

When tables are very large and queries naturally filter by partition key, such as date or tenant/project. Partitioning adds complexity, so use after simpler optimizations.

---

# 11. Your Passed Coding Round: How to Discuss It

## Problem summary

You were given a construction-related worker scheduling problem:

- Workers have emails, trades, and costs.
- `suitable_workers(trade)` returns emails for workers who can do the trade sorted alphabetically.
- `schedule_one_day(trades)` schedules workers for a day.
- A worker cannot work twice in the same day.
- Choose the cheapest available worker.
- `schedule_all_tasks(trades)` schedules across minimum number of days possible.

## Your approach

You preprocessed workers by trade:

```ruby
@workers_by_trades = Hash.new { |h, k| h[k] = [] }

@workers.each do |worker|
  worker.trades.each do |trade|
    @workers_by_trades[trade] << worker
  end
end

@workers_by_trades.values.each { |list| list.sort_by!(&:cost) }
```

This improves repeated lookup.

## How to explain it

> “The naive approach scans all workers every time we need a worker for a trade. Since the same lookup happens many times, I built an index from trade to workers during initialization. Then I sorted each trade’s workers by cost, so selecting the cheapest available worker is a simple scan over the relevant candidates.”

## Tradeoff

- More memory for the hash.
- Faster lookup.
- Cleaner scheduling logic.

## Complexity

Let:

- `W` = workers
- `T` = average trades per worker
- `K` = workers matching a specific trade
- `N` = requested trades

Preprocessing:

```text
O(W * T + sorting per trade)
```

Scheduling one day:

```text
O(N * K)
```

Worst case if every worker can do every trade:

```text
O(N * W)
```

But in practice, indexing by trade reduces unnecessary scanning.

## What you could improve

- Remove unused `get_worker`.
- Extract worker selection to one method.
- Guard against impossible trades to avoid infinite loops.
- Use worker object identity instead of email if emails are not guaranteed unique.
- Add deterministic tie-breaking by cost then email.
- Add tests for unavailable trades.

Improved selection:

```ruby
def cheapest_available_worker_for(trade, used_workers)
  @workers_by_trades[trade].find { |worker| !used_workers.include?(worker.email) }
end
```

Guard in `schedule_all_tasks`:

```ruby
raise "Impossible schedule" if schedule_day.empty?
```

## If asked whether greedy gives minimum days

For this specific problem, if each task takes one worker per day and workers can only be used once per day, minimum days is constrained by repeated trades and worker availability. The greedy approach likely passed the provided tests, but in a more general scheduling/assignment problem, greedy may not always be globally optimal if choosing a cheap worker for one trade prevents a better assignment later.

Staff-level answer:

> “For the interview constraints and tests, greedy was appropriate. In production, I would clarify whether global optimality is required. If yes, I would model it as bipartite matching per day or a min-cost max-flow problem depending on requirements.”

---

# 12. Questions They May Ask About Your CV

## Q1. Tell me about yourself.

### Answer

“I’m a backend-focused Staff/Senior Software Engineer with more than 10 years of experience building scalable web applications, mostly with Ruby on Rails, PostgreSQL, and cloud-based systems. Recently, at Escape Ventures, I led the architecture of an AI-powered recommendation and search platform using OpenAI embeddings, PostgreSQL pgvector, caching, and async Sidekiq pipelines. Before that, I worked remotely with Andela clients like Kinship and Litmus, where I focused on Rails performance, PostgreSQL optimization, and production reliability. What interests me about Procore is that the role combines Rails at scale, platform thinking, architecture, and customer-impacting construction workflows.”

## Q2. What is your strongest technical project?

### Answer

“At Escape Ventures, I designed a production recommendation platform that combined semantic search, SQL filtering, business ranking, caching, and background processing. The challenge was not only generating embeddings, but making the system fast, reliable, and cost-efficient. We cached embeddings and search results, used PostgreSQL/pgvector for vector search, moved expensive work to Sidekiq, and optimized query performance. This reduced expensive API usage significantly and improved response latency.”

## Q3. Tell me about a production performance problem.

### Answer

“In a Rails/PostgreSQL system, I investigated slow endpoints by looking at logs, query patterns, and database execution. The issue was a combination of inefficient queries and loading more data than needed. I optimized the queries, added the right indexes, used eager loading to remove N+1 behavior, and moved expensive work outside the request path. The result was a significant reduction in query time and better stability under load.”

## Q4. How do you mentor engineers?

### Answer

“I try to mentor through context, not only answers. In code reviews, I explain the reasoning behind suggestions: performance, maintainability, testability, or domain clarity. I also pair with engineers on complex tasks and help break large problems into smaller steps. My goal is to make the team stronger, not make people dependent on me.”

## Q5. Why Procore?

### Answer

“Procore is interesting to me because it solves real operational problems in construction, where software quality directly affects collaboration, project cost, and delivery. The role also matches my background: Rails/backend engineering, scalable systems, performance, architecture, and AI-powered workflows. I’m especially interested in working on platform features that improve engineering excellence and enable teams to build faster and safer.”

---

# 13. Values Interview Preparation: Openness, Optimism, Ownership

Even though today’s interviews are architecture and specialized technical, values can appear in any interview.

## Ownership

### Question

> Tell me about a time you owned a difficult technical problem.

### Answer

Use Escape Ventures AI recommendation engine.

Structure:

- Situation: Needed scalable AI recommendations/search.
- Task: Design reliable, low-latency, cost-efficient architecture.
- Action: Added pgvector, caching, async jobs, ranking, prompt cost controls.
- Result: Reduced API calls/costs and improved latency.

## Openness

### Question

> Tell me about a time you disagreed with a teammate.

### Answer

Use architecture tradeoff.

Key message:

- Listened first.
- Made tradeoffs explicit.
- Used data/prototype.
- Chose team/company outcome over ego.

## Optimism

### Question

> Tell me about a difficult project with uncertainty.

### Answer

Use production migration or debugging.

Key message:

- Stayed calm.
- Broke problem down.
- Created a plan.
- Kept team aligned.
- Delivered progress.

---

# 14. High-Probability Architecture Scenarios

Prepare to design these quickly:

1. Task management system
2. Notification system
3. Document/drawing management system
4. RFI workflow
5. Submittal workflow
6. Punch list workflow
7. Permission system
8. Audit log system
9. Search system
10. Offline mobile sync
11. Reporting/dashboard system
12. API integration/webhook system
13. Project activity feed
14. Budget/cost tracking system
15. Migration from monolith module to service

---

# 15. High-Probability Specialized Technical Questions

Prepare these deeply:

1. Explain Rails request lifecycle.
2. How do you debug a slow Rails endpoint?
3. Explain OpenTelemetry traces/spans/metrics/logs.
4. How would you instrument Rails with OpenTelemetry?
5. How would you instrument Sidekiq?
6. What custom spans would you add?
7. How do you avoid high-cardinality attributes?
8. How do you handle sampling?
9. Explain ActiveRecord `includes`, `preload`, `eager_load`, `joins`.
10. How do you fix N+1 queries?
11. How do you optimize PostgreSQL queries?
12. How do you handle transactions and `after_commit`?
13. How do you prevent duplicate Sidekiq job effects?
14. How do you handle race conditions?
15. How do you safely run large migrations?
16. How do you design caching and invalidation?
17. How do you structure large Rails apps?
18. How do you handle multi-tenancy?
19. How do you design service boundaries?
20. How do you monitor p95/p99 latency?

---

# 16. Questions to Ask Dennis in Architecture Interview

Ask one or two only.

1. “At Procore scale, what are the biggest architecture challenges for the Project Management team today: domain complexity, scaling existing workflows, platform extensibility, or developer velocity?”

2. “How does Procore think about evolving a large Rails codebase: modular monolith boundaries, service extraction, or platform-level shared capabilities?”

3. “For Staff Engineers at Procore, what does success look like in the first 6 months?”

4. “How do architecture decisions get reviewed across teams?”

---

# 17. Questions to Ask Matt in Specialized Technical Interview

1. “How mature is OpenTelemetry adoption in the Runtime team today? Is the bigger challenge instrumentation coverage, signal quality, or helping teams act on telemetry?”

2. “What are the most common performance issues the Runtime team sees in Rails services?”

3. “How do teams at Procore balance framework-level Rails conventions with platform-level engineering standards?”

4. “What would make someone successful in this Runtime/Rails backend context?”

---

# 18. Final Tips for Tonight

## For Architecture

Do:

- Ask clarifying questions.
- Start simple.
- Model the domain clearly.
- Mention tradeoffs.
- Mention observability and migration.
- Think in terms of Procore’s construction workflows.

Do not:

- Jump immediately to microservices.
- Over-focus on AI unless the question asks for it.
- Ignore permissions/audit logs.
- Ignore offline/mobile field constraints.

## For Specialized Rails

Do:

- Be specific.
- Mention actual Rails/ActiveRecord/Sidekiq details.
- Tie performance to traces, metrics, and logs.
- Mention OpenTelemetry naturally.
- Explain tradeoffs.

Do not:

- Give only definitions.
- Forget production concerns.
- Ignore idempotency.
- Ignore DB constraints.
- Overclaim OpenTelemetry expertise if you have not implemented every detail. Say what you would do clearly.

## Your best repeated line

> “I usually start with the simplest architecture that protects correctness and gives us observability. Then I evolve it based on measured bottlenecks, team ownership, and product needs.”

---

# 19. 30-Minute Emergency Review Plan

If you only have 30 minutes:

1. Review architecture answer structure.
2. Review task management, notifications, permissions, documents.
3. Review OpenTelemetry traces/spans/metrics/logs.
4. Review Rails performance: N+1, includes/preload/eager_load/joins.
5. Review Sidekiq idempotency and transactions.
6. Prepare your Escape Ventures story.
7. Prepare your WorkScheduler explanation.

---

# 20. Final Confidence Notes

You are well-positioned because:

- You already passed their practical coding round.
- Your CV matches Rails/backend/platform/performance.
- Your AI/vector search work aligns with Procore’s AI direction.
- Your PostgreSQL and Sidekiq experience maps well to Rails runtime work.
- Your leadership experience supports Staff-level expectations.

The main thing is to answer as a Staff Engineer:

- clarify
- reason
- trade off
- design for operations
- communicate clearly
- show ownership
