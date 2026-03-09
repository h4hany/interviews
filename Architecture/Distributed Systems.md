# Distributed Systems Interview Questions

## 1. What is a Distributed System?

**Answer:**
A Distributed System is a collection of independent computers that appear to users as a single coherent system. Components communicate over a network.

## 2. What are the characteristics of Distributed Systems?

**Answer:**
- Multiple autonomous components
- Communication over network
- Concurrency
- No global clock
- Independent failures
- Transparency (location, access, migration)

## 3. What are the challenges of Distributed Systems?

**Answer:**
- Network latency
- Partial failures
- Concurrency
- Clock synchronization
- Consistency
- Security
- Scalability

## 4. What is CAP Theorem?

**Answer:**
CAP Theorem states that in a distributed system, you can only guarantee two out of three:
- **Consistency**: All nodes see same data
- **Availability**: System remains operational
- **Partition Tolerance**: System continues despite network failures

## 5. What is the difference between ACID and BASE?

**Answer:**
- **ACID**: Strong consistency, transactions (traditional databases).
- **BASE**: Eventual consistency, high availability (NoSQL, distributed systems).

## 6. What is Consistency in Distributed Systems?

**Answer:**
Consistency ensures all nodes see the same data at the same time. Types: strong, eventual, weak, causal.

## 7. What is the difference between Strong and Eventual Consistency?

**Answer:**
- **Strong Consistency**: All nodes see updates immediately (synchronous).
- **Eventual Consistency**: All nodes eventually converge to same state (asynchronous).

## 8. What is Partition Tolerance?

**Answer:**
Partition Tolerance means the system continues operating despite network partitions (message loss or delay).

## 9. What is Availability in Distributed Systems?

**Answer:**
Availability means the system remains operational and responds to requests, even during failures.

## 10. What is the difference between Horizontal and Vertical Scaling?

**Answer:**
- **Horizontal Scaling**: Add more machines (scale out).
- **Vertical Scaling**: Add more resources to existing machine (scale up).

## 11. What is Load Balancing?

**Answer:**
Load Balancing distributes incoming requests across multiple servers to ensure no single server is overwhelmed.

## 12. What is the difference between Client-Side and Server-Side Load Balancing?

**Answer:**
- **Client-Side**: Client selects server (service discovery).
- **Server-Side**: Load balancer selects server (hardware/software LB).

## 13. What is Replication?

**Answer:**
Replication creates copies of data across multiple nodes for availability, performance, and fault tolerance.

## 14. What is the difference between Master-Slave and Master-Master Replication?

**Answer:**
- **Master-Slave**: One master handles writes, slaves replicate (read scaling).
- **Master-Master**: Multiple masters handle writes (conflict resolution needed).

## 15. What is Sharding?

**Answer:**
Sharding partitions data across multiple databases/servers, enabling horizontal scaling.

## 16. What is the difference between Replication and Sharding?

**Answer:**
- **Replication**: Same data on multiple nodes (availability).
- **Sharding**: Different data on different nodes (scalability).

## 17. What is Distributed Consensus?

**Answer:**
Distributed Consensus ensures multiple nodes agree on a value or decision (Paxos, Raft algorithms).

## 18. What is Raft Algorithm?

**Answer:**
Raft is a consensus algorithm for managing replicated logs, electing leaders, and handling failures.

## 19. What is Paxos Algorithm?

**Answer:**
Paxos is a consensus algorithm for distributed systems to agree on a value despite failures.

## 20. What is Leader Election?

**Answer:**
Leader Election selects a single node to coordinate operations in a distributed system.

## 21. What is Distributed Locking?

**Answer:**
Distributed Locking coordinates access to shared resources across multiple nodes (Redis, ZooKeeper, etcd).

## 22. What is Two-Phase Commit (2PC)?

**Answer:**
2PC is a protocol for distributed transactions, ensuring all nodes commit or abort together (blocking, not fault-tolerant).

## 23. What is Three-Phase Commit (3PC)?

**Answer:**
3PC improves 2PC by adding a pre-commit phase, reducing blocking but still not fully fault-tolerant.

## 24. What is Saga Pattern?

**Answer:**
Saga Pattern manages distributed transactions using a sequence of local transactions with compensation.

## 25. What is Distributed Tracing?

**Answer:**
Distributed Tracing tracks requests across multiple services, providing visibility into system behavior.

## 26. What is Service Discovery?

**Answer:**
Service Discovery allows services to find and communicate with each other dynamically (Eureka, Consul, etcd).

## 27. What is Circuit Breaker Pattern?

**Answer:**
Circuit Breaker prevents cascading failures by stopping requests to failing services and providing fallbacks.

## 28. What is Bulkhead Pattern?

**Answer:**
Bulkhead isolates resources to prevent one service failure from affecting others.

## 29. What is Retry Pattern?

**Answer:**
Retry Pattern automatically retries failed operations with exponential backoff and jitter.

## 30. What is Idempotency?

**Answer:**
Idempotency ensures operations produce the same result when executed multiple times, critical for retries.

## 31. What is Distributed Caching?

**Answer:**
Distributed Caching stores frequently accessed data across multiple nodes for performance (Redis Cluster, Memcached).

## 32. What is Cache Invalidation?

**Answer:**
Cache Invalidation removes or updates cached data when source data changes (write-through, write-behind, TTL).

## 33. What is Eventual Consistency?

**Answer:**
Eventual Consistency means all nodes will eventually have consistent data, but not immediately.

## 34. What is Vector Clocks?

**Answer:**
Vector Clocks track causality in distributed systems, enabling detection of event ordering.

## 35. What is Lamport Timestamps?

**Answer:**
Lamport Timestamps provide a logical clock for ordering events in distributed systems.

## 36. What is Distributed Transactions?

**Answer:**
Distributed Transactions ensure ACID properties across multiple nodes (challenging, often use eventual consistency).

## 37. What is the difference between Synchronous and Asynchronous Communication?

**Answer:**
- **Synchronous**: Request-response, blocking, simpler.
- **Asynchronous**: Event-driven, non-blocking, more complex.

## 38. What is Message Queue?

**Answer:**
Message Queue enables asynchronous communication between services, providing decoupling and reliability.

## 39. What is Distributed System Monitoring?

**Answer:**
Monitoring tracks system health, performance, and errors across distributed components (metrics, logs, traces).

## 40. What is Distributed System Best Practices?

**Answer:**
- Design for failure
- Implement idempotency
- Use circuit breakers
- Monitor everything
- Implement retries with backoff
- Use distributed tracing
- Design for eventual consistency
- Implement health checks
- Use service discovery
- Handle network partitions gracefully

