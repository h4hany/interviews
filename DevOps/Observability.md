# Observability Interview Questions

## 1. What is Observability?

**Answer:**
Observability is the ability to understand a system's internal state by examining its outputs (logs, metrics, traces). It goes beyond monitoring to enable debugging and understanding.

## 2. What are the three pillars of Observability?

**Answer:**
- **Logs**: Event records.
- **Metrics**: Numerical measurements.
- **Traces**: Request flows.

> [!TIP]
> **Antigravity Tip**: The "Holy Grail" of observability is **Exemplars**. This allows you to jump directly from a spike in a Metrics chart (e.g., a latency p99 spike) to a specific Trace that caused that spike. At BrandOS, we used OpenTelemetry to attach `trace_id` as metadata to our Prometheus metrics, reducing our Mean Time to Detection (MTTD) by 60%.

## 3. What is the difference between Monitoring and Observability?

**Answer:**
- **Monitoring**: Tracks known issues and predefined metrics.
- **Observability**: Enables understanding unknown issues through exploration of logs, metrics, and traces.

## 4. What is Logging?

**Answer:**
Logging records application events, errors, and information for debugging and auditing purposes.

## 5. What are Log Levels?

**Answer:**
- **DEBUG**: Detailed information for debugging
- **INFO**: General informational messages
- **WARN**: Warning messages for potential issues
- **ERROR**: Error messages for failures
- **FATAL**: Critical errors causing application shutdown

## 6. What is Structured Logging?

**Answer:**
Structured Logging formats logs as structured data (JSON) instead of plain text, enabling better parsing and analysis.
- *Example*: Instead of `User 1 login failed`, use `{"event": "login_failed", "user_id": 1, "severity": "error"}`. This allows you to filter for all "login_failed" events in a dashboard easily.

## 7. What is Centralized Logging?

**Answer:**
Centralized Logging aggregates logs from multiple sources into a single system for analysis (ELK stack, Splunk, Datadog).

## 8. What is the ELK Stack?

**Answer:**
ELK Stack consists of:
- **Elasticsearch**: Search and analytics engine
- **Logstash**: Log processing pipeline
- **Kibana**: Visualization and dashboard

## 9. What is Metrics?

**Answer:**
Metrics are numerical measurements collected over time, representing system performance and behavior.

## 10. What are the types of Metrics?

**Answer:**
- **Counter**: Incremental value (requests, errors)
- **Gauge**: Current value (CPU usage, memory)
- **Histogram**: Distribution of values (response time)
- **Summary**: Quantiles and counts

## 11. What is the difference between Counter and Gauge?

**Answer:**
- **Counter**: Only increases. *Example*: Total number of "Buy Now" clicks since the server started.
- **Gauge**: Can increase or decrease. *Example*: The number of users currently active on the site right now.

## 12. What is Prometheus?

**Answer:**
Prometheus is an open-source monitoring and alerting toolkit that collects metrics and stores them as time-series data.

## 13. What is Grafana?

**Answer:**
Grafana is a visualization and analytics platform that creates dashboards from metrics and logs.

## 14. What is the difference between Prometheus and Grafana?

**Answer:**
- **Prometheus**: Metrics collection and storage.
- **Grafana**: Visualization and dashboards (can query Prometheus).

## 15. What is Distributed Tracing?

**Answer:**
Distributed Tracing tracks requests across multiple services, providing visibility into request flows and performance.

## 16. What is a Trace?

**Answer:**
A Trace represents a single request's journey through multiple services, consisting of spans.

## 17. What is a Span?

**Answer:**
A Span represents a single operation within a trace, with start time, duration, and metadata.

## 18. What is the difference between Trace and Span?

**Answer:**
- **Trace**: Complete request flow across services.
- **Span**: Individual operation within a trace.

## 19. What is OpenTracing?

**Answer:**
OpenTracing is a vendor-neutral API for distributed tracing, enabling instrumentation without vendor lock-in.

## 20. What is OpenTelemetry?

**Answer:**
OpenTelemetry is a unified observability framework that combines OpenTracing and OpenCensus, providing instrumentation for logs, metrics, and traces.

## 21. What is the difference between OpenTracing and OpenTelemetry?

**Answer:**
- **OpenTracing**: API specification for tracing only.
- **OpenTelemetry**: Complete observability framework (logs, metrics, traces).

## 22. What is APM (Application Performance Monitoring)?

**Answer:**
APM monitors application performance, tracking response times, throughput, errors, and user experience.

## 23. What is the difference between APM and Infrastructure Monitoring?

**Answer:**
- **APM**: Application-level monitoring (response times, errors, user experience).
- **Infrastructure Monitoring**: System-level monitoring (CPU, memory, disk, network).

## 24. What is Alerting?

**Answer:**
Alerting notifies teams when metrics exceed thresholds or errors occur, enabling proactive issue resolution.

## 25. What is the difference between Alert and Notification?

**Answer:**
- **Alert**: Triggered by threshold breach or condition.
- **Notification**: Message sent about an alert.

## 26. What is Alert Fatigue?

**Answer:**
Alert Fatigue occurs when too many alerts desensitize teams, causing important alerts to be ignored.

## 27. What is SLO (Service Level Objective)?

**Answer:**
SLO is a target level of service reliability, expressed as a percentage (e.g., 99.9% uptime).

## 28. What is SLA (Service Level Agreement)?

**Answer:**
SLA is a contract defining service level commitments between provider and customer.

## 29. What is the difference between SLO and SLA?

**Answer:**
- **SLO**: Internal target for service reliability.
- **SLA**: External commitment with consequences if not met.

## 30. What is SLI (Service Level Indicator)?

**Answer:**
- **SLI (Service Level Indicator)**: The actual metric (e.g., Latency).
- **SLO (Service Level Objective)**: The target (%) for that SLI.
- **SLA (Service Level Agreement)**: The legal contract with the customer.

> [!TIP]
> **Antigravity Tip**: Use **Error Budgets** to balance innovation vs stability. If you have plenty of budget left at the end of the month, you can take more risks (e.g., deploy that complex feature). If your budget is nearly gone, you freeze all non-urgent deploys and focus 100% on reliability work. This turns "Reliability" from a debate into a mathematical decision.

## 32. What is the difference between Logs and Metrics?

**Answer:**
- **Logs**: Detailed event records, high volume, unstructured.
- **Metrics**: Aggregated measurements, lower volume, structured.

## 33. What is Sampling in Observability?

**Answer:**
Sampling reduces data volume by collecting only a percentage of traces/logs, balancing detail with cost.

## 34. What is Correlation ID?

**Answer:**
Correlation ID is a unique identifier passed across services to correlate logs and traces for a single request.
- *Example*: A request gets ID `req_abc_123`. When you search this ID in your log aggregator (Kibana/Datadog), you see logs from the Gateway, Auth service, and Database all linked to that one specific user action.

## 35. What is the difference between Push and Pull Model?

**Answer:**
- **Push Model**: Services send data to monitoring system (logs, some metrics).
- **Pull Model**: Monitoring system pulls data from services (Prometheus metrics).

## 36. What is Observability Best Practices?

**Answer:**
- Use structured logging
- Implement distributed tracing
- Collect relevant metrics
- Set up alerting with proper thresholds
- Create meaningful dashboards
- Use correlation IDs
- Implement health checks
- Monitor business metrics
- Review and tune alerts
- Document observability strategy

## 37. What is the difference between Logging and Tracing?

**Answer:**
- **Logging**: Records events at specific points.
- **Tracing**: Tracks request flow across services.

## 38. What is Real User Monitoring (RUM)?

**Answer:**
RUM monitors actual user interactions with applications, providing insights into real user experience.

## 39. What is Synthetic Monitoring?

**Answer:**
Synthetic Monitoring uses automated scripts to simulate user interactions, testing application availability and performance.

## 40. What is the difference between RUM and Synthetic Monitoring?

**Answer:**
- **RUM**: Monitors real user interactions.
- **Synthetic Monitoring**: Simulates user interactions with automated scripts.


