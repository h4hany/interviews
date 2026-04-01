# Node.js Interview Mastery — Yassir Staff Backend Engineer

> **Company Context:** Yassir is the leading super-app in the Maghreb region (Algeria, Morocco, Tunisia + France, Canada, Sub-Saharan Africa). Backed by $200M, it runs ride-hailing, last-mile delivery, and digital financial services on **Google Cloud (GKE, Pub/Sub, Cloud Run, BigQuery, Vertex AI)**. Their stack includes **Node.js, NestJS, Go, Java, React, MongoDB, PostgreSQL**. As a Staff Engineer you will own architecture decisions across squads, mentor engineers, and drive the technical roadmap. Expect deep NestJS/Node.js questions, distributed systems design, event-driven architecture, and leadership scenarios.

---

## TABLE OF CONTENTS

1. [Glassdoor Questions — Detailed Answers](#1-glassdoor-questions--detailed-answers)
2. [Node.js Core & Runtime](#2-nodejs-core--runtime)
3. [NestJS Deep Dive](#3-nestjs-deep-dive)
4. [Async Patterns & Event Architecture](#4-async-patterns--event-architecture)
5. [Distributed Systems & Microservices](#5-distributed-systems--microservices)
6. [System Design: Wishlist + Email Notification](#6-system-design-wishlist--email-notification)
7. [System Design: Shopping Cart & Order Placement](#7-system-design-shopping-cart--order-placement)
8. [Database & Persistence](#8-database--persistence)
9. [API Design & Reverse Proxy](#9-api-design--reverse-proxy)
10. [Testing, CI/CD & Engineering Standards](#10-testing-cicd--engineering-standards)
11. [Staff-Level Leadership Questions](#11-staff-level-leadership-questions)
12. [Quick-Fire Reference Cheatsheet](#12-quick-fire-reference-cheatsheet)

---

## 1. Glassdoor Questions — Detailed Answers

---

### Q1 — What is the difference between `Promise.then` and `await`? 🔥 PROBABILITY: 95%

**Short answer:** Both handle Promises, but they differ in syntax style, error handling, and execution flow control.

**Detailed answer:**

`Promise.then` is the original chaining API. It takes a callback and returns a new Promise, enabling chains:

```js
fetchUser(id)
  .then(user => fetchOrders(user.id))
  .then(orders => processOrders(orders))
  .catch(err => console.error(err));
```

`await` is syntactic sugar introduced in ES2017. It pauses execution of an `async` function until the Promise settles, making code read like synchronous code:

```js
async function loadUserOrders(id) {
  const user = await fetchUser(id);
  const orders = await fetchOrders(user.id);
  return processOrders(orders);
}
```

**Key differences:**

| Aspect | `.then()` | `await` |
|---|---|---|
| Style | Callback/chain | Synchronous-looking |
| Error handling | `.catch()` at end of chain | `try/catch` block |
| Parallelism | Easy with `Promise.all` inline | Need `Promise.all` explicitly |
| Stack traces | Harder to debug | Better, more readable traces |
| Context | Works anywhere | Only inside `async` functions |
| Short-circuit | `.catch()` handles all above | Each `await` needs its own `try/catch` or outer block |

**Parallel execution — common trap:**

```js
// SEQUENTIAL — waits for each one (slow)
const a = await fetchA();
const b = await fetchB();

// PARALLEL — both start simultaneously (fast)
const [a, b] = await Promise.all([fetchA(), fetchB()]);
```

**When to use which:**
- Use `await` for linear, sequential logic — easier to read and debug.
- Use `.then()` chaining when you want a functional pipeline or when working outside async contexts (e.g., in module-level code in older Node.js).
- Prefer `Promise.allSettled` when you want all results even if some fail.

---

### Q2 — What happens if you place a `require()` inside a function scope? 🔥 PROBABILITY: 85%

**Short answer:** It works, but it defers loading and can have performance and caching implications.

**Detailed answer:**

Node.js module loading with `require()` is **synchronous** and **cached**. The first time a module is required, Node reads and executes the file, then stores the `module.exports` result in `require.cache` keyed by the resolved filename. Subsequent `require()` calls return the cached value instantly.

**When `require` is at the top level (normal):**
```js
const fs = require('fs'); // Loaded once at startup, always available
```

**When `require` is inside a function:**
```js
function processCSV(filePath) {
  const csv = require('csv-parser'); // Loaded on first call, cached after
  // ...
}
```

**What actually happens:**
1. First call: Node resolves the path, reads the file from disk synchronously, executes it, caches the result. This can block the event loop momentarily.
2. Subsequent calls: The cached module is returned instantly — no disk I/O. Essentially free.

**When is this useful?**
- **Lazy loading** — only load heavy modules when needed (e.g., a PDF generator module only needed if the user requests a PDF).
- **Conditional dependencies** — load different implementations based on environment.
- **Circular dependency management** — sometimes helps break circular require chains.

**Downsides / things to know:**
- The first call is synchronous and blocking. In a hot path (called frequently at startup) this is bad.
- Harder to mock in tests — tools like `jest.mock()` work best with top-level requires.
- Code readability suffers — dependencies are hidden inside functions.
- In ESM (`import`), you cannot do this — ESM is statically analyzed. Instead you'd use dynamic `import()` which returns a Promise.

**Staff-level nuance:** In large NestJS apps, lazy loading modules (`LazyModuleLoader`) is the equivalent pattern — you defer module initialization to reduce startup time, which matters for serverless (Cloud Run) cold starts at Yassir's scale.

---

### Q3 — How does the Event Loop work? 🔥 PROBABILITY: 98%

**Short answer:** The event loop is what makes Node.js non-blocking. It continuously checks a series of queues and executes callbacks when I/O and timers are ready.

**Detailed answer:**

Node.js runs on a single thread but handles concurrency through the event loop, which processes callbacks registered for I/O, timers, and other async operations.

**The phases of the event loop (in order):**

```
   ┌──────────────────────────────────────┐
   │         1. timers                    │  setTimeout, setInterval callbacks
   │         2. pending callbacks         │  I/O errors from previous iteration
   │         3. idle, prepare             │  internal use
   │         4. poll                      │  ← retrieve new I/O events; execute I/O callbacks
   │         5. check                     │  setImmediate callbacks
   │         6. close callbacks           │  socket.on('close', ...)
   └──────────────────────────────────────┘
         ↑___________________________________↓
```

**Microtask queues (run between EVERY phase):**
- `process.nextTick()` — highest priority, drains completely before moving on
- `Promise.resolve()` / `queueMicrotask()` — drains after nextTick queue

**Execution order example:**

```js
console.log('1 - sync');

setTimeout(() => console.log('2 - setTimeout'), 0);

setImmediate(() => console.log('3 - setImmediate'));

Promise.resolve().then(() => console.log('4 - promise microtask'));

process.nextTick(() => console.log('5 - nextTick'));

console.log('6 - sync end');

// Output:
// 1 - sync
// 6 - sync end
// 5 - nextTick        ← microtask queue (nextTick drains first)
// 4 - promise microtask ← microtask queue (promises)
// 2 - setTimeout      ← timers phase
// 3 - setImmediate    ← check phase
```

**The poll phase** is the heart of I/O:
- When I/O callbacks are pending, the loop enters poll, retrieves completed I/O events from the OS (via libuv), and executes their callbacks.
- If no I/O is pending and no timers are set, it blocks here waiting for new I/O.

**Blocking the event loop** — the #1 performance sin:
```js
// BAD — blocks the loop for every request
app.get('/compute', (req, res) => {
  const result = heavyCPUWork(); // Starves all other requests
  res.send(result);
});

// GOOD — offload to worker thread
const { Worker } = require('worker_threads');
app.get('/compute', (req, res) => {
  const worker = new Worker('./heavy-work.js');
  worker.on('message', result => res.send(result));
});
```

**libuv thread pool** (default 4 threads, max 1024 via `UV_THREADPOOL_SIZE`):
- Handles: file system ops, DNS lookups, crypto, zlib
- Network I/O (TCP/UDP) uses OS async APIs — does NOT use the thread pool

---

### Q4 — How to design a distributed system? 🔥 PROBABILITY: 90%

**Short answer:** Start with requirements, identify service boundaries, choose communication patterns, plan for failure, and design for observability.

**Detailed answer — the Staff Engineer framework:**

**Step 1: Clarify requirements**
- What are the read/write ratios?
- What's the SLA? (99.9% = ~8.7hr downtime/year; 99.99% = ~52 min)
- What's the expected QPS? Peak load?
- Do we need strong consistency or is eventual consistency acceptable?

**Step 2: Identify service boundaries (DDD approach)**
- Model around bounded contexts (Orders, Users, Payments, Notifications, Catalog)
- Services own their data — no shared databases between services
- At Yassir: Ride service, Delivery service, Wallet service, Notification service

**Step 3: Choose communication patterns**

| Pattern | When to use | Tech at Yassir scale |
|---|---|---|
| Sync REST/gRPC | Query/response, client needs immediate answer | API Gateway → services |
| Async messaging | Decouple producers from consumers, high throughput | Google Cloud Pub/Sub, Kafka |
| Event streaming | Audit trail, replay, CQRS | Kafka, Pub/Sub |

**Step 4: Handle failure (everything fails)**
- **Retry with exponential backoff** — don't hammer a failing service
- **Circuit breaker** — fail fast when downstream is down (Resilience4j / custom)
- **Bulkhead** — isolate resource pools so one service failure doesn't starve others
- **Idempotency** — POST /orders with idempotency key; safe to retry
- **Dead letter queues** — capture messages that fail to process

**Step 5: Data management**
- Each service owns its DB (polyglot persistence is fine)
- Distributed transactions → use Saga pattern (choreography or orchestration)
- CQRS: separate read models from write models for high-read services

**Step 6: Observability**
- **Metrics:** Latency (p50/p95/p99), error rate, throughput (USE/RED methods)
- **Distributed tracing:** OpenTelemetry → Jaeger/Google Cloud Trace
- **Centralized logging:** Structured JSON logs → BigQuery / Cloud Logging
- **Alerting:** SLO-based alerts (burn rate), not just threshold-based

**Yassir-specific context:** Their ride-hailing and delivery platform is a classic multi-sided marketplace with real-time matching. They use GKE for orchestration, Pub/Sub for event streaming, and Vertex AI for personalization. Design for 100k+ concurrent partners.

---

### Q5 — How do you choose a library? 🔥 PROBABILITY: 75%

**Framework for evaluating a library (as a Staff Engineer):**

1. **Maintenance health**
   - Last commit date, release frequency, issue response time
   - Number of maintainers (bus factor)
   - Is it backed by a company or a solo dev?

2. **Community & adoption**
   - Weekly npm downloads (meaningful signal)
   - GitHub stars trend (growing or declining?)
   - StackOverflow activity, Discord/Slack community size

3. **Security posture**
   - Known CVEs (check Snyk, npm audit)
   - How fast do maintainers patch security issues?
   - Dependency tree size — more deps = more attack surface

4. **Bundle size & performance**
   - Use bundlephobia.com for frontend libs
   - Benchmark against alternatives for critical paths

5. **API design & ergonomics**
   - Does the API align with how your team thinks?
   - TypeScript support (first-class types vs. `@types/*` community types)?
   - Does it work with your existing stack (NestJS DI, etc.)?

6. **License compatibility**
   - MIT/Apache-2.0 are fine. GPL has copyleft implications for commercial products.

7. **Escape hatch**
   - If we need to replace this in 2 years, how hard is it?
   - Abstract it behind an interface in your codebase from day one.

**Example — choosing a job queue library for Yassir's notification service:**
- BullMQ (Redis-backed): mature, 50k+ stars, NestJS `@nestjs/bull` integration, supports delayed jobs and rate limiting ✓
- Agenda (MongoDB-backed): lighter, but slower, fewer features ✗
- Decision: BullMQ because it fits the stack and handles Yassir's email batching requirement

---

### Q6 — Reverse Proxy & Monolith-to-Microservices 🔥 PROBABILITY: 80%

**Reverse Proxy:**

A reverse proxy sits in front of backend services. Clients talk to the proxy; the proxy forwards requests to the appropriate backend.

```
Client → [Nginx / Kong / Envoy] → [Service A]
                                 → [Service B]
                                 → [Service C]
```

**What a reverse proxy provides:**
- **Load balancing** — round-robin, least-connections, IP hash
- **SSL termination** — decrypt HTTPS once, forward HTTP internally
- **Rate limiting** — protect services from abuse
- **Auth** — verify JWTs before requests reach services
- **Caching** — cache static responses
- **Request routing** — `/api/rides/*` → Ride Service, `/api/wallet/*` → Wallet Service
- **Canary / blue-green deployments** — route % of traffic to new version

**At Yassir's scale:** Kong or Envoy as API gateway in front of GKE services. Nginx for static assets. Cloud Load Balancer for global traffic distribution.

**Monolith → Microservices migration (the Strangler Fig pattern):**

```
Phase 1: Add reverse proxy in front of monolith
         Client → Proxy → Monolith (unchanged)

Phase 2: Carve out first service (e.g., Notifications)
         Client → Proxy → /notifications/* → Notification Service (new)
                        → everything else  → Monolith

Phase 3: Repeat for each bounded context
         Eventually the monolith is "strangled" — each piece replaced

Phase 4: Decommission the monolith
```

**Key challenges and how to handle them:**
- **Shared database** — use the Database-per-Service pattern; migrate data gradually using dual writes
- **Distributed transactions** — implement Saga pattern
- **Cross-cutting concerns** — extract to shared libraries or sidecar proxies
- **Testing** — contract testing with Pact, consumer-driven contracts
- **Feature flags** — route traffic to new service only for % of users first

---

## 2. Node.js Core & Runtime

---

### Q7 — Explain the Node.js module system: CommonJS vs ESM 🔥 PROBABILITY: 70%

**CommonJS (CJS):**
```js
// Synchronous, dynamic
const lodash = require('lodash');
module.exports = { myFunc };
```

**ES Modules (ESM):**
```js
// Asynchronous, static analysis, tree-shakeable
import { debounce } from 'lodash-es';
export const myFunc = () => {};
```

**Key differences:**

| | CommonJS | ESM |
|---|---|---|
| Loading | Synchronous | Asynchronous |
| Analysis | Runtime | Static (build time) |
| Tree shaking | No | Yes |
| `__dirname` | Available | Use `import.meta.url` |
| Circular deps | Partial result returned | Error or undefined |
| Node support | All versions | Node 12+ (stable 14+) |

**NestJS** uses CommonJS by default (compiled TypeScript). You can mix them with `"type": "module"` in package.json but it requires careful handling.

---

### Q8 — Memory management & garbage collection in Node.js 🔥 PROBABILITY: 65%

Node.js uses V8's garbage collector (mark-and-sweep with generational collection):

- **Young generation (Scavenge GC):** Short-lived objects. Fast, frequent GC. Objects promoted to old gen if they survive 2 GC cycles.
- **Old generation (Mark-Sweep-Compact):** Long-lived objects. Slower, incremental.

**Common memory leaks:**
```js
// 1. Forgotten event listeners
const emitter = new EventEmitter();
emitter.on('data', handler); // Never removed → handler + closure leak

// Fix:
emitter.once('data', handler);
// or
emitter.removeListener('data', handler);

// 2. Growing caches with no eviction
const cache = {};
app.get('/user/:id', async (req, res) => {
  cache[req.params.id] = await db.getUser(req.params.id); // Grows forever!
});
// Fix: Use LRU cache (lru-cache package) with max size

// 3. Closures holding references
function makeAdder(x) {
  const bigArray = new Array(1000000).fill(x); // Held by closure!
  return (y) => bigArray[0] + y;
}
```

**Profiling:**
```bash
node --inspect app.js          # Chrome DevTools memory profiler
node --max-old-space-size=4096 # Increase heap (default ~1.5GB)
```

---

### Q9 — Worker Threads vs Child Processes vs Cluster 🔥 PROBABILITY: 72%

| | Worker Threads | Child Process | Cluster |
|---|---|---|---|
| Isolation | Shared memory possible | Fully isolated | Fully isolated |
| Use case | CPU-heavy tasks | Run external programs | Scale HTTP server across CPUs |
| Communication | SharedArrayBuffer, MessageChannel | IPC, stdio | IPC (handled by `cluster` module) |
| Overhead | Low | High (fork) | Medium |
| Memory | Lower (shared heap possible) | Separate heap | Separate heap per worker |

**Worker threads example (CPU-bound at Yassir — e.g., route optimization):**
```js
// main.js
const { Worker } = require('worker_threads');

function runOptimization(routeData) {
  return new Promise((resolve, reject) => {
    const worker = new Worker('./optimize-route.js', {
      workerData: routeData
    });
    worker.on('message', resolve);
    worker.on('error', reject);
  });
}

// optimize-route.js
const { workerData, parentPort } = require('worker_threads');
const result = heavyOptimizationAlgorithm(workerData);
parentPort.postMessage(result);
```

**Cluster example (scale Node HTTP server):**
```js
const cluster = require('cluster');
const os = require('os');

if (cluster.isPrimary) {
  os.cpus().forEach(() => cluster.fork());
  cluster.on('exit', (worker) => cluster.fork()); // Auto-restart
} else {
  require('./server'); // Each worker runs independently
}
```

In production (GKE/K8s), horizontal pod scaling handles this — you typically don't use Cluster. Worker threads are still valuable for CPU-bound tasks within a single pod.

---

### Q10 — Streams in Node.js 🔥 PROBABILITY: 68%

Streams process data incrementally — critical for large file handling, log processing, and data pipelines at Yassir scale.

**Four types:**
- **Readable** — source of data (fs.createReadStream, HTTP request body)
- **Writable** — destination (fs.createWriteStream, HTTP response)
- **Duplex** — both readable and writable (TCP socket)
- **Transform** — duplex that transforms data (zlib, crypto)

**Backpressure — the key concept:**
```js
// Without backpressure — can OOM for large files
readableStream.on('data', chunk => {
  writableStream.write(chunk); // If write is slow, buffers pile up!
});

// With pipe — handles backpressure automatically
readableStream.pipe(transform).pipe(writableStream);

// Modern: pipeline (handles cleanup on error)
const { pipeline } = require('stream/promises');
await pipeline(
  fs.createReadStream('large-file.csv'),
  new TransformStream(), // Custom transform
  fs.createWriteStream('output.json')
);
```

**Real Yassir use case:** Processing bulk driver location updates, streaming large report exports to S3/GCS without loading into memory.

---

## 3. NestJS Deep Dive

---

### Q11 — NestJS architecture: Modules, Providers, Controllers, Guards 🔥 PROBABILITY: 95%

NestJS is built around Angular-inspired architecture with Dependency Injection at its core.

**Module system:**
```typescript
@Module({
  imports: [TypeOrmModule.forFeature([Order]), BullModule.registerQueue({ name: 'notifications' })],
  controllers: [OrderController],
  providers: [OrderService, OrderRepository],
  exports: [OrderService], // Make available to importing modules
})
export class OrderModule {}
```

**Provider lifecycle scopes:**
```typescript
@Injectable({ scope: Scope.DEFAULT })    // Singleton (default) — one instance per app
@Injectable({ scope: Scope.REQUEST })    // New instance per HTTP request
@Injectable({ scope: Scope.TRANSIENT })  // New instance per injection point
```

**Guards — authorization at the route level:**
```typescript
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<Role[]>('roles', [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!requiredRoles) return true;
    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.some(role => user.roles?.includes(role));
  }
}

// Usage:
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN)
@Get('admin/orders')
getAdminOrders() {}
```

**Interceptors — AOP for cross-cutting concerns:**
```typescript
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const start = Date.now();
    return next.handle().pipe(
      tap(() => console.log(`Request took ${Date.now() - start}ms`)),
      catchError(err => {
        console.error('Request failed', err);
        return throwError(() => err);
      })
    );
  }
}
```

---

### Q12 — NestJS Microservices with Pub/Sub (Yassir's stack) 🔥 PROBABILITY: 90%

```typescript
// notification.module.ts — subscriber service
@Module({
  imports: [
    ClientsModule.register([{
      name: 'NOTIFICATION_SERVICE',
      transport: Transport.KAFKA, // or Pub/Sub via custom transport
      options: {
        client: { brokers: ['kafka:9092'] },
        consumer: { groupId: 'notification-consumer' }
      }
    }])
  ],
})
export class NotificationModule {}

// notification.controller.ts
@Controller()
export class NotificationController {
  @EventPattern('order.placed')
  async handleOrderPlaced(@Payload() data: OrderPlacedEvent) {
    await this.notificationService.sendConfirmation(data);
  }

  @MessagePattern({ cmd: 'send_notification' })
  async sendNotification(@Payload() dto: SendNotificationDto) {
    return this.notificationService.send(dto);
  }
}
```

**Lazy module loading (reduces cold start on Cloud Run):**
```typescript
@Injectable()
export class AppService {
  constructor(private lazyModuleLoader: LazyModuleLoader) {}

  async getPdfService() {
    const { PdfModule } = await import('./pdf/pdf.module');
    const moduleRef = await this.lazyModuleLoader.load(() => PdfModule);
    return moduleRef.get(PdfService);
  }
}
```

---

### Q13 — NestJS Exception Filters & Custom Error Handling 🔥 PROBABILITY: 80%

```typescript
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  constructor(private readonly logger: Logger) {}

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    const status = exception instanceof HttpException
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;

    const message = exception instanceof HttpException
      ? exception.getResponse()
      : 'Internal server error';

    this.logger.error({
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: request.url,
      error: exception instanceof Error ? exception.message : exception,
    });

    response.status(status).json({
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: request.url,
      message,
    });
  }
}
```

---

## 4. Async Patterns & Event Architecture

---

### Q14 — Event-Driven Architecture patterns 🔥 PROBABILITY: 88%

**Core patterns used at Yassir:**

**1. Event Sourcing**
Store all state changes as immutable events. Reconstruct current state by replaying.
```
OrderCreated → OrderPaid → DriverAssigned → OrderDelivered
```
Benefits: Audit trail, time-travel debugging, replay for new read models.
Used for: Ride-hailing trip lifecycle, financial transactions.

**2. CQRS (Command Query Responsibility Segregation)**
```
Write side: OrderService.placeOrder() → publishes OrderPlaced event
Read side:  OrderQueryService.getOrderStatus() → reads from optimized read model
```
This is critical at Yassir — the write side handles transactional consistency while the read side is optimized for high-throughput queries.

**3. Saga Pattern (Distributed Transactions)**
```
PlaceOrderSaga:
  1. ReserveInventory     → success → continue
  2. ChargPayment         → fail    → compensate: ReleaseInventory
  3. AssignDriver         → fail    → compensate: RefundPayment + ReleaseInventory
```

Choreography (event-driven, no central coordinator):
```
OrderService publishes OrderCreated
  → PaymentService listens, publishes PaymentProcessed
  → DriverService listens, publishes DriverAssigned
  → NotificationService listens to all, sends updates
```

Orchestration (central Saga orchestrator):
```
OrderOrchestrator:
  await paymentService.charge(order)
  await driverService.assign(order)
  await notificationService.notify(order)
  // Handles compensation centrally on failure
```

**4. Outbox Pattern (reliable event publishing):**
```sql
BEGIN TRANSACTION;
  INSERT INTO orders (id, status, ...) VALUES (...);
  INSERT INTO outbox (event_type, payload, status) VALUES ('OrderCreated', {...}, 'PENDING');
COMMIT;
-- Separate outbox processor polls and publishes to Pub/Sub, marks as SENT
```
Guarantees events are published even if the app crashes after DB write.

---

### Q15 — Async error handling best practices 🔥 PROBABILITY: 82%

```typescript
// Anti-pattern: swallowing errors
async function badPattern() {
  try {
    await doSomething();
  } catch (e) {
    console.log(e); // Swallowed — no re-throw, no metrics
  }
}

// Anti-pattern: unhandled promise rejections
fetchData().then(process); // If process throws, unhandled rejection!

// Good pattern: always handle or propagate
async function goodPattern() {
  try {
    await doSomething();
  } catch (err) {
    metrics.increment('errors', { type: err.constructor.name });
    logger.error({ err, context: 'goodPattern' });
    throw new AppError('Processing failed', { cause: err }); // Wrap and rethrow
  }
}

// Global safety net in Node.js
process.on('unhandledRejection', (reason, promise) => {
  logger.fatal({ reason }, 'Unhandled Promise Rejection');
  // Graceful shutdown
  server.close(() => process.exit(1));
});

process.on('uncaughtException', (err) => {
  logger.fatal({ err }, 'Uncaught Exception');
  server.close(() => process.exit(1));
});
```

---

## 5. Distributed Systems & Microservices

---

### Q16 — Service Discovery & Load Balancing 🔥 PROBABILITY: 75%

In a Kubernetes environment (GKE at Yassir):

**Service discovery:**
- Kubernetes DNS: `http://order-service.orders.svc.cluster.local`
- Services register automatically; K8s maintains endpoints
- In non-K8s envs: Consul, Eureka, or cloud service registries

**Load balancing strategies:**
- **Round-robin:** Equal distribution (K8s default kube-proxy)
- **Least connections:** Route to service with fewest active connections
- **IP hash:** Sticky sessions — same client always hits same pod
- **Weighted:** Send 10% to canary, 90% to stable

**Client-side vs server-side load balancing:**
- Server-side (Nginx, Envoy): Simpler for clients, single point of routing
- Client-side (gRPC built-in, Netflix Ribbon): Client holds server list, chooses directly

---

### Q17 — Rate Limiting & Throttling 🔥 PROBABILITY: 78%

```typescript
// NestJS built-in throttler
@Module({
  imports: [
    ThrottlerModule.forRoot([{
      name: 'short',
      ttl: 1000,   // 1 second
      limit: 10,   // 10 requests per second
    }, {
      name: 'medium',
      ttl: 10000,  // 10 seconds
      limit: 50,   // 50 per 10 seconds
    }])
  ]
})

// Redis-backed sliding window for distributed rate limiting
async isRateLimited(userId: string): Promise<boolean> {
  const key = `ratelimit:${userId}`;
  const now = Date.now();
  const window = 60000; // 1 minute

  const pipeline = this.redis.pipeline();
  pipeline.zadd(key, now, `${now}`);          // Add current timestamp
  pipeline.zremrangebyscore(key, 0, now - window); // Remove old entries
  pipeline.zcard(key);                           // Count in window
  pipeline.expire(key, 60);

  const results = await pipeline.exec();
  const count = results[2][1] as number;
  return count > 100; // Limit: 100 req/min
}
```

**Token bucket vs sliding window:**
- Token bucket: Fixed rate of token replenishment, allows bursts up to bucket size
- Sliding window: More accurate, prevents edge-case burst at window boundaries
- At Yassir scale: Redis-backed sliding window per user + per IP

---

### Q18 — Caching strategies 🔥 PROBABILITY: 85%

```
Read-through:  App → Cache miss → DB → populate cache → return
Write-through: App → Write to cache → Write to DB (synchronous)
Write-behind:  App → Write to cache → async flush to DB (faster, risk of loss)
Cache-aside:   App checks cache, on miss: loads from DB, writes to cache
```

**TTL strategies for Yassir:**
- Driver locations: 10s TTL (real-time, short-lived)
- Ride pricing: 5 min TTL (changes with surge, not per-second)
- User profile: 1 hour TTL with invalidation on update
- Restaurant menu: 15 min TTL

**Cache invalidation patterns:**
```typescript
// Event-driven invalidation (most reliable)
@OnEvent('user.updated')
async invalidateUserCache(event: UserUpdatedEvent) {
  await this.cache.del(`user:${event.userId}`);
  await this.cache.del(`user:profile:${event.userId}`);
}

// NestJS cache manager with Redis
@Injectable()
export class UserService {
  constructor(@Inject(CACHE_MANAGER) private cache: Cache) {}

  async getUser(id: string): Promise<User> {
    const cached = await this.cache.get<User>(`user:${id}`);
    if (cached) return cached;

    const user = await this.userRepo.findOne(id);
    await this.cache.set(`user:${id}`, user, 3600); // 1hr TTL
    return user;
  }
}
```

---

## 6. System Design: Wishlist + Email Notification

This is a real Glassdoor question from Yassir. Here is the complete answer.

---

### Q19 — Design the Wishlist + Daily Email Notification System 🔥 PROBABILITY: 92%

**Requirements recap:**
- Users can add books to a wishlist
- When a wishlisted book becomes available for purchase, send email notification
- Email: max once per day, all new books in a single digest email
- Must NOT affect existing app performance
- Existing app: standalone service with PostgreSQL

---

**High-Level Architecture:**

```
┌─────────────────────────────────────────────────────────────────────┐
│                    EXISTING BOOK APP (unchanged)                     │
│                                                                      │
│   PostgreSQL ──── Book Service ──── API Gateway                     │
│                        │                                            │
│                        │ Publishes event (new channel/outbox)        │
│                        ▼                                            │
│               [book_availability_outbox table]                       │
└─────────────────────────────────┬───────────────────────────────────┘
                                  │
                    Outbox Processor (new microservice)
                                  │
                                  ▼
                     ┌─────────────────────┐
                     │   Message Queue      │
                     │  (Google Pub/Sub /   │
                     │    RabbitMQ)         │
                     │                      │
                     │  Topic: book.new     │
                     └──────────┬──────────┘
                                │
              ┌─────────────────┴──────────────────┐
              │                                     │
              ▼                                     ▼
   ┌────────────────────┐              ┌────────────────────────┐
   │  Wishlist Service  │              │  Notification Service  │
   │                    │              │                        │
   │  POST /wishlist    │◄────────────►│  Consumes book.new     │
   │  DELETE /wishlist  │  (internal   │  Looks up wishlists    │
   │  GET /wishlist     │   calls)     │  Batches per user      │
   │                    │              │  Stores in digest queue│
   └─────────┬──────────┘              └──────────┬─────────────┘
             │                                    │
             ▼                                    ▼
    ┌──────────────────┐               ┌──────────────────────┐
    │  Wishlist DB     │               │  Notification DB     │
    │  (PostgreSQL)    │               │  (PostgreSQL/Redis)  │
    │                  │               │                      │
    │  user_wishlists  │               │  pending_digests     │
    │  wishlist_items  │               │  sent_log            │
    └──────────────────┘               └──────────┬───────────┘
                                                  │
                                    ┌─────────────▼──────────────┐
                                    │   Daily Digest Scheduler   │
                                    │   (cron: runs at 9AM)      │
                                    │                            │
                                    │   1. Query pending_digests │
                                    │   2. Group by user_id      │
                                    │   3. Check sent_log        │
                                    │   4. Send email via SES/   │
                                    │      SendGrid              │
                                    │   5. Record in sent_log    │
                                    └────────────────────────────┘
```

---

**Database Schema (new services only):**

```sql
-- Wishlist Service DB
CREATE TABLE user_wishlists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE wishlist_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wishlist_id UUID REFERENCES user_wishlists(id),
  book_id UUID NOT NULL,         -- References book in existing app
  book_title TEXT NOT NULL,      -- Denormalized for resilience
  added_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(wishlist_id, book_id)
);

CREATE INDEX idx_wishlist_items_book_id ON wishlist_items(book_id);

-- Notification Service DB
CREATE TABLE pending_digest_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  book_id UUID NOT NULL,
  book_title TEXT NOT NULL,
  book_url TEXT NOT NULL,
  queued_at TIMESTAMPTZ DEFAULT NOW(),
  status TEXT DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'SENT'))
);

CREATE TABLE digest_sent_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  book_count INT NOT NULL
);

CREATE INDEX idx_pending_digest_user ON pending_digest_items(user_id, status);
CREATE INDEX idx_sent_log_user_date ON digest_sent_log(user_id, sent_at);

-- Outbox table added to EXISTING app's DB (minimal change)
CREATE TABLE book_availability_outbox (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  book_id UUID NOT NULL,
  book_title TEXT NOT NULL,
  book_url TEXT NOT NULL,
  event_type TEXT DEFAULT 'book.available',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  published BOOLEAN DEFAULT FALSE
);
```

---

**Key Implementation Details:**

```typescript
// 1. Outbox processor — polls every 5s, publishes to Pub/Sub
@Cron('*/5 * * * * *')
async processOutbox() {
  const events = await this.db.query(
    `SELECT * FROM book_availability_outbox
     WHERE published = FALSE
     ORDER BY created_at
     LIMIT 100`
  );

  for (const event of events) {
    await this.pubsub.topic('book.available').publish(
      Buffer.from(JSON.stringify(event))
    );
    await this.db.query(
      `UPDATE book_availability_outbox SET published = TRUE WHERE id = $1`,
      [event.id]
    );
  }
}

// 2. Notification service — consumes events
async handleBookAvailable(event: BookAvailableEvent) {
  // Find all users who have this book in their wishlist
  const users = await this.wishlistService.getUsersWithBook(event.bookId);

  // Queue digest items for each user
  await this.db.query(
    `INSERT INTO pending_digest_items (user_id, book_id, book_title, book_url)
     SELECT unnest($1::uuid[]), $2, $3, $4
     ON CONFLICT DO NOTHING`,
    [users.map(u => u.id), event.bookId, event.bookTitle, event.bookUrl]
  );
}

// 3. Daily digest sender — cron at 9AM
@Cron('0 9 * * *')
async sendDailyDigests() {
  // Get all users with pending items not yet sent today
  const usersWithPending = await this.db.query(`
    SELECT DISTINCT pdi.user_id
    FROM pending_digest_items pdi
    WHERE pdi.status = 'PENDING'
      AND NOT EXISTS (
        SELECT 1 FROM digest_sent_log dsl
        WHERE dsl.user_id = pdi.user_id
          AND dsl.sent_at > NOW() - INTERVAL '24 hours'
      )
  `);

  for (const { user_id } of usersWithPending) {
    await this.sendDigestForUser(user_id);
  }
}

async sendDigestForUser(userId: string) {
  const items = await this.db.query(
    `SELECT * FROM pending_digest_items
     WHERE user_id = $1 AND status = 'PENDING'`,
    [userId]
  );

  const user = await this.userService.getUser(userId);

  await this.emailService.send({
    to: user.email,
    subject: `${items.length} books from your wishlist are now available!`,
    template: 'wishlist-digest',
    data: { books: items }
  });

  // Mark as sent + log
  await this.db.query(
    `UPDATE pending_digest_items SET status = 'SENT'
     WHERE user_id = $1 AND status = 'PENDING'`,
    [userId]
  );
  await this.db.query(
    `INSERT INTO digest_sent_log (user_id, book_count) VALUES ($1, $2)`,
    [userId, items.length]
  );
}
```

**Why this design doesn't affect existing app performance:**
1. The outbox table is in the existing DB, but the polling is external — no transactions, minimal I/O.
2. All new functionality runs in separate services with their own resources.
3. The existing book publishing flow is unmodified — it only writes to the outbox table.
4. Pub/Sub decouples the event pipeline — backpressure from notification service never reaches the book app.

---

## 7. System Design: Shopping Cart & Order Placement

---

### Q20 — Design Shopping Cart & Order Placement 🔥 PROBABILITY: 88%

**Requirements (assumed):**
- Add/remove items, update quantities
- Support concurrent users (100k+ at Yassir scale)
- Handle inventory, payment, and driver assignment
- Idempotent order placement (retry-safe)

**Cart service design:**

```typescript
// Cart stored in Redis (fast, ephemeral, per-user)
interface CartItem {
  productId: string;
  name: string;
  price: number;        // Snapshot at time of adding
  quantity: number;
}

class CartService {
  async addItem(userId: string, item: CartItem) {
    const key = `cart:${userId}`;
    const existing = await this.redis.hget(key, item.productId);
    const qty = existing ? JSON.parse(existing).quantity + item.quantity : item.quantity;

    await this.redis.hset(key, item.productId, JSON.stringify({ ...item, quantity: qty }));
    await this.redis.expire(key, 86400 * 7); // 7 day TTL
  }

  async checkout(userId: string, idempotencyKey: string): Promise<Order> {
    // Idempotency: check if we've already processed this key
    const existing = await this.redis.get(`idempotency:${idempotencyKey}`);
    if (existing) return JSON.parse(existing);

    const items = await this.getCart(userId);
    // Lock + process
    const order = await this.orderSaga.execute({ userId, items, idempotencyKey });

    await this.redis.setex(`idempotency:${idempotencyKey}`, 86400, JSON.stringify(order));
    return order;
  }
}
```

**Order placement flow (Saga):**

```
1. ValidateCart          → Check all items still available & prices valid
2. ReserveInventory      → Decrement stock (optimistic locking)
3. CreateOrder           → Write order in PENDING state
4. ProcessPayment        → Charge card via Stripe/Wallet
5. ConfirmOrder          → Status → CONFIRMED
6. AssignDriver          → Publish to matching service (Yassir's strength)
7. NotifyUser            → Push notification + email receipt

Compensations (reverse order):
- If payment fails  → ReleaseInventory + CancelOrder
- If driver assignment fails → RefundPayment + ReleaseInventory + CancelOrder
```

---

## 8. Database & Persistence

---

### Q21 — PostgreSQL performance for high-traffic apps 🔥 PROBABILITY: 80%

**Indexing strategy:**
```sql
-- Partial index — only index what you query
CREATE INDEX idx_active_orders ON orders(user_id, created_at)
WHERE status IN ('PENDING', 'CONFIRMED');

-- Composite index — order matters (most selective first)
CREATE INDEX idx_orders_user_status ON orders(user_id, status, created_at DESC);

-- GIN index for full-text search (book search use case)
CREATE INDEX idx_books_search ON books USING GIN(to_tsvector('english', title || ' ' || description));

-- Query using the GIN index
SELECT * FROM books
WHERE to_tsvector('english', title || ' ' || description) @@ plainto_tsquery('english', 'nodejs architecture');
```

**Connection pooling (critical at scale):**
```typescript
// PgBouncer in front of PostgreSQL
// Or TypeORM / Prisma connection pool config
TypeOrmModule.forRoot({
  type: 'postgres',
  host: process.env.DB_HOST,
  poolSize: 20,          // Max connections per pod
  connectTimeoutMS: 3000,
  // With PgBouncer: pool_mode = transaction (most efficient for microservices)
})
```

**EXPLAIN ANALYZE — know how to read query plans:**
```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT o.*, u.email
FROM orders o
JOIN users u ON u.id = o.user_id
WHERE o.status = 'PENDING'
  AND o.created_at > NOW() - INTERVAL '1 hour';
-- Look for: Seq Scan (bad on large tables), Index Scan (good), Nested Loop (watch cardinality)
```

---

### Q22 — Database per Service & data consistency 🔥 PROBABILITY: 72%

Each microservice owns its data store. Cross-service queries use:

1. **API composition** — service B calls service A via HTTP/gRPC to get data
2. **Event-driven denormalization** — service B subscribes to events from A and maintains its own read copy
3. **CQRS read models** — a dedicated query service joins data from multiple sources

```typescript
// Event-driven denormalization example:
// OrderService subscribes to UserUpdated events
@OnEvent('user.updated')
async handleUserUpdated(event: UserUpdatedEvent) {
  // Update denormalized user data in orders DB
  await this.orderRepo.updateUserSnapshot(event.userId, {
    email: event.email,
    name: event.name,
  });
}
```

---

## 9. API Design & Reverse Proxy

---

### Q23 — RESTful API design best practices 🔥 PROBABILITY: 85%

```
Resource naming:
GET    /orders              → List orders
POST   /orders              → Create order
GET    /orders/:id          → Get specific order
PATCH  /orders/:id          → Partial update
DELETE /orders/:id          → Cancel order
POST   /orders/:id/confirm  → Action (not pure REST but pragmatic)

Versioning strategies:
URL path:    /api/v1/orders  (most common, easy to route)
Header:      Accept: application/vnd.yassir.v2+json
Query:       /orders?version=2

Pagination:
Cursor-based (preferred for real-time data):
  GET /orders?cursor=eyJpZCI6MTAwfQ&limit=20
Offset-based (simple but inconsistent with inserts):
  GET /orders?page=2&limit=20

Response envelope:
{
  "data": [...],
  "meta": { "total": 100, "cursor": "abc123" },
  "links": { "next": "/orders?cursor=abc123" }
}

Error format (RFC 7807 Problem Details):
{
  "type": "https://api.yassir.com/errors/insufficient-balance",
  "title": "Insufficient Balance",
  "status": 402,
  "detail": "Wallet balance 50 DZD is less than order total 150 DZD",
  "instance": "/orders/abc123"
}
```

---

### Q24 — GraphQL vs REST for a super-app 🔥 PROBABILITY: 60%

**REST is better when:**
- Simple, well-defined resources
- Caching is important (HTTP cache works natively)
- Public APIs consumed by external partners
- Mobile clients with predictable data needs

**GraphQL is better when:**
- Complex, deeply nested data (e.g., ride details + driver + car + rating)
- Multiple clients (iOS, Android, web) need different shapes of the same data
- Rapid product iteration — frontend can change queries without backend changes

**At Yassir:** Most likely REST/gRPC between microservices (performance, strong types with Protobuf), GraphQL for the consumer-facing BFF (Backend For Frontend) layer if they have divergent mobile/web needs.

---

## 10. Testing, CI/CD & Engineering Standards

---

### Q25 — Testing strategy for a Staff Engineer 🔥 PROBABILITY: 85%

**Testing pyramid:**
```
         /\
        /  \   E2E Tests (few, slow, expensive)
       /    \  Supertest / Playwright
      /──────\
     /        \ Integration Tests (moderate)
    /          \ DB + real HTTP, in-memory or test containers
   /────────────\
  /              \ Unit Tests (many, fast, cheap)
 /                \ Jest, pure functions, mocked deps
/──────────────────\
```

**NestJS unit test with mocks:**
```typescript
describe('OrderService', () => {
  let service: OrderService;
  let mockRepo: jest.Mocked<OrderRepository>;
  let mockQueue: jest.Mocked<Queue>;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        OrderService,
        { provide: OrderRepository, useValue: { save: jest.fn(), findOne: jest.fn() } },
        { provide: getQueueToken('notifications'), useValue: { add: jest.fn() } },
      ],
    }).compile();

    service = module.get(OrderService);
    mockRepo = module.get(OrderRepository);
  });

  it('should create order and queue notification', async () => {
    mockRepo.save.mockResolvedValue({ id: 'order-1', status: 'PENDING' });

    const result = await service.createOrder({ userId: 'user-1', items: [] });

    expect(result.id).toBe('order-1');
    expect(mockQueue.add).toHaveBeenCalledWith('order.created', expect.objectContaining({ orderId: 'order-1' }));
  });
});
```

**Contract testing (for microservices):**
```typescript
// Pact consumer test — defines what the consumer expects from the provider
const pact = new Pact({ consumer: 'OrderService', provider: 'UserService' });
pact.addInteraction({
  state: 'user 123 exists',
  uponReceiving: 'a request for user 123',
  withRequest: { method: 'GET', path: '/users/123' },
  willRespondWith: {
    status: 200,
    body: { id: '123', email: 'hany@example.com' }
  }
});
```

---

### Q26 — Monorepo management (Nx, Turborepo) 🔥 PROBABILITY: 70%

```
yassir-platform/
├── apps/
│   ├── order-service/        NestJS microservice
│   ├── notification-service/ NestJS microservice
│   ├── api-gateway/          NestJS gateway
│   └── consumer-web/         React frontend
├── libs/
│   ├── shared-dtos/          Shared TypeScript interfaces/DTOs
│   ├── shared-auth/          JWT guards, decorators
│   ├── shared-logging/       Winston config, request logger
│   └── shared-testing/       Test utilities, fixtures
├── nx.json
└── package.json
```

**Nx benefits:**
- Affected commands: `nx affected:test` only tests changed projects and their dependents
- Build caching: skip unchanged builds (remote cache in CI)
- Dependency graph visualization
- Code generation: `nx generate @nestjs/schematics:module orders`

---

## 11. Staff-Level Leadership Questions

---

### Q27 — How do you drive a technical roadmap? 🔥 PROBABILITY: 85%

**Framework:**
1. **Audit current state** — identify tech debt, scaling bottlenecks, security gaps, DX pain points
2. **Align with product roadmap** — technical work must enable business outcomes
3. **Prioritize with a matrix:**
   - High business impact + low effort → Do now
   - High business impact + high effort → Plan and resource
   - Low business impact + low effort → Opportunistic
   - Low business impact + high effort → Deprioritize or cut
4. **Write RFCs** (Request for Comments) for significant decisions — build alignment before building
5. **Set measurable goals** — reduce p99 latency from 500ms to 150ms by Q3; reduce incident count by 40%
6. **Review quarterly** — technical roadmaps must be living documents

**Example answer framed for Yassir:**
"At Kinship/Andela I identified that our monolith was causing 200ms+ latency on every request due to shared DB connections. I wrote an RFC proposing service extraction with the Strangler Fig pattern, got buy-in from 3 engineering leads, and executed it over two quarters. We reduced p99 latency by 60% and halved deployment risk."

---

### Q28 — How do you mentor junior engineers? 🔥 PROBABILITY: 80%

**Concrete approaches:**
- **Structured 1:1s** — weekly, focused on blockers, growth, not status updates
- **Pair programming sessions** — on complex problems, not to watch them code
- **Code review as teaching** — explain *why*, not just *what's wrong*; link to RFC/doc
- **Stretch assignments** — assign tasks slightly above their level with support
- **ADRs (Architecture Decision Records)** — involve them in writing decisions; ownership drives growth
- **Inner loop optimization** — reduce friction in their dev environment (DX improvements)

**For Staff level at Yassir:** You're mentoring across squads. Document your decisions publicly (Confluence/Notion), hold optional architecture office hours, and create reusable templates (NestJS service template, PR checklist, incident runbook).

---

### Q29 — How do you handle technical debt? 🔥 PROBABILITY: 78%

**Framework:**
1. **Make it visible** — maintain a tech debt register with business impact + estimated effort
2. **Categorize it:**
   - **Critical** (security vulnerability, causes incidents) → fix immediately
   - **High** (slows feature development, causes bugs) → allocate 20% of sprint capacity
   - **Low** (code smell, missing tests) → fix during related feature work ("Boy Scout Rule")
3. **Negotiate with product** — frame in business terms: "This debt costs us 2 extra days per feature in this module"
4. **Debt sprints** — occasional focused sprints on strategic debt paydown
5. **Avoid taking new debt** — PR checklist, architecture review for new services

---

## 12. Quick-Fire Reference Cheatsheet

---

### Node.js Core Concepts — Fast Answers

| Topic | Key Answer |
|---|---|
| What is libuv? | C library that provides async I/O, thread pool, event loop to Node.js |
| What is the V8 engine? | Google's JS engine that compiles JS to native machine code |
| What is `process.nextTick`? | Schedules callback before next event loop iteration, after current operation |
| Difference `setImmediate` vs `setTimeout(fn, 0)` | `setImmediate` runs in check phase; `setTimeout` runs in timers phase; order depends on context |
| What is a closure? | Function that retains access to its outer lexical scope even after the outer function returns |
| What is `Symbol`? | Unique, immutable primitive. Used for private-ish object keys, `Symbol.iterator`, etc. |
| `null` vs `undefined`? | `undefined` = declared but not assigned. `null` = intentional absence of value |
| What is weak reference? | `WeakMap`/`WeakSet` hold references that don't prevent GC of the key object |
| SIGTERM vs SIGKILL? | SIGTERM = graceful shutdown signal (handle and clean up). SIGKILL = immediate kill (cannot handle) |
| What is backpressure? | When write destination is slower than read source — must pause the readable stream |

### NestJS Fast Answers

| Topic | Key Answer |
|---|---|
| Difference Interceptor vs Middleware? | Middleware runs before routing; Interceptors have access to ExecutionContext and wrap both request and response |
| Difference Guard vs Middleware? | Guards determine if request should proceed (auth/authz); middleware transforms request |
| What is a Pipe? | Transforms and validates incoming data before it reaches the handler |
| How does DI work in NestJS? | Providers registered in module, injected via constructor using TypeScript reflection metadata |
| What is `forwardRef`? | Resolves circular dependency between modules by lazily referencing the provider |
| What is `ConfigModule`? | NestJS module for loading `.env` and config factories with validation (class-validator) |
| What is DTOs purpose? | Data Transfer Object — defines and validates shape of incoming data (combined with class-validator) |

### System Design Fast Answers

| Topic | Key Answer |
|---|---|
| CAP Theorem | Consistency, Availability, Partition Tolerance — can only guarantee 2 of 3 when partitions occur |
| BASE vs ACID | ACID = strong consistency (SQL). BASE = Basically Available, Soft state, Eventually consistent (NoSQL) |
| What is idempotency? | Same operation called multiple times produces same result — critical for retries in distributed systems |
| What is a circuit breaker? | Stops calling failing service after N failures, returns fallback; allows service to recover |
| What is a bulkhead? | Isolates resource pools (threads/connections) so one failing dependency doesn't exhaust all resources |
| What is sharding? | Horizontal partitioning — splitting data across multiple DB nodes by a shard key |
| Leader election? | Distributed algorithm (Raft, ZooKeeper) to designate one node as primary for writes |
| What is a hot partition? | Single shard/partition receiving disproportionate traffic — solved by random suffix salting, composite keys |

---

*Built for Yassir Staff Backend Engineer Interview — Node.js Track*
*Stack context: NestJS · Node.js · Google Cloud (GKE, Pub/Sub) · PostgreSQL · Redis · Kafka*
