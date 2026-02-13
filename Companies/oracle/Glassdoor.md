# Oracle Interview Questions - Glassdoor Collection

---

## 1) Graph Problem — Top Linked Movies Within 3 Hops

### Problem Idea
Movies are nodes. Edge exists if two movies share the same genre (or are linked by genre relation). From a starting movie → find top linked movies within ≤3 hops.

### Expected Interview Direction
- Graph modeling
- BFS traversal (level-limited)
- Ranking / scoring (optional)
- Complexity analysis

### Strong Principal-Level Answer

#### Approach
- Model as undirected graph
- Use BFS up to depth = 3
- Track visited to avoid cycles
- Count link strength (frequency or weight)
- Return top-K by score

#### Pseudo Code
```python
from collections import deque, defaultdict

def top_linked_movies(graph, start, max_hops=3, k=5):
    q = deque([(start, 0)])
    visited = set([start])
    score = defaultdict(int)

    while q:
        movie, depth = q.popleft()
        if depth == max_hops:
            continue

        for neighbor in graph[movie]:
            if neighbor not in visited:
                visited.add(neighbor)
                score[neighbor] += 1
                q.append((neighbor, depth + 1))

    return sorted(score, key=score.get, reverse=True)[:k]
```

#### Complexity
- **Time:** O(V + E) (bounded by 3 hops)
- **Space:** O(V)

### Principal-Level Extension
- Weighted edges by genre similarity
- Use PageRank-style scoring
- Precompute using graph DB (Neo4j)
- Distributed BFS using Spark GraphX for huge dataset

---

## 2) Dynamic Programming — Unbounded Knapsack

### Problem
Given bundles with cost/value and unlimited quantity → maximize value within budget.

### Strong Interview Answer

#### DP Recurrence
```
dp[w] = max(dp[w], dp[w - weight[i]] + value[i])
```

#### Code
```python
def unbounded_knapsack(weights, values, W):
    dp = [0] * (W + 1)

    for w in range(W + 1):
        for i in range(len(weights)):
            if weights[i] <= w:
                dp[w] = max(dp[w], dp[w - weights[i]] + values[i])

    return dp[W]
```

#### Complexity
- **Time:** O(N * W)
- **Space:** O(W)

### Principal-Level Insight
- Greedy fails due to non-linear combinations
- Optimize with monotonic queue (if structured weights)
- Use memoization for sparse DP
- Parallelizable using segment partitioning

---

## 3) Backtracking — Word Search (LeetCode Style)

Find word in 2D grid by DFS.

### Expected Concepts
- Backtracking
- DFS
- Visited marking
- Pruning

#### Code
```python
def exist(board, word):
    rows, cols = len(board), len(board[0])

    def dfs(r, c, i):
        if i == len(word):
            return True
        if r < 0 or c < 0 or r >= rows or c >= cols or board[r][c] != word[i]:
            return False

        temp = board[r][c]
        board[r][c] = "#"

        found = (dfs(r+1, c, i+1) or dfs(r-1, c, i+1) or
                 dfs(r, c+1, i+1) or dfs(r, c-1, i+1))

        board[r][c] = temp
        return found

    for r in range(rows):
        for c in range(cols):
            if dfs(r, c, 0):
                return True
    return False
```

#### Complexity
- **Time:** O(N * 4^L)
- **Space:** recursion depth O(L)

### Principal Insight
- Use Trie for multiple word search
- Use bitmask visited for memory efficiency
- Parallelize by splitting grid

---

## 4) System Design — Subscription Billing Architecture

This is very common at Oracle / Stripe / SaaS companies.

### Core Components
- API Gateway
- Billing Engine
- Pricing/Plan Service
- Usage Metering
- Invoice Generator
- Payment Gateway
- Subscription Lifecycle Manager
- Event Bus
- Ledger / Accounting
- Retry & Dunning system
- Tax & Compliance engine

### High-Level Flow
1. User subscribes → Subscription Service
2. Usage recorded → Metering Service
3. Billing cycle triggers → Billing Engine
4. Invoice generated → Invoice Service
5. Payment attempt → Payment Gateway
6. Failure → Retry / Dunning
7. Success → Ledger entry + notification

### Principal-Level Discussion Points
- Idempotency for billing
- Event-driven architecture
- Exactly-once charge guarantee
- Proration handling
- Multi-currency + tax
- Scalability (millions invoices/hour)
- Strong audit trail
- PCI compliance

---

## 5) System Design — Distributed Job Scheduler

### Components
- Job API
- Scheduler
- Queue (Kafka / SQS)
- Worker nodes
- Retry manager
- Distributed lock (Zookeeper / Redis / etcd)
- Monitoring & metrics
- Dead letter queue

### Scheduling Strategy
- Time-wheel / Cron
- Priority queue
- Sharding jobs across nodes
- Leader election for scheduler

### Failure Handling
- Retry with backoff
- Idempotent jobs
- Exactly-once vs at-least-once
- Detect stuck jobs via heartbeat

### Principal-Level Topics
- Horizontal scaling
- Distributed coordination
- Cron vs event scheduling
- Job deduplication
- Workflow DAG scheduler (Airflow style)

---

## 6) Generic Principal Screening Topics

### Expect:
- Deep architecture of your current system
- Tradeoffs
- Scalability
- Bottlenecks
- Failure recovery
- Cost optimization
- Cross-cloud strategy
- Observability
- Leadership & mentoring

---

## 7) Coding + Design + Managerial (Generic Loop)

This is not a single question but a pattern Oracle uses.

### What They Really Evaluate

#### Coding
- Data structures
- Clean code
- Edge cases
- Complexity
- Concurrency

#### Design
- Scalability
- Failure handling
- Tradeoffs
- Real production thinking

#### Managerial
- Ownership
- Leadership
- Mentoring
- Conflict resolution
- Architecture decisions

### How to Answer Strongly (Principal Level)

Use this structure:
1. Clarify requirements
2. State constraints
3. Present brute force → optimized
4. Discuss tradeoffs
5. Talk about scaling & failures
6. Mention observability & cost

---

## 8) "Know Everything in Your CV" — Deep Technical Drill

This is very real at Oracle.

### They May Ask:
- Why did you choose this architecture?
- What bottleneck did you hit?
- What would you redesign today?
- How did you scale?
- How did you debug production issue?
- What was your hardest bug?
- How did you optimize cost/performance?
- What failure scenario did you face?

### How to Prepare

Be ready with deep stories about:
- Distributed system you built
- Performance optimization
- System failure & recovery
- Architecture decision
- Tradeoff you made
- Scaling problem
- Production debugging

**Note:** If you cannot go deep → they reject immediately at Principal level

---

## 9) Design Patterns + SQL + APIs + Troubleshooting

This looks like Oracle enterprise stack style interview.

### Most Common Patterns Asked

| Pattern | Where Used |
|---------|------------|
| Singleton | Config / DB connection |
| Factory | Object creation / drivers |
| Strategy | Pricing / billing logic |
| Observer | Event / notifications |
| Builder | Complex object creation |
| Adapter | External APIs |
| Circuit Breaker | Distributed systems |
| Retry Pattern | Fault tolerance |

### Example Strong Answer — Circuit Breaker

#### Purpose
Prevent cascading failure when downstream service is slow or failing.

#### States
- **CLOSED** → normal
- **OPEN** → block calls
- **HALF-OPEN** → test recovery

#### Use Cases
- Payment service
- Cross-cloud API
- Database overload

#### Principal-Level Extension
- Combine with bulkhead isolation
- Add fallback strategy
- Adaptive threshold

### SQL / Troubleshooting Example

#### Typical Question
How do you debug slow query?

#### Strong Answer
- Check execution plan
- Look for full table scans
- Add index / composite index
- Remove N+1 queries
- Partition large tables
- Use caching
- Monitor lock contention
- Check I/O wait
- Analyze cardinality estimation

---

## 10) System Design — Notification System

Very common.

### Components
- Notification API
- Event Queue (Kafka)
- Template Service
- User Preference Service
- Delivery Workers
- Channel adapters (Email / SMS / Push)
- Retry & DLQ
- Rate limiter
- Metrics / observability

### Key Discussion Points
- At-least-once vs exactly-once
- Deduplication
- Backpressure
- Batch sending
- Priority queue
- Multi-region failover
- Idempotent delivery

### Scaling
- Partition by user
- Async pipeline
- Worker autoscaling
- Use CDN for push payload

### Principal Topics
- Fan-out at scale
- Avoid notification storm
- Cost optimization
- SLA vs best-effort

---

## 11) DSA — Longest Increasing Subsequence O(n log n)

### Optimal Solution (Binary Search)
```python
import bisect

def LIS(nums):
    tail = []

    for n in nums:
        i = bisect.bisect_left(tail, n)
        if i == len(tail):
            tail.append(n)
        else:
            tail[i] = n

    return len(tail)
```

#### Complexity
- **Time:** O(n log n)
- **Space:** O(n)

### Principal Insight
- DP O(n²) is brute force
- This uses patience sorting concept
- Can reconstruct sequence with parent pointers

---

## 12) Concurrency — Threads + Semaphores

Classic OS / Java concurrency problem.

### Example Problem
Synchronize producer & consumer OR limit concurrency.

### Strong Answer
```java
import java.util.concurrent.Semaphore;

Semaphore sem = new Semaphore(3); // allow 3 threads

public void task() {
    try {
        sem.acquire();
        System.out.println(Thread.currentThread().getName()+" running");
        Thread.sleep(1000);
    } catch(Exception e) {}
    finally {
        sem.release();
    }
}
```

### Key Concepts Interviewer Wants
- Mutual exclusion
- Deadlock avoidance
- Starvation
- Fair semaphore
- Producer/Consumer
- Reader/Writer problem
- Lock vs Semaphore vs Mutex

### Principal-Level Discussion
- Use lock-free when possible
- Avoid blocking in hot path
- Use bounded queue for backpressure
- Thread pool tuning
- CPU vs I/O bound

---

## 13) Resume Deep-Dive / Background Round

This is very critical at Principal level.

### What They Evaluate
- Depth (not buzzwords)
- Ownership
- Architecture decisions
- Failures & recovery
- Scaling
- Tradeoffs
- Real production experience

### Strong Structure to Answer

When they ask about any project:

1. **Context**
   - Problem scale
   - Constraints

2. **Architecture**
   - Components
   - Data flow
   - Why chosen

3. **Challenges**
   - Bottlenecks
   - Failures
   - Debugging

4. **Impact**
   - Performance improvement
   - Cost reduction
   - Scale achieved

5. **What you'd redesign today**

**Note:** If you cannot go deep → Principal rejection

---

## 14) Competitive Programming / DSA Screening

Oracle still asks:
- Graph
- DP
- Binary search
- Strings
- Arrays
- Concurrency
- Recursion

### You Must Show:
- Clean thinking
- Correct complexity
- Edge cases
- Optimized solution

---

## 15) OOP + Debug Code + Fix Bug

### What Interviewer Checks
- Code reading
- Bug detection
- Clean fix
- Design understanding

### Typical Example
Bug: null pointer / race / off-by-one / memory / logic

### Strong Answer Strategy
1. Understand expected behavior
2. Identify failing case
3. Explain root cause
4. Fix cleanly
5. Add validation / edge case

### Example (Java)
```java
if(list != null && !list.isEmpty()) {
    process(list);
}
```

### Principal Insight
- Prevent class of bug (not just fix)
- Add unit test
- Improve design
- Add observability

---

## 16) REST + Microservices Concepts

### Key Topics
- Stateless services
- Idempotency
- Retry & backoff
- Circuit breaker
- Service discovery
- API Gateway
- Rate limiting
- Observability
- Distributed tracing
- Saga pattern

### Common Question
How do you design resilient microservices?

### Strong Answer:
- Retry with backoff
- Circuit breaker
- Bulkhead isolation
- Timeout
- Idempotent APIs
- Event-driven architecture
- Graceful degradation
- Health checks
- Autoscaling
- Observability

---

## 17) Behavioral + Career Questions

### Typical:
- Why leaving job?
- Hardest problem?
- Leadership example?
- Conflict?
- Failure?
- Mentoring?
- Biggest impact?

### Strong Rule
Always show:
- Ownership
- Learning
- Impact
- Growth
- Calm under pressure

---

## 18) Binary Search — Target in Rotated Sorted Array

### Optimal O(log n)
```python
def search(nums, target):
    l, r = 0, len(nums)-1

    while l <= r:
        mid = (l+r)//2
        if nums[mid] == target:
            return mid

        if nums[l] <= nums[mid]:
            if nums[l] <= target < nums[mid]:
                r = mid-1
            else:
                l = mid+1
        else:
            if nums[mid] < target <= nums[r]:
                l = mid+1
            else:
                r = mid-1
    return -1
```

#### Complexity
- **Time:** O(log n)
- **Space:** O(1)

### Principal Insight
- Works because one side always sorted
- Can extend for duplicates
- Used in time-series rotated storage

---

## 19) System Design — Payment Wallet (Very Important)

### Core Components
- Wallet Service
- Ledger (double entry)
- Transaction Service
- Payment Gateway
- Fraud Detection
- Balance Cache
- Event Bus
- Retry / Reconciliation
- Notification
- Audit log

### Flow
1. User requests transfer
2. Validate balance
3. Create transaction
4. Debit → Credit (atomic)
5. Persist ledger
6. Emit event
7. Notify

### Critical Design Points
- Double-entry accounting
- Idempotent transaction
- Exactly-once debit
- Distributed transaction → Saga
- Retry & reconciliation
- Fraud prevention
- Locking strategy
- Strong audit trail
- High availability

### Principal-Level Discussion
- Handling partial failure
- Idempotency keys
- Eventual consistency
- Ledger immutability
- Scaling to millions TPS
- Prevent double spend
- Consistent balance
- ACID vs BASE tradeoff

---

## 20) Random Deep Networking / Cloud / Experience Questions

### Expect:
- TCP vs HTTP vs gRPC
- Load balancing
- DNS routing
- Multi-region failover
- Observability
- Latency optimization
- Cloud cost
- Bottlenecks
- Scaling

---

## 21) API Logging & Tracing in Microservice Gateway

This is VERY important for distributed/cloud roles (OCI Multicloud).

### Goals
- Observability
- Debugging
- Performance monitoring
- Failure tracing
- Security audit

### Best Practices (Principal-Level)

#### 1. Structured Logging
- JSON logs (not plain text)
- Include:
  - `trace_id`
  - `span_id`
  - `request_id`
  - `user_id`
  - `service_name`
  - `latency`
  - `status_code`
  - `error_code`

**Example:**
```json
{
  "trace_id": "abc123",
  "service": "payment",
  "latency_ms": 120,
  "status": 200
}
```

#### 2. Distributed Tracing
- Use OpenTelemetry
- Track:
  - Request flow across services
  - Latency per service
  - Failures
- Key components:
  - Trace
  - Span
  - Context propagation

#### 3. Correlation ID Propagation
- Inject trace_id into headers
- Forward across services
- Enables full request tracking

**Header example:**
```
x-trace-id: 123abc
```

#### 4. Log Levels Strategy

| Level | Use |
|-------|-----|
| INFO | business flow |
| WARN | slow call |
| ERROR | failure |
| DEBUG | dev only |

#### 5. Sampling (For High Traffic)
- Log only X%
- Always log errors
- Adaptive sampling for spikes

#### 6. Centralized Logging
- Stack:
  - Fluentd / Logstash
  - Elasticsearch
  - Kibana / Grafana

#### 7. Metrics + Logs + Traces = Full Observability
- Track:
  - p99 latency
  - error rate
  - throughput
  - retry rate
  - queue depth

### Principal-Level Discussion
- Avoid logging sensitive data
- Cost vs observability tradeoff
- Log storm prevention
- Async logging for performance
- Correlate with autoscaling
- Detect cross-cloud latency

---

## 22) Algorithms — LeetCode Easy → Moderate

Oracle frequently asks:
- Graph traversal
- DFS/BFS
- Binary search
- Sliding window
- DP basics
- Hashing
- String manipulation

### Focus On:
- Clean code
- Edge cases
- Complexity

---

## 23) Backtracking — Count Number of Islands

Classic graph problem.

### DFS Solution
```python
def numIslands(grid):
    rows, cols = len(grid), len(grid[0])

    def dfs(r, c):
        if r < 0 or c < 0 or r >= rows or c >= cols or grid[r][c] != "1":
            return
        grid[r][c] = "0"
        dfs(r+1, c)
        dfs(r-1, c)
        dfs(r, c+1)
        dfs(r, c-1)

    count = 0
    for r in range(rows):
        for c in range(cols):
            if grid[r][c] == "1":
                dfs(r, c)
                count += 1
    return count
```

#### Complexity
- **Time:** O(M×N)
- **Space:** recursion stack

---

## 24) Real-Time Production Incident (Behavioral)

Very common at Principal level.

### Strong STAR Example

#### Situation
High latency spike in production.

#### Task
Restore service and identify root cause.

#### Action
- Checked metrics & logs
- Found DB query lock
- Added index + optimized query
- Applied hotfix
- Added alert & retry

#### Result
- Latency ↓ 70%
- No recurrence
- Improved observability

### What Interviewer Evaluates
- Calmness
- Root cause thinking
- Ownership
- Prevention mindset
- Real production experience

---

## 25) String Manipulation — Anagram
```python
from collections import Counter

def isAnagram(s, t):
    return Counter(s) == Counter(t)
```

#### Complexity
- **Time:** O(n)
- **Space:** O(1) for ASCII

---

## 26) Sliding Window Pattern

Used for:
- Substring
- Rate limiting
- Max/min window
- Stream processing

### Example — Longest Substring Without Repeating
```python
def longest_unique(s):
    seen = {}
    l = 0
    max_len = 0

    for r in range(len(s)):
        if s[r] in seen and seen[s[r]] >= l:
            l = seen[s[r]] + 1
        seen[s[r]] = r
        max_len = max(max_len, r - l + 1)
    return max_len
```

---

## 27) Rate Limiter Design

### Algorithms

| Algorithm | Use |
|-----------|-----|
| Token bucket | burst allowed |
| Leaky bucket | smooth |
| Sliding window | accurate |
| Fixed window | simple |

### Distributed Design
- Redis / in-memory
- Atomic counter
- TTL
- Per-user key
- Global vs per-tenant

---

## 28) Blocking vs Non-blocking

### Blocking
- Thread waits → resource idle

### Non-blocking
- Async / event loop → scalable

### Used In:
- NIO
- Netty
- Node
- Reactive systems

### Principal Insight
- Use non-blocking for high concurrency
- Avoid thread explosion
- Backpressure control

---

## 29) REST API Best Practices
- Stateless
- Idempotent
- Versioned
- Pagination
- Rate limiting
- Auth (OAuth/JWT)
- Retry safe
- Proper HTTP codes
- Observability
- Backward compatible

---

## 30) Shopping Cart Design (Mini System Design)

### Components
- Cart Service
- Inventory Service
- Pricing Service
- Checkout Service
- Payment
- Order Service
- Cache (Redis)
- DB (persistent cart)

### Challenges
- Multi-device sync
- Expired cart
- Price change
- Inventory race
- Distributed transaction

### Principal Topics
- Eventual consistency
- Saga pattern
- Locking inventory
- High scale
- Cost optimization

---

## 31) System Design — Transaction System with Unit Availability

(Inventory + Transactions — very common)

### Problem
Design a system to perform transactions only if units are available (e.g., tickets, stock, seats).

### Core Components
- API Gateway
- Inventory Service
- Reservation Service (hold units temporarily)
- Transaction Service
- Payment Service
- DB (strong consistency)
- Cache (Redis)
- Message Queue
- Reconciliation worker

### High-Level Flow
1. User requests purchase
2. Check inventory (fast cache)
3. Reserve units (temporary lock / hold)
4. Process payment
5. Commit transaction → decrement stock
6. Release hold or rollback on failure

### Critical Problems
- Race condition → overselling
- Double payment
- Partial failure
- Retry duplication
- Distributed consistency

### Strong Solutions
- Optimistic locking / versioning
- Atomic reservation
- Idempotent transaction
- Saga pattern
- Timeout hold
- Event-driven reconciliation

### Principal-Level Topics
- Strong vs eventual consistency
- Partitioning inventory
- Flash-sale handling
- Distributed lock vs DB lock
- Horizontal scaling
- Multi-region inventory sync

---

## 32) Large Decimal Addition (String-Based)

### Problem
Add two huge decimal numbers without built-in big-int.

```python
def add_strings(a, b):
    i, j = len(a)-1, len(b)-1
    carry = 0
    res = []

    while i >= 0 or j >= 0 or carry:
        x = int(a[i]) if i >= 0 else 0
        y = int(b[j]) if j >= 0 else 0
        s = x + y + carry
        res.append(str(s % 10))
        carry = s // 10
        i -= 1
        j -= 1

    return "".join(res[::-1])
```

#### Complexity
- **Time:** O(n)
- **Space:** O(n)

---

## 33) Class Design — Minesweeper

### Key OOP Concepts
- **Classes:**
  - Board
  - Cell
  - Game
  - Player
  - MineGenerator

### Design Considerations
- Encapsulation
- Lazy mine generation
- Flood fill reveal
- Game state machine
- Separation of logic/UI

### Principal Insight
- Use MVC
- Event-driven
- Testable logic
- Thread-safe if multiplayer

---

## 34) Sliding Window Rate Limiter with Duplicate Rejection

### Idea
Reject repeated requests within time window.

### Implementation (Redis)
- Key = user_id
- Store timestamps
- Remove old entries
- Check count

### Principal Extension
- Use sorted set (ZSET)
- Distributed atomic ops
- Use token bucket for burst
- Global + per-tenant limit

---

## 35) IoT Data Collection System (HLD)

### Components
- Device Gateway (MQTT)
- Stream ingestion (Kafka)
- Data processing (Flink / Spark)
- Time-series DB
- Alerting engine
- Device registry
- OTA updater
- Monitoring

### Challenges
- Millions devices
- Unreliable network
- Duplicate data
- Out-of-order
- Latency vs throughput
- Cost optimization

### Principal Topics
- Edge aggregation
- Batch vs streaming
- Compression
- Partitioning
- Backpressure
- Fault tolerance

---

## 36) Fast Modular Exponentiation — (n^m) % y

### Optimal Solution — Binary Exponentiation
```python
def mod_exp(n, m, mod):
    res = 1
    n = n % mod

    while m > 0:
        if m % 2 == 1:
            res = (res * n) % mod
        n = (n * n) % mod
        m //= 2

    return res
```

#### Complexity
- **Time:** O(log m)
- **Space:** O(1)

---

## 37) C / OS / System Programming Topics

### Expect:
- Memory layout
- Heap vs stack
- Pointer arithmetic
- Process vs thread
- Mutex / semaphore
- Deadlock
- Context switch
- Scheduling
- Virtual memory
- File descriptors
- System calls

### Principal Insight:
- Performance + memory efficiency
- Lock contention
- CPU cache
- NUMA awareness

---

## 38) "Greatest Professional Achievement" (Behavioral)

### Strong Answer Structure
- Problem scale
- Your leadership
- Technical depth
- Impact (metrics)
- Learning
- Long-term result

### Example:
- Reduced latency 60%
- Saved $X cloud cost
- Scaled system to millions
- Led architecture change

---

## 39) Design Patterns — Frequently Asked

Must know deeply:
- Singleton
- Factory
- Strategy
- Observer
- Builder
- Adapter
- Circuit Breaker
- Retry
- Saga
- CQRS
- Event Sourcing

### Principal Expectation:
Know when NOT to use a pattern

---

## 40) Merge Sort (Classic)
```python
def merge_sort(arr):
    if len(arr) <= 1:
        return arr
    mid = len(arr)//2
    left = merge_sort(arr[:mid])
    right = merge_sort(arr[mid:])
    return merge(left, right)

def merge(l, r):
    res = []
    i = j = 0
    while i < len(l) and j < len(r):
        if l[i] < r[j]:
            res.append(l[i])
            i += 1
        else:
            res.append(r[j])
            j += 1
    res.extend(l[i:])
    res.extend(r[j:])
    return res
```

#### Complexity
- **Time:** O(n log n)
- **Stable**
- External sorting use case

---

## 41) PL/SQL + Oracle DB Fundamentals

### Core Topics You Must Know
- Stored Procedures / Functions
- Triggers
- Cursors (implicit / explicit)
- Indexes (B-tree, bitmap)
- Execution plan
- Joins optimization
- Partitioning
- Transactions & isolation levels
- Locking
- Materialized views

### Common Question — Optimize Slow Query

#### Strong Answer:
- Check execution plan
- Add proper index (composite if needed)
- Remove full table scan
- Use bind variables
- Avoid SELECT *
- Partition large tables
- Use caching / materialized view
- Analyze locks / wait events

### Principal Insight
- Query optimization impacts system latency more than code
- DB contention = distributed system bottleneck
- Always design for scale & partitioning

---

## 42) Linked List Implementation

### Typical Operations:
- Reverse
- Detect cycle (Floyd)
- Merge lists
- Remove nth node
- LRU foundation

### Reverse Linked List
```python
def reverse(head):
    prev = None
    curr = head

    while curr:
        nxt = curr.next
        curr.next = prev
        prev = curr
        curr = nxt

    return prev
```

#### Complexity
- **Time:** O(n)
- **Space:** O(1)

---

## 43) LRU Cache (Very Important)

### Expected Approach
- HashMap → O(1) lookup
- Doubly Linked List → order tracking

### Python Example
```python
from collections import OrderedDict

class LRU:
    def __init__(self, capacity):
        self.cache = OrderedDict()
        self.cap = capacity

    def get(self, key):
        if key not in self.cache:
            return -1
        self.cache.move_to_end(key)
        return self.cache[key]

    def put(self, key, val):
        if key in self.cache:
            self.cache.move_to_end(key)
        self.cache[key] = val
        if len(self.cache) > self.cap:
            self.cache.popitem(last=False)
```

### Principal Discussion
- Thread safety
- Sharding
- Distributed cache (Redis)
- Eviction tuning
- Memory pressure

---

## 44) Data Structure Selection Strategy

How to choose DS → very common Principal question

| Requirement | DS |
|-------------|-----|
| Fast lookup | HashMap |
| Ordered | TreeMap |
| LRU | Hash + DLL |
| Queue | Deque |
| Graph | Adjacency list |
| Priority | Heap |
| Concurrent | ConcurrentHashMap |

### Principal Thinking
- Access pattern
- Memory
- Concurrency
- Cache locality
- Scale
- Mutation frequency

---

## 45) Message List by Timeframe (Streaming / Query)

### Approach
- Store messages sorted by timestamp
- Binary search start/end
- Range query

### If Large Scale:
- Time-series DB
- Partition by time
- Index timestamp
- Use streaming pipeline

---

## 46) Project Management + Delivery

### Expect Questions On:
- Estimation
- Planning
- Risk
- Coordination
- Delivery
- Monitoring

### Strong Answer
- Break project into milestones
- Identify risks early
- Track metrics
- Continuous delivery
- Postmortem culture
- Communication

---

## 47) Software Development Life Cycle (SDLC)
- Requirements
- Design
- Implementation
- Testing
- Deployment
- Monitoring
- Maintenance

### Principal Insight:
- Iterative > waterfall
- Observability built-in
- Automation
- Feedback loop

---

## 48) Conflict Resolution (Behavioral)

### Strong Pattern:
- Listen first
- Understand root issue
- Align on goal
- Use data
- De-escalate
- Resolve professionally

---

## 49) How to Manage a Project (Principal Level)
- Define architecture
- Align stakeholders
- Remove blockers
- Mentor engineers
- Ensure delivery
- Track performance
- Improve system long-term

---

## 50) Core Java / Spring / Backend

### Expect:
- Threading
- JVM memory
- GC tuning
- Spring lifecycle
- Dependency injection
- REST design
- Transaction management
- Hibernate performance
- Connection pooling

### Principal Insight:
- Performance tuning
- Scalability
- Observability
- Failure recovery
