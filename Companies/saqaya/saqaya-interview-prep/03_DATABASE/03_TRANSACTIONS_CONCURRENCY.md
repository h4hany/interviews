# Transactions & Concurrency - Technical Lead Level

## 1. Transaction Isolation Levels

PostgreSQL supports 4 standard SQL isolation levels, though internally Read Uncommitted behaves as Read Committed.

### Read Committed (Default)
- **What**: A transaction sees only data committed before the query began.
- **Anomalies**: Non-repeatable reads (re-reading a row yields a different value if another TX committed an update), Phantom reads.
- **When to use**: Default. Good for most web workloads.

### Repeatable Read
- **What**: A transaction sees only data committed before the *transaction* began. The snapshot is taken at the first statement of the TX.
- **Anomalies**: Phantom reads are prevented in PG's implementation, but serialization anomalies can occur.
- **Failure Mode**: If you try to update a row that was updated by another TX since your snapshot started, you get a `could not serialize access due to concurrent update` error. You MUST write application logic to retry the transaction.

### Serializable
- **What**: Strictest level. Guarantees that concurrent transactions execute as if they were run serially one after another.
- **Internals**: Uses Predicate Locking (tracking which ranges of data a TX reads) to detect write skew and cycle dependencies.
- **Failure Mode**: Frequent serialization failures requiring application-level retries. High overhead.

## 2. Lock Types and Deadlocks

### Row Locks
- Automatically acquired on `UPDATE`, `DELETE`, `SELECT FOR UPDATE`.
- Don't block reads (thanks to MVCC), but block other writers of the *same row*.
- Stored in the page data itself (`xmax`), not in memory, meaning you can lock millions of rows without running out of RAM.

### Table Locks
- Acquired for DDL (`ALTER TABLE`, `TRUNCATE`). `AccessExclusiveLock` blocks everything.

### Deadlocks
- **What**: TX A locks Row 1, TX B locks Row 2. TX A tries to lock Row 2, TX B tries to lock Row 1. Both wait forever.
- **Detection**: PG runs a deadlock detector (timeout controlled by `deadlock_timeout`, default 1s). It aborts one of the TXs.
- **Prevention**: Always acquire locks in the same consistent order across the application.

## 3. Optimistic vs Pessimistic Locking

### Pessimistic Locking
- Uses `SELECT ... FOR UPDATE`. Locks the row in the DB immediately.
- **Pros**: Strong consistency, simple to reason about.
- **Cons**: Can cause lock contention, DB-level deadlocks, and connection exhaustion if held during slow external API calls.

### Optimistic Locking
- Uses a `version` column. `UPDATE tbl SET val = new, version = 2 WHERE id = 1 AND version = 1`.
- **Pros**: No DB locks held across user think time or external calls. Highly scalable.
- **Cons**: Application must handle the case where 0 rows are updated (meaning version changed) and retry.

## Interview Questions

## Question 1: SELECT FOR UPDATE and Concurrency
### What the interviewer is testing
Knowledge of row-level locking, wait behavior, and avoiding lock contention in job queues/concurrent workers.

### Short answer
`SELECT FOR UPDATE` locks rows to prevent concurrent modifications. To build concurrent consumers (e.g., queue workers) without them blocking each other waiting for locks, we use `SELECT FOR UPDATE SKIP LOCKED`.

### Detailed answer
When multiple workers query the database for pending jobs `SELECT * FROM jobs WHERE status = 'pending' LIMIT 1 FOR UPDATE`, Worker 1 locks Job A. Worker 2's query evaluates Job A, sees the lock, and halts, waiting for Worker 1 to commit. This destroys concurrency.
By appending `SKIP LOCKED`, Worker 2 will instantly skip Job A and lock Job B.

### How it works internally
PG attempts to lock the tuple. If the lock is held by another transaction, standard behavior is to wait (subject to `lock_timeout`). With `SKIP LOCKED`, the heap fetch mechanism simply ignores the locked tuple and moves to the next valid tuple in the scan.

### Real-world example
Implementing a high-throughput outbox pattern or background job queue directly in PostgreSQL. Using `FOR UPDATE SKIP LOCKED` allows 50 concurrent Node.js processes to claim distinct rows without any lock contention.

### Trade-offs
`SKIP LOCKED` provides inconsistent views of the data (you don't see rows that match your WHERE clause but are locked). It is exclusively for work-stealing/queue patterns, not for business logic reporting.

### Strong Technical Lead answer
"For generic business logic protecting a bank balance, I use `FOR UPDATE`. But if I'm building a transactional outbox or job queue, standard `FOR UPDATE` serializes the workers. I mandate `FOR UPDATE SKIP LOCKED`. Furthermore, I ensure the lock is held for the absolute minimum time—claim the row, mark it 'processing', commit, and then do the heavy work asynchronously, to keep database transactions extremely short and avoid long-held locks or idle-in-transaction connections."

## Question 2: Handling Concurrency Bugs (Lost Updates)
### What the interviewer is testing
Ability to identify race conditions and apply correct isolation levels or locking strategies.

### Short answer
A lost update occurs when two transactions read a value, modify it in memory, and write it back, causing one's update to overwrite the other. I prevent this using either atomic DB operations, Optimistic Locking (versioning), or Pessimistic Locking (FOR UPDATE).

### Detailed answer
Assume an ORM reads a user: `user = find(1)`. `user.balance += 100`. `user.save()`.
If TX 1 and TX 2 do this concurrently, both read 100. Both save 200. We lost 100.
**Solutions**:
1. **Atomic Update**: `UPDATE users SET balance = balance + 100 WHERE id = 1;` (Evaluates balance at execution time).
2. **Pessimistic**: `SELECT * FROM users WHERE id = 1 FOR UPDATE;` (TX 2 blocks until TX 1 commits).
3. **Optimistic**: `UPDATE users SET balance = 200, version = 2 WHERE id = 1 AND version = 1;` (TX 2 fails, app retries).

### Strong Technical Lead answer
"Lost updates are the most common ORM-induced concurrency bug. For counters, I force atomic SQL updates. For complex entities, I strongly prefer Optimistic Locking with a version column (or `updated_at` timestamp). It scales perfectly because it holds no locks and moves the conflict resolution to the application tier. I enforce this at the ORM layer (e.g., Prisma's optimistic concurrency or Hibernate's @Version) so developers don't have to remember to write it. I only use Pessimistic locking for highly contended financial operations where we want the DB to serialize access."
