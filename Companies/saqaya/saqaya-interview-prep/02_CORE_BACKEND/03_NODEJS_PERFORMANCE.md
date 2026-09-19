# Node.js Performance Optimization for Technical Leads

## 1. Event Loop Monitoring and Optimization

Node.js is single-threaded; performance relies on high I/O concurrency and not blocking the CPU.
**Event Loop Lag:** The delay between when a timeout is scheduled and when it actually executes. High lag means the CPU is blocked by synchronous code (JSON parsing large payloads, RegEx, tight loops).

### APM Integration & Monitoring
Production environments must monitor Event Loop Lag using APM tools (Datadog, New Relic) or `perf_hooks`.

```javascript
const { monitorEventLoopDelay } = require('perf_hooks');
const h = monitorEventLoopDelay({ resolution: 10 });
h.enable();

// Log to metrics system periodically
setInterval(() => {
  console.log(`P99 Event Loop Lag: ${h.percentile(99)} ns`);
  h.reset();
}, 10000);
```

## 2. Memory Leak Detection and Prevention

### What Causes Leaks in Node.js?
1. **Global Variables:** Unintended accumulation in global scope.
2. **Closures:** Keeping references to large objects in enclosed scopes (e.g., event listeners not being removed).
3. **Caches:** In-memory caching without a TTL or maximum size (always use LRU caches).
4. **Promises/Callbacks:** Unresolved promises holding onto context.

### Detection (Heap Snapshots)
- Take snapshots in production using `v8.writeHeapSnapshot()`.
- Use Chrome DevTools (Memory tab) to compare snapshots and find the "Retained Size" of objects that shouldn't be there.
- Use `node --inspect` locally or Clinic.js (`clinic heapprofiler`).

## 3. Database Query Optimization from Node.js

- **Connection Pooling:** Never instantiate a new DB connection per request. Use a pool (e.g., `pg.Pool`). Configure `max` pool size based on `(CPU cores * 2) + 1` formula or DB limits.
- **Pipelining/Batching:** Group inserts into single queries.
- **Cursor/Streams:** Avoid loading 1,000,000 rows into an array. Use DB cursors piped to Node.js streams to keep memory flat.

```javascript
// Postgres stream to HTTP response
const QueryStream = require('pg-query-stream');
const stream = new QueryStream('SELECT * FROM large_table');
pool.connect((err, client, done) => {
  const dbStream = client.query(stream);
  dbStream.on('end', done);
  dbStream.pipe(JSONStream.stringify()).pipe(res);
});
```

## 4. Interview Questions

### Question 1: Your Node.js microservice is experiencing high latency and the CPU is at 100%. How do you debug and resolve this?
### What the interviewer is testing
Performance troubleshooting, profiling, and deep understanding of V8/Node.js internals.
### Short answer
Generate a CPU profile using the V8 inspector or APM, identify the synchronous blocking code using flame graphs, and offload it to worker threads or optimize the algorithm.
### Detailed answer
100% CPU in Node implies the event loop is blocked by synchronous JS execution. I would connect via the inspector protocol (if safe in prod) or trigger a CPU profile via `v8-profiler-node`. I would analyze the generated `.cpuprofile` in Chrome DevTools to view the Flame Graph. Wide blocks at the top indicate time-consuming functions. Common culprits are massive `JSON.parse`, synchronous crypto hashing (e.g., bcrypt without async), or catastrophic backtracking in RegEx.
### How it works internally
V8 samples the call stack at a regular interval (e.g., every 1ms). Flame graphs plot the stack depth on the Y-axis and CPU time on the X-axis.
### Trade-offs
Taking CPU profiles in production adds a slight overhead. It is best done on a dedicated canary instance or conditionally triggered.
### Common mistakes
Trying to solve CPU bounding by increasing the Node cluster size—this just delays the inevitable. Restarting the pod constantly. Using `setInterval` to "unblock" which doesn't solve the core issue.
### Strong Technical Lead answer
"First, I look at our APM (like Datadog) to isolate the endpoint causing the spike. Next, I pull a CPU profile using Clinic.js or Chrome DevTools. If the flame graph shows an intensive synchronous operation—say, processing large Excel files—I have three architectural choices: 1) Optimize the algorithm, perhaps using streams instead of loading everything into memory. 2) Offload the task to Node's `worker_threads` so the main event loop remains free to handle incoming HTTP requests. 3) If it's a core domain requirement (like heavy cryptography or machine learning), I'd write a dedicated microservice in a more CPU-suited language like Go or Rust and communicate via gRPC or message queues. As a Lead, my priority is keeping the event loop unblocked so liveness probes don't fail, causing cascading Kubernetes pod restarts."

---

### Question 2: How do you implement effective caching in a Node.js backend to maximize throughput?
### What the interviewer is testing
System design, memory management, and scaling strategies.
### Short answer
Multi-tier caching using in-memory LRU cache for hot paths and Redis for distributed caching, while avoiding memory leaks.
### Detailed answer
Caching in Node must be careful of the V8 heap limits. I use a two-tiered approach:
1. **L1 (In-Memory):** `lru-cache` package. Extremely fast, zero network overhead. Stores highly frequent, less mutable data (e.g., configuration, JWT public keys). Crucial: MUST have a max size limit to prevent memory exhaustion, and a TTL to prevent stale data.
2. **L2 (Redis):** Distributed cache for data shared across multiple instances (e.g., user sessions, query results). Prevents cache stampedes using stale-while-revalidate patterns.
### Real-world example
Using `Redis` with pipeline commands to batch fetches, and preventing the "Thundering Herd" problem by using a locking mechanism or `promise-memoize` during cache misses.
### Trade-offs
L1 cache is duplicated across every pod (memory waste) and harder to invalidate globally. Redis requires network hops.
### Strong Technical Lead answer
"As a Tech Lead, I approach caching defensively. In Node.js, unbound in-memory caching is the #1 cause of memory leaks. We mandate `lru-cache` with strict limits for L1. For L2, we use Redis. I also implement the 'Stale-While-Revalidate' pattern: when a cache expires, we return the stale data immediately to the user while kicking off a background asynchronous promise to update the cache. This guarantees sub-millisecond response times even during cache misses, entirely avoiding cache stampedes on our primary database."
