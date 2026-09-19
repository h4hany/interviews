# 02 Distributed Systems

## 1. Consensus Algorithms

### Raft
Raft is a consensus algorithm designed to be easy to understand. It decomposes consensus into leader election, log replication, and safety.
- **Leader Election:** Nodes start as Followers. If they don't hear a heartbeat, they become Candidates and request votes. The one with majority becomes Leader.
- **Log Replication:** Leader accepts writes, appends to its log, sends AppendEntries RPCs to followers. Once a majority write to their logs, the leader commits and applies to its state machine.
- **Split-Brain:** Raft prevents this by requiring a majority (quorum) to elect a leader. In a partition, only the side with the majority can elect a leader and accept writes.

### Paxos
More complex but foundational. Operates in phases: Prepare/Promise, Accept/Accepted. Harder to implement in practice compared to Raft, which is why systems like etcd and Consul use Raft.

## 2. Distributed Transactions

### Two-Phase Commit (2PC)
- **Phase 1 (Prepare):** Coordinator asks all participants if they can commit.
- **Phase 2 (Commit):** If all say yes, coordinator sends commit. If any say no, coordinator sends rollback.
- **Trade-offs:** Blocking protocol. If coordinator fails during phase 2, participants are locked waiting. Not highly available.

### Saga Pattern
Used in microservices. A long-running transaction broken into local transactions.
- **Choreography:** Services publish events, other services listen and act.
- **Orchestration:** A central controller tells services what local transactions to execute.
- **Compensation:** If a step fails, the saga executes compensating transactions to undo the previous steps.

## 3. Eventual Consistency & CRDTs
**Eventual Consistency:** System guarantees that updates will propagate through the system and all nodes will eventually be consistent.
**CRDTs (Conflict-free Replicated Data Types):** Data structures that can be replicated across a network and updated independently, and mathematically guarantee that they will converge to the same state. Examples: G-Counter (Grow-only), PN-Counter, LWW-Element-Set.

## 4. Vector Clocks
A mechanism for generating a partial ordering of events in a distributed system and detecting causality violations.
- Each node keeps a vector of logical clocks (one for each node).
- On local event, node increments its own clock.
- On sending a message, includes the vector.
- On receiving, node updates its vector to `max(local, received)` and increments its own.
- Used in Amazon Dynamo.

## 5. Gossip Protocols
Nodes periodically pick a few random peers and exchange state information. Used for dissemination (e.g., membership in a cluster, failure detection). Extremely scalable and robust against network failures.

## 6. Leader Election & Locks
- **Leader Election:** Used to designate a single node to perform a task to avoid conflicts. (e.g., using Zookeeper or etcd).
- **Distributed Locking:** Ensuring only one process acts on a resource. Redis `SETNX` (Redlock algorithm), or Zookeeper ephemeral nodes.

### Code Example: Redis Distributed Lock (Python)
```python
import redis
import time
import uuid

r = redis.Redis(host='localhost', port=6379, db=0)

def acquire_lock(lock_name, acquire_timeout=10, lock_timeout=10):
    identifier = str(uuid.uuid4())
    end = time.time() + acquire_timeout
    while time.time() < end:
        if r.set(lock_name, identifier, ex=lock_timeout, nx=True):
            return identifier
        time.time().sleep(0.001)
    return False

def release_lock(lock_name, identifier):
    pipe = r.pipeline(True)
    while True:
        try:
            pipe.watch(lock_name)
            if pipe.get(lock_name).decode('utf-8') == identifier:
                pipe.multi()
                pipe.delete(lock_name)
                pipe.execute()
                return True
            pipe.unwatch()
            break
        except redis.WatchError:
            pass
    return False
```

## 7. Interview Questions & Answers
**Q: How do you achieve exactly-once semantics in a distributed system?**
*A:* True exactly-once delivery is impossible over unreliable networks. You achieve exactly-once processing by combining at-least-once delivery with idempotent operations. Give each message a unique ID, store the ID in the database atomically along with the business state change. If the message is redelivered, the database constraint will reject the duplicate ID.
