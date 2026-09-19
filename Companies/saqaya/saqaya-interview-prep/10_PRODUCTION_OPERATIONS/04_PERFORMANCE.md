# Performance & Scalability

Performance isn't just about making things fast; it's about predictable behavior under load and cost-efficiency.

## Types of Performance Testing
1. **Load Testing:** Assessing system behavior under expected normal and peak load conditions.
2. **Stress Testing:** Pushing the system beyond normal limits to find the breaking point and observe how it fails (gracefully or catastrophically).
3. **Soak (Endurance) Testing:** Running a system at a sustained load for an extended period (hours/days) to uncover memory leaks or resource exhaustion that wouldn't show up in a short test.
4. **Spike Testing:** Testing sudden, extreme increases or decreases in load (e.g., Black Friday sale start).

## Modern Tooling
- **k6 (Grafana):** Developer-centric, writes tests in JavaScript, highly performant (written in Go). Excellent for CI/CD pipelines.
- **Artillery:** Node.js based, great for testing complex workflows and WebSockets.
- **Locust:** Python-based, distributed load testing, highly scriptable user behavior.

## Identifying Bottlenecks
Performance issues generally fall into one of these resource constraints:
- **CPU Bound:** Extensive calculations, encryption, serialization/deserialization (e.g., massive JSON payloads).
- **Memory Bound:** Caching too much data, memory leaks, large object allocations causing Garbage Collection pauses.
- **I/O Bound (Most Common):** Waiting on Database queries, Network calls to external APIs, or Disk reads/writes.

## Database Optimization Strategies
The database is typically the hardest component to scale.
- **Indexing:** Ensure queries are hitting indexes. Avoid over-indexing (slows down writes).
- **N+1 Query Problem:** Ensure ORMs are eagerly loading associations rather than making a query per row.
- **Connection Pooling:** Use PgBouncer (Postgres) or Prisma Accelerate to manage connections. Opening a DB connection per request will kill performance.
- **Caching:** 
  - *Read-Through:* Application checks cache (Redis), if miss, fetches DB, populates cache.
  - *Write-Through:* App writes to cache and DB simultaneously.
- **Read Replicas:** Route heavy `SELECT` queries to read-only replicas to offload the primary writer node.

## API Performance Optimizations
- **Pagination:** Never return unbounded lists. Use cursor-based pagination for massive datasets (faster than offset/limit).
- **Compression:** Enable Gzip/Brotli encoding on the API Gateway or CDN.
- **Payload Reduction:** Use GraphQL or sparse fields in REST to return only what the client needs.
- **Asynchronous Processing:** Move slow tasks (email sending, PDF generation, report generation) to background worker queues (RabbitMQ, SQS, Celery, BullMQ).

## LLM API Performance
Integrating with LLMs (OpenAI, Anthropic) introduces massive latency (seconds, not milliseconds).
- **Streaming:** Always stream tokens back to the UI (Server-Sent Events or WebSockets) to reduce perceived latency.
- **Semantic Caching:** Cache LLM responses based on semantic similarity of prompts using Vector Databases (e.g., if a user asks a slightly reworded version of a cached question).
- **Smaller Models:** Use smaller, faster models (e.g., Llama-3-8b, GPT-4o-mini) for tasks like routing, classification, or summarization, reserving large models only for complex reasoning.

## Interview Questions
**Q: We have an endpoint that generates a massive report and takes 15 seconds to respond. Users are complaining, and connections are timing out. How do you fix it?**
*A: 15 seconds is too long for a synchronous HTTP request. I would decouple the process using the Async Request-Reply pattern.
1. The client requests the report.
2. The server creates a job in a message queue (SQS/RabbitMQ), saves a status 'PENDING' in the DB, and immediately returns an HTTP 202 Accepted with a Job ID.
3. A background worker processes the heavy report and saves the result to S3, updating the DB to 'COMPLETED'.
4. The client either polls a `/status` endpoint or receives a WebSocket/Webhook notification when the report is ready to download.*

**Q: Your k6 load test shows that at 500 RPS, your API latency jumps from 100ms to 5 seconds. What is your troubleshooting methodology?**
*A: I would look for the bottleneck systematically. 
1. APM / Tracing: Is the time spent in the App or DB?
2. If DB: Check for connection pool exhaustion, slow query logs, or lock contention.
3. If App: Check CPU and Memory. Is it thrashing due to GC? Are worker threads exhausted (e.g., Node.js event loop blocked)?
4. If neither: Check network infrastructure—is the API Gateway or Load Balancer queuing requests, or NAT Gateway dropping packets due to port exhaustion?*
