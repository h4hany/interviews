# OpenTelemetry & Observability — Rollout, Instrumentation, Monitoring

> Critical for the Specialized Technical Interview. Procore is mid-SOA migration and observability is a first-class concern.

---

## 1. OpenTelemetry Overview

OpenTelemetry (OTel) is a vendor-neutral standard and set of SDKs/APIs for collecting telemetry: **traces, metrics, and logs**.

### Core Value
Application code emits telemetry in a standard format, decoupled from any vendor. Export to Honeycomb, Datadog, Grafana, Prometheus, etc.

### Three Pillars

| Signal | What It Is | Example |
|--------|-----------|---------|
| **Traces** | Path of a request across services | Request → controller → DB → external API → response |
| **Metrics** | Numeric measurements over time | p99 latency, error rate, request count |
| **Logs** | Discrete event records | Error messages, audit events, debug info |

### Key Relationships
- **Trace** = directed acyclic graph of spans representing a single request's journey
- **Span** = single unit of work (one DB query, one HTTP call) with start/end time and attributes
- **Metric** = aggregated measurement (e.g., histogram of `http.server.request.duration`)

> "Metrics tell me something is wrong, traces tell me where it happened, and logs give me detailed context."

---

## 2. OTel Rollout Plan for Rails Monolith → SOA

### Phase 1: Instrument the Monolith First

Don't wait for SOA. Install OTel before any service extraction — this gives you a performance baseline.

```ruby
# Gemfile
gem 'opentelemetry-sdk'
gem 'opentelemetry-instrumentation-all'  # Rails, ActiveRecord, Sidekiq, Redis, Net::HTTP
gem 'opentelemetry-exporter-otlp'

# config/initializers/opentelemetry.rb
require 'opentelemetry/sdk'
require 'opentelemetry/instrumentation/all'

OpenTelemetry::SDK.configure do |c|
  c.resource = OpenTelemetry::SDK::Resources::Resource.create(
    'service.name'    => ENV.fetch('OTEL_SERVICE_NAME', 'procore-monolith'),
    'service.version' => ENV.fetch('APP_VERSION', 'unknown'),
    'deployment.environment' => Rails.env
  )
  c.use_all   # auto-instruments Rails, AR, Sidekiq, Faraday, etc.
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::OTLP::Exporter.new(endpoint: ENV['OTEL_EXPORTER_OTLP_ENDPOINT'])
    )
  )
end
```

### Phase 2: Context Propagation Across Boundaries

**HTTP calls:** W3C TraceContext headers (`traceparent`, `tracestate`) propagated automatically by `opentelemetry-instrumentation-faraday` / `net_http`.

**Async boundaries (Sidekiq, Kafka):** Manual propagation required:

```ruby
class ProjectUpdateWorker
  include Sidekiq::Worker

  def self.perform_later(project_id)
    carrier = {}
    OpenTelemetry.propagation.inject(carrier)   # injects traceparent
    perform_async(project_id, carrier)
  end

  def perform(project_id, carrier)
    context = OpenTelemetry.propagation.extract(carrier)
    OpenTelemetry::Context.with_current(context) do
      OpenTelemetry.tracer_provider.tracer('worker').in_span('project_update') do |span|
        span.set_attribute('project.id', project_id)
        # ... actual work
      end
    end
  end
end
```

### Phase 3: Custom Business Spans

Generic instrumentation is not enough for Procore's domain. Add custom spans:

```ruby
tracer = OpenTelemetry.tracer_provider.tracer('procore.project_management')

tracer.in_span('budget.recalculate', attributes: {
  'project.id'        => project.id.to_s,
  'budget.line_items' => line_items.count,
  'user.id'           => current_user.id.to_s
}) do |span|
  result = BudgetCalculator.new(project).recalculate
  span.set_attribute('budget.change_pct', result.change_percentage)
  result
end
```

---

## 3. What Telemetry to Capture

### Traces
- HTTP request spans: route, status code, latency, exceptions
- Database spans: query timing, operation type, table name
- Background job spans: queue name, class, retries, duration, failure reason
- External API spans: dependency name, timeout, status code
- Custom domain spans: permissions, scheduling, document processing

### Metrics
- Request latency percentiles: p50, p95, p99
- Error rate by endpoint, service, deployment version
- Throughput: requests/sec, jobs/minute
- Queue depth, queue latency, retry rate, dead-letter count
- DB metrics: query latency, connection pool saturation, lock waits
- Cache hit rate and cache latency
- Memory usage, GC time, container restarts

### Logs (Correlated)
- Every log line includes `trace_id` + `span_id`
- Enables jumping from log error → full trace in Datadog/Grafana

---

## 4. Sampling Strategies

### Head-Based Sampling (at trace start)
- Simple: `TraceIdRatioBased(0.1)` samples 10% of traces
- Risk: may drop error traces

### Tail-Based Sampling (at trace end, in OTel Collector)
- Keeps 100% of error traces and slow traces
- Samples down normal traffic
- Best for production

### Procore-Specific Rules
```text
Always keep: error=true OR duration > 2s OR status_code >= 500
Sample 10%: normal successful requests
Always keep: permission check failures
Always keep: financial transaction traces
```

---

## 5. Span Design Best Practices

### DO
- Use semantic conventions where possible (`http.method`, `db.system`)
- Use custom namespaced attributes for domain concepts (`procore.project.id`)
- Record exceptions with `span.record_exception(error)`
- Use low-cardinality attributes (status, action type, count)

### DON'T
- Add PII (emails, tokens, raw request bodies)
- Add high-cardinality attributes (every worker email, every item ID)
- Over-instrument — add spans for meaningful operations, not every method call
- Ignore `span.set_status(error)` on failures

### Example: Instrumenting WorkScheduler

```ruby
tracer = OpenTelemetry.tracer_provider.tracer("work_scheduler")

tracer.in_span("work_scheduler.schedule_all_tasks") do |span|
  span.set_attribute("scheduler.trades.count", trades.size)
  span.set_attribute("scheduler.workers.count", @workers.size)

  days = schedule_all_tasks_internal(trades)

  span.set_attribute("scheduler.days.count", days.size)
  span.set_status(OpenTelemetry::Trace::Status.ok)
  days
rescue => error
  span.record_exception(error)
  span.set_status(OpenTelemetry::Trace::Status.error(error.message))
  raise
end
```

---

## 6. Production Observability Setup

### Dashboards & Alerts

Build around **SLOs**, not just raw metrics:

```text
SLO: "95% of project activity feed requests complete under 300ms"
Alert: SLO burn rate exceeds threshold
Dashboard: p50/p95/p99 latency, error rate, throughput
```

### Key Dashboards
1. **Service Health** — latency, error rate, throughput per service
2. **Database Health** — query latency, connection pool, slow queries
3. **Background Jobs** — queue depth, processing time, dead jobs
4. **External Dependencies** — API latency, error rate per dependency
5. **Business Metrics** — RFIs created/hour, documents uploaded, active projects

### Incident Debugging Flow
```text
1. Alert fires (SLO breach)
2. Check dashboard → which service, which endpoint?
3. Open trace → find slow or errored span
4. Drill into span → DB query? External call? Permission check?
5. Check logs filtered by trace_id
6. Identify root cause → deploy fix → verify metrics improve
```

---

## 7. Procore-Specific Observability Angles

### Most Valuable Traces at Procore Scale
- **Permission checks** — usually the most expensive AR-heavy operation in construction SaaS
- **Document/drawing versioning queries** — complex joins across versions
- **Aggregation queries across project hierarchies** — cross-project reports
- **Notification delivery** — fan-out to many users

### Why Observability Before SOA
> "Tracing these before extraction lets you set SLOs and detect regressions in the extracted service immediately. You can't safely extract what you can't measure."

### Staff-Level Role
> "I would not stop at instrumentation. I would document conventions, create reusable initializers, define span naming standards, review instrumentation quality in PRs, and teach teams how to use traces during incidents and performance debugging."

---

## 8. Interview Quick Reference

| Question | Key Points |
|----------|-----------|
| What is OTel? | Vendor-neutral telemetry standard. Traces, metrics, logs. Decoupled from backend. |
| Trace vs Span vs Metric? | Trace = request journey. Span = unit of work. Metric = aggregated measurement. |
| How to roll out OTel? | Install in monolith first → auto-instrument → add custom business spans → propagate context → add sampling |
| Context propagation? | W3C TraceContext for HTTP. Manual injection/extraction for Sidekiq/Kafka. |
| Sampling? | Head-based for simplicity. Tail-based for keeping errors/slow traces. |
| What to measure? | Latency percentiles, error rate, throughput, DB time, cache hit rate, queue depth |
| Procore angle? | Permission checks, document versioning, project hierarchies — trace before you extract |
