# Procore Staff Software Engineer - Ruby on Rails Runtime Interview Master Guide

Prepared for: **Staff Software Engineer - RoR, Procore Technologies, Cairo**  
Interview focus: **Specialized Technical Interview, Runtime team, Ruby/Rails refactoring, OpenTelemetry, observability, performance, production debugging**  
Likely interviewer level: **Principal Software Engineer**

---

## 0. How to use this guide

This is not a normal Rails CRUD interview guide. Based on the job description and prep email, expect the interviewer to evaluate whether you can:

1. Refactor existing Ruby/Rails code safely.
2. Explain tradeoffs clearly at Staff level.
3. Design instrumentation that makes production behavior visible.
4. Use OpenTelemetry correctly, not just add spans randomly.
5. Improve scalability, performance, reliability, and maintainability.
6. Mentor engineers through code reviews, testing, and technical clarity.
7. Think like a platform/runtime engineer who helps many product teams.

For every answer, try to speak in this pattern:

```text
First I would clarify the behavior and constraints.
Then I would add tests around the existing behavior.
Then I would refactor in small steps.
Then I would add instrumentation to prove whether the change improved production behavior.
Finally I would document the tradeoffs and rollout plan.
```

That pattern is very strong for a Principal Engineer interview because it shows judgment, not only syntax.

---

## 1. Research notes used for this guide

The current Procore observability-related role descriptions emphasize OpenTelemetry adoption, Honeycomb/Datadog visibility, golden paths for telemetry, observability enablement, and helping product teams move from blind to informed debugging.

Public references used while preparing this guide:

- Procore Staff Software Engineer - Observability Cairo job description: https://careers.procore.com/jobs/staff-software-engineer-observability-cairo-egypt-5d161b1a-5b33-411d-baf1-dcde1f136adb
- Procore observability job mirrors mentioning OpenTelemetry, Honeycomb, Datadog, Golden Paths, and follow-the-sun support: https://builtin.com/job/senior-software-engineer-observability/9137781
- Rails Active Support Instrumentation guide: https://guides.rubyonrails.org/active_support_instrumentation.html
- OpenTelemetry Ruby instrumentation docs: https://opentelemetry.io/docs/languages/ruby/instrumentation/
- OpenTelemetry Ruby getting started docs: https://opentelemetry.io/docs/languages/ruby/getting-started/
- OpenTelemetry HTTP semantic conventions: https://opentelemetry.io/docs/specs/semconv/http/http-spans/
- OpenTelemetry database semantic conventions: https://opentelemetry.io/docs/specs/semconv/db/database-spans/
- OpenTelemetry Collector processors docs: https://opentelemetry.io/docs/collector/components/processor/
- OpenTelemetry sampling docs: https://opentelemetry.io/docs/concepts/sampling/
- OpenTelemetry Collector tail sampling processor docs: https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/processor/tailsamplingprocessor/README.md
- Datadog Ruby tracing docs: https://docs.datadoghq.com/tracing/trace_collection/dd_libraries/ruby/

---

# Part 1: Your previous live-coding task and how it may come back

You already passed the first live-coding round with a `WorkScheduler`. In the specialized round, they may reuse the same domain but ask you to refactor, improve complexity, add tests, find bugs, instrument the code, or discuss production readiness.

Original behavior summary:

```ruby
class WorkScheduler
  def initialize(workers)
    @workers = workers
    @workers_by_trades = Hash.new { |h, k| h[k] = [] }
    @workers.each do |worker|
      worker.trades.each do |trade|
        @workers_by_trades[trade] << worker
      end
    end
    @workers_by_trades.values.each { |list| list.sort_by!(&:cost) }
  end

  def suitable_workers(trade)
    @workers_by_trades[trade].map(&:email).sort
  end

  def schedule_one_day(trades)
    used_workers = Set.new
    schedule_workers = []
    trades.each do |trade|
      worker = @workers_by_trades[trade].find { |w| !used_workers.include?(w.email) }
      if worker
        used_workers.add(worker.email)
        schedule_workers << worker.email
      end
    end
    schedule_workers
  end

  def schedule_all_tasks(trades)
    result = []
    remaining_trades = trades.dup
    until remaining_trades.empty?
      schedule_day = []
      used_workers = Set.new
      unfulfilled_trades = []
      remaining_trades.each do |trade|
        worker = @workers_by_trades[trade].find { |w| !used_workers.include?(w.email) }
        if worker
          used_workers.add(worker.email)
          schedule_day << worker.email
        else
          unfulfilled_trades << trade
        end
      end
      result << schedule_day
      remaining_trades = unfulfilled_trades
    end
    result
  end
end
```

## 1.1 Important risks in this code

### Risk 1: Infinite loop when a trade has no worker

If `remaining_trades` contains a trade that no worker can do, `schedule_day` stays empty and `unfulfilled_trades` remains the same forever.

A Staff-level answer should say:

> I would protect the loop with an impossible-task check. Before scheduling, validate that every requested trade has at least one eligible worker. During the loop, if a day schedules zero tasks, raise a domain error instead of looping forever.

### Risk 2: Greedy strategy may not always minimize days globally

The code chooses the cheapest available worker for each trade in the given order. That is simple and often acceptable, but the problem of assigning workers to trades across days can become a matching/optimization problem.

A Staff-level answer should say:

> If the requirement is truly minimum number of days, I would confirm whether greedy is acceptable. If not, I would model each day as a bipartite matching problem between trades and workers. Greedy is easier and faster to implement, but it can fail when local cheapest choices block a better global assignment.

### Risk 3: It returns only emails, not trade-to-worker pairs

`schedule_one_day` returns only worker emails. If the caller needs to know which worker was assigned to which trade, the result is ambiguous.

Better return shape:

```ruby
[
  { trade: "plumbing", worker_email: "a@example.com" },
  { trade: "electrical", worker_email: "b@example.com" }
]
```

### Risk 4: Tie-breaking is not explicit

Workers are sorted by cost only. If two workers have the same cost, the order depends on input order. For deterministic behavior, sort by `[cost, email]`.

```ruby
@workers_by_trade.values.each { |workers| workers.sort_by! { |w| [w.cost, w.email] } }
```

### Risk 5: `get_worker` is dead code

The private method is not used. In a refactor interview, mention that dead code increases maintenance cost and should be removed after tests confirm it is unused.

### Risk 6: `Set` requires `require "set"`

In standalone Ruby, `Set` is not available unless required. In Rails, it may appear loaded depending on environment, but production code should be explicit.

```ruby
require "set"
```

---

## 1.2 Refactored version of the scheduler

This version improves naming, determinism, error handling, and testability.

```ruby
require "set"

class WorkScheduler
  class UnschedulableTradeError < StandardError; end

  Assignment = Struct.new(:trade, :worker_email, keyword_init: true)

  def initialize(workers)
    @workers = workers
    @workers_by_trade = build_worker_index(workers)
  end

  def suitable_workers(trade)
    @workers_by_trade.fetch(trade, []).map(&:email).sort
  end

  def schedule_one_day(trades)
    used_worker_emails = Set.new

    trades.each_with_object([]) do |trade, assignments|
      worker = cheapest_available_worker_for(trade, used_worker_emails)
      next unless worker

      used_worker_emails.add(worker.email)
      assignments << Assignment.new(trade: trade, worker_email: worker.email)
    end
  end

  def schedule_all_tasks(trades)
    validate_schedulable!(trades)

    days = []
    remaining_trades = trades.dup

    until remaining_trades.empty?
      assignments = schedule_one_day(remaining_trades)

      if assignments.empty?
        raise UnschedulableTradeError, "No progress made while scheduling trades"
      end

      scheduled_trades = assignments.map(&:trade)
      days << assignments
      remaining_trades = remove_scheduled_trades(remaining_trades, scheduled_trades)
    end

    days
  end

  private

  attr_reader :workers_by_trade

  def build_worker_index(workers)
    workers.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |worker, index|
      worker.trades.each do |trade|
        index[trade] << worker
      end
    end.tap do |index|
      index.values.each { |list| list.sort_by! { |worker| [worker.cost, worker.email] } }
    end
  end

  def cheapest_available_worker_for(trade, used_worker_emails)
    workers_by_trade.fetch(trade, []).find do |worker|
      !used_worker_emails.include?(worker.email)
    end
  end

  def validate_schedulable!(trades)
    missing_trades = trades.uniq.select { |trade| workers_by_trade.fetch(trade, []).empty? }
    return if missing_trades.empty?

    raise UnschedulableTradeError, "No workers available for: #{missing_trades.join(', ')}"
  end

  def remove_scheduled_trades(remaining_trades, scheduled_trades)
    scheduled_counts = scheduled_trades.tally

    remaining_trades.reject do |trade|
      if scheduled_counts[trade].to_i.positive?
        scheduled_counts[trade] -= 1
        true
      else
        false
      end
    end
  end
end

class Worker
  attr_reader :email, :trades, :cost

  def initialize(email, trades, cost)
    @email = email
    @trades = trades
    @cost = cost
  end
end
```

### Why this refactor is stronger

- Uses explicit error class for domain failure.
- Avoids infinite loops.
- Keeps the worker index private.
- Makes tie-breaking deterministic.
- Returns richer assignment objects.
- Removes unused logic.
- Is easier to test because each method has a single responsibility.

---

## 1.3 RSpec tests they may expect you to write

```ruby
RSpec.describe WorkScheduler do
  let(:alice) { Worker.new("alice@example.com", ["plumbing", "electrical"], 100) }
  let(:bob)   { Worker.new("bob@example.com", ["plumbing"], 80) }
  let(:cara)  { Worker.new("cara@example.com", ["electrical"], 90) }

  subject(:scheduler) { described_class.new([alice, bob, cara]) }

  describe "#suitable_workers" do
    it "returns emails sorted alphabetically" do
      expect(scheduler.suitable_workers("plumbing")).to eq([
        "alice@example.com",
        "bob@example.com"
      ])
    end
  end

  describe "#schedule_one_day" do
    it "assigns each worker at most once" do
      assignments = scheduler.schedule_one_day(["plumbing", "electrical"])
      emails = assignments.map(&:worker_email)

      expect(emails).to eq(emails.uniq)
    end

    it "chooses the cheapest available worker for each trade" do
      assignments = scheduler.schedule_one_day(["plumbing"])

      expect(assignments.first.worker_email).to eq("bob@example.com")
    end
  end

  describe "#schedule_all_tasks" do
    it "schedules all tasks across multiple days" do
      days = scheduler.schedule_all_tasks(["plumbing", "plumbing", "electrical"])

      expect(days.flatten.map(&:trade)).to contain_exactly("plumbing", "plumbing", "electrical")
    end

    it "raises an error when a trade has no worker" do
      expect {
        scheduler.schedule_all_tasks(["roofing"])
      }.to raise_error(WorkScheduler::UnschedulableTradeError)
    end
  end
end
```

---

## 1.4 How to instrument this code with OpenTelemetry

A Runtime/Observability interviewer may ask: “How would you make this code observable?”

Good answer:

> I would not add logs everywhere. I would identify the main operation, create a span around scheduling, add low-cardinality attributes such as number of trades, number of workers, number of days, result status, and error class. I would avoid high-cardinality attributes like every worker email unless needed in controlled debug mode, because that can increase cost and reduce query quality.

Example:

```ruby
tracer = OpenTelemetry.tracer_provider.tracer("work_scheduler")

tracer.in_span("work_scheduler.schedule_all_tasks") do |span|
  span.set_attribute("scheduler.trades.count", trades.size)
  span.set_attribute("scheduler.workers.count", @workers.size)

  days = schedule_all_tasks_without_instrumentation(trades)

  span.set_attribute("scheduler.days.count", days.size)
  span.set_status(OpenTelemetry::Trace::Status.ok)

  days
rescue => error
  span.record_exception(error)
  span.set_status(OpenTelemetry::Trace::Status.error(error.message))
  raise
end
```

What to mention:

- Add spans around meaningful business operations.
- Use semantic conventions where possible.
- Use custom namespaced attributes for domain concepts.
- Avoid PII and high-cardinality attributes.
- Record exceptions and preserve trace context.
- Correlate logs with trace IDs.
- Add metrics for scheduling duration, failure count, and task volume.

---

# Part 2: Recommended interview questions and answers

Each question includes a likely level. Since the interviewer is Principal level and the role is Staff, many questions are written to test beyond implementation.

---

# Section A: Ruby refactoring and code quality

## 1. How would you approach refactoring unfamiliar Ruby code in an interview?

**Grade:** Staff  
**Likely asked:** Very high

**Answer:**

I would start by clarifying the expected behavior, inputs, outputs, and edge cases. Then I would add characterization tests around the current behavior before changing structure. After that, I would refactor in small safe steps: improve names, extract methods, remove duplication, isolate side effects, and reduce hidden state.

I would avoid large rewrites unless the current design blocks correctness or scalability. In production, I would also compare metrics before and after the refactor, such as latency, allocation rate, query count, error rate, and memory usage.

A Staff-level refactor is not only about making code prettier. It is about reducing risk while improving clarity, testability, and future change cost.

---

## 2. What would you improve in the `WorkScheduler` code?

**Grade:** Staff  
**Likely asked:** Very high

**Answer:**

I would improve six things.

First, I would prevent infinite loops when a trade cannot be scheduled. The current `schedule_all_tasks` can loop forever if no worker supports a trade.

Second, I would make the result more explicit. Returning only emails loses the relationship between trade and worker. A better shape is an assignment object containing `trade` and `worker_email`.

Third, I would make tie-breaking deterministic by sorting workers by `[cost, email]`, not only cost.

Fourth, I would remove the unused `get_worker` method because dead code creates confusion.

Fifth, I would require `set` explicitly because the code depends on `Set`.

Sixth, I would add tests for impossible trades, duplicate trades, cost tie-breaks, and the rule that one worker cannot be assigned twice in the same day.

---

## 3. Is the greedy scheduling algorithm always optimal?

**Grade:** Staff / Principal  
**Likely asked:** High

**Answer:**

Not necessarily. The greedy approach chooses the cheapest available worker for each trade in input order. That may be acceptable if the business requirement prioritizes simplicity and cost locally, but it does not guarantee a globally optimal schedule for all possible inputs.

If the requirement is truly “minimum number of days,” I would model each day as a bipartite matching problem between remaining trades and available workers. That helps maximize assignments per day. If cost also matters, I would consider minimum-cost maximum matching.

In an interview, I would say:

> The current algorithm is a pragmatic greedy solution. I would confirm whether “minimum days” is a hard correctness requirement or an approximation. If hard, I would move from greedy selection to matching.

---

## 4. How would you explain Big O complexity of the current scheduler?

**Grade:** Senior  
**Likely asked:** Medium

**Answer:**

Let:

- `W` = number of workers
- `T` = number of requested trades
- `K` = average number of trades per worker
- `M` = average number of workers per trade

Initialization builds an index by trade, so it is roughly `O(W * K)`, plus sorting each worker list. If many workers support the same trade, sorting can approach `O(W log W)` per trade group.

`suitable_workers(trade)` uses the index, so it avoids scanning all workers. It maps emails and sorts alphabetically. If `M` workers support the trade, complexity is `O(M log M)` because of email sorting.

`schedule_one_day(trades)` checks each trade and finds the first unused worker in a sorted list. Worst case is `O(T * M)`.

`schedule_all_tasks` repeats scheduling until all trades are fulfilled. Worst case depends on number of days. If `D` is number of days, complexity is about `O(D * T * M)`.

---

## 5. How do you decide between keeping code simple and using a more complex algorithm?

**Grade:** Staff / Principal  
**Likely asked:** High

**Answer:**

I decide based on correctness requirements, data size, operational impact, and change cost.

If the greedy algorithm gives acceptable results and data size is small, I would keep it simple and document the limitation. If incorrect scheduling has business cost or the data grows, I would use a matching algorithm and add tests proving optimality.

At Staff level, the key is not to over-engineer early, but also not to hide a known correctness limitation. I would document the tradeoff and define the signal that tells us when to revisit it, such as failure rate, schedule quality, or customer impact.

---

## 6. What makes Ruby code maintainable at scale?

**Grade:** Staff  
**Likely asked:** Medium

**Answer:**

Maintainable Ruby code has clear names, small objects, explicit boundaries, predictable side effects, and good tests. It should be easy to understand without knowing the whole system.

In Rails, I also care about keeping controllers thin, keeping models focused, extracting complex workflows into service/domain objects, avoiding hidden callback chains, and making database queries visible.

At scale, maintainability also means observability. If a service object performs a critical workflow, it should emit useful traces, metrics, and structured logs so production behavior can be understood.

---

## 7. When would you use a service object in Rails?

**Grade:** Senior  
**Likely asked:** High

**Answer:**

I use a service object when an operation represents an application workflow that does not belong cleanly inside one Active Record model or controller.

Examples:

- Creating a receipt and calculating cashback.
- Scheduling work across multiple entities.
- Calling an external API and persisting the result.
- Running a multi-step import.
- Generating a report.

A good service object has a clear name, a small public API, explicit inputs, predictable return values, and tests around success and failure paths.

Bad service objects become dumping grounds. If a service grows too large, I split it by domain responsibility or introduce command/result objects.

---

## 8. How would you structure errors in service objects?

**Grade:** Senior / Staff  
**Likely asked:** Medium

**Answer:**

I prefer explicit domain errors for expected business failures and exceptions for unexpected failures.

For example:

```ruby
class WorkScheduler
  class UnschedulableTradeError < StandardError; end
end
```

For user-facing flows, I may return a result object:

```ruby
Result = Struct.new(:success?, :value, :error, keyword_init: true)
```

For infrastructure failures like database errors, external API timeouts, or serialization issues, I usually let exceptions bubble to a boundary where they are logged, traced, retried, or converted to an API response.

The important part is consistency. Teams should know when to expect a returned failure versus a raised exception.

---

## 9. How do you review a refactor PR as a Staff engineer?

**Grade:** Staff  
**Likely asked:** Medium

**Answer:**

I review whether the refactor preserves behavior, improves clarity, reduces risk, and has enough test coverage.

I look for:

- Are behavior changes intentional and documented?
- Are tests covering edge cases and previous bugs?
- Is the new abstraction easier to understand?
- Did we reduce duplication or just move it around?
- Did performance or query behavior change?
- Are instrumentation and logs still useful?
- Is the rollout safe?

For a large refactor, I prefer small PRs: first add tests, then extract structure, then change behavior if needed.

---

## 10. How would you handle a Principal Engineer challenging your code design?

**Grade:** Staff  
**Likely asked:** Medium

**Answer:**

I would treat it as a design discussion, not a defense. I would explain the constraints I optimized for, acknowledge tradeoffs, and ask what risk they are most concerned about.

A strong answer sounds like:

> I chose the simpler greedy implementation because it satisfies the current constraints and is easy to reason about. The tradeoff is that it may not be globally optimal. If minimum days is strict, I would replace this with bipartite matching. I would add tests to demonstrate the failure case before changing the algorithm.

This shows humility and technical judgment.

---

# Section B: Rails performance and runtime behavior

## 11. How do you investigate a slow Rails endpoint?

**Grade:** Staff  
**Likely asked:** Very high

**Answer:**

I start with production evidence, not guesses. I check traces, logs, metrics, and recent deploys. I look at total latency and break it down into controller time, database time, view/render time, external calls, cache calls, and background job side effects.

Then I identify whether the slowness is broad or isolated. I compare fast and slow traces. I check request parameters, account size, data volume, N+1 queries, missing indexes, lock contention, slow external services, payload size, and memory allocations.

After finding the bottleneck, I fix the smallest high-impact issue, add a regression test or instrumentation, and verify improvement using before/after telemetry.

---

## 12. What is an N+1 query and how do you detect it?

**Grade:** Senior  
**Likely asked:** High

**Answer:**

An N+1 query happens when Rails loads a collection and then runs another query per item in the collection.

Example:

```ruby
projects = Project.all
projects.each do |project|
  puts project.tasks.count
end
```

This can run one query for projects plus one query per project.

I detect it through logs, development tools like Bullet, database query count tests, and traces that show repeated similar SQL spans.

I fix it using `includes`, `preload`, `eager_load`, joins with aggregation, counter caches, or query restructuring depending on the access pattern.

---

## 13. What is the difference between `includes`, `preload`, `eager_load`, and `joins`?

**Grade:** Senior  
**Likely asked:** High

**Answer:**

`includes` is Rails’ flexible eager loading API. Rails may use separate queries or a `LEFT OUTER JOIN` depending on whether the associated table is referenced.

`preload` always uses separate queries. It is useful when I want to avoid large joined result sets.

`eager_load` always uses a `LEFT OUTER JOIN`. It can be useful when filtering or ordering by associated columns, but it can create duplicated rows and heavier SQL.

`joins` creates an SQL join for filtering, but it does not preload association objects. If I use `joins` and later access the association, I can still get N+1 queries.

---

## 14. How do you reduce payload size in a Rails API?

**Grade:** Staff  
**Likely asked:** High because the JD mentions payload size

**Answer:**

I reduce payload size by returning only fields the client needs, avoiding deeply nested associations, paginating large collections, compressing responses, using sparse fieldsets when appropriate, and moving expensive optional data behind separate endpoints or lazy loading.

I also check serializer behavior. A serializer can accidentally trigger N+1 queries or include large nested objects. I would measure response body size, serialization time, database time, and frontend usage.

At Staff level, I would also coordinate with Product and UX. Sometimes the best backend optimization is changing the interaction so the client does not need all data upfront.

---

## 15. What causes high memory usage in Rails?

**Grade:** Senior / Staff  
**Likely asked:** Medium

**Answer:**

Common causes include loading too many Active Record objects, large JSON serialization, unbounded arrays, inefficient background jobs, memory leaks through class variables or global caches, large file processing in memory, and high concurrency with large per-request allocations.

To investigate, I would look at memory metrics, GC behavior, object allocations, heap dumps if needed, and traces for endpoints or jobs with large payloads.

Typical fixes include batching with `find_each`, using `pluck` for scalar values, streaming large files, limiting preloads, reducing object allocations, using pagination, and moving heavy work to background jobs.

---

## 16. How do you handle large database updates in Rails?

**Grade:** Staff  
**Likely asked:** Medium

**Answer:**

I avoid loading all records into memory. I use batches, id ranges, or background jobs. I also consider locking, transaction size, replication lag, and index impact.

For example:

```ruby
User.where(active: true).find_in_batches(batch_size: 1_000) do |users|
  User.where(id: users.map(&:id)).update_all(processed: true)
end
```

For production migrations, I avoid long blocking migrations. I add columns safely, backfill in batches, add indexes concurrently where supported, and deploy in multiple steps.

---

## 17. How do you avoid dangerous Rails migrations?

**Grade:** Staff  
**Likely asked:** Medium

**Answer:**

I avoid operations that lock large tables for a long time. For PostgreSQL, I use concurrent indexes, split schema and data changes, backfill asynchronously, and avoid adding a non-null column with a default in one step on large tables.

A safe flow is:

1. Add nullable column.
2. Deploy code that writes both old and new columns if needed.
3. Backfill in batches.
4. Add constraint or validation after data is clean.
5. Remove old code or column later.

The exact steps depend on database version and table size, so I verify the migration plan against production scale.

---

## 18. What is your approach to caching in Rails?

**Grade:** Senior / Staff  
**Likely asked:** Medium

**Answer:**

I use caching only after I understand the bottleneck. Caching can reduce load but introduces invalidation complexity.

Rails caching options include fragment caching, low-level caching with `Rails.cache`, HTTP caching, Russian doll caching, and database counter caches.

At scale, I define the cache key carefully, include versioning, set sensible TTLs, and instrument hit rate, miss rate, payload size, and cache latency.

I avoid caching sensitive data without clear isolation, and I avoid using cache as the source of truth.

---

## 19. How would you debug intermittent 500 errors in Rails?

**Grade:** Staff  
**Likely asked:** High

**Answer:**

I would start by grouping errors by exception class, endpoint, account, deploy version, and trace ID. Then I would inspect representative traces and logs to identify the failing dependency or code path.

Intermittent errors often come from race conditions, nil assumptions, external API timeouts, database deadlocks, background job retries, cache inconsistency, or feature flags.

I would add targeted instrumentation if the current telemetry is insufficient. Then I would fix the cause, add tests for the failing scenario, and monitor error rate after rollout.

---

## 20. How do you think about database indexes?

**Grade:** Senior  
**Likely asked:** Medium

**Answer:**

Indexes speed up reads but slow down writes and consume storage, so I add them based on query patterns, not guesses.

I inspect slow queries and `EXPLAIN` plans. I consider columns used in `WHERE`, `JOIN`, `ORDER BY`, and uniqueness constraints. For compound indexes, column order matters. I also consider partial indexes for common filtered conditions.

After adding an index, I verify that the query planner uses it and that write overhead is acceptable.

---

# Section C: OpenTelemetry and observability

## 21. What is OpenTelemetry?

**Grade:** Senior  
**Likely asked:** Very high

**Answer:**

OpenTelemetry is a vendor-neutral standard and set of SDKs, APIs, and tools for collecting telemetry from software systems. It supports traces, metrics, and logs.

The main value is that application code can emit telemetry in a standard format instead of being tightly coupled to one vendor. Then telemetry can be exported to tools such as Honeycomb, Datadog, Grafana, Prometheus, or other backends.

In a Rails system, OpenTelemetry can capture request traces, database spans, background job execution, external HTTP calls, and custom business operations.

---

## 22. What is the difference between logs, metrics, and traces?

**Grade:** Senior  
**Likely asked:** Very high

**Answer:**

Logs are discrete event records. They are useful for detailed messages, errors, and audit-style information.

Metrics are numeric measurements over time. They are useful for dashboards, alerts, SLOs, rates, latency percentiles, error rates, and resource usage.

Traces show the path of a request or workflow across services. They are useful for understanding distributed systems, finding bottlenecks, and seeing where time was spent.

A strong observability system connects all three. For example, a log line should include trace ID so I can jump from a log to the trace.

---

## 23. What is a span?

**Grade:** Senior  
**Likely asked:** Very high

**Answer:**

A span represents one operation within a trace. It has a name, start time, end time, duration, attributes, status, events, and parent/child relationships.

Examples of spans in Rails:

- HTTP request span.
- Controller action span.
- Active Record SQL span.
- Redis/cache call span.
- External API call span.
- Background job span.
- Custom domain operation span such as `receipt.calculate_cashback`.

Good span names should describe the operation, not include high-cardinality values.

Bad:

```text
GET /projects/123/tasks/456
```

Better:

```text
GET /projects/:project_id/tasks/:id
```

---

## 24. What makes telemetry actionable?

**Grade:** Staff  
**Likely asked:** Very high

**Answer:**

Telemetry is actionable when it helps engineers answer production questions quickly.

Good telemetry tells me:

- What operation happened?
- How long did it take?
- Was it successful?
- Which dependency was slow or failing?
- Which service, endpoint, job, or tenant was involved?
- Was this related to a deploy, feature flag, or data shape?
- Can I compare good and bad cases?

Bad telemetry is noisy, inconsistent, missing context, or full of high-cardinality sensitive data with no clear query strategy.

At Staff level, I would define conventions and examples so teams instrument consistently.

---

## 25. How would you instrument a Rails app with OpenTelemetry?

**Grade:** Staff  
**Likely asked:** Very high

**Answer:**

I would start with auto-instrumentation for the framework and common libraries, then add manual instrumentation for important business workflows.

Typical steps:

1. Add OpenTelemetry SDK and Rails instrumentation gems.
2. Configure service name, environment, version, and exporter.
3. Enable instrumentation for Rails, Rack, Active Record, Net::HTTP/Faraday, Redis, and Active Job where applicable.
4. Export telemetry to an OpenTelemetry Collector or directly to a backend depending on platform standards.
5. Add custom spans for domain workflows that auto-instrumentation cannot understand.
6. Add trace/log correlation.
7. Add sampling and filtering strategy.
8. Validate data quality in Honeycomb/Datadog.
9. Document golden paths for other teams.

---

## 26. What is auto-instrumentation vs manual instrumentation?

**Grade:** Senior  
**Likely asked:** High

**Answer:**

Auto-instrumentation captures telemetry from frameworks and libraries with minimal code changes. In Rails, it can capture HTTP requests, controller actions, database queries, and background jobs.

Manual instrumentation is code we add around business operations that frameworks do not understand.

Example:

```ruby
tracer.in_span("cashback.calculate") do |span|
  span.set_attribute("cashback.brand_id", brand.id)
  CalculateCashback.call(receipt)
end
```

Auto-instrumentation gives broad coverage quickly. Manual instrumentation gives domain meaning. A strong observability strategy uses both.

---

## 27. What attributes would you add to a Rails request span?

**Grade:** Staff  
**Likely asked:** High

**Answer:**

I would use OpenTelemetry semantic conventions where possible. Useful attributes include:

- HTTP method.
- Route pattern, not raw path with IDs.
- HTTP status code.
- Service name.
- Environment.
- Deployment version.
- Controller/action.
- Request ID.
- Tenant/account ID only if allowed and safe.
- Feature flag state if relevant.

I avoid raw request bodies, tokens, passwords, emails, or unbounded high-cardinality values.

---

## 28. Why are semantic conventions important?

**Grade:** Staff  
**Likely asked:** High

**Answer:**

Semantic conventions give teams a shared language for telemetry. If one service uses `http.status_code`, another uses `status`, and another uses `response_code`, cross-service querying becomes painful.

OpenTelemetry defines conventions for HTTP, databases, messaging, and other areas. Using them makes dashboards, alerts, and debugging queries reusable across services and languages.

For custom domain attributes, I would use clear namespacing, such as:

```text
procore.project.id
scheduler.trades.count
receipt.cashback.amount_cents
```

---

## 29. What is high cardinality and why does it matter?

**Grade:** Staff  
**Likely asked:** Very high

**Answer:**

Cardinality means the number of unique values for an attribute. High-cardinality attributes include user IDs, emails, request IDs, trace IDs, project IDs, and raw URLs.

High cardinality can be useful for debugging, but it can also increase storage cost and make metrics systems inefficient. For metrics, high-cardinality labels are especially dangerous. For traces, high-cardinality attributes can be acceptable if controlled and useful, depending on the backend.

I would avoid PII and raw unbounded values. I would keep metrics low-cardinality and use traces for richer context where appropriate.

---

## 30. How do you avoid leaking PII in telemetry?

**Grade:** Staff  
**Likely asked:** High

**Answer:**

I would define rules at instrumentation and collector levels.

In application code:

- Do not record passwords, tokens, request bodies, or personal information.
- Use IDs only when approved and useful.
- Prefer route patterns over raw URLs.
- Scrub SQL bind values if needed.

In the telemetry pipeline:

- Use processors to drop or hash sensitive attributes.
- Add allowlists for approved attributes.
- Review telemetry changes in code review.
- Add tests for scrubbing if the system handles sensitive data.

At Staff level, I would document this as a golden path so teams do not invent different standards.

---

## 31. What is sampling in OpenTelemetry?

**Grade:** Senior / Staff  
**Likely asked:** High

**Answer:**

Sampling decides which traces are retained or exported. It helps control telemetry volume and cost.

Head sampling makes the decision at the start of a trace. It is simple and cheap, but it may drop interesting traces before knowing whether they are slow or failed.

Tail sampling makes the decision after seeing more or all spans in the trace. It can keep errors or slow traces more intelligently, but it requires state in the collector and is more complex to scale.

For high-volume production systems, I would often combine strategies: keep all errors, keep slow traces, sample normal traffic, and always keep traces for critical workflows.

---

## 32. What is the OpenTelemetry Collector?

**Grade:** Staff  
**Likely asked:** High

**Answer:**

The OpenTelemetry Collector is a vendor-neutral telemetry pipeline. It can receive telemetry, process it, enrich it, filter it, batch it, sample it, and export it to one or more backends.

Using a collector gives platform teams more control. Applications do not need to know every vendor detail. The collector can handle batching, retries, memory limiting, resource detection, attribute scrubbing, and multi-destination export.

For Procore-style platform work, I would expect collector configuration to be part of the golden path.

---

## 33. What processors would you use in an OpenTelemetry Collector pipeline?

**Grade:** Staff  
**Likely asked:** Medium / High

**Answer:**

Common processors include:

- `batch`: batches telemetry before export to improve efficiency.
- `memory_limiter`: protects the collector from excessive memory usage.
- `resource`: adds or modifies resource attributes like environment or service metadata.
- `attributes`: adds, removes, hashes, or redacts attributes.
- `filter`: drops unwanted telemetry.
- `tail_sampling`: keeps traces based on policies such as error status or latency.

A safe production pipeline usually includes memory protection before batching and careful filtering/sampling to control cost.

---

## 34. How would you verify that OpenTelemetry is implemented correctly?

**Grade:** Staff  
**Likely asked:** Very high

**Answer:**

I would verify both technical correctness and usefulness.

Technical checks:

- Service name, environment, and version are correct.
- Trace context propagates across services.
- Rails requests, DB queries, jobs, and external calls produce spans.
- Errors are recorded with status and exception details.
- Logs include trace ID and span ID.
- Sampling behaves as expected.
- Collector export is healthy.

Usefulness checks:

- Can an engineer debug a slow request from trace to SQL query?
- Can we compare good and bad traces?
- Can we find failures by endpoint, job, dependency, or deploy version?
- Are attributes consistent and safe?
- Are dashboards and alerts tied to SLOs?

---

## 35. How would you add custom instrumentation to a Rails service object?

**Grade:** Senior / Staff  
**Likely asked:** High

**Answer:**

I would wrap the meaningful operation in a span and add attributes that help debugging without exposing sensitive data.

Example:

```ruby
class ReceiptCreatorService
  def call
    tracer.in_span("receipt.create") do |span|
      span.set_attribute("receipt.items.count", params[:items].size)
      span.set_attribute("receipt.source", params[:source])

      create_receipt!
    rescue => error
      span.record_exception(error)
      span.set_status(OpenTelemetry::Trace::Status.error(error.message))
      raise
    end
  end

  private

  def tracer
    OpenTelemetry.tracer_provider.tracer("receipt_service")
  end
end
```

I would avoid adding full receipt content, image URLs, user email, or raw params.

---

## 36. What is trace propagation?

**Grade:** Senior  
**Likely asked:** High

**Answer:**

Trace propagation passes trace context between services so spans from multiple services can be connected into one distributed trace.

For HTTP, this usually happens through headers such as `traceparent`. If propagation is broken, each service may create isolated traces and the team cannot see the full request path.

To verify propagation, I would make a request through multiple services and confirm that downstream spans share the same trace ID.

---

## 37. How do you instrument background jobs?

**Grade:** Staff  
**Likely asked:** High

**Answer:**

I would ensure job execution creates spans with job class, queue, retry count, status, duration, and error information. If a job is created from an HTTP request, I would preserve context where appropriate so the async work can be correlated to the initiating request.

Important metrics include:

- Queue latency.
- Execution duration.
- Success/failure rate.
- Retry count.
- Dead jobs.
- Jobs by queue and class.

I would avoid putting raw arguments into telemetry if they include sensitive data.

---

## 38. How would you connect Rails ActiveSupport::Notifications to OpenTelemetry?

**Grade:** Staff  
**Likely asked:** Medium / High

**Answer:**

Rails emits many internal events through ActiveSupport::Notifications, such as controller processing, SQL queries, rendering, cache operations, and jobs.

I can subscribe to custom or framework events and convert meaningful events into spans, metrics, or logs.

Example:

```ruby
ActiveSupport::Notifications.subscribe("cashback.calculate") do |name, start, finish, id, payload|
  duration_ms = (finish - start) * 1000
  Rails.logger.info(
    event: name,
    duration_ms: duration_ms,
    brand_id: payload[:brand_id]
  )
end
```

For OpenTelemetry, I would be careful not to duplicate spans already emitted by auto-instrumentation. I would use this mainly for domain events or metrics.

---

## 39. How do you decide what to instrument manually?

**Grade:** Staff  
**Likely asked:** High

**Answer:**

I manually instrument operations that are important to the business or hard to understand from framework spans alone.

Good candidates:

- Payment or billing operations.
- Receipt/cashback calculation.
- Search and recommendation logic.
- Data imports.
- Scheduling algorithms.
- External API integrations.
- Large background jobs.
- Feature-flagged migrations.

I do not instrument every private method. Too many spans create noise and cost. I choose boundaries that answer production questions.

---

## 40. What is the difference between monitoring and observability?

**Grade:** Staff  
**Likely asked:** Medium

**Answer:**

Monitoring tells us whether known problems are happening through predefined dashboards and alerts.

Observability helps us ask new questions about unknown problems using rich telemetry from the system.

Monitoring might tell us “checkout latency is high.” Observability helps answer “why is checkout slow only for large enterprise customers after the latest deploy?”

At Staff level, I care about both. Monitoring supports alerting and SLOs. Observability supports debugging and learning.

---

## 41. How would you design a telemetry golden path for Rails teams?

**Grade:** Staff / Principal  
**Likely asked:** Very high for Runtime team

**Answer:**

I would provide a standard library, templates, documentation, examples, and dashboards that product teams can adopt with minimal custom work.

The golden path should include:

- Default OpenTelemetry setup.
- Standard service/resource attributes.
- Rails, Active Record, job, cache, and HTTP client instrumentation.
- Trace/log correlation.
- Safe attribute naming conventions.
- PII redaction rules.
- Sampling defaults.
- Collector configuration.
- Example custom spans for service objects.
- Dashboards for latency, error rate, throughput, and saturation.
- Runbook examples for common incidents.

The goal is to make the right thing easy and consistent.

---

## 42. How would you migrate a large Rails codebase from vendor-specific tracing to OpenTelemetry?

**Grade:** Staff / Principal  
**Likely asked:** High

**Answer:**

I would avoid a big-bang migration. I would design an incremental migration.

Steps:

1. Inventory current tracing, metrics, logs, dashboards, and alerts.
2. Define the target OpenTelemetry conventions.
3. Build a small pilot in one service or endpoint.
4. Export to both old and new backends temporarily if needed.
5. Validate parity for key debugging workflows.
6. Create migration guides and reusable libraries.
7. Roll out team by team.
8. Track adoption and telemetry quality.
9. Retire old instrumentation after dashboards and alerts are migrated.

The biggest risk is not installing the SDK. The biggest risk is breaking engineers’ debugging workflows.

---

## 43. What can go wrong with OpenTelemetry implementation?

**Grade:** Staff  
**Likely asked:** High

**Answer:**

Common issues include:

- Missing service names or wrong environment tags.
- Broken trace propagation across services.
- Too many spans or noisy attributes.
- High-cardinality metrics labels.
- PII leakage.
- Double instrumentation.
- Missing errors or incorrect span status.
- Collector overload.
- Sampling that drops important failures.
- Dashboards that do not answer real incident questions.

I would treat telemetry as production code: reviewed, tested, documented, and monitored.

---

## 44. How do you reduce telemetry cost without losing debugging value?

**Grade:** Staff / Principal  
**Likely asked:** Medium / High

**Answer:**

I would reduce volume intelligently rather than blindly lowering sample rates.

Approaches:

- Drop noisy health-check endpoints.
- Use head sampling for normal traffic.
- Use tail sampling to keep errors and slow traces.
- Keep full traces for critical workflows.
- Remove useless attributes.
- Avoid high-cardinality metrics.
- Aggregate metrics where possible.
- Set retention policies by signal and environment.
- Route debug-level telemetry only when needed.

The goal is to preserve the ability to debug important incidents while controlling cost.

---

## 45. How would you make logs useful with traces?

**Grade:** Senior / Staff  
**Likely asked:** Medium

**Answer:**

I would use structured logs and include trace correlation fields such as `trace_id` and `span_id`.

Example log fields:

```json
{
  "level": "error",
  "service": "project-management-api",
  "trace_id": "abc123",
  "span_id": "def456",
  "event": "receipt.create.failed",
  "error_class": "Timeout::Error"
}
```

This lets engineers move from a log entry to the full trace. I would avoid unstructured string-only logs for important production events.

---

# Section D: Rails architecture and service-oriented systems

## 46. What is service-oriented architecture?

**Grade:** Staff  
**Likely asked:** High

**Answer:**

Service-oriented architecture means splitting a system into services with clear responsibilities and communication boundaries. Each service owns a business capability or platform capability and exposes APIs or events to other services.

The benefits are independent scaling, deployment, ownership, and clearer boundaries. The costs are network latency, operational complexity, data consistency challenges, distributed tracing needs, and harder local development.

At Staff level, I would not split services just for trend reasons. I would split when the domain boundary, team ownership, scaling needs, or reliability isolation justify the complexity.

---

## 47. Modular monolith vs microservices: how do you choose?

**Grade:** Staff / Principal  
**Likely asked:** High

**Answer:**

A modular monolith keeps deployment simple while enforcing internal boundaries. It is often the best starting point when one team owns the product and scale is manageable.

Microservices are useful when teams need independent ownership, services have different scalability/reliability needs, or deployment coupling becomes too expensive.

The tradeoff is that microservices require strong observability, API contracts, versioning, service discovery, retries, timeouts, and incident ownership.

I would choose the simplest architecture that satisfies current and near-future constraints.

---

## 48. How do you design APIs between services?

**Grade:** Staff  
**Likely asked:** Medium

**Answer:**

I design APIs around stable domain contracts, not internal database structures. I define ownership, request/response schemas, error formats, versioning strategy, idempotency, authentication, authorization, rate limits, and observability.

For critical APIs, I add contract tests and clear documentation. I also define timeout and retry behavior because distributed systems fail partially.

A good service API should be easy to use correctly and hard to misuse.

---

## 49. How do you handle external API failures in Rails?

**Grade:** Senior / Staff  
**Likely asked:** High

**Answer:**

I use timeouts, retries with backoff, circuit breakers where appropriate, idempotency keys for safe retries, and clear error handling.

I also instrument external calls with spans showing service name, endpoint pattern, status, latency, and error class.

For user-facing flows, I decide whether to fail fast, degrade gracefully, or enqueue work for later. The decision depends on business criticality.

---

## 50. What is idempotency and why does it matter?

**Grade:** Senior  
**Likely asked:** Medium

**Answer:**

Idempotency means repeating the same operation produces the same result without unintended side effects.

It matters for retries, background jobs, payment-like operations, imports, and distributed systems. Without idempotency, a retry can create duplicate records, send duplicate emails, or charge a customer twice.

In Rails, I might implement idempotency using unique constraints, idempotency keys, job deduplication, state machines, or database transactions.

---

## 51. How do you think about transactions in Rails?

**Grade:** Senior / Staff  
**Likely asked:** High

**Answer:**

Transactions protect consistency when multiple database changes must succeed or fail together.

Example:

```ruby
ApplicationRecord.transaction do
  order.update!(status: "paid")
  payment.create!(amount_cents: order.total_cents)
end
```

I avoid doing external HTTP calls inside database transactions because it keeps locks open and can create inconsistent side effects. For side effects like emails or events, I prefer `after_commit` or an outbox pattern.

---

## 52. What is the outbox pattern?

**Grade:** Staff  
**Likely asked:** Medium / High

**Answer:**

The outbox pattern stores an event in the same database transaction as the business change. A separate worker then publishes that event to a message broker or external system.

This avoids the problem where the database commit succeeds but the event publish fails, or the event publishes but the database rolls back.

It is useful for reliable integration between services.

---

## 53. How do you handle eventual consistency?

**Grade:** Staff  
**Likely asked:** Medium

**Answer:**

I first identify which parts of the business require strong consistency and which can tolerate delay.

For eventually consistent flows, I use events, background jobs, retries, reconciliation jobs, idempotent consumers, and clear user experience. I also add observability so we can detect stuck events or lag.

I communicate the tradeoff clearly to Product: eventual consistency improves availability and decoupling, but users may briefly see stale state.

---

## 54. How do you design for multi-tenancy?

**Grade:** Staff  
**Likely asked:** Medium

**Answer:**

I start by clarifying tenant isolation requirements. Options include shared database with tenant ID, separate schemas, or separate databases.

For shared tables, every tenant-scoped query must include tenant filtering. I would enforce this through domain boundaries, tests, authorization checks, and possibly database constraints or row-level security.

For observability, tenant/account context may be useful but must be handled carefully to avoid PII or excessive cardinality.

---

## 55. How do you think about feature flags?

**Grade:** Senior / Staff  
**Likely asked:** Medium

**Answer:**

Feature flags allow safer rollout, experimentation, and quick rollback. But they also add complexity.

I use flags for risky changes, staged migrations, beta features, and operational kill switches. I make sure flags are observable by adding flag state to traces when relevant.

I also define cleanup ownership. Stale flags make systems harder to reason about.

---

# Section E: Testing and TDD

## 56. What does TDD mean to you in Rails?

**Grade:** Senior / Staff  
**Likely asked:** High because JD mentions TDD

**Answer:**

TDD means using tests to drive design and protect behavior. I write a failing test for expected behavior, implement the simplest code to pass, then refactor safely.

In Rails, I use different test levels:

- Model/domain tests for business rules.
- Service object tests for workflows.
- Request specs for API behavior.
- Job specs for background work.
- System specs for critical user flows.
- Contract tests for service boundaries.

The goal is confidence, not 100% coverage for its own sake.

---

## 57. How would you test the WorkScheduler?

**Grade:** Senior  
**Likely asked:** High

**Answer:**

I would test:

- `suitable_workers` returns alphabetical emails.
- Cheapest worker is selected.
- A worker cannot be assigned twice in one day.
- Duplicate trades can be scheduled across multiple days.
- Unknown trades raise an error.
- Tie-breaking is deterministic.
- Empty input returns an empty schedule.

I would also add tests around the algorithm’s known limitation if greedy is not globally optimal.

---

## 58. What should you mock in Rails tests?

**Grade:** Senior  
**Likely asked:** Medium

**Answer:**

I mock external boundaries, not internal implementation details.

Good things to mock:

- External APIs.
- Email providers.
- Payment gateways.
- Expensive network calls.
- Time where deterministic behavior is needed.

Things I avoid mocking too much:

- Active Record behavior.
- Private methods.
- Internal collaborators where integration gives better confidence.

Over-mocking makes tests pass while the real system breaks.

---

## 59. How do you test observability code?

**Grade:** Staff  
**Likely asked:** Medium / High

**Answer:**

I test observability code at a few levels.

For custom instrumentation, I can use an in-memory exporter or test subscriber to assert that expected spans/events are emitted with safe attributes.

I also test that sensitive attributes are not emitted. For example, raw request bodies, tokens, and emails should be absent.

At integration level, I verify in staging that traces connect across services and dashboards show expected values.

I do not test every auto-generated framework span. I focus on custom spans and critical conventions.

---

## 60. How do you make tests reliable and fast?

**Grade:** Staff  
**Likely asked:** Medium

**Answer:**

I isolate tests, avoid unnecessary database writes, use factories carefully, reduce global state, avoid sleeps, control time, and split unit-level tests from slower integration/system tests.

For Rails, slow tests often come from heavy factories, too many callbacks, unnecessary full-stack tests, and external dependencies.

At Staff level, I also improve team feedback loops by monitoring test suite duration, flaky tests, and CI bottlenecks.

---

# Section F: Production debugging and incident thinking

## 61. A deploy increased p95 latency. What do you do?

**Grade:** Staff  
**Likely asked:** Very high

**Answer:**

First, I confirm the impact: which endpoints, services, customers, regions, and percentiles are affected. Then I compare traces before and after the deploy.

I check whether latency is from database, external calls, serialization, cache misses, lock contention, CPU, memory, or queueing.

If customer impact is high, I rollback or disable the feature flag while continuing investigation. If impact is limited, I may patch forward.

After mitigation, I write a short post-incident note: cause, detection gap, fix, and prevention.

---

## 62. How do you debug a memory leak in a Rails app?

**Grade:** Staff  
**Likely asked:** Medium

**Answer:**

I first confirm whether it is a true leak or expected memory growth from traffic and GC behavior. I look at RSS, heap slots, object allocations, GC metrics, endpoint/job correlation, and deploy timing.

Then I isolate which code path grows memory. Common causes include global caches, class variables, large arrays retained accidentally, background jobs processing huge datasets, and gems holding references.

I would reproduce in staging if possible, use heap dumps or allocation profiling, patch the leak, and monitor memory after deploy.

---

## 63. How do you investigate database lock contention?

**Grade:** Staff  
**Likely asked:** Medium

**Answer:**

I look at slow queries, blocked queries, transaction duration, lock waits, and recent migrations or code changes.

Common causes include long transactions, updates touching many rows, missing indexes, background jobs competing with user traffic, and migrations on large tables.

I fix it by shortening transactions, adding indexes safely, batching writes, reducing lock scope, and moving heavy work out of request paths.

---

## 64. How do you design useful alerts?

**Grade:** Staff  
**Likely asked:** Medium

**Answer:**

Useful alerts are tied to user impact and SLOs. I avoid alerting on every internal metric unless it predicts customer impact.

Good alerts:

- Error rate above threshold.
- p95/p99 latency above SLO.
- Job queue latency too high.
- Dependency failures affecting users.
- Saturation risks like database connections exhausted.

Bad alerts are noisy, unactionable, or lack runbooks. Every alert should tell the engineer what is wrong, why it matters, and where to start.

---

## 65. What is an SLI, SLO, and SLA?

**Grade:** Staff  
**Likely asked:** Medium

**Answer:**

An SLI is a service level indicator: a measurement of reliability, such as successful request rate or latency.

An SLO is a service level objective: the target for that indicator, such as 99.9% of requests succeed over 30 days.

An SLA is a contractual agreement, usually with business/legal consequences.

Engineering teams should use SLOs to balance reliability work with feature delivery.

---

## 66. How would you reduce MTTR?

**Grade:** Staff / Principal  
**Likely asked:** Medium

**Answer:**

I would reduce mean time to recovery by improving detection, diagnosis, and mitigation.

Actions:

- Better alerts tied to user impact.
- Dashboards that start from symptoms.
- Trace/log correlation.
- Runbooks for common failures.
- Feature flags and safe rollback.
- Ownership clarity.
- Post-incident learning.
- Instrumentation standards so every service exposes useful signals.

For a Runtime team, reducing MTTR across many teams is a core platform value.

---

# Section G: Staff/Principal-level collaboration

## 67. How do you communicate a complex technical solution to non-technical stakeholders?

**Grade:** Staff  
**Likely asked:** High because JD mentions communication

**Answer:**

I start with the business problem and user impact, not implementation details. Then I explain options, tradeoffs, risks, and recommendation.

For example:

> We can ship the simple version faster, but it may not scale for large customers. The safer option takes longer but reduces incident risk and supports future customization. My recommendation is to ship in phases: first the core workflow behind a feature flag, then scale improvements after we validate usage.

I use diagrams and examples when needed. I avoid jargon unless the audience needs it.

---

## 68. How do you mentor junior engineers during refactoring?

**Grade:** Staff  
**Likely asked:** High

**Answer:**

I mentor by making the reasoning visible. Instead of only saying “change this,” I explain why the current code is risky and how to improve it safely.

I encourage small PRs, tests before refactors, clear naming, and asking what behavior must stay the same. I also pair on difficult changes and write examples that become team references.

Good mentorship scales judgment, not dependency on me.

---

## 69. How do you bring clarity to complex solutions?

**Grade:** Staff  
**Likely asked:** High because JD mentions documentation and clarity

**Answer:**

I use design docs, diagrams, ADRs, examples, and decision records. A good design doc explains:

- Problem.
- Goals and non-goals.
- Constraints.
- Options considered.
- Recommendation.
- Tradeoffs.
- Rollout plan.
- Observability plan.
- Risks and mitigations.

I also keep documentation close to code where possible and update it after implementation changes.

---

## 70. How do you balance short-term delivery with long-term architecture?

**Grade:** Staff / Principal  
**Likely asked:** High

**Answer:**

I separate reversible and irreversible decisions. For reversible decisions, I optimize for speed. For hard-to-reverse architecture decisions, I spend more time validating assumptions.

I may choose a pragmatic short-term solution if it has a clear migration path. But I avoid shortcuts that create hidden data corruption, security risk, or operational instability.

The Staff-level answer is not “always build perfect architecture.” It is “make the tradeoff explicit and manage the risk.”

---

## 71. How do you influence teams without authority?

**Grade:** Staff  
**Likely asked:** Medium

**Answer:**

I influence through trust, evidence, and enablement. I listen to team constraints, show data, propose practical improvements, and provide tools or examples that reduce their workload.

For platform initiatives like OpenTelemetry, I would not just tell teams to instrument better. I would give them a golden path, templates, dashboards, office hours, and migration support.

Influence works best when teams feel the change helps them, not only the platform team.

---

## 72. Tell me about a technically challenging project from your experience.

**Grade:** Staff  
**Likely asked:** High

**Suggested answer based on your background:**

One technically challenging project I worked on was an IoT truck-loading system for a construction/materials flow. The application communicated with a truck scale, controlled the loading flow for cement, sand, bricks, and gravel, opened and closed gates, captured truck plate information, identified the driver, controlled fast and slow loading phases, triggered alarms when loading completed, and generated a full report at the end.

The challenge was that this was not a normal CRUD app. It had real-world hardware, timing, safety, data integrity, and anti-theft concerns. I had to make sure the system tracked each step correctly and reduced manual manipulation.

The business impact was strong because it reduced theft, improved reporting, and made loading more controlled and auditable.

To connect this to Procore, I would say:

> This experience is relevant because construction software must model real operational workflows, not just screens. Reliability, auditability, and clear production visibility matter a lot.

---

## 73. How would you use AI tools responsibly as a Staff engineer?

**Grade:** Staff  
**Likely asked:** Medium because JD mentions AI/agentic workflows

**Answer:**

I would use AI tools to accelerate understanding, generate test cases, explore refactoring options, write first drafts of documentation, and review possible edge cases.

But I would not blindly trust AI output. For production code, I still need tests, code review, security review, performance validation, and observability.

For agentic workflows, I would define guardrails: limited permissions, clear context, automated tests, linting, human approval for risky changes, and audit logs.

AI should increase engineering leverage, not reduce accountability.

---

# Section H: Questions they may ask specifically about OpenTelemetry in Rails

## 74. Show a minimal Rails OpenTelemetry setup.

**Grade:** Senior  
**Likely asked:** Medium

**Answer:**

A simplified setup may look like this:

```ruby
# Gemfile
gem "opentelemetry-sdk"
gem "opentelemetry-exporter-otlp"
gem "opentelemetry-instrumentation-all"
```

```ruby
# config/initializers/opentelemetry.rb
require "opentelemetry/sdk"
require "opentelemetry/exporter/otlp"
require "opentelemetry/instrumentation/all"

OpenTelemetry::SDK.configure do |config|
  config.service_name = "project-management-api"
  config.use_all
end
```

In production, I would align this with platform standards: collector endpoint, resource attributes, environment, service version, sampling, and secure exporter configuration.

---

## 75. How would you name custom spans?

**Grade:** Staff  
**Likely asked:** Medium

**Answer:**

I would use stable operation names that describe the action and do not include IDs or raw values.

Good:

```text
receipt.create
cashback.calculate
work_scheduler.schedule_all_tasks
external.vendor.fetch_profile
```

Bad:

```text
receipt.create.12345
GET /projects/928/tasks/123
calculate for user hany@example.com
```

Stable names make traces easier to aggregate and compare.

---

## 76. How do you handle errors in spans?

**Grade:** Senior  
**Likely asked:** Medium

**Answer:**

When an operation fails, I record the exception on the span, set the span status to error, and re-raise the exception unless the code intentionally handles it.

```ruby
tracer.in_span("external.profile.fetch") do |span|
  fetch_profile
rescue => error
  span.record_exception(error)
  span.set_status(OpenTelemetry::Trace::Status.error(error.message))
  raise
end
```

I avoid swallowing errors just to make traces look successful.

---

## 77. What is double instrumentation?

**Grade:** Staff  
**Likely asked:** Medium

**Answer:**

Double instrumentation happens when the same operation is instrumented twice by different libraries or by both auto and manual instrumentation.

For example, if Rails auto-instrumentation already creates SQL spans and I manually wrap every Active Record call with another span, traces become noisy and misleading.

I prevent this by understanding what auto-instrumentation already provides and adding manual spans only around meaningful domain boundaries.

---

## 78. How would you instrument a slow SQL query investigation?

**Grade:** Staff  
**Likely asked:** Medium

**Answer:**

I would use existing Active Record/SQL spans to identify slow queries. Then I would look at query shape, bind values if safe, table size, indexes, query plan, and whether the query is repeated.

I would add custom attributes only if they help, such as logical operation name or feature flag state. I would avoid recording full raw SQL with sensitive values unless sanitized.

After fixing, I would compare before/after trace duration and database metrics.

---

## 79. What is trace/log correlation and why is it useful?

**Grade:** Senior  
**Likely asked:** Medium

**Answer:**

Trace/log correlation means logs include identifiers that connect them to traces, usually trace ID and span ID.

This is useful because logs show detailed events while traces show request flow and timing. When correlated, an engineer can start from either signal and navigate to the other.

It reduces debugging time during incidents.

---

## 80. How would you know if observability adoption is successful?

**Grade:** Staff / Principal  
**Likely asked:** High

**Answer:**

I would measure both adoption and outcomes.

Adoption signals:

- Percentage of services using OpenTelemetry.
- Percentage with correct service metadata.
- Percentage with trace/log correlation.
- Number of teams using golden path libraries.
- Dashboard/runbook coverage.

Outcome signals:

- Reduced MTTR.
- Fewer incidents with “unknown cause.”
- Faster debugging during deploy regressions.
- Better SLO visibility.
- Lower telemetry cost per useful signal.
- Positive feedback from product engineers.

Success is not “we emit spans.” Success is “engineers can resolve production issues faster and with more confidence.”

---

# Section I: Principal-level challenge questions

## 81. You want every team to adopt OpenTelemetry, but teams are busy. What do you do?

**Grade:** Principal  
**Likely asked:** High

**Answer:**

I would reduce adoption friction and connect the work to team pain.

Instead of asking every team to learn OpenTelemetry deeply, I would provide a golden path: a standard gem/config, examples, dashboards, and migration checklist. I would pick one high-impact team as a pilot, prove value during a real debugging scenario, then use that success story to drive adoption.

I would also make adoption measurable and incremental. For example, first require correct service metadata and request traces. Then add critical workflow spans. Then improve sampling and dashboards.

---

## 82. A team adds too many custom spans and telemetry cost increases. How do you respond?

**Grade:** Principal  
**Likely asked:** Medium

**Answer:**

I would not simply tell them to remove everything. I would review what questions they are trying to answer and keep telemetry that supports those questions.

Then I would apply standards:

- Remove spans around trivial methods.
- Keep spans at workflow and dependency boundaries.
- Drop noisy endpoints.
- Reduce high-cardinality attributes.
- Use sampling for normal traffic.
- Keep error and slow traces.
- Add code review guidelines for telemetry changes.

The goal is useful signal, not maximum data.

---

## 83. A product team says “we already have logs; why do we need traces?”

**Grade:** Staff / Principal  
**Likely asked:** Medium

**Answer:**

I would explain that logs and traces answer different questions.

Logs are good for specific events. Traces show the full path and timing of a request across services. In a distributed system, traces help find whether latency came from Rails, SQL, Redis, another service, or an external dependency.

I would show a real example: a slow request where logs show many messages but the trace immediately reveals that 80% of time was spent in one external API call.

---

## 84. How would you design observability for a new platform extensibility feature?

**Grade:** Staff / Principal  
**Likely asked:** Medium

**Answer:**

For a platform extensibility feature, I would instrument both platform-level and customer-level behavior.

I would track:

- Request volume by extension type.
- Latency and error rate.
- External callback/webhook failures.
- Sandbox or execution failures.
- Rate limiting.
- Resource usage.
- Timeout rates.
- Customer-visible failure modes.

I would also create dashboards and alerts before full rollout, because extensibility features often create unpredictable usage patterns.

---

## 85. What does Staff-level ownership mean to you?

**Grade:** Staff / Principal  
**Likely asked:** High

**Answer:**

Staff-level ownership means owning outcomes beyond my own tickets. It means improving systems, mentoring engineers, clarifying ambiguous problems, anticipating risks, and creating patterns that other teams can reuse.

For this role, that means not only writing Ruby/Rails code, but helping Procore engineering teams build systems that are scalable, observable, reliable, and easier to operate.

A Staff engineer should raise the engineering quality of the team and reduce future complexity.

---

# Part 3: Questions you should ask the Principal Engineer

Use these near the end of the interview.

## Question 1

How does Procore currently define successful OpenTelemetry adoption across product teams: coverage, MTTR reduction, SLO visibility, or something else?

## Question 2

What are the biggest observability pain points today for Rails services in the Project Management or Runtime area?

## Question 3

How much of the role is hands-on refactoring inside product codebases versus building platform libraries and golden paths?

## Question 4

How do teams currently balance Honeycomb, Datadog, logs, metrics, and traces during incidents?

## Question 5

What would you expect a successful Staff engineer in this role to improve in the first 3 to 6 months?

## Question 6

Are there existing Rails conventions for service objects, instrumentation, background jobs, and API patterns, or would part of the role involve standardizing them?

---

# Part 4: Final preparation checklist

Before the interview, make sure you can confidently explain:

- Your WorkScheduler solution and its limitations.
- How to refactor code safely with tests.
- Why greedy scheduling may not be globally optimal.
- How to detect and fix N+1 queries.
- `includes` vs `preload` vs `eager_load` vs `joins`.
- How to instrument Rails with OpenTelemetry.
- Logs vs metrics vs traces.
- Span naming and attributes.
- High cardinality and PII risks.
- Sampling strategies.
- Collector pipeline basics.
- Trace propagation.
- Background job observability.
- Production debugging workflow.
- How to communicate tradeoffs at Staff level.
- How to mentor and create reusable engineering standards.

---

# Part 5: Short answers to memorize

## “How do you refactor safely?”

I first lock current behavior with tests, then refactor in small steps, keeping behavior changes separate from structure changes. After that, I verify with tests and production telemetry.

## “What does good observability mean?”

Good observability means engineers can answer production questions quickly without guessing. It connects traces, logs, and metrics with consistent, safe attributes.

## “How would you add OpenTelemetry?”

I would start with auto-instrumentation for Rails and common libraries, then add manual spans around critical business workflows, configure exporter/collector, add trace-log correlation, define sampling, and validate usefulness in the backend.

## “What is your Staff engineer mindset?”

I optimize for team-level outcomes. I write code, but I also improve patterns, documentation, observability, review quality, and long-term maintainability.

## “What would you improve in the scheduler?”

I would prevent infinite loops, make result shape explicit, add deterministic tie-breaking, remove dead code, require `set`, add tests, and clarify whether greedy is acceptable or if we need a matching algorithm.

---

# Part 6: One-minute intro tailored to this interview

Here is a concise intro you can use:

```text
I have strong Ruby on Rails backend experience building production systems, APIs, background workflows, and performance-sensitive features. In my recent work, I focused a lot on refactoring complex logic, improving data integrity, handling long-running jobs, and making systems easier to reason about.

One project I’m proud of was an IoT truck-loading platform for construction materials, where the system controlled gates, communicated with truck scales, managed loading flow, identified drivers and trucks, and generated audit reports. That project taught me a lot about reliability, observability, and building software that maps to real operational workflows.

For this Procore role, I’m especially interested in the combination of Rails, platform engineering, observability, and construction-domain complexity. I think my strengths in debugging, refactoring, and simplifying complex workflows match well with what the Runtime and Project Management teams need.
```

---

# End of guide
