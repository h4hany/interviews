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
- **Network latency**: The time it takes for data to travel between nodes (e.g., a 100ms delay when a server in New York calls a database in Singapore).
- **Partial failures**: When some parts of the system fail while others continue to work (e.g., the "Login" service is down, but "Search" still works).
- **Concurrency**: Multiple operations happening at the same time, leading to race conditions (e.g., two users trying to buy the last seat on a flight simultaneously).
- **Clock synchronization**: Difficult to keep time perfectly aligned across machines (e.g., Server A thinks it's 10:00:01 while Server B thinks it's 10:00:02).
- **Consistency**: Ensuring all users see the same data (e.g., double-spending a digital wallet because balance was not updated everywhere).
- **Security**: Distributed systems have a larger "attack surface" due to multiple nodes and network communication.
- **Scalability**: Growing the system to handle more load without losing performance.

## 4. What is CAP Theorem?

**Answer:**
CAP Theorem states that in a distributed system, you can only guarantee two out of three:
- **Consistency**: All nodes see the same data at the same time.
- **Availability**: Every request receives a (non-error) response, even if some nodes are down.
- **Partition Tolerance**: The system continues to operate despite network failures (dropped messages/splits).

**Real-World Examples:**
- **CP (Consistency + Partition Tolerance)**: **MongoDB**. If a network split occurs, the system stops taking writes until a new leader is elected to ensure data remains consistent.
- **AP (Availability + Partition Tolerance)**: **Cassandra / DynamoDB**. During a network split, nodes keep accepting writes/reads. Data might be inconsistent for a short time but the system remains available.
- **CA (Consistency + Availability)**: **Standard RDBMS (e.g., Postgres)** on a single node. It provides high consistency and availability but cannot handle network partitions (if the network goes, the system goes).

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
- **Horizontal Scaling**: Add more machines to your regular resource pool (scale out).
    - *Example*: Adding 5 more EC2 instances to handle a surge in Black Friday traffic.
- **Vertical Scaling**: Add more power (CPU, RAM) to an existing machine (scale up).
    - *Example*: Upgrading a database server from 16GB RAM to 128GB RAM to improve query performance.

## 11. What is Load Balancing?

**Answer:**
Load Balancing distributes incoming requests across multiple servers to ensure no single server is overwhelmed.
- *Example*: An Nginx load balancer sits in front of a cluster of 10 web servers, passing incoming HTTP requests to whichever server currently has the least load.

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
Sharding partitions data across multiple databases/servers, enabling horizontal scaling by splitting a large dataset.
- *Example*: A global user database where users with IDs 1-1,000,000 are stored on Server A, and IDs 1,000,001-2,000,000 are stored on Server B.

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
Saga Pattern manages distributed transactions using a sequence of local transactions where each step has a "compensating transaction" if it fails.
- *Example*: In an e-commerce app:
    1. Order Service creates order (Pending).
    2. Payment Service charges customer.
    3. If Payment fails, Order Service runs a "Cancel Order" step to revert state.

## 25. What is Distributed Tracing?

**Answer:**
Distributed Tracing tracks requests across multiple services, providing visibility into system behavior.

## 26. What is Service Discovery?

**Answer:**
Service Discovery allows services to find and communicate with each other dynamically (Eureka, Consul, etcd).

## 27. What is Circuit Breaker Pattern?

**Answer:**
Circuit Breaker prevents cascading failures by stopping requests to failing services and providing fallbacks.
- *Example*: If the "Recommendation" service is timing out, the Circuit Breaker "trips" and the UI displays a generic "Top 10" list instead of failing the whole page.

## 28. What is Bulkhead Pattern?

**Answer:**
Bulkhead isolates resources to prevent one service failure from affecting others.

## 29. What is Retry Pattern?

**Answer:**
Retry Pattern automatically retries failed operations with exponential backoff and jitter.

## 30. What is Idempotency?

**Answer:**
Idempotency ensures operations produce the same result even if executed multiple times.
- *Example*: A "Purchase" API that includes a unique `request_id`. If the user clicks "Pay" twice, the server sees the same ID and doesn't charge them a second time.

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


