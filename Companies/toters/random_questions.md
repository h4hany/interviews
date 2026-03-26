# 🚀 Toters Staff Backend Engineer — Complete Interview Preparation Guide

> **Candidate:** Hany Sayed Ahmed Khalaf
> **Role:** Staff Backend Engineer
> **Company:** Toters (On-demand e-commerce / logistics)
> **Mock Result:** Strong Hire (92%)

---

## 📋 Table of Contents

1. [🗂️ Component Cheat Sheet — When & Why to Use Each](#cheat-sheet)
2. [⚡ Problem 1: Flash Sale Concurrency (25k RPS)](#flash-sale)
3. [🗺️ Problem 2: Real-Time Courier Tracking](#courier-tracking)
4. [🔥 Problem 3: Hot-Zone Order Density Monitor](#hot-zone)
5. [🏗️ Problem 4: Food Delivery Ecosystem Design](#food-delivery)
6. [📈 Scalability & Performance Patterns](#scalability)
7. [🛡️ Reliability & Fault Tolerance](#reliability)
8. [🧠 Staff-Level Leadership](#leadership)
9. [💻 Coding Questions (LRU, Rate Limiter, etc.)](#coding)
10. [❓ Extended Practice Questions with Answers](#practice)

---

## 🗂️ Component Cheat Sheet — When & Why to Use Each {#cheat-sheet}

This is your quick-reference before any system design question. Ask yourself: **"What problem am I solving?"** then pick from this table.

### 🔴 Redis — The Swiss Army Knife

| Use Case | Redis Feature | Why Redis? | When NOT to Use |
|---|---|---|---|
| Flash sale counter | `INCR` + Lua Script | Atomic, 100k+ ops/sec, sub-ms | When you need durability without AOF |
| Idempotency check | `SETNX` / `SET NX EX` | Atomic set-if-not-exists with TTL | Long-lived records (use DB instead) |
| Live courier location | `GEOADD` / `GEODIST` | Built-in geospatial, O(log N) | Historical data (use TimescaleDB) |
| Rate limiting | `INCR` + `EXPIRE` | Simple token bucket in 2 commands | Complex rate rules (use dedicated lib) |
| Session management | `SET` with TTL | Fast lookup, auto-expiry | Sensitive PII (use encrypted store) |
| Pub/Sub fan-out | `PUBLISH` / `SUBSCRIBE` | Low latency broadcast | Guaranteed delivery (use Kafka) |
| Sliding window counter | Sorted Sets (`ZADD`, `ZRANGEBYSCORE`) | Range queries by score/time | Very high cardinality (use HyperLogLog) |
| Cache stampede prevention | `SET NX` distributed lock | Only one thread rebuilds cache | — |

**🔑 Key Principle:** Redis is your **synchronous decision layer**. Use it when you need an *immediate* answer (win/lose, rate limit hit/pass). Do NOT use it as your primary database of record.

---

### 🟡 Kafka — The Durable Event Bus

| Use Case | Why Kafka? | When NOT to Use |
|---|---|---|
| Async DB writes after Redis decision | Durable, replayable, decoupled | When you need <10ms latency end-to-end |
| Fan-out to multiple consumers (notifications, analytics, loyalty) | One producer → many consumer groups | Simple job queue (use Sidekiq/Redis) |
| Event sourcing / audit trail | Immutable log, configurable retention | Tiny teams / simple workloads |
| Cross-service communication (Order → Dispatch → Payment) | Loose coupling, retry built-in | Request-response patterns (use gRPC) |
| Backpressure buffer during traffic spikes | Absorbs load, consumers catch up | When consumer lag is unacceptable |

**🔑 Key Principle:** Kafka is your **async reliability backbone**. Use it when the producer and consumer can tolerate some latency and you need guaranteed delivery + replay.

---

### 🟢 PostgreSQL / MySQL — The Source of Truth

| Use Case | Why SQL? | When NOT to Use |
|---|---|---|
| Orders, payments, users | ACID compliance, foreign keys | High-write time-series (use Cassandra) |
| Complex reporting / analytics | Joins, window functions, CTEs | Sub-10ms hot reads (add Redis cache) |
| Financial ledgers | Transactions, rollback support | Unstructured or schemaless data |
| Audit history | Temporal tables, point-in-time queries | 1M+ writes/sec (will bottleneck) |

**🔑 Key Principle:** PostgreSQL is your **durable source of truth**. It's almost never on the critical path for high-traffic writes — let Redis or Kafka absorb the spike first.

---

### 🔵 Cassandra / DynamoDB — The Horizontal Write Machine

| Use Case | Why NoSQL? | When NOT to Use |
|---|---|---|
| GPS coordinate history (billions of rows) | Massive write throughput, scales horizontally | Complex joins or transactions |
| Notification / event logs | High insert rate, simple lookup by key | You need SQL-style aggregations |
| Driver location history | Time-series with partition by driver ID | Consistency is critical (eventual only) |
| Feature flags at scale | Key-value lookup, globally distributed | Small datasets (overkill) |

---

### 🟣 Kafka Streams / TimescaleDB — Time-Series Analytics

| Use Case | Why? |
|---|---|
| Order density per zone per minute | Continuous aggregation, retention policies |
| Courier speed / ETA calculations | Time-bucketed queries, rollups |
| SLO monitoring (p99 latency over time) | Purpose-built for time-series workloads |

---

### ⚡ gRPC vs REST vs WebSockets — Communication Layer

| Protocol | Use When | Avoid When |
|---|---|---|
| **gRPC** | Internal service-to-service, need streaming, binary efficiency | Public APIs (tooling/debugging harder) |
| **REST** | Public API, simple CRUD, broad client compatibility | Real-time bidirectional communication |
| **WebSockets** | Live map updates, chat, real-time dashboards | One-off request-response |
| **SSE** | Server pushes only (courier location to customer) | Client also needs to send data |

---

### 🔧 Circuit Breaker vs Retry vs Rate Limiter

| Tool | Purpose | Example |
|---|---|---|
| **Circuit Breaker** | Stop hammering a failing dependency | If Redis fails 5x, open breaker, return "Unavailable" for 30s |
| **Retry with Backoff** | Handle transient failures | Payment API timeout → retry after 100ms, 200ms, 400ms |
| **Rate Limiter** | Protect your service from abuse | Max 100 req/sec per user IP |
| **Bulkhead** | Isolate failure domains | Separate thread pools for Payments and Tracking |

---

## ⚡ Problem 1: Flash Sale Concurrency (25k RPS) {#flash-sale}

### 🎯 The Scenario

> **"The first 1,000 users to click a button get a 50% discount. 50,000 users click within 3 seconds."**

**Constraints:**
- Exactly 1,000 winners — no more, no less
- One win per user (idempotency)
- Immediate synchronous response: "You won!" or "Sold out"
- 25,000–150,000 RPS

---

### ❌ Wrong Approaches (And Why)

**Wrong: Use a Message Queue (Kafka/RabbitMQ) to buffer**

```
User → API → Kafka → Worker → DB → "You won!"
                                    ^
                           (seconds later)
```

**Why it fails:** The user needs an *immediate* answer. If you queue them and process async, you cannot guarantee exactly 1,000 winners — you might process 1,200 before the consumer catches up and enforces the limit.

**Wrong: Check-then-act in application code**

```ruby
# RACE CONDITION — Two threads can both read "999" simultaneously
current = redis.get("promo:counter")  # Thread A reads 999
current = redis.get("promo:counter")  # Thread B reads 999 (same time!)
if current.to_i < 1000
  redis.incr("promo:counter")  # Both increment → counter = 1001!
end
```

**Why it fails:** Non-atomic. Any distributed system with 2+ app servers will over-subscribe.

---

### ✅ Correct Architecture

```
User Request
     │
     ▼
API Gateway (Rate Limit: 100k req/sec max per IP)
     │
     ▼
App Server (stateless, horizontally scaled)
     │
     ▼
Redis Lua Script (ATOMIC — single source of truth)
  ├── Already claimed? → Return ALREADY_CLAIMED
  ├── Counter ≥ 1000? → Return SOLD_OUT
  └── Counter < 1000? → INCR counter + mark user + XADD stream → Return SUCCESS
     │
     ▼ (async, off critical path)
Redis Stream Consumer → Kafka → PostgreSQL (persist winners)
```

---

### ✅ The Optimized Lua Script (Full Production Version)

```lua
-- KEYS[1] = promo:{promoId}:counter
-- KEYS[2] = promo:{promoId}:users   (Redis SET for O(1) membership check)
-- KEYS[3] = promo:{promoId}:stream  (Redis Stream for durable event log)
-- ARGV[1] = user_id
-- ARGV[2] = max_winners (e.g., "1000")

local counter_key  = KEYS[1]
local users_key    = KEYS[2]
local stream_key   = KEYS[3]
local user_id      = ARGV[1]
local max_winners  = tonumber(ARGV[2])

-- Step 1: Idempotency — has this user already claimed?
if redis.call("SISMEMBER", users_key, user_id) == 1 then
  return {2, "ALREADY_CLAIMED"}
end

-- Step 2: Is inventory still available?
local current = tonumber(redis.call("GET", counter_key) or "0")
if current >= max_winners then
  return {0, "SOLD_OUT"}
end

-- Step 3: Atomically claim the slot
redis.call("INCR", counter_key)
redis.call("SADD", users_key, user_id)

-- Step 4: Transactional Outbox — write to stream BEFORE returning
-- If app server crashes after this line, the worker still sees the event
redis.call("XADD", stream_key, "*",
  "user_id", user_id,
  "status", "SUCCESS",
  "slot", tostring(current + 1)
)

return {1, "SUCCESS"}
```

**Result mapping in Ruby:**
```ruby
result, message = redis.eval(lua_script, keys: [...], argv: [...])
case result
when 1 then render json: { status: "SUCCESS", message: "You won! 🎉" }
when 2 then render json: { status: "ALREADY_CLAIMED", message: "You already claimed this offer." }
when 0 then render json: { status: "SOLD_OUT", message: "Offer is no longer available." }
end
```

---

### 🔑 Why the Lua Script Solves "Ghost Success"

**The Bug Without XADD in Lua:**
```
1. Lua returns SUCCESS ✓
2. App server crashes 💥
3. User sees "You won!" (in-flight response delivered)
4. No event in Kafka → no DB write
5. User shows up to claim prize → records say they didn't win
```

**The Fix With XADD Inside Lua:**
```
1. Lua atomically: INCR + SADD + XADD ✓
2. App server crashes 💥
3. Redis Stream has the event permanently
4. Worker picks it up on next poll → writes to DB ✓
5. Everything consistent
```

---

### 🔧 Redis Cluster Gotcha

When using Redis Cluster, Lua scripts **must operate on keys in the same hash slot**.

```ruby
# ❌ WRONG — keys might land on different cluster nodes
promo_key  = "promo:#{promo_id}:counter"
user_key   = "promo:#{promo_id}:users"

# ✅ CORRECT — Hash tags {} force same slot
promo_key  = "promo:{#{promo_id}}:counter"
user_key   = "promo:{#{promo_id}}:users"
stream_key = "promo:{#{promo_id}}:stream"
```

---

### 📊 Scale Estimation

| Metric | Calculation | Result |
|---|---|---|
| Peak RPS | 50,000 users / 3 seconds | ~16,700 RPS |
| Redis capacity | Standard Redis | 100,000+ ops/sec |
| Redis memory for 1M users | ~50 bytes/entry in SET | ~50 MB |
| Winner records in PostgreSQL | 1,000 rows × 200 bytes | ~200 KB |

---

### 🧪 Extended Practice Questions

**Q: What if Redis goes down mid-promotion?**

> **Answer:** Apply the **Fail Fast** principle. Do NOT queue requests for later. If the source of truth is unavailable, you cannot guarantee the 1,000 limit. Return `503 Promotion Temporarily Unavailable`. Better to disappoint users than to over-promise and hand out 50,000 discounts you can't afford.
>
> Implementation: Circuit Breaker around the Redis call. After 3 consecutive failures, open the breaker for 30 seconds, returning errors immediately without hammering Redis.

**Q: How would you handle the same promotion running in 5 cities simultaneously?**

> **Answer:** Namespace by city. Each city gets its own Redis keys: `promo:{promo-123:cairo}:counter`. This also enables running per-city limits (Cairo gets 200, Beirut gets 100, etc.) and keeps keys in the same Redis cluster region for low latency.

**Q: A user claims "the system said I won but now it says sold out." How do you debug this?**

> **Answer:** Check the Redis Stream for that user_id. If `XRANGE promo:{id}:stream - +` shows their entry with `status=SUCCESS`, they won and there's a bug in the async worker. If their entry isn't there, the Lua script returned an incorrect result (very unlikely if implemented correctly). Distributed tracing (OpenTelemetry trace_id) would let you replay the exact request path.

**Q: How do you handle promotions with different limits (500 for VIP, 1000 for regular users)?**

> **Answer:** Pass the limit as `ARGV[2]` to the Lua script (already done above). Maintain two separate counters with separate keys: `promo:{id}:vip:counter` and `promo:{id}:regular:counter`. The tier check happens in application code before calling the Lua script.

---

## 🗺️ Problem 2: Real-Time Courier Tracking {#courier-tracking}

### 🎯 The Scenario

> **"Design a system to track 15,000 active couriers and display their location to 100,000 concurrent customers."**

---

### 📐 Scale Estimation (Do This First in Interview)

| Metric | Calculation | Result |
|---|---|---|
| Write throughput | 15,000 couriers × 1 ping/5s | **3,000 WPS** |
| Read throughput (polling) | 100,000 users × 1 poll/5s | **20,000 RPS** |
| WebSocket fan-out | 3,000 events/sec × avg 1.5 subscribers | **~4,500 pushes/sec** |
| Storage (raw GPS) | 100 bytes/ping × 3,000/sec × 86,400 sec | **~26 GB/day** |
| Redis memory for live locations | 15,000 couriers × 200 bytes | **~3 MB** (trivial) |

---

### ✅ Architecture

```
                    WRITE PATH (Courier App)
                          │
               [Mobile App — sends ping every 5s]
                          │ WebSocket / gRPC
                          ▼
              [Location Service — Go/Node.js]
                     /         \
                    /           \
         [Redis GEOADD]    [Kafka Producer]
          (Hot path:         (Cold path:
          last known          async persist)
          location)               │
                                  ▼
                         [Kafka Consumer]
                                  │
                         [TimescaleDB / Cassandra]
                          (historical route audit)

                    READ PATH (Customer App)
                          │
               [Customer opens order map]
                          │ WebSocket connection
                          ▼
              [Tracking Service]
                          │
                   [Subscribe to Redis Pub/Sub
                    channel: courier:{courier_id}]
                          │
                   [Push on location change]
```

---

### 🔑 The Hot Path — Redis Geospatial

```ruby
# Courier sends GPS ping
def update_courier_location(courier_id:, lat:, lng:, timestamp:)
  # Store last known location — O(log N) 
  redis.geoadd("couriers:live", lng, lat, courier_id)
  
  # Broadcast to subscribers
  payload = { courier_id: courier_id, lat: lat, lng: lng, ts: timestamp }.to_json
  redis.publish("courier:#{courier_id}", payload)
  
  # Async: publish to Kafka for persistence
  kafka_producer.produce(payload, topic: "courier-locations")
end

# Find all couriers within 2km of a restaurant
def couriers_near(lat:, lng:, radius_km: 2)
  redis.georadius("couriers:live", lng, lat, radius_km, "km",
                  "WITHCOORD", "WITHDIST", "ASC", "COUNT", 10)
end
```

---

### 🔧 Handling Edge Cases

**Dead zones (tunnels, basements):**
- Mobile app buffers pings locally with timestamps
- On reconnect, sends batch: `[{lat, lng, ts: T-15}, {lat, lng, ts: T-10}, ...]`
- Backend validates timestamps — only apply if `ts > current_stored_ts`

**Out-of-order GPS pings:**
```lua
-- Lua script: only update if incoming timestamp is newer
local stored_ts = tonumber(redis.call("HGET", "courier:" .. ARGV[1], "ts") or "0")
if tonumber(ARGV[3]) > stored_ts then
  redis.call("GEOADD", "couriers:live", ARGV[2], ARGV[1], ARGV[4])  -- lng, lat, id
  redis.call("HSET", "courier:" .. ARGV[1], "ts", ARGV[3])
  return 1  -- Updated
end
return 0  -- Stale, ignored
```

**Battery optimization (Adaptive Pinging):**
```
Courier is stationary (accelerometer delta < 0.1) → ping every 30s
Courier moving < 20 km/h → ping every 5s  
Courier moving > 20 km/h → ping every 3s (smooth animation for customer)
```

**The Reconnect Storm (100k clients reconnect after server restart):**
```
Problem: All 100k clients reconnect simultaneously, hitting DB for auth
Solution: 
  1. Use stateless JWT (no DB lookup for auth)
  2. Exponential backoff with jitter on client
     reconnect_delay = min(30s, base_delay × 2^attempt) + random(0, 1000ms)
  3. Stagger reconnections → load spreads over ~2 minutes
```

---

### 🌍 Geofencing — The "Staff Level" Addition

```ruby
# Automatically trigger "Food is arriving!" without courier clicking anything
def check_geofences(courier_id:, lat:, lng:)
  active_orders = Order.where(courier_id: courier_id, status: "in_transit")
  
  active_orders.each do |order|
    distance = haversine(lat, lng, order.delivery_lat, order.delivery_lng)
    
    if distance <= 50  # meters
      order.update!(status: "arriving")
      PushNotificationJob.perform_async(order.customer_id, "Your order is arriving!")
    end
    
    if distance <= 10
      order.update!(status: "delivered")
    end
  end
end
```

**Optimization:** Don't run geofence checks on every ping. Use a **Spatial Index (R-Tree)** to quickly discard irrelevant zones before expensive distance calculations.

---

### 🌐 Regional Scaling (10x: 5 cities)

```
Problem: 5 cities = 75,000 active couriers

Solution: Regional Redis Clusters + Geographic Sharding

Cairo Traffic → Egypt Redis Cluster (AWS Cairo region)
Beirut Traffic → Lebanon Redis Cluster (AWS Bahrain region)

Cross-region queries (rare, e.g., cross-border courier) → 
  Route through Global Load Balancer → 
  Query both clusters → merge results
```

---

### 🧪 Extended Practice Questions

**Q: A customer complains the map shows the courier going backwards. What happened?**

> **Answer:** Out-of-order GPS delivery. The mobile app sent pings in order, but network conditions caused a delayed packet to arrive after a newer one. Fix: timestamp-based Compare-and-Set (the Lua script above). Also add client-side smoothing — never render a location that's geographically impossible given elapsed time.

**Q: How do you handle 10x sudden load (a big marketing campaign)?**

> **Answer:**
> 1. **Horizontal scaling** of the Location Service (stateless, add nodes behind load balancer)
> 2. **Redis cluster autoscaling** — pre-scale Redis before the campaign
> 3. **Reduce ping frequency** — degrade gracefully: 5s → 10s pings under extreme load, customers barely notice
> 4. **Circuit breaker** on Kafka producer — if Kafka is backed up, Location Service still updates Redis (hot path) and drops the cold path temporarily

**Q: How would you implement "Driver is stuck in traffic" ETA updates?**

> **Answer:** Calculate speed from consecutive GPS pings: `speed = distance(ping_n, ping_{n-1}) / time_delta`. If speed < 5 km/h for > 2 minutes AND courier is on a road segment, trigger "Traffic delay" event. Push updated ETA to customer via existing WebSocket connection. ETA calculation uses a routing API (Google Maps / HERE) with current traffic data.

---

## 🔥 Problem 3: Hot-Zone Order Density Monitor {#hot-zone}

### 🎯 The Scenario

> **"Build a system to track how many orders are placed per geographic zone in a 1-hour sliding window. 15,000 RPS average, 150,000 RPS peak."**

**API surface:**
```
recordOrder(orderId, zoneId, timestamp)
getHotZoneLoad(zoneId, windowSeconds)
```

---

### 📐 Scale Estimation

| Metric | Value |
|---|---|
| Zones per city | 75–100 |
| Write rate (avg) | 15,000 RPS |
| Write rate (peak) | 150,000 RPS |
| Read latency target | < 100ms |
| Window size | 3,600 seconds (1 hour) |
| Keys per zone (naive) | 3,600 (one per second) |

---

### ❌ Naive Approach: Store Raw Events

```
redis.rpush("zone:#{zone_id}:events", {order_id:, timestamp:}.to_json)
```

**Why it fails:**
- O(N) scan to count events in a 1-hour window with 15,000 events/sec = 54M events per hour per zone
- Memory: 54M × 100 bytes = 5.4 GB for one zone alone

---

### ✅ The "Bucketed Counter" Approach

```
Key format: zone:{zoneId}:{shardId}:{unix_second}
Value: integer count
TTL: 3601 seconds (1 hour + 1 second buffer)
```

```ruby
def record_order(order_id:, zone_id:, timestamp:)
  second_bucket = timestamp.to_i  # truncate to second
  shard_id = Digest::MD5.hexdigest(order_id)[0..1].to_i(16) % NUM_SHARDS
  
  key = "zone:{#{zone_id}}:#{shard_id}:#{second_bucket}"
  redis.multi do |tx|
    tx.incr(key)
    tx.expire(key, 3601)
  end
end

def get_hot_zone_load(zone_id:, window_seconds: 3600)
  now = Time.now.to_i
  start_second = now - window_seconds
  
  total = 0
  (start_second..now).each do |second|
    NUM_SHARDS.times do |shard|
      key = "zone:{#{zone_id}}:#{shard}:#{second}"
      total += redis.get(key).to_i
    end
  end
  total
end
```

**Complexity improvement:** O(N events) → O(W × shards) where W = window size in seconds

---

### 🔥 The "Hot Key" Problem and Solution

**Problem:** If zone "Downtown Cairo" is extremely popular, all writes to `zone:{downtown}:counter` hit the same Redis node → CPU bottleneck.

**Solution: Key Striping**

```
Instead of: zone:{cairo-central}:0:1700000000
Use:        zone:{cairo-central}:0:1700000000  ← shard 0
            zone:{cairo-central}:1:1700000000  ← shard 1
            zone:{cairo-central}:2:1700000000  ← shard 2
            ...
            zone:{cairo-central}:N:1700000000  ← shard N

Write: hash(order_id) % N → pick shard
Read: sum all N shards
```

**Why it works:** Writes are distributed across N Redis CPU cores. Reads aggregate N values — more work at read time, but reads are rarer than writes and Redis pipeline makes it fast.

---

### 🔑 Lua Script for Atomic Read (Avoid N Round-Trips)

```lua
-- KEYS: all keys to sum
-- Returns: sum of all counters
local total = 0
for i, key in ipairs(KEYS) do
  total = total + tonumber(redis.call("GET", key) or "0")
end
return total
```

This executes server-side — fetches and sums all 3,600 × N shard keys in one network round-trip.

---

### ⚡ The Lambda Architecture (Cold Path)

```
Orders → Kafka → 
  ├── Hot Path: Redis Lua INCR (real-time, 1-hour window)
  └── Cold Path: TimescaleDB (historical analytics, unlimited retention)
                     ↑
              Workers consume from Kafka,
              batch-insert every 5 seconds
              for throughput efficiency
```

**Recovery scenario:** If Redis restarts, seed it from TimescaleDB:
```sql
SELECT zone_id, COUNT(*) as order_count
FROM orders
WHERE timestamp > NOW() - INTERVAL '1 hour'
GROUP BY zone_id, DATE_TRUNC('second', timestamp);
```

---

### 🧪 Extended Practice Questions

**Q: How do you prevent "stale" data from corrupting real-time metrics? (Kafka Consumer Lag)**

> **Answer:** Event Time Validation. When the Kafka consumer processes an event, check: `current_time - event.timestamp`. If the lag exceeds the window size (3,600 seconds), discard the event — it's too old to count in the current window. Alert on consumer lag exceeding 60 seconds; that's when accuracy starts degrading.

**Q: How would you push Hot Zone updates to the Ops Dashboard?**

> **Answer:** Use Server-Sent Events (SSE) — the server pushes zone updates, no client-to-server data needed. Every 10 seconds, a background job queries `getHotZoneLoad` for all zones, diffs against previous state, and pushes only changed zones to subscribed dashboard clients. If the dashboard needs bidirectional interaction (filter zones, zoom map), upgrade to WebSockets.

**Q: How does this change for 100 cities globally?**

> **Answer:**
> 1. **Regional Redis clusters** — Cairo zones on Egypt cluster, Dubai zones on Gulf cluster
> 2. **Zone ID namespacing** — `zone:{city_id}:{zone_id}` ensures no key collision
> 3. **Global aggregation** (cross-city dashboard) — dedicate a separate aggregation service that queries each regional cluster periodically and stores city-level summaries in a global Redis or PostgreSQL
> 4. **Write locality** — never write Cairo data to a Dubai cluster; route by city

---

## 🏗️ Problem 4: Food Delivery Ecosystem Design {#food-delivery}

### 🎯 The Scenario

> **"Design the backend for Toters — order management, restaurant catalog, courier dispatch, payments."**

---

### 🗂️ Domain Decomposition (Microservices)

```
┌─────────────────────────────────────────────────────┐
│                   API Gateway                        │
│          (Auth, Rate Limiting, Routing)              │
└──────┬──────────┬──────────┬──────────┬─────────────┘
       │          │          │          │
       ▼          ▼          ▼          ▼
  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
  │ Order  │ │Catalog │ │Courier │ │Payment │
  │Service │ │Service │ │Dispatch│ │Service │
  └────┬───┘ └────────┘ └───┬────┘ └────────┘
       │                     │
       └─────────┬───────────┘
                 ▼
           [Kafka Topics]
    ├── order.created
    ├── order.status_changed
    ├── courier.assigned
    ├── payment.completed
    └── notification.requested
                 │
       ┌─────────┼─────────┐
       ▼         ▼         ▼
  [Loyalty]  [Analytics] [Notification]
  [Service]  [Service]   [Service]
```

---

### 📦 Order State Machine

```
PENDING → PAYMENT_PROCESSING → CONFIRMED → PREPARING → 
READY_FOR_PICKUP → IN_TRANSIT → DELIVERED

         OR

PENDING → PAYMENT_FAILED (terminal)
CONFIRMED → CANCELLED (if restaurant rejects)
IN_TRANSIT → DELIVERY_FAILED (terminal)
```

**Implementation:**
```ruby
class Order
  VALID_TRANSITIONS = {
    "pending"             => ["payment_processing"],
    "payment_processing"  => ["confirmed", "payment_failed"],
    "confirmed"           => ["preparing", "cancelled"],
    "preparing"           => ["ready_for_pickup"],
    "ready_for_pickup"    => ["in_transit"],
    "in_transit"          => ["delivered", "delivery_failed"],
  }.freeze

  def transition_to!(new_status)
    allowed = VALID_TRANSITIONS[status] || []
    raise InvalidTransition unless allowed.include?(new_status)
    
    update!(status: new_status, updated_at: Time.now)
    kafka.produce({ order_id: id, from: status, to: new_status }, 
                  topic: "order.status_changed")
  end
end
```

---

### 💳 Idempotent Payments

```ruby
# Client generates UUID before hitting "Pay" button
# Stored client-side and resent on retry

POST /v1/payments
{
  "idempotency_key": "550e8400-e29b-41d4-a716-446655440000",
  "order_id": "ord_123",
  "amount": 4500,
  "currency": "EGP"
}
```

```ruby
def process_payment(idempotency_key:, order_id:, amount:)
  # Check for existing result (in Redis with 24h TTL)
  cached = redis.get("idem:#{idempotency_key}")
  return JSON.parse(cached) if cached
  
  # Process payment
  result = payment_gateway.charge(order_id: order_id, amount: amount)
  
  # Cache result — future retries return same response
  redis.setex("idem:#{idempotency_key}", 86400, result.to_json)
  
  result
end
```

---

### 🚗 Courier Dispatch Algorithm

```ruby
def dispatch_courier(order:)
  restaurant = Restaurant.find(order.restaurant_id)
  
  # Find available couriers near restaurant (within 3km)
  candidates = redis.georadius(
    "couriers:available",
    restaurant.lng, restaurant.lat,
    3, "km",
    "WITHCOORD", "WITHDIST", "ASC", "COUNT", 5
  )
  
  # Score each candidate
  best_courier = candidates.min_by do |courier_id, distance, _coords|
    courier = Courier.find(courier_id)
    score = distance * 0.6                    # Distance weight
    score += courier.active_orders.count * 2  # Penalize busy couriers
    score += courier.avg_rating < 4.0 ? 1 : 0 # Penalize low-rated couriers
    score
  end
  
  assign_courier(order: order, courier_id: best_courier.first)
end
```

---

### 🧪 Extended Practice Questions

**Q: The restaurant app is slow — meals are marked "Ready" 10 minutes late. How do you solve this?**

> **Answer (Product-Driven Engineering):** Don't rely on restaurant staff clicking buttons. Instead:
> 1. **ML prediction** — train a model on historical prep times per restaurant, cuisine type, order size. Auto-advance status at T+predicted_prep_time
> 2. **IoT integration** — smart order-receipt printers that auto-accept orders
> 3. **Incentive alignment** — show restaurant a "Courier waiting cost" metric to motivate faster updates

**Q: How do you handle the "Cold Food" problem with order batching?**

> **Answer:** Thermal Decay Batching. Before grouping two orders for one courier, calculate: `total_trip_time = prep_time_remaining + distance(restaurant → customer_A) + distance(customer_A → customer_B)`. If `total_trip_time` for the first customer > threshold (e.g., 45 minutes), do NOT batch. Also track insulated bag usage — couriers with thermal bags get priority for batching.

**Q: Distributed transaction: Payment succeeded but Order Service crashes before confirming. How do you handle it?**

> **Answer:** Transactional Outbox Pattern.
> ```
> BEGIN TRANSACTION
>   INSERT INTO orders (status = 'payment_processing')
>   INSERT INTO outbox_events (type='payment.initiate', payload={...})
> COMMIT
>
> Background relay process:
>   SELECT * FROM outbox_events WHERE published = false
>   → publish to Kafka
>   → mark published = true
> ```
> Even if the Order Service crashes, the outbox entry survives in the DB. On restart, the relay sends the event to Kafka, and Payment Service is idempotent (won't double-charge due to idempotency key).

---

## 📈 Scalability & Performance Patterns {#scalability}

### 🔴 Database Scaling Ladder

```
Level 1: Single PostgreSQL instance (< 1k RPS)
   │
Level 2: Add Redis cache (cache-aside) (< 10k RPS)
   │
Level 3: Read Replicas (scale reads independently) (< 50k RPS)
   │
Level 4: Connection pooling (PgBouncer) — prevent connection exhaustion
   │
Level 5: Table partitioning (partition orders by created_at monthly)
   │
Level 6: Shard by customer_id or region (> 100k RPS)
```

### 🟡 Incident Response Playbook (50ms → 2s latency)

```
Step 1: MITIGATE (don't investigate yet)
  → Check deploys: Was there a recent deployment? Rollback if yes.
  → Check autoscaling: Is CPU at 100%? Scale up.
  
Step 2: ISOLATE  
  → Look at p99 latency per service (Datadog/Grafana)
  → Is it one endpoint or all? One service or all?
  
Step 3: DIAGNOSE
  → Database: EXPLAIN ANALYZE slow queries, check pg_stat_activity for locks
  → External APIs: Is payment gateway timeout spiking?
  → Memory: GC pauses? Check heap usage
  
Step 4: REMEDIATE
  → DB query: Add index, add query timeout, paginate
  → External API: Enable circuit breaker, return cached/static response
  → Memory: Tune GC, reduce object allocations
  
Step 5: POST-MORTEM
  → What monitoring should have caught this earlier?
  → What automated runbook would reduce MTTR next time?
```

### Cache Invalidation Strategies

| Strategy | When to Use | Trade-off |
|---|---|---|
| **Write-through** | High read consistency needed | Slower writes (write to cache + DB) |
| **Cache-aside (Lazy)** | Read-heavy, cache miss acceptable | Stale data possible; stampede risk |
| **Write-behind** | High write throughput needed | Risk of data loss if cache crashes |
| **Time-based TTL** | Data changes predictably | Stale window = TTL duration |
| **Event-driven invalidation** | Near-real-time consistency | More complex (need event bus) |

---

## 🛡️ Reliability & Fault Tolerance {#reliability}

### Circuit Breaker State Machine

```
          [CLOSED] ← success threshold met
          ↓ N failures
          [OPEN] → fail fast, return error immediately
          ↓ timeout (e.g., 30s)
          [HALF-OPEN] → allow 1 test request
          ↓ if success → CLOSED
          ↓ if failure → OPEN
```

```ruby
class CircuitBreaker
  FAILURE_THRESHOLD = 5
  TIMEOUT = 30.seconds
  
  def call(&block)
    case state
    when :open
      raise CircuitOpenError, "Service unavailable" if Time.now < open_until
      self.state = :half_open
    when :half_open, :closed
      begin
        result = block.call
        reset! if state == :half_open
        result
      rescue => e
        record_failure!
        raise
      end
    end
  end
end
```

### Graceful Degradation Examples

| Service Down | Graceful Response |
|---|---|
| ETA Service | Show "Arriving soon" instead of specific time |
| Recommendation Engine | Show top 10 most popular restaurants |
| Redis (cache) | Fall through to PostgreSQL (slower, still works) |
| Redis (flash sale) | Return 503 "Temporarily Unavailable" |
| Kafka | Write to DB outbox, Kafka relay catches up later |
| Payment Gateway | Show "Payment processing…" with retry button |

---

## 🧠 Staff-Level Leadership {#leadership}

### STAR Story Templates

#### Handling Ambiguity
> **Situation:** Tasked with building an AI recommendation engine with no requirements.
> **Task:** Define scope, select tech, deliver in 6 weeks.
> **Action:** Ran discovery sprint. Embedded with product team. Evaluated pgvector vs. dedicated vector DBs. Chose pgvector for iteration speed. Built A/B test framework to measure lift.
> **Result:** 22% increase in click-through rate. Documented architecture RFC for team.

#### Technical Disagreement
> **Situation:** Team wanted to rewrite Order Service in Go for performance.
> **Task:** Evaluate and recommend.
> **Action:** Profiled the service. Found bottleneck was PostgreSQL N+1 queries, not Ruby speed. Proposed targeted optimization instead of rewrite.
> **Result:** p99 latency dropped from 800ms to 120ms without a rewrite. Saved 3 months of engineering time.

#### Mentorship
> **Situation:** Senior engineer was good at execution but avoided defining problem scope.
> **Task:** Help them grow to Staff level.
> **Action:** Started pairing on "problem definition" sessions before any implementation. Introduced RFC process. Had them lead one architecture guild session per month.
> **Result:** Within 6 months they were independently scoping cross-team projects.

### Reviewing Architecture as a Staff Engineer

Ask these questions in every design review:
1. **"What happens when load triples?"** — forces scalability thinking
2. **"How do we roll this back if it fails?"** — forces operational thinking
3. **"What's the blast radius if this service goes down?"** — forces isolation thinking
4. **"What does the runbook look like for a 3am incident?"** — forces on-call thinking
5. **"What metric tells us this is working?"** — forces observability thinking

### Speed vs. Quality: The Two-Door Framework

```
Two-Way Door Decision (REVERSIBLE — prioritize speed):
- Choosing a cache TTL value
- Naming a Kafka topic
- Selecting a logging level
→ Make the decision quickly, iterate based on data

One-Way Door Decision (IRREVERSIBLE — prioritize research):
- Choosing PostgreSQL vs Cassandra for orders
- Public API contract
- Encryption key management strategy
→ Write RFC, gather feedback, decide deliberately
```

---

## 💻 Coding Questions {#coding}

### Rate Limiter (Token Bucket in Redis)

```ruby
def allow_request?(user_id:, limit: 100, window: 60)
  key = "rate:#{user_id}"
  
  count = redis.incr(key)
  redis.expire(key, window) if count == 1  # Set TTL on first request
  
  count <= limit
end
```

**Edge case:** What if the key expires between `incr` and `expire`? Use Lua:

```lua
local key = KEYS[1]
local limit = tonumber(ARGV[1])
local window = tonumber(ARGV[2])

local count = redis.call("INCR", key)
if count == 1 then
  redis.call("EXPIRE", key, window)
end

if count > limit then
  return 0  -- Rejected
else
  return 1  -- Allowed
end
```

### LRU Cache

```ruby
class LRUCache
  def initialize(capacity)
    @capacity = capacity
    @cache = {}          # key → value (O(1) lookup)
    @order = []          # Most recent at front
  end

  def get(key)
    return -1 unless @cache.key?(key)
    touch(key)
    @cache[key]
  end

  def put(key, value)
    if @cache.key?(key)
      touch(key)
    else
      evict_lru! if @cache.size >= @capacity
      @order.unshift(key)
    end
    @cache[key] = value
  end

  private

  def touch(key)
    @order.delete(key)
    @order.unshift(key)
  end

  def evict_lru!
    oldest = @order.pop
    @cache.delete(oldest)
  end
end
```

**Production note:** Use a Doubly Linked List + Hash Map for O(1) operations. The array `delete` above is O(N). In Ruby, use `Hash` with insertion-order preservation (Ruby 1.9+):

```ruby
class LRUCache
  def initialize(capacity)
    @capacity = capacity
    @store = {}  # Ruby Hash maintains insertion order
  end

  def get(key)
    return -1 unless @store.key?(key)
    value = @store.delete(key)
    @store[key] = value  # Re-insert at "end" (most recent)
    value
  end

  def put(key, value)
    @store.delete(key) if @store.key?(key)
    @store.shift if @store.size >= @capacity  # Remove oldest (front)
    @store[key] = value
  end
end
```

---

## ❓ Extended Practice Questions with Full Answers {#practice}

### System Design

**Q: Design a "surge pricing" system for Toters (price goes up when demand > supply).**

> **Architecture:**
> - Every 30 seconds, a Pricing Service reads: `active_orders_per_zone` from Redis (from Hot Zone Monitor) and `available_couriers_per_zone` from Redis GEOADD
> - Calculates `demand_ratio = active_orders / available_couriers`
> - If ratio > 2.0 → apply 1.25x multiplier; ratio > 3.0 → 1.5x; etc.
> - Stores surge multiplier in Redis: `SET surge:{zone_id} 1.25 EX 60`
> - Order Service reads this before calculating final price
> - Pub/Sub notifies mobile app to show "Busy time — higher delivery fee"

**Q: How would you implement "Real-time ETA" for a delivery?**

> **ETA = prep_time_remaining + pickup_travel_time + delivery_travel_time**
> - `prep_time_remaining`: ML model prediction based on order size, restaurant history
> - `pickup_travel_time`: Google Maps API with real-time traffic (courier current location → restaurant)
> - `delivery_travel_time`: Google Maps API (restaurant → customer)
> - Recalculate every 60 seconds or on significant courier location change (> 200m)
> - Push via WebSocket to customer app

**Q: Design a system for "Order batching" — assign multiple orders to one courier.**

> - When a new order is ready for dispatch, check if any courier already heading to the same restaurant has capacity
> - Only batch if: same restaurant, courier hasn't picked up yet, adding the new delivery doesn't increase first customer's ETA by > 10 minutes
> - Use a dedicated "Batching Service" that holds orders in a 30-second waiting pool before assigning
> - Track `estimated_delivery_time` for each customer in the batch separately

### Distributed Systems

**Q: What is the CAP Theorem and how does it apply to Toters?**

> **CAP:** A distributed system can only guarantee 2 of: Consistency, Availability, Partition Tolerance.
>
> - **Orders / Payments (CP):** Prefer Consistency. Better to be temporarily unavailable than to charge a customer twice or create duplicate orders. Use PostgreSQL in synchronous replication mode.
> - **Courier Locations (AP):** Prefer Availability. A slightly stale courier position is acceptable. The map might show a courier 10 seconds behind — nobody notices. Use Redis with async replication.
> - **Flash Sale Counter (CP):** Prefer Consistency. Must enforce exactly 1,000 winners. Use Redis with Lua scripts (atomic operations guarantee consistency within a single node).

**Q: Explain the Saga Pattern with a Toters example.**

> **Scenario:** Place an order (Order Service), charge payment (Payment Service), assign courier (Dispatch Service).
>
> **Choreography Saga:**
> ```
> 1. Order Service: Creates order → publishes "order.created" to Kafka
> 2. Payment Service: Consumes event → charges card → publishes "payment.completed"
> 3. Dispatch Service: Consumes event → assigns courier → publishes "courier.assigned"
> 4. Order Service: Consumes event → updates status to "confirmed"
>
> If Payment fails:
> 2. Payment Service → publishes "payment.failed"
> 3. Order Service → consumes → cancels order (compensating transaction)
> ```
>
> No 2PC (Two-Phase Commit) required. Each step is independently retryable. Each service is autonomous.

---

## 📊 Observability Cheat Sheet

### Key Metrics to Monitor

| Service | SLI | Target SLO |
|---|---|---|
| Flash Sale claim | p99 response time | < 50ms |
| Order placement | Success rate | > 99.9% |
| Payment processing | p99 latency | < 2s |
| Courier location update | Write throughput | 3,000 WPS |
| Hot Zone query | p99 read latency | < 100ms |
| Kafka Consumer | Consumer lag | < 60 seconds |

### Alerting Rules

```yaml
alerts:
  - name: FlashSaleRedisDown
    condition: redis_ping_latency > 100ms for 10s
    action: Open circuit breaker, return 503

  - name: KafkaConsumerLag
    condition: kafka_consumer_lag > 60s
    action: Scale consumers, page on-call

  - name: OrderSuccessRateDrop
    condition: order_success_rate < 99%  for 2min
    action: Page on-call immediately
```

---

*Prepared from Toters Mock Interview Sessions — Staff Backend Engineer Track*
*Last updated: March 2026*
