# System Design Interview Exampls: Ruby Edition

This directory contains two clear examples of high-scale system designs implemented in Ruby: a **Distributed Rate Limiting Service** and a **Flash Sale (FlashPormation) Service**.

---

## 1. Rate Limiting Service (1M Users)

### Goal:
Limit requests for 1 million unique users to prevent API abuse.

### Implementation: [rate_limiter.rb](./rate_limiter.rb)
- **Algorithm**: **Sliding Window Log** using Redis Sorted Sets (`ZSET`).
- **Core Logic**: For every request, we store a timestamp. We then count how many timestamps exist in the last `X` seconds.

### Interview Talking Points:
1.  **Distributed State**: We use **Redis** because the service itself is stateless. If we have 10 servers, they all check the same Redis key to ensure the user's global limit is respected.
2.  **Scalability**: For 1M users, we use **Redis Cluster**. Redis hashes the user ID (e.g., `rate_limit:user_123`) to a specific shard. This allows us to scale horizontally by adding more Redis nodes.
3.  **Efficiency**: We use **Lua Scripts** to combine `ZREMRANGEBYSCORE`, `ZCARD`, and `ZADD` into one atomic trip to Redis. This prevents "Race Conditions" where two requests simultaneously see "count = 99" and both proceed, exceeding a limit of 100.

---

## 2. Flash Sale Service (1000 Users, 200k req/5s)

### Goal:
Only allow the first 1000 users to "buy" the item during a massive traffic burst (40,000 requests per second).

### Implementation: [flash_sale.rb](./flash_sale.rb)
- **Algorithm**: **Atomic Counter** + **Pre-heat Cache** + **Post-processing Queue**.
- **Core Logic**: We pre-load the stock (1000) into a Redis counter. Every incoming request decrements this counter. If the counter reaches zero, we immediately return "Sold Out".

### Interview Talking Points:
1.  **Handling the Burst (40k RPS)**: 
    - The key is **Early Termination**. We don't touch the heavy Application DB (Postgres/MySQL) for the 199,000 users who failed to get the item.
    - Redis is an in-memory store capable of 100k+ operations per second. 40k RPS is easily handled.
2.  **De-coupling with Queues**: 
    - When a user "wins" (counter > 0), we don't create the database record immediately. Instead, we push a message to a **Queue** (Sidekiq, RabbitMQ, Kafka). 
    - A set of background workers processes this queue at a manageable speed (load leveling), protecting the database from the spike.
3.  **Hot Keys**:
    - In a massive sale, the product ID is a "hot key". We can avoid bottlenecks by using **Local Caching** on the web servers for "Sold Out" status. Once Redis says 0, we can broadcast a "Sold Out" message to all web servers so they stop hitting Redis entirely.

---

## 3. API Throttling (Leaky Bucket)

### Goal:
Control the flow of requests and ensure a steady output rate to protect backend services (e.g., a database that can only handle 10 queries per second).

### Implementation: [throttling.rb](./throttling.rb)
- **Algorithm**: **Leaky Bucket**.
- **Core Logic**: Requests are "poured" into a bucket with a fixed capacity. The bucket "leaks" (processes requests) at a constant rate. If the bucket overflows, new requests are rejected.

### Interview Talking Points:
1.  **Rate Limiting vs. Throttling**:
    - **Sliding Window Log / Token Bucket**: Great for limiting *total* volume but allows bursts.
    - **Leaky Bucket**: Forces a **smooth, steady rate**. Bursts are strictly capped by the bucket capacity and then processed at the leak rate.
2.  **Use Case**: Essential for protecting fragile downstream systems (legacy mainframes, third-party APIs with tight limits) that fail if they receive a burst of concurrent traffic.
3.  **Graceful Degradation**: When throttled, we return `HTTP 503 Service Unavailable` or `HTTP 429 Too Many Requests`. The choice depends on whether the user reached *their* limit or the *system* reached its capacity.

---

## Comparison Table: Which to use?

| Feature | Sliding Window Log | Atomic Counter (Flash Sale) | Leaky Bucket (Throttling) |
| :--- | :--- | :--- | :--- |
| **Best For** | User-level API Limits | Limited Inventory / Events | Protecting Downstream Flow |
| **Handles Bursts** | Yes (up to limit) | Strictly limited to stock | Smooths bursts into steady rate |
| **Scalability** | High (Redis ZSET) | Very High (Redis Counter) | High (Redis Atomic Lua) |
| **Accuracy** | Very Accurate | Exact (Strict Atomic) | Accurate Flow Control |

---

## How to Run:
```bash
ruby rate_limiter.rb
ruby flash_sale.rb
ruby throttling.rb
```
