# Common Failure Modes & Mitigations

Understanding how complex distributed systems fail is critical for designing resilient architecture.

## 1. Cascading Failures
**What:** A failure in one component causes failures in other components, eventually bringing down the entire system. Usually caused by positive feedback loops.
**Scenario:** Service A calls Service B. Service B slows down. Service A's connection pool fills up waiting for B. Service A becomes unresponsive to the API Gateway. The whole system crashes.
**Mitigations:**
- **Circuit Breakers:** If Service B fails a certain threshold (e.g., 50% of requests over 10s), Service A trips the circuit and immediately returns an error or fallback response without calling B, giving B time to recover.
- **Timeouts:** Aggressive, short timeouts on all network calls.
- **Bulkheads:** Isolate resources. E.g., Use separate connection pools for different downstream services so a failure in one doesn't exhaust connections for others.

## 2. Thundering Herd
**What:** A massive number of requests hit the system simultaneously, usually after a cache invalidation or a service restart.
**Scenario:** A popular cached item expires. Thousands of concurrent requests hit the server, find a cache miss, and all query the database simultaneously for the exact same expensive data. The DB crashes.
**Mitigations:**
- **Cache Stampede Protection (Mutex/Lock):** When a cache miss occurs, the first request acquires a lock, fetches the data, and populates the cache. The other requests wait for the lock or serve slightly stale data.
- **Jitter:** Add randomness to TTLs or retry intervals so not all clients retry/expire at the exact same millisecond.

## 3. Connection Pool Exhaustion (Database Storms)
**What:** The application attempts to open more database connections than the DB can handle, leading to timeouts and DB CPU spikes. Often occurs in serverless environments (e.g., AWS Lambda) where auto-scaling spins up thousands of concurrent instances, each opening its own DB connection.
**Mitigations:**
- **Connection Proxy/Multiplexer:** Use PgBouncer (PostgreSQL) or AWS RDS Proxy. It maintains a small pool of persistent connections to the DB and multiplexes thousands of application connections over them.

## 4. Retries without Backoff (Retry Storms)
**What:** Clients aggressively retry failed requests, multiplying the load on an already struggling system, effectively DDoS-ing yourself.
**Mitigations:**
- **Exponential Backoff:** Wait 1s, then 2s, 4s, 8s between retries.
- **Jitter:** Wait (1s + random ms), (2s + random ms). Prevents retries from syncing up.
- **Circuit Breakers:** Stop retrying entirely if the downstream is clearly down.

## 5. Memory Leaks & Resource Exhaustion
**What:** The application fails to release memory, eventually causing an OutOfMemory (OOM) crash.
**Mitigations:**
- Health checks (Liveness probes in Kubernetes) to restart stuck or OOMing containers automatically.
- Strict resource limits (Memory/CPU limits) so a leaking container is killed before it takes down the whole physical node.

## 6. External Dependency Outages (e.g., LLM Providers)
**What:** OpenAI, Stripe, or AWS us-east-1 goes down.
**Mitigations:**
- **Graceful Degradation:** The system should continue functioning, albeit with fewer features. If the LLM is down, return standard pre-computed responses or disable the AI chat widget without breaking the main app.
- **Fallback Routing:** Automatically switch from OpenAI to Anthropic if OpenAI API error rates exceed a threshold.

## Interview Questions
**Q: Your monitoring shows the database CPU is at 100%. Application servers are restarting because their health checks are failing. What is likely happening and how do you mitigate it?**
*A: This sounds like a cascading failure due to connection pool exhaustion or a slow DB query. The slow DB causes app requests to block. The app runs out of worker threads, causing health checks to fail. Kubernetes restarts the app. When the app restarts, it creates a Thundering Herd of reconnects to the DB, keeping it at 100% CPU. Mitigation: Stop incoming traffic at the API Gateway. Let the DB recover. Restart the app servers. Slowly bleed traffic back in while analyzing the slow query log to fix the root cause (likely a missing index).*

**Q: Explain the Circuit Breaker pattern.**
*A: It's an engineering pattern inspired by electrical engineering to prevent cascading failures. It wraps a remote service call in an object that monitors for failures. 
- **Closed State:** Normal operation. Calls pass through.
- **Open State:** If failure rate exceeds a threshold, the circuit opens. Calls fail fast immediately without hitting the remote service.
- **Half-Open State:** After a timeout, it allows a few test requests through. If they succeed, it closes the circuit. If they fail, it re-opens it. 
This protects the failing downstream service from being overwhelmed while it tries to recover.*
