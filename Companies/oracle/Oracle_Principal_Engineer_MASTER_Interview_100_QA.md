# Oracle Principal Software Engineer (OCI Multicloud)
## MASTER Interview Preparation — 100 Questions with Full Answers

Level: Principal / IC4  
Focus: Distributed Systems, Cloud, System Design, Coding, Concurrency, Architecture, Behavioral

---

# SECTION 1 — CODING & DATA STRUCTURES

## 1. Graph BFS — Top Linked Movies within 3 Hops
**Answer:** Model movies as graph nodes, edges by shared genre. Use BFS up to depth=3, track visited, score neighbors by frequency, return top-K.  
Time: O(V+E). Scale using graph DB (Neo4j) or distributed BFS.

## 2. Unbounded Knapsack
**Answer:** dp[w] = max(dp[w], dp[w-weight[i]] + value[i]).  
Time: O(N×W). Optimize with memoization or pruning.

## 3. Word Search
**Answer:** DFS + backtracking, mark visited, explore 4 directions.  
Time: O(N×4^L). Use Trie for multi-word optimization.

## 4. Longest Increasing Subsequence
**Answer:** Binary search on tail array.  
Time: O(n log n). Reconstruct sequence using parent pointers.

## 5. Search in Rotated Sorted Array
**Answer:** Binary search, detect sorted half.  
Time: O(log n). Works due to partial ordering.

## 6. Number of Islands
**Answer:** DFS flood fill.  
Time: O(M×N). Use union-find for parallelism.

## 7. Modular Exponentiation
**Answer:** Binary exponentiation.  
Time: O(log n). Used in cryptography.

## 8. Reverse Linked List
**Answer:** Iterative pointer swap.  
Time: O(n). Space O(1).

## 9. Detect Cycle in Linked List
**Answer:** Floyd slow/fast pointer.  
Time: O(n). Space O(1).

## 10. LRU Cache
**Answer:** HashMap + Doubly Linked List → O(1).  
Discuss thread safety, distributed Redis version.

## 11. Sliding Window Longest Substring
**Answer:** HashMap + moving window.  
Time O(n).

## 12. Rate Limiter (Sliding Window)
**Answer:** Store timestamps in Redis sorted set, remove expired, count remaining.  
Use token bucket for burst.

## 13. Merge Sort
**Answer:** Divide & merge. Stable sort.  
Time O(n log n).

## 14. Big Number Addition
**Answer:** String digit-by-digit addition with carry.  
Time O(n).

## 15. Linked List Merge
**Answer:** Two-pointer merge sorted lists.

## 16. Binary Tree Level Order
**Answer:** BFS queue traversal.

## 17. Binary Tree LCA
**Answer:** Recursive search, return node where both sides found.

## 18. Top K Elements
**Answer:** Min-heap size K. Time O(n log k).

## 19. Thread-safe Counter
**Answer:** AtomicInteger / CAS / lock-free increment.

## 20. Producer Consumer
**Answer:** Blocking queue + semaphore.

---

# SECTION 2 — SYSTEM DESIGN

## 21. Subscription Billing
**Answer:** Event-driven architecture, idempotent billing, ledger, retry, proration, multi-currency, strong audit.

## 22. Distributed Job Scheduler
**Answer:** Leader election, job queue, retry, idempotent execution, heartbeat, failover.

## 23. Notification System
**Answer:** Kafka queue, template engine, delivery workers, retry + DLQ, deduplication.

## 24. Payment Wallet
**Answer:** Double-entry ledger, Saga, idempotent transaction, fraud detection, reconciliation.

## 25. Inventory Reservation System
**Answer:** Optimistic locking, temporary hold, commit/rollback, avoid overselling.

## 26. IoT Data Collection
**Answer:** MQTT ingestion, stream processing, time-series DB, edge aggregation, backpressure.

## 27. Shopping Cart
**Answer:** Eventual consistency, inventory locking, pricing snapshot, checkout Saga.

## 28. Distributed Cache
**Answer:** Sharding, consistent hashing, replication, eviction policy, cache invalidation.

## 29. Global Load Balancer
**Answer:** Geo-DNS, health checks, failover, latency routing.

## 30. API Gateway
**Answer:** Auth, routing, rate limiting, logging, tracing, circuit breaker.

---

# SECTION 3 — MICROSERVICES / CLOUD

## 31. Logging & Tracing
**Answer:** Structured logs + OpenTelemetry + correlation IDs + sampling + centralized logging.

## 32. Microservice Resilience
**Answer:** Retry, circuit breaker, timeout, bulkhead, idempotency.

## 33. REST Best Practices
**Answer:** Stateless, versioning, pagination, idempotency, correct HTTP codes.

## 34. Blocking vs Non-blocking
**Answer:** Async improves concurrency, avoid thread starvation.

## 35. Kubernetes Scaling
**Answer:** HPA, readiness probe, rolling updates, PDB, autoscaling.

## 36. Terraform State
**Answer:** Remote backend + locking prevents corruption.

## 37. Multi-cloud Networking
**Answer:** Private links, latency routing, failover.

## 38. Observability Stack
**Answer:** Metrics + Logs + Traces + SLO + alerting.

## 39. Security in Cloud
**Answer:** IAM, encryption, secrets manager, rotation, audit.

## 40. Cost Optimization
**Answer:** Autoscale, spot instances, cache, storage tiering.

---

# SECTION 4 — DATABASE / SQL

## 41. Query Optimization
**Answer:** Indexing, execution plan, partitioning, avoid full scan.

## 42. Isolation Levels
**Answer:** Read committed vs repeatable vs serializable.

## 43. Deadlock Debugging
**Answer:** Lock graph, retry, smaller transactions.

## 44. Partitioning Strategy
**Answer:** Range/hash/time-based improves performance.

## 45. NoSQL vs SQL
**Answer:** SQL strong consistency, NoSQL scale & flexibility.

---

# SECTION 5 — CONCURRENCY / SYSTEM

## 46. Semaphore vs Mutex
**Answer:** Semaphore allows N threads, mutex only 1.

## 47. Deadlock Conditions
**Answer:** Mutual exclusion, hold & wait, no preemption, circular wait.

## 48. Lock-free Programming
**Answer:** CAS, atomic ops, avoid blocking.

## 49. JVM GC Tuning
**Answer:** Reduce allocation, tune heap, use G1/ZGC.

## 50. Thread Pool Tuning
**Answer:** CPU vs IO bound, queue size, backpressure.

---

# SECTION 6 — DESIGN PATTERNS

## 51. Singleton
Ensure one instance.

## 52. Factory
Decouple creation.

## 53. Strategy
Switch algorithm runtime.

## 54. Observer
Event notification.

## 55. Builder
Complex object creation.

## 56. Adapter
Integrate incompatible APIs.

## 57. Circuit Breaker
Prevent cascading failure.

## 58. Retry Pattern
Handle transient failure.

## 59. Saga
Distributed transaction.

## 60. CQRS
Separate read/write.

---

# SECTION 7 — BEHAVIORAL

## 61. Production Incident
Explain root cause, fix, prevention, metrics.

## 62. Leadership Example
Show ownership, impact, mentoring.

## 63. Conflict Resolution
Listen, align, resolve professionally.

## 64. Failure Story
Show learning + improvement.

## 65. Greatest Achievement
Problem → action → measurable result.

## 66. Mentoring Engineers
Coaching + code review + autonomy.

## 67. Handling Pressure
Stay calm, prioritize, execute.

## 68. Architecture Decision
Explain tradeoffs clearly.

## 69. Scaling Experience
Show real production scale.

## 70. Debugging Strategy
Metrics → logs → trace → isolate → fix.

---

# SECTION 8 — PRINCIPAL EXPECTATIONS

## 71. Tradeoff Thinking
Performance vs cost vs reliability.

## 72. Distributed Systems
Consistency, partitioning, fault tolerance.

## 73. Observability
Measure before optimize.

## 74. Reliability
Design for failure.

## 75. Performance
Profile first.

## 76. Scalability
Horizontal scaling.

## 77. Security
Defense in depth.

## 78. Cost
Optimize infra usage.

## 79. Ownership
End-to-end responsibility.

## 80. Mentorship
Grow team capability.

---

# SECTION 9 — EXTRA CODING / DESIGN

## 81. Binary Heap
Priority queue implementation.

## 82. Trie
Prefix search optimization.

## 83. Union Find
Connectivity detection.

## 84. Sliding Window Max
Deque O(n).

## 85. Topological Sort
DAG ordering.

## 86. Graph Cycle Detection
DFS / union-find.

## 87. Distributed Lock
Redis/etcd with TTL.

## 88. Consistent Hashing
Load distribution.

## 89. Leader Election
Raft / Zookeeper.

## 90. Gossip Protocol
Cluster membership.

---

# SECTION 10 — FINAL PRINCIPAL PREP

## 91. How to scale system to 10M users
Shard, cache, async, autoscale.

## 92. How to debug latency spike
Trace, metrics, isolate bottleneck.

## 93. How to avoid cascading failure
Circuit breaker + bulkhead.

## 94. How to handle retries safely
Idempotency key.

## 95. How to design multi-region system
Active-active + replication.

## 96. How to design fault tolerant service
Redundancy + failover.

## 97. How to prevent data loss
Replication + backups.

## 98. How to tune database performance
Index + partition + caching.

## 99. How to reduce cloud cost
Autoscale + right sizing.

## 100. Why you fit Principal role
Strong system design, distributed systems, production leadership, scalability mindset.

---

END OF MASTER DOCUMENT
