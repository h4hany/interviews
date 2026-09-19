# Debugging in Production

Debugging in production is fundamentally different from local debugging. You cannot attach a debugger, step through code, or restart the service casually. You rely entirely on telemetry, logs, and state inspection.

## Principles of Production Debugging
1. **First, Do No Harm:** Your investigation should not worsen the outage (e.g., running un-indexed queries on a struggling DB).
2. **Mitigate First, Fix Later:** If rolling back fixes the issue, roll back immediately. You can debug the bad build in staging.
3. **Never SSH directly (if possible):** Rely on aggregated logs and remote profiling. If SSH is required, it highlights a gap in observability.

## Debugging Without Reproducing Locally
Often, bugs only appear at scale or with specific production data.
- **Feature Flags:** Allow isolating the new code. You can toggle the feature off for mitigation, or turn it on for specific internal users to reproduce the bug safely in prod.
- **Traffic Shadowing/Mirroring:** Use API Gateways (like Envoy/Istio) to duplicate real production traffic and send it to a staging service to reproduce the issue without impacting users.

## Log and Trace Analysis
- **Correlation IDs:** Every incoming request must be tagged with a unique ID that is passed to downstream services and injected into every log line.
  ```bash
  # grep across multiple files for a specific request journey
  grep "req_id: 5f8a9b2c" /var/log/services/*.log | sort -k1
  ```
- **Trace Waterfalls:** Use tools like Jaeger or Datadog to visualize where the time was spent. A gap in the trace waterfall usually indicates CPU starvation, garbage collection pauses, or synchronous blocking calls.

## Database Query Analysis
Slow databases cause cascading failures across the system.
- **EXPLAIN PLANS:** Analyze slow queries. Look for `Seq Scan` (Sequential Scan) on large tables, which indicates missing indexes.
- **pg_stat_statements (PostgreSQL):** Identify the most frequent and longest-running queries.
- **Lock Contention:** Check for long-running transactions holding row locks.
  ```sql
  -- Postgres: Find blocking queries
  SELECT pid, usename, pg_blocking_pids(pid) as blocked_by, query as blocked_query
  FROM pg_stat_activity
  WHERE cardinality(pg_blocking_pids(pid)) > 0;
  ```

## Memory Leaks
Symptoms: Gradual increase in memory usage over time, culminating in an OOMKill (Out of Memory), followed by a restart and repeating the cycle.
- **Heap Dumps:** Capture a heap dump just before the OOM. Compare two heap dumps taken 10 minutes apart to see which object count is growing.
- **Node.js/V8:** Use `--inspect` flag locally, or tools like Datadog Profiler in prod. Look for closures holding onto large objects or unclosed event listeners.

## CPU Profiling in Production
Symptoms: High CPU usage, increased latency, but no external dependencies are slow.
- **Flame Graphs:** Visual representations of profiled software, allowing the most frequent code paths to be identified quickly.
- **Continuous Profiling:** Tools like Pyroscope or Datadog Continuous Profiler regularly sample the CPU stack traces with low overhead (< 1%), allowing you to look back at what was consuming CPU during an incident.

## Debugging Serverless (AWS Lambda)
Serverless hides the infrastructure, changing debugging approaches.
- **Cold Starts:** High latency on initial invocations. Fix by optimizing package size or using Provisioned Concurrency.
- **Timeouts:** Use AWS X-Ray to trace if the timeout is due to an external API, database, or internal logic.
- **Logging:** Ensure proper JSON logging to CloudWatch. Use CloudWatch Insights to query logs efficiently.

## Interview Questions
**Q: A service is experiencing high CPU and latency. The database and external APIs are healthy. How do you debug?**
*A: This suggests an application-level bottleneck. I would first check for Garbage Collection storms (if Java/Node.js) which consume massive CPU. Next, I'd look at flame graphs or continuous profilers to identify infinite loops, excessive regex processing, or synchronous blocking code. If no profiler is attached, I might take a thread dump to see what the active threads are executing.*

**Q: Users report a random 500 error that happens sporadically (1 in 10,000 requests). You can't reproduce it locally. How do you find it?**
*A: I would look at error aggregation tools like Sentry. If it's truly sporadic, it might be tied to specific dirty data in the DB, a race condition, or a specific pod that has degraded. I would ensure structured logging includes user ID, tenant ID, and pod ID. By analyzing the 500s, I might find they all map to a specific tenant with a rare configuration, or they all happen on one specific Kubernetes node with failing networking.*
