> Imagine you need to build, deploy, and run a TypeScript-based microservice on Azure that exposes a high-throughput
> REST API for third-party partner integrations.
> Walk me through your end-to-end approach

### Covering

***1. Type modeling:***

how you’d use advanced TypeScript features (e.g. generics, mapped or conditional types) to ensure domain-safe code?

- using generics for reusable data structures (e.g., paginated responses):
  ```typescript
        interface Paginated<T> {
            data: T[];
            meta: {
            total: number;
            limit: number;
            offset: number;
            };
        }
  ```
- using mapped typed and conditional type
  ```typescript
    type Readonly<T> = {
         readonly [K in keyof T]: T[K];
    };
    type ExtractKeys<T, U> = T extends U ? keyof T : never;
  ```
- using union for cases like payment status
  ```typescript
    type PaymentStatus = 
      | { status: 'success'; transactionId: string }
      | { status: 'failed'; reason: string };
  ```

Why: These reduce bugs, ensure schema evolution safety

***2. API Design:***

- Pagination: Offset or cursor-based (cursor preferred for high throughput).
- Filtering: Accept structured filters, e.g. GET /orders?status=pending&createdAfter=2023-01-01.
- Versioning: Via URI (/v1/orders) or header (Accept-Version), avoiding breaking changes.
- Idempotency: Use Idempotency-Key header with Redis-backed deduplication for POST/PUT requests.
- Error Handling: Standardized error format with codes:
    ```json
        {
          "error": {
            "code": "VALIDATION_ERROR",
            "message": "Invalid input",
            "details": { "field": "email" }
          }
        }
    ```
  Tools: OpenAPI (Swagger)

***3. Infrastructure & CI/CD:***

i didn't work with azure before but the is no big different between it and aws

- Azure Resources: (found this by search but they are same as aws )
    - Azure Kubernetes Service (AKS) for container orchestration.
    - Azure API Management (APIM) for managing, throttling, and monitoring external access.
    - Azure Cosmos DB / PostgreSQL / Service Bus based on data/storage/event needs.
    - Azure Key Vault for secrets management.
- Automation
    - Infrastructure as Code: Use Terraform
    - CI/CD: GitHub Actions , bitbucket pipeline , or Azure DevOps Pipelines (i found this by search i don't know it )
        - Lint, test, build container
        - Deploy to AKS via Helm charts
        - Use blue/green or canary deployments for zero downtime.

***4. Reliability: SLIs & Resilience:***

- SLIs:
    - Availability: % of successful responses < 500.
    - Latency: p95 response time < 300ms.
    - Error Rate: < 0.5% of total requests.

- Patterns:
    - Retry/Backoff: Exponential backoff with jitter (e.g., Axios interceptors or Polly).
    - Circuit Breaker: Use libraries like opossum
    - Timeouts & Bulkheads to isolate failures.

- Monitoring:
    - Use Azure Monitor, App Insights, and Prometheus/Grafana in AKS.
    - Structured logging (e.g., pino), trace correlation using OpenTelemetry.

***5. Data Consistency:***

- Patterns:
    - For strong consistency, use distributed transactions with Outbox pattern and eventual consistency.
    - For long-running processes, use Saga pattern:
        - Orchestrated (centralized coordinator)
        - Choreographed (event-driven with pub/sub)

- Tools:
  Temporal.io, Azure Durable Functions, or custom orchestrators with queues and retry logic.

- Example:
  When creating an order:
  Save in DB → publish OrderCreated event → inventory service handles asynchronously.
  On failure, publish OrderFailed to trigger rollback/compensations.

***6. Performance Tuning***

- Detection:
    - Use Azure Application Insights, OpenTelemetry, and Prometheus to collect:
        - Latency per endpoint
        - DB query times
        - External API call latencies

- Diagnosis:
    - CPU/memory profiling with Clinic.js, Node.js profiler
    - Trace slow routes with Flamegraphs or distributed tracing

- Resolution:
    - DB Indexing
    - Cache frequently accessed data (Redis )
    - Offload heavy tasks to background jobs
    - Rate limiting (e.g., Redis token bucket)
    - Optimize JSON serialization/deserialization