# 🚀 Toters Staff Backend Engineer — Full Question Bank with Answers

> Complete answers to every question category. Study this before the interview.

---

## 📋 Table of Contents

1. [🔥 System Design](#system-design)
2. [⚙️ Backend Core Concepts](#backend-core)
3. [⚡ Performance & Scaling](#performance)
4. [🧱 Microservices & Architecture](#microservices)
5. [☁️ Cloud / DevOps](#devops)
6. [🔐 Reliability & Fault Tolerance](#reliability)
7. [🧠 Staff-Level Leadership](#leadership)
8. [🔥 Real-World Problem Solving](#real-world)
9. [🧪 Coding Questions](#coding)

---

## 🔥 1. System Design {#system-design}

---

### Q: Design a food delivery system like Toters

**Start with clarifying questions (do this every time):**
- How many active users? (say: 500k DAU, 50k concurrent peak)
- What geographies? (say: 3–5 cities)
- Expected order throughput? (say: 10k orders/hour peak)
- Any SLA requirements? (say: <200ms order placement, <100ms tracking)

**High-Level Architecture:**

```
Mobile/Web Client
        │
        ▼
[API Gateway] — Auth, Rate Limiting, SSL Termination
        │
   ┌────┼────────────────────────┐
   ▼    ▼                        ▼
[Order] [Catalog]            [Payment]
[Svc]   [Svc]                [Svc]
   │    │                        │
   └────┴────────┬───────────────┘
                 ▼
          [Kafka Event Bus]
                 │
     ┌───────────┼──────────────┐
     ▼           ▼              ▼
[Dispatch]  [Notification]  [Loyalty]
[Svc]       [Svc]           [Svc]
     │
     ▼
[Location Svc] ←→ [Redis GeoSet]
```

**Data stores per service:**

| Service | Primary DB | Cache | Why |
|---|---|---|---|
| Order | PostgreSQL | Redis | ACID for order state |
| Catalog | PostgreSQL + Elasticsearch | Redis | Full-text search on menus |
| Payment | PostgreSQL | Redis (idempotency keys) | ACID non-negotiable |
| Location | Redis GeoSet | — | Sub-ms geospatial lookups |
| History | Cassandra | — | High-write location history |
| Analytics | ClickHouse / Redshift | — | OLAP aggregations |

**Order State Machine:**

```
PENDING → PAYMENT_PROCESSING → CONFIRMED → PREPARING
→ READY_FOR_PICKUP → IN_TRANSIT → DELIVERED

Failure paths:
PAYMENT_PROCESSING → PAYMENT_FAILED (terminal)
CONFIRMED          → CANCELLED
IN_TRANSIT         → DELIVERY_FAILED (terminal)
```

**Key design decisions to mention proactively:**
1. All inter-service communication via Kafka (async) to avoid tight coupling
2. Redis for hot data (current order status, driver locations)
3. Transactional Outbox pattern for DB + Kafka consistency
4. Idempotency keys on every payment and order creation

---

### Q: Design a real-time order tracking system

**Components:**

```
Courier App → WebSocket/gRPC → Location Service
                                     │
                               Redis GEOADD (hot path)
                               Kafka (cold path → Cassandra)
                                     │
                           Redis Pub/Sub ──► Tracking Service
                                                    │
                                             WebSocket push
                                                    │
                                           Customer App (map)
```

**Write path (courier → server):**
```ruby
# Every 5 seconds from courier app
def handle_location_ping(courier_id:, lat:, lng:, timestamp:)
  # Atomic compare-and-set: only update if newer timestamp
  redis.eval(lua_compare_and_set, keys: [...], argv: [courier_id, lat, lng, timestamp])

  # Pub/Sub: push to all subscribers of this courier
  redis.publish("courier:#{courier_id}", { lat:, lng:, ts: timestamp }.to_json)

  # Async: persist to Cassandra for history
  kafka.produce({ courier_id:, lat:, lng:, timestamp: }, topic: "courier.locations")
end
```

**Read path (customer → server):**
```ruby
# Customer opens order map → WebSocket established
ws.on(:open) do
  order = Order.find(order_id)
  courier_id = order.courier_id

  # Subscribe to this courier's location updates
  redis_subscriber.subscribe("courier:#{courier_id}") do |msg|
    ws.send(msg)  # Push directly to customer
  end
end
```

**Key deep-dives to prepare:**
- Out-of-order GPS handling (timestamp validation in Lua)
- Reconnect storm (JWT stateless auth + exponential backoff)
- Battery optimization (adaptive ping rate: 3s moving, 30s stationary)
- Geofencing for "Your food is arriving" notification (50m radius trigger)

---

### Q: Design a dispatch system for drivers (batching orders)

**Phases:**

**Phase 1 — Find candidates (within 3km of restaurant):**
```ruby
candidates = redis.georadius(
  "couriers:available",
  restaurant.lng, restaurant.lat,
  3, "km",
  "WITHCOORD", "WITHDIST", "ASC", "COUNT", 10
)
```

**Phase 2 — Score each candidate:**
```
score = (distance_km × 0.5)          # Distance weight
      + (active_orders.count × 2.0)  # Penalize busy couriers
      + (avg_rating < 4.0 ? 1.5 : 0) # Penalize low-rated
      + (has_thermal_bag ? -0.5 : 0)  # Reward insulated bag for batching
```

**Phase 3 — Batching eligibility check:**
```ruby
def batchable?(existing_order, new_order, courier)
  return false unless same_restaurant?(existing_order, new_order)
  return false if courier.already_picked_up?(existing_order)

  # Will adding new order push first customer's ETA over threshold?
  added_time = estimated_detour_minutes(existing_order, new_order)
  added_time < MAX_BATCH_DETOUR_MINUTES  # e.g., 10 minutes
end
```

**Phase 4 — Assignment with optimistic locking (prevent double-assignment):**
```sql
UPDATE couriers
SET status = 'assigned', order_id = $1, version = version + 1
WHERE id = $2
  AND status = 'available'
  AND version = $3;  -- Optimistic lock
-- If 0 rows updated → courier was taken, try next candidate
```

**Peak load handling:**
- Pre-compute courier clusters every 30s using Redis GeoSet
- Maintain a "standby pool" of couriers near popular restaurant clusters
- During lunch spike: widen dispatch radius from 3km → 5km

---

### Q: Design a high-throughput notification system (SMS / push)

**Architecture:**

```
Any Service → Kafka topic: notifications.requested
                    │
              [Notification Service]
              ├── Reads from Kafka
              ├── Deduplication (Redis SET, 24h TTL)
              ├── User preference lookup (DB/cache)
              ├── Template rendering
              └── Routes to provider:
                  ├── Firebase FCM (push)
                  ├── Twilio (SMS)
                  └── SendGrid (email)
```

**Deduplication (prevent double-notifications):**
```ruby
def send_notification(user_id:, type:, idempotency_key:)
  dedup_key = "notif:sent:#{idempotency_key}"
  return if redis.set(dedup_key, "1", nx: true, ex: 86400).nil?

  # First time seeing this key — proceed
  deliver_notification(user_id:, type:)
end
```

**Rate limiting per user (no spam):**
```lua
-- Max 5 notifications per user per hour
local key = "notif:rate:" .. ARGV[1]  -- user_id
local count = redis.call("INCR", key)
redis.call("EXPIRE", key, 3600)
if count > 5 then return 0 end
return 1
```

**Priority queues:**
```
High priority (order confirmed, payment failed) → notifications.high    → 3 consumers
Medium priority (promotions)                   → notifications.medium  → 1 consumer
Low priority (weekly digest)                   → notifications.low     → batch nightly
```

**Provider failover:**
```ruby
def send_push(token:, message:)
  FCM.send(token:, message:)
rescue FCM::Error
  # Fallback to SMS if push fails
  Twilio.send(phone: user.phone, message: message.to_sms)
end
```

---

### Q: Design a payment system with retries & idempotency

**Core principle: every payment request must be idempotent.**

```ruby
POST /v1/payments
{
  "idempotency_key": "uuid-generated-by-client",
  "order_id": "ord_123",
  "amount": 4500,
  "currency": "EGP",
  "payment_method_id": "pm_456"
}
```

**Server-side idempotency handler:**
```ruby
def process_payment(idempotency_key:, **params)
  # 1. Check cache for existing result
  cached = redis.get("payment:idem:#{idempotency_key}")
  return JSON.parse(cached) if cached

  # 2. Acquire distributed lock (prevent concurrent duplicate requests)
  lock_acquired = redis.set("payment:lock:#{idempotency_key}", "1",
                             nx: true, ex: 30)
  raise DuplicateRequestError unless lock_acquired

  # 3. Process payment
  result = PaymentGateway.charge(**params)

  # 4. Store result with 24h TTL
  redis.setex("payment:idem:#{idempotency_key}", 86400, result.to_json)

  # 5. Persist to DB
  Payment.create!(idempotency_key:, **result)

  result
ensure
  redis.del("payment:lock:#{idempotency_key}")
end
```

**Retry strategy for external payment gateway:**
```ruby
def charge_with_retry(params, max_attempts: 3)
  attempts = 0
  begin
    PaymentGateway.charge(params)
  rescue PaymentGateway::TimeoutError,
         PaymentGateway::ServiceUnavailable => e
    attempts += 1
    raise e if attempts >= max_attempts

    # Exponential backoff with jitter
    sleep_time = (2 ** attempts) + rand(0.0..1.0)
    sleep(sleep_time)
    retry
  rescue PaymentGateway::CardDeclined => e
    raise e  # Don't retry declined cards — idempotent failure
  end
end
```

**State machine:**
```
INITIATED → PROCESSING → SUCCEEDED
                      → FAILED (retryable)
                      → DECLINED (terminal — don't retry)
                      → REFUNDED
```

---

### Q: Design a rate limiter for APIs

**Algorithm options:**

| Algorithm | Pros | Cons | Use When |
|---|---|---|---|
| Fixed Window | Simple, O(1) | Allows 2x burst at window edge | Simple quotas |
| Sliding Window Log | Exact | High memory (stores timestamps) | Strict accuracy needed |
| Sliding Window Counter | Memory efficient, accurate | Slightly approximate | Most production cases |
| Token Bucket | Smooth, allows bursts | Slightly complex | API gateways |
| Leaky Bucket | Strict output rate | Drops excess | Protecting downstream |

**Production implementation — Sliding Window Counter in Lua:**
```lua
-- KEYS[1]: rate limit key
-- ARGV[1]: window_seconds, ARGV[2]: max_requests, ARGV[3]: current_time

local key = KEYS[1]
local window = tonumber(ARGV[1])
local limit = tonumber(ARGV[2])
local now = tonumber(ARGV[3])

-- Remove events outside the current window
redis.call("ZREMRANGEBYSCORE", key, "-inf", now - window)

-- Count events in current window
local count = redis.call("ZCARD", key)

if count >= limit then
  return {0, limit - count}  -- Rejected, tokens remaining = 0
end

-- Add current request
redis.call("ZADD", key, now, now .. math.random())
redis.call("EXPIRE", key, window)

return {1, limit - count - 1}  -- Allowed, tokens remaining
```

**Multi-tier rate limiting:**
```
Per IP:    1,000 req/min  (DDoS protection)
Per User:  100 req/min    (fair usage)
Per API:   10,000 req/min (service protection)
Per Plan:  varies         (monetization)
```

---

### ⚡ Deep Follow-ups

**Q: How do you handle 1M+ requests per minute?**

> 1M req/min = ~16,700 RPS.
>
> **Layer 1 — Edge:** CDN (CloudFront) absorbs static content. API Gateway handles SSL termination and rough rate limiting.
>
> **Layer 2 — App:** Stateless app servers behind ALB. Horizontal autoscaling triggered at 70% CPU. Target: each server handles 1,000–2,000 RPS.
>
> **Layer 3 — Cache:** Redis absorbs hot reads. 80% cache hit ratio → only 3,300 RPS reaches the DB.
>
> **Layer 4 — DB:** PostgreSQL with read replicas. Writes go to primary, reads to replicas. Connection pooling via PgBouncer (1,000 app connections → 100 real DB connections).
>
> **Layer 5 — Async:** Non-critical work (notifications, analytics) moves off the request path into Kafka queues.

**Q: How do you ensure low latency (<100ms)?**

> - **Connection pooling** (PgBouncer) — eliminates 50–100ms connection setup overhead
> - **Redis caching** — sub-millisecond for hot data
> - **gRPC for internal calls** — binary protocol, multiplexed, 30–50% faster than REST
> - **Async where possible** — move non-blocking work (logging, analytics) off the request thread
> - **Database indexes** — EXPLAIN ANALYZE every slow query; add composite indexes for common query patterns
> - **N+1 elimination** — use `includes` / `eager_load` or raw SQL with JOINs
> - **Pagination** — never return unbounded result sets
> - **CDN** — serve restaurant images and menus from edge

**Q: How do you handle partial failures (driver app down, payment fails)?**

| Failure | Response |
|---|---|
| Driver app down | Order stays `CONFIRMED`, re-dispatch timer triggers after 5 min |
| Payment gateway timeout | Retry with exponential backoff (3 attempts), then return PAYMENT_FAILED |
| Notification service down | Circuit breaker opens, order still confirmed, notification retried from Kafka |
| Courier location service down | Last known location shown, ETA shows "updating…" |
| Redis down | Circuit breaker on Redis; fall through to PostgreSQL (slower but correct) |

**Q: How do you handle hot partitions (popular restaurant)?**

> A popular restaurant like a large McDonald's franchise might generate 10x normal order volume during lunch, creating a "hot key" in any database or cache partitioned by restaurant_id.
>
> **Approaches:**
> 1. **Read replicas per restaurant** — route all reads for a hot restaurant to a dedicated replica
> 2. **Cache aggressively** — restaurant catalog data (menu, hours) changes rarely; TTL = 5 minutes; cache at CDN level
> 3. **Key splitting** — instead of one Redis key `restaurant:123:active_orders`, use `restaurant:123:active_orders:shard:{0..N}` and distribute writes by hash of order_id
> 4. **Database partitioning** — partition orders table by `restaurant_id % 32` so hot restaurants don't affect others

**Q: What happens if Kafka is down?**

> **Transactional Outbox Pattern** — the safe fallback:
>
> ```sql
> -- Within the same DB transaction as the business logic:
> BEGIN;
> INSERT INTO orders (...) VALUES (...);
> INSERT INTO outbox_events (type, payload, published)
>   VALUES ('order.created', '{"order_id": 123}', false);
> COMMIT;
> ```
>
> A relay process polls `outbox_events WHERE published = false` and retries publishing to Kafka continuously. When Kafka recovers, all buffered events drain automatically.
>
> **Critical:** The outbox write is in the SAME transaction as the business write. Either both succeed or both fail. No inconsistency possible.

**Q: How do you guarantee eventual consistency?**

> Eventual consistency is achieved through:
> 1. **Idempotent consumers** — Kafka messages may be delivered more than once; consumers must produce the same result regardless of how many times they process a message
> 2. **Event sourcing** — state is derived from an immutable event log; replay events to reconstruct any state
> 3. **Conflict resolution policy** — for concurrent updates (e.g., two drivers claim same order), use "last-write-wins" with version timestamps, or application-level conflict resolution
> 4. **Saga pattern** — for multi-service workflows, each step publishes an event; compensating transactions handle rollback

---

### 💡 Toters-Specific Scenarios

**Q: How do you batch orders efficiently?**

> **Window-based batching:**
> 1. New order arrives for pickup at Restaurant X
> 2. Check: any courier currently at Restaurant X or within 2 min of it?
> 3. Check: is that courier's first customer's ETA still within acceptable window if we add this order?
> 4. If yes → batch. If no → assign separate courier.
>
> **Thermal constraints:** Only batch cold items with cold items; don't batch ice cream with hot food. Tag each order item with temperature requirement. Dispatch algorithm filters accordingly.
>
> **Limit:** Max 2–3 orders per courier per batch. Beyond that, the first customer's experience degrades too much.

**Q: How do you assign nearest driver in real-time?**

> ```ruby
> # O(log N) geospatial query — Redis GEORADIUS
> couriers = redis.georadius(
>   "couriers:available",
>   restaurant.lng, restaurant.lat,
>   3, "km",      # Start with 3km radius
>   "WITHCOORD", "WITHDIST", "ASC", "COUNT", 5
> )
>
> # If no couriers found, expand radius
> if couriers.empty?
>   couriers = redis.georadius(..., 5, "km", ...)
> end
>
> # Score and assign (optimistic lock to prevent double-assignment)
> assign_with_lock(best_courier(couriers), order)
> ```

**Q: How do you handle peak traffic (lunch/dinner spikes)?**

> **Predictive scaling:** Use historical data to pre-scale at 11:45am and 6:45pm before demand hits. Don't wait for autoscaling to react.
>
> **Priority queuing:** During peak, non-critical operations (loyalty point calculations, email receipts) are deprioritized. Order placement and payment are protected.
>
> **Circuit breakers:** If ETA service slows down, return a cached/static "30–45 min" estimate rather than blocking order placement.
>
> **Courier incentives:** Dynamically increase courier incentives during peak hours to increase supply before demand spikes.

**Q: How do you handle multi-city scaling?**

> **Regional isolation:**
> - Each city gets its own Redis cluster, PostgreSQL cluster, and Kafka cluster
> - A "Global Router" determines which regional cluster to hit based on user's registered city
> - Inter-city operations (cross-city analytics, pricing) go through a dedicated global aggregation service
>
> **Key namespacing:**
> ```
> courier:{cairo}:{courier_id}:location
> order:{beirut}:{order_id}:status
> ```
>
> **Data sovereignty:** Some regions require data to remain within their borders. Regional isolation makes compliance straightforward.

**Q: How do you prevent duplicate orders?**

> **Client-side:** Generate idempotency_key (UUID) before first attempt. Resend the same key on retry.
>
> **Server-side:**
> ```ruby
> # Before creating order, check if key exists
> existing = redis.get("order:idem:#{idempotency_key}")
> return existing if existing
>
> # Create order + store result atomically (Lua script)
> order = Order.create!(...)
> redis.setex("order:idem:#{idempotency_key}", 3600, order.to_json)
> ```
>
> **DB-level:** Unique index on `(user_id, idempotency_key)` as final safety net.

---

## ⚙️ 2. Backend Core Concepts {#backend-core}

---

### Q: When do you use SQL vs NoSQL?

| Choose SQL (PostgreSQL) When | Choose NoSQL When |
|---|---|
| ACID transactions required (orders, payments) | Massive write throughput (GPS history) |
| Complex joins and aggregations | Flexible/schemaless data |
| Strong consistency non-negotiable | Horizontal scaling is the priority |
| Relationships between entities | Simple key-value or document lookups |
| Audit trail / financial ledger | High availability > consistency |

**Toters examples:**
- **SQL:** Orders, payments, users, restaurants — ACID required
- **NoSQL (Cassandra):** Courier GPS history — millions of writes/hour, no joins needed
- **Redis:** Live courier locations, session data, rate limiting — sub-ms latency needed

---

### Q: How do you design a schema for orders?

```sql
-- Core orders table
CREATE TABLE orders (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES users(id),
  restaurant_id UUID NOT NULL REFERENCES restaurants(id),
  courier_id    UUID REFERENCES couriers(id),
  status        VARCHAR(32) NOT NULL DEFAULT 'pending',
  total_amount  INTEGER NOT NULL,           -- Store in cents/piastres
  currency      CHAR(3) NOT NULL DEFAULT 'EGP',
  idempotency_key VARCHAR(64) UNIQUE,       -- Prevent duplicate submissions
  version       INTEGER NOT NULL DEFAULT 0, -- Optimistic locking
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Order items (separate table, normalized)
CREATE TABLE order_items (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id   UUID NOT NULL REFERENCES orders(id),
  menu_item_id UUID NOT NULL REFERENCES menu_items(id),
  quantity   INTEGER NOT NULL DEFAULT 1,
  unit_price INTEGER NOT NULL,
  notes      TEXT
);

-- Order status history (full audit trail)
CREATE TABLE order_status_events (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id   UUID NOT NULL REFERENCES orders(id),
  from_status VARCHAR(32),
  to_status  VARCHAR(32) NOT NULL,
  actor_id   UUID,         -- who triggered the change
  actor_type VARCHAR(32),  -- 'user', 'courier', 'system'
  reason     TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Key indexes
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_restaurant_id ON orders(restaurant_id);
CREATE INDEX idx_orders_status ON orders(status) WHERE status NOT IN ('delivered', 'cancelled');
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
```

**Why store amounts in integers (cents)?** Floating-point arithmetic is imprecise. `0.1 + 0.2 ≠ 0.3` in most languages. Store `450` piastres, not `4.50` EGP.

---

### Q: How do you handle database scaling?

**Step-by-step scaling ladder:**

```
Step 1: Optimize queries (EXPLAIN ANALYZE, add indexes)
     ↓
Step 2: Connection pooling (PgBouncer — 1000 app threads → 100 DB connections)
     ↓
Step 3: Read replicas (route SELECT queries to replicas, writes to primary)
     ↓
Step 4: Table partitioning (partition orders by created_at monthly)
     ↓
Step 5: Caching layer (Redis — cache hot restaurant menus, user sessions)
     ↓
Step 6: Vertical scaling (bigger DB instance — buys time, not a long-term solution)
     ↓
Step 7: Sharding (partition by user_id % N or region — major complexity increase)
```

**Read replica routing in Rails:**
```ruby
# ApplicationRecord or specific models
connects_to database: { writing: :primary, reading: :replica }

# Explicit routing
ActiveRecord::Base.connected_to(role: :reading) do
  Restaurant.find(id)  # Hits replica
end
```

---

### Q: What is CAP theorem and where does MySQL fit?

**CAP Theorem:** In a distributed system experiencing a network partition (P), you must choose between Consistency (C) and Availability (A). You cannot have both.

| Mode | Meaning | Use Case |
|---|---|---|
| **CP** | Consistent + Partition Tolerant | Refuse writes during partition rather than risk inconsistency |
| **AP** | Available + Partition Tolerant | Accept writes during partition, reconcile later |
| **CA** | Consistent + Available | Only possible with no partitions (single-node, not truly distributed) |

**MySQL / PostgreSQL:** Configured as **CP** in primary-replica setups. During a network partition, the primary stops accepting writes rather than risk split-brain. This is the correct choice for financial data.

**Redis Cluster:** Configurable. Default is **AP** — accepts writes to the available partition.

**Toters application:**
- Payments → CP (never lose a transaction)
- Courier tracking → AP (stale location data is acceptable)
- Flash sale counter → CP (must enforce exact winner count)

---

### Q: How do you handle distributed transactions?

**Option 1: Two-Phase Commit (2PC) — Avoid in most cases**
- All services vote "ready", then coordinator sends "commit"
- Problems: Blocking (coordinator SPOF), high latency, complex failure recovery

**Option 2: Saga Pattern (Preferred)**

*Choreography-based Saga for Order Placement:*
```
1. OrderSvc: Creates order (PENDING) → publishes order.created
2. PaymentSvc: Charges card → publishes payment.completed OR payment.failed
3. If payment.completed → DispatchSvc: Assigns courier → publishes courier.assigned
4. If payment.failed → OrderSvc: Cancels order (compensating transaction)
```

```
Each step:
  Success → publish next event
  Failure → publish compensating event
  Timeout → retry or publish failure event
```

**Option 3: Transactional Outbox (for DB + Kafka consistency)**
```sql
-- In ONE transaction:
INSERT INTO orders (status='pending') VALUES (...);
INSERT INTO outbox_events (type='order.created', published=false) VALUES (...);
COMMIT;

-- Background relay publishes outbox → Kafka
```

---

### Q: Where do you use Redis in this system?

| Use Case | Redis Feature | TTL |
|---|---|---|
| Live courier locations | GeoSet (GEOADD) | No TTL (updated continuously) |
| Flash sale counter | String + INCR | Duration of sale |
| Idempotency keys | String (SET NX EX) | 24 hours |
| Rate limiting | Sorted Set / INCR | Window size |
| Session tokens | String | Session timeout |
| Order status (hot read) | Hash | 1 hour after delivery |
| Restaurant menu cache | Hash | 5 minutes |
| Pub/Sub (live tracking) | Pub/Sub | — |
| Distributed locks | String (SET NX) | Lock timeout |
| OTP codes | String | 5 minutes |

---

### Q: Cache invalidation strategies — When to use which?

**Write-Through:**
```
Write → [App] → DB + Cache simultaneously
Read  → [App] → Cache (always fresh)
```
- ✅ Cache always consistent with DB
- ❌ Every write hits both DB and cache (slower writes)
- **Use when:** Read-heavy, consistency important (restaurant menus)

**Write-Behind (Write-Back):**
```
Write → [App] → Cache immediately → DB asynchronously
```
- ✅ Fast writes
- ❌ Risk of data loss if cache crashes before DB write
- **Use when:** Non-critical high-write data (analytics counters)

**Cache-Aside (Lazy Loading):**
```
Read miss → [App] → DB → populate cache → return
Write → [App] → DB only → invalidate or update cache
```
- ✅ Only caches data that's actually needed
- ❌ First read after invalidation is slow (cache miss)
- **Use when:** Most general-purpose caching (user profiles, order history)

**Read-Through:**
```
Read → Cache → if miss → Cache fetches from DB → returns to App
```
- Similar to cache-aside but the cache handles DB reads transparently
- Used by some managed caching services

---

### Q: How do you prevent cache stampede?

**The problem:** Cache key expires → 1,000 requests simultaneously miss cache → all hit DB simultaneously → DB crashes.

**Solution 1: Distributed Lock (most common)**
```ruby
def fetch_with_lock(key:, ttl:, &generator)
  cached = redis.get(key)
  return JSON.parse(cached) if cached

  # Only one process regenerates the cache
  lock_key = "lock:#{key}"
  if redis.set(lock_key, "1", nx: true, ex: 10)
    value = generator.call
    redis.setex(key, ttl, value.to_json)
    redis.del(lock_key)
    value
  else
    # Another process is regenerating — wait briefly and retry
    sleep(0.1)
    fetch_with_lock(key:, ttl:, &generator)
  end
end
```

**Solution 2: Probabilistic Early Recomputation**
```ruby
# Regenerate cache BEFORE it expires, with increasing probability
def should_recompute?(key, ttl)
  remaining_ttl = redis.ttl(key)
  probability = 1.0 - (remaining_ttl.to_f / ttl)
  rand < probability * 0.1  # 10% base rate
end
```

**Solution 3: Background refresh**
- Cache entries never expire; a background job refreshes them on a schedule
- Application always reads from cache — never cold

---

### Q: Race conditions — Two users ordering last item

**Optimistic Locking (low contention, recommended):**
```sql
-- Step 1: Read current inventory with version
SELECT id, stock, version FROM menu_items WHERE id = $1;
-- Result: { stock: 1, version: 42 }

-- Step 2: Only update if version hasn't changed
UPDATE menu_items
SET stock = stock - 1, version = version + 1
WHERE id = $1
  AND version = 42  -- Optimistic lock check
  AND stock > 0;

-- If 0 rows updated: someone else got it first → return "Sold out"
-- If 1 row updated: success
```

**Pessimistic Locking (high contention, flash sales):**
```sql
BEGIN;
SELECT stock FROM menu_items WHERE id = $1 FOR UPDATE;
-- Row is now locked — other transactions must wait
UPDATE menu_items SET stock = stock - 1 WHERE id = $1 AND stock > 0;
COMMIT;
```

**Redis Lua (best for high-concurrency flash sales):**
```lua
-- Atomic check-and-decrement (no race possible)
local stock = tonumber(redis.call("GET", KEYS[1]) or "0")
if stock > 0 then
  redis.call("DECR", KEYS[1])
  return 1  -- Claimed
end
return 0  -- Out of stock
```

---

### Q: When do you use Kafka vs RabbitMQ?

| Feature | Kafka | RabbitMQ |
|---|---|---|
| **Retention** | Days/weeks (configurable) | Until consumed (default) |
| **Throughput** | Very high (millions/sec) | Moderate (tens of thousands) |
| **Ordering** | Per partition | Per queue |
| **Replay** | ✅ Yes — consumers can re-read | ❌ No — consumed = gone |
| **Consumer groups** | Multiple independent groups read same topic | Competing consumers share a queue |
| **Routing** | Simple (topic + partition) | Flexible (exchanges, routing keys) |
| **Use case** | Event log, analytics, audit trail | Task queues, RPC, complex routing |

**Toters uses Kafka for:**
- Order events (multiple consumers: Loyalty, Analytics, Notifications, Dispatch)
- Courier location history
- Payment events

**RabbitMQ might be used for:**
- Simple background jobs (resize restaurant image)
- RPC-style requests (synchronous-ish async)

---

### Q: What if consumer crashes after processing but before commit?

This is the "at-least-once delivery" problem.

```
1. Consumer reads message from Kafka
2. Consumer processes order (DB write succeeds)
3. Consumer crashes before committing offset to Kafka
4. On restart: Kafka replays the same message
5. Consumer tries to process the same order again
```

**Solution: Idempotent Consumers**
```ruby
def process_order_created(event)
  # Check if we already processed this event
  return if OrderEvent.exists?(kafka_offset: event.offset)

  Order.create!(...)
  OrderEvent.create!(kafka_offset: event.offset, processed_at: Time.now)
  # Kafka offset committed automatically after this method returns
end
```

**Key insight:** The `OrderEvent` record and the `Order` record should be written in the same DB transaction. Either both are written or neither is.

---

## ⚡ 3. Performance & Scaling {#performance}

---

### Q: How do you reduce API latency?

**Checklist, in order of impact:**

1. **Eliminate N+1 queries** — single biggest source of hidden latency
   ```ruby
   # Bad: 1 query for orders + N queries for restaurants
   Order.recent.each { |o| o.restaurant.name }
   
   # Good: 2 queries total
   Order.recent.includes(:restaurant).each { |o| o.restaurant.name }
   ```

2. **Add database indexes** — check `EXPLAIN ANALYZE` for `Seq Scan`
   ```sql
   -- If you query orders by user_id frequently:
   CREATE INDEX CONCURRENTLY idx_orders_user_id ON orders(user_id);
   ```

3. **Cache hot data in Redis** — sub-millisecond vs 10–50ms DB round-trip

4. **Connection pooling** — PgBouncer prevents 50–100ms connection setup on each request

5. **Async non-critical work** — push notifications, loyalty updates → Kafka

6. **Paginate everything** — never return unbounded result sets

7. **Use `select` to fetch only needed columns**
   ```ruby
   # Don't load full objects if you only need IDs
   Order.where(user_id: uid).pluck(:id, :status)
   ```

8. **gRPC for internal services** — binary protocol, 30–50% faster than JSON/REST

---

### Q: How do you handle the N+1 queries problem?

```ruby
# PROBLEM: In a loop, each call to .restaurant triggers a new DB query
orders = Order.where(status: "pending").limit(100)
orders.each do |order|
  puts order.restaurant.name   # N queries!
  puts order.user.email        # N more queries!
end

# SOLUTION 1: eager loading
orders = Order.where(status: "pending")
              .includes(:restaurant, :user)
              .limit(100)

# SOLUTION 2: pluck + batch load
order_ids   = Order.where(status: "pending").pluck(:id, :restaurant_id)
restaurants = Restaurant.where(id: order_ids.map(&:last)).index_by(&:id)
order_ids.each do |order_id, rest_id|
  puts restaurants[rest_id].name
end
```

**Detection:** Use `bullet` gem in development, or look for log lines showing the same query repeating.

---

### Q: Latency spike from 50ms → 2s. What do you do?

**Structured response:**

```
Step 1: MITIGATE (stop the bleeding first)
├── Was there a recent deploy? → Rollback immediately
├── Is CPU/memory at ceiling? → Scale out
└── Is a specific endpoint affected? → Rate limit or disable it

Step 2: ISOLATE (narrow the scope)
├── Is it all users or a subset? (region, user segment)
├── Is it all endpoints or one? (check p99 per endpoint)
└── Is it one downstream service causing the cascade?

Step 3: DIAGNOSE (find root cause)
├── Database: pg_stat_activity for long-running queries / locks
├── Slow query log: queries > 100ms
├── External APIs: Is payment gateway, maps API timing out?
├── Memory: GC pauses, heap pressure?
└── Redis: Hit rate dropped? Evictions?

Step 4: REMEDIATE
└── Add index / fix N+1 / increase cache TTL / enable circuit breaker

Step 5: POST-MORTEM (24–48 hours later)
├── Why didn't our alerts catch this earlier?
├── What's the automated runbook for next time?
└── What monitoring should we add?
```

---

### Q: How do you handle thundering herd problem?

**Definition:** Massive simultaneous load (e.g., 50,000 users hit "order now" at midnight sale launch).

**Solutions:**

1. **Jitter on client requests** — mobile app adds random 0–3s delay before first request
2. **Queue on the server** — put requests in a fast queue (Redis), process at controlled rate
3. **Circuit breaker** — if DB/Redis is overwhelmed, fail fast instead of queueing more requests
4. **Autoscale ahead** — predictive scaling based on expected event time
5. **Cache warming** — pre-populate cache for expected hot data before the event starts
6. **Rate limiting per user** — cap at 1 req/3s per user (users won't notice)

---

## 🧱 4. Microservices & Architecture {#microservices}

---

### Q: Monolith vs Microservices — when and why?

| Start With Monolith When | Move to Microservices When |
|---|---|
| Early stage / MVP | Different services need independent scaling |
| Team < 10 engineers | Team is large (Conway's Law: architecture mirrors org) |
| Domain boundaries unclear | Domain boundaries are well-understood |
| Speed of iteration > operational complexity | Different services need different tech stacks |
| — | Specific service has very different SLAs |

**Toters recommendation:** Staff-level answer is "it depends, but for a system at Toters' scale, a modular monolith first, then extract services that have independent scaling needs (Location Service is the first candidate — it has 10x the write load of everything else)."

---

### Q: REST vs gRPC vs async events — when to use each?

| Protocol | Use For | Example |
|---|---|---|
| **REST** | Public API, mobile clients, third-party integrations | `POST /orders`, `GET /restaurants/:id` |
| **gRPC** | Internal service-to-service, streaming, high-performance | OrderSvc → PaymentSvc |
| **Async events (Kafka)** | Decoupled workflows, fan-out, non-blocking | "Order confirmed" → notify 5 downstream services |
| **WebSockets** | Real-time bidirectional (tracking map) | Courier location → Customer app |
| **SSE** | Server-push only (live status updates) | Order status updates to customer |

---

### Q: How do you handle distributed tracing?

```
Every request gets a trace_id at the API Gateway
Trace ID is propagated in every downstream call:
  - HTTP headers: X-Trace-ID
  - Kafka message headers
  - gRPC metadata
  - Async job metadata

Each service creates a "span" (start time, end time, service name, trace_id)
Spans are sent to a collector (Jaeger / Zipkin / Datadog APM)

Result: full request lifecycle visible across all services
```

**Implementation:**
```ruby
# Rails middleware (or use opentelemetry-ruby gem)
class TracingMiddleware
  def call(env)
    trace_id = env["HTTP_X_TRACE_ID"] || SecureRandom.uuid
    Thread.current[:trace_id] = trace_id

    status, headers, body = @app.call(env)
    headers["X-Trace-ID"] = trace_id
    [status, headers, body]
  end
end
```

---

### Q: How do you manage schema changes across services?

**Golden rules:**
1. **Never break consumers** — additive changes only (add columns, never remove)
2. **Schema registry for Kafka** — Avro + Confluent Schema Registry enforces compatibility
3. **API versioning** — `/v1/orders` and `/v2/orders` can coexist during migration
4. **Expand-Contract pattern:**
   ```
   Phase 1 (Expand): Add new column/field alongside old one
   Phase 2 (Migrate): Backfill data; update consumers to use new field
   Phase 3 (Contract): Remove old column/field once all consumers updated
   ```
5. **Never require all services to deploy simultaneously** — each service deploys independently

---

## ☁️ 5. Cloud / DevOps {#devops}

---

### Q: How would you deploy this system on AWS?

```
[Route 53] → DNS routing
    │
[CloudFront] → CDN, static assets, DDoS protection
    │
[ALB] → Application Load Balancer, SSL termination
    │
[ECS / EKS] → Container orchestration (auto-scaling groups)
    │
┌───┴──────────┐
│ Databases    │
├─ RDS (PostgreSQL Multi-AZ primary)
├─ ElastiCache (Redis Cluster)
├─ MSK (Managed Kafka)
└─ S3 (assets, logs, backups)
    │
[VPC] → Private subnets for databases, public for app tier
```

**Key AWS services for Toters:**
- **ECS / EKS** — container orchestration with auto-scaling
- **RDS Multi-AZ** — automatic failover for PostgreSQL
- **ElastiCache** — managed Redis (handles clustering, failover)
- **MSK** — managed Kafka (Toters' primary event bus)
- **SQS** — dead-letter queues for failed notifications
- **CloudWatch** — logs, metrics, alarms
- **X-Ray** — distributed tracing

---

### Q: Blue/Green vs Canary deployment?

| | Blue/Green | Canary |
|---|---|---|
| **How** | Two full environments; flip traffic instantly | Gradually route % of traffic to new version |
| **Rollback** | Instant (flip back) | Instant (route 0% to canary) |
| **Risk** | Binary — all or nothing | Gradual — catch issues at 1% before 100% |
| **Cost** | Double infrastructure during deploy | Minimal extra cost |
| **Use when** | Major changes, database migrations | Normal releases; want gradual confidence |

**Toters recommendation:** Canary for normal releases. Blue/Green for major database migrations where you need clean rollback capability.

---

### Q: Deployment caused errors → what do you do?

```
1. DETECT:     Alert fires (error rate > 1% for 2 minutes)
2. ASSESS:     Is this affecting payments? (Severity 1) or just analytics? (Severity 3)
3. ROLLBACK:   If Severity 1-2, rollback immediately without investigation
   └── ECS: aws ecs update-service --task-definition previous-version
   └── Kubernetes: kubectl rollout undo deployment/order-service
4. CONFIRM:    Error rate drops → incident resolved
5. INVESTIGATE: Now look at what went wrong (safely, not under fire)
   ├── Diff the deploy: what changed?
   ├── Reproduce locally
   └── Write fix + tests
6. POST-MORTEM: Document timeline, root cause, and prevention measures
```

---

## 🔐 6. Reliability & Fault Tolerance {#reliability}

---

### Q: Circuit Breaker Pattern

**States:**
```
CLOSED (normal)
│ Count failures
│ If failures > threshold → open
▼
OPEN (failing fast)
│ All requests immediately return error
│ After timeout → half-open
▼
HALF-OPEN (testing)
│ Allow 1 probe request
│ Success → CLOSED
│ Failure → OPEN (reset timer)
```

**When to apply at Toters:**

| Service | Threshold | Timeout | Fallback |
|---|---|---|---|
| Payment gateway | 3 failures / 30s | 30s | "Payment temporarily unavailable" |
| ETA service | 5 failures / 10s | 15s | "Arriving soon" (static) |
| Notification service | 10 failures / 60s | 60s | Queue for retry; order still confirmed |
| Redis (cache) | 3 failures / 5s | 10s | Fall through to PostgreSQL |

---

### Q: Retry with backoff — how do you implement it?

```ruby
def with_retry(max_attempts: 3, base_delay: 0.1, retriable_errors: [Net::TimeoutError])
  attempts = 0
  begin
    yield
  rescue *retriable_errors => e
    attempts += 1
    raise e if attempts >= max_attempts

    # Exponential backoff + jitter
    delay = (base_delay * (2 ** attempts)) + rand(0.0..0.1)
    sleep(delay)
    retry
  end
end

# Usage:
with_retry(retriable_errors: [PaymentGateway::Timeout]) do
  PaymentGateway.charge(amount: 100)
end
```

**Retry delays:**
```
Attempt 1: 0.1s + jitter
Attempt 2: 0.2s + jitter
Attempt 3: 0.4s + jitter (max attempts — raise)
```

**Never retry:** Card declined, invalid request, authentication errors (non-transient).

---

### Q: How do you prevent cascading failures?

**Scenario:** Payment gateway is slow → Order service threads block waiting → Order service runs out of threads → API Gateway can't reach Order service → entire platform appears down.

**Prevention layers:**

1. **Timeouts everywhere:** Every external call has an explicit timeout (e.g., 500ms for payment gateway)
2. **Circuit breaker:** After N timeouts, stop calling the gateway; return error immediately
3. **Bulkhead pattern:** Separate thread pools for different dependencies
   ```ruby
   # Payment calls use their own thread pool (max 10 threads)
   # If all 10 are busy → reject new payment requests immediately
   # Other services (unrelated to payments) are unaffected
   payment_pool = Concurrent::ThreadPoolExecutor.new(max_threads: 10)
   ```
4. **Health checks:** Load balancer removes unhealthy app instances before they cascade
5. **Graceful degradation:** Slow ETA service → return static estimate → don't block orders

---

### Q: How do you design graceful degradation?

**Decision tree:**

```
Is the failing service on the critical path of the user's current action?
│
├── YES → Does a reasonable fallback exist?
│         ├── YES → Use fallback (static data, cached value, simplified response)
│         └── NO  → Fail with a clear, helpful error message
│
└── NO  → Degrade silently (log the failure, continue without that service)
```

**Toters examples:**

| Service Down | User Action | Degraded Response |
|---|---|---|
| ETA service | Placing order | Show "30–45 min estimate" instead |
| Recommendation engine | Browsing | Show top 10 popular restaurants |
| Review service | Order confirmed | Hide review section on order page |
| Loyalty service | Order completed | Queue loyalty points; apply when service recovers |
| Notification service | Order confirmed | Order confirms normally; notification queued for retry |

---

## 🧠 7. Staff-Level Leadership {#leadership}

---

### Q: How do you review system design of others?

**Framework — ask these questions in every review:**

1. **Scale:** "What happens when our load triples next quarter?"
2. **Failure modes:** "What's the blast radius if this service goes down at 2am?"
3. **Rollback:** "How do we undo this change if it causes a production issue?"
4. **Observability:** "What metrics tell us this is working correctly?"
5. **Operability:** "What does the runbook look like? Would a junior engineer be able to handle an incident alone?"
6. **Data consistency:** "What happens if we process the same event twice?"
7. **Cost:** "How does cost scale as we grow 10x?"

**What you're NOT doing:**
- Nitpicking implementation details in a design review
- Blocking the design because of your personal technology preferences
- Reviewing for style instead of substance

---

### Q: How do you handle disagreement on architecture?

**Process:**
1. **Understand their reasoning fully** — ask them to explain the trade-offs they're optimizing for
2. **Separate facts from opinions** — "gRPC is faster" (fact, measurable) vs "gRPC is better" (opinion)
3. **Run an experiment if possible** — "Let's prototype both approaches and benchmark them"
4. **Write an RFC** — document both approaches, trade-offs, and let the team weigh in
5. **Accept the decision gracefully** — if overruled, support the decision fully; document your dissent in the RFC for the record

**What you don't do:** Make it personal, block progress indefinitely, or say "I told you so" if their approach has issues later.

---

### Q: How do you grow mid-level → senior engineers?

**The key transition:** From "given a task, executes well" → "given a problem, defines the task, then executes well."

**Concrete actions:**
1. **Pair on problem definition** — before they write any code, sit with them to define "what problem are we actually solving?"
2. **Assign ownership** — let them own a feature end-to-end (design → deploy → monitor). Be available for guidance but don't take the wheel.
3. **Structured code reviews** — give feedback on architectural decisions, not just syntax
4. **Architecture guild participation** — have them present their design to the group; public presentations accelerate growth
5. **Post-mortem ownership** — when their code causes an incident (it will), have them lead the post-mortem. It's the fastest way to learn operational thinking.

---

### Q: How do you deal with an underperforming engineer?

1. **Diagnose first** — is it skill (can't do the work) or will (won't do the work) or environment (blocked, misaligned)?
2. **Have a direct conversation** — don't let it fester. "I've noticed X. Help me understand what's happening."
3. **Set clear, measurable expectations** — "In the next 30 days, I need to see: X, Y, Z"
4. **Provide support** — pair programming, mentorship, remove blockers
5. **Escalate if unchanged** — document everything; involve HR if performance doesn't improve after genuine support

**What you don't do:** Give vague feedback in annual reviews. Address it early, specifically, and humanely.

---

### Q: Tell me about a time you made a bad technical decision

**Template (use a real example, or adapt this):**

> *"We chose MongoDB for order storage early on because the team was familiar with it. Six months later, we needed complex reporting across orders, items, and payments — queries that would be simple JOINs in SQL but required multiple aggregation stages in Mongo. The migration to PostgreSQL took 3 weeks and caused two minor incidents during the cutover.*
>
> *What I learned: choose the database that fits the access patterns of the data, not the team's comfort zone. I now always start design discussions with 'what queries will we run against this data?' before picking a storage technology."*

---

### Q: How do you balance speed vs quality?

**The Two-Door Framework:**

```
REVERSIBLE decision (Two-Way Door) → MOVE FAST
Examples:
  - Cache TTL value
  - Kafka topic name
  - Feature flag default
  → Decide in a day. Iterate based on data.

IRREVERSIBLE decision (One-Way Door) → MOVE CAREFULLY
Examples:
  - Primary database choice
  - Public API contract
  - Encryption/key management
  → Write RFC. Get multiple reviewers. Research thoroughly.
```

**When under deadline pressure for a One-Way Door decision:**
- Make the reversibility explicit in the design ("we'll need to migrate off X in 12 months")
- Document the trade-offs so future teams understand why the decision was made
- Never pretend a One-Way Door is Two-Way just to ship faster

---

## 🔥 8. Real-World Problem Solving {#real-world}

---

### Q: Spike in 500 errors — what do you do?

```
PHASE 1 — MITIGATE (0–5 minutes)
├── Is there a recent deploy? → Rollback immediately
├── Is it CPU/memory pressure? → Scale out
├── Is one server causing it? → Remove from load balancer
└── Can we rate-limit the affected endpoint to reduce blast radius?

PHASE 2 — ISOLATE (5–15 minutes)
├── Which endpoints? (check error rate per endpoint in APM)
├── Which users? (new users, specific region, specific payment method?)
├── Which downstream service? (check trace_ids in logs to find failure point)
└── What's the error message? (check exception tracking — Sentry/Rollbar)

PHASE 3 — DIAGNOSE (15–30 minutes)
├── Database: check pg_stat_activity for locks or long queries
├── Redis: check connection errors, memory usage
├── External APIs: check payment gateway / maps API status pages
├── Code: Did recent deploy change relevant codepath?
└── Infrastructure: Any AWS service health events?

PHASE 4 — REMEDIATE
└── Fix + deploy + verify error rate drops

PHASE 5 — POST-MORTEM (24 hours later)
├── Timeline of events
├── Root cause analysis (5 Whys)
├── What monitoring would have caught this earlier?
└── What runbook would reduce MTTR next time?
```

---

### Q: Would you choose consistency or availability here?

**Framework answer:**

> "It depends on the business impact of each failure mode. Let me reason through it:
>
> **Payments:** I choose consistency. An inconsistent payment record (charging twice or not charging at all) is a financial and legal liability. It's better to return a 503 'Payment temporarily unavailable' than to process a payment in an inconsistent state.
>
> **Courier location tracking:** I choose availability. If two customers briefly see slightly different positions for the same courier, that's acceptable. A stale location is recoverable; a full map service outage is not.
>
> **Flash sale inventory:** I choose consistency. Overselling is worse than occasionally telling a user the sale is temporarily unavailable.
>
> The question to ask is: 'What is the cost of being wrong?' For financial or inventory data, the cost is high → choose consistency. For user experience / informational data, the cost is lower → choose availability."

---

## 🧪 9. Coding Questions {#coding}

---

### Implement a Rate Limiter

**Token Bucket in Redis (production-ready):**
```ruby
class RateLimiter
  def initialize(redis:, limit:, window_seconds:)
    @redis = redis
    @limit = limit
    @window = window_seconds
  end

  # Returns [allowed, remaining_tokens]
  def allow?(identifier)
    key = "rate:#{identifier}"
    result = @redis.eval(LUA_SCRIPT,
                         keys: [key],
                         argv: [@limit, @window, Time.now.to_f])
    [result[0] == 1, result[1].to_i]
  end

  LUA_SCRIPT = <<~LUA
    local key      = KEYS[1]
    local limit    = tonumber(ARGV[1])
    local window   = tonumber(ARGV[2])
    local now      = tonumber(ARGV[3])

    -- Remove expired entries
    redis.call("ZREMRANGEBYSCORE", key, "-inf", now - window)

    local count = redis.call("ZCARD", key)
    if count >= limit then
      return {0, 0}  -- Rejected
    end

    -- Add this request (score = timestamp, member = timestamp+random for uniqueness)
    redis.call("ZADD", key, now, now .. math.random())
    redis.call("EXPIRE", key, window)

    return {1, limit - count - 1}  -- Allowed, tokens remaining
  LUA
end

# Usage
limiter = RateLimiter.new(redis: $redis, limit: 100, window_seconds: 60)
allowed, remaining = limiter.allow?("user:#{user_id}")
return render json: { error: "Rate limit exceeded" }, status: 429 unless allowed
```

---

### Design LRU Cache (O(1) operations)

**Implementation using Ruby Hash (insertion-order preserved since Ruby 1.9):**
```ruby
class LRUCache
  def initialize(capacity)
    @capacity = capacity
    @store = {}  # Maintains insertion order
  end

  def get(key)
    return -1 unless @store.key?(key)
    # Move to end (most recently used)
    value = @store.delete(key)
    @store[key] = value
    value
  end

  def put(key, value)
    if @store.key?(key)
      @store.delete(key)  # Remove to re-insert at end
    elsif @store.size >= @capacity
      @store.shift  # Remove least recently used (first entry)
    end
    @store[key] = value
  end

  def size = @store.size
end

# Test
cache = LRUCache.new(3)
cache.put(:a, 1)  # {a:1}
cache.put(:b, 2)  # {a:1, b:2}
cache.put(:c, 3)  # {a:1, b:2, c:3}
cache.get(:a)     # {b:2, c:3, a:1} → returns 1, moves :a to front
cache.put(:d, 4)  # Evicts :b (LRU) → {c:3, a:1, d:4}
cache.get(:b)     # → -1 (evicted)
```

**Explain in the interview:** The Hash `shift` removes the first-inserted key (LRU). The `delete` + re-insert moves a key to the "most recent" position. Both operations are O(1) in Ruby's Hash implementation.

---

### Handle Concurrent Requests Safely

**Scenario: 1,000 concurrent requests to decrement inventory**

```ruby
# Option 1: Database optimistic locking
def claim_item(item_id:, user_id:)
  ActiveRecord::Base.transaction do
    item = Item.lock("FOR UPDATE").find(item_id)  # Pessimistic lock
    raise "Out of stock" if item.stock <= 0

    item.decrement!(:stock)
    Order.create!(user_id:, item_id:, quantity: 1)
  end
end

# Option 2: Atomic Redis decrement (better for flash sales)
def claim_item_redis(item_id:, user_id:)
  result = redis.eval(<<~LUA, keys: ["item:#{item_id}:stock"], argv: [user_id])
    local stock = tonumber(redis.call("GET", KEYS[1]) or "0")
    if stock <= 0 then return 0 end
    redis.call("DECR", KEYS[1])
    return 1
  LUA

  if result == 1
    # Async: write to DB via Kafka
    kafka.produce({ user_id:, item_id: }, topic: "item.claimed")
    "Success"
  else
    "Out of stock"
  end
end
```

---

## 📊 Quick Reference — Numbers Every Staff Engineer Should Know

| Operation | Latency |
|---|---|
| L1 cache read | ~0.5 ns |
| L2 cache read | ~7 ns |
| RAM read | ~100 ns |
| Redis GET (same datacenter) | ~0.5 ms |
| PostgreSQL simple query (indexed) | ~5–10 ms |
| PostgreSQL query (no index, 1M rows) | ~100–500 ms |
| HTTP request (same region) | ~5–50 ms |
| HTTP request (cross-region) | ~100–300 ms |
| Kafka produce + consume | ~5–10 ms |
| DNS lookup | ~20–100 ms |
| SSD random read | ~0.1 ms |

**Memory rules of thumb:**

| Data | Size |
|---|---|
| Redis string entry | ~50–100 bytes overhead |
| Redis GeoSet entry | ~50 bytes |
| Redis Sorted Set entry | ~65 bytes |
| PostgreSQL row (typical order) | ~200–500 bytes |
| Kafka message overhead | ~70 bytes |
| 1M users in Redis SET | ~50–100 MB |

---

*Toters Staff Engineer Interview — Complete Question Bank*
*Last updated: March 2026*
