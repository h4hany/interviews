# Node.js for Technical Leads: Deep Dive & Interview Prep

## 1. Node.js Event Loop & Architecture

### Core Concepts
Node.js runs on the **V8 JavaScript engine** and uses **libuv** for asynchronous I/O.
- **Single-Threaded:** The JavaScript execution is single-threaded.
- **Thread Pool:** Libuv maintains a thread pool (default 4 threads, configurable via `UV_THREADPOOL_SIZE`) for CPU-intensive OS operations like `fs`, `crypto`, and `dns.lookup`.

### Event Loop Phases (libuv)
1. **Timers:** Executes callbacks scheduled by `setTimeout` and `setInterval`.
2. **Pending Callbacks:** Executes I/O callbacks deferred to the next loop iteration.
3. **Idle, Prepare:** Internal use only.
4. **Poll:** Retrieves new I/O events; executes I/O related callbacks (almost all with the exception of close callbacks, timers, and `setImmediate`). Block here if queue is empty.
5. **Check:** Executes `setImmediate` callbacks.
6. **Close Callbacks:** Executes `socket.on('close')`.

**Microtasks:** Executed *between* every phase. `process.nextTick` takes the highest priority over Promises.

## 2. Worker Threads vs Child Processes vs Cluster

- **Cluster:** Spawns multiple identical Node.js processes sharing the same port. Great for scaling HTTP servers across CPU cores. Less relevant now in Kubernetes environments (where pods scale horizontally), but useful for maximizing single-pod CPU utilization.
- **Child Processes (`child_process`):** Spawns independent OS processes. Communicates via IPC. High memory overhead.
- **Worker Threads (`worker_threads`):** Shares the same OS process but creates a new V8 isolate. Communicates via `MessageChannel` and shares memory via `SharedArrayBuffer`. Best for CPU-heavy tasks (e.g., image processing, heavy cryptography) without blocking the main event loop.

## 3. Streams & Backpressure

Streams process data chunk by chunk, preventing large files from blowing up the memory heap (V8 limit is ~1.4GB on 64-bit by default).

**Backpressure:** When the readable stream produces data faster than the writable stream can consume. Handled automatically via `.pipe()` or the modern `stream/promises.pipeline()`.

```javascript
// Production Example: Safe stream processing with Pipeline
import { pipeline } from 'stream/promises';
import { createReadStream, createWriteStream } from 'fs';
import { createGzip } from 'zlib';

async function compressFile(input, output) {
  try {
    await pipeline(
      createReadStream(input),
      createGzip(),
      createWriteStream(output)
    );
    console.log('Pipeline succeeded.');
  } catch (err) {
    console.error('Pipeline failed.', err); // Automatically destroys all streams on error
  }
}
```

## 4. Interview Questions

### Question 1: What is the difference between `setImmediate` and `process.nextTick`?
### What the interviewer is testing
Understanding of Node.js event loop phases and microtask queues.
### Short answer
`process.nextTick` runs immediately after the current operation completes, before the event loop continues. `setImmediate` runs in the Check phase of the event loop.
### Detailed answer
`process.nextTick` queues a microtask that is evaluated at the end of the current C++ to JS boundary transition. If you recursively call `nextTick`, you will block the event loop entirely (I/O starvation). `setImmediate` is queued in the Check phase (after Poll). Recursive `setImmediate` calls yield to the event loop, allowing I/O to be processed.
### How it works internally
Libuv doesn't know about `nextTick` or Promises; they are managed by V8/Node.js core. Libuv manages the phases. Before moving to any libuv phase, Node drains the microtask queue (`nextTick` first, then Promises).
### Real-world example
Use `setImmediate` to break up heavy synchronous CPU work into chunks so the HTTP server can still respond to health checks. Use `nextTick` strictly when an API expects an asynchronous callback but you have the data synchronously, to maintain consistent async API contracts.
### Trade-offs
Overuse of `nextTick` causes event loop lag and unresponsiveness.
### Common mistakes
Assuming `setImmediate` is faster than `setTimeout(0)`. (They are non-deterministic if called from the main module, but within an I/O cycle, `setImmediate` always fires first).
### Strong Technical Lead answer
"I view `process.nextTick` as a potential danger in production because it can starve the event loop if misused. In highly concurrent microservices, if we must defer execution, we prefer `setImmediate` to ensure I/O polling can still occur, keeping our Kubernetes liveness probes passing. For CPU-bound tasks, neither is sufficient, and we offload to `worker_threads` or separate Rust/Go services."

---

### Question 2: How do you handle unhandled promise rejections and uncaught exceptions in production?
### What the interviewer is testing
Production readiness, system stability, and graceful shutdown patterns.
### Short answer
Log the error as FATAL, gracefully shut down HTTP connections, and exit the process.
### Detailed answer
Catching `uncaughtException` and attempting to continue is an anti-pattern because the V8 state is compromised, potentially leading to memory leaks or data corruption. You must trap the event, instruct the HTTP server to stop accepting new connections (graceful shutdown), finish active requests, and exit with `process.exit(1)`. PM2 or Kubernetes will restart the container.
### How it works internally
Node emits the `uncaughtException` event on the `process` object. Since Node 15, `unhandledRejection` also terminates the process by default.
### Real-world example
```javascript
process.on('uncaughtException', (err) => {
  logger.fatal({ err }, 'Uncaught Exception! Initiating graceful shutdown.');
  server.close(() => {
    process.exit(1);
  });
  
  // Fail-safe timeout
  setTimeout(() => process.exit(1), 10000).unref();
});
```
### Trade-offs
Graceful shutdown delays the restart. Load balancers must be configured correctly with readiness probes to route traffic away during the shutdown period.
### Common mistakes
Leaving the process running after `uncaughtException`. Using `process.exit(0)` on failure (breaks orchestration tools).
### Strong Technical Lead answer
"A Node.js process in an indeterminate state cannot be trusted. My standard boilerplate for production microservices includes trapping `SIGTERM`, `uncaughtException`, and `unhandledRejection`. On trigger, we immediately fail the Kubernetes readiness probe, log the stack trace to Datadog/ELK, invoke `server.close()`, wait for active DB transaction pools to drain (with a 10-second fail-safe), and exit with code 1. Immutability applies to compute: if a process breaks, burn it down and let the orchestrator spin up a fresh one."
