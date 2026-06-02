# Ruby on Rails Interview Preparation — Intermediate Topics

**Prepared date:** 2026-06-02  
**Target:** Mid → Senior Rails backend interviews; also useful for Team Lead fundamentals  
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

Use this file after the basic guide. Practice each answer using this pattern: define the concept, explain when to use it, mention tradeoffs, give a production example, then show the code.

---

### Q1. Explain `includes`, `preload`, `eager_load`, and `joins`.
**Interview category / level:** Mid / Senior Rails performance

**Answer:**
Use `preload` when you want separate queries to load associations without a join. Use `eager_load` when you need a `LEFT OUTER JOIN`, usually because you filter or order by associated table columns. `includes` chooses between those strategies depending on query shape. `joins` creates SQL joins but does not instantiate associations, so accessing the association later may still cause N+1 queries. Always check generated SQL for high-volume endpoints.

**Ruby/Rails example:**
```ruby
Project.preload(:tasks)
Project.eager_load(:tasks).where(tasks: { status: "open" })
Project.includes(:tasks)
Project.joins(:tasks).where(tasks: { status: "open" })
```

**Resources:**
- Rails Active Record Query Interface: https://guides.rubyonrails.org/active_record_querying.html

---


### Q2. How do you debug an N+1 query?
**Interview category / level:** Mid / Senior Rails performance

**Answer:**
Look for repeated similar SQL queries as the collection size grows. Use Rails logs, APM traces, Bullet in development, and query-count tests. Fix the root query shape with eager loading, aggregation, counter caches, or a custom SQL query. Do not blindly add `includes` for huge associations because memory can become worse.

**Ruby/Rails example:**
```ruby
projects = Project.includes(:owner, tasks: :assignee).where(company_id: company.id)
projects.each do |project|
  puts project.owner.name
end
```

---


### Q3. What is lazy loading in ActiveRecord?
**Interview category / level:** Mid Rails querying

**Answer:**
ActiveRecord relations are lazy. Calling `where`, `order`, and `limit` builds a relation but does not hit the database until you enumerate or call methods such as `to_a`, `first`, `count`, `pluck`, or `each`. This makes relations composable, but it can also hide when queries actually execute.

**Ruby/Rails example:**
```ruby
scope = User.where(active: true).order(created_at: :desc)
# no SQL yet
users = scope.limit(10).to_a
# SQL now
```

---


### Q4. How do you optimize a slow ActiveRecord query?
**Interview category / level:** Mid / Senior database

**Answer:**
Start from evidence: capture the SQL, run `EXPLAIN ANALYZE`, check row estimates, sequential scans, sorts, index usage, and buffer reads. Then reduce selected columns, add or adjust indexes, paginate, remove unnecessary joins, denormalize or materialize if it is a reporting query, and verify the improvement.

**Ruby/Rails example:**
```ruby
add_index :tasks, [:project_id, :status, :due_date], algorithm: :concurrently
```

**Resources:**
- PostgreSQL EXPLAIN: https://www.postgresql.org/docs/current/sql-explain.html

---


### Q5. What is `EXPLAIN ANALYZE` and how do you read it?
**Interview category / level:** Mid / Senior PostgreSQL

**Answer:**
EXPLAIN shows the planned query execution. EXPLAIN ANALYZE actually runs the query and shows actual timing and row counts. Compare estimated rows vs actual rows; large differences mean stale statistics or bad selectivity. Look for sequential scans on large tables, expensive sorts, nested loops with high loops, and disk reads.

**Ruby/Rails example:**
```ruby
sql = Task.where(project_id: 1, status: "open").to_sql
puts ActiveRecord::Base.connection.execute("EXPLAIN ANALYZE #{sql}").values
```

**Resources:**
- PostgreSQL using EXPLAIN: https://www.postgresql.org/docs/current/using-explain.html

---


### Q6. What are database transactions and when should you use them?
**Interview category / level:** Mid Rails database correctness

**Answer:**
Transactions group changes so they all commit or all rollback. Use them when multiple writes must stay consistent: creating a task plus assignments plus audit log. Use bang methods inside transactions so failures raise. Avoid slow external calls inside transactions.

**Ruby/Rails example:**
```ruby
ActiveRecord::Base.transaction do
  task.update!(status: "closed")
  ActivityLog.create!(resource: task, action: "closed")
end
```

---


### Q7. Why should you avoid external API calls inside DB transactions?
**Interview category / level:** Mid / Senior reliability

**Answer:**
External API calls are slow and cannot roll back with the database. Holding a DB transaction open during HTTP calls keeps locks and connections busy. If the external call succeeds and the DB transaction rolls back, your systems diverge. Prefer commit local state first, then call external systems asynchronously or through an outbox workflow.

**Ruby/Rails example:**
```ruby
Subscription.transaction do
  subscription.update!(status: "pending")
end
ProvisionSubscriptionJob.perform_later(subscription.id)
```

---


### Q8. What is `after_commit` vs `after_save`?
**Interview category / level:** Mid Rails callbacks

**Answer:**
`after_save` runs inside the transaction before commit. `after_commit` runs only after commit succeeds. Use `after_commit` for side effects such as jobs, emails, cache invalidation, and publishing events.

**Ruby/Rails example:**
```ruby
class Invoice < ApplicationRecord
  after_commit :enqueue_pdf_generation, on: :create
  def enqueue_pdf_generation
    GenerateInvoicePdfJob.perform_later(id)
  end
end
```

---


### Q9. What are callback risks in Rails?
**Interview category / level:** Mid / Senior architecture

**Answer:**
Callbacks hide control flow. They can trigger external side effects during unrelated saves, make tests slow, cause unexpected behavior in migrations, and couple models to infrastructure. Use callbacks for local invariants such as normalization; use explicit services/events for workflows.

**Ruby/Rails example:**
```ruby
class User < ApplicationRecord
  before_validation :normalize_email
  # Good: local invariant, no external side effect
end
```

---


### Q10. How do you design a good service object?
**Interview category / level:** Mid / Senior Rails architecture

**Answer:**
A good service object models one use case, has explicit inputs, returns a predictable result, uses clear names, owns transaction boundaries when needed, and is easy to test. Avoid generic names like `Processor` or huge `call` methods doing many domains at once.

**Ruby/Rails example:**
```ruby
module Tasks
  class Complete
    def self.call(task:, actor:)
      new(task, actor).call
    end
    def initialize(task, actor)
      @task = task
      @actor = actor
    end
    def call
      Task.transaction do
        @task.update!(status: "completed", completed_by: @actor)
        ActivityLog.create!(resource: @task, actor: @actor, action: "completed")
      end
    end
  end
end
```

---


### Q11. What is idempotency and why is it important?
**Interview category / level:** Mid / Senior distributed systems

**Answer:**
Idempotency means running an operation more than once has the same effect as running it once. It is critical for retries, webhooks, background jobs, and flaky networks. Use unique keys, processed event tables, database constraints, and safe state transitions.

**Ruby/Rails example:**
```ruby
ProcessedEvent.create!(event_id: payload[:id])
# unique index prevents duplicate processing
```

---


### Q12. How do you design an idempotent Sidekiq job?
**Interview category / level:** Mid / Senior background jobs

**Answer:**
Pass IDs, not full objects. Re-fetch current state. Check whether work already happened. Use database uniqueness or state fields to prevent duplicate side effects. Assume the job can run multiple times.

**Ruby/Rails example:**
```ruby
class SendNotificationJob
  include Sidekiq::Worker
  def perform(notification_id)
    notification = Notification.find_by(id: notification_id)
    return unless notification
    return if notification.sent_at?
    NotificationMailer.notify(notification.id).deliver_now
    notification.update!(sent_at: Time.current)
  end
end
```

---


### Q13. What is the difference between Sidekiq retry and application retry?
**Interview category / level:** Mid background jobs

**Answer:**
Sidekiq retry re-runs the whole job after failure. Application retry handles a smaller operation inside the job, such as an external API call. Do not retry non-idempotent work blindly. Use exponential backoff, jitter, and dead-letter queues for repeated failures.

**Ruby/Rails example:**
```ruby
sidekiq_options retry: 5

rescue ExternalApi::RateLimited => e
  self.class.perform_in(e.retry_after.seconds, id)
end
```

---


### Q14. What is the outbox pattern?
**Interview category / level:** Senior Rails reliability

**Answer:**
The outbox pattern writes an event record in the same database transaction as the business change. A worker later publishes the event to queues, webhooks, search, or notifications. It prevents losing events when the DB commit succeeds but publishing fails.

**Ruby/Rails example:**
```ruby
ActiveRecord::Base.transaction do
  task.update!(status: "closed")
  OutboxEvent.create!(event_type: "task.closed", aggregate_id: task.id, payload: { task_id: task.id })
end
```

---


### Q15. How do you safely add a non-null column to a large table?
**Interview category / level:** Mid / Senior migrations

**Answer:**
Use expand-contract. Add nullable column first. Deploy code that writes it. Backfill in batches. Add a check constraint or NOT NULL after data is complete. Avoid adding a default + not-null in one blocking migration on huge tables unless your PostgreSQL version and operation are proven safe.

**Ruby/Rails example:**
```ruby
add_column :tasks, :priority, :string
# backfill later
add_check_constraint :tasks, "priority IS NOT NULL", name: "tasks_priority_not_null", validate: false
```

---


### Q16. What is optimistic locking?
**Interview category / level:** Mid / Senior database concurrency

**Answer:**
Optimistic locking detects conflicting updates without holding a lock. Rails uses a `lock_version` column. If another process changes the row first, Rails raises `ActiveRecord::StaleObjectError`. Use it for low-contention user edits.

**Ruby/Rails example:**
```ruby
# migration: add_column :documents, :lock_version, :integer, default: 0, null: false
doc.update!(title: "New")
```

---


### Q17. What is pessimistic locking?
**Interview category / level:** Mid / Senior database concurrency

**Answer:**
Pessimistic locking uses database row locks, usually `SELECT ... FOR UPDATE`, to serialize access to critical rows. Use it for inventory, wallet balance, seat allocation, or other high-consistency updates. Keep locks short and never call external services while holding them.

**Ruby/Rails example:**
```ruby
wallet.with_lock do
  raise "insufficient" if wallet.balance < amount
  wallet.update!(balance: wallet.balance - amount)
end
```

---


### Q18. How do you handle race conditions in Rails?
**Interview category / level:** Senior Rails reliability

**Answer:**
Use database constraints, transactions, row locks, optimistic locking, unique indexes, idempotency keys, and retry logic. Do not rely only on `if record.exists?` checks in Ruby because concurrent requests can race.

**Ruby/Rails example:**
```ruby
add_index :task_assignments, [:task_id, :user_id], unique: true
```

---


### Q19. What is a database deadlock and how do you prevent it?
**Interview category / level:** Senior PostgreSQL / Rails

**Answer:**
A deadlock happens when two transactions hold locks the other needs. Prevent it by keeping transactions short, acquiring locks in consistent order, indexing update queries, and retrying deadlock errors safely.

**Ruby/Rails example:**
```ruby
ids = [source_wallet.id, target_wallet.id].sort
Wallet.where(id: ids).lock.index_by(&:id)
```

---


### Q20. How do you handle read replicas and stale reads?
**Interview category / level:** Senior Rails scaling

**Answer:**
Read replicas reduce primary load but can lag behind writes. Do not read from a replica when the user needs read-after-write consistency. Route critical reads to primary, tolerate eventual consistency for dashboards/search, and monitor replica lag.

**Ruby/Rails example:**
```ruby
ActiveRecord::Base.connected_to(role: :reading) do
  Project.where(active: true).limit(20).to_a
end
```

---


### Q21. How do you choose indexes for Rails tables?
**Interview category / level:** Mid / Senior database

**Answer:**
Index columns used in WHERE, JOIN, ORDER BY, and uniqueness constraints. Composite index order matters. Use partial indexes for common subsets such as open tasks. Avoid adding indexes blindly because they slow writes and use storage.

**Ruby/Rails example:**
```ruby
add_index :tasks, [:project_id, :status, :due_date]
add_index :tasks, [:project_id, :due_date], where: "status = 'open'"
```

---


### Q22. What is a counter cache?
**Interview category / level:** Mid Rails performance

**Answer:**
A counter cache stores the count of associated records on the parent row, avoiding repeated COUNT queries. It improves read performance but must be kept consistent. Rails can manage it automatically for basic associations.

**Ruby/Rails example:**
```ruby
class Comment < ApplicationRecord
  belongs_to :post, counter_cache: true
end
```

---


### Q23. What is pagination and why is cursor pagination better for large datasets?
**Interview category / level:** Mid API design

**Answer:**
Pagination limits result size. Offset pagination gets slower for deep pages because the database still scans/skips many rows. Cursor pagination uses a stable field like `created_at` or `id` to fetch the next page efficiently.

**Ruby/Rails example:**
```ruby
Task.where("created_at < ?", cursor).order(created_at: :desc).limit(50)
```

---


### Q24. How do you reduce API payload size?
**Interview category / level:** Mid / Senior API performance

**Answer:**
Return only needed fields, avoid deep nested associations, paginate collections, compress responses, use summary endpoints for lists, and detail endpoints for rich data. Measure response size and serializer time.

**Ruby/Rails example:**
```ruby
render json: TaskSerializer.render(tasks, view: :summary)
```

---


### Q25. What causes memory bloat in Rails?
**Interview category / level:** Mid / Senior runtime

**Answer:**
Memory bloat comes from large temporary allocations: loading huge ActiveRecord collections, serializing large JSON, building giant arrays/strings, or processing files in memory. GC can reclaim objects but RSS may remain high. Use batching, streaming, `pluck`, and smaller serializers.

**Ruby/Rails example:**
```ruby
Task.where(project_id: id).find_each(batch_size: 1000) { |task| ProcessTask.call(task) }
```

---


### Q26. What is the difference between memory leak and memory bloat?
**Interview category / level:** Senior runtime

**Answer:**
A leak means objects remain referenced forever and cannot be garbage-collected. Bloat means temporary allocations force the process memory up and the OS does not immediately reclaim it. Leaks grow continuously; bloat spikes after heavy requests/jobs.

**Ruby/Rails example:**
```ruby
CACHE = []
# Leak risk if this grows forever
CACHE << expensive_payload
```

---


### Q27. How do you debug high database CPU?
**Interview category / level:** Senior production debugging

**Answer:**
Check top queries using `pg_stat_statements`, APM traces, slow logs, query plans, missing indexes, lock waits, connection count, and recent deployments. Mitigate first if customer impact is high, then optimize or roll back.

**Ruby/Rails example:**
```ruby
SELECT query, calls, total_exec_time FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 10;
```

---


### Q28. What should be logged in a Rails API request?
**Interview category / level:** Mid observability

**Answer:**
Log request ID, trace ID, route, status, duration, user/account IDs if allowed, error class, and safe business context. Do not log passwords, tokens, raw request bodies, PII, or secrets.

**Ruby/Rails example:**
```ruby
Rails.logger.info({ request_id: request.request_id, route: request.path, status: response.status }.to_json)
```

---


### Q29. How do you structure authorization in Rails?
**Interview category / level:** Mid / Senior security

**Answer:**
Centralize authorization using policies or permission services. Scope queries by tenant/project. Never rely on frontend hiding buttons. Add tests for denied access and cross-tenant access.

**Ruby/Rails example:**
```ruby
class ProjectPolicy
  def show?
    user.project_ids.include?(record.id)
  end
end
```

---


### Q30. Why is `Project.find(params[:id])` dangerous in multi-tenant apps?
**Interview category / level:** Mid security

**Answer:**
It can fetch a project outside the current user’s tenant if the ID is valid. Always scope through the current tenant or authorized relation.

**Ruby/Rails example:**
```ruby
project = current_company.projects.find(params[:id])
```

---


### Q31. What is `CurrentAttributes` and when should you avoid it?
**Interview category / level:** Mid / Senior Rails architecture

**Answer:**
`ActiveSupport::CurrentAttributes` stores request-local context like current user or tenant. Use sparingly for cross-cutting context. Avoid hiding business dependencies inside it because it makes services hard to test and background jobs unsafe.

**Ruby/Rails example:**
```ruby
class Current < ActiveSupport::CurrentAttributes
  attribute :user, :company
end
```

---


### Q32. What is Rails instrumentation with `ActiveSupport::Notifications`?
**Interview category / level:** Mid observability

**Answer:**
Rails emits events for controller actions, SQL, rendering, cache, and jobs. Subscribers can collect metrics or create traces. Be careful subscribing to high-volume events like SQL in production without sampling.

**Ruby/Rails example:**
```ruby
ActiveSupport::Notifications.subscribe("process_action.action_controller") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  Rails.logger.info(duration: event.duration)
end
```

**Resources:**
- Rails Active Support Instrumentation: https://guides.rubyonrails.org/active_support_instrumentation.html

---


### Q33. What are metrics, logs, and traces?
**Interview category / level:** Mid / Senior observability

**Answer:**
Metrics answer whether something is wrong; logs explain what happened; traces show where time went across a request or workflow. Great observability connects all three using trace IDs and request IDs.

---


### Q34. How would you instrument a Rails service object?
**Interview category / level:** Senior observability

**Answer:**
Add a span around the meaningful business operation, not every line. Record low-cardinality attributes like count, status, queue, and result. Record exceptions. Avoid PII and high-cardinality values unless approved.

**Ruby/Rails example:**
```ruby
tracer.in_span("tasks.complete") do |span|
  span.set_attribute("tasks.id", task.id)
  Tasks::Complete.call(task: task, actor: actor)
rescue => e
  span.record_exception(e)
  raise
end
```

**Resources:**
- OpenTelemetry Ruby instrumentation: https://opentelemetry.io/docs/languages/ruby/instrumentation/

---


### Q35. How do you test service objects?
**Interview category / level:** Mid testing

**Answer:**
Test success path, validation failure, authorization/permission failure, transaction rollback, side effects, and edge cases. Prefer testing behavior over private implementation details.

**Ruby/Rails example:**
```ruby
RSpec.describe Tasks::Complete do
  it "marks task completed and writes activity" do
    expect { described_class.call(task: task, actor: user) }
      .to change { task.reload.status }.to("completed")
      .and change(ActivityLog, :count).by(1)
  end
end
```

---


### Q36. How do you handle flaky tests?
**Interview category / level:** Mid / Senior engineering quality

**Answer:**
Identify whether flakiness comes from time, order dependence, database cleanup, async jobs, external network, random data, or shared global state. Fix the cause; do not just retry forever. Track flaky tests as engineering debt.

---


### Q37. What is contract testing?
**Interview category / level:** Senior distributed systems testing

**Answer:**
Contract testing verifies that a provider service still satisfies consumer expectations. It prevents mocks from drifting from reality in microservices. Useful when extracting Rails monolith domains into services.

---


### Q38. How do you handle feature flags?
**Interview category / level:** Mid / Senior release engineering

**Answer:**
Use flags for gradual rollout, kill switches, migrations, and experiments. Track owner and cleanup date. Avoid leaving flags forever. Instrument impact by flag state.

**Ruby/Rails example:**
```ruby
if Feature.enabled?(:new_task_search, current_company)
  NewTaskSearch.call(params)
else
  LegacyTaskSearch.call(params)
end
```

---


### Q39. How do you design retries for external API calls?
**Interview category / level:** Senior reliability

**Answer:**
Use timeouts, limited retries, exponential backoff with jitter, circuit breakers for repeated failures, idempotency keys for non-read calls, and clear failure states. Do not retry indefinitely.

**Ruby/Rails example:**
```ruby
Retriable.retriable(on: [Timeout::Error], tries: 3, base_interval: 0.5) do
  ExternalClient.post(payload, idempotency_key: key)
end
```

---


### Q40. What is a circuit breaker?
**Interview category / level:** Senior reliability

**Answer:**
A circuit breaker stops calling an unhealthy dependency after repeated failures. It moves through closed, open, and half-open states. It protects your app from thread exhaustion and cascading failures.

---


### Q41. How do you safely process large CSV imports?
**Interview category / level:** Mid / Senior backend

**Answer:**
Stream the file line by line, validate rows, batch inserts, track progress, make processing idempotent, handle partial failure, and avoid loading the entire file into memory.

**Ruby/Rails example:**
```ruby
CSV.foreach(file.path, headers: true).each_slice(1000) do |rows|
  User.insert_all(rows.map { |r| { email: r["email"] } })
end
```

---


### Q42. How do you design a large export?
**Interview category / level:** Mid / Senior backend

**Answer:**
Run exports asynchronously, stream/batch database reads, write to a temp file or object storage, notify the user when ready, and enforce permissions at generation time. Avoid building giant strings in memory.

**Ruby/Rails example:**
```ruby
Tempfile.create(["tasks", ".csv"]) do |file|
  Task.find_each { |task| file.write(CSV.generate_line([task.id, task.title])) }
end
```

---


### Q43. What is JSONB in PostgreSQL and when should you use it?
**Interview category / level:** Mid / Senior PostgreSQL

**Answer:**
JSONB stores semi-structured data in PostgreSQL. Use it for flexible metadata that does not need strict relational constraints. Add GIN or expression indexes for queried keys. Do not use JSONB to avoid proper modeling for core domain data.

**Ruby/Rails example:**
```ruby
add_column :projects, :metadata, :jsonb, default: {}, null: false
add_index :projects, :metadata, using: :gin
```

---


### Q44. What are partial indexes?
**Interview category / level:** Mid / Senior PostgreSQL

**Answer:**
A partial index indexes only rows matching a condition. It is useful when most queries target a subset, such as open tasks or active users.

**Ruby/Rails example:**
```ruby
add_index :tasks, [:project_id, :due_date], where: "status = 'open'"
```

---


### Q45. What are materialized views?
**Interview category / level:** Senior PostgreSQL / reporting

**Answer:**
A materialized view stores the result of a query and must be refreshed. It is useful for dashboards and reports where slightly stale data is acceptable. Use `REFRESH MATERIALIZED VIEW CONCURRENTLY` when possible.

**Ruby/Rails example:**
```ruby
execute "REFRESH MATERIALIZED VIEW CONCURRENTLY project_dashboard_summaries"
```

---


### Q46. How do you design for tenant isolation?
**Interview category / level:** Senior SaaS architecture

**Answer:**
Scope all data by tenant/company/project, enforce backend authorization, add indexes including tenant keys, test cross-tenant access, and consider row-level security for high-risk data. Never trust the frontend for tenant isolation.

**Ruby/Rails example:**
```ruby
current_company.projects.find(params[:project_id])
```

---


### Q47. What is the difference between RBAC and ABAC?
**Interview category / level:** Mid / Senior security architecture

**Answer:**
RBAC grants access based on roles. ABAC grants access based on attributes such as resource state, tenant, ownership, project status, or company relationship. A hybrid is common in complex SaaS systems.

---


### Q48. How do you approach production incident response?
**Interview category / level:** Senior / Team Lead operations

**Answer:**
Confirm impact, mitigate first, communicate clearly, inspect metrics/logs/traces, identify recent changes, find root cause, add prevention, and write a blameless postmortem. The first priority is reducing customer impact.

---


### Q49. What belongs in a postmortem?
**Interview category / level:** Senior / Team Lead operations

**Answer:**
Timeline, impact, detection, root cause, contributing factors, what went well, what went poorly, action items, owners, due dates, and prevention. Avoid blame; focus on system improvements.

---


### Q50. How do you mentor engineers through code review?
**Interview category / level:** Senior / Staff leadership

**Answer:**
Give context, not just comments. Explain the risk, suggest a path, pair when needed, and turn repeated issues into documentation, linters, templates, or examples. Protect both code quality and the relationship.

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
