# Backend Staff Engineer (Node.js) Interview Guide — Yassir

A structured Q&A guide for the Backend Staff Engineer (Node.js) role at Yassir, from fundamentals to system design, leadership, and behavioral questions.

---

## Table of Contents

1. [Node.js Fundamentals](#1-nodejs-fundamentals)
2. [Asynchronous Patterns](#2-asynchronous-patterns)
3. [System Design](#3-system-design)
4. [Databases & Data Management](#4-databases--data-management)
5. [Performance & Optimization](#5-performance--optimization)
6. [Security & Reliability](#6-security--reliability)
7. [Testing](#7-testing)
8. [Leadership & Mentorship](#8-leadership--mentorship)
9. [Architecture & Advanced Topics](#9-architecture--advanced-topics)
10. [Behavioral Questions](#10-behavioral-questions)
11. [Questions You Should Ask](#11-questions-you-should-ask)
12. [Final Tips](#12-final-tips)

---

## 1. Node.js Fundamentals

### Q1: Explain the Node.js Event Loop.

**Answer:**  
The Event Loop is the core mechanism that allows Node.js to handle **non-blocking I/O** despite being single-threaded. It is implemented by **libuv** and runs in a fixed order of phases:

1. **Timers** — `setTimeout` / `setInterval` callbacks  
2. **Pending callbacks** — deferred I/O callbacks  
3. **Idle / prepare** — internal use  
4. **Poll** — retrieve new I/O events; execute I/O callbacks; may block here  
5. **Check** — `setImmediate()` callbacks  
6. **Close callbacks** — e.g. `socket.on('close')`

**Microtasks** run *between* phases: first the entire **`process.nextTick()`** queue, then the **Promise** callback queue. So nextTick and Promise callbacks run before the next phase (e.g. before the next timer). **Macrotasks** (setTimeout, setImmediate, I/O) run in their respective phases.

---

### Q2: Difference between `process.nextTick()` and `setImmediate()`?

**Answer:**  
- **`process.nextTick()`** — Runs after the current operation, *before* the event loop moves to the next phase. Lives in the **microtask** queue. Highest priority; overuse can starve I/O and block the loop.  
- **`setImmediate()`** — Runs in the **check** phase (after I/O). Good for deferring work until after the current I/O callbacks.

In practice: use **setImmediate** when you want “after I/O”; use **nextTick** only when you need to run before the next phase (e.g. in libraries), and avoid scheduling a lot of work with it.

---

### Q3: Why is Node.js single-threaded and still scalable?

**Answer:**  
- **Non-blocking I/O** — While waiting on network, DB, or disk, the thread serves other requests; no thread per connection.  
- **libuv** — Offloads I/O to the OS (and uses a small **thread pool** for file/crypto/DNS), so the main thread stays free.  
- **I/O-bound workloads** — Typical APIs and proxies are I/O-bound; one thread can handle many concurrent operations.  
- **Scaling out** — For more throughput: **cluster** (multiple processes, one per CPU) or **horizontal scaling** (more instances behind a load balancer). For **CPU-bound** work: **worker_threads** or separate services.

---

### Q4: Why avoid `require()` inside functions?

**Answer:**  
- **`require()` is synchronous** — It blocks the event loop. If the module isn’t in `require.cache`, disk and parsing block the thread.  
- **Unpredictable performance** — First call loads and runs the module; later calls use cache. Putting it in hot paths can cause occasional latency spikes.  
- **Best practice** — Load dependencies at **top-level** (or at app startup) so startup pays the cost and request handling stays fast.  
- **Dynamic imports** — If you truly need conditional loading, use **`import()`** (async) in ESM so you don’t block the loop.

---

## 2. Asynchronous Patterns

### Q5: Difference between Promises and async/await?

**Answer:**  
Both represent asynchronous values; **async/await** is syntactic sugar over Promises.

| Aspect        | Promise.then()     | async/await           |
|---------------|--------------------|------------------------|
| Readability   | Chain-based        | Linear, like sync code |
| Error handling| `.catch()` / .then(fn, err) | `try/catch`        |
| Debugging     | Harder (many .then)| Easier (stack traces)  |
| Control flow  | Multiple chains    | Sequential by default  |
| Concurrency   | Promise.all etc.   | await in loop or Promise.all |

Use **async/await** for clarity; use **Promise.all** / **Promise.allSettled** when you need parallel async work.

---

### Q6: How do you handle concurrency in Node.js?

**Answer:**  
- **Parallel async I/O** — `Promise.all()` for “all must succeed,” `Promise.allSettled()` for “run all, get outcomes.”  
- **CPU-bound work** — **Worker Threads** (shared memory optional) or **child_process** so the event loop isn’t blocked.  
- **Distributed concurrency** — **Message queues** (Kafka, RabbitMQ) for cross-service work and backpressure.  
- **Rate limiting** — Limit concurrency with semaphores, queues, or libraries (e.g. `p-limit`) to avoid overwhelming DBs or APIs.  
- **Cluster** — Multiple Node processes (e.g. one per CPU) for throughput of I/O-bound HTTP servers.

---

## 3. System Design

### Q7: Design a ride-hailing system like Yassir.

**Answer:**  
**High-level architecture**

- **Microservices:**  
  - **User Service** — Auth, profile, preferences.  
  - **Ride/Booking Service** — Create trip, state machine (requested → matched → in_progress → completed/cancelled).  
  - **Driver Service** — Driver state, availability, location updates.  
  - **Matching Service** — Find nearby drivers (geo), apply rules (vehicle type, rating).  
  - **Payment Service** — Charges, payouts, idempotent processing.  
  - **Notification Service** — Push, SMS, in-app (events from Kafka).

**Key components**

- **API Gateway** — Auth (JWT/session), rate limiting, routing, request validation.  
- **Redis** — Real-time driver locations (e.g. GeoHash/Redis Geo), session/cache; optional leaderboard or ETA cache.  
- **Kafka (or similar)** — Events: ride requested, driver assigned, ride completed, payment initiated. Enables async flows and replay.  
- **PostgreSQL** — Rides, users, drivers, payments (ACID where needed).  
- **Elasticsearch (optional)** — Search (e.g. ride history, analytics).

**Flow (simplified)**

1. User requests ride (idempotency key, origin/destination, vehicle type).  
2. **Matching**: Query nearby available drivers (Redis Geo or DB with geo index).  
3. Notify drivers (push/WebSocket); first accept or timeout → assign driver.  
4. Track location updates (driver → service → store in Redis/DB).  
5. On trip end: compute fare, emit event, **Payment Service** charges (idempotent).  
6. Notifications (receipt, rating prompt) via event-driven flow.

**Staff-level considerations**

- **Idempotency** on ride creation and payment to avoid double charges.  
- **Consistency**: critical operations in one service/DB; eventual consistency for cross-service (e.g. ride + payment).  
- **Geo**: Index and query efficiency (Redis Geo, PostGIS, or dedicated geo DB).  
- **Availability**: Stateless app servers, DB replicas, circuit breakers for external services.

---

### Q8: How do you scale a Node.js application?

**Answer:**  
- **Horizontal scaling** — Run multiple instances behind a **load balancer** (NGINX, ALB, etc.).  
- **Stateless app** — No in-memory session state; use Redis or DB for session so any instance can serve any request.  
- **Caching** — Redis for hot data (e.g. driver locations, user session, API responses) to reduce DB load.  
- **Database** — Read replicas, connection pooling, indexing, query optimization; **sharding** by a key (e.g. user_id, region) when one DB isn’t enough.  
- **Async processing** — Offload heavy or non-critical work to **message queues** (Kafka, RabbitMQ, SQS).  
- **Node-level** — **Cluster** module or PM2 cluster to use all CPU cores per machine.  
- **Observability** — Metrics, tracing, logs to find bottlenecks and set SLOs.

---

### Q9: What is an API Gateway and why use it?

**Answer:**  
An **API Gateway** is a single entry point for client requests to backend services.

**Typical responsibilities:**  
- **Authentication / authorization** — Validate JWT or API keys; forward identity to services.  
- **Rate limiting** — Per user/IP/key to protect backends and ensure fairness.  
- **Routing** — Path-based or header-based routing to different services (e.g. `/rides` → Ride Service).  
- **Request/response transformation** — Aggregation, protocol translation (REST → gRPC internally).  
- **Logging and monitoring** — Central place for access logs, metrics, and sometimes tracing.

**Benefits:**  
- **Security** — One place to enforce auth and rate limits.  
- **Decoupling** — Clients see one API; backends can change without changing clients.  
- **Operability** — Centralized observability and policy (e.g. circuit breaking at the edge).

---

## 4. Databases & Data Management

### Q10: When to use SQL vs NoSQL?

**Answer:**  
- **SQL (e.g. PostgreSQL)** when you need:  
  - **ACID** and strong consistency (payments, bookings, inventory).  
  - **Complex queries**, joins, and relational integrity.  
  - **Structured schema** and migrations.  
- **NoSQL** when you need:  
  - **Very high write/read scale** and horizontal scaling (e.g. Cassandra, DynamoDB).  
  - **Flexible or evolving schema** (e.g. MongoDB for documents).  
  - **Specific access patterns** (key-value, wide-column, graph).

**For a ride-hailing app:** Use **PostgreSQL** for users, rides, payments (transactions); use **Redis** for session, cache, and real-time geo; consider **NoSQL** for high-volume event or analytics data if needed.

---

### Q11: How would you design a wishlist + notification system?

**Answer:**  
**Components**

- **Wishlist Service** — CRUD for user wishlists (e.g. items, product IDs). Store in DB; expose API.  
- **Inventory / Catalog Service** — Knows when items are in stock or on sale.  
- **Event bus** — Kafka or similar (e.g. topic: `product.available` or `product.discounted`).  
- **Notification Service** — Subscribes to events; sends email/push/SMS (template + user preferences).

**Flow**

1. User adds item to wishlist → stored in DB (Wishlist Service).  
2. When item becomes available (or discounted), Inventory/Catalog publishes an event.  
3. **Wishlist Service** (or a dedicated worker) consumes event, finds users who wishlisted that item.  
4. For each user, emit “send notification” (or call Notification Service) with channel preference.  
5. Notification Service sends email/push and marks as sent (idempotency to avoid duplicates).

**Staff-level considerations:** Idempotency for notifications, batching to avoid thundering herd, and respecting user preferences and rate limits.

---

## 5. Performance & Optimization

### Q12: How do you handle memory leaks in Node.js?

**Answer:**  
- **Identify** — **Heap snapshots** (Chrome DevTools, `node --inspect`); compare before/after or over time. Look for growing arrays, caches, or closures.  
- **Common causes:**  
  - **Global or module-level state** that grows (e.g. unbounded caches, request data stored in globals).  
  - **Event listeners** not removed (especially on long-lived objects like servers or shared emitters).  
  - **Closures** holding large references; **setInterval**/setTimeout keeping references alive.  
- **Mitigations:**  
  - Avoid storing request-scoped data in module/global scope; use **AsyncLocalStorage** for context.  
  - Remove listeners when done (`EventEmitter` `removeListener`/`off`) or use `{ once: true }`.  
  - Cap caches (size or TTL); use weak references where appropriate.  
- **Operationally** — Monitor RSS/heap (PM2, New Relic, Datadog); set alerts and restarts if needed.

---

### Q13: How do you improve API performance?

**Answer:**  
- **Caching** — Redis (or in-memory) for hot reads; cache invalidation strategy (TTL, events).  
- **Pagination** — Cursor-based or offset with a cap to avoid large result sets and deep offsets.  
- **DB** — Indexes for hot queries; avoid N+1 (batch or join); connection pooling; read replicas for read-heavy paths.  
- **Payload** — Compression (gzip/brotli); return only needed fields (field selection or GraphQL).  
- **Async** — Offload non-critical work to queues; use streaming for large responses.  
- **Infrastructure** — CDN for static/assets; HTTP/2; keep app stateless and horizontally scalable.

---

## 6. Security & Reliability

### Q14: How do you secure a Node.js/Express API?

**Answer:**  
- **Authentication** — JWT or session (httpOnly cookies); validate on every protected route.  
- **Authorization** — Check permissions after auth (RBAC/ABAC as needed).  
- **Input validation** — Schema validation (Joi, Zod, express-validator) on body/query/params; sanitize to prevent injection and XSS.  
- **HTTPS** — Enforce TLS; secure cookies.  
- **Headers** — Helmet for security headers; CORS restricted to known origins.  
- **Rate limiting** — Per IP/user/key (e.g. express-rate-limit) to prevent abuse and DDoS.  
- **Secrets** — Env vars or secret manager; never in code; rotate regularly.  
- **Dependencies** — Audit (npm audit); keep deps updated.

---

### Q15: How do you implement graceful shutdown?

**Answer:**  
- Listen for **SIGTERM** (and **SIGINT** for Ctrl+C).  
- **Stop accepting new work** — e.g. `server.close()` so the load balancer stops sending new connections.  
- **Finish in-flight requests** — Allow current handlers to complete (with a **timeout**).  
- **Close resources** — DB pool, Redis client, queue consumers, then exit with `process.exit(0)`.  
- **Timeout** — If shutdown doesn’t complete in N seconds, force exit to avoid stuck processes (e.g. in Kubernetes).

Example idea: `process.on('SIGTERM', () => { server.close(() => { db.close().then(() => process.exit(0)); }); });`

---

## 7. Testing

### Q16: How do you write testable code?

**Answer:**  
- **Dependency injection** — Pass DB, queue, or HTTP client into handlers/services so tests can inject mocks.  
- **Small, focused functions** — Single responsibility; pure where possible; easier to unit test.  
- **Avoid tight coupling** — Depend on interfaces/contracts, not concrete implementations.  
- **Mock external services** — Use test doubles (e.g. in-memory DB, mock HTTP) so tests are fast and deterministic.  
- **Layers** — Route → controller → service → repo: test business logic (service) with mocked repo; integration tests for critical paths.

---

### Q17: Tools for testing in Node.js?

**Answer:**  
- **Unit / integration** — **Jest** (popular, built-in mocks, coverage) or **Mocha** + **Chai** (flexible).  
- **HTTP/API** — **Supertest** with Express (or similar) to hit routes and assert status/body.  
- **E2E** — **Playwright** or **Puppeteer** for browser; Postman/Newman for API flows.  
- **Mocking** — **sinon** for stubs/spies; **nock** for HTTP; Jest’s built-in mocks.  
- **Coverage** — Jest’s coverage or **c8**/Istanbul.

---

## 8. Leadership & Mentorship

### Q18: How do you mentor junior engineers?

**Answer:**  
- **Code reviews** — Explain *why* (design, security, performance), not only “change this.”  
- **Pair programming** — On hard bugs or design; share shortcuts and debugging habits.  
- **Ownership** — Assign clear ownership (e.g. a service or area) so they can go deep.  
- **Problem-solving** — Ask guiding questions instead of giving the answer; point to docs or runbooks.  
- **Feedback** — Regular 1:1s; balance positive feedback with concrete, actionable improvement.

---

### Q19: How do you handle technical disagreements?

**Answer (STAR):**  
- **Situation** — Disagreement on whether to split a service or adopt a new framework.  
- **Task** — Align on a decision that best serves reliability, timeline, and team capacity.  
- **Action** — Captured options and trade-offs; built a small POC or benchmark; shared results; discussed with the team and stakeholders.  
- **Result** — Decision was data-driven and documented; team bought in and we had a clear rollback path.

---

### Q20: How do you manage technical debt?

**Answer:**  
- **Visibility** — Track debt in backlog (tickets, labels, or a doc); link to incidents or slowdowns.  
- **Allocate time** — e.g. ~20% or “payback” sprints so debt is addressed regularly.  
- **Prioritize** — By impact (reliability, velocity, onboarding) and cost of delay.  
- **Incremental refactors** — Prefer small, safe steps over big rewrites; feature flags and tests to de-risk.  
- **Prevent new debt** — Standards, reviews, and “boy scout rule” (leave code better when you touch it).

---

## 9. Architecture & Advanced Topics

### Q21: Monolith vs Microservices?

**Answer:**  
| Monolith | Microservices |
|----------|----------------|
| Single codebase and deploy | Many services, independent deploy |
| Simpler ops and debugging | More operational complexity (observability, deployment) |
| Hard to scale parts independently | Scale and scale teams per service |
| Tight coupling, risk of “big ball of mud” | Loose coupling, clear boundaries |
| Good for small teams and early stage | Good when teams and domains are large and distinct |

Start with a **modular monolith** (bounded contexts, clear interfaces); split into services when you hit real limits (team size, scaling, technology). Avoid microservices only for the sake of it.

---

### Q22: Event-driven architecture?

**Answer:**  
- **Idea** — Services produce and consume **events** (e.g. “ride.completed,” “payment.succeeded”) instead of only synchronous RPC/HTTP.  
- **Tools** — Kafka, RabbitMQ, AWS EventBridge, etc.  
- **Benefits** — Loose coupling (producers don’t know consumers), scalability (multiple consumers), resilience (retries, DLQ), and replay for recovery or new features.  
- **Trade-offs** — Eventually consistent; harder to debug end-to-end; need schemas/versioning and idempotent consumers.

---

## 10. Behavioral Questions

### Q23: Why Yassir?

**Answer:**  
- **Super App vision** — Multiple services (ride-hailing, delivery, payments) in one place; interesting product and technical challenges.  
- **Impact in Africa** — Opportunity to build systems that affect many users and markets.  
- **Scale and growth** — Real scaling, reliability, and platform challenges as the company grows.  
- **Role** — Chance to lead architecture, standards, and mentoring as a Staff Engineer.

---

### Q24: Describe a system you scaled.

**Answer:**  
Structure the story clearly:  
- **Problem** — What was failing or limiting (e.g. latency, throughput, cost)?  
- **What you did** — Architecture or infra changes (caching, DB, queues, splitting services).  
- **Metrics** — Before/after (e.g. p99, RPS, error rate).  
- **Learnings** — What you’d do differently or what you standardized after (monitoring, capacity planning).

---

### Q25: Your 5–10 year goal?

**Answer:**  
- Progress toward **Principal Engineer or CTO** — Own technical strategy and large systems.  
- **Lead** — Cross-team or org-wide initiatives (reliability, platform, data).  
- **Mentor** — Grow senior and staff engineers.  
- **Product impact** — Drive products that reach many users (e.g. global or multi-country).

---

## 11. Questions You Should Ask

- How do you ensure **consistency and data integrity** across microservices (e.g. sagas, outbox, two-phase)?  
- What are the **biggest scaling or reliability challenges** you face today?  
- How do you balance **speed of delivery** vs **quality and tech debt**?  
- What does **success** look like for this role in the first 6 months?  
- How are **on-call** and **incident response** organized?  
- How do **backend** and **product/mobile** teams collaborate on API design and rollout?

---

## 12. Final Tips

- Think **systems and trade-offs**, not only code — availability, consistency, scalability, and operability.  
- Show **ownership** — “I would measure X, then do Y, and own the outcome.”  
- Be **data-driven** — Refer to metrics, benchmarks, or incidents when discussing decisions.  
- Demonstrate **leadership** — Clarify requirements, align stakeholders, mentor, and document decisions.  
- For system design — **Clarify scope** (e.g. just matching, or full flow), then **outline components**, **data flow**, and **failure modes** before diving into details.
