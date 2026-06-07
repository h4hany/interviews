# Performance & Optimization — N+1, Payload, Memory, Indexing, Profiling

> Highly relevant — JD explicitly mentions "highly performant code that minimizes payload size and resource consumption."

---

## 1. Systematic Debugging Approach

**Never guess. Always measure first.**

```text
1. Check production signals (p95/p99 latency, traces, logs, error rate)
2. Compare fast vs slow traces
3. Break down: controller → DB → external calls → serialization → queue
4. Identify the bottleneck
5. Apply smallest high-impact fix
6. Verify with before/after metrics
7. Add regression protection
```

---

## 2. N+1 Query Detection & Resolution

### What Is N+1?
Loading a collection (1 query), then running another query per item (N queries).

```ruby
# BAD: N+1 — one query per project for tasks
projects = Project.all
projects.each { |p| puts p.tasks.count }

# GOOD: Eager loading
projects = Project.includes(:tasks).all
```

### Detection Methods
| Tool | Where |
|------|-------|
| `bullet` gem | Development — warns about N+1 |
| `rack-mini-profiler` | Development — visual SQL count |
| APM traces | Production — repeated similar SQL spans |
| Rails logs | Development — repeated `SELECT` statements |
| Test assertions | CI — assert max query count |

### Fix Strategies

| Situation | Fix |
|-----------|-----|
| Simple association access | `includes(:association)` |
| Filtering on association | `eager_load(:association).where(...)` |
| Only need count | `counter_cache: true` |
| Only need IDs | `pluck(:id)` |
| Large association | Targeted query instead of eager load |

### When NOT to Eager Load
> "Fixing N+1 is not always just adding includes. Sometimes eager loading too much data increases memory and makes things worse. If the association is huge, use targeted queries, counters, or denormalized read models."

---

## 3. Payload Optimization

### Reduce Response Size
1. **Remove unused fields** from serializers — only return what the client needs
2. **Avoid deeply nested objects** — use IDs or summary objects instead
3. **Separate list vs detail endpoints** — list returns summaries, detail returns full data
4. **Paginate everything** — never return unbounded data
5. **Support sparse fieldsets** — `?fields=id,title,status`
6. **Compress responses** — gzip/brotli
7. **Use cursor pagination** over offset for large datasets

```ruby
# BAD: Returns everything
render json: @projects, include: [:tasks, :rfis, :documents, :users]

# GOOD: Returns only what's needed
render json: @projects, 
  only: [:id, :name, :status, :updated_at],
  include: { tasks: { only: [:id, :title, :status] } }
```

### Cursor Pagination
```http
GET /api/v1/projects/:project_id/tasks?cursor=abc&limit=50
```
Offset pagination (`page=100`) becomes slow on large datasets because the DB must skip all prior rows.

---

## 4. Query Optimization

### Process
1. Capture the SQL → `Task.where(...).to_sql`
2. Run `EXPLAIN ANALYZE` in PostgreSQL
3. Check index usage and scan type (Seq Scan vs Index Scan)
4. Look at estimated vs actual rows
5. Add or adjust indexes

### Index Strategies

```ruby
# Composite index for common queries
add_index :tasks, [:project_id, :status]
add_index :tasks, [:project_id, :due_date]
add_index :tasks, [:company_id, :status, :due_date]

# Partial index for frequent filter
add_index :tasks, :due_date, where: "status != 'closed'"

# Concurrent index creation (no write lock)
add_index :tasks, :project_id, algorithm: :concurrently
```

### Column Order Matters
For composite indexes, put the **equality column first**, then the **range/sort column**:
```sql
-- Good: equality (status) first, range (due_date) second
CREATE INDEX ON tasks(project_id, status, due_date);
```

### Select Only What You Need
```ruby
# BAD
Task.all.map(&:title)

# GOOD
Task.pluck(:title)

# If you need model instances but not all columns
Task.select(:id, :title, :status)
```

> "I avoid adding indexes blindly because they slow writes and increase storage. I add indexes based on actual query patterns."

---

## 5. Memory Optimization

### Common Memory Issues
- Loading too many ActiveRecord objects
- Large JSON serialization
- Unbounded arrays/hashes
- Background jobs processing large batches in memory
- Memory leaks through class variables or global caches

### Fixes

```ruby
# BAD: Loads all records into memory
User.all.each { |u| process(u) }

# GOOD: Batch processing
User.find_each(batch_size: 1000) { |u| process(u) }

# BAD: Load full objects for scalar values
User.all.map(&:email)

# GOOD: Direct SQL for scalar values
User.pluck(:email)
```

### Large Exports
- Generate asynchronously in background job
- Stream to file/S3, don't hold in memory
- Notify user when ready
- Set download expiration

### Monitoring
- Track RSS memory per process
- Track GC time and frequency
- Track object allocation hotspots
- Track container restarts (OOM kills)

> "I would not start with memory profiling. I would first check if the endpoint or job is loading more data than it needs."

---

## 6. Caching Strategy

### When to Cache
- Read-heavy, stable data
- Computed aggregates that don't change every request
- Permission lookups (with careful invalidation)
- Project metadata

### Cache Invalidation Rules
- Define invalidation **before** adding cache
- Use cache keys with version/timestamp
- Set sensible TTLs
- Never use cache as source of truth

```ruby
Rails.cache.fetch(["project-tasks-count", project.id, project.updated_at], 
                   expires_in: 10.minutes) do
  project.tasks.count
end
```

### Redis Caching for Procore-Style
```text
Cache Key: project:{id}:rfi_counts_by_status
Invalidate: when any RFI status changes in that project
TTL: 5 minutes
```

---

## 7. Rails-Specific Performance Tools

| Tool | Purpose |
|------|---------|
| `bullet` gem | N+1 detection in development |
| `rack-mini-profiler` | Request profiling (SQL, memory, time) |
| `EXPLAIN ANALYZE` | PostgreSQL query plan analysis |
| `strong_migrations` | Catch dangerous migrations |
| `SimpleCov` | Test coverage tracking |
| `benchmark-ips` | Ruby micro-benchmarks |
| `memory_profiler` | Object allocation analysis |
| `derailed_benchmarks` | Boot-time memory usage |
| `counter_cache` | Avoid COUNT queries |

---

## 8. Performance STAR Story (Your Template)

**Situation:** AI recommendation endpoint degraded to 800ms p95 under moderate load.

**Task:** Bring p95 below 100ms and reduce API costs without degrading quality.

**Action (three layers):**
1. **N+1 elimination** — Used `rack-mini-profiler` + `bullet` to find serializer triggering 1 query per item. Added `includes(:tags, :category)` and custom serialization with Blueprinter.
2. **Semantic caching** — Before hitting OpenAI for embeddings, query pgvector for similar cached prompts (cosine similarity > 0.92). Cache hit rate reached ~68%, cutting API costs ~80%.
3. **Payload optimization** — Removed unused JSON fields (40% size reduction), introduced cursor pagination, added `fields` query parameter for sparse fieldsets.

**Result:** p95 dropped from 800ms to sub-100ms, API costs down ~80%, caching layer became reusable.

---

## 9. Debugging Intermittent 500 Errors

### Approach
1. Group errors by exception class, endpoint, account, deploy version, trace ID
2. Inspect representative traces and logs
3. Look for patterns: specific accounts, data sizes, timing

### Common Causes
- Race conditions (concurrent updates)
- Nil assumptions on optional associations
- External API timeouts
- Database deadlocks
- Background job retries creating conflicts
- Cache inconsistency
- Feature flag edge cases

### Resolution
1. Add targeted instrumentation if telemetry is insufficient
2. Fix the root cause
3. Add tests for the failing scenario
4. Monitor error rate after rollout

---

## 10. Quick Reference: What to Measure

| Metric | What It Tells You |
|--------|-------------------|
| **p95/p99 latency** | Worst-case user experience |
| **SQL query count** | N+1 problems |
| **SQL query duration** | Missing indexes, slow queries |
| **Payload size** | Over-serialization |
| **Memory RSS** | Memory bloat |
| **GC time** | Allocation pressure |
| **Cache hit rate** | Cache effectiveness |
| **Error rate** | Reliability |
| **Queue depth** | Background job backlog |
| **External API latency** | Dependency health |
