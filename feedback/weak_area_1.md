# Staff Backend Engineer – Core Concepts Study Guide

This guide focuses on the gaps identified in your interview. It is designed as a **single source of truth** with simple explanations, examples, and Q&A.

---

# 1. Idempotency (VERY IMPORTANT)

## What is Idempotency?

Idempotency means:

> Making the same request multiple times should result in the same outcome (no duplicates).

Example:

* User clicks "Pay" twice
* Only **one order** should be created

---

## How to Implement Idempotency

### Step 1: Client sends Idempotency Key

```
POST /orders
Headers:
  Idempotency-Key: abc-123
```

### Step 2: Store Key

Use **Redis + Database**

* Redis → fast lookup
* DB → source of truth

### Data Model Example

```
idempotency_key
user_id
status (PENDING, SUCCESS, FAILED)
response_data
created_at
```

---

## Handling Race Conditions

### Problem

Two requests arrive at the same time

### Solution

Use Redis atomic operation:

```
SETNX key value
```

OR Lua script

---

## TTL Strategy

* Redis key expires (e.g., 24 hours)
* DB keeps permanent record

---

## What if Redis fails?

* Fallback to DB unique constraint
* Example:
  UNIQUE(idempotency_key)

---

## Interview Questions

### Q: Where do you store idempotency keys?

Answer:

* Redis (fast check)
* DB (durability)

### Q: How do you prevent duplicates?

Answer:

* Atomic write (SETNX / DB unique constraint)

---

# 2. CAP Theorem (CRITICAL)

## What is CAP?

You can only guarantee 2 of 3:

* C → Consistency
* A → Availability
* P → Partition tolerance

In distributed systems → Partition (P) is always required

So choice is:

* CP (Consistency + Partition)
* AP (Availability + Partition)

---

## MySQL Reality

### Single node:

* CA (no partition scenario)

### Distributed (replication):

* CP system

---

## Network Partition Scenario

If network breaks:

* CP system → reject writes
* AP system → allow inconsistent writes

---

## Interview Questions

### Q: Can MySQL be CA?

Answer:

* Only in single-node setup
* Distributed → NO

### Q: What happens during partition?

Answer:

* System must choose:

    * Reject requests (CP)
    * Or allow inconsistency (AP)

---

# 3. Sync vs Async Architecture

## Problem

Synchronous systems:

* Slow
* Fragile
* Hard to scale

---

## Rule of Thumb

### Keep synchronous:

* Authentication
* Basic validation
* Creating initial record

### Make async:

* Notifications
* Driver assignment
* Emails
* Analytics

---

## Example Architecture

```
POST /orders
  → validate
  → create order (PENDING)
  → publish event (Kafka)
```

Consumers:

* Payment Service
* Driver Service
* Notification Service

---

## Benefits

* Scalability
* Fault tolerance
* Decoupling

---

## Interview Questions

### Q: What should be async?

Answer:

* Non-critical path operations

### Q: Why use Kafka?

Answer:

* Decouple services
* Handle retries
* Scale independently

---

# 4. Concurrency & Race Conditions

## Common Problem

Multiple processes update same resource

Example:

* 2 orders assign same driver

---

## Solutions

### 1. Distributed Lock

Redis:

```
SETNX driver_id LOCK
```

---

### 2. State Machine

Driver states:

* AVAILABLE
* RESERVED
* BUSY

---

### 3. DB Locking

```
SELECT ... FOR UPDATE
```

---

## Interview Questions

### Q: How prevent same driver assignment?

Answer:

* Lock OR state transition

---

# 5. Saga Pattern (Distributed Transactions)

## Problem

Multiple services, no global transaction

---

## Solution: Saga

### Flow

1. Order Created
2. Payment Processed
3. Driver Assigned

---

## Two Types

### 1. Orchestration

* Central controller

### 2. Choreography

* Services communicate via events

---

## Compensation

If failure:

* Refund payment
* Cancel order

---

## Interview Questions

### Q: When use Saga?

Answer:

* Distributed transactions

### Q: Example?

Answer:

* Payment success → order fails → refund

---

# 6. Failure Handling & Retries

## Types of Delivery

### At-least-once

* May duplicate

### Exactly-once

* Hard to guarantee

---

## Retry Strategy

* Exponential backoff
* Max retry limit

---

## Dead Letter Queue (DLQ)

Failed messages go here

---

## Interview Questions

### Q: How handle failures?

Answer:

* Retry + DLQ + monitoring

---

# 7. Event-Driven Systems (Kafka Basics)

## Key Concepts

* Producer
* Consumer
* Topic
* Partition

---

## Why Kafka?

* High throughput
* Durable
* Scalable

---

## Common Pitfalls

* Duplicate processing
* Ordering issues

---

# 8. What Staff Engineers Do Differently

## Not Enough:

* Saying "use Redis"

## Expected:

* Explain:

    * Why
    * How
    * Trade-offs

---

## Example

Bad:

> Use Kafka

Good:

> Use Kafka to decouple order creation from driver assignment, allowing retries and independent scaling

---

# Final Advice

## Always Answer Like This:

1. Define problem
2. Give solution
3. Explain trade-offs
4. Mention failure handling

---

## Practice Questions

1. Design idempotent payment API
2. Handle duplicate Kafka messages
3. Prevent double booking problem
4. Design retry system
5. Handle partial failure in distributed system

---

# End

Use this daily before interview. Focus on understanding, not memorizing.
