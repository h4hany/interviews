# Toters — Technical Deep Dive Interview

**Role:** Staff Backend Engineer
**Focus:** Coding + System Design

---

## 🔹 1. Live Coding – SQL / Coding Loop

### **Question 1 — SQL Scenario**

**Q:** Join 3+ tables (e.g., Customers, Orders, Order_Items) to find customers who spent over $500 in a specific month but have *never* ordered a specific category (e.g., `'Electronics'`).
*(This question was reported as asked in Toters interviews.)*

```sql
SELECT c.customer_id, c.first_name, c.last_name
FROM Customers c
         JOIN Orders o ON c.customer_id = o.customer_id
         JOIN Order_Items oi ON o.order_id = oi.order_id
         JOIN Products p ON oi.product_id = p.product_id
WHERE o.order_date BETWEEN '2025-01-01' AND '2025-01-31'
GROUP BY c.customer_id
HAVING SUM(o.total_amount) > 500
   AND SUM(CASE WHEN p.category = 'Electronics' THEN 1 ELSE 0 END) = 0;
```

### Explanation

* We join customers → orders → items → products.
* We group by customer and filter total spend > $500.
* We exclude anyone who ordered Electronics by checking that case sum = 0.
* This logic expresses both aggregation and filtering requirements in one query.

💡 **Tip:** Always use clear grouping and conditional aggregates for “never ordered” constraints.

> [!TIP]
> **Antigravity Tip**: For Toters, where delivery efficiency is key, expect follow-ups on **Window Functions**. For example, how to find the 'Top 3 fastest riders per zone last week' using `DENSE_RANK() OVER (PARTITION BY zone_id ORDER BY avg_delivery_time)`. This shows you can handle complex logistical reporting.

---

## 💻 2. Backend Coding

### Question 2 — REST API Implementation

**Q:** Implement a REST endpoint to fetch paginated delivery routes for riders. Include filtering by city and status.

### Answer Outline (Express.js / Node.js)

```javascript
app.get('/api/v1/routes', async (req, res) => {
  const { city, status, page = 1, size = 20 } = req.query;

  const filter = {};
  if (city) filter.city = city;
  if (status) filter.status = status;

  const routes = await RouteModel.find(filter)
    .skip((page - 1) * size)
    .limit(Number(size));

  res.json({ page, size, data: routes });
});
```

### Key Points to Discuss

* Validation and error handling
* Pagination logic and defaults
* Filtering applied only when query present
* Use eager loading or indexes for performance

---

## 🏗️ 3. System Design

### Question 3 — Design a Scalable Delivery Tracking System

**Prompt:**
Design a backend system to track package deliveries in real time across multiple cities, with high throughput and low latency.

### Key Areas to Cover

#### Event-Driven Microservices

* Workers publish delivery status updates to Kafka/RabbitMQ
* Consumers update real-time caches and databases

#### Storage

* OLTP DB: PostgreSQL for core entities
* NoSQL / Fast Cache: Redis or Cassandra for status lookup
* Partition data by city / zone

> [!TIP]
> **Antigravity Tip**: In a tracking system for 100K+ riders, a single Redis instance will become a bottleneck. Mention **Geo-sharding**. At BrandOS (hypothetically), we would shard our real-time location cache by `city_id` or `zone_id` so each shard only handles 5-10K riders, ensuring < 10ms update latency.

#### API Patterns

* `/deliveries/{id}/status`
* Websocket or SSE for real-time updates

#### Scalability

* Auto-scaled consumer groups
* Sharded caching
* Load balanced API layer

#### Observability

* Metrics: Latency, QPS, queue lag
* Logging: Correlation IDs

---

## 🔍 4. Distributed Systems

### Question 4 — Microservices vs Monolith

**Q:** What benefits and challenges come with microservices?

### Benefits

* Independent deployment & scaling
* Fault isolation
* Tech stack heterogeneity

### Challenges

* Distributed transactions
* Increased complexity (network calls)
* Observability & data consistency

💡 Tie your answer to concepts like retries, circuit breakers, service discovery, and monitoring.

---

## ⚙️ 5. Leadership / Senior Engineering

### Question 5 — Technical Strategy

**Q:** How would you ensure coding standards and quality across multiple backend teams?

### Answer

* Define and enforce patterns through linting + shared style guides
* Pull request checklists
* Structured code reviews
* Promote automated testing
* Round-table discussions on patterns

---

## 🚀 6. DevOps / Cloud

### Question 6 — Deployment Pipeline

**Q:** How would you design the CI/CD pipeline for a Kubernetes-based backend?

### Answer Framework

* GitHub Actions / GitLab CI
* Stages: Build → Test → Security Scan → Deploy
* Use Helm charts for releases
* Canary deployments for risk reduction

---

## 🛠️ 7. Debugging & Support

### Question 7 — Production Incident

**Q:** You notice a spike in 500 errors. What steps do you take?

### Answer

* Mitigate (rate limiting, rollback)
* Inspect logs
* Correlate with recent commits
* Check resource limits (CPU / memory)
* Create post-mortem

---

# Toters — Hiring Manager / Behavioral Interview

**Role:** Staff Backend Engineer
**Focus:** Culture, Leadership, Collaboration

---

## 🧠 1. Team Leadership

### **Question 1 — Mentoring**

**Q:** Describe a time you mentored another engineer to solve a hard production problem.

**Answer Example:**

> At my previous role, I coached a mid-level engineer struggling with race conditions under high load. I shared debugging strategies (logs, thread dumps), explained locking patterns, and we paired to refactor the critical section for thread safety. Within days, the error rate dropped by 95%. This improved both system reliability and the mentee’s confidence.

**Focus:** Specific situation, action, outcome (STAR).

---

## 🤝 2. Cross-Functional Collaboration

### **Question 2 — Working with Product**

**Q:** How do you partner effectively with Product Managers?

**Answer Example:**

> I align early on priorities, clarify non-functional requirements (scale, latency), negotiate trade-offs, and document scope. Regular checkpoints with stakeholders keep visibility high and help eliminate blockers early.

---

## 🧩 3. Handling Tradeoffs

### **Question 3 — Technical vs Product Trade-offs**

**Q:** A product request compromises performance. What do you do?

**Answer:**

* Explain technical impact in clear terms
* Offer alternatives (rate limits, batching)
* Let stakeholders choose after seeing trade-offs
* Maintain documented decision rationale

---

## 🌟 4. Scenario — Scaling

### **Question 4 — Scaling Challenge**

**Q:** You have a legacy service with increasing traffic and frequent outages. How do you approach it?

**Answer:**

* Audit existing metrics/logs
* Define bottlenecks (DB, code, network)
* Propose incremental improvements
* Set up load testing
* Track impact post-deploy

---

## 🗣️ 5. Communication

### **Question 5 — Difficult Feedback**

**Q:** How do you handle giving critical feedback to a peer?

**Answer:**

* Ask permission to discuss
* Focus on behavior & outcomes
* Use specific examples
* Provide alternatives
* Follow up

---

## 🤔 6. Culture Fit

### **Question 6 — Why Toters?**

**Q:** Why do you want to work at Toters as Staff Backend Engineer?

**Sample Answer:**

> I’m excited by Toters’ scale challenge and rapid growth in the Middle East tech scene. I love data-driven problem-solving and mentoring junior engineers. I see this role as an opportunity to build resilient services and contribute to engineering excellence.

---

## 📌 7. Leadership Vision

### **Question 7 — Your Vision**

**Q:** What is your long-term technical vision if hired?

**Answer Framework:**

* Improve observability & reliability
* Design modular services with clear APIs
* Invest in automation for release velocity
* Support knowledge sharing & documentation

---

# Design a Scalable Delivery Tracking System

Let’s design a real-time delivery tracking system (like Uber Eats / Toters style 👀).

Structured the way you'd answer in a Staff Backend / System Design interview.

---

## 1️⃣ Clarify Requirements

### ✅ Functional Requirements

Users can:

* Place orders
* Track delivery driver in real-time on map

Drivers can:

* Update location frequently (every 2–5 seconds)
* Accept/reject delivery

System should:

* Show live ETA
* Notify user on status updates
* Store delivery history

### ⚙️ Non-Functional Requirements

* Handle 100K+ concurrent deliveries
* Low latency (< 200ms location update delay)
* Highly available
* Fault tolerant
* Eventually consistent is acceptable for location

---

## 2️⃣ High-Level Architecture

Core Components:

* Mobile Apps (Driver + User)
* API Gateway
* Location Service
* Order Service
* Notification Service
* Real-time Messaging Layer (WebSocket)
* Databases
* Cache Layer
* Message Queue

---

## 3️⃣ Traffic Estimation (Back-of-the-envelope)

Assume:

* 100K active deliveries
* Each driver sends location every 5 seconds

100,000 / 5 sec = 20,000 location updates per second
That’s **20K writes/sec**

If each location payload = 200 bytes:

20K × 200 bytes = 4 MB/sec
≈ 345 GB/day raw movement data

⚠️ So we must:

* Store only important points
* Use TTL for real-time location cache
* Archive summarized routes

---

## 4️⃣ System Design Components

### 🔵 API Gateway

Examples:

* Amazon Web Services API Gateway
* NGINX
* Kong

Responsibilities:

* Auth
* Rate limiting
* Routing
* Request logging

### 🔵 Load Balancer

* Distribute traffic across services
* Health checks
* Auto scaling

Examples:

* Amazon Web Services ELB
* NGINX

### 🔵 Real-Time Location Updates

We cannot use polling (too expensive).

We use:

👉 **WebSockets**

Persistent connection between:

* Driver → Backend
* Backend → User

Alternatives:

* Socket.IO
* Apache Kafka (event streaming backbone)

#### Flow

```
Driver App
   ↓ (WebSocket)
Location Service
   ↓ (publish event)
Message Broker
   ↓
User WebSocket
```

---

## 5️⃣ Data Storage Design

### 🟢 1. Orders (Transactional)

Use relational DB:

* PostgreSQL
* MySQL

Why?

* ACID compliance
* Strong consistency for payments & status

### 🟢 2. Real-time Location

Use in-memory store:

* Redis

Store:

```
driver_id → {lat, lng, timestamp}
TTL = 30 seconds
```

Why?

* 100x faster than disk DB
* Low latency
* Ephemeral data

### 🟢 3. Historical Routes

Use scalable NoSQL:

* MongoDB
* Apache Cassandra

Optimized for:

* Time-series writes
* High throughput

---

## 6️⃣ Database Scaling Strategy

* Reads heavy? → Add read replicas
* Writes heavy? → Shard by:

```
driver_id hash % N
```

For geo queries:

* Use geospatial indexes
* Partition by region

---

## 7️⃣ Caching Strategy

Use:

* Redis

Cache:

* Active deliveries
* ETAs
* Driver profiles

TTL:

* 1–5 minutes depending on data volatility

---

## 8️⃣ Real-Time ETA Calculation

### Option A: External API

* Google Maps API

Pros:

* Accurate
  Cons:
* Expensive at scale

### Option B: Internal Engine

* Precompute routes
* Use graph algorithm (Dijkstra / A*)
* Periodically recalc every 30 sec

Better at large scale.

---

## 9️⃣ CAP Theorem Decision

For location service:

We choose:

**AP (Availability + Partition Tolerance)**

Why?

* Slightly stale location is OK
* System must never stop tracking

For payments:

We choose:

**CP (Consistency + Partition Tolerance)**

---

## 🔟 Scaling Strategy

### Horizontal Scaling

* Stateless services
* Kubernetes auto-scaling
* WebSocket clusters

### Message Queue

Use:

* Apache Kafka
* RabbitMQ

For:

* Event-driven updates
* Decoupling services
* Reliability

---

## 1️⃣1️⃣ Failure Handling

If WebSocket server crashes:

* Driver reconnects automatically
* Last location pulled from Redis
* Kafka replays missed events

If region goes down:

* Geo DNS failover
* Multi-region replication

---

## 1️⃣2️⃣ Bottlenecks & Solutions

| Problem             | Solution                |
| ------------------- | ----------------------- |
| DB overload         | Cache + read replicas   |
| Too many WebSockets | Use connection sharding |
| Network spikes      | Rate limit drivers      |
| Log explosion       | Store in object storage |

---

## 1️⃣3️⃣ Monitoring

Use:

* Prometheus
* Grafana
* Datadog

Track:

* Requests/sec
* Location updates/sec
* WebSocket connections
* DB latency

---

## 🔥 Final High-Level Flow

```
Driver → WebSocket → Location Service → Redis
                                      ↓
                                   Kafka
                                      ↓
User WebSocket → User App (Map Update)
```
