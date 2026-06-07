# Rails Deep Dive — ActiveRecord, Request Lifecycle, Architecture

> Focus areas: ActiveRecord query optimization, request lifecycle, concerns, transactions, migrations, caching, security, app structure.

---

## 1. Rails Request Lifecycle

```text
Web Server (Puma) → Rack Middleware → Router → Controller → Service/Domain Layer
→ ActiveRecord/Models → Database → Serializer/View → HTTP Response
```

**Middleware handles:** sessions, cookies, request IDs, logging, authentication, CORS, tracing.

**Staff-Level Addition:**
> "For observability, every request should have a request ID and trace ID propagated through downstream services and background jobs."

---

## 2. ActiveRecord Query Methods

### `includes` vs `preload` vs `eager_load` vs `joins`

| Method | Strategy | SQL Generated | When to Use |
|--------|----------|--------------|-------------|
| `includes` | Rails decides | preload OR LEFT JOIN | Default choice — Rails picks best strategy |
| `preload` | Always separate queries | `SELECT * FROM posts; SELECT * FROM comments WHERE post_id IN (...)` | Avoid large joins, safe for display |
| `eager_load` | Always LEFT OUTER JOIN | Single query with LEFT JOIN | When filtering/ordering on associated table |
| `joins` | INNER JOIN for filtering | `SELECT users.* FROM users INNER JOIN posts ON...` | Filtering only — does NOT eager load objects |

```ruby
# preload (2 queries)
User.preload(:posts)

# eager_load (1 query with LEFT JOIN)
User.eager_load(:posts)

# includes (Rails decides)
User.includes(:posts)

# joins (for filtering, still gets N+1 if you access association)
User.joins(:posts).where(posts: { published: true })
```

**Staff-Level Answer:**
> "I choose based on query shape. For simple display, preload is safer. For filtering on joined tables, I use joins or eager_load carefully. I always check generated SQL and query plans for high-volume endpoints."

### `pluck` vs `select` vs `map`

| Method | Returns | Loads AR Objects? | Use When |
|--------|---------|-------------------|----------|
| `map` | Array of values | Yes — full objects loaded | Need model methods |
| `pluck` | Array of raw values | No — direct SQL | Only need scalar values |
| `select` | AR objects with limited fields | Yes — partial objects | Need model instances but not all columns |

```ruby
User.pluck(:email)                    # => ["a@b.com", "c@d.com"]
User.select(:id, :email)             # => [#<User id: 1, email: "a@b.com">]
User.all.map(&:email)                # Loads ALL columns, extracts in Ruby — wasteful
```

---

## 3. Transactions

```ruby
ActiveRecord::Base.transaction do
  task.update!(status: "closed")
  ActivityLog.create!(task: task, action: "closed")
end
```

### Critical Rules
1. **Use bang methods** inside transactions — `save!`, `update!`, `create!`
2. **Never call external APIs** inside transactions — they can't be rolled back
3. **Don't enqueue jobs** that depend on committed data before commit
4. **Use `after_commit`** for side effects (notifications, job enqueuing)

```ruby
class Task < ApplicationRecord
  after_commit :notify_assignees, on: :update

  private

  def notify_assignees
    NotifyAssigneesJob.perform_later(id)
  end
end
```

**Staff-Level Point:**
> "A common bug is sending notifications or enqueuing jobs inside a transaction before data is committed. I prefer after_commit or outbox patterns."

---

## 4. Race Conditions & Locking

### Optimistic Locking
Uses `lock_version` column. Raises `StaleObjectError` if another process updated the record.

```ruby
class Task < ApplicationRecord
  # Requires lock_version column in DB
end

# User A reads task (lock_version: 3)
# User B reads task (lock_version: 3)
# User A updates → lock_version becomes 4 ✓
# User B tries to update → StaleObjectError ✗ (expected 3, got 4)
```

**Best for:** Low contention (user editing their profile, task details).

### Pessimistic Locking
Issues `SELECT ... FOR UPDATE` — blocks other processes.

```ruby
task.with_lock do
  task.update!(status: "closed")
end
```

**Best for:** High contention (inventory decrement, budget allocation).

### Database Constraints
```ruby
add_index :assignments, [:task_id, :user_id], unique: true
```

**Staff-Level Point:**
> "Application-level checks are not enough under concurrency. I want the database to protect critical invariants."

---

## 5. Validations vs Database Constraints

Use **both**:

```ruby
# Model validation — user-friendly errors
validates :email, presence: true, uniqueness: true

# Database constraint — data integrity under concurrency
add_index :users, :email, unique: true
```

> "Validation is UX. Constraint is correctness."

---

## 6. Safe Database Migrations

### Dangerous Operations to Avoid
- `ALTER TABLE ADD COLUMN NOT NULL DEFAULT` on large tables — locks table
- Adding index without `CONCURRENTLY` — blocks writes
- Renaming columns — breaks running code

### Safe Migration Pattern
1. Add nullable column
2. Deploy code that writes to both old and new columns
3. Backfill in batches
4. Add NOT NULL constraint using `NOT VALID` then `VALIDATE CONSTRAINT`
5. Remove old column in a later deploy

```ruby
# Safe index creation
add_index :tasks, :project_id, algorithm: :concurrently

# Batch backfill
User.where(active: true).find_in_batches(batch_size: 1_000) do |users|
  User.where(id: users.map(&:id)).update_all(processed: true)
end
```

**Use `strong_migrations` gem** to catch dangerous migrations at deploy time.

> "For large production tables, schema changes must be treated as deployable projects, not simple code changes."

---

## 7. Rails Concerns — When Helpful vs Harmful

**Good Use:**
- Small, cohesive behavior reused in multiple places
- Clear, self-contained functionality

**Bad Use:**
- Hiding large business logic
- Creating implicit dependencies
- Making models harder to reason about

> "I use concerns carefully. If a concern becomes a business workflow, I move it to a domain object or service."

---

## 8. Service Objects

Use when an operation coordinates multiple models or systems:

```ruby
class Tasks::CloseService
  def call(task:, actor:)
    ActiveRecord::Base.transaction do
      task.update!(status: "closed", completed_at: Time.current)
      ActivityLog.create!(task: task, actor: actor, action: "closed")
    end

    NotifyAssigneesJob.perform_later(task.id) # after commit
  end
end
```

**Principles:**
- Clear name representing a use case
- Small public API
- Explicit inputs
- Predictable return values

> "I avoid service-object dumping grounds. Services should represent clear use cases, not become procedural replacements for domain modeling."

---

## 9. Dependent Destroy vs Delete All

| Option | Behavior |
|--------|----------|
| `dependent: :destroy` | Instantiates each record, runs callbacks |
| `dependent: :delete_all` | Deletes via SQL, skips callbacks |

> "Using `delete_all` can bypass important cleanup logic, audit logs, or external side effects."

---

## 10. Caching Strategy

### Caching Layers
1. **HTTP caching** — browser/CDN cache headers
2. **Fragment caching** — view partials
3. **Low-level cache** — `Rails.cache.fetch`
4. **Redis caching** — explicit key-value
5. **Counter caches** — denormalized counts

```ruby
Rails.cache.fetch(["project-summary", project.id, project.updated_at], expires_in: 10.minutes) do
  ProjectSummaryBuilder.call(project)
end
```

### Principles
- Cache read-heavy, stable data
- Plan invalidation **before** adding cache
- Avoid caching permission-sensitive data incorrectly
- Measure hit rate

> "Caching is easy to add and hard to invalidate. I only cache after I understand the data freshness requirement."

---

## 11. Securing a Rails API

| Area | Implementation |
|------|----------------|
| **Authentication** | JWT / OAuth 2.0 / session tokens |
| **Authorization** | RBAC + ABAC policies (Pundit/custom) |
| **Input Validation** | Strong params, allowlisting |
| **SQL Injection** | Parameterized queries (ActiveRecord does this) |
| **Mass Assignment** | Strong parameters |
| **CSRF** | Token verification for non-API requests |
| **Rate Limiting** | Rack::Attack or API gateway |
| **Encryption** | TLS in transit, encrypted at rest |
| **Audit Logging** | Who did what, when, on what resource |
| **Secrets** | Rails credentials, environment variables |

---

## 12. Structuring a Large Rails App

### Domain-Oriented Structure
```text
app/domains/project_management/
app/domains/permissions/
app/domains/notifications/
app/domains/documents/
```

### Principles
- Clear ownership per domain
- Explicit interfaces between domains
- No circular dependencies
- Keep controllers thin
- Keep business logic out of views/jobs
- Use `packwerk` (Shopify's gem) for boundary enforcement

> "The goal is not folder structure. The goal is reducing cognitive load and preventing accidental coupling."

---

## 13. Connection Pooling

Puma threads each need a DB connection:
```yaml
# database.yml
pool: <%= ENV.fetch('RAILS_MAX_THREADS') { 5 } %>
```

**Pool size should match:** `puma.rb thread count × worker count`

**Common production issue:** `ActiveRecord::ConnectionTimeoutError` when threads exceed pool size.

---

## 14. Background Jobs with Sidekiq

### Design Principles
- Jobs should be **small** and **idempotent**
- Pass IDs, not full objects
- Handle missing records gracefully
- Use retries with exponential backoff
- Monitor dead queue size

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

> "I assume any job can run zero, one, or multiple times, so I design side effects accordingly."
