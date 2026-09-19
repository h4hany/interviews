# API Design for Technical Leads

## 1. RESTful Principles & Best Practices

### Resource-Oriented Design
- **Nouns, not Verbs:** APIs should model resources. Use `POST /users`, not `POST /createUser`.
- **Nesting:** Limit nesting to one level to avoid complex URLs. E.g., `GET /users/{id}/orders`. For deeply nested resources, use query parameters: `GET /orders?user_id={id}&status=shipped`.

### Idempotency
**What:** An operation is idempotent if making multiple identical requests has the same effect as making a single request.
- **Idempotent HTTP Methods:** `GET`, `PUT`, `DELETE`, `HEAD`, `OPTIONS`.
- **Non-idempotent:** `POST` (usually creates a new resource), `PATCH` (can be, but not strictly guaranteed).
- **Implementation:** For `POST` operations (like payments), use an `Idempotency-Key` header. The server stores the response for this key. If the client retries with the same key, the server returns the cached response instead of processing the payment twice.

### Versioning Strategies
1. **URI Versioning (Most Common):** `/v1/users`. Easy to route, visible. Drawback: changes the URL semantics.
2. **Header Versioning:** `Accept: application/vnd.company.v1+json`. Cleaner URLs, but harder to test via browser and requires header inspection.
3. **Query Parameter:** `/users?version=1`. Simple, but rarely used for core APIs.

## 2. Pagination: Cursor vs Offset

| Feature | Offset/Limit Pagination | Cursor Pagination |
|---------|-------------------------|-------------------|
| **Mechanism** | `?offset=100&limit=20` | `?cursor=eyJpZ...` |
| **Performance** | Slows down as offset grows (DB must scan & skip records) | Consistent O(1) performance using indexed columns |
| **Data Drift** | Missing or duplicate records if data changes during pagination | Immune to inserts/deletes, always fetches the correct "next" |
| **Use Case** | Admin panels, page numbers ("Page 3 of 10") | Infinite scroll, high-scale APIs, feeds |

## 3. Webhooks & Asynchronous Operations

**Long-Running Operations:**
When a request takes longer than a few seconds (e.g., video processing, report generation), do not block the HTTP response.
- **Pattern:** Accept the request, return `202 Accepted` with a `Location` header or a task ID.
- **Client polling:** Client polls `GET /tasks/{id}` until status is `completed`.
- **Webhooks:** Client registers a callback URL. Server pushes a POST request to the client when the job is done.

**Webhook Design Security:**
1. Use HMAC signatures so the client can verify the payload came from your server.
2. Require clients to return `2xx` quickly. Offload webhook processing to queues.
3. Implement exponential backoff for retries if the client endpoint fails.

## 4. API Security (OWASP Top 10 API)

- **BOLA (Broken Object Level Authorization):** User A requests `GET /users/User_B_ID` and the server allows it. *Fix:* Always verify the authenticated user has permissions for the specific resource ID requested.
- **Mass Assignment:** Client sends `{"username": "test", "is_admin": true}` and the ORM blindly updates it. *Fix:* Use explicit DTOs/schemas (like Pydantic) to strictly define allowed fields.
- **Rate Limiting:** Protect against DDoS and brute force. Implement Token Bucket or Leaky Bucket algorithms via Redis API gateways.

## 5. Interview Questions

**Q1: How do you design an API to handle bulk uploads of 1 million records?**
*Answer:* A single JSON payload is unfeasible due to memory constraints and timeouts. I would design a process:
1. Client requests an upload URL (`POST /bulk-imports/jobs` -> returns a pre-signed S3 URL and a Job ID).
2. Client uploads a CSV/JSONL file directly to the blob storage (bypassing our API servers).
3. S3 triggers an event (or client calls `POST /bulk-imports/jobs/{id}/start`).
4. A background worker (e.g., Celery/SQS) streams the file from S3, processing in chunks, writing to the DB.
5. Client polls the job status or receives a webhook upon completion.

**Q2: Contrast GraphQL and REST. When would you choose GraphQL?**
*Answer:* GraphQL prevents over-fetching and under-fetching by letting the client specify exactly what data it needs. It shines in complex, deeply relational data models (like social networks) or when aggregating data for mobile apps with limited bandwidth. However, REST is simpler, natively utilizes HTTP caching, and is easier to secure (rate limiting and complexity analysis in GraphQL can be difficult). For standard microservice-to-microservice communication, REST (or gRPC) is usually preferred over GraphQL.
