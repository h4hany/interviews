# Procore Staff Software Engineer — Architecture Interview Preparation

Prepared for: **Hany Sayed**  
Target role: **Staff Software Engineer - Ruby on Rails / Backend**  
Interview: **Architecture with Principal Software Engineer**

---

## 0. Research Summary: What Procore Is Likely Evaluating

Based on the Procore job description, the recruiter email, Glassdoor-style interview notes, Procore's public engineering interview guide, and Procore product/domain research, the architecture round is likely to evaluate whether you can:

1. Translate a business/Product Requirements Document (PRD) into a scalable design.
2. Ask strong clarification questions before designing.
3. Propose both **High-Level Design (HLD)** and **Low-Level Design (LLD)**.
4. Discuss tradeoffs, not just list technologies.
5. Include UX/product improvements.
6. Design around construction-domain workflows such as:
   - RFIs
   - Submittals
   - Documents/drawings
   - Tasks
   - Permissions
   - Project collaboration
   - Notifications
   - Audit logs
7. Communicate like a Staff Engineer:
   - clear assumptions
   - phased delivery
   - operational thinking
   - observability
   - reliability
   - team impact

### Research Signals

- Public Procore interview reports mention a System Design & Architecture round focused on PRD analysis, UX suggestions, low-level design, and high-level design.
- Procore's own engineering interview guide says architecture interviews test architecture skills, design patterns, problem breakdown, teamwork, discussion of tradeoffs, and asking questions.
- Procore Project Management officially includes scheduling, RFI tracking, submittals, and document management.
- Procore's RFI product/domain material emphasizes linking documents, drawings, specs, photos, and RFIs together to reduce miscommunication.
- Procore's developer platform exposes REST APIs, OAuth 2.0, API versioning, rate limits, pagination, and changelog/version lifecycle concepts. This suggests that platform extensibility and external integrations are important.

---

# 1. How to Structure Your Architecture Interview

Use this structure for almost any system design prompt.

## Step 1: Clarify the Product Requirements

Start with:

> Before jumping into architecture, I want to clarify the main users, workflows, scale, and constraints so I design the right system.

Ask questions around:

### Users
- Who are the users?
- Are they internal employees, contractors, subcontractors, project managers, field workers, admins, or external vendors?
- Do multiple companies collaborate on the same project?

### Workflow
- What is the core action?
- Is there an approval workflow?
- Are there status transitions?
- Are comments/attachments required?
- Are notifications required?

### Scale
- How many companies?
- How many projects per company?
- How many active users per project?
- How many records per project?
- Peak read/write volume?

### Consistency
- Which operations must be strongly consistent?
- Which can be eventually consistent?

### UX
- Does the UI need real-time updates?
- Does mobile/offline support matter?
- What filters/search capabilities are expected?

### Security
- What roles and permissions are needed?
- Are audit logs required?
- Are external integrations allowed?

---

## Step 2: State Assumptions

After asking questions, say:

> To move forward, I’ll make a few assumptions and we can adjust if needed.

Example:

- Multi-tenant SaaS system.
- Each company has many projects.
- Projects can include users from multiple companies.
- Most workflows are read-heavy.
- Core writes should be strongly consistent.
- Notifications/search/indexing can be eventually consistent.
- We need auditability because construction decisions can have contractual impact.

---

## Step 3: Define Functional Requirements

Example:

- Create/update/search resources.
- Assign users.
- Attach documents/photos.
- Track status transitions.
- Comment and mention users.
- Send notifications.
- Provide audit history.

---

## Step 4: Define Non-Functional Requirements

Example:

- High availability.
- Low latency for common operations.
- Strong authorization boundaries.
- Scalable reads.
- Reliable async processing.
- Observable system.
- Safe API evolution.
- Data retention and backup strategy.

---

## Step 5: Capacity Estimation

Do quick math.

Example:

If the system handles `30K requests/minute`:

```text
30,000 / 60 = 500 requests/second
```

If each app server handles `100 requests/second`:

```text
500 / 100 = 5 servers
Add 30-50% buffer => 7-8 servers
```

For storage:

```text
records_per_month * average_record_size = monthly_storage
```

Do not spend too long here. The goal is to show engineering judgment.

---

## Step 6: High-Level Design

Use a clean architecture:

```text
Web / Mobile Clients
        |
        v
Load Balancer / API Gateway
        |
        v
Rails Backend / Modular Monolith
        |
        +--> PostgreSQL
        +--> Redis
        +--> Sidekiq / Background Workers
        +--> S3 / Object Storage
        +--> Search Index
        +--> Event Bus / Outbox
        +--> Observability Platform
```

For Staff-level Procore answer:

> I would start with a modular monolith because Rails can scale well when domain boundaries are clean. I would extract services only when team ownership, deployment independence, or different scaling characteristics justify the operational complexity.

---

## Step 7: Low-Level Design

Mention:

- Rails controllers
- service objects
- models
- policies
- jobs
- serializers
- event/outbox records

Example:

```text
TasksController
Tasks::CreateService
TaskPolicy
Task
TaskAssignment
ActivityLog
NotificationJob
TaskSerializer
```

---

## Step 8: API Design

Show REST APIs:

```http
POST /projects/:project_id/tasks
GET /projects/:project_id/tasks
GET /tasks/:id
PATCH /tasks/:id
POST /tasks/:id/comments
POST /tasks/:id/attachments
GET /tasks/:id/activity
```

Mention:

- pagination
- filtering
- sorting
- idempotency keys for risky writes
- API versioning for external clients

---

## Step 9: Database Design

Show the main tables and relationships.

Mention indexes:

```text
INDEX(project_id, status)
INDEX(project_id, assignee_id)
INDEX(created_at)
INDEX(resource_type, resource_id)
```

For Procore:

- Always think `company_id` and `project_id`.
- Always enforce tenant isolation.
- Always include audit logs for important operations.

---

## Step 10: Async Processing

Move slow side effects out of request path:

- notifications
- search indexing
- document processing
- email delivery
- analytics
- OCR
- AI summary/extraction

Use:

```text
Outbox table -> worker -> event bus / queue
```

---

## Step 11: Caching

Use Redis for:

- permissions cache
- project metadata
- user sessions
- dashboard aggregates
- frequently used filters

Use CDN for:

- static assets
- document previews
- images

Mention cache invalidation clearly.

---

## Step 12: Observability

Mention:

- OpenTelemetry traces
- p95/p99 latency
- error rate
- throughput
- DB query time
- queue latency
- worker retries
- cache hit rate
- external API latency

Strong line:

> Metrics tell me something is wrong, traces tell me where it happened, and logs give me detailed context.

---

## Step 13: Security

Mention:

- OAuth/JWT/session auth
- RBAC + ABAC
- tenant isolation
- encrypted data in transit and at rest
- audit logs
- rate limiting
- input validation
- signed URLs for file access

---

## Step 14: Tradeoffs and Evolution

Always finish with tradeoffs:

- Monolith vs microservices.
- SQL vs NoSQL.
- Sync vs async.
- Strong consistency vs eventual consistency.
- Search index vs relational query.
- Simplicity now vs future extensibility.

Then say how you would evolve the system in phases.

---

# 2. Example 1 — Design an RFI Management System

## Prompt

Design a system for managing **Requests for Information (RFIs)** in construction projects.

An RFI is used when a contractor/subcontractor needs clarification about drawings, specs, schedules, or project conditions. Users should be able to create RFIs, attach documents/drawings/photos, assign reviewers, respond, approve/close RFIs, and notify stakeholders.

---

## System Capabilities

### RFI Management
- Create RFIs.
- Edit draft RFIs.
- Submit RFIs for review.
- Assign responsible reviewers.
- Add official responses.
- Change status: draft, open, under_review, answered, closed, rejected.
- Track due dates and overdue RFIs.

### Collaboration
- Comments.
- Mentions.
- Attachments.
- Link RFI to drawings, specs, tasks, and submittals.

### Notifications
- Notify assignee when RFI is submitted.
- Notify creator when answer is posted.
- Reminder before due date.
- Escalation when overdue.

### Search & Filtering
- Search by title, number, project, assignee, status, due date.
- Filter by overdue/open/closed.

### Audit & Compliance
- Track status changes.
- Track who answered and when.
- Keep historical records.

---

## Functional Requirements

- Create/update/search RFIs.
- Link documents/drawings/photos to an RFI.
- Assign reviewers.
- Support comments and official responses.
- Track status transitions.
- Notify stakeholders.
- Provide full audit history.
- Support external API access for integrations.

---

## Non-Functional Requirements

- Multi-tenant isolation by company/project.
- Low-latency reads for RFI lists.
- Strong consistency for status transitions and official answers.
- Eventual consistency for notifications/search indexing.
- High availability.
- Auditability.
- API versioning and rate limiting for external integrations.

---

## Clarifying Questions

I would ask:

1. Who can create RFIs? General contractor, subcontractor, project manager, architect?
2. Can multiple companies collaborate on the same RFI?
3. Is there only one official response or multiple?
4. Can an RFI be reopened after closure?
5. Are attachments required?
6. Do we need approval before the answer becomes official?
7. Do we need due dates and escalation rules?
8. Do we need offline mobile access?
9. What is the expected scale per project?
10. Do external systems need to create or sync RFIs via API?

---

## Assumptions

To move forward:

- Each company has many projects.
- Each project can have thousands of RFIs.
- RFIs are collaborative and may involve users from multiple companies.
- Official status changes must be strongly consistent.
- Notifications/search indexing can be async.
- We need audit logs because RFIs can affect project cost, schedule, and liability.

---

## Capacity Estimation

Assume:

- 10,000 companies.
- 50 active projects per company.
- 1,000 RFIs per project over project lifetime.
- Average RFI record: 5 KB.
- Average comments/metadata per RFI: 10 KB.
- Average attachments: 3 files per RFI, 2 MB each.
- Peak traffic: 30K requests/minute.

### Request Rate

```text
30,000 requests/minute / 60 = 500 requests/second
```

If each app server handles around 100 RPS:

```text
500 / 100 = 5 app servers
Add 50% buffer => 8 app servers
```

### Storage

RFI metadata:

```text
10,000 companies * 50 projects * 1,000 RFIs * 15 KB
= 7.5 TB metadata over lifetime
```

Attachments:

```text
10,000 * 50 * 1,000 * 3 * 2 MB
= 3 PB object storage over lifetime
```

This tells us:
- Metadata belongs in PostgreSQL.
- Attachments belong in object storage like S3.
- Old/closed project data needs retention/archival policies.

---

## High-Level Architecture

```text
Web / Mobile Client
        |
        v
Load Balancer / API Gateway
        |
        v
Rails Modular Monolith
        |
        +--> RFI Module
        +--> Document Module
        +--> Notification Module
        +--> Permission Module
        +--> Audit Module
        |
        +--> PostgreSQL
        +--> Redis
        +--> Sidekiq Workers
        +--> S3/Object Storage
        +--> Search Index
        +--> OpenTelemetry/APM
```

### Why Modular Monolith?

I would start with a modular Rails monolith because:
- RFIs, documents, permissions, notifications, and audit logs are closely related.
- Strong transaction boundaries are easier.
- Teams can move faster without distributed-system overhead.
- We can still enforce boundaries using modules/packages.

I would extract separate services only when:
- document processing scale becomes independent,
- search needs a separate specialized team,
- notification delivery needs independent scaling,
- API platform needs independent deployment.

---

## Low-Level Design

### Rails Components

```text
RfisController
Rfis::CreateService
Rfis::SubmitService
Rfis::RespondService
Rfis::CloseService
RfiPolicy
Rfi
RfiResponse
RfiAttachment
RfiComment
ActivityLog
NotificationJob
SearchIndexJob
```

### Flow: Create RFI

```text
Client sends POST /projects/:project_id/rfis
        |
Controller validates request shape
        |
Policy checks user can create RFI in project
        |
Rfis::CreateService opens DB transaction
        |
Create RFI
Create linked attachments metadata
Create activity log
Create outbox event: RfiCreated
        |
Return response
        |
Async workers send notifications and index search
```

---

## API Design

```http
POST /projects/:project_id/rfis
GET /projects/:project_id/rfis?status=open&assignee_id=123&page=1
GET /rfis/:id
PATCH /rfis/:id
POST /rfis/:id/submit
POST /rfis/:id/responses
POST /rfis/:id/comments
POST /rfis/:id/attachments/presign
POST /rfis/:id/attachments/complete
POST /rfis/:id/close
GET /rfis/:id/activity
```

### API Considerations

- Paginate list endpoints.
- Filter by status, assignee, due date.
- Use idempotency key for submit/respond operations.
- Use API versioning for external integrations.
- Rate-limit external API clients.

---

## Database Design

```text
companies
- id
- name

projects
- id
- company_id
- name

users
- id
- company_id
- email
- name

project_memberships
- id
- project_id
- user_id
- company_id
- role_id

rfis
- id
- project_id
- company_id
- number
- title
- question
- status
- created_by_id
- assigned_to_id
- due_date
- closed_at
- created_at
- updated_at

rfi_responses
- id
- rfi_id
- responder_id
- body
- official
- created_at

rfi_comments
- id
- rfi_id
- user_id
- body
- created_at

attachments
- id
- project_id
- resource_type
- resource_id
- file_name
- s3_key
- content_type
- file_size
- uploaded_by_id
- created_at

activity_logs
- id
- company_id
- project_id
- actor_id
- action
- resource_type
- resource_id
- metadata_json
- created_at

outbox_events
- id
- event_type
- aggregate_type
- aggregate_id
- payload_json
- status
- created_at
```

### Indexes

```text
rfis(project_id, status)
rfis(project_id, assigned_to_id)
rfis(project_id, due_date)
rfis(company_id, created_at)
attachments(resource_type, resource_id)
activity_logs(resource_type, resource_id)
outbox_events(status, created_at)
```

---

## Caching

Use Redis for:

- project membership/role cache
- RFI count by status for dashboard
- frequently accessed RFI lists
- notification unread counts

Cache invalidation:
- invalidate project RFI counts when RFI status changes.
- invalidate permission cache when roles/memberships change.

---

## Async Processing

Use Sidekiq/background jobs for:

- notifications
- attachment virus scanning
- document preview generation
- search indexing
- overdue reminders
- analytics events

Use Outbox Pattern:

```text
DB transaction writes RFI + outbox event
Worker reads outbox event
Worker publishes notification/search/audit side effects
```

This avoids losing events when the DB commit succeeds but event publishing fails.

---

## Search

Use PostgreSQL full-text search initially for:
- title
- question
- response body

Move to Elasticsearch/OpenSearch if:
- advanced filters grow,
- fuzzy search is required,
- cross-resource search is required,
- ranking becomes complex.

---

## UX Improvements

Suggest:

1. RFI dashboard with:
   - open
   - overdue
   - assigned to me
   - waiting for response
2. Timeline view showing all comments, responses, attachments, and status changes.
3. Quick link from RFI to related drawing/spec/submittal.
4. Clear status badges.
5. Due-date reminders and escalation.
6. Bulk export for project closeout.
7. Mobile-friendly creation from field with photo attachment.
8. Offline draft mode for jobsite usage.

Strong backend support for UX:
- pagination
- filtering
- saved views
- partial responses
- optimized APIs
- real-time updates for comments/status changes

---

## Monitoring & Observability

Track:

- RFI creation latency.
- RFI list p95/p99 latency.
- DB query duration.
- notification delivery success/failure.
- search indexing delay.
- attachment processing delay.
- overdue reminder job failures.
- permission check latency.

OpenTelemetry trace example:

```text
POST /projects/123/rfis
  RfisController#create
  Rfis::CreateService
  SQL INSERT rfis
  SQL INSERT activity_logs
  SQL INSERT outbox_events
  Sidekiq enqueue NotificationJob
```

---

## Security

- RBAC + project-level authorization.
- Tenant isolation by company/project.
- Signed URLs for attachments.
- Virus scan uploaded files.
- Audit every official answer/status change.
- Validate file type and size.
- Encrypt files at rest and in transit.
- Avoid putting sensitive data in logs/spans.

---

## Tradeoffs

### Strong Consistency vs Eventual Consistency

- RFI status and official response must be strongly consistent.
- Notifications/search indexing can be eventually consistent.

### Modular Monolith vs Microservices

- Modular monolith is simpler and safer initially.
- Services may be extracted later for document processing, notifications, or search.

### PostgreSQL vs Search Engine

- PostgreSQL is enough for initial search/filtering.
- Search engine becomes useful for full-text ranking and cross-project/global search.

---

## Summary Answer

I would design the RFI system as a multi-tenant Rails modular monolith backed by PostgreSQL for transactional data, S3 for attachments, Redis for cache, Sidekiq for async processing, and a search index when full-text requirements grow. Core RFI state transitions would be strongly consistent, while notifications, search indexing, reminders, and document processing would be eventually consistent through background jobs and an outbox pattern. I would pay special attention to project-level permissions, audit logs, attachment security, and UX features like overdue dashboards and links to drawings/specs.

---

# 3. Example 2 — Design a Document & Drawing Management System

## Prompt

Design a system where construction teams can upload, version, review, publish, search, and share project documents/drawings.

---

## System Capabilities

### Document Management
- Upload documents.
- Upload drawings.
- Organize by project/folder.
- Version documents.
- Publish or archive versions.
- Download/view documents.

### Drawing Management
- Upload drawing sheets.
- Extract sheet metadata.
- Support current drawing set.
- Prevent users from building from old revisions.
- Link drawings to RFIs, submittals, tasks, and punch items.

### Collaboration
- Comments.
- Markups.
- Mentions.
- Attach photos.
- Review/approval workflow.

### Search
- Search by name, number, discipline, version, text content.
- Filter by current/revision/archived.

### Security
- Role-based access.
- Signed file URLs.
- Audit download/publish/delete events.

---

## Functional Requirements

- Generate pre-signed upload URLs.
- Store document metadata.
- Upload large files directly to object storage.
- Create versions.
- Publish current version.
- Generate previews/thumbnails.
- Extract text/OCR when possible.
- Link document to project entities.
- Support permissions.
- Maintain audit trail.

---

## Non-Functional Requirements

- Support large files.
- Avoid sending large file payloads through Rails.
- Highly available file access.
- Strong consistency for version/publish metadata.
- Eventual consistency for OCR/search/preview generation.
- Scalable storage.
- Secure file access.
- Long-term archival.

---

## Clarifying Questions

1. What file types are supported? PDF, images, CAD, BIM?
2. What is maximum file size?
3. Do we need version history forever?
4. Can users restore old versions?
5. Is there an approval flow before publishing?
6. Do we need OCR/search inside documents?
7. Do drawings need sheet number extraction?
8. Do users need offline access on mobile?
9. Are documents shared with external collaborators?
10. Do we need legal/audit retention?

---

## Assumptions

- Files can be large.
- Users access documents frequently from field and office.
- The current published version matters.
- Old versions must be retained.
- Upload processing can happen asynchronously.
- Metadata must remain strongly consistent.

---

## Capacity Estimation

Assume:

- 10,000 companies.
- 50 projects per company.
- 50,000 documents/drawings per project over lifetime.
- Average file size: 2 MB.
- Metadata size: 2 KB.
- Peak traffic: 20K requests/minute.
- 10% of requests are downloads.

### Request Rate

```text
20,000 / 60 = 333 requests/second
```

### Metadata Storage

```text
10,000 * 50 * 50,000 * 2 KB
= 50 TB metadata over lifetime
```

### File Storage

```text
10,000 * 50 * 50,000 * 2 MB
= 50 PB object storage over lifetime
```

This confirms:
- metadata needs careful partitioning/indexing/archival,
- binary files belong in object storage,
- CDN is important for previews/downloads.

---

## High-Level Architecture

```text
Web / Mobile Client
        |
        v
API Gateway / Load Balancer
        |
        v
Rails Backend / Document Module
        |
        +--> PostgreSQL metadata
        +--> S3/Object Storage files
        +--> CDN for previews/downloads
        +--> Redis for metadata cache
        +--> Sidekiq processing workers
        +--> Search Index
        +--> OCR/Preview service
        +--> Observability
```

---

## Upload Flow

```text
Client requests upload URL
        |
Rails validates permission and creates pending document_version
        |
Rails returns pre-signed S3 URL
        |
Client uploads directly to S3
        |
Client calls complete-upload endpoint
        |
Rails marks version uploaded
        |
Background jobs process file
```

Why direct-to-S3?

- Avoids Rails memory pressure.
- Supports large files.
- Scales upload throughput better.
- Reduces app server load.

---

## Low-Level Design

```text
DocumentsController
DocumentVersionsController
Documents::CreateUploadService
Documents::CompleteUploadService
Documents::PublishVersionService
DocumentPolicy
Document
DocumentVersion
DocumentLink
DocumentMarkup
DocumentComment
PreviewGenerationJob
OcrExtractionJob
SearchIndexJob
```

---

## API Design

```http
POST /projects/:project_id/documents/presign
POST /projects/:project_id/documents/complete
GET /projects/:project_id/documents?folder_id=123&page=1
GET /documents/:id
GET /documents/:id/versions
POST /documents/:id/versions/presign
POST /documents/:id/versions/complete
POST /documents/:id/publish
POST /documents/:id/comments
POST /documents/:id/links
GET /documents/:id/activity
```

---

## Database Design

```text
documents
- id
- company_id
- project_id
- folder_id
- name
- document_type
- current_version_id
- status
- created_by_id
- created_at
- updated_at

document_versions
- id
- document_id
- version_number
- s3_key
- checksum
- file_size
- content_type
- status
- uploaded_by_id
- published_at
- created_at

document_links
- id
- document_id
- linked_resource_type
- linked_resource_id

document_comments
- id
- document_id
- user_id
- body
- created_at

document_markups
- id
- document_version_id
- user_id
- markup_json
- created_at
```

### Indexes

```text
documents(project_id, folder_id)
documents(project_id, status)
documents(project_id, current_version_id)
document_versions(document_id, version_number)
document_links(linked_resource_type, linked_resource_id)
```

---

## Search

Initial:
- PostgreSQL full-text search on document names and metadata.

Advanced:
- OpenSearch/Elasticsearch for:
  - OCR text
  - drawing numbers
  - specs
  - cross-resource project search
  - relevance ranking

---

## Caching

Use Redis for:

- folder tree cache
- current version metadata
- permission cache
- recent documents per project

Use CDN for:

- thumbnails
- previews
- frequently accessed files

---

## Async Processing

Workers:

```text
VirusScanJob
PreviewGenerationJob
ThumbnailGenerationJob
OcrExtractionJob
SearchIndexJob
DocumentPublishedNotificationJob
```

Processing states:

```text
pending_upload -> uploaded -> processing -> ready -> failed
```

---

## UX Improvements

1. Show the current published version clearly.
2. Warn users if they are viewing an outdated revision.
3. Provide drawing/document links from RFI/task/submittal pages.
4. Preview before download.
5. Bulk upload with progress.
6. Search inside drawings/specs using OCR.
7. Mobile quick access to recently viewed drawings.
8. Offline cache for field users.
9. Activity timeline for document changes.
10. Clear permissions/error messages.

---

## Monitoring & Observability

Track:

- upload presign latency
- upload completion errors
- processing job latency
- failed OCR/preview jobs
- download rate
- signed URL generation failures
- search indexing lag
- file storage cost growth

---

## Security

- Pre-signed URLs with short TTL.
- Validate content type and file size.
- Virus scanning.
- Access checks before generating signed download URLs.
- Encrypt files at rest.
- Audit upload/download/delete/publish events.
- Avoid public buckets.

---

## Tradeoffs

### Synchronous Upload vs Direct Object Storage Upload

Direct upload is more complex but more scalable.

### Store Files in DB vs Object Storage

Object storage is better for binary files. DB stores metadata only.

### Immediate Search vs Async Indexing

Async indexing gives better write performance but search results may lag.

### Keep All Versions vs Retention Policy

Keeping all versions improves auditability but increases storage cost.

---

## Summary Answer

I would design document management with Rails managing metadata and permissions, S3/object storage handling file content, direct client uploads via pre-signed URLs, background workers for virus scanning/OCR/previews, and a search index for document discovery. The current published version would be strongly consistent in PostgreSQL, while OCR, thumbnails, and search indexing would be async. I would focus heavily on permissions, audit logs, version correctness, and UX warnings to prevent teams from using outdated drawings.

---

# 4. Example 3 — Design a Project Task / Punch List System

## Prompt

Design a task management or punch list system for construction projects where users can create tasks, assign them, track status, attach photos, comment, and notify stakeholders.

---

## System Capabilities

### Task Management
- Create/update/delete tasks.
- Assign tasks to users/companies.
- Set priority and due date.
- Track status: open, in_progress, blocked, completed, verified, closed.

### Collaboration
- Comments.
- Mentions.
- Attachments/photos.
- Activity history.

### Workflow
- Assignment.
- Completion.
- Verification.
- Reopen.
- Escalation.

### Dashboard
- Tasks assigned to me.
- Overdue tasks.
- Tasks by company.
- Tasks by project/location/status.

### Notifications
- Assignment notification.
- Due date reminder.
- Completion notification.
- Comment/mention notification.

---

## Functional Requirements

- Create tasks.
- Assign users.
- Add comments/attachments.
- Search/filter tasks.
- Track status transitions.
- Notify relevant stakeholders.
- Maintain audit trail.
- Support mobile field usage.

---

## Non-Functional Requirements

- Low-latency task list.
- Strong consistency for task status and assignments.
- Eventual consistency for notifications/search.
- Multi-tenant access control.
- High availability.
- Scalable reads.
- Observability.

---

## Clarifying Questions

1. Can a task have multiple assignees?
2. Are assignees users or companies?
3. Is task verification required before closing?
4. Do tasks belong to locations/areas?
5. Are attachments/photos required?
6. Do we need recurring tasks?
7. Are dependencies between tasks required?
8. Should users receive real-time updates?
9. Do we need mobile/offline support?
10. What scale per project should we support?

---

## Assumptions

- Each task belongs to one project.
- Each task can have multiple assignees.
- Tasks are heavily read by dashboards/mobile views.
- Status transitions should be strongly consistent.
- Notifications and search indexing can be async.
- Attachments are stored in object storage.

---

## Capacity Estimation

Assume:

- 10,000 companies.
- 50 active projects per company.
- 20,000 tasks per project.
- Average task metadata: 4 KB.
- Average comments/activity: 6 KB.
- Average attachments: 2 photos per task, 500 KB each.
- Peak: 40K requests/minute.

### Request Rate

```text
40,000 / 60 = 667 requests/second
```

If each app instance handles 100 RPS:

```text
667 / 100 = 6.67
Add buffer => 10 app instances
```

### Metadata Storage

```text
10,000 * 50 * 20,000 * 10 KB
= 100 TB metadata over lifetime
```

### Attachment Storage

```text
10,000 * 50 * 20,000 * 2 * 500 KB
= 10 PB object storage over lifetime
```

---

## High-Level Architecture

```text
Web / Mobile Clients
        |
        v
API Gateway / Load Balancer
        |
        v
Rails Modular Monolith
        |
        +--> Task Module
        +--> Comment Module
        +--> Attachment Module
        +--> Notification Module
        +--> Permission Module
        +--> Audit Module
        |
        +--> PostgreSQL
        +--> Redis
        +--> Sidekiq Workers
        +--> S3/Object Storage
        +--> Search Index
        +--> Observability
```

---

## Low-Level Design

```text
TasksController
Tasks::CreateService
Tasks::AssignService
Tasks::ChangeStatusService
TaskPolicy
Task
TaskAssignment
TaskComment
Attachment
ActivityLog
NotificationJob
SearchIndexJob
TaskSerializer
```

### Task Creation Flow

```text
POST /projects/:project_id/tasks
        |
Authorize user
        |
Validate input
        |
DB transaction:
  create task
  create assignments
  create activity log
  create outbox event
        |
Return task response
        |
Async:
  send notifications
  update search index
  update dashboard counters
```

---

## API Design

```http
POST /projects/:project_id/tasks
GET /projects/:project_id/tasks?status=open&assignee_id=123&page=1
GET /tasks/:id
PATCH /tasks/:id
POST /tasks/:id/assignments
DELETE /tasks/:id/assignments/:assignment_id
POST /tasks/:id/comments
POST /tasks/:id/attachments/presign
POST /tasks/:id/status
GET /tasks/:id/activity
```

### API Enhancements

- Pagination.
- Filtering.
- Sorting by due date/priority.
- Sparse fields for mobile.
- Idempotency key for create task if client retries.
- Versioned APIs for external clients.

---

## Database Design

```text
tasks
- id
- company_id
- project_id
- title
- description
- status
- priority
- location_id
- created_by_id
- due_date
- completed_at
- verified_at
- created_at
- updated_at

task_assignments
- id
- task_id
- user_id
- company_id
- assigned_by_id
- created_at

task_comments
- id
- task_id
- user_id
- body
- created_at

attachments
- id
- project_id
- resource_type
- resource_id
- s3_key
- file_name
- content_type
- file_size
- uploaded_by_id
- created_at

activity_logs
- id
- company_id
- project_id
- actor_id
- action
- resource_type
- resource_id
- metadata_json
- created_at
```

### Indexes

```text
tasks(project_id, status)
tasks(project_id, due_date)
tasks(project_id, location_id)
task_assignments(user_id, task_id)
task_assignments(task_id)
activity_logs(resource_type, resource_id)
```

---

## Caching

Use Redis for:

- dashboard counts
- assigned-to-me task counts
- permission checks
- project metadata
- task list cache for common filters

Be careful:
- task list caches must be invalidated when status/assignment changes.

---

## Async Processing

Use workers for:

- notifications
- attachment processing
- search indexing
- overdue reminders
- dashboard aggregate updates
- analytics events

---

## UX Improvements

1. Saved views: “Assigned to me”, “Overdue”, “Blocked”.
2. Bulk update task status.
3. Drag-and-drop status board.
4. Mobile photo-first task creation.
5. Offline drafts on mobile.
6. Clear due date indicators.
7. Activity timeline.
8. Real-time updates for comments/status.
9. Smart notifications instead of noisy notifications.

---

## Monitoring & Observability

Track:

- task creation latency
- task list p95/p99 latency
- DB query count per task list
- N+1 query detection
- notification delay
- overdue job reliability
- queue latency
- cache hit rate
- error rate by endpoint

---

## Security

- Project-level authorization.
- Users can only view tasks in projects they belong to.
- Attachments require signed URLs.
- Audit important status changes.
- Enforce tenant scoping at query level.
- Avoid leaking project IDs across tenants.

---

## Tradeoffs

### Denormalized Dashboard Counters

Good:
- Fast dashboard.

Bad:
- Must maintain consistency.

Solution:
- Async aggregate updates + periodic reconciliation.

### Real-Time Updates

WebSockets improve UX but add operational complexity.

Start with polling/refresh and introduce WebSockets where collaboration value is high.

### Search Index

PostgreSQL is enough initially; search index helps at scale.

---

## Summary Answer

I would design the task system as a Rails modular monolith with PostgreSQL for tasks/assignments/statuses, Redis for fast dashboard counts and permission cache, Sidekiq for notifications and overdue reminders, S3 for photo attachments, and search indexing when filtering/search becomes advanced. I would make status transitions and assignments strongly consistent, while notifications and search updates can be eventual. The design should emphasize project-level permissions, audit history, mobile-friendly APIs, and observability around slow task lists and background job delays.

---

# 5. Example 4 — Design a Notification System for Procore Project Collaboration

## Prompt

Design a notification system for project events: task assignment, RFI response, document published, comment mention, overdue item, and approval request.

---

## System Capabilities

- In-app notifications.
- Email notifications.
- Push notifications.
- User preferences.
- Read/unread state.
- Notification grouping/digests.
- Retry failed deliveries.
- Avoid duplicate notifications.
- Support project/company context.

---

## Functional Requirements

- Create notification from domain events.
- Deliver via multiple channels.
- Store in-app notifications.
- Mark as read/unread.
- Respect user preferences.
- Retry failed deliveries.
- Support notification templates.
- Support audit/debugging of delivery attempts.

---

## Non-Functional Requirements

- High throughput.
- Eventual consistency is acceptable.
- Idempotent processing.
- Low-latency in-app notification display.
- Reliable delivery.
- Observability around failures and delays.

---

## Clarifying Questions

1. Which channels are required: in-app, email, push, SMS?
2. Are notifications real-time?
3. Do users have preferences per project/event/channel?
4. Do we need digest emails?
5. Should notifications be grouped?
6. What is the expected event volume?
7. Are there compliance requirements for delivery records?
8. Should external integrations receive webhooks?

---

## Assumptions

- Notifications are generated from business events.
- Notification delivery does not block the main user workflow.
- In-app notifications are stored.
- Email/push delivery can retry.
- Duplicate notifications are bad UX and should be prevented.

---

## Capacity Estimation

Assume:

- 50K project events/minute during peak.
- Each event may notify 3 users on average.
- Notification payload: 1 KB.
- Delivery attempt log: 1 KB.

```text
50K events/min * 3 recipients = 150K notifications/min
150K / 60 = 2,500 notifications/second
```

Storage per day:

```text
150K/min * 60 * 24 * 2 KB = 432 GB/day
```

This suggests:
- notification retention policies are important,
- delivery logs should be archived,
- queues/workers must scale independently.

---

## High-Level Architecture

```text
Domain Modules
(Task/RFI/Document/Comment)
        |
        v
Outbox Events
        |
        v
Notification Dispatcher
        |
        +--> In-App Notification Store
        +--> Email Queue
        +--> Push Queue
        +--> Digest Queue
        |
        v
Notification Providers
```

---

## Low-Level Design

```text
NotificationEventsConsumer
NotificationDispatcher
NotificationPreferenceService
NotificationTemplateRenderer
EmailNotificationJob
PushNotificationJob
DigestNotificationJob
Notification
NotificationDelivery
```

---

## API Design

```http
GET /notifications?status=unread&page=1
POST /notifications/:id/read
POST /notifications/read_all
GET /notification_preferences
PATCH /notification_preferences
```

For internal event creation:

```text
TaskAssigned
RfiAnswered
DocumentPublished
CommentMentioned
ItemOverdue
```

---

## Database Design

```text
notifications
- id
- company_id
- project_id
- recipient_id
- actor_id
- event_type
- resource_type
- resource_id
- title
- body
- read_at
- created_at

notification_deliveries
- id
- notification_id
- channel
- status
- provider_message_id
- error_message
- attempted_at

notification_preferences
- id
- user_id
- project_id
- event_type
- channel
- enabled
```

### Idempotency

Use a deduplication key:

```text
recipient_id + event_type + resource_type + resource_id + event_version
```

Store it as a unique index.

---

## Caching

Use Redis for:

- unread count
- user preferences
- rate limiting
- temporary dedupe keys

---

## Async Processing

Every delivery channel has its own queue:

```text
critical_notifications
email_notifications
push_notifications
digest_notifications
webhook_notifications
```

This prevents email slowness from blocking in-app notifications.

---

## UX Improvements

1. Group repeated notifications.
2. Allow per-project preferences.
3. Show clear notification source/project.
4. Support “mute project”.
5. Provide digest options.
6. Avoid sending both mention and comment notification if they refer to same event.
7. Deep link notification to the exact RFI/task/document.

---

## Monitoring & Observability

Track:

- notification creation rate
- delivery success rate by channel
- provider failures
- queue latency
- retry count
- unread count cache failures
- duplicate suppression rate
- digest processing time

---

## Security

- Notification access scoped by recipient.
- Do not expose data from projects user cannot access.
- Validate authorization when user opens linked resource.
- Avoid sensitive content in push/email if project confidentiality matters.

---

## Tradeoffs

### Immediate Delivery vs Digest

Immediate delivery improves responsiveness but can create noise. Digest improves UX but delays awareness.

### Single Queue vs Multiple Queues

Multiple queues add complexity but improve isolation and prioritization.

### Store Full Message vs Render on Read

Storing full message is faster and preserves history. Rendering on read keeps content fresh but can change historical meaning.

---

## Summary Answer

I would design notifications as an event-driven subsystem. Core business actions write outbox events, and notification workers asynchronously create in-app records and deliver email/push messages. I would make notification jobs idempotent, support preferences and deduplication, isolate channels with separate queues, and monitor delivery latency and failure rates. This keeps the core product workflow fast while still giving users reliable project collaboration updates.

---

# 6. Example 5 — Design a Permission and Audit System for Multi-Company Project Collaboration

## Prompt

Design a permission system for a platform where owners, general contractors, subcontractors, architects, and vendors collaborate on the same construction project.

---

## System Capabilities

- Company-level roles.
- Project-level roles.
- Resource-level permissions.
- External collaborators.
- Permission inheritance.
- Audit logs.
- Secure API access.
- Support permission checks across tasks, RFIs, documents, and submittals.

---

## Functional Requirements

- Add/remove project members.
- Assign roles.
- Define permissions.
- Check access before actions.
- Audit sensitive actions.
- Support custom roles.
- Support company/project/resource scoping.
- Cache permissions safely.

---

## Non-Functional Requirements

- Very fast permission checks.
- Strong tenant isolation.
- Consistent role changes.
- Auditable access.
- Secure by default.
- Scalable for large projects.

---

## Clarifying Questions

1. Are roles fixed or customer-defined?
2. Are permissions company-level, project-level, or resource-level?
3. Can external users belong to multiple companies/projects?
4. Do permissions inherit from company to project?
5. Are there private documents/tasks within a project?
6. Do API integrations need scoped permissions?
7. Do role changes take effect immediately?
8. Do we need audit logs for read access or only writes?

---

## Assumptions

- Users can belong to multiple projects.
- Users may collaborate across company boundaries.
- Most permissions are project-scoped.
- Some resources may need resource-level restrictions.
- Permission checks happen on almost every request.
- Role changes should take effect quickly.

---

## Capacity Estimation

Assume:

- 10,000 companies.
- 50 projects per company.
- 200 users per project.
- 100 permission checks per user session/hour.

Project memberships:

```text
10,000 * 50 * 200 = 100M memberships
```

Permission checks/hour:

```text
active_users * 100 checks/hour
```

This tells us:
- permissions need strong indexing,
- role permissions should be cached,
- membership lookup must be efficient.

---

## High-Level Architecture

```text
Client
  |
  v
Rails API
  |
  +--> Authentication
  +--> Authorization Layer
  +--> Policy Objects
  +--> Permission Cache
  +--> PostgreSQL Roles/Memberships
  +--> Audit Log
```

---

## Low-Level Design

```text
ProjectMembership
Role
Permission
RolePermission
Policy Objects
PermissionResolver
PermissionCache
AuditLogger
```

Example Rails policy:

```ruby
class RfiPolicy
  def update?
    user_member_of_project? &&
      permission?(:update_rfi) &&
      !record.closed?
  end
end
```

---

## API Design

```http
GET /projects/:project_id/members
POST /projects/:project_id/members
PATCH /projects/:project_id/members/:id/role
DELETE /projects/:project_id/members/:id
GET /roles
POST /roles
PATCH /roles/:id
GET /permissions
GET /audit_logs?project_id=123&resource_type=RFI
```

---

## Database Design

```text
users
- id
- company_id
- email
- name

companies
- id
- name

projects
- id
- company_id
- name

roles
- id
- company_id
- name
- scope

permissions
- id
- key
- description

role_permissions
- role_id
- permission_id

project_memberships
- id
- project_id
- user_id
- company_id
- role_id
- status

resource_permissions
- id
- resource_type
- resource_id
- user_id
- permission_key

audit_logs
- id
- company_id
- project_id
- actor_id
- action
- resource_type
- resource_id
- metadata_json
- created_at
```

### Indexes

```text
project_memberships(project_id, user_id)
project_memberships(user_id, project_id)
role_permissions(role_id)
resource_permissions(resource_type, resource_id, user_id)
audit_logs(project_id, created_at)
```

---

## Caching

Cache:

```text
user_id + project_id -> role/permissions
```

Invalidate when:

- user role changes,
- user removed from project,
- role permission changes,
- project archived.

Important:

> Permission cache must be designed to fail closed, not fail open.

If cache is unavailable, fall back to DB or deny risky operations.

---

## Audit Strategy

Audit important actions:

- role changes
- member added/removed
- document published/deleted
- RFI official response
- task closed/reopened
- permission changes

For critical actions:
- write audit log in same transaction.

For lower-risk analytics:
- emit async event.

---

## UX Improvements

1. Explain why access is denied.
2. Show “request access” workflow.
3. Role preview: show what each role can do.
4. Audit timeline for admins.
5. Bulk member import.
6. Permission templates by company/project type.
7. Warn when removing last admin.

---

## Monitoring & Observability

Track:

- permission check latency.
- permission cache hit rate.
- denied requests by endpoint.
- role update errors.
- audit log write failures.
- suspicious access attempts.

---

## Security

- Server-side authorization on every endpoint.
- Tenant scoping in every query.
- Avoid relying on frontend hiding buttons.
- Audit sensitive writes.
- Use least privilege for API integrations.
- Rate-limit membership/role endpoints.

---

## Tradeoffs

### RBAC vs ABAC

RBAC is simpler and easier to explain.

ABAC is more flexible for conditions like:
- project status,
- company relationship,
- resource state,
- ownership.

Best solution:
- RBAC for standard permissions,
- ABAC for contextual rules.

### Cache vs Freshness

Caching improves performance but can cause stale access. Invalidate aggressively on role changes.

### Custom Roles vs Fixed Roles

Custom roles give flexibility but increase complexity. Start with fixed roles and add custom roles when needed.

---

## Summary Answer

I would design permissions using RBAC plus contextual ABAC rules. PostgreSQL stores users, roles, project memberships, permissions, and audit logs. Rails policy objects enforce authorization consistently across controllers/services. Redis caches frequently used permission lookups, with strict invalidation and fail-closed behavior. Critical permission changes and sensitive project actions are audited in the same transaction. This approach gives Procore-style multi-company collaboration while protecting tenant boundaries and keeping permission checks fast.

---

# 7. Fast Interview Checklist

Before answering any architecture question, remember this checklist:

```text
1. Clarify users and workflow
2. State assumptions
3. Define functional requirements
4. Define non-functional requirements
5. Estimate scale
6. Draw high-level architecture
7. Define APIs
8. Define database schema
9. Discuss async processing
10. Discuss caching
11. Discuss security/permissions
12. Discuss observability
13. Discuss tradeoffs
14. Suggest UX improvements
15. Explain phased rollout
```

---

# 8. Staff-Level Phrases You Can Use

## When choosing modular monolith

> I would start with a modular monolith because the domain boundaries are still closely related, and keeping transactional consistency simple is valuable. I would extract services later only when team ownership, deployment independence, or different scaling requirements justify the operational complexity.

## When discussing tradeoffs

> I would not treat this as a purely technical choice. The decision depends on scale, team ownership, operational maturity, and how quickly the product needs to evolve.

## When discussing async work

> I would keep the user-facing transaction small and move side effects like notifications, indexing, and analytics to background jobs.

## When discussing observability

> I want every critical workflow to be traceable end-to-end, from controller to database to background jobs, so we can debug production issues quickly.

## When discussing UX

> From the backend side, I would support this UX through fast filtering, pagination, saved views, and APIs that do not force the frontend to load too much data.

## When discussing security

> In a multi-tenant construction platform, authorization is not a frontend concern. Every backend endpoint must enforce tenant and project-level permissions.

---

# 9. Strong Questions to Ask the Architecture Interviewer

Ask one or two near the end.

1. At Procore scale, what are the biggest architecture challenges for the Project Management team today: domain boundaries, performance, developer velocity, or platform extensibility?

2. When Procore builds new platform capabilities, how do teams decide whether to keep them in the Rails monolith or extract them into separate services?

3. How do Staff and Principal Engineers at Procore balance short-term customer delivery with long-term architecture direction?

4. What does great architecture ownership look like for a Staff Engineer on this team?

5. Are most architecture challenges today around product scale, integration scale, or internal engineering productivity?

---

# 10. One-Minute Opening Answer for the Architecture Interview

If the interviewer asks, “How do you approach system design?” say:

> I usually start by clarifying the product requirements, users, scale, and consistency needs before jumping into components. Then I define the core entities and workflows, sketch the high-level architecture, and go deeper into APIs, database design, async processing, caching, permissions, and observability. I also like to call out tradeoffs explicitly, because for Staff-level architecture the hard part is rarely choosing a technology; it is choosing the right level of complexity for the business problem and team maturity.

---

# 11. Final Advice for Your Procore Architecture Round

For Procore, always include these concepts when relevant:

- `company_id`
- `project_id`
- project membership
- role/permission checks
- audit logs
- document attachments
- async notifications
- background processing
- API versioning/rate limits
- mobile/field UX
- real-time visibility when useful
- observability with traces/metrics/logs

The interviewer is likely looking for a collaborative Staff Engineer, not someone who memorized one architecture. Ask questions, make assumptions, explain tradeoffs, and evolve the design step by step.
