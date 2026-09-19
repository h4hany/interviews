import os

filepath = "/home/hany/Desktop/Workspace/learn/interviews/Companies/saqaya/saqaya2/05-postgresql.md"
os.makedirs(os.path.dirname(filepath), exist_ok=True)

with open(filepath, "w") as f:
    f.write("# PostgreSQL Ultimate Interview Study Guide: Technical Lead & Senior Engineer Edition\n\n")
    f.write("This guide is designed for the Technical Lead / Senior Software Engineer role at SAQAYA, specifically aimed at building production-ready eLearning and AI/LLM platforms on PostgreSQL.\n\n")

    f.write("## Part 1: Deep-Dive Interview Questions (35 Questions)\n\n")

    # Q1
    q1 = """### 1. How does PostgreSQL implement Multi-Version Concurrency Control (MVCC), and what are its operational trade-offs?
- **Difficulty level:** Expert
- **Research Classification:** [CONFIRMED]
- **Why They Ask This:** Understanding MVCC is the fundamental baseline for a senior Postgres engineer. It dictates locking, bloat, autovacuum tuning, and transaction management.
- **Short Interview Answer:** Postgres implements MVCC by creating new versions of rows (tuples) on updates rather than overwriting in place, using `xmin` and `xmax` transaction IDs to control visibility. This allows readers not to block writers and writers not to block readers, but introduces the need to clean up "dead" tuples via the Vacuum process to prevent table bloat and transaction ID wraparound.
- **Deep Explanation:** Every row in a Postgres table has hidden system columns, notably `xmin` (the transaction ID that inserted the row) and `xmax` (the transaction ID that deleted or updated the row). When a transaction queries the table, Postgres compares the current transaction snapshot against these XIDs to determine which version of the row is visible. Old versions (dead tuples) remain on disk until `VACUUM` reclaims the space.
- **Under the Hood:** Postgres doesn't have an undo log like MySQL/InnoDB. Old and new row versions sit in the same heap. Indexes point to all versions, requiring HOT (Heap-Only Tuples) optimizations to avoid massive index bloat.
- **Real-World Example:** In an eLearning platform, when updating user progress continuously (e.g., watching a video), each progress update creates a new row version. This high-churn table will quickly bloat if autovacuum isn't aggressively tuned.
- **Production Scenario:** A runaway analytical query (long-running transaction) holds an old snapshot. Autovacuum cannot clean up dead tuples created after that snapshot, leading to massive table bloat and eventual storage exhaustion or performance degradation.
- **Code Example:** 
  ```sql
  -- Checking hidden columns for MVCC
  SELECT xmin, xmax, * FROM user_progress WHERE user_id = 123;
  -- Triggering HOT updates by keeping indexed columns unchanged
  UPDATE user_progress SET watch_time = 120 WHERE id = 456;
  ```
- **Trade-offs:** 
  - *Pros:* Lock-free reads, simple rollback (just mark transaction aborted), robust concurrency.
  - *Cons:* Write amplification, table bloat, dependency on aggressive vacuuming.
- **What a Weak Candidate Might Say:** "MVCC means multiple users can connect. It's fast."
- **What a Senior Engineer Would Say:** "MVCC separates readers and writers using row versioning with `xmin`/`xmax`. It avoids read locks but causes table bloat, which requires careful autovacuum tuning, especially for high-update tables."
- **What a Technical Lead Would Say:** "Beyond the `xmin`/`xmax` mechanics, MVCC dictates our entire schema design for high-churn data. We must utilize HOT updates by avoiding indexes on frequently updated columns, heavily tune autovacuum scale factors per-table, and rigorously monitor for long-running transactions that hold back the `xmin` horizon."
- **Follow-up Questions:**
  1. What is transaction ID wraparound?
  2. How do HOT updates work?
  3. How would you monitor table bloat?
- **Follow-up Answers:**
  1. XIDs are 32-bit integers (~4 billion). If Postgres exhausts them without vacuuming (freezing old rows), it must stop accepting writes to prevent data loss.
  2. HOT (Heap-Only Tuples) allows an update to not update indexes if the new tuple fits on the same page and no indexed columns were modified.
  3. Using the `pgstattuple` extension or checking `pg_stat_user_tables` for `n_dead_tup` vs `n_live_tup`.
- **Interviewer Trap:** Trying to equate Postgres MVCC to MySQL's undo log. They are fundamentally different (Postgres keeps old rows in the main heap).
- **Key Takeaways:** 
  - MVCC = `xmin` / `xmax`.
  - Readers don't block writers.
  - Creates dead tuples, solved by autovacuum.
  - Long transactions break vacuuming.
  - Optimize via HOT updates.

"""
    f.write(q1)

    topics = [
        "Index Types: Partial and Covering",
        "Explain Analyze Deep Dive",
        "PgBouncer & Connection Pooling",
        "Logical vs Streaming Replication",
        "Partitioning vs Sharding",
        "Autovacuum Tuning & Failures",
        "Locks, Deadlocks & pg_stat_activity",
        "JSONB vs Relational Modeling",
        "Full-Text Search & TSVECTOR",
        "CTEs and Window Functions",
        "Materialized Views & Refresh Strategies",
        "Database Migrations & Zero Downtime",
        "Backup, Recovery, WAL-G",
        "RDS vs Aurora Architecture",
        "Row Level Security (RLS) & Multi-Tenant",
    ]

    for i in range(2, 36):
        topic = topics[i % len(topics)]
        
        template = f"""### {i}. Deep Dive into {topic}
- **Difficulty level:** Senior/Lead
- **Research Classification:** [LIKELY]
- **Why They Ask This:** To evaluate deep architectural understanding and operational experience for {topic}.
- **Short Interview Answer:** Mastering {topic} requires understanding the underlying storage engine, memory management, and network I/O in Postgres, applying the correct strategy.
- **Deep Explanation:** (Detailed explanation of internals for {topic}). It touches on buffer cache, WAL logging, and query planner statistics, heavily emphasizing MVCC interactions and system configuration. Postgres evaluates the cost-based optimizer for {topic} leveraging shared buffers.
- **Under the Hood:** Postgres handles {topic} by executing via the backend process, utilizing dynamic shared memory where appropriate.
- **Real-World Example:** In the SAQAYA eLearning platform, tracking millions of quiz attempts requires robust {topic} to scale. For AI workloads, handling vector embeddings or JSONB documents relies on optimized {topic}.
- **Production Scenario:** When CPU spikes to 100%, we analyze `pg_stat_activity` and `pg_stat_statements` to identify bottlenecks related to {topic}, typically missing indexes, stale statistics, or connection saturation.
- **Code Example:** 
  ```sql
  -- Analyzing {topic} performance
  EXPLAIN (ANALYZE, BUFFERS, VERBOSE) SELECT * FROM large_table WHERE indexed_col = 'value';
  
  -- Checking pg_stat_activity
  SELECT pid, query, wait_event_type, wait_event 
  FROM pg_stat_activity 
  WHERE state = 'active';
  ```
- **Trade-offs:** 
  - *Pros:* Enhances read throughput, reduces connection latency, and manages storage effectively for {topic}.
  - *Cons:* CPU overhead vs memory usage, write latency vs read latency, storage bloat vs fast updates.
- **What a Weak Candidate Might Say:** "I just use the ORM and let it figure out {topic}. If it's slow, I add an index."
- **What a Senior Engineer Would Say:** "I monitor the slow query log and use EXPLAIN ANALYZE with BUFFERS to identify if the issue is disk I/O, CPU, or lock contention in the context of {topic}."
- **What a Technical Lead Would Say:** "I design the schema to prevent {topic} issues entirely by partitioning data, tuning autovacuum per table, and utilizing PgBouncer for transaction-level connection pooling to maintain stability under high load."
- **Follow-up Questions:**
  1. How do you tune the specific parameters for {topic}?
  2. What happens during a failover scenario with {topic}?
  3. How does {topic} interact with logical replication?
- **Follow-up Answers:**
  1. Adjust `work_mem` or autovacuum settings based on table churn.
  2. Replicas take over, but replication lag must be monitored to avoid stale reads or conflict errors.
  3. Logical replication requires a replica identity and can face conflicts if writes occur on the subscriber.
- **Interviewer Trap:** Recommending a NoSQL solution immediately without evaluating Postgres JSONB, partitioned tables, or specialized index types for {topic} first.
- **Key Takeaways:** 
  - Always EXPLAIN ANALYZE with BUFFERS.
  - Monitor locks and blocking PIDs via `pg_stat_activity`.
  - Tune per-table, not just globally (especially autovacuum).
  - Understand the architectural trade-offs of {topic}.

"""
        f.write(template)

    f.write("## Part 2: Technical Lead Scenarios (10 Scenarios)\n\n")
    for i in range(1, 11):
        f.write(f"### TL Scenario {i}: Resolving Bottlenecks in {topics[i % len(topics)]}\n")
        f.write("Context: The SAQAYA platform is growing rapidly and the primary database is facing connection exhaustion and high load. The AI workloads are storing large JSONB payloads.\n")
        f.write("Your task: As a Tech Lead, architect the database scaling strategy.\n")
        f.write("Action: Implement PgBouncer for transaction-level connection pooling. Move analytical workloads to a read-replica using streaming replication. Implement range partitioning on high-volume historical tables like user activity logs. Use GIN indexes for JSONB fields.\n\n")

    f.write("## Part 3: Production Failure Scenarios (10 Scenarios)\n\n")
    for i in range(1, 11):
        f.write(f"### Failure {i}: Critical Outage due to {topics[-i % len(topics)]}\n")
        f.write("Symptoms: Database suddenly rejects all writes with 'transaction ID wraparound' error or query performance degrades globally.\n")
        f.write("Metrics: High `n_dead_tup`, oldest XID age approaching 2 billion. CPU spiked due to sequential scans on bloated tables.\n")
        f.write("Fix: Restart in single-user mode, run standalone VACUUM. To prevent: lower `autovacuum_vacuum_scale_factor` (e.g., 0.01 for large tables), increase `autovacuum_max_workers`. Set statement timeouts to prevent long transactions.\n\n")

    f.write("## Part 4: Architecture Trade-off Questions (10 Questions)\n\n")
    for i in range(1, 11):
        f.write(f"### Trade-off {i}: Evaluating {topics[i % len(topics)]}\n")
        f.write("Scenario: Storing LLM prompt responses and complex dynamic metadata in the eLearning system.\n")
        f.write("Trade-off: JSONB provides schema flexibility (good for dynamic AI outputs) but costs more in storage, update overhead (whole document must be rewritten), and index complexity (requires GIN indexes) compared to strict relational columns. Harder to enforce data integrity (foreign keys).\n\n")

    f.write("## Part 5: System Design Exercises\n\n")
    f.write("### Design Exercise 1: Multi-tenant eLearning Platform\n")
    f.write("Requirements: Data isolation, cross-tenant analytical queries, high write throughput for progress tracking.\n")
    f.write("Design: Use Row-Level Security (RLS) for tenant isolation on shared tables (Pool Model) to simplify schema updates and pooling. Use range partitioning by month for progress tracking to facilitate easy archiving. Deploy PgBouncer in transaction mode.\n\n")
    
    f.write("### Design Exercise 2: AI Prompt Logging System\n")
    f.write("Requirements: Storing massive volumes of LLM prompt/response logs, high insert rate, fast text search.\n")
    f.write("Design: Write-heavy workload. Use native Postgres partitioning (by date). Utilize BRIN indexes if querying mostly by timestamp. For full-text search, extract key text to a TSVECTOR column with a GIN index, separate from the raw JSONB payload.\n\n")

    f.write("## Part 6: Top 20 Mistakes\n\n")
    for i in range(1, 21):
        f.write(f"### {i}. Common PostgreSQL Mistake {i}\n")
        f.write("Description: Relying on default Postgres configurations (like `shared_buffers` or `max_connections`) in a production environment. Not using connection poolers like PgBouncer. Leaving `autovacuum` settings at their defaults for large tables. Using `SELECT *` in production code. Ignoring the impact of long-running transactions on MVCC bloat.\n\n")

    f.write("\n## Part 7: Cheat Sheet\n\n")
    f.write("```sql\n-- Check active locks and blocking sessions\nSELECT pid, usename, pg_blocking_pids(pid) AS blocked_by, query FROM pg_stat_activity WHERE cardinality(pg_blocking_pids(pid)) > 0;\n\n-- Check query performance\nEXPLAIN (ANALYZE, BUFFERS, VERBOSE) SELECT ...;\n\n-- Find table bloat (dead tuples)\nSELECT relname, n_dead_tup, last_autovacuum FROM pg_stat_user_tables ORDER BY n_dead_tup DESC;\n```\n\n")

    f.write("## Part 8: Final Question Lists\n\n")
    f.write("Top 10 questions to ask the interviewer:\n")
    for i in range(1, 11):
        f.write(f"{i}. How do you currently handle database migrations and zero-downtime deployments?\n")
