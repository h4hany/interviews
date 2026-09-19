# Technical Lead Interview Study Guide: Node.js (SAQAYA / Palladium Context)

## Context & Role Overview
- **Role:** Technical Lead / Senior Software Engineer
- **Company Context:** SAQAYA (Client: Palladium)
- **Domain:** eLearning platform, LLM/AI workloads
- **Stack:** Node.js, TypeScript, Python, FastAPI, PostgreSQL, AWS, CI/CD
- **Goal:** Production readiness, scaling, architecture

---

## 1. Top 20 Mistakes (Node.js Anti-Patterns in Production)
1. **Blocking the Event Loop:** Running CPU-intensive tasks (e.g., large JSON.parse, crypto, regex) on the main thread instead of using `worker_threads`.
2. **Ignoring Backpressure in Streams:** Piping massive S3 video files into HTTP responses without handling stream buffering, causing OOM crashes.
3. **Unhandled Promise Rejections:** Failing to use top-level error handlers (`unhandledRejection`), causing silent failures or process crashes.
4. **Memory Leaks via Closures:** Keeping references to large objects (e.g., LLM context arrays) in global scopes or event listener closures.
5. **No Graceful Shutdown:** Abruptly killing the process (`SIGKILL`) during deployments instead of catching `SIGTERM`, draining connections, and safely exiting.
6. **Abusing `process.nextTick`:** Creating recursive `process.nextTick` calls which starve the event loop's I/O phases.
7. **Default Connection Pool Limits:** Leaving PostgreSQL or HTTP agent connection pools at their defaults, causing connection starvation under load.
8. **Using `npm install` over `npm ci`:** Relying on mutable dependency trees in CI/CD instead of strictly locking versions.
9. **Sync File Operations in APIs:** Using `fs.readFileSync` inside an Express route, halting all concurrent requests.
10. **Lack of Circuit Breakers:** Allowing cascading failures when an external LLM API (like OpenAI) goes down or throttles.
11. **Assuming PM2 is a Silver Bullet:** Using PM2 clustering without understanding that state (like WebSocket connections or rate limit counters) isn't shared automatically.
12. **Console.log in Production:** Using synchronous `console.log` heavily under load instead of asynchronous logging libraries (Pino/Winston).
13. **Vulnerable Dependencies:** Ignoring supply chain security and failing to audit `node_modules` in the CI pipeline.
14. **Over-promisifying:** Wrapping already asynchronous standard APIs unnecessarily, adding microtask overhead.
15. **Unbounded Queues:** Pushing background jobs into in-memory arrays instead of durable message brokers (SQS/Redis/RabbitMQ).
16. **Missing Health Checks:** Deploying containers without deep health checks (DB connection verification), causing orchestrators to route traffic to dead pods.
17. **Fat Docker Images:** Shipping source code, devDependencies, and OS bloat instead of multi-stage distless builds.
18. **Poor Secret Management:** Passing secrets in CLI args or committing `.env` files instead of using AWS Secrets Manager/KMS.
19. **Inefficient Garbage Collection:** Not tuning V8 flags (e.g., `--max-old-space-size`) for specific memory profiles (like large document parsing for LLMs).
20. **No Request Idempotency:** Failing to implement idempotency keys for retried frontend requests, leading to duplicate database records.

---

## 2. Node.js Cheat Sheet

### Event Loop Phases (libuv)
1. **Timers:** executes `setTimeout` and `setInterval` callbacks.
2. **Pending Callbacks:** executes deferred I/O callbacks.
3. **Idle, Prepare:** internal use only.
4. **Poll:** retrieves new I/O events (accepts incoming connections, data read); node will block here if appropriate.
5. **Check:** executes `setImmediate` callbacks.
6. **Close Callbacks:** e.g., `socket.on('close', ...)`.
*(Microtasks, including Promises and `process.nextTick`, are drained completely between EVERY phase).*

### Threading & Scaling
- **`cluster`:** Forks the process, sharing the same server port. Good for scaling HTTP across CPU cores.
- **`worker_threads`:** Shares memory (via `SharedArrayBuffer`), runs CPU-heavy tasks without blocking the main event loop.
- **`child_process`:** Spawns a new OS process (e.g., calling a Python script for AI tasks).

### Garbage Collection (V8)
- **Scavenger (Minor GC):** Cleans up short-lived objects (Young Generation). Fast, stops the thread briefly.
- **Mark-Sweep/Compact (Major GC):** Cleans up long-lived objects (Old Generation). Slower, can cause noticeable pauses.

---

## 3. Detailed Interview Questions

*(Due to length constraints, 5 ultra-detailed examples are provided covering the core requirements with exact structure, followed by the specific scenarios requested).*

### Q1: The Event Loop & Microtask Starvation
**Interview Question:** Walk me through the Node.js event loop phases. What happens if a microtask recursively queues another microtask, and how does this impact a high-traffic Express server handling file uploads?
**Difficulty level:** Advanced
**Research Classification:** [CONFIRMED]
**Why They Ask This:** To see if you understand the internal scheduler (libuv vs V8) and how careless async code can completely freeze a server, which is critical for a Tech Lead designing high-throughput systems.
**Short Interview Answer (30-90 seconds spoken):** The event loop has six phases, primarily Timers, Poll (for I/O), and Check (for setImmediate). Crucially, between every phase, V8 drains the microtask queue (Promises) and the nextTick queue. If a microtask recursively queues another microtask, the microtask queue never empties. The event loop gets stuck between phases, meaning the Poll phase never runs. I/O is starved, and your Express server will stop accepting new connections or processing file uploads, appearing completely dead to users.
**Deep Explanation:** Node.js delegates I/O to libuv, which maintains the phases. V8 maintains the microtask queue. `process.nextTick` is actually part of Node's core, not V8, and runs immediately before Promises. The scheduler demands that the current queue must be completely empty before advancing to the next libuv phase. Recursive microtasks thus act like a synchronous infinite loop, freezing the server.
**Under the Hood:** V8's `MicrotaskQueue::RunMicrotasks` continues fetching the head of the queue. If new items are pushed during execution, the loop condition `while(!queue.empty())` never resolves to false. The libuv event loop (`uv_run`) cannot proceed to `uv__io_poll`.
**Real-World Example (production-grade):** In our eLearning platform, we process large LLM prompt evaluations asynchronously. A junior developer used a recursive Promise chain to poll the LLM generation status without yielding. The microtask queue froze, and students couldn't submit new assignments because the API gateway's HTTP requests (which depend on the Poll phase) were completely ignored.
**Production Scenario:** A sudden drop in API throughput to zero, but CPU usage is pegged at 100%. Datadog shows event loop lag spiking to infinity.
**Code Example:**
```typescript
// BAD: Starves the event loop
function processLLMDataRecursively() {
  Promise.resolve().then(() => {
    // Process a chunk of text
    processLLMDataRecursively(); // Queues another microtask immediately
  });
}

// GOOD: Yields to the event loop using setImmediate (Check phase)
function processLLMDataSafely() {
  setImmediate(() => {
    // Process chunk
    processLLMDataSafely(); // Yields, allowing I/O (Poll phase) to run
  });
}
```
**Trade-offs:** Yielding with `setImmediate` prevents starvation but increases the total time to finish the background task due to context switching. 
**What a Weak Candidate Might Say:** "The event loop runs promises, then timeouts. A recursive promise will just take a long time but other requests will run in parallel."
**What a Senior Engineer Would Say:** Accurately describes the phases and the microtask queue. Identifies that recursive promises block I/O.
**What a Technical Lead Would Say:** Explains libuv vs V8 interaction, identifies the exact metric to monitor (event loop lag/delay), and prescribes an architectural fix (moving this to a separate worker thread or using an SQS queue) rather than just fixing the syntax.
**Follow-up Questions:**
1. How does `process.nextTick()` differ from `setImmediate()`?
2. If you needed to process a massive JSON payload synchronously, how would you prevent starvation?
3. How do you monitor event loop lag in production?
**Follow-up Answers:**
1. `nextTick` runs immediately before the next phase (or before promises resolve). `setImmediate` runs specifically in the Check phase.
2. Use `worker_threads` to offload the parsing, or use a streaming JSON parser like `JSONStream`.
3. Use APM tools (Datadog/New Relic) or `perf_hooks.monitorEventLoopDelay` natively in Node.js.
**Interviewer Trap:** Asking if `setTimeout(fn, 0)` is faster than `setImmediate(fn)`. (Answer: It depends on context; inside an I/O callback, `setImmediate` always runs first).
**Key Takeaways:** 
- Microtasks block the event loop if recursive.
- Event loop lag is a critical health metric.
- CPU-heavy tasks belong in worker threads.

### Q2: Streams & Backpressure with Large Files
**Interview Question:** We are building an eLearning feature where students download 5GB course video files stored in S3. If we stream this through our Node.js server, how do you handle backpressure, and what happens if you don't?
**Difficulty level:** Advanced
**Research Classification:** [COMMON]
**Why They Ask This:** Handling large data efficiently is crucial for Node.js. If you don't understand backpressure, you will cause memory leaks and Out-of-Memory (OOM) crashes in production.
**Short Interview Answer (30-90 seconds spoken):** Backpressure occurs when the readable stream (S3) reads data faster than the writable stream (the HTTP response to the client's slow connection) can consume it. If unhandled, Node buffers the excess data in RAM. With a 5GB file, this quickly exceeds the V8 heap limit, crashing the server. I would use the `.pipe()` method or the modern `pipeline()` utility from the `stream` module, which automatically pauses the readable stream when the writable stream's internal buffer is full, and resumes when it drains.
**Deep Explanation:** Streams implement a `highWaterMark` (usually 16kb or 64kb). When a writable stream's buffer exceeds this, `write()` returns `false`. This is the signal for backpressure. Node's `.pipe()` listens for this and calls `.pause()` on the source, then listens for the `'drain'` event on the destination to call `.resume()`.
**Under the Hood:** The memory allocated for stream buffers sits outside the V8 JavaScript heap (in C++ allocated Buffers). However, if unbounded, it will exhaust system RAM, triggering the Linux OOM Killer to terminate the Node process (`SIGKILL`).
**Real-World Example (production-grade):** Proxying video files from an internal S3 bucket to a client. We use `stream.pipeline` to route the `S3.getObject().createReadStream()` directly into the Express `res` object, ensuring that if a student is on a slow 3G connection, we don't pull the entire video into our server's RAM.
**Production Scenario:** Containers are randomly restarting with Exit Code 137 (OOM Killed) during peak hours. Memory graphs show a sharp spike before the crash.
**Code Example:**
```typescript
import { pipeline } from 'stream/promises';
import { S3Client, GetObjectCommand } from '@aws-sdk/client-s3';

const s3 = new S3Client({ region: 'us-east-1' });

app.get('/video/:id', async (req, res) => {
  const command = new GetObjectCommand({ Bucket: 'course-videos', Key: req.params.id });
  const { Body } = await s3.send(command);
  
  try {
    // pipeline handles backpressure and error propagation automatically
    await pipeline(Body as NodeJS.ReadableStream, res);
  } catch (err) {
    console.error('Pipeline failed', err);
    res.status(500).end();
  }
});
```
**Trade-offs:** Streaming through the Node server consumes network I/O and connections. An alternative architecture is generating an AWS S3 Pre-signed URL and bypassing the Node server entirely, which is more scalable.
**What a Weak Candidate Might Say:** "I would use `fs.readFile` and send it in the response. If it's big, I'll increase the memory limit of Node."
**What a Senior Engineer Would Say:** Explains backpressure, `highWaterMark`, and uses `pipeline()` to prevent memory exhaustion.
**What a Technical Lead Would Say:** Points out that passing large files through Node is an anti-pattern if it can be avoided. Proposes S3 Pre-signed URLs or CloudFront signed cookies to offload the streaming to the CDN, saving server costs.
**Follow-up Questions:**
1. Why use `pipeline` instead of `.pipe()`?
2. How would you handle a scenario where you need to transform the video stream on the fly?
3. What is the V8 heap limit, and do Buffers count against it?
**Follow-up Answers:**
1. `.pipe()` does not forward errors properly. If the read stream fails, the write stream stays open (memory leak). `pipeline` tears down all streams if one fails.
2. Insert a Transform stream (e.g., using `ffmpeg`) into the pipeline.
3. V8 heap is typically ~1.4GB by default on 64-bit. `Buffer` objects are allocated in C++ land outside the V8 heap, but they still consume system RAM.
**Interviewer Trap:** Asking how to increase the V8 heap size to fix a stream memory leak. (Answer: Increasing heap size just delays the inevitable crash; you must fix the backpressure).
**Key Takeaways:** 
- Unhandled backpressure = OOM crashes.
- `pipeline()` > `.pipe()`.
- Pre-signed URLs are architecturally superior for raw file delivery.

### Q3: Worker Threads vs Cluster Module
**Interview Question:** Our Node.js platform needs to parse 100MB PDF documents and run a heavy NLP tokenization algorithm locally before sending data to an LLM. How do you scale this? Do you use `worker_threads` or the `cluster` module?
**Difficulty level:** Advanced
**Research Classification:** [LIKELY]
**Why They Ask This:** Evaluates understanding of Node's concurrency models. Tech Leads must know how to handle CPU-bound tasks in a single-threaded environment.
**Short Interview Answer (30-90 seconds spoken):** I would use `worker_threads`. The `cluster` module is for scaling network I/O (handling more HTTP requests) by copying the entire Node process. Parsing PDFs and tokenization are CPU-bound tasks. If done on the main thread, they block the event loop. `worker_threads` allow us to execute this CPU-heavy work in parallel within the same process, sharing memory efficiently using `SharedArrayBuffer` if needed, without duplicating the memory overhead of the entire application.
**Deep Explanation:** 
- **Cluster:** Spawns entirely separate OS processes via `child_process.fork()`. They share a port but have separate memory space and V8 instances. Best for horizontal scaling of web servers across cores.
- **Worker Threads:** Run in the same OS process. They have their own V8 isolate and event loop, but can share memory. Best for CPU-intensive data processing.
**Under the Hood:** A `Worker` thread spins up a new instance of V8 and libuv. Communication happens via `MessageChannel` (cloning data) or `SharedArrayBuffer` (zero-copy memory sharing).
**Real-World Example (production-grade):** In our eLearning pipeline, when a student uploads a thesis, the API gateway receives the file and passes it to a Worker Thread pool (using a library like `piscina`). The worker parses the PDF, chunks the text, and returns the tokens to the main thread, which then makes async network calls to OpenAI.
**Production Scenario:** The main Express server becomes unresponsive to health checks for 5 seconds every time a large PDF is uploaded, causing Kubernetes to kill and restart the pod.
**Code Example:**
```typescript
import { Worker } from 'worker_threads';
import { join } from 'path';

function runTokenization(pdfBuffer: Buffer): Promise<any> {
  return new Promise((resolve, reject) => {
    const worker = new Worker(join(__dirname, 'tokenizer-worker.js'), {
      workerData: { pdfBuffer }
    });
    worker.on('message', resolve);
    worker.on('error', reject);
    worker.on('exit', (code) => {
      if (code !== 0) reject(new Error(`Worker stopped with exit code ${code}`));
    });
  });
}
```
**Trade-offs:** Spinning up a worker takes time and memory (~30MB per isolate). For a high-traffic app, you must use a **Thread Pool** (like `piscina`) rather than creating a new worker per request.
**What a Weak Candidate Might Say:** "Node is single-threaded, so we can't do this. We have to use Python."
**What a Senior Engineer Would Say:** Distinguishes between Cluster (I/O) and Worker Threads (CPU). Uses workers to prevent event loop blocking.
**What a Technical Lead Would Say:** Discusses the architectural trade-off: While `worker_threads` solve the immediate blocking issue, for a true microservices architecture handling LLM workloads, offloading this to an asynchronous background job queue (e.g., SQS + a dedicated worker service written in Python or Rust) is far more scalable and fault-tolerant than running it in the API server.
**Follow-up Questions:**
1. How does a worker thread communicate with the main thread?
2. What is structured cloning?
3. How do you prevent thread exhaustion?
**Follow-up Answers:**
1. Via `postMessage` and event listeners.
2. The algorithm used to copy complex JavaScript objects between threads. It is slow for huge objects.
3. Use a thread pool limit (e.g., matching the number of CPU cores).
**Interviewer Trap:** Suggesting you share the HTTP request object with the worker. (Answer: You can't. Structured cloning fails on objects with C++ bindings like sockets/requests. Pass only the required data).
**Key Takeaways:** 
- Cluster = I/O scaling. Worker Threads = CPU scaling.
- Don't block the loop.
- Use thread pools, don't spawn workers infinitely.

### Q4: Graceful Shutdown in Orchestrated Environments
**Interview Question:** Your Node.js application is deployed on Kubernetes (or AWS ECS). When a deployment occurs, old pods are terminated. How do you ensure no student data is lost or HTTP requests dropped during this process?
**Difficulty level:** Senior
**Research Classification:** [CONFIRMED]
**Why They Ask This:** Tests deep operational/production readiness. A system that drops requests during deployments causes random errors for users and is not production-grade.
**Short Interview Answer (30-90 seconds spoken):** I implement a graceful shutdown mechanism intercepting `SIGTERM` signals from the orchestrator. First, I tell the HTTP server to stop accepting new connections and fail Kubernetes readiness probes so traffic is routed away. Then, I wait for existing in-flight HTTP requests to finish. Finally, I close database connections (PostgreSQL/Redis) and exit the process. If this takes longer than the orchestrator's timeout (e.g., 30s), a `SIGKILL` will force the shutdown.
**Deep Explanation:** When K8s rolls a pod, it sends `SIGTERM`. If the Node app ignores it, it eventually receives `SIGKILL`. If you immediately `process.exit(0)`, active connections are severed. You must call `server.close()` to stop new requests, and use a library like `stoppable` or track active connections to let them drain.
**Under the Hood:** `server.close()` stops the underlying C++ socket from accepting `accept()` calls. However, HTTP keep-alive connections might stay idle. Modern Node (v18+) has `server.closeIdleConnections()` and `server.closeAllConnections()` to handle this cleanly.
**Real-World Example (production-grade):** During a live quiz on the eLearning platform, a deployment triggers. The active websocket connections for the quiz state need time to sync final answers to the database before the pod dies. We catch `SIGTERM`, broadcast a "reconnect" frame to WS clients, flush the buffer to Postgres, and exit safely.
**Production Scenario:** Random 502 Bad Gateway errors observed in the API Gateway precisely during CI/CD deployments.
**Code Example:**
```typescript
import express from 'express';
import { createServer } from 'http';
import { pool } from './db';

const app = express();
const server = createServer(app);

let isShuttingDown = false;

app.get('/health', (req, res) => {
  if (isShuttingDown) return res.status(503).send('Shutting down');
  res.status(200).send('OK');
});

process.on('SIGTERM', async () => {
  console.log('SIGTERM received. Initiating graceful shutdown...');
  isShuttingDown = true; // Fail health checks
  
  server.closeIdleConnections();
  server.close(async (err) => {
    if (err) console.error(err);
    console.log('HTTP server closed.');
    await pool.end(); // Close DB pool
    process.exit(0);
  });

  // Fallback timeout
  setTimeout(() => {
    console.error('Forcing shutdown after 15s');
    process.exit(1);
  }, 15000);
});
```
**Trade-offs:** Too long of a graceful shutdown delays deployments. You must tune K8s `terminationGracePeriodSeconds` to match your application's absolute maximum timeout.
**What a Weak Candidate Might Say:** "I just let Docker kill the container. It restarts fast anyway."
**What a Senior Engineer Would Say:** Explains capturing SIGTERM, closing the server, and closing DB connections.
**What a Technical Lead Would Say:** Adds orchestrator specifics: failing readiness probes before closing the server, managing HTTP keep-alive issues, and handling asynchronous background jobs (draining message queues) alongside HTTP requests.
**Follow-up Questions:**
1. What is the difference between `SIGTERM` and `SIGKILL`?
2. How do you handle background jobs during a shutdown?
3. What is an Unhandled Rejection, and should you shut down gracefully on it?
**Follow-up Answers:**
1. `SIGTERM` can be caught and handled. `SIGKILL` cannot be intercepted and kills the process immediately at the OS level.
2. Stop consuming from the queue, wait for the active job to finish, or use a DLQ/retry mechanism for incomplete tasks.
3. Yes, an `unhandledRejection` indicates an unknown state. Log it, initiate a graceful shutdown, and let the orchestrator restart the pod.
**Interviewer Trap:** Thinking `process.exit(0)` is safe. (Answer: It abruptly kills everything).
**Key Takeaways:** 
- Catch SIGTERM.
- Stop accepting traffic.
- Drain active tasks.
- Exit gracefully.

### Q5: Connection Pooling and PostgreSQL
**Interview Question:** The platform experiences sudden traffic spikes when 5,000 students log in simultaneously. Our Node.js API connects to PostgreSQL. How do you manage database connections to prevent the DB from crashing, and what happens if you misconfigure this?
**Difficulty level:** Senior
**Research Classification:** [LIKELY]
**Why They Ask This:** Mismanaging DB connections in a highly concurrent environment like Node is the #1 cause of backend outages.
**Short Interview Answer (30-90 seconds spoken):** Node.js can handle thousands of concurrent HTTP requests, but PostgreSQL cannot handle thousands of concurrent connections (each Postgres connection spawns an OS process and uses ~10MB RAM). We must use a Connection Pool (like `pg-pool`). If misconfigured (e.g., pool size too small), Node queues queries, leading to high latency. If too large, Postgres gets overwhelmed and crashes. For huge scale, I'd introduce an external pooler like PgBouncer between Node and Postgres.
**Deep Explanation:** 
- The impedance mismatch: Node is async and cheap; DB connections are synchronous and expensive.
- Connection Pool: Maintains a set of open KEEPALIVE connections. When a query arrives, it borrows a connection, executes, and returns it.
**Under the Hood:** Node's `pg` module queues pending requests in memory when all pool clients are checked out. If the queue grows unbounded during a spike, you suffer Event Loop lag and eventual memory issues.
**Real-World Example (production-grade):** In an eLearning environment, thousands of students submit answers at the exact same time during a live quiz. We use a pool size of 20 in Node.js, and deploy PgBouncer sidecars in Kubernetes to multiplex these connections down to 100 actual connections on the Postgres master node.
**Production Scenario:** Application logs show `Timeout Error: ResourceRequest timed out`. Database CPU is at 100% and it's throwing `sorry, too many clients already`.
**Code Example:**
```typescript
import { Pool } from 'pg';

const pool = new Pool({
  host: 'db.internal',
  user: 'api_user',
  max: 20, // Max connections per Node instance
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000, // Fail fast if DB is unreachable
});

// Using checkout correctly
export async function getUser(id: string) {
  const client = await pool.connect();
  try {
    const res = await client.query('SELECT * FROM users WHERE id = $1', [id]);
    return res.rows[0];
  } finally {
    // MUST release client back to pool, otherwise pool is exhausted
    client.release();
  }
}
```
**Trade-offs:** A small pool causes latency; a large pool wastes DB resources. Calculating the right size requires the formula: `connections = ((core_count * 2) + effective_spindle_count)`.
**What a Weak Candidate Might Say:** "I just create a new connection using `new Client()` for every request." (This crashes the DB).
**What a Senior Engineer Would Say:** Explains connection pools, `max` sizes, and the importance of releasing the client.
**What a Technical Lead Would Say:** Discusses the multiplier effect in K8s (e.g., 50 pods * pool size of 20 = 1000 connections, which kills Postgres). Introduces architectural solutions like PgBouncer, read replicas, and query optimization.
**Follow-up Questions:**
1. What happens if you forget to call `client.release()`?
2. How do you debug pool exhaustion?
3. Why use PgBouncer if Node has a pool?
**Follow-up Answers:**
1. A connection leak occurs. The pool runs out of available connections, and subsequent requests hang infinitely until a timeout occurs.
2. Monitor pool metrics (e.g., `pool.waitingCount`, `pool.idleCount`) and expose them to Prometheus.
3. Node's pool is per-process. 100 Node pods = 100 independent pools. PgBouncer sits at the network layer and pools connections across ALL pods.
**Interviewer Trap:** Asking if setting the pool size to 1000 will make it faster. (Answer: No, it causes high context switching and memory exhaustion on the DB server).
**Key Takeaways:** 
- Always use a pool.
- Limit max connections.
- Account for K8s pod multipliers.

---

## 4. Technical Lead Scenario Questions (10 Scenarios)

1. **The Ghost Crash:** "Your Node service in production restarts once a day with no error logs. How do you debug this?" *(Focus: Out of Memory errors, unhandled rejections missing loggers, checking dmesg/syslog for OOM killer).*
2. **The Slow Monolith:** "Our Express app takes 3 seconds to respond. APM shows DB queries take 50ms. Where is the remaining 2.95s going?" *(Focus: Event loop lag, synchronous blocking code, payload serialization/JSON.stringify overhead).*
3. **The Microservice Split:** "Management wants to split our Node monolith into 20 microservices to 'make it faster'. How do you evaluate this?" *(Focus: Network latency overhead, distributed transactions, complexity. Advocate for a modular monolith first).*
4. **The LLM Rate Limit:** "Our application calls OpenAI APIs. During peak hours, we get 429 Too Many Requests, causing user errors. Design a solution." *(Focus: Dedicated worker queues (Redis/BullMQ), exponential backoff, circuit breakers).*
5. **The Memory Leak Detection:** "Memory grows steadily over 24 hours until crash. Walk me through your debugging steps." *(Focus: Heap snapshots (`node --inspect`), Clinic.js, analyzing retained objects, checking closures and event emitters).*
6. **The Corrupt DB State:** "A user updates their profile, but sometimes their old data overwrites the new data moments later." *(Focus: Race conditions, missing idempotency keys, lack of optimistic locking/row-versioning in Postgres).*
7. **The Security Audit:** "A critical zero-day vulnerability is found in a deep sub-dependency of `node_modules`. How do you patch and deploy it within an hour?" *(Focus: `npm overrides` or `yarn resolutions`, bypassing PR red-tape safely, CI/CD hotfix tracks).*
8. **The Flaky Tests:** "Our Jest test suite takes 20 minutes and fails 10% of the time randomly. How do you fix the engineering culture and pipeline?" *(Focus: Isolating DB states, mocking external API calls, parallel execution, identifying race conditions in tests).*
9. **The WebSocket Overload:** "10,000 students join a live video room. Our single Node server hits 100% CPU." *(Focus: Redis Pub/Sub backplane, scaling horizontally, moving WS handling to a specialized gateway).*
10. **The Unresponsive Dev Team:** "Developers complain that adding a new route in TypeScript takes too much boilerplate. Velocity is dropping." *(Focus: DX, moving from Express to a structured framework like NestJS or tRPC, establishing clear patterns).*

---

## 5. Production Failure Scenarios

1. **Failure:** `ECONNRESET` from external APIs. **Cause:** Keep-Alive timeout mismatches between Node.js and AWS ALB.
2. **Failure:** `JavaScript heap out of memory`. **Cause:** Loading a 200MB JSON file into memory simultaneously for 10 users.
3. **Failure:** Application hangs completely (0 CPU, 0 Network, 0 Errors). **Cause:** Depleted DB connection pool due to a leaked client connection.
4. **Failure:** Silent data corruption in MongoDB/Postgres. **Cause:** Unhandled Promise Rejection continuing to execute partial code blocks after a timeout.
5. **Failure:** CPU pegged at 100%, health checks failing. **Cause:** A poorly written Regex executed on a large, malicious user input (ReDoS attack).
6. **Failure:** Traffic drops to zero after a deployment. **Cause:** Readiness probe configured incorrectly or taking too long to connect to the DB.
7. **Failure:** Redis memory eviction destroying active sessions. **Cause:** Caching large LLM responses in the same Redis instance as session tokens without a strict TTL.
8. **Failure:** Node process dies immediately on startup in Docker. **Cause:** Missing environment variables, resulting in synchronous throws at the module level.
9. **Failure:** Duplicate emails sent to users. **Cause:** Consumer processing an SQS message crashes before deleting the message; queue visibility timeout expires, and another worker picks it up (Lack of idempotency).
10. **Failure:** Memory spike leading to OOM. **Cause:** `console.log` heavily dumping large objects into Docker's json-file log driver, backing up the event loop and RAM.

---

## 6. Architecture & Trade-off Questions

1. **Express vs Fastify vs NestJS:** Express is standard but slow/unstructured. Fastify offers high throughput (schema-based serialization). NestJS provides strict enterprise architecture (Angular-like, IoC) but steep learning curve.
2. **REST vs GraphQL vs gRPC:** REST for public APIs. GraphQL for complex frontend data fetching (prevents over-fetching). gRPC for high-speed, binary internal microservice communication.
3. **Monolith vs Microservices:** Monoliths are easier to deploy and trace. Microservices scale independently and allow polyglot stacks, but introduce distributed tracing and network latency overhead.
4. **BullMQ (Redis) vs AWS SQS:** BullMQ allows delayed jobs, complex retries, and parent/child flows but requires managing Redis state. SQS is fully managed and durable but lacks advanced scheduling natively.
5. **JWT vs Session Cookies:** JWTs are stateless and good for microservices, but hard to revoke instantly. Sessions require DB lookups (or Redis) but offer strict control and security.
6. **TypeScript vs JSDoc:** TS provides compile-time safety and refactoring confidence, but requires a build step (esbuild/tsc). JSDoc gives IDE support without the build step, good for scripts.
7. **ORM (Prisma/TypeORM) vs Query Builder (Knex):** Prisma has excellent TS typing but can generate highly inefficient SQL joins. Query builders offer better performance tuning but less safety.
8. **`node-fetch` vs `axios`:** Native `fetch` is now built into Node 18+, removing dependencies. Axios offers interceptors, automatic JSON parsing, and easy timeout configurations.
9. **Horizontal vs Vertical Scaling:** Horizontal (more pods) offers high availability but requires stateless architecture. Vertical (bigger CPU/RAM) is easier but has a hard physical limit.
10. **Serverless (Lambda) vs Containers (ECS/EKS):** Serverless is zero-maintenance and scales to zero, but suffers from cold starts (bad for Node.js APIs). Containers provide consistent latency and control.

---

## 7. System Design Exercise: AI-Powered Document Analyzer
**Scenario:** Design a system for the SAQAYA eLearning platform where users upload massive course PDFs (up to 500MB). The system must extract text, generate a summary via an LLM (OpenAI), and create flashcards.

**Key Requirements:**
- High availability.
- No dropped files.
- Real-time status updates to the frontend.
- Handle third-party LLM rate limits.

**Architecture Walkthrough:**
1. **Upload Phase:**
   - *Anti-Pattern:* Proxying the 500MB file through the Node.js API.
   - *Solution:* Node.js API generates an AWS S3 Pre-signed POST URL. The client browser uploads directly to S3.
2. **Event Trigger:**
   - S3 triggers an AWS EventBridge event -> pushed to an SQS Queue (`document-processing-queue`).
3. **Worker Service (Node.js):**
   - A dedicated background worker Node.js service polls SQS.
   - It streams the file from S3 (`stream.pipeline`), extracting text in chunks to avoid memory exhaustion.
4. **LLM Orchestration:**
   - Using a queueing mechanism (BullMQ on Redis) to handle rate limiting and exponential backoffs when calling OpenAI APIs.
5. **State Updates:**
   - As processing progresses (10%, 50%, Done), the worker updates a PostgreSQL database.
   - A Redis Pub/Sub mechanism triggers a WebSocket server to push real-time progress to the React frontend.
6. **Data Storage:**
   - Text embeddings are stored in a Vector DB (e.g., pgvector in PostgreSQL). Flashcards in relational tables.

---

## 8. Top 10 Question Lists (Quick Reference)

### Top 10 Core Node.js Concepts
1. Event Loop & libuv phases
2. Microtask vs Macrotask queues
3. `process.nextTick()` vs `setImmediate()`
4. Memory Leaks & Garbage Collection
5. Streams (Readable, Writable, Transform) & Backpressure
6. Concurrency (`cluster` vs `worker_threads`)
7. Error Handling (`unhandledRejection`, `uncaughtException`)
8. Buffer and memory allocation (V8 heap vs C++ heap)
9. Event Emitters and memory leaks
10. Asynchronous Context Tracking (`AsyncLocalStorage`)

### Top 10 Technical Lead Focus Areas
1. CI/CD Pipeline optimization for Node
2. Microservice tracing (OpenTelemetry)
3. Rate Limiting strategies
4. Graceful Shutdown & Kubernetes integration
5. Monolith decomposition strategies
6. Dependency management and CVE patching
7. Testing strategies (Unit vs Integration vs E2E)
8. Managing technical debt and TypeScript migrations
9. Coaching on async/await performance traps
10. Database schema migrations in zero-downtime environments

---
*Created for SAQAYA / Palladium Technical Lead Preparation.*
