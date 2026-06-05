# Procore Staff Backend Interview Guide

## Focus Areas Covered

This guide summarizes and expands the topics discussed:

1. Staff-level backend interview question for a task management service.
2. Database schema design for a task management system.
3. REST API design for task management.
4. Staff-level backend concerns: authorization, scalability, concurrency, observability, and maintainability.
5. How to investigate and react to a traffic dip.
6. Common types of security attacks every backend/Rails engineer should know.

---

# 1. Likely Backend Interview Question

## Interview Prompt

Design the backend for a **Task Management Service** used by a construction SaaS platform.

Companies use the system to manage work across construction projects. A project can have many tasks. Tasks may be assigned to users, have due dates, statuses, priorities, comments, attachments, dependencies, and audit history.

The service should support:

- Creating, updating, assigning, and completing tasks.
- Listing tasks by project, assignee, status, due date, and priority.
- Supporting task dependencies.
- Supporting comments and activity history.
- Supporting permissions so users only access tasks for companies/projects they belong to.
- Sending notifications when a task is assigned, due soon, overdue, or completed.
- Scaling to many companies, projects, users, and tasks.
- Exposing clean REST APIs.
- Handling concurrency, idempotency, and auditability.
- Being maintainable inside a large Rails/modular-monolith or service-oriented backend.

---

# 2. How to Approach the Question

A Staff Engineer should not jump directly into tables. Start with clarification, assumptions, then design.

## Good Interview Structure

1. Clarify requirements.
2. Define assumptions.
3. Identify core entities.
4. Design the database schema.
5. Add constraints and indexes.
6. Design API endpoints.
7. Explain authorization.
8. Explain concurrency and idempotency.
9. Explain async jobs/events.
10. Explain scalability and observability.
11. Discuss tradeoffs.

---

# 3. Clarifying Questions

Ask questions like:

- Is a task always inside a project?
- Can a task have one assignee or multiple assignees?
- Do we need subtasks?
- Do we need recurring tasks?
- Do tasks need comments and attachments?
- Are permissions company-based or project-based?
- Do we need real-time updates?
- Is this system internal-only or customer-facing?
- What scale are we expecting?
- Do we need audit history for compliance?

## Reasonable Assumptions

You can say:

> I will assume this is a multi-tenant B2B SaaS system. Companies have projects, projects have tasks, users belong to companies and projects, and tasks can have multiple assignees, dependencies, comments, attachments, notifications, and audit logs.

---

# 4. Core Entities

The main entities are:

- Company
- User
- Project
- Project Membership
- Task
- Task Assignee
- Task Dependency
- Task Comment
- Task Attachment
- Task Activity Log
- Notification
- Idempotency Key

---

# 5. Database Schema Design

## 5.1 companies

```sql
companies
---------
id UUID PRIMARY KEY
name VARCHAR NOT NULL
created_at TIMESTAMP NOT NULL
updated_at TIMESTAMP NOT NULL
```

### Why?

This is a B2B SaaS system. Most data should be tenant-scoped by company.

---

## 5.2 users

```sql
users
-----
id UUID PRIMARY KEY
company_id UUID NOT NULL REFERENCES companies(id)
email VARCHAR NOT NULL
first_name VARCHAR
last_name VARCHAR
status VARCHAR NOT NULL -- active, invited, disabled
created_at TIMESTAMP NOT NULL
updated_at TIMESTAMP NOT NULL

UNIQUE(company_id, email)
```

### Indexes

```sql
CREATE INDEX idx_users_company_id ON users(company_id);
```

### Notes

The same email might exist in different companies depending on product rules, but inside one company it should be unique.

---

## 5.3 projects

```sql
projects
--------
id UUID PRIMARY KEY
company_id UUID NOT NULL REFERENCES companies(id)
name VARCHAR NOT NULL
status VARCHAR NOT NULL -- active, archived
created_at TIMESTAMP NOT NULL
updated_at TIMESTAMP NOT NULL
```

### Indexes

```sql
CREATE INDEX idx_projects_company_id ON projects(company_id);
```

---

## 5.4 project_memberships

```sql
project_memberships
-------------------
id UUID PRIMARY KEY
project_id UUID NOT NULL REFERENCES projects(id)
user_id UUID NOT NULL REFERENCES users(id)
role VARCHAR NOT NULL -- admin, manager, member, viewer
created_at TIMESTAMP NOT NULL
updated_at TIMESTAMP NOT NULL

UNIQUE(project_id, user_id)
```

### Why?

Not every user in a company should automatically access every project. Project membership gives us project-level access control.

---

## 5.5 tasks

```sql
tasks
-----
id UUID PRIMARY KEY
company_id UUID NOT NULL REFERENCES companies(id)
project_id UUID NOT NULL REFERENCES projects(id)
created_by_id UUID NOT NULL REFERENCES users(id)
title VARCHAR NOT NULL
description TEXT
status VARCHAR NOT NULL -- todo, in_progress, blocked, done, archived
priority VARCHAR NOT NULL -- low, medium, high, urgent
due_date DATE
started_at TIMESTAMP
completed_at TIMESTAMP
lock_version INTEGER NOT NULL DEFAULT 0
deleted_at TIMESTAMP
created_at TIMESTAMP NOT NULL
updated_at TIMESTAMP NOT NULL
```

### Important Indexes

```sql
CREATE INDEX idx_tasks_company_project ON tasks(company_id, project_id);
CREATE INDEX idx_tasks_project_status ON tasks(project_id, status);
CREATE INDEX idx_tasks_project_due_date ON tasks(project_id, due_date);
CREATE INDEX idx_tasks_company_status_due_date ON tasks(company_id, status, due_date);
CREATE INDEX idx_tasks_created_by ON tasks(created_by_id);
CREATE INDEX idx_tasks_deleted_at ON tasks(deleted_at);
```

### Staff-Level Notes

- Keep `company_id` on `tasks` even though it can be reached through `project_id`. This improves tenant-scoped queries and authorization safety.
- Use `lock_version` for optimistic locking.
- Use `deleted_at` if the business needs soft deletion.
- Avoid loading all tasks without pagination.

---

## 5.6 task_assignees

```sql
task_assignees
--------------
id UUID PRIMARY KEY
task_id UUID NOT NULL REFERENCES tasks(id)
user_id UUID NOT NULL REFERENCES users(id)
assigned_by_id UUID NOT NULL REFERENCES users(id)
assigned_at TIMESTAMP NOT NULL
created_at TIMESTAMP NOT NULL
updated_at TIMESTAMP NOT NULL

UNIQUE(task_id, user_id)
```

### Indexes

```sql
CREATE INDEX idx_task_assignees_task_id ON task_assignees(task_id);
CREATE INDEX idx_task_assignees_user_id ON task_assignees(user_id);
```

### Why not put `assignee_id` directly on `tasks`?

Because requirements often evolve. Today the system may support one assignee, but later it may need multiple assignees, watchers, collaborators, reviewers, or accountable/responsible users. A join table is more flexible.

---

## 5.7 task_dependencies

```sql
task_dependencies
-----------------
id UUID PRIMARY KEY
task_id UUID NOT NULL REFERENCES tasks(id)
depends_on_task_id UUID NOT NULL REFERENCES tasks(id)
created_by_id UUID NOT NULL REFERENCES users(id)
created_at TIMESTAMP NOT NULL

UNIQUE(task_id, depends_on_task_id)
CHECK(task_id <> depends_on_task_id)
```

### Meaning

```text
task_id depends on depends_on_task_id
```

Example:

```text
Install drywall depends on Complete framing inspection.
```

### Indexes

```sql
CREATE INDEX idx_task_dependencies_task_id ON task_dependencies(task_id);
CREATE INDEX idx_task_dependencies_depends_on ON task_dependencies(depends_on_task_id);
```

### Staff-Level Concern: Cycle Prevention

Invalid dependency example:

```text
Task A depends on Task B
Task B depends on Task C
Task C depends on Task A
```

This creates a cycle.

To prevent this:

- Check that a task does not depend on itself.
- Ensure both tasks belong to the same project/company.
- Before inserting a dependency, perform graph traversal or a recursive SQL query to detect if the new dependency would create a cycle.

---

## 5.8 task_comments

```sql
task_comments
-------------
id UUID PRIMARY KEY
task_id UUID NOT NULL REFERENCES tasks(id)
user_id UUID NOT NULL REFERENCES users(id)
body TEXT NOT NULL
created_at TIMESTAMP NOT NULL
updated_at TIMESTAMP NOT NULL
deleted_at TIMESTAMP
```

### Indexes

```sql
CREATE INDEX idx_task_comments_task_id_created_at
ON task_comments(task_id, created_at);
```

---

## 5.9 task_attachments

```sql
task_attachments
----------------
id UUID PRIMARY KEY
task_id UUID NOT NULL REFERENCES tasks(id)
uploaded_by_id UUID NOT NULL REFERENCES users(id)
file_name VARCHAR NOT NULL
file_url TEXT NOT NULL
content_type VARCHAR
file_size BIGINT
created_at TIMESTAMP NOT NULL
```

### Notes

Files should usually live in object storage such as S3. The database stores metadata and the file reference.

---

## 5.10 task_activity_logs

```sql
task_activity_logs
------------------
id UUID PRIMARY KEY
company_id UUID NOT NULL REFERENCES companies(id)
project_id UUID NOT NULL REFERENCES projects(id)
task_id UUID NOT NULL REFERENCES tasks(id)
actor_id UUID NOT NULL REFERENCES users(id)
action VARCHAR NOT NULL
metadata JSONB
created_at TIMESTAMP NOT NULL
```

### Example Actions

```text
task_created
task_updated
task_assigned
task_unassigned
status_changed
priority_changed
comment_added
attachment_uploaded
dependency_added
task_completed
```

### Example Metadata

```json
{
  "field": "status",
  "from": "todo",
  "to": "in_progress"
}
```

### Indexes

```sql
CREATE INDEX idx_activity_task_created_at
ON task_activity_logs(task_id, created_at DESC);

CREATE INDEX idx_activity_project_created_at
ON task_activity_logs(project_id, created_at DESC);

CREATE INDEX idx_activity_company_created_at
ON task_activity_logs(company_id, created_at DESC);
```

### Staff-Level Notes

Activity logs should generally be append-only. Do not update old audit rows unless required for compliance, privacy, or redaction.

---

## 5.11 notifications

```sql
notifications
-------------
id UUID PRIMARY KEY
user_id UUID NOT NULL REFERENCES users(id)
task_id UUID REFERENCES tasks(id)
type VARCHAR NOT NULL -- assigned, due_soon, overdue, completed, mentioned
status VARCHAR NOT NULL -- unread, read
payload JSONB
created_at TIMESTAMP NOT NULL
read_at TIMESTAMP
```

### Indexes

```sql
CREATE INDEX idx_notifications_user_status_created
ON notifications(user_id, status, created_at DESC);
```

---

## 5.12 idempotency_keys

```sql
idempotency_keys
----------------
id UUID PRIMARY KEY
company_id UUID NOT NULL REFERENCES companies(id)
key VARCHAR NOT NULL
request_hash VARCHAR NOT NULL
response_body JSONB
status VARCHAR NOT NULL -- processing, completed, failed
created_at TIMESTAMP NOT NULL
updated_at TIMESTAMP NOT NULL

UNIQUE(company_id, key)
```

### Why?

Clients may retry requests after timeouts. Without idempotency, duplicate tasks may be created.

---

# 6. Entity Relationship Summary

```text
Company
  has many Users
  has many Projects
  has many Tasks

Project
  belongs to Company
  has many ProjectMemberships
  has many Users through ProjectMemberships
  has many Tasks

Task
  belongs to Company
  belongs to Project
  belongs to Creator/User
  has many TaskAssignees
  has many Assignees through TaskAssignees
  has many Comments
  has many Attachments
  has many ActivityLogs
  has many Dependencies
```

---

# 7. API Design

## 7.1 Create Task

```http
POST /api/v1/projects/:project_id/tasks
```

### Request

```json
{
  "title": "Install drywall on level 2",
  "description": "Start after framing inspection is complete",
  "priority": "high",
  "due_date": "2026-06-20",
  "assignee_ids": ["user-1", "user-2"],
  "dependency_ids": ["task-123"]
}
```

### Response

```json
{
  "id": "task-456",
  "project_id": "project-1",
  "title": "Install drywall on level 2",
  "status": "todo",
  "priority": "high",
  "due_date": "2026-06-20",
  "assignees": [
    {
      "id": "user-1",
      "name": "Ahmed Ali"
    }
  ],
  "created_at": "2026-06-05T10:00:00Z"
}
```

### Staff-Level Notes

Task creation should happen inside a database transaction:

1. Create task.
2. Add assignees.
3. Add dependencies.
4. Write activity log.
5. Publish event after commit.

---

## 7.2 List Tasks

```http
GET /api/v1/projects/:project_id/tasks
```

### Query Parameters

```text
status=todo
assignee_id=user-1
priority=high
due_before=2026-06-30
sort=due_date
page=1
per_page=50
```

### Example

```http
GET /api/v1/projects/123/tasks?status=in_progress&assignee_id=456&sort=due_date
```

### Response

```json
{
  "data": [
    {
      "id": "task-1",
      "title": "Pour concrete",
      "status": "in_progress",
      "priority": "high",
      "due_date": "2026-06-15"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 50,
    "total_count": 120
  }
}
```

### Staff-Level Note

For large data, prefer cursor pagination:

```http
GET /api/v1/projects/:project_id/tasks?cursor=abc&limit=50
```

Offset pagination can become slow with very large datasets.

---

## 7.3 Get Task Details

```http
GET /api/v1/tasks/:id
```

### Response

```json
{
  "id": "task-1",
  "title": "Pour concrete",
  "description": "Concrete pour for foundation section A",
  "status": "in_progress",
  "priority": "high",
  "assignees": [],
  "dependencies": [],
  "comments_count": 10,
  "attachments_count": 2,
  "created_at": "2026-06-05T10:00:00Z",
  "updated_at": "2026-06-05T12:00:00Z"
}
```

---

## 7.4 Update Task

```http
PATCH /api/v1/tasks/:id
```

### Request

```json
{
  "title": "Pour concrete for foundation",
  "status": "in_progress",
  "priority": "urgent",
  "lock_version": 3
}
```

### Why `lock_version`?

It prevents lost updates.

Example:

- User A opens task.
- User B opens same task.
- User A changes priority.
- User B changes status.
- Without optimistic locking, one update can silently overwrite the other.

With `lock_version`, stale updates can return:

```http
409 Conflict
```

---

## 7.5 Complete Task

```http
POST /api/v1/tasks/:id/complete
```

### Request

```json
{
  "lock_version": 4
}
```

### Validation

Before completing a task:

- User must have permission.
- Required dependencies must be complete.
- Task must not already be completed.
- State transition must be valid.

---

## 7.6 Assign Users

```http
POST /api/v1/tasks/:id/assignees
```

### Request

```json
{
  "user_ids": ["user-1", "user-2"]
}
```

---

## 7.7 Remove Assignee

```http
DELETE /api/v1/tasks/:id/assignees/:user_id
```

---

## 7.8 Add Comment

```http
POST /api/v1/tasks/:id/comments
```

### Request

```json
{
  "body": "Framing inspection is done. This task can start tomorrow."
}
```

---

## 7.9 List Comments

```http
GET /api/v1/tasks/:id/comments
```

---

## 7.10 Add Dependency

```http
POST /api/v1/tasks/:id/dependencies
```

### Request

```json
{
  "depends_on_task_id": "task-123"
}
```

### Validation

- Both tasks must be in the same project.
- Task cannot depend on itself.
- Dependency must not create a cycle.

---

## 7.11 Remove Dependency

```http
DELETE /api/v1/tasks/:id/dependencies/:dependency_id
```

---

## 7.12 Activity Log

```http
GET /api/v1/tasks/:id/activity
```

Used for task timeline and audit history.

---

# 8. Authorization Design

Every task API should follow this flow:

```text
1. Load task.
2. Check task.company_id.
3. Check current_user belongs to company.
4. Check current_user is a project member.
5. Check role permission.
```

## Example Roles

```text
viewer  => read only
member  => create/comment/update own tasks
manager => assign/update/complete tasks
admin   => full control
```

## Bad Authorization Example

```ruby
Task.find(params[:id])
```

This may allow IDOR vulnerabilities if a user guesses another task ID.

## Better Authorization Example

```ruby
Task
  .joins(project: :project_memberships)
  .where(id: params[:id])
  .where(company_id: current_user.company_id)
  .where(project_memberships: { user_id: current_user.id })
  .first!
```

---

# 9. Rails Model Sketch

```ruby
class Task < ApplicationRecord
  belongs_to :company
  belongs_to :project
  belongs_to :created_by, class_name: "User"

  has_many :task_assignees, dependent: :destroy
  has_many :assignees, through: :task_assignees, source: :user

  has_many :task_comments, dependent: :destroy
  has_many :task_attachments, dependent: :destroy
  has_many :task_activity_logs, dependent: :destroy

  has_many :task_dependencies, dependent: :destroy
  has_many :dependencies,
           through: :task_dependencies,
           source: :depends_on_task

  enum :status, {
    todo: "todo",
    in_progress: "in_progress",
    blocked: "blocked",
    done: "done",
    archived: "archived"
  }

  enum :priority, {
    low: "low",
    medium: "medium",
    high: "high",
    urgent: "urgent"
  }

  validates :title, presence: true
  validates :status, presence: true
  validates :priority, presence: true
end
```

---

# 10. Service Object Example

```ruby
class Tasks::CreateTask
  def initialize(project:, actor:, params:)
    @project = project
    @actor = actor
    @params = params
  end

  def call
    Task.transaction do
      task = Task.create!(
        company: @project.company,
        project: @project,
        created_by: @actor,
        title: @params[:title],
        description: @params[:description],
        priority: @params[:priority] || "medium",
        status: "todo",
        due_date: @params[:due_date]
      )

      assign_users(task)
      add_dependencies(task)
      log_activity(task)

      task
    end.tap do |task|
      Tasks::TaskCreatedEvent.publish(task.id)
    end
  end

  private

  def assign_users(task)
    Array(@params[:assignee_ids]).each do |user_id|
      task.task_assignees.create!(
        user_id: user_id,
        assigned_by: @actor,
        assigned_at: Time.current
      )
    end
  end

  def add_dependencies(task)
    Array(@params[:dependency_ids]).each do |dependency_id|
      Tasks::AddDependency.new(
        task: task,
        depends_on_task_id: dependency_id,
        actor: @actor
      ).call
    end
  end

  def log_activity(task)
    TaskActivityLog.create!(
      company: task.company,
      project: task.project,
      task: task,
      actor: @actor,
      action: "task_created",
      metadata: {}
    )
  end
end
```

---

# 11. Concurrency and Correctness

## Problem: Two Users Update the Same Task

Use optimistic locking with `lock_version`.

When stale data is submitted, return:

```http
409 Conflict
```

Example response:

```json
{
  "error": "Task was updated by another user. Please refresh and try again."
}
```

---

## Problem: Completing a Task While Dependencies Change

Use transactions and locking.

```ruby
task.with_lock do
  raise "Dependencies incomplete" unless task.dependencies.all?(&:done?)

  task.update!(
    status: "done",
    completed_at: Time.current
  )
end
```

---

## Problem: Duplicate Create Requests

Use idempotency keys.

```http
Idempotency-Key: abc-123
```

This avoids duplicate tasks when clients retry failed or timed-out requests.

---

# 12. Scalability Considerations

## Database Scaling

- Tenant-scoped indexes using `company_id` and `project_id`.
- Avoid unbounded list endpoints.
- Use cursor pagination for large datasets.
- Use read replicas for heavy reporting.
- Partition activity logs by `created_at` or `company_id` if they grow very large.
- Archive old completed tasks.
- Use a search engine only if Postgres filtering/search becomes insufficient.

## API Scaling

- Pagination.
- Rate limiting.
- Avoid N+1 queries.
- Cache project membership/permission checks carefully.
- Use background jobs for notifications.
- Use idempotency keys for retry-safe creates.

## Background Jobs

Use async jobs for:

- Notifications.
- Due-soon reminders.
- Overdue checks.
- Activity feed fanout.
- Search indexing.

---

# 13. Observability

A Staff Engineer should mention observability even if not asked.

## Metrics

```text
tasks.created.count
tasks.updated.count
tasks.completed.count
tasks.create.latency
tasks.list.latency
tasks.dependency_cycle_detected.count
notifications.enqueued.count
notifications.failed.count
```

## Logs Should Include

```text
company_id
project_id
task_id
actor_id
request_id
```

## Tracing Example

```text
POST /tasks
  authorization check
  task insert
  assignee inserts
  dependency validation
  activity log insert
  event publish
```

This helps debug slow or failed requests in production.

---

# 14. Monolith vs Microservice

A strong answer:

> I would start this as a well-bounded module inside the Rails backend or modular monolith. I would define clear domain boundaries around Tasks, Projects, Users, Notifications, and Activity Logs. I would avoid extracting a microservice too early unless task traffic, team ownership, scaling needs, or deployment independence justify it.

## Why?

A microservice adds operational complexity:

- Network calls.
- Distributed transactions.
- More deployment pipelines.
- More observability requirements.
- More failure modes.

A modular monolith is often better until there is a real reason to extract.

---

# 15. Best Staff-Level Interview Answer

Use this as your final answer summary:

> I would model this as a tenant-scoped task domain. The core tables are companies, users, projects, project_memberships, tasks, task_assignees, task_dependencies, comments, attachments, activity_logs, notifications, and idempotency_keys.
>
> I would keep company_id on major tables for tenant isolation and query performance. Tasks belong to projects, and assignments are a join table to support multiple assignees. Dependencies are modeled as edges between tasks, with validation to prevent self-dependencies and cycles.
>
> APIs would be RESTful: create/list/update/complete tasks, manage assignees, comments, dependencies, and activity. I would enforce authorization through project membership and role checks on every endpoint.
>
> For scalability, I would add compound indexes around project/status/assignee/due_date, use cursor pagination, avoid N+1 queries, and move notifications/search indexing to background jobs.
>
> For correctness, I would use DB transactions, optimistic locking with lock_version, idempotency keys for creates, and append-only audit logs.
>
> Architecturally, I would start this as a well-bounded module inside the Rails backend or modular monolith, with clear service boundaries and events. I would extract it only if scale or team ownership requires independent deployment.

---

# 16. Traffic Dip Investigation

## What is a Traffic Dip?

A traffic dip means the number of users, sessions, page views, API requests, or business events suddenly decreased.

Examples:

- Website visits dropped 30%.
- Signup traffic dropped 50%.
- API request volume dropped suddenly.
- Mobile traffic dropped but desktop is normal.
- Organic search traffic dropped after a deployment.

---

## 16.1 First Rule: Do Not Panic

React like an investigator.

The first goal is to answer:

```text
Is this a real traffic drop or just a measurement/tracking issue?
```

---

## 16.2 Confirm the Dip is Real

Compare traffic with:

- Yesterday.
- Same day last week.
- Same period last month.
- Same period last year.

Ask:

- Is all traffic down?
- Is only one channel down?
- Is only one country down?
- Is only one device type down?
- Is only one browser down?
- Is only one page or endpoint down?
- Is only one campaign down?

---

## 16.3 Split by Traffic Source

Check:

- Organic search.
- Paid ads.
- Direct.
- Referral.
- Email.
- Social.
- App traffic.
- API traffic.

Example:

```text
Total traffic down 30%.
Organic down 5%.
Paid ads down 80%.
```

This suggests the issue is likely paid campaigns, not the whole product.

Another example:

```text
Desktop traffic normal.
Mobile traffic down 60%.
```

This may suggest a mobile bug, tracking issue, layout issue, or app/webview problem.

---

## 16.4 Check if Tracking is Broken

Sometimes traffic did not really drop. Analytics just stopped recording.

Check:

- Did we deploy recently?
- Did analytics script change?
- Did Google Tag Manager change?
- Did consent/cookie banner change?
- Did tracking events change?
- Did CSP block analytics requests?
- Did ad blockers affect measurement?

Engineering checks:

- Browser console errors.
- Network requests to analytics provider.
- Backend request logs.
- CDN logs.
- Load balancer logs.

If backend logs are normal but analytics is down, it is probably a tracking issue.

---

## 16.5 Check Recent Deployments

Ask:

```text
What changed before the dip?
```

Check:

- Frontend deploy.
- Backend deploy.
- SEO change.
- Redirect change.
- Sitemap change.
- robots.txt change.
- CDN configuration.
- Firewall/WAF rule.
- Payment or signup bug.
- Feature flag change.

For a Rails/backend app:

```bash
git log --since="24 hours ago"
```

Also check:

- Sentry.
- Datadog.
- New Relic.
- Grafana.
- CloudWatch.
- OpenTelemetry traces.

---

## 16.6 Check Errors and Performance

Traffic can dip because users cannot load pages or complete actions.

Check:

- HTTP 5xx errors.
- HTTP 4xx errors.
- Timeouts.
- Database slow queries.
- Queue delays.
- CPU spikes.
- Memory spikes.
- CDN errors.
- DNS issues.
- SSL certificate issues.

Important metrics:

```text
request_count
error_rate
p95_latency
p99_latency
apdex
database_time
external_api_time
cache_hit_rate
```

Example:

```text
Traffic dropped at 10:05 AM.
p95 latency jumped from 300ms to 8s at 10:04 AM.
```

This suggests performance degradation caused users or bots to stop reaching the site.

---

## 16.7 If Organic Traffic Dropped

Check:

- Google Search Console.
- Index coverage.
- Manual actions.
- robots.txt.
- Sitemap.
- Canonical tags.
- Noindex tags.
- Redirects.
- Page titles/meta changes.
- Core Web Vitals.
- Server errors for Googlebot.

Common causes:

- Accidentally added `noindex`.
- robots.txt blocked important pages.
- Broken canonical URLs.
- Redirect loop.
- Pages returning 404/500.
- Sitemap removed URLs.
- Site speed got worse.
- Search engine algorithm update.

---

## 16.8 If Paid Traffic Dropped

Check:

- Campaign status.
- Budget exhausted.
- Payment failed.
- Ad rejected.
- Targeting changed.
- Bid strategy changed.
- Tracking template broken.
- Landing page down.
- UTM parameters changed.

Example:

```text
Paid traffic is down, but organic and direct traffic are normal.
```

Likely causes:

- Campaign paused.
- Daily budget hit early.
- Payment issue.
- Ad account restriction.

---

## 16.9 If One Region Dropped

Check:

- Local holiday.
- Regional CDN issue.
- Regional DNS issue.
- Country-specific campaign issue.
- Country-specific firewall or WAF rule.
- Local payment or localization problem.

Example:

```text
Egypt traffic is normal.
US traffic is down 70%.
```

Then investigate US-specific infrastructure, campaigns, or region-based incidents.

---

## 16.10 Interview Answer for Traffic Dip

> First, I would confirm whether the traffic dip is real or a tracking issue by comparing analytics with backend, CDN, and load balancer logs. Then I would segment the traffic by source, device, geography, page, and time.
>
> After that, I would check recent deployments, feature flags, analytics changes, SEO changes, campaign changes, and infrastructure metrics. If the dip is tied to errors or latency, I would treat it as an incident and roll back or mitigate. If it is isolated to organic search, I would check Search Console, robots.txt, sitemap, redirects, canonical tags, and indexing. If it is paid traffic, I would check campaign status, budget, payment, ad approvals, and landing page health.
>
> Finally, I would document the root cause, add monitoring for the affected traffic segment, and create alerts so we catch similar dips earlier.

---

# 17. Security Attacks Every Backend Engineer Should Know

Security attacks can be grouped into:

1. Application-layer attacks.
2. Authentication and authorization attacks.
3. Infrastructure and network attacks.
4. Data and secrets exposure.
5. Business logic and concurrency attacks.

---

## 17.1 SQL Injection

### What It Is

An attacker injects SQL commands through user input.

### Bad Ruby Example

```ruby
User.where("email = '#{params[:email]}'")
```

Input:

```sql
' OR 1=1 --
```

Generated query:

```sql
SELECT * FROM users
WHERE email = '' OR 1=1 --'
```

### Risk

The attacker may read, modify, or delete data.

### Prevention

Use parameterized queries:

```ruby
User.where(email: params[:email])
```

---

## 17.2 Cross-Site Scripting - XSS

### What It Is

An attacker injects JavaScript into a page viewed by other users.

Example input:

```html
<script>alert("hacked")</script>
```

### Risks

- Steal cookies.
- Steal JWT tokens.
- Session hijacking.
- Phishing.
- Perform actions as the victim.

### Prevention in Rails

Rails escapes output by default:

```erb
<%= comment.body %>
```

Avoid unsafe rendering:

```erb
<%= raw comment.body %>
```

Only use raw HTML after sanitization.

---

## 17.3 Cross-Site Request Forgery - CSRF

### What It Is

A victim is logged into your site. An attacker tricks the victim's browser into making an unwanted request.

### Example

A malicious website submits a hidden form to your banking app while the user is logged in.

### Prevention

Rails provides:

```ruby
protect_from_forgery
```

Also use:

- CSRF tokens.
- SameSite cookies.
- Proper HTTP verbs.

---

## 17.4 Broken Authentication

### Examples

- Weak passwords.
- No MFA.
- Predictable password reset tokens.
- Session fixation.
- Poor session expiration.

### Prevention

- MFA.
- Strong password policies.
- Password hashing using strong algorithms.
- Account lockout or throttling.
- Secure password reset flow.
- Rate limiting.

---

## 17.5 Broken Authorization / IDOR

### What It Is

IDOR means Insecure Direct Object Reference.

Bad API:

```http
GET /orders/123
```

Bad backend:

```ruby
Order.find(params[:id])
```

An attacker changes the ID:

```http
GET /orders/124
```

If the backend does not check ownership, the attacker may see another user's order.

### Prevention

Scope queries to the current user or tenant:

```ruby
current_user.orders.find(params[:id])
```

For multi-tenant systems:

```ruby
current_user.company.orders.find(params[:id])
```

---

## 17.6 Session Hijacking

### What It Is

An attacker steals a session cookie and uses it as the victim.

### Causes

- XSS.
- Insecure cookies.
- Public WiFi interception.
- Cookie leakage in logs.

### Prevention

- HTTPS.
- Secure cookies.
- HttpOnly cookies.
- SameSite cookies.
- Short expiration.
- Session rotation after login.

---

## 17.7 Brute Force Attack

### What It Is

An attacker repeatedly guesses passwords.

### Prevention

- Rate limiting.
- Temporary account lock.
- CAPTCHA after suspicious attempts.
- MFA.
- Login monitoring.

---

## 17.8 Credential Stuffing

### What It Is

Attackers use leaked credentials from another website and try them on your app.

### Prevention

- MFA.
- Password breach checks.
- Risk-based authentication.
- Rate limiting.
- Device/location anomaly detection.

---

## 17.9 Denial of Service - DoS

### What It Is

A single attacker overwhelms your service with traffic or expensive requests.

### Impact

- CPU exhaustion.
- Memory exhaustion.
- Database overload.
- Queue overload.
- Service downtime.

### Prevention

- Rate limiting.
- Caching.
- CDN.
- WAF.
- Load balancing.
- Request timeouts.

---

## 17.10 Distributed Denial of Service - DDoS

### What It Is

A DoS attack from many machines, usually a botnet.

### Prevention

- CDN.
- WAF.
- DDoS protection services.
- Autoscaling.
- Traffic filtering.
- Upstream provider protection.

---

## 17.11 Server-Side Request Forgery - SSRF

### What It Is

The backend makes a request to a URL controlled by the attacker.

Bad code:

```ruby
Net::HTTP.get(URI(params[:url]))
```

Attacker sends:

```text
http://169.254.169.254
```

On AWS, this can target the metadata service.

### Prevention

- Allowlist trusted domains.
- Block internal IP ranges.
- Validate URLs.
- Disable redirects or validate redirected destinations.
- Use network-level egress restrictions.

---

## 17.12 Command Injection

### What It Is

Attacker injects shell commands into system calls.

Bad code:

```ruby
system("ping #{params[:host]}")
```

Malicious input:

```bash
google.com; rm -rf /
```

### Prevention

Pass arguments safely:

```ruby
system("ping", params[:host])
```

Also:

- Avoid shell execution when possible.
- Validate input.
- Use allowlists.

---

## 17.13 Path Traversal

### What It Is

An attacker accesses files outside the intended directory.

Input:

```text
../../../etc/passwd
```

### Prevention

- Normalize paths.
- Restrict access to a safe base directory.
- Validate filenames.
- Do not directly trust user-provided file paths.

---

## 17.14 Insecure File Upload

### What It Is

Attacker uploads malicious files such as scripts or malware.

Examples:

```text
shell.php
malware.exe
fake-image.jpg
```

### Prevention

- Validate content type.
- Validate file extension.
- Scan files for malware.
- Store files outside web root.
- Rename uploaded files.
- Use signed/private URLs.
- Restrict executable files.

---

## 17.15 XML External Entity - XXE

### What It Is

An attacker uses malicious XML to access internal files or services.

Example:

```xml
<!DOCTYPE foo [
<!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
```

### Prevention

- Disable external entities.
- Avoid parsing untrusted XML when possible.
- Use secure XML parser settings.

---

## 17.16 JWT Attacks

### Examples

- Weak signing secret.
- No expiration.
- Algorithm confusion.
- Accepting unsigned tokens.
- Storing JWT in unsafe browser storage.

### Prevention

- Use strong secrets or asymmetric keys.
- Validate algorithm.
- Use short expiration.
- Rotate keys.
- Validate issuer and audience.
- Avoid storing sensitive data inside JWT payload.

---

## 17.17 Replay Attack

### What It Is

An attacker captures a valid request and sends it again.

Example:

```text
Payment request is captured and replayed twice.
```

### Prevention

- Nonces.
- Timestamps.
- Idempotency keys.
- Request signing.
- Short-lived tokens.

---

## 17.18 Man-in-the-Middle - MITM

### What It Is

An attacker intercepts traffic between client and server.

### Prevention

- HTTPS.
- TLS.
- Certificate validation.
- HSTS.
- Avoid sending secrets over insecure channels.

---

## 17.19 Clickjacking

### What It Is

A malicious website loads your site inside an iframe and tricks the user into clicking something.

### Prevention

Use security headers:

```http
X-Frame-Options: DENY
```

or:

```http
Content-Security-Policy: frame-ancestors 'none'
```

---

## 17.20 Sensitive Data Exposure

### Examples

- Passwords in logs.
- API tokens in GitHub.
- Credit card data in logs.
- PII in URLs.
- Unencrypted backups.
- Secrets in environment dumps.

### Prevention

- Encryption at rest.
- Encryption in transit.
- Log masking.
- Secret management.
- Least privilege access.
- Regular secret rotation.

---

## 17.21 Race Condition Attacks

### Example

Two withdraw requests happen at the same time:

```text
Withdraw $100
Withdraw $100
```

Account balance:

```text
$100
```

Both requests may succeed if there is no locking.

### Prevention in Rails

```ruby
account.with_lock do
  raise "Insufficient funds" if account.balance < amount

  account.update!(balance: account.balance - amount)
end
```

Also use:

- Database transactions.
- Row-level locks.
- Optimistic locking.
- Unique constraints.
- Idempotency keys.

---

## 17.22 Mass Assignment

### What It Is

An attacker sends fields they should not be allowed to set.

Bad example:

```ruby
User.create(params[:user])
```

Attacker sends:

```json
{
  "email": "attacker@test.com",
  "admin": true
}
```

### Prevention in Rails

Use strong parameters:

```ruby
params.require(:user).permit(:email, :name)
```

Never permit sensitive fields like:

```text
admin
role
account_id
company_id
is_superuser
```

unless explicitly controlled by trusted backend logic.

---

## 17.23 Secrets Leakage

### Examples

- AWS keys committed to GitHub.
- Database passwords in source code.
- API tokens in logs.
- `.env` files uploaded publicly.

### Prevention

- Secret manager.
- Environment variables.
- Git secret scanning.
- Key rotation.
- Least privilege IAM policies.
- Avoid logging secrets.

---

# 18. Top Security Attacks to Memorize for Interviews

If you only memorize ten, memorize these:

1. SQL Injection.
2. XSS.
3. CSRF.
4. Broken Authentication.
5. Broken Authorization / IDOR.
6. SSRF.
7. DDoS.
8. Command Injection.
9. JWT vulnerabilities.
10. Race conditions.

---

# 19. Short Interview Answer About Security Attacks

> The most common web application attacks include SQL Injection, XSS, CSRF, broken authentication, broken authorization or IDOR, SSRF, command injection, DDoS, JWT-related vulnerabilities, and race conditions.
>
> In Rails applications, I mitigate these using parameterized queries, output escaping, CSRF protection, authorization policies, secure session handling, rate limiting, input validation, HTTPS, strong secrets management, and proper locking and transaction strategies.

---

# 20. Staff-Level Follow-Up Questions to Practice

## Task Management Design

1. How would you prevent circular task dependencies?
2. How would you design indexes for task filtering?
3. How would you avoid N+1 queries in Rails?
4. How would you handle soft delete vs hard delete?
5. How would you scale audit logs?
6. How would you support recurring tasks?
7. How would you support subtasks?
8. How would you support task templates?
9. How would you support mentions in comments?
10. How would you send notifications reliably?
11. What happens if notification delivery fails?
12. How do you make task creation idempotent?
13. How do you handle duplicate requests?
14. How do you model permissions?
15. How would you migrate from one assignee to multiple assignees?
16. How would you expose this API to mobile clients?
17. How would you version the API?
18. How would you test this design?
19. When would you introduce Elasticsearch/OpenSearch?
20. Would you build this as a microservice or monolith?

## Traffic Dip Investigation

1. How do you know if the dip is real or tracking-related?
2. Which metrics would you check first?
3. How do you segment traffic?
4. How do you investigate a paid traffic drop?
5. How do you investigate an organic traffic drop?
6. How do you connect a traffic dip to a deployment?
7. What dashboards would you build?
8. When would you rollback?
9. How would you communicate the incident?
10. How would you prevent recurrence?

## Security

1. What is SQL injection and how does Rails prevent it?
2. What is XSS and how do you prevent it?
3. What is CSRF and how does Rails handle it?
4. What is IDOR?
5. How do you prevent mass assignment in Rails?
6. What is SSRF?
7. How do JWT attacks happen?
8. How do you prevent brute force attacks?
9. What is a replay attack?
10. How do race conditions become security vulnerabilities?

---

# 21. Final Preparation Advice

For a Staff Software Engineer backend interview, do not answer only with tables and endpoints.

You should show that you think about:

- Product requirements.
- Data modeling.
- API design.
- Multi-tenancy.
- Authorization.
- Security.
- Transactions.
- Idempotency.
- Scalability.
- Observability.
- Incident response.
- Tradeoffs.
- Long-term maintainability.

A strong Staff-level answer connects implementation details with production reliability and business impact.
