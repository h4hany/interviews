# Ruby on Rails Interview Preparation — System Design Examples

**Prepared date:** 2026-06-02  
**Target:** Senior → Staff → Principal architecture, team lead, and engineering manager technical rounds  
**Format:** Question → Interview Category / Level → Answer → Ruby/Rails example → Interview tips/resources.

---

## Master deep-dive prompt

Copy this prompt to any AI when you want to go deeper on any question in this file:

```text
You are a Principal Ruby on Rails interviewer and Staff-level mentor.
I am preparing for Ruby on Rails interviews. I will give you one question from this guide.
Your task:
1. Explain the concept from first principles.
2. Give a real production Rails example.
3. Show Ruby/Rails code when useful.
4. Explain tradeoffs, edge cases, performance impact, security impact, and testing strategy.
5. Ask me 3 follow-up interview questions.
6. Give me a short answer version I can say in an interview.
7. Correct my answer if I respond.
Question: <PASTE QUESTION HERE>
```

---

## How to use this guide

Use this file as a repeatable architecture script. For each prompt, start by asking clarifying questions, state assumptions, draw a simple design, then go deeper into data model, APIs, async processing, caching, security, observability, and tradeoffs.

---
## Universal architecture answer structure

Use this for almost every architecture prompt:

1. Clarify users, workflow, scale, consistency, security, and UX.
2. State assumptions.
3. Define functional and non-functional requirements.
4. Start with a simple high-level architecture.
5. Define core data model and APIs.
6. Discuss async jobs, events, caching, and search.
7. Discuss security, authorization, and audit logs.
8. Discuss observability and SLOs.
9. Discuss tradeoffs and phased rollout.
10. Mention how you would evolve the system.

---

    ### System Design 1. Design an RFI Management System

    **Interview category / level:** Senior / Staff / Principal Architecture

    **Problem framing:**  
    RFIs are construction clarification workflows. Model lifecycle carefully because state affects responsibility, notifications, reporting, and liability.

    **Clarifying questions:**
    - Who creates RFIs?
- Can multiple companies collaborate?
- Is approval required before official answer?
- Can an RFI reopen?
- Do we need due dates/escalations?
- Offline mobile?

    **Functional requirements:**
    - Create/edit/submit RFIs
- Assign reviewers
- Official responses
- Comments/attachments
- Status transitions
- Search/filtering
- Audit trail
- Notifications

    **Non-functional requirements:**
    - Tenant/project isolation
- Strong consistency for official status
- Eventual consistency for notifications/search
- Low-latency lists
- High availability
- Auditability

    **High-level architecture:**
    ```text
    Rails modular monolith + PostgreSQL for RFI data + S3 for attachments + Redis for counts/cache + Sidekiq for notifications/reminders + search index when full-text grows.
    ```

    **Low-level data model:**
    ```text
    rfis(id, company_id, project_id, number, title, question, status, created_by_id, assigned_to_id, due_date)
rfi_responses(id, rfi_id, responder_id, body, official)
rfi_comments(id, rfi_id, user_id, body)
attachments(id, resource_type, resource_id, s3_key)
activity_logs(id, actor_id, action, resource_type, resource_id, metadata_json)
outbox_events(id, event_type, aggregate_id, payload_json, status)
    ```

    **API design:**
    ```http
    POST /projects/:project_id/rfis
GET /projects/:project_id/rfis?status=open&assignee_id=123
POST /rfis/:id/submit
POST /rfis/:id/responses
POST /rfis/:id/comments
POST /rfis/:id/attachments/presign
GET /rfis/:id/activity
    ```

    **Async processing / reliability:**
    - Use background jobs for slow side effects.
    - Use an outbox/event table when business changes must reliably trigger downstream work.
    - Make workers idempotent.
    - Use retries with backoff and a dead-letter path.
    - Track queue latency and failure rate.

    **Caching / performance:**
    - Cache read-heavy stable data.
    - Use pagination/cursor pagination for lists.
    - Measure cache hit rate.
    - Define invalidation rules before adding cache.

    **Security / permissions:**
    - Enforce tenant/project authorization in the backend.
    - Avoid leaking data through search, notifications, or cached responses.
    - Audit important state changes.
    - Use signed URLs for private file access.

    **Observability:**
    - p95/p99 endpoint latency.
    - Error rate.
    - DB query latency.
    - Queue latency.
    - Worker failures/retries.
    - Cache hit rate.
    - External API latency.
    - Trace important workflow spans.

    **Tradeoffs:**
    - Status and official response are strongly consistent
- Notifications/search/reminders are async
- PostgreSQL first, OpenSearch later
- Modular monolith first; extract document/search/notification later if needed

    **Common mistakes:**
    - Forgetting project-level permissions
- No audit log
- No state machine
- Sending emails inside transaction
- No attachment security
- Unpaginated list endpoints

    **Strong closing sentence:**  
    I would start with the simplest design that protects correctness and gives us observability, then evolve based on measured bottlenecks, team ownership, and product requirements.

    ---

    ### System Design 2. Design a Document and Drawing Management System

    **Interview category / level:** Senior / Staff Architecture

    **Problem framing:**  
    Construction document systems must protect version correctness. Users must not accidentally build from stale drawings.

    **Clarifying questions:**
    - File types and max size?
- Do we need version retention forever?
- Approval before publish?
- OCR/search?
- Offline access?
- External collaborators?

    **Functional requirements:**
    - Direct uploads
- Version documents
- Publish current version
- Generate previews/OCR
- Search
- Comments/markups
- Link to RFIs/tasks
- Audit downloads/publishes

    **Non-functional requirements:**
    - Large file support
- Avoid Rails file streaming
- Strong consistency for metadata/current version
- Async previews/search
- Secure signed URLs
- Durable storage

    **High-level architecture:**
    ```text
    Client requests pre-signed URL from Rails. Client uploads directly to S3/object storage. Rails stores metadata and enqueues scan/preview/OCR/search jobs. CDN serves previews/downloads after authorization.
    ```

    **Low-level data model:**
    ```text
    documents(id, company_id, project_id, folder_id, name, current_version_id, status)
document_versions(id, document_id, version_number, s3_key, checksum, file_size, status, uploaded_by_id)
document_links(id, document_id, linked_resource_type, linked_resource_id)
document_markups(id, document_version_id, user_id, markup_json)
activity_logs(...)
    ```

    **API design:**
    ```http
    POST /projects/:project_id/documents/presign
POST /documents/:id/versions/complete
POST /documents/:id/publish
GET /documents/:id/versions
POST /documents/:id/comments
GET /projects/:project_id/documents?folder_id=123&page=1
    ```

    **Async processing / reliability:**
    - Use background jobs for slow side effects.
    - Use an outbox/event table when business changes must reliably trigger downstream work.
    - Make workers idempotent.
    - Use retries with backoff and a dead-letter path.
    - Track queue latency and failure rate.

    **Caching / performance:**
    - Cache read-heavy stable data.
    - Use pagination/cursor pagination for lists.
    - Measure cache hit rate.
    - Define invalidation rules before adding cache.

    **Security / permissions:**
    - Enforce tenant/project authorization in the backend.
    - Avoid leaking data through search, notifications, or cached responses.
    - Audit important state changes.
    - Use signed URLs for private file access.

    **Observability:**
    - p95/p99 endpoint latency.
    - Error rate.
    - DB query latency.
    - Queue latency.
    - Worker failures/retries.
    - Cache hit rate.
    - External API latency.
    - Trace important workflow spans.

    **Tradeoffs:**
    - Direct upload is more complex but prevents app-server memory pressure
- Async search means recent docs may not appear instantly
- Keep metadata in PostgreSQL and binaries in object storage
- Use CDN for previews but always authorize signed URL generation

    **Common mistakes:**
    - Streaming GB files through Rails
- No version model
- No warning for outdated drawings
- Public buckets
- Search as source of truth
- No virus scan

    **Strong closing sentence:**  
    I would start with the simplest design that protects correctness and gives us observability, then evolve based on measured bottlenecks, team ownership, and product requirements.

    ---

    ### System Design 3. Design a Project Task / Punch List System

    **Interview category / level:** Mid / Senior / Staff Architecture

    **Problem framing:**  
    Task/punch systems are collaborative, mobile-heavy, and read-heavy. Status transitions and assignments must be correct; notifications and search can be eventual.

    **Clarifying questions:**
    - Multiple assignees?
- Verification required?
- Locations/areas?
- Dependencies?
- Recurring tasks?
- Offline mobile?
- Real-time comments?

    **Functional requirements:**
    - Create/update tasks
- Assign users/companies
- Status workflow
- Comments
- Photos
- Dashboard filters
- Notifications
- Audit history

    **Non-functional requirements:**
    - Low-latency lists
- Strong consistency for assignment/status
- Eventual consistency for notifications/search
- Tenant isolation
- Mobile-friendly APIs

    **High-level architecture:**
    ```text
    Rails task module + PostgreSQL + Redis dashboard counters + Sidekiq notifications/reminders + S3 attachments + optional search index.
    ```

    **Low-level data model:**
    ```text
    tasks(id, company_id, project_id, title, status, priority, location_id, created_by_id, due_date)
task_assignments(id, task_id, user_id, company_id)
task_comments(id, task_id, user_id, body)
attachments(...)
activity_logs(...)
    ```

    **API design:**
    ```http
    POST /projects/:project_id/tasks
GET /projects/:project_id/tasks?status=open&assignee_id=123
POST /tasks/:id/comments
POST /tasks/:id/attachments/presign
POST /tasks/:id/status
GET /tasks/:id/activity
    ```

    **Async processing / reliability:**
    - Use background jobs for slow side effects.
    - Use an outbox/event table when business changes must reliably trigger downstream work.
    - Make workers idempotent.
    - Use retries with backoff and a dead-letter path.
    - Track queue latency and failure rate.

    **Caching / performance:**
    - Cache read-heavy stable data.
    - Use pagination/cursor pagination for lists.
    - Measure cache hit rate.
    - Define invalidation rules before adding cache.

    **Security / permissions:**
    - Enforce tenant/project authorization in the backend.
    - Avoid leaking data through search, notifications, or cached responses.
    - Audit important state changes.
    - Use signed URLs for private file access.

    **Observability:**
    - p95/p99 endpoint latency.
    - Error rate.
    - DB query latency.
    - Queue latency.
    - Worker failures/retries.
    - Cache hit rate.
    - External API latency.
    - Trace important workflow spans.

    **Tradeoffs:**
    - Denormalized dashboard counters are fast but need reconciliation
- Polling first; WebSockets only where collaboration value is high
- PostgreSQL filtering first; search index later

    **Common mistakes:**
    - No pagination
- No tenant scoping
- No audit of status changes
- No idempotency for mobile retries
- Unbounded photo uploads

    **Strong closing sentence:**  
    I would start with the simplest design that protects correctness and gives us observability, then evolve based on measured bottlenecks, team ownership, and product requirements.

    ---

    ### System Design 4. Design a Notification System

    **Interview category / level:** Senior / Staff Architecture

    **Problem framing:**  
    Notifications look simple but become complex because of preferences, deduplication, retries, rate limits, and channel isolation.

    **Clarifying questions:**
    - Channels: in-app/email/push/SMS?
- Digest support?
- User preferences?
- Real-time?
- Compliance delivery logs?
- Expected volume?

    **Functional requirements:**
    - Create notifications from domain events
- Store in-app notifications
- Read/unread
- Preferences
- Email/push delivery
- Retry failed delivery
- Deduplicate

    **Non-functional requirements:**
    - High throughput
- Eventual consistency acceptable
- Idempotent processing
- Low-latency in-app display
- Reliable retries
- Observability

    **High-level architecture:**
    ```text
    Domain modules write outbox events. Notification dispatcher consumes events, checks preferences/permissions, creates notification records, and enqueues channel-specific delivery jobs.
    ```

    **Low-level data model:**
    ```text
    notifications(id, recipient_id, actor_id, project_id, event_type, resource_type, resource_id, title, body, read_at)
notification_deliveries(id, notification_id, channel, status, provider_message_id, error_message)
notification_preferences(id, user_id, project_id, event_type, channel, enabled)
    ```

    **API design:**
    ```http
    GET /notifications?status=unread&page=1
POST /notifications/:id/read
POST /notifications/read_all
GET /notification_preferences
PATCH /notification_preferences
    ```

    **Async processing / reliability:**
    - Use background jobs for slow side effects.
    - Use an outbox/event table when business changes must reliably trigger downstream work.
    - Make workers idempotent.
    - Use retries with backoff and a dead-letter path.
    - Track queue latency and failure rate.

    **Caching / performance:**
    - Cache read-heavy stable data.
    - Use pagination/cursor pagination for lists.
    - Measure cache hit rate.
    - Define invalidation rules before adding cache.

    **Security / permissions:**
    - Enforce tenant/project authorization in the backend.
    - Avoid leaking data through search, notifications, or cached responses.
    - Audit important state changes.
    - Use signed URLs for private file access.

    **Observability:**
    - p95/p99 endpoint latency.
    - Error rate.
    - DB query latency.
    - Queue latency.
    - Worker failures/retries.
    - Cache hit rate.
    - External API latency.
    - Trace important workflow spans.

    **Tradeoffs:**
    - Immediate notifications increase responsiveness but can be noisy
- Separate queues isolate slow email provider from in-app notifications
- Store rendered message for historical accuracy vs render on read for freshness

    **Common mistakes:**
    - Duplicate notifications
- No preferences
- Blocking core request
- One queue for every channel
- No permission check before sending

    **Strong closing sentence:**  
    I would start with the simplest design that protects correctness and gives us observability, then evolve based on measured bottlenecks, team ownership, and product requirements.

    ---

    ### System Design 5. Design Permission and Audit System for Multi-Company Collaboration

    **Interview category / level:** Staff / Principal Architecture

    **Problem framing:**  
    In construction SaaS, multiple companies work on the same project. Permission bugs can leak sensitive project data.

    **Clarifying questions:**
    - Fixed or custom roles?
- Company/project/resource scope?
- External collaborators?
- Role changes immediate?
- Audit read access or writes only?

    **Functional requirements:**
    - Add/remove members
- Assign roles
- Check permissions
- Custom roles
- Resource restrictions
- Audit sensitive actions
- Cache permission lookups

    **Non-functional requirements:**
    - Fast permission checks
- Tenant isolation
- Fail closed for sensitive actions
- Auditable changes
- Cache invalidation
- Scalable memberships

    **High-level architecture:**
    ```text
    Use RBAC for base roles plus ABAC for contextual rules. Central policy layer in Rails. PostgreSQL source of truth. Redis permission cache with aggressive invalidation. Append-only audit logs.
    ```

    **Low-level data model:**
    ```text
    users(id, company_id)
projects(id, company_id)
project_memberships(id, project_id, user_id, company_id, role_id)
roles(id, company_id, name, scope)
permissions(id, key)
role_permissions(role_id, permission_id)
resource_permissions(resource_type, resource_id, user_id, permission_key)
audit_logs(id, project_id, actor_id, action, resource_type, resource_id, metadata_json)
    ```

    **API design:**
    ```http
    GET /projects/:project_id/members
PATCH /projects/:project_id/members/:id/role
GET /roles
POST /roles
GET /audit_logs?project_id=123&resource_type=RFI
    ```

    **Async processing / reliability:**
    - Use background jobs for slow side effects.
    - Use an outbox/event table when business changes must reliably trigger downstream work.
    - Make workers idempotent.
    - Use retries with backoff and a dead-letter path.
    - Track queue latency and failure rate.

    **Caching / performance:**
    - Cache read-heavy stable data.
    - Use pagination/cursor pagination for lists.
    - Measure cache hit rate.
    - Define invalidation rules before adding cache.

    **Security / permissions:**
    - Enforce tenant/project authorization in the backend.
    - Avoid leaking data through search, notifications, or cached responses.
    - Audit important state changes.
    - Use signed URLs for private file access.

    **Observability:**
    - p95/p99 endpoint latency.
    - Error rate.
    - DB query latency.
    - Queue latency.
    - Worker failures/retries.
    - Cache hit rate.
    - External API latency.
    - Trace important workflow spans.

    **Tradeoffs:**
    - RBAC simple but rigid; ABAC flexible but harder to reason about
- Cache improves speed but risks stale access
- Fail closed improves security but can reduce availability during cache/DB issues

    **Common mistakes:**
    - Scattered permission checks
- Frontend-only authorization
- No cache invalidation
- No audit for role changes
- Queries missing company/project scope

    **Strong closing sentence:**  
    I would start with the simplest design that protects correctness and gives us observability, then evolve based on measured bottlenecks, team ownership, and product requirements.

    ---

    ### System Design 6. Design Offline Mobile Sync for Field Teams

    **Interview category / level:** Staff Architecture

    **Problem framing:**  
    Construction sites often have weak connectivity. Offline sync should be limited to high-value workflows and conflict-aware.

    **Clarifying questions:**
    - Which operations offline?
- Conflict policy?
- Attachments offline?
- How long offline?
- Do approvals require online validation?

    **Functional requirements:**
    - Local writes
- Pending operation queue
- Sync token
- Pull changes since token
- Apply operations idempotently
- Conflict reporting

    **Non-functional requirements:**
    - Idempotent sync
- Conflict safety
- Low bandwidth
- Eventual consistency
- Secure local storage
- Auditability

    **High-level architecture:**
    ```text
    Mobile client stores local DB + pending operations with client IDs. Server exposes sync endpoint accepting operations with idempotency keys and returning server changes since a sync token.
    ```

    **Low-level data model:**
    ```text
    sync_operations(id, client_operation_id, user_id, resource_type, resource_id, operation_type, payload, status)
change_logs(id, project_id, resource_type, resource_id, version, changed_at)
    ```

    **API design:**
    ```http
    POST /sync/push
GET /sync/pull?project_id=123&since_token=abc
POST /attachments/offline_upload/complete
    ```

    **Async processing / reliability:**
    - Use background jobs for slow side effects.
    - Use an outbox/event table when business changes must reliably trigger downstream work.
    - Make workers idempotent.
    - Use retries with backoff and a dead-letter path.
    - Track queue latency and failure rate.

    **Caching / performance:**
    - Cache read-heavy stable data.
    - Use pagination/cursor pagination for lists.
    - Measure cache hit rate.
    - Define invalidation rules before adding cache.

    **Security / permissions:**
    - Enforce tenant/project authorization in the backend.
    - Avoid leaking data through search, notifications, or cached responses.
    - Audit important state changes.
    - Use signed URLs for private file access.

    **Observability:**
    - p95/p99 endpoint latency.
    - Error rate.
    - DB query latency.
    - Queue latency.
    - Worker failures/retries.
    - Cache hit rate.
    - External API latency.
    - Trace important workflow spans.

    **Tradeoffs:**
    - Offline creates complexity; support only selected workflows
- Last-write-wins is simple but can lose data
- Explicit conflict UI is safer for important records

    **Common mistakes:**
    - No idempotency
- No conflict detection
- Allowing risky approvals offline
- Large attachments without resumable upload

    **Strong closing sentence:**  
    I would start with the simplest design that protects correctness and gives us observability, then evolve based on measured bottlenecks, team ownership, and product requirements.

    ---

    ### System Design 7. Design Project Activity Feed

    **Interview category / level:** Senior / Staff Architecture

    **Problem framing:**  
    Activity feeds are read-heavy projections of domain events. The feed should not slow core writes.

    **Clarifying questions:**
    - Per project or global?
- Strict ordering?
- Retention?
- Permissions?
- Real-time updates?
- Fanout strategy?

    **Functional requirements:**
    - Generate activity events
- List with cursor pagination
- Filter by project/resource
- Real-time update signal
- Replay/rebuild feed

    **Non-functional requirements:**
    - Low read latency
- Eventual consistency
- Idempotent consumers
- Permission safety
- Consumer lag monitoring

    **High-level architecture:**
    ```text
    Domain actions write outbox events. Feed processor builds read model in PostgreSQL/Redis/OpenSearch. Clients read feed by cursor. WebSocket broadcasts lightweight 'new activity' signals.
    ```

    **Low-level data model:**
    ```text
    activity_events(id, company_id, project_id, actor_id, event_type, resource_type, resource_id, metadata_json, created_at)
outbox_events(...)
    ```

    **API design:**
    ```http
    GET /projects/:project_id/activity?cursor=abc&limit=50
GET /resources/:type/:id/activity
    ```

    **Async processing / reliability:**
    - Use background jobs for slow side effects.
    - Use an outbox/event table when business changes must reliably trigger downstream work.
    - Make workers idempotent.
    - Use retries with backoff and a dead-letter path.
    - Track queue latency and failure rate.

    **Caching / performance:**
    - Cache read-heavy stable data.
    - Use pagination/cursor pagination for lists.
    - Measure cache hit rate.
    - Define invalidation rules before adding cache.

    **Security / permissions:**
    - Enforce tenant/project authorization in the backend.
    - Avoid leaking data through search, notifications, or cached responses.
    - Audit important state changes.
    - Use signed URLs for private file access.

    **Observability:**
    - p95/p99 endpoint latency.
    - Error rate.
    - DB query latency.
    - Queue latency.
    - Worker failures/retries.
    - Cache hit rate.
    - External API latency.
    - Trace important workflow spans.

    **Tradeoffs:**
    - Fanout-on-write is fast for reads but can write amplify
- Fanout-on-read is simpler for large audiences
- Eventual consistency acceptable with optimistic UI

    **Common mistakes:**
    - Building feed from OLTP tables on every request
- No cursor pagination
- No idempotency
- No replay

    **Strong closing sentence:**  
    I would start with the simplest design that protects correctness and gives us observability, then evolve based on measured bottlenecks, team ownership, and product requirements.

    ---

    ### System Design 8. Design Webhook Delivery Platform

    **Interview category / level:** Staff / Principal API Platform

    **Problem framing:**  
    Webhook systems must isolate external endpoint slowness from the core product.

    **Clarifying questions:**
    - Which events exposed?
- Retry policy?
- Developer replay?
- Signing/secrets?
- Per-tenant rate limits?
- Payload filtering?

    **Functional requirements:**
    - Subscriptions
- Event catalog
- Delivery attempts
- Retries
- HMAC signatures
- Replay
- Developer logs
- Rate limits

    **Non-functional requirements:**
    - At-least-once delivery
- Core system isolation
- Backpressure
- Observability
- Secure payloads
- Idempotent event IDs

    **High-level architecture:**
    ```text
    Business transaction writes outbox. Publisher queues events. Webhook dispatcher finds subscriptions, creates delivery records, signs payloads, sends HTTP, retries transient failures with backoff+jitter, and dead-letters repeated failures.
    ```

    **Low-level data model:**
    ```text
    webhook_subscriptions(id, company_id, url, secret, enabled)
webhook_events(id, event_type, aggregate_id, payload_json)
webhook_deliveries(id, subscription_id, event_id, status, attempt_count, next_retry_at, response_code)
    ```

    **API design:**
    ```http
    POST /webhook_subscriptions
GET /webhook_deliveries?status=failed
POST /webhook_deliveries/:id/replay
    ```

    **Async processing / reliability:**
    - Use background jobs for slow side effects.
    - Use an outbox/event table when business changes must reliably trigger downstream work.
    - Make workers idempotent.
    - Use retries with backoff and a dead-letter path.
    - Track queue latency and failure rate.

    **Caching / performance:**
    - Cache read-heavy stable data.
    - Use pagination/cursor pagination for lists.
    - Measure cache hit rate.
    - Define invalidation rules before adding cache.

    **Security / permissions:**
    - Enforce tenant/project authorization in the backend.
    - Avoid leaking data through search, notifications, or cached responses.
    - Audit important state changes.
    - Use signed URLs for private file access.

    **Observability:**
    - p95/p99 endpoint latency.
    - Error rate.
    - DB query latency.
    - Queue latency.
    - Worker failures/retries.
    - Cache hit rate.
    - External API latency.
    - Trace important workflow spans.

    **Tradeoffs:**
    - At-least-once means receivers must dedupe
- Retrying 4xx blindly creates noise
- Signing improves trust but requires secret rotation

    **Common mistakes:**
    - Calling webhooks inside request
- No HMAC signature
- No delivery logs
- Infinite retries
- No endpoint circuit breaker

    **Strong closing sentence:**  
    I would start with the simplest design that protects correctness and gives us observability, then evolve based on measured bottlenecks, team ownership, and product requirements.

    ---

    ### System Design 9. Design Search Across Project Data

    **Interview category / level:** Staff Architecture

    **Problem framing:**  
    Search spans tasks, RFIs, documents, comments, and users. The hard part is permission-safe, relevant results.

    **Clarifying questions:**
    - Which resources?
- Full-text vs semantic?
- Permission filtering?
- Latency target?
- Cross-project search?
- Freshness requirement?

    **Functional requirements:**
    - Index resources
- Search/filter/rank
- Permission-aware results
- Handle stale index
- Reindex/reconcile
- Highlight snippets

    **Non-functional requirements:**
    - Low-latency
- Eventual consistency acceptable
- PostgreSQL source of truth
- Secure filtering
- Rebuildable index

    **High-level architecture:**
    ```text
    PostgreSQL remains source of truth. Domain events update search index asynchronously. Query API validates permission and filters by allowed project/resource scope. Reconciliation jobs fix missed events.
    ```

    **Low-level data model:**
    ```text
    search_documents(indexed outside DB or table projection):
resource_type, resource_id, company_id, project_id, title, body, permissions_snapshot, updated_at
    ```

    **API design:**
    ```http
    GET /search?q=door&project_id=123&type=rfi,task&page=1
    ```

    **Async processing / reliability:**
    - Use background jobs for slow side effects.
    - Use an outbox/event table when business changes must reliably trigger downstream work.
    - Make workers idempotent.
    - Use retries with backoff and a dead-letter path.
    - Track queue latency and failure rate.

    **Caching / performance:**
    - Cache read-heavy stable data.
    - Use pagination/cursor pagination for lists.
    - Measure cache hit rate.
    - Define invalidation rules before adding cache.

    **Security / permissions:**
    - Enforce tenant/project authorization in the backend.
    - Avoid leaking data through search, notifications, or cached responses.
    - Audit important state changes.
    - Use signed URLs for private file access.

    **Observability:**
    - p95/p99 endpoint latency.
    - Error rate.
    - DB query latency.
    - Queue latency.
    - Worker failures/retries.
    - Cache hit rate.
    - External API latency.
    - Trace important workflow spans.

    **Tradeoffs:**
    - Query-time permission filtering safer but slower
- Index-time permission snapshot faster but can go stale
- PostgreSQL FTS first; OpenSearch when ranking/fuzzy/cross-resource grows

    **Common mistakes:**
    - Returning unauthorized search hits
- Treating search as source of truth
- No reindex strategy
- No index lag metrics

    **Strong closing sentence:**  
    I would start with the simplest design that protects correctness and gives us observability, then evolve based on measured bottlenecks, team ownership, and product requirements.

    ---

    ### System Design 10. Design Reporting/Dashboard System

    **Interview category / level:** Senior / Staff Architecture

    **Problem framing:**  
    Reports can overload OLTP databases if heavy aggregations run on primary tables during peak traffic.

    **Clarifying questions:**
    - Real-time or daily?
- Exports?
- Filters?
- Tenant isolation?
- Data retention?
- Who consumes?

    **Functional requirements:**
    - Dashboard metrics
- CSV/PDF export
- Filters
- Async generation
- Download link
- Scheduled reports

    **Non-functional requirements:**
    - Low impact on OLTP
- Acceptable freshness
- Scalable exports
- Permission enforcement
- Observability

    **High-level architecture:**
    ```text
    Start with optimized SQL/materialized views. Move expensive reports to background jobs and object storage. Long-term, use CDC/ETL to analytics store/warehouse.
    ```

    **Low-level data model:**
    ```text
    report_jobs(id, user_id, project_id, report_type, status, s3_key)
project_metric_snapshots(project_id, metric_name, value, calculated_at)
    ```

    **API design:**
    ```http
    POST /projects/:project_id/reports
GET /reports/:id
GET /projects/:project_id/dashboard
    ```

    **Async processing / reliability:**
    - Use background jobs for slow side effects.
    - Use an outbox/event table when business changes must reliably trigger downstream work.
    - Make workers idempotent.
    - Use retries with backoff and a dead-letter path.
    - Track queue latency and failure rate.

    **Caching / performance:**
    - Cache read-heavy stable data.
    - Use pagination/cursor pagination for lists.
    - Measure cache hit rate.
    - Define invalidation rules before adding cache.

    **Security / permissions:**
    - Enforce tenant/project authorization in the backend.
    - Avoid leaking data through search, notifications, or cached responses.
    - Audit important state changes.
    - Use signed URLs for private file access.

    **Observability:**
    - p95/p99 endpoint latency.
    - Error rate.
    - DB query latency.
    - Queue latency.
    - Worker failures/retries.
    - Cache hit rate.
    - External API latency.
    - Trace important workflow spans.

    **Tradeoffs:**
    - Materialized views simple but stale
- Warehouse adds power but complexity
- Async exports better UX for huge data

    **Common mistakes:**
    - Synchronous giant exports
- SELECT * reports
- No permission check on export
- No expiration for download URLs

    **Strong closing sentence:**  
    I would start with the simplest design that protects correctness and gives us observability, then evolve based on measured bottlenecks, team ownership, and product requirements.

    ---

    ### System Design 11. Design Budget / Cost Tracking System

    **Interview category / level:** Staff / Principal Architecture

    **Problem framing:**  
    Financial-like construction data requires correctness, auditability, and explainability.

    **Clarifying questions:**
    - Ledger required?
- Approval flow?
- Currencies?
- Change orders?
- External accounting integration?
- Consistency level?

    **Functional requirements:**
    - Budgets
- Cost codes
- Commitments
- Invoices
- Change orders
- Forecasts
- Audit trail
- Reports

    **Non-functional requirements:**
    - Strong consistency for ledger source
- Append-only history
- Idempotent integrations
- High auditability
- Eventual summaries

    **High-level architecture:**
    ```text
    Use append-only ledger events as source of truth. Derive balances/summaries into read models. Wrap critical writes in transactions and database constraints. Integrate external accounting async with reconciliation.
    ```

    **Low-level data model:**
    ```text
    ledger_entries(id, project_id, cost_code_id, amount_cents, currency, entry_type, source_type, source_id, created_at)
budget_summaries(project_id, cost_code_id, committed_cents, actual_cents, forecast_cents)
    ```

    **API design:**
    ```http
    POST /projects/:project_id/change_orders
GET /projects/:project_id/budget
GET /ledger_entries?cost_code_id=123
    ```

    **Async processing / reliability:**
    - Use background jobs for slow side effects.
    - Use an outbox/event table when business changes must reliably trigger downstream work.
    - Make workers idempotent.
    - Use retries with backoff and a dead-letter path.
    - Track queue latency and failure rate.

    **Caching / performance:**
    - Cache read-heavy stable data.
    - Use pagination/cursor pagination for lists.
    - Measure cache hit rate.
    - Define invalidation rules before adding cache.

    **Security / permissions:**
    - Enforce tenant/project authorization in the backend.
    - Avoid leaking data through search, notifications, or cached responses.
    - Audit important state changes.
    - Use signed URLs for private file access.

    **Observability:**
    - p95/p99 endpoint latency.
    - Error rate.
    - DB query latency.
    - Queue latency.
    - Worker failures/retries.
    - Cache hit rate.
    - External API latency.
    - Trace important workflow spans.

    **Tradeoffs:**
    - Ledger correctness over convenience
- Summaries can be eventual but source entries must be durable
- External accounting needs idempotency/reconciliation

    **Common mistakes:**
    - Updating balances without history
- No unique idempotency key
- No audit trail
- Floats for money

    **Strong closing sentence:**  
    I would start with the simplest design that protects correctness and gives us observability, then evolve based on measured bottlenecks, team ownership, and product requirements.

    ---

    ### System Design 12. Design Real-Time Comments

    **Interview category / level:** Senior Architecture

    **Problem framing:**  
    Comments need strong persistence, async notifications, and optional real-time broadcast.

    **Clarifying questions:**
    - Resources supported?
- Mentions?
- Attachments?
- Edit/delete?
- Realtime required?
- Permissions?

    **Functional requirements:**
    - Create comments
- Mentions
- Attachments
- Broadcast
- Notify
- Activity log
- Moderation/delete

    **Non-functional requirements:**
    - Strong consistency for stored comment
- Eventual notifications
- Permission-safe broadcasts
- Low latency

    **High-level architecture:**
    ```text
    POST comment in transaction. Write mentions/activity/outbox. After commit, broadcast event and enqueue notifications. Clients refresh if broadcast missed.
    ```

    **Low-level data model:**
    ```text
    comments(id, resource_type, resource_id, user_id, body)
mentions(id, comment_id, mentioned_user_id)
outbox_events(...)
    ```

    **API design:**
    ```http
    POST /tasks/:id/comments
PATCH /comments/:id
DELETE /comments/:id
    ```

    **Async processing / reliability:**
    - Use background jobs for slow side effects.
    - Use an outbox/event table when business changes must reliably trigger downstream work.
    - Make workers idempotent.
    - Use retries with backoff and a dead-letter path.
    - Track queue latency and failure rate.

    **Caching / performance:**
    - Cache read-heavy stable data.
    - Use pagination/cursor pagination for lists.
    - Measure cache hit rate.
    - Define invalidation rules before adding cache.

    **Security / permissions:**
    - Enforce tenant/project authorization in the backend.
    - Avoid leaking data through search, notifications, or cached responses.
    - Audit important state changes.
    - Use signed URLs for private file access.

    **Observability:**
    - p95/p99 endpoint latency.
    - Error rate.
    - DB query latency.
    - Queue latency.
    - Worker failures/retries.
    - Cache hit rate.
    - External API latency.
    - Trace important workflow spans.

    **Tradeoffs:**
    - Broadcast is best-effort; DB is source of truth
- WebSockets improve UX but add infra complexity
- Mentions can be async

    **Common mistakes:**
    - Broadcast before commit
- No permission check on channel
- No moderation/edit audit

    **Strong closing sentence:**  
    I would start with the simplest design that protects correctness and gives us observability, then evolve based on measured bottlenecks, team ownership, and product requirements.

    ---

    ### System Design 13. Design Submittals Workflow

    **Interview category / level:** Senior / Staff Architecture

    **Problem framing:**  
    Submittals are approval workflows. Model explicit state transitions rather than booleans.

    **Clarifying questions:**
    - Sequential or parallel reviewers?
- Revision cycle?
- Delegation?
- Due dates?
- External reviewers?
- Official response?

    **Functional requirements:**
    - Create submittal
- Submit
- Review steps
- Approve/revise/reject
- Attachments
- Notifications
- Audit

    **Non-functional requirements:**
    - Strong consistency for state transitions
- Async reminders
- Auditability
- Permission boundaries

    **High-level architecture:**
    ```text
    PostgreSQL state machine for submittals and review steps. Workers send reminders and update search. Attachments in object storage.
    ```

    **Low-level data model:**
    ```text
    submittals(id, project_id, status, created_by_id)
submittal_review_steps(id, submittal_id, position, status)
submittal_responses(id, step_id, reviewer_id, response, comment)
    ```

    **API design:**
    ```http
    POST /projects/:project_id/submittals
POST /submittals/:id/submit
POST /submittals/:id/review_steps/:step_id/respond
    ```

    **Async processing / reliability:**
    - Use background jobs for slow side effects.
    - Use an outbox/event table when business changes must reliably trigger downstream work.
    - Make workers idempotent.
    - Use retries with backoff and a dead-letter path.
    - Track queue latency and failure rate.

    **Caching / performance:**
    - Cache read-heavy stable data.
    - Use pagination/cursor pagination for lists.
    - Measure cache hit rate.
    - Define invalidation rules before adding cache.

    **Security / permissions:**
    - Enforce tenant/project authorization in the backend.
    - Avoid leaking data through search, notifications, or cached responses.
    - Audit important state changes.
    - Use signed URLs for private file access.

    **Observability:**
    - p95/p99 endpoint latency.
    - Error rate.
    - DB query latency.
    - Queue latency.
    - Worker failures/retries.
    - Cache hit rate.
    - External API latency.
    - Trace important workflow spans.

    **Tradeoffs:**
    - Explicit state machine makes reporting/testing easier
- Parallel reviews faster but more complex
- Async reminders do not block core workflow

    **Common mistakes:**
    - Ad-hoc booleans
- No revision history
- No due-date escalation
- No audit

    **Strong closing sentence:**  
    I would start with the simplest design that protects correctness and gives us observability, then evolve based on measured bottlenecks, team ownership, and product requirements.

    ---

    ### System Design 14. Design Observability Platform / Telemetry Pipeline

    **Interview category / level:** Staff / Principal Runtime Architecture

    **Problem framing:**  
    Telemetry must help teams debug without overwhelming storage/cost.

    **Clarifying questions:**
    - Signals needed?
- Backend vendor?
- Sampling rules?
- PII policy?
- Volume?
- Team standards?

    **Functional requirements:**
    - Collect traces/metrics/logs
- Propagate context
- Sampling
- Dashboards
- Alerts
- Collector pipeline
- Attribute standards

    **Non-functional requirements:**
    - Low overhead
- Cost control
- Privacy
- High availability
- Useful queryability

    **High-level architecture:**
    ```text
    Apps emit OTel to local/gateway collectors. Collectors batch, filter, scrub, sample, and export to backend. Keep all errors/slow traces; sample healthy traffic. Define standards and golden paths.
    ```

    **Low-level data model:**
    ```text
    No app DB schema required, but standards include:
service.name, deployment.environment, service.version, trace_id in logs
    ```

    **API design:**
    ```http
    OTLP/gRPC from apps to collector
Collector exporters to Datadog/Honeycomb/Tempo/Prometheus
    ```

    **Async processing / reliability:**
    - Use background jobs for slow side effects.
    - Use an outbox/event table when business changes must reliably trigger downstream work.
    - Make workers idempotent.
    - Use retries with backoff and a dead-letter path.
    - Track queue latency and failure rate.

    **Caching / performance:**
    - Cache read-heavy stable data.
    - Use pagination/cursor pagination for lists.
    - Measure cache hit rate.
    - Define invalidation rules before adding cache.

    **Security / permissions:**
    - Enforce tenant/project authorization in the backend.
    - Avoid leaking data through search, notifications, or cached responses.
    - Audit important state changes.
    - Use signed URLs for private file access.

    **Observability:**
    - p95/p99 endpoint latency.
    - Error rate.
    - DB query latency.
    - Queue latency.
    - Worker failures/retries.
    - Cache hit rate.
    - External API latency.
    - Trace important workflow spans.

    **Tradeoffs:**
    - Auto-instrumentation gives breadth; manual spans give business meaning
- Tail sampling better for errors but requires buffering
- High-cardinality metrics are expensive

    **Common mistakes:**
    - No sampling
- PII in spans
- No async propagation
- No naming conventions
- Dashboards no one uses

    **Strong closing sentence:**  
    I would start with the simplest design that protects correctness and gives us observability, then evolve based on measured bottlenecks, team ownership, and product requirements.

    ---

    ### System Design 15. Design Monolith to Service Extraction for Permissions

    **Interview category / level:** Staff / Principal Architecture

    **Problem framing:**  
    Permissions is cross-cutting and high-risk. Extract slowly and safely.

    **Clarifying questions:**
    - Why extract?
- Current callers?
- Latency target?
- Failure behavior fail-open/closed?
- Data ownership?
- Migration timeline?

    **Functional requirements:**
    - Internal permission API
- Backfill data
- Shadow compare
- Gradual read switch
- Cache decisions
- Audit changes

    **Non-functional requirements:**
    - Zero downtime
- Security correctness
- Low latency
- Backward compatibility
- Observability

    **High-level architecture:**
    ```text
    First modularize inside monolith, create `Permissions::CheckAccess` interface, instrument calls, stop direct table access, build service behind client, shadow compare, shift traffic with flags, migrate data with outbox/backfill.
    ```

    **Low-level data model:**
    ```text
    permission_checks are not necessarily stored, but data includes:
project_memberships, roles, permissions, role_permissions, audit_logs
    ```

    **API design:**
    ```http
    POST /internal/permissions/check
POST /internal/permissions/grant_role
GET /internal/permissions/users/:id/projects/:project_id
    ```

    **Async processing / reliability:**
    - Use background jobs for slow side effects.
    - Use an outbox/event table when business changes must reliably trigger downstream work.
    - Make workers idempotent.
    - Use retries with backoff and a dead-letter path.
    - Track queue latency and failure rate.

    **Caching / performance:**
    - Cache read-heavy stable data.
    - Use pagination/cursor pagination for lists.
    - Measure cache hit rate.
    - Define invalidation rules before adding cache.

    **Security / permissions:**
    - Enforce tenant/project authorization in the backend.
    - Avoid leaking data through search, notifications, or cached responses.
    - Audit important state changes.
    - Use signed URLs for private file access.

    **Observability:**
    - p95/p99 endpoint latency.
    - Error rate.
    - DB query latency.
    - Queue latency.
    - Worker failures/retries.
    - Cache hit rate.
    - External API latency.
    - Trace important workflow spans.

    **Tradeoffs:**
    - Modular monolith may be enough
- Service extraction improves ownership but adds network/failure complexity
- Fail closed is safer but can hurt availability

    **Common mistakes:**
    - Distributed monolith
- No shadow validation
- No rollback
- Shared DB forever

    **Strong closing sentence:**  
    I would start with the simplest design that protects correctness and gives us observability, then evolve based on measured bottlenecks, team ownership, and product requirements.

    ---

    ### System Design 16. Design API Rate Limiting

    **Interview category / level:** Senior / Staff API Platform

    **Problem framing:**  
    Rate limiting protects the platform and provides fair usage.

    **Clarifying questions:**
    - Limit by user/company/API key/IP?
- Burst allowed?
- Internal bypass?
- Paid tiers?
- Endpoint-specific limits?

    **Functional requirements:**
    - Token bucket
- 429 responses
- Headers
- Admin overrides
- Metrics
- Abuse detection

    **Non-functional requirements:**
    - Distributed correctness
- Low latency
- Burst control
- Clear developer UX

    **High-level architecture:**
    ```text
    Use Redis token bucket with Lua for atomic check/update. Apply limits at API gateway and app layer for business-specific rules.
    ```

    **Low-level data model:**
    ```text
    rate_limit_events(optional): id, key, endpoint, allowed, created_at
    ```

    **API design:**
    ```http
    HTTP 429
X-RateLimit-Limit
X-RateLimit-Remaining
Retry-After
    ```

    **Async processing / reliability:**
    - Use background jobs for slow side effects.
    - Use an outbox/event table when business changes must reliably trigger downstream work.
    - Make workers idempotent.
    - Use retries with backoff and a dead-letter path.
    - Track queue latency and failure rate.

    **Caching / performance:**
    - Cache read-heavy stable data.
    - Use pagination/cursor pagination for lists.
    - Measure cache hit rate.
    - Define invalidation rules before adding cache.

    **Security / permissions:**
    - Enforce tenant/project authorization in the backend.
    - Avoid leaking data through search, notifications, or cached responses.
    - Audit important state changes.
    - Use signed URLs for private file access.

    **Observability:**
    - p95/p99 endpoint latency.
    - Error rate.
    - DB query latency.
    - Queue latency.
    - Worker failures/retries.
    - Cache hit rate.
    - External API latency.
    - Trace important workflow spans.

    **Tradeoffs:**
    - Token bucket allows bursts; leaky bucket smooths traffic
- Gateway-level faster; app-level knows tenant/business context

    **Common mistakes:**
    - Non-atomic get/set
- No headers
- One global limit for all endpoints
- No allowlist

    **Strong closing sentence:**  
    I would start with the simplest design that protects correctness and gives us observability, then evolve based on measured bottlenecks, team ownership, and product requirements.

    ---

    ### System Design 17. Design Large File Upload System

    **Interview category / level:** Senior Architecture

    **Problem framing:**  
    Large uploads should not flow through Rails memory.

    **Clarifying questions:**
    - Max size?
- Multipart?
- Resume?
- Virus scanning?
- Private files?
- Client platforms?

    **Functional requirements:**
    - Presign upload
- Multipart upload
- Complete callback
- Metadata
- Scan
- Preview
- Retry/resume

    **Non-functional requirements:**
    - Scalable upload throughput
- Secure URLs
- Durable storage
- Async processing

    **High-level architecture:**
    ```text
    Rails creates pending file version and returns pre-signed multipart URLs. Client uploads directly to object storage. Completion endpoint marks uploaded and queues processing.
    ```

    **Low-level data model:**
    ```text
    file_uploads(id, project_id, status, storage_key, checksum, size_bytes, uploaded_by_id)
    ```

    **API design:**
    ```http
    POST /files/presign
POST /files/:id/complete
GET /files/:id/download_url
    ```

    **Async processing / reliability:**
    - Use background jobs for slow side effects.
    - Use an outbox/event table when business changes must reliably trigger downstream work.
    - Make workers idempotent.
    - Use retries with backoff and a dead-letter path.
    - Track queue latency and failure rate.

    **Caching / performance:**
    - Cache read-heavy stable data.
    - Use pagination/cursor pagination for lists.
    - Measure cache hit rate.
    - Define invalidation rules before adding cache.

    **Security / permissions:**
    - Enforce tenant/project authorization in the backend.
    - Avoid leaking data through search, notifications, or cached responses.
    - Audit important state changes.
    - Use signed URLs for private file access.

    **Observability:**
    - p95/p99 endpoint latency.
    - Error rate.
    - DB query latency.
    - Queue latency.
    - Worker failures/retries.
    - Cache hit rate.
    - External API latency.
    - Trace important workflow spans.

    **Tradeoffs:**
    - Direct upload complex but scalable
- Server proxy simpler but poor for large files
- Async processing means pending state must be clear

    **Common mistakes:**
    - No checksum
- Long-lived signed URLs
- Public bucket
- No failed processing state

    **Strong closing sentence:**  
    I would start with the simplest design that protects correctness and gives us observability, then evolve based on measured bottlenecks, team ownership, and product requirements.

    ---

    ### System Design 18. Design Event-Driven Audit Logging

    **Interview category / level:** Senior / Staff Architecture

    **Problem framing:**  
    Audit logs must prioritize integrity and traceability over UI convenience.

    **Clarifying questions:**
    - Audit reads or writes?
- Retention?
- Immutable?
- Search requirements?
- Compliance export?
- Sensitive data?

    **Functional requirements:**
    - Record actor/action/resource
- Old/new values
- Trace/request ID
- Append-only
- Search/export

    **Non-functional requirements:**
    - Durability
- Tamper resistance
- Low write overhead
- Queryable history

    **High-level architecture:**
    ```text
    Critical audit writes happen in same transaction as business change. High-volume activity events can be async. Store request_id/trace_id for investigation.
    ```

    **Low-level data model:**
    ```text
    audit_logs(id, company_id, project_id, actor_id, action, resource_type, resource_id, previous_values, new_values, request_id, trace_id, created_at)
    ```

    **API design:**
    ```http
    GET /audit_logs?project_id=123&resource_type=Document
    ```

    **Async processing / reliability:**
    - Use background jobs for slow side effects.
    - Use an outbox/event table when business changes must reliably trigger downstream work.
    - Make workers idempotent.
    - Use retries with backoff and a dead-letter path.
    - Track queue latency and failure rate.

    **Caching / performance:**
    - Cache read-heavy stable data.
    - Use pagination/cursor pagination for lists.
    - Measure cache hit rate.
    - Define invalidation rules before adding cache.

    **Security / permissions:**
    - Enforce tenant/project authorization in the backend.
    - Avoid leaking data through search, notifications, or cached responses.
    - Audit important state changes.
    - Use signed URLs for private file access.

    **Observability:**
    - p95/p99 endpoint latency.
    - Error rate.
    - DB query latency.
    - Queue latency.
    - Worker failures/retries.
    - Cache hit rate.
    - External API latency.
    - Trace important workflow spans.

    **Tradeoffs:**
    - Compliance audit vs product activity feed are different
- Same-transaction audit stronger but adds write cost
- Async audit scalable but can lose critical events unless outbox-backed

    **Common mistakes:**
    - Mutable audit rows
- No actor/request ID
- No tenant scope
- Sensitive values stored raw

    **Strong closing sentence:**  
    I would start with the simplest design that protects correctness and gives us observability, then evolve based on measured bottlenecks, team ownership, and product requirements.

    ---


## Core resources used / recommended

- Rails Guides — Active Record Query Interface: https://guides.rubyonrails.org/active_record_querying.html
- Rails Guides — Active Record Associations: https://guides.rubyonrails.org/association_basics.html
- Rails Guides — Active Record Validations: https://guides.rubyonrails.org/active_record_validations.html
- Rails Guides — Active Record Callbacks: https://guides.rubyonrails.org/active_record_callbacks.html
- Rails Guides — Active Record Migrations: https://guides.rubyonrails.org/active_record_migrations.html
- Rails Guides — Securing Rails Applications: https://guides.rubyonrails.org/security.html
- Rails Guides — Testing Rails Applications: https://guides.rubyonrails.org/testing.html
- Rails Guides — Active Job Basics: https://guides.rubyonrails.org/active_job_basics.html
- Rails Guides — Active Support Instrumentation: https://guides.rubyonrails.org/active_support_instrumentation.html
- OpenTelemetry Ruby instrumentation: https://opentelemetry.io/docs/languages/ruby/instrumentation/
- OpenTelemetry Ruby getting started: https://opentelemetry.io/docs/languages/ruby/getting-started/
- Ruby Fiber scheduler docs: https://docs.ruby-lang.org/en/3.4/fiber_md.html
- PostgreSQL EXPLAIN docs: https://www.postgresql.org/docs/current/sql-explain.html
- PostgreSQL using EXPLAIN: https://www.postgresql.org/docs/current/using-explain.html
