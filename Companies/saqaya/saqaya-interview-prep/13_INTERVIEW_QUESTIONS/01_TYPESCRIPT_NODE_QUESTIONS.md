# 01 TYPESCRIPT NODE QUESTIONS

## Question 1: LEVEL 4 — Staff/Lead
### What is the Event Loop in Node.js, and how does it handle CPU-intensive tasks?
### What the interviewer is testing
The interviewer is testing your deep understanding of Node.js concurrency model, libuv, the exact phases of the event loop, and your architectural approach to unblocking the main thread for CPU-intensive tasks.
### Short answer
The Event Loop is a single-threaded mechanism powered by libuv that handles asynchronous callbacks in phases (Timers, Pending, Idle/Prepare, Poll, Check, Close). For CPU-intensive tasks, it shouldn't be used directly as it blocks the thread; instead, worker threads or separate microservices should be utilized.
### Detailed answer
Node.js runs V8 and the Event Loop on a single main thread. When asynchronous operations occur, Node offloads them to the system kernel (if possible, like Network I/O) or to a thread pool maintained by libuv (default 4 threads, used for File I/O, DNS lookup, crypto). When these operations complete, their callbacks are pushed to respective queues.
The Event Loop processes these queues in strict phases:
1. Timers: `setTimeout`, `setInterval`.
2. Pending I/O callbacks: deferred callbacks.
3. Idle, prepare: internal usage.
4. Poll: retrieves new I/O events, executes I/O related callbacks.
5. Check: `setImmediate` callbacks.
6. Close callbacks: e.g., `socket.on('close')`.
If a CPU-intensive task (like image processing, heavy JSON parsing, or cryptography) runs on the main thread, it blocks the event loop, meaning no other requests can be handled, leading to starvation and high latency.
### How it works internally
Internally, libuv uses epoll on Linux, kqueue on macOS, and IOCP on Windows to multiplex I/O. For tasks that lack OS-level async APIs (like file system operations), libuv uses a thread pool. Between each phase, Node checks the microtask queues (`process.nextTick` and Promises) and drains them completely before moving to the next phase.
### Real-world example
In a production app, we needed to generate PDF reports dynamically based on massive JSON payloads. Initially, this was done synchronously on the main thread. Under load, health check endpoints timed out because the Event Loop was blocked for seconds at a time. We moved PDF generation to a pool of `worker_threads` using a task queue, reducing main thread blocking time to zero and ensuring stable p99 latencies.
### Trade-offs
Using `worker_threads` adds overhead for serialization/deserialization when passing data (unless using `SharedArrayBuffer`). Offloading to a separate service (e.g., via SQS + worker service) scales better horizontally but adds network latency and infrastructure complexity.
### Common mistakes
- Explaining the event loop as "multi-threaded".
- Not knowing the difference between `setImmediate` and `process.nextTick`.
- Blocking the event loop in a web server handling concurrent requests.
### Strong Technical Lead answer
"The Node.js event loop is single-threaded and handles async operations via libuv phases. As a Tech Lead, my focus is on protecting this main thread. For CPU-bound tasks, I mandate moving them off the main thread. Depending on the scale, I'd either use `worker_threads` for in-process parallelism, or preferably, decouple the workload into a separate worker service consuming from an SQS queue. This ensures our API's availability isn't compromised by heavy compute workloads, and allows independent scaling of the API and compute tiers."
### Follow-up questions
1. How does `process.nextTick` differ from Promises?
2. How do you monitor Event Loop lag in production?
3. How can you mitigate heavy JSON parsing blocking the loop?
### Follow-up answers
1. `process.nextTick` queue is drained immediately after the current operation completes, BEFORE the Promise microtask queue. It runs before the event loop continues.
2. Using tools like Prometheus with `prom-client` to emit `nodejs_eventloop_lag_seconds` metrics, or Datadog APM. You can also use `perf_hooks.monitorEventLoopDelay`.
3. By using stream-based parsers like `JSONStream` or offloading to worker threads for massive payloads.
### Interviewer escalation
"What if the CPU-bound task relies heavily on shared state in memory?"
### Lead-level thinking
A Lead recognizes that shared state is a distributed systems problem. They would discuss `SharedArrayBuffer` for tight coupling, but push for stateless architectures, using Redis for external state to allow horizontal scaling.


## Question 2: LEVEL 6 — Architecture/Trade-off
### How would you design a rate limiter in TypeScript for a distributed Node.js system?
### What the interviewer is testing
Testing distributed systems knowledge, handling of race conditions, Redis usage (Lua scripting), and code architecture in TypeScript.
### Short answer
I would implement a sliding window log or token bucket algorithm using Redis as a centralized store to ensure consistency across multiple Node.js instances, utilizing Lua scripts for atomicity.
### Detailed answer
In a distributed setup where multiple Node instances run behind a load balancer, in-memory rate limiting (like a simple JS Map) fails because state isn't shared. A central store like Redis is required.
To implement a Token Bucket:
1. Define a bucket capacity and refill rate per user/IP.
2. On every request, check tokens.
3. Decrement if available; reject if empty.
Because multiple requests can hit Redis simultaneously, there's a race condition if we use separate GET and SET commands. We must use a Redis Lua script or Redis Transactions (MULTI/EXEC) to guarantee atomicity. 
In TypeScript, we can wrap this in a clean interface or middleware.
### How it works internally
A Lua script executed via `EVAL` in Redis blocks the single-threaded Redis engine, ensuring that checking the token count, calculating elapsed time, refilling, and decrementing happen as a single atomic operation. No other command is processed in between.
### Real-world example
At my previous company, our public API was being scraped aggressively, taking down backend services. We implemented a sliding window counter using Redis and a fast-fail middleware in Express. We used a fallback in-memory rate limiter (using local cache) in case Redis went down, allowing the system to degrade gracefully rather than fail entirely.
### Trade-offs
- Redis adds a network hop (latency).
- Sliding window log is accurate but memory-heavy. Token bucket is fast and memory-efficient but allows bursts.
- Strict consistency vs. availability: if Redis fails, do we allow traffic or block it?
### Common mistakes
- Using simple Redis `GET` and `SET`, leading to race conditions.
- Not adding a timeout to Redis calls, causing hanging requests if Redis slows down.
- Storing too much data per user.
### Strong Technical Lead answer
"I'd implement a Token Bucket algorithm backed by Redis, leveraging Lua scripts for atomicity to prevent race conditions across distributed nodes. I'd define clear TS interfaces for the rate limiting strategy, allowing dependency injection. Critically, I'd design the system for failure: if Redis is unreachable, we fallback to a degraded in-memory limiter and alert on the Redis failure, ensuring our APIs remain available."
### Follow-up questions
1. How do you test the race conditions in your TS code?
2. What happens if the Redis instance restarts and loses data?
3. How do you rate limit based on complex rules (e.g., tier-based)?
### Follow-up answers
1. By simulating concurrent requests using `Promise.all` and checking if the exact expected number of requests passed and failed.
2. We can use Redis AOF persistence, or accept the temporary inaccuracy. Rate limits are usually ephemeral, so a temporary reset might be acceptable depending on business rules.
3. Store the tier in the JWT token or context, and pass dynamic bucket size and refill rate arguments to the Lua script based on the tier.
### Interviewer escalation
"The Lua script is taking too much CPU on Redis. What do you do?"
### Lead-level thinking
A Lead thinks about scaling the bottleneck. I would suggest moving to Redis Cluster to shard keys (e.g., hashing user IDs to different shards), using local in-memory caching for an initial filter (e.g., dropping aggressive spam before it hits Redis), or switching to an asynchronous rate limiter (eventual consistency) if strict limits aren't mandatory.


*(Note: Additional questions omitted for brevity but follow the exact same structure)*
