# Architecture Examples — Full System Design Walkthroughs

> Practice these end-to-end designs. Each follows the architecture framework from `08_system_design_patterns.md`.

---

# 1. RFI Management System

## Prompt
> "Design a system for managing Requests for Information (RFIs) in construction projects."

## Clarifying Questions
1. Who can create RFIs? GC, subcontractor, PM, architect?
2. Can multiple companies collaborate on the same RFI?
3. Is there only one official response or multiple?
4. Can an RFI be reopened after closure?
5. Do we need due dates and escalation rules?
6. Do external systems need to create/sync RFIs via API?

## Assumptions
- Multi-tenant: each company has many projects
- Thousands of RFIs per project over lifetime
- RFIs are collaborative — involve users from multiple companies
- Official status changes must be strongly consistent
- Notifications/search can be async
- Audit logs required (RFIs affect cost, schedule, liability)

## High-Level Architecture
```text
Web / Mobile Client → API Gateway / LB → Rails Modular Monolith
  ├── RFI Module
  ├── Document Module
  ├── Notification Module
  ├── Permission Module
  └── Audit Module
  → PostgreSQL | Redis | Sidekiq | S3 | Search Index | OTel
```

## Database Design
```sql
rfis(id, project_id, company_id, number, title, question, status, 
     created_by_id, assigned_to_id, due_date, closed_at, created_at, updated_at)

rfi_responses(id, rfi_id, responder_id, body, official, created_at)
rfi_comments(id, rfi_id, user_id, body, created_at)
attachments(id, project_id, resource_type, resource_id, file_name, s3_key, 
            content_type, file_size, uploaded_by_id, created_at)
activity_logs(id, company_id, project_id, actor_id, action, resource_type, 
              resource_id, metadata_json, created_at)
outbox_events(id, event_type, aggregate_type, aggregate_id, payload_json, status, created_at)
```

### Key Indexes
```sql
rfis(project_id, status)
rfis(project_id, assigned_to_id)
rfis(project_id, due_date)
attachments(resource_type, resource_id)
```

## API Design
```http
POST /projects/:project_id/rfis
GET  /projects/:project_id/rfis?status=open&assignee_id=123
GET  /rfis/:id
PATCH /rfis/:id
POST /rfis/:id/submit
POST /rfis/:id/responses
POST /rfis/:id/comments
POST /rfis/:id/close
GET  /rfis/:id/activity
```

## Async Processing
- Notifications, attachment virus scanning, search indexing, overdue reminders via Sidekiq
- Outbox pattern for reliable event delivery

## Summary Answer
> "Multi-tenant Rails modular monolith, PostgreSQL for transactional data, S3 for attachments, Redis for cache, Sidekiq for async. Core state transitions strongly consistent, notifications/search/reminders eventually consistent via outbox pattern. Special attention to project-level permissions, audit logs, and UX features like overdue dashboards."

---

# 2. Document & Drawing Management System

## Prompt
> "Design a system where construction teams can upload, version, review, publish, search, and share documents/drawings."

## Key Design Decisions

### Direct-to-S3 Upload (Don't stream through Rails)
```text
Client requests upload URL → Rails validates permission, creates pending version
→ Rails returns pre-signed S3 URL → Client uploads directly to S3
→ Client calls complete-upload endpoint → Background jobs process file
```

**Why:** Avoids Rails memory pressure, supports large files, scales upload throughput.

### Version Management
```sql
documents(id, company_id, project_id, folder_id, name, document_type, 
          current_version_id, status, created_by_id, created_at)
          
document_versions(id, document_id, version_number, s3_key, checksum, 
                   file_size, content_type, status, uploaded_by_id, published_at)
```

### Processing Pipeline
```text
pending_upload → uploaded → processing → ready (or failed)

Workers:
  VirusScanJob → PreviewGenerationJob → ThumbnailJob → OcrExtractionJob → SearchIndexJob
```

### UX Considerations
- Show current published version clearly
- **Warn users viewing outdated revisions** — critical for construction
- Preview before download
- Bulk upload with progress
- Mobile quick access to recent drawings

## Summary Answer
> "Rails manages metadata and permissions, S3 handles files via pre-signed URLs, background workers for virus scan/OCR/previews, search index for discovery. Current published version strongly consistent in PostgreSQL; OCR, thumbnails, search async. Focus on permissions, version correctness, and UX warnings to prevent teams using outdated drawings."

---

# 3. Task / Punch List System

## Prompt
> "Design a task management or punch list system for construction projects."

## Status Machine
```text
open → in_progress → blocked → completed → verified → closed
                                    ↓
                                  reopened → in_progress
```

## Database Design
```sql
tasks(id, company_id, project_id, title, description, status, priority, 
      location_id, created_by_id, due_date, completed_at, verified_at, 
      lock_version, created_at, updated_at)

task_assignments(id, task_id, user_id, company_id, assigned_by_id, created_at)
task_comments(id, task_id, user_id, body, created_at)
task_dependencies(id, task_id, depends_on_task_id, created_by_id, created_at)
```

### Staff-Level Concerns
- **`company_id` on tasks** even though reachable via project — improves tenant-scoped queries
- **`lock_version`** for optimistic locking — prevents lost updates when two users edit same task
- **Dependency cycle prevention** — check before inserting; recursive SQL or graph traversal
- **Why join table for assignees?** — requirements evolve: multiple assignees, watchers, reviewers

## Task Completion Validation
```ruby
def complete_task(task, actor)
  validate_permission!(actor, task)
  validate_dependencies_complete!(task)
  validate_status_transition!(task, "completed")
  
  ActiveRecord::Base.transaction do
    task.update!(status: "completed", completed_at: Time.current, lock_version: task.lock_version)
    ActivityLog.create!(task: task, actor: actor, action: "completed")
  end
end
```

---

# 4. Notification System

## Architecture
```text
Domain action → Event (TaskAssigned / CommentMentioned / RFIUpdated)
  → Notification Processor → Notification DB
  → Sidekiq Workers → Email / Push / In-app
```

## Database
```sql
notifications(id, recipient_id, actor_id, project_id, event_type, 
              entity_type, entity_id, status, read_at, created_at)

notification_preferences(user_id, event_type, channel, enabled)
```

## Flow
1. User creates comment with mention
2. Application writes comment in transaction
3. Records outbox event
4. Worker processes event
5. Checks permissions and user preferences
6. Creates in-app notification rows
7. Sends email/push async

## Critical Design Points
- **Idempotent workers** using unique event key
- **Retries** with exponential backoff
- **Dead-letter queue** for repeated failures
- **Never send notifications before transaction commits**
- **Batched digests** for noisy events

> "Notification systems look simple, but the hard parts are idempotency, user preferences, permissions, transaction boundaries, and noisy fan-out."

---

# 5. Real-Time Activity Feed

## Design
```text
Domain Event → Outbox → Message Broker → Feed Processor → Read Model
                                                      → WebSocket Hub → Clients
```

### Write Path (Fast)
Core transaction writes business change + outbox row. Worker publishes to message broker.

### Read Model
Redis Sorted Set per project: `project:{id}:feed`, scored by timestamp.
- `ZREVRANGE` for paginated feed — O(log N + M)
- Keep last 1000 events in Redis; older from PostgreSQL

### Fan-Out Strategy
- **< 500 subscribers** → fan-out on write (write to each subscriber's feed cache)
- **> 500 subscribers** → fan-out on read (compute feed at read time)

### Real-Time Delivery
- ActionCable for same-datacenter
- Pusher/Ably for cross-region WebSocket management

### Consistency
- Eventual consistency acceptable for activity feeds
- Client optimistically shows user's own action immediately
- Events idempotent with UUID, clients deduplicate on `event_id`

---

# 6. Additional Design Topics (Rapid-Fire Answers)

## Permission System
**Model:** `user_project_roles(user_id, project_id, role_id)` — roles are project-scoped, not global. Cache in Redis with short TTL, invalidate on role change.

## Offline Mobile Sync
**Client:** local DB + pending operation queue + sync token. **Server:** sync API + change log table + conflict resolution. Use client-generated IDs, idempotent server-side application, soft deletes.

## Audit Logging
Append-only `audit_events` table. Record actor, action, entity, old/new values, request_id, trace_id. Separate product activity logs from compliance-grade audit logs.

## Search Across Project Data
PostgreSQL full-text search initially. Elasticsearch/OpenSearch for advanced filtering, fuzzy search, cross-resource search. Permission-filtered results. Source of truth always PostgreSQL.

## Budget/Cost Tracking
Ledger-style append-only financial events. Never overwrite financial history. Derive balances from transactions. Strong transactional integrity. Background jobs for reports.

## Submittals Workflow
```text
Draft → Submitted → In Review → Revise & Resubmit → Approved → Closed
```
Model as explicit states and transitions rather than boolean columns. Makes it testable, observable, and evolvable.

## Reports/Dashboard
Short-term: optimized SQL + materialized views + caching + background export jobs.
Long-term: data warehouse + event streaming + pre-aggregated metrics.

> "I would avoid running heavy reporting queries directly against critical transactional tables during peak usage."

## Webhook Delivery
```sql
webhook_deliveries(id, subscription_id, event_id, status, attempt_count, 
                   next_retry_at, response_code)
```
Sign payloads with HMAC. Retry transient failures. Dead-letter for permanent failures. Make delivery idempotent with event IDs.

## Rate Limiting
Redis token bucket or leaky bucket. Scope by user, company, API client, endpoint. Return 429. Monitor rejection rate.

## Feature Flags
Use for gradual rollout, kill switches, risky migrations, A/B tests. Track ownership and cleanup dates. Don't leave flags forever.
