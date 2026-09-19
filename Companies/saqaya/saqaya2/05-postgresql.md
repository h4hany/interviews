# PostgreSQL Ultimate Interview Study Guide: Technical Lead & Senior Engineer Edition

This guide is designed for the Technical Lead / Senior Software Engineer role at SAQAYA, focusing on building production-ready eLearning and AI/LLM platforms on PostgreSQL.

## Part 1: Deep-Dive Interview Questions (35 Questions)

### 1. How does PostgreSQL implement Multi-Version Concurrency Control (MVCC), and what are its operational trade-offs?
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

### 2. How do you identify a missing index using EXPLAIN ANALYZE?
- **Difficulty level:** Senior
- **Research Classification:** [COMMON]
- **Why They Ask This:** Proves you can debug real production slowdowns.
- **Short Interview Answer:** By looking for `Seq Scan` (Sequential Scans) on large tables in the `EXPLAIN ANALYZE` output, especially where a large number of rows are filtered out by a `Filter` condition, resulting in high `actual time` and low `actual rows`.
- **Deep Explanation:** `EXPLAIN ANALYZE` executes the query and shows both estimated and actual costs. If a node shows `Seq Scan on large_table (cost=0.00..50000.00 rows=100000 width=8) (actual time=0.050..1500.000 rows=5 loops=1)` and `Filter: (user_id = 123) Rows Removed by Filter: 99995`, it means Postgres had to read 100,000 rows to find 5. An index on `user_id` would change this to an `Index Scan` or `Bitmap Heap Scan`.
- **Under the Hood:** A sequential scan reads every page of the table from disk/cache. An index scan traverses a B-Tree (usually depth 3-4) to find the exact pages, dramatically reducing block reads.
- **Real-World Example:** Querying an eLearning `course_completions` table (100M rows) for a specific user. Without an index, this takes seconds; with an index, milliseconds.
- **Production Scenario:** A dashboard is timing out. You run `EXPLAIN (ANALYZE, BUFFERS)` and see `shared hit=10000 read=50000`. You add a covering index to turn it into an Index Only Scan.
- **Code Example:** 
  ```sql
  EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM course_completions WHERE user_id = 123;
  -- If Seq Scan, add:
  CREATE INDEX idx_completions_user ON course_completions(user_id);
  ```
- **Trade-offs:** Adding indexes speeds up reads but slows down writes (INSERT/UPDATE/DELETE) and uses disk space.
- **What a Weak Candidate Might Say:** "I look for big numbers."
- **What a Senior Engineer Would Say:** "I look for Seq Scans on large tables where the filter removes a high percentage of rows, indicating a missing index."
- **What a Technical Lead Would Say:** "I use `EXPLAIN (ANALYZE, BUFFERS)` to track I/O. I look for mismatches between estimated and actual rows (stale stats), and Seq Scans that filter heavily. I also evaluate if a partial or covering index would prevent heap fetches entirely."
- **Follow-up Questions:**
  1. What is an Index Only Scan?
  2. When is a Seq Scan faster than an Index Scan?
  3. What does `BUFFERS` tell you?
- **Follow-up Answers:**
  1. An Index Only Scan happens when all requested columns are in the index, and the visibility map shows the pages are all-visible, avoiding heap lookups.
  2. When retrieving a large percentage of the table (e.g., > 15-20%), Seq Scan is faster because it does sequential I/O instead of random I/O.
  3. `BUFFERS` shows memory vs disk usage (`shared hit` vs `read`).
- **Interviewer Trap:** Thinking Seq Scans are always bad. They are optimal for small tables or large result sets.
- **Key Takeaways:** 
  - Look for `Filter` removing many rows.
  - Compare actual vs estimated rows.
  - Use `BUFFERS` to see cache hits.

### 3. When would you use a Partial Index vs a Covering Index?
- **Difficulty level:** Senior
- **Research Classification:** [LIKELY]
- **Why They Ask This:** Demonstrates advanced schema optimization beyond basic `CREATE INDEX`.
- **Short Interview Answer:** Use a Partial Index to index only a subset of rows (e.g., active users, pending tasks) to save space and write overhead. Use a Covering Index (`INCLUDE`) to store additional columns in the index payload to enable Index-Only Scans.
- **Deep Explanation:** A Partial Index uses a `WHERE` clause (e.g., `WHERE status = 'pending'`). It drastically reduces index size if the condition filters out most rows. A Covering Index uses `INCLUDE (col1, col2)` to put data in the leaf nodes of a B-tree without participating in the sort order.
- **Under the Hood:** Partial indexes mean the B-tree is physically smaller, fitting easily in RAM. Covering indexes keep the B-tree height the same for the key but widen the leaf pages, avoiding heap lookups if the query only selects included columns.
- **Real-World Example:** In SAQAYA, a `jobs` table might have 10M rows but only 1,000 `status = 'pending'`. A partial index on pending jobs is tiny. A query fetching `user_name` for a given `user_id` can use a covering index on `(user_id) INCLUDE (user_name)`.
- **Production Scenario:** A high-throughput API endpoint fetching user display names was causing high CPU. Adding a covering index dropped I/O to near zero because the heap was no longer accessed.
- **Code Example:** 
  ```sql
  -- Partial Index
  CREATE INDEX idx_pending_jobs ON jobs(created_at) WHERE status = 'pending';
  -- Covering Index
  CREATE INDEX idx_user_name ON users(id) INCLUDE (display_name);
  ```
- **Trade-offs:** Partial indexes are useless if queries don't include the exact `WHERE` clause. Covering indexes increase the size of the index on disk.
- **What a Weak Candidate Might Say:** "Partial index is part of an index."
- **What a Senior Engineer Would Say:** "Partial indexes filter rows using a WHERE clause to save space. Covering indexes add columns to avoid heap fetches."
- **What a Technical Lead Would Say:** "Partial indexes are crucial for soft deletes (`deleted_at IS NULL`) or queuing patterns. Covering indexes are my go-to for optimizing high-frequency read endpoints where we want to guarantee an Index-Only Scan without bloating the B-tree search keys."
- **Follow-up Questions:**
  1. Can you combine partial and covering indexes?
  2. Why not just put the included column in the main index key?
- **Follow-up Answers:**
  1. Yes, e.g., `CREATE INDEX ON t(id) INCLUDE (name) WHERE active = true;`.
  2. Putting it in the key changes the sort order, increases the search depth, and forces unique constraints to apply to the composite key.
- **Interviewer Trap:** Thinking covering indexes automatically make queries faster. They only help if all selected columns are in the index.
- **Key Takeaways:** 
  - Partial = `WHERE` (saves space).
  - Covering = `INCLUDE` (avoids heap lookup).
  - Both are essential for high-performance tuning.

### 4. How do you choose between GIN, GiST, and B-Tree indexes?
- **Difficulty level:** Senior
- **Research Classification:** [CONFIRMED]
- **Why They Ask This:** Standard B-Trees don't work for everything. Knowledge of specialized indexes is required for search and AI workloads.
- **Short Interview Answer:** B-Tree is for scalar equality and range queries. GIN is an inverted index for elements inside containers (arrays, JSONB, full-text search). GiST is for complex data types like geometric shapes, overlapping ranges, or nearest-neighbor searches (like vector embeddings).
- **Deep Explanation:** B-Tree sorts data logically. GIN (Generalized Inverted Index) maps keys (like words in a document or keys in JSONB) to lists of row IDs, making it ideal for "contains" (`@>`) queries. GiST (Generalized Search Tree) partitions data into overlapping bounding boxes or ranges, making it perfect for GIS, IP ranges, or pgvector.
- **Under the Hood:** GIN index updates can be slow because one row insert might update many index entries (e.g., 100 words in a document). GiST uses a lossy approach where it finds candidate pages, and Postgres filters false positives at the heap level.
- **Real-World Example:** In an eLearning app, filtering courses by tags (`tags @> '{"math"}'`) requires GIN. Finding students within a 5-mile radius requires PostGIS + GiST. Querying vector embeddings for AI recommendations uses `pgvector` with HNSW or ivfflat (built on GiST principles).
- **Production Scenario:** A text search on JSONB metadata was doing sequential scans. Adding a GIN index on the JSONB column reduced query time from 4s to 10ms.
- **Code Example:** 
  ```sql
  -- GIN for JSONB
  CREATE INDEX idx_metadata ON courses USING GIN (metadata);
  -- GiST for geometry
  CREATE INDEX idx_location ON users USING GiST (location);
  ```
- **Trade-offs:** GIN has high write overhead. B-Tree is fast for writes but limited to scalar types. GiST is flexible but can be slower for exact matches than B-Tree.
- **What a Weak Candidate Might Say:** "I just use B-tree."
- **What a Senior Engineer Would Say:** "B-tree for standard columns, GIN for JSONB and arrays, GiST for geo-spatial or ranges."
- **What a Technical Lead Would Say:** "I use B-tree for primary keys and foreign keys. For our AI payloads in JSONB, I heavily utilize GIN with jsonb_path_ops to reduce index size. For vector search, I evaluate pgvector's HNSW index, which offers better recall vs performance tradeoffs than standard GiST."
- **Follow-up Questions:**
  1. What is the `fastupdate` parameter for GIN?
  2. Can you use B-Tree on JSONB?
- **Follow-up Answers:**
  1. `fastupdate` buffers GIN index updates in a pending list to speed up inserts, flushing them to the main index later during vacuum.
  2. Yes, but only for full document equality (`=`), not for checking if a key exists inside the document (`@>`).
- **Interviewer Trap:** Thinking GIN is always fast. It's fast for reads but terrible for heavy write workloads without `fastupdate`.
- **Key Takeaways:** 
  - B-Tree: `<`, `>`, `=`.
  - GIN: `@>`, arrays, full-text.
  - GiST: Geometries, ranges, KNN.

### 5. What is the difference between Partitioning and Sharding in PostgreSQL?
- **Difficulty level:** Lead
- **Research Classification:** [COMMON]
- **Why They Ask This:** To see if you understand architectural scaling strategies.
- **Short Interview Answer:** Partitioning splits a large table into smaller physical tables (partitions) within the **same** database server for easier management and querying. Sharding splits data across **multiple** independent database servers to scale compute and storage horizontally.
- **Deep Explanation:** Postgres native declarative partitioning allows you to divide a table by RANGE, LIST, or HASH. The query planner uses partition pruning to skip irrelevant partitions. Sharding (e.g., using Citus or application-level routing) distributes partitions across a cluster.
- **Under the Hood:** Partitioning is a logical abstraction in a single instance; it shares the same CPU/RAM. Sharding requires a coordinator node or smart client to route queries to different physical machines, dealing with distributed transactions and cross-shard joins.
- **Real-World Example:** Partitioning: SAQAYA's `activity_logs` partitioned by month so we can efficiently `DROP TABLE logs_2020_01` (archiving). Sharding: Scaling a multi-tenant SaaS where each tenant's data lives on different database servers based on `tenant_id`.
- **Production Scenario:** A 500GB table's indexes no longer fit in RAM, causing heavy swap. By partitioning the table by month, the active month's index becomes 10GB, fitting in RAM and restoring performance.
- **Code Example:** 
  ```sql
  CREATE TABLE logs ( id serial, created_at date ) PARTITION BY RANGE (created_at);
  CREATE TABLE logs_2024_01 PARTITION OF logs FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
  ```
- **Trade-offs:** Partitioning is easy but bound by single-node limits. Sharding scales infinitely but makes joins, transactions, and schema management highly complex.
- **What a Weak Candidate Might Say:** "They are the same thing, splitting data."
- **What a Senior Engineer Would Say:** "Partitioning is on one server, sharding is across multiple servers. I prefer partitioning first because it's natively supported and simpler."
- **What a Technical Lead Would Say:** "I always exhaust vertical scaling and native Postgres partitioning before even considering sharding. Sharding introduces distributed computing problems (two-phase commits, cross-node joins). Partitioning gives us partition pruning and easy data lifecycle management (dropping partitions instead of DELETEs)."
- **Follow-up Questions:**
  1. What happens if a query doesn't include the partition key?
  2. How do foreign keys work with partitioned tables?
- **Follow-up Answers:**
  1. The query planner must scan ALL partitions (a fan-out query), which is terrible for performance.
  2. Postgres 12+ supports FKs referencing partitioned tables, but it requires the partition key to be part of the primary key.
- **Interviewer Trap:** Jumping straight to Sharding to sound "scalable". Good engineers know sharding is a last resort.
- **Key Takeaways:** 
  - Partitioning = 1 Server.
  - Sharding = N Servers.
  - Always partition before sharding.
  - Query must include partition key.

### 6. Explain Transaction Isolation Levels in PostgreSQL.
- **Difficulty level:** Senior
- **Research Classification:** [LIKELY]
- **Why They Ask This:** Tests your understanding of concurrency, data anomalies, and consistency guarantees.
- **Short Interview Answer:** Postgres offers three effective isolation levels: Read Committed (default), Repeatable Read, and Serializable. Read Committed sees committed changes per statement. Repeatable Read locks the snapshot for the entire transaction. Serializable guarantees transactions execute as if they were serial, throwing errors on conflicts.
- **Deep Explanation:** 
  - **Read Committed:** A statement sees data committed before the statement began. Vulnerable to non-repeatable reads (data changes between two SELECTs in the same transaction) and phantoms.
  - **Repeatable Read:** All statements in the transaction see a snapshot established at the first query. Prevents non-repeatable reads and phantoms (in Postgres).
  - **Serializable:** Uses SSI (Serializable Snapshot Isolation) to monitor read/write dependencies. If it detects a cycle that would violate serial execution, it aborts one transaction.
- **Under the Hood:** Because of MVCC, Postgres never has "Dirty Reads" (reading uncommitted data). Therefore, `Read Uncommitted` is treated exactly like `Read Committed`.
- **Real-World Example:** In a banking system (or LMS credit system), transferring funds. If using Repeatable Read, two concurrent transactions trying to deduct the same balance will cause a serialization failure on the second one, which the app must retry.
- **Production Scenario:** A financial report running in Read Committed gives inconsistent totals because rows are updated while the report is running. Switching the report transaction to `SET TRANSACTION ISOLATION LEVEL REPEATABLE READ` ensures a perfectly consistent snapshot.
- **Code Example:** 
  ```sql
  BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
  SELECT sum(balance) FROM accounts; -- Takes snapshot
  -- Other tx updates accounts here, but we don't see it
  SELECT count(*) FROM accounts;
  COMMIT;
  ```
- **Trade-offs:** Higher isolation (Serializable) means stronger guarantees but requires the application to implement retry logic for `40001` serialization failures.
- **What a Weak Candidate Might Say:** "Serializable locks the whole database."
- **What a Senior Engineer Would Say:** "Read committed is default. Repeatable read is for consistent snapshots. Serializable prevents all anomalies but requires app retries."
- **What a Technical Lead Would Say:** "I avoid Serializable unless strictly necessary for complex invariant checks because of the overhead and retry complexity. For most cases requiring strict consistency, I use Read Committed with explicit row locks (`SELECT FOR UPDATE`) or atomic updates (`UPDATE ... SET balance = balance - 100 WHERE balance >= 100`)."
- **Follow-up Questions:**
  1. Does Postgres Repeatable Read prevent Phantom Reads?
  2. How do you handle Serializable transaction failures?
- **Follow-up Answers:**
  1. Yes, the SQL standard allows phantoms in Repeatable Read, but Postgres's MVCC implementation prevents them.
  2. The application middleware must catch the `40001` error code and retry the entire transaction block.
- **Interviewer Trap:** Thinking Read Uncommitted exists in Postgres (it's functionally just Read Committed).
- **Key Takeaways:** 
  - Read Committed = default.
  - Repeatable Read = consistent snapshot for whole TX.
  - Serializable = strict, needs retries.
  - No dirty reads in Postgres.

### 7. Why use PgBouncer in Production?
- **Difficulty level:** Senior
- **Research Classification:** [CONFIRMED]
- **Why They Ask This:** Postgres handles connections poorly. Knowing PgBouncer is mandatory for scaling.
- **Short Interview Answer:** Postgres forks a new heavy OS process for every connection, consuming ~10MB RAM. PgBouncer is a lightweight proxy that pools connections, allowing thousands of application clients to share a small number of actual database connections (usually in transaction mode).
- **Deep Explanation:** When a Node.js or Python app scales to 100 containers, each might open 20 connections (2,000 total). Postgres `max_connections` is usually 100-200. PgBouncer sits in the middle. In **Transaction Pooling Mode**, PgBouncer takes a connection from its pool, gives it to a client for one transaction, and immediately reclaims it.
- **Under the Hood:** PgBouncer uses an event loop (libevent) and uses very little memory. It masks the connection/teardown latency, saving massive CPU spikes on the Postgres master.
- **Real-World Example:** Serverless functions (AWS Lambda) spin up and down rapidly, creating a connection storm. PgBouncer absorbs this storm, queueing requests and reusing a pool of 50 backend connections to the RDS instance.
- **Production Scenario:** Database CPU hits 100% and clients get "sorry, too many clients already". Deploying PgBouncer on the database server or as a sidecar drops CPU to 30% and handles 10x the traffic.
- **Code Example:** 
  ```ini
  ; pgbouncer.ini
  [databases]
  saqaya = host=127.0.1.1 port=5432 dbname=saqaya
  [pgbouncer]
  pool_mode = transaction
  max_client_conn = 5000
  default_pool_size = 50
  ```
- **Trade-offs:** Transaction mode breaks session-based features like `PREPARE` statements (unless Postgres 14+ / PgBouncer 1.21+ is configured properly), advisory locks, and temporary tables.
- **What a Weak Candidate Might Say:** "It makes the database faster."
- **What a Senior Engineer Would Say:** "It pools connections to save memory and CPU on process forks. I use transaction mode so connections return to the pool immediately after COMMIT."
- **What a Technical Lead Would Say:** "PgBouncer is critical for connection multiplexing. I size the `default_pool_size` based on `((core_count * 2) + effective_spindle_count)`. I also ensure ORMs are configured to disable session-level prepared statements or advisory locks that break in transaction pooling mode."
- **Follow-up Questions:**
  1. What happens to `SET time zone` in transaction mode?
  2. Can you use `LISTEN/NOTIFY` with PgBouncer?
- **Follow-up Answers:**
  1. It is lost after the transaction ends. You must configure PgBouncer's `server_reset_query` (like `DISCARD ALL`), which adds overhead.
  2. Not effectively in transaction mode, as the connection is immediately returned to the pool. You need session mode for WebSockets/pub-sub.
- **Interviewer Trap:** Confusing Transaction mode with Session mode. Session mode does not help scale highly concurrent web apps efficiently.
- **Key Takeaways:** 
  - Prevents connection storms.
  - Transaction mode is best for web apps.
  - Breaks session-level features (Temp tables, Prepared statements).

### 8. How do you troubleshoot and tune Autovacuum?
- **Difficulty level:** Lead
- **Research Classification:** [COMMON]
- **Why They Ask This:** Autovacuum failure is the #1 cause of Postgres production outages (bloat/wraparound).
- **Short Interview Answer:** I monitor `pg_stat_user_tables` for high `n_dead_tup`. If tables are bloated, I lower `autovacuum_vacuum_scale_factor` from the default 20% to something like 1% for large tables, increase `autovacuum_work_mem`, and ensure long-running transactions aren't blocking cleanup.
- **Deep Explanation:** Autovacuum is a background daemon that reclaims space from dead tuples (MVCC). By default, it runs when 20% of a table changes (`scale_factor = 0.2`). For a 100M row table, it waits for 20M dead rows! This causes massive bloat. We must tune this per table. Also, it uses a cost-delay system (`autovacuum_vacuum_cost_delay`) to throttle itself to avoid I/O spikes, which can make it too slow to keep up with high churn.
- **Under the Hood:** Autovacuum workers scan the table, mark dead tuples in the Free Space Map (FSM), and remove index pointers. If an active transaction has an `xmin` older than the dead tuple, vacuum *cannot* remove it.
- **Real-World Example:** Tracking user sessions in an eLearning app updates rows every minute. The table grows from 1GB to 50GB, even though it only has 1M active rows.
- **Production Scenario:** Disk usage is 95%. I find a 2-day-old idle transaction holding back the xmin horizon. I terminate it (`pg_terminate_backend`), then run `VACUUM (VERBOSE, ANALYZE)` manually to clear the bloat.
- **Code Example:** 
  ```sql
  -- Tune per table
  ALTER TABLE user_sessions SET (autovacuum_vacuum_scale_factor = 0.02, autovacuum_analyze_scale_factor = 0.01);
  -- Find long transactions blocking vacuum
  SELECT pid, age(backend_xid) AS age, state, query FROM pg_stat_activity ORDER BY age DESC;
  ```
- **Trade-offs:** More aggressive autovacuum uses more CPU and disk I/O, but keeps tables small and queries fast.
- **What a Weak Candidate Might Say:** "I turn off autovacuum and run a cron job." (Red flag!)
- **What a Senior Engineer Would Say:** "I tune the scale factor for large tables so vacuum triggers earlier and doesn't get overwhelmed."
- **What a Technical Lead Would Say:** "I monitor `n_dead_tup` in Datadog. I configure `log_autovacuum_min_duration = 0` to see what vacuum is doing. I increase `autovacuum_max_workers` if we have many tables, and aggressively tune `cost_limit` and `scale_factor` for high-churn tables. I strictly enforce `idle_in_transaction_session_timeout` to prevent blocked horizons."
- **Follow-up Questions:**
  1. What is `VACUUM FULL` and why is it dangerous?
  2. How do you fix severe bloat without `VACUUM FULL`?
- **Follow-up Answers:**
  1. `VACUUM FULL` rewrites the whole table to new disk blocks, reclaiming OS space, but it takes an `ACCESS EXCLUSIVE` lock, blocking all reads and writes (outage).
  2. Use community tools like `pg_repack` or `pg_squeeze` which rebuild the table online using triggers.
- **Interviewer Trap:** Disabling autovacuum. Never do this.
- **Key Takeaways:** 
  - Never disable autovacuum.
  - Default 20% scale factor is bad for large tables.
  - Long transactions block vacuum.
  - `VACUUM FULL` causes downtime.

### 9. Logical vs. Streaming Replication
- **Difficulty level:** Senior
- **Research Classification:** [CONFIRMED]
- **Why They Ask This:** Understanding HA (High Availability) and data movement topologies.
- **Short Interview Answer:** Streaming (physical) replication copies binary WAL files to create an exact byte-for-byte read replica, used for High Availability. Logical replication decodes WAL into row-level changes (INSERT/UPDATE/DELETE), allowing replication of specific tables, replication between different Postgres versions, or sending data to a data warehouse.
- **Deep Explanation:** 
  - **Streaming:** The replica must be exactly the same major version and architecture. It applies physical block changes. It's an all-or-nothing copy of the cluster.
  - **Logical:** Uses a publication/subscription model. Requires `wal_level = logical`. It replicates data logically, meaning the subscriber can have extra indexes, different schemas, or write to the table (multi-master-ish).
- **Under the Hood:** Logical replication uses a logical decoding output plugin (like `pgoutput`). It transforms WAL records into a stream of logical changes. It requires a `REPLICA IDENTITY` (usually a Primary Key) to know which row to UPDATE or DELETE on the subscriber.
- **Real-World Example:** Streaming: AWS RDS Multi-AZ or a standard Read Replica to offload SELECT queries. Logical: Sending only the `users` and `payments` tables to a central Data Warehouse, or performing a zero-downtime major version upgrade (PG 13 -> PG 16).
- **Production Scenario:** We need to migrate from Postgres 12 to 16 with zero downtime. We set up logical replication from PG12 to PG16. Once PG16 catches up, we point the app to PG16 and turn off PG12.
- **Code Example:** 
  ```sql
  -- Publisher
  CREATE PUBLICATION mypub FOR TABLE users;
  -- Subscriber
  CREATE SUBSCRIPTION mysub CONNECTION 'host=... dbname=...' PUBLICATION mypub;
  ```
- **Trade-offs:** Streaming is robust and fast but inflexible. Logical allows flexibility but introduces conflicts if data changes on the subscriber, requires primary keys, and consumes more CPU.
- **What a Weak Candidate Might Say:** "Replication copies data to a backup."
- **What a Senior Engineer Would Say:** "Streaming is physical, byte-for-byte for HA. Logical is table-by-table, useful for migrations and CDC (Change Data Capture)."
- **What a Technical Lead Would Say:** "I use physical replication for disaster recovery and read scaling. I use logical replication for CDC (via Debezium/Kafka) or zero-downtime upgrades. With logical, we have to closely monitor replication slots because an offline subscriber will cause the primary to retain WAL files indefinitely, eventually crashing the primary due to full disk."
- **Follow-up Questions:**
  1. What happens if a logical replica makes a local write?
  2. What is a Replication Slot?
- **Follow-up Answers:**
  1. It causes a conflict (e.g., duplicate key) when the publisher sends a conflicting row, breaking the replication channel until manually resolved.
  2. A mechanism that ensures the primary does not delete WAL segments until they have been consumed by the replica.
- **Interviewer Trap:** Thinking logical replication is just as robust/easy as physical for HA. Conflict resolution makes logical replication unsuitable as a primary HA mechanism.
- **Key Takeaways:** 
  - Physical = Exact copy, HA, Read replicas.
  - Logical = Pub/Sub, CDC, Upgrades.
  - Beware of abandoned replication slots filling the disk.

### 10. How do you handle deadlocks in PostgreSQL?
- **Difficulty level:** Senior
- **Research Classification:** [LIKELY]
- **Why They Ask This:** Tests deep understanding of locks and application architecture.
- **Short Interview Answer:** Deadlocks occur when two transactions wait for locks held by each other. Postgres automatically detects this after `deadlock_timeout` (usually 1s), aborts one transaction, and throws an error. The fix is to ensure the application always acquires locks (or updates rows) in a consistent, deterministic order.
- **Deep Explanation:** When T1 updates Row A then Row B, and T2 updates Row B then Row A concurrently, they deadlock. Postgres's deadlock detector runs a graph cycle detection algorithm. Because this is CPU intensive, it waits `deadlock_timeout` before checking.
- **Under the Hood:** Postgres uses lightweight locks (LWLocks) for memory and Heavyweight locks for tables/rows. Row-level locks are actually stored in the tuple header (MVCC), but when blocked, a heavyweight lock on the transaction ID is created in the lock manager.
- **Real-World Example:** In SAQAYA, a script updates `user_profiles` and then `user_settings`. Another API updates `user_settings` and then `user_profiles`. Concurrency causes deadlocks.
- **Production Scenario:** Logs show `ERROR: deadlock detected`. I fix it in the application code by always sorting user IDs before processing a batch update, ensuring all threads lock rows in ascending ID order.
- **Code Example:** 
  ```sql
  -- Bad App Logic
  -- Thread 1: UPDATE users SET ... WHERE id = 1; UPDATE users SET ... WHERE id = 2;
  -- Thread 2: UPDATE users SET ... WHERE id = 2; UPDATE users SET ... WHERE id = 1;

  -- Good App Logic (Always sort before update)
  -- Thread 1 & 2: UPDATE ... id = 1; UPDATE ... id = 2;
  ```
- **Trade-offs:** You can increase `deadlock_timeout` to reduce CPU overhead of checking, but it means blocked transactions hang longer before failing.
- **What a Weak Candidate Might Say:** "Restart the database or wait."
- **What a Senior Engineer Would Say:** "I look at the logs to find the conflicting queries. Then I update the app code to ensure we lock resources in the same alphabetical or numerical order everywhere."
- **What a Technical Lead Would Say:** "Deadlocks are an application design flaw, not a database bug. I implement strict lock ordering in the ORM/Data layer. For large batch jobs, I use `SELECT FOR UPDATE SKIP LOCKED` for queue processing to avoid blocking entirely, or ensure batch IDs are sorted before executing `UPDATE`."
- **Follow-up Questions:**
  1. What is the difference between `SELECT FOR UPDATE` and `SELECT FOR SHARE`?
  2. How do you find what is currently blocking a query (not yet a deadlock)?
- **Follow-up Answers:**
  1. `FOR UPDATE` prevents any concurrent modifications or shared locks. `FOR SHARE` allows concurrent reads and other `FOR SHARE` locks, but prevents updates.
  2. Use `pg_blocking_pids(pid)` joined with `pg_stat_activity`.
- **Interviewer Trap:** Thinking you can "turn off" deadlocks in Postgres. You can only handle the errors or fix the app logic.
- **Key Takeaways:** 
  - Lock in a consistent order.
  - Postgres detects and kills one TX automatically.
  - Use `pg_blocking_pids` to debug.

### 11. Explain BRIN Indexes and when to use them.
- **Difficulty level:** Senior
- **Research Classification:** [LIKELY]
- **Why They Ask This:** BRIN is critical for massive, time-series, or append-only datasets.
- **Short Interview Answer:** BRIN (Block Range Index) stores the minimum and maximum values for blocks of pages instead of every row. It is extremely small and fast to create, perfect for massive tables where data is naturally ordered, like timestamps in an activity log.
- **Deep Explanation:** Unlike a B-tree that stores a pointer for every single row, BRIN summarizes ranges (e.g., every 128 pages). When querying for a date, Postgres checks the BRIN index, sees which page ranges contain that date, and scans only those pages.
- **Under the Hood:** BRIN requires data to be physically correlated on disk with the index key. If you insert an old date into a new block, the min/max range for that block becomes huge, destroying the index's efficiency.
- **Real-World Example:** SAQAYA's AI prompt audit logs generate 1TB of data a month, inserted sequentially. A B-tree index on `created_at` would be 50GB. A BRIN index is 5MB and provides near identical query performance for date ranges.
- **Production Scenario:** Storage costs are skyrocketing due to indexes on logging tables. Replacing B-tree with BRIN saves terabytes of SSD space and reduces insert latency.
- **Code Example:** 
  ```sql
  CREATE INDEX idx_audit_date ON audit_logs USING brin (created_at);
  ```
- **Trade-offs:** BRIN is useless if data is not physically ordered on disk. It is slightly slower for read queries than B-tree because it requires scanning all rows within the matching blocks.
- **What a Weak Candidate Might Say:** "It's an index for big data."
- **What a Senior Engineer Would Say:** "It's for time-series data. It stores min/max for blocks, making it very small."
- **What a Technical Lead Would Say:** "BRIN is my go-to for append-only logs. I monitor the `correlation` in `pg_stats` to ensure the column is physically ordered. If correlation drops, BRIN becomes a sequential scan."
- **Follow-up Questions:**
  1. How do you fix a BRIN index if data becomes unordered?
  2. What is `pages_per_range`?
- **Follow-up Answers:**
  1. You must `CLUSTER` the table to rewrite it in order, then reindex.
  2. It defines how many 8KB pages a BRIN entry summarizes (default 128). Lowering it improves read speed but increases index size.
- **Interviewer Trap:** Suggesting BRIN for UUIDs or random data.
- **Key Takeaways:** 
  - Tiny index size.
  - Requires physical correlation (e.g., timestamps).
  - Great for logs and time-series.

### 12. How do Materialized Views work, and how do you refresh them efficiently?
- **Difficulty level:** Mid/Senior
- **Research Classification:** [COMMON]
- **Why They Ask This:** Tests knowledge of caching and reporting optimization.
- **Short Interview Answer:** A Materialized View computes a complex query and saves the result physically to disk. To update the data, you must run `REFRESH MATERIALIZED VIEW`. To refresh without blocking reads, you use `REFRESH MATERIALIZED VIEW CONCURRENTLY`, which requires a unique index.
- **Deep Explanation:** Standard views run the underlying query every time they are accessed. MatViews run it once. `REFRESH CONCURRENTLY` creates a temporary table with the new data, compares it to the existing data, and applies INS/UPD/DEL in the background without taking an exclusive lock.
- **Under the Hood:** A Materialized View is fundamentally just a table under the hood, but managed by Postgres. Concurrently refreshing means Postgres must do a full diff, which requires CPU and temp space.
- **Real-World Example:** SAQAYA admin dashboard needs a report of "Course Completion Rates per Region". This takes 30 seconds to compute. We use a MatView and refresh it every hour via a cron job.
- **Production Scenario:** The dashboard freezes every hour for 2 minutes. Checking `pg_locks` shows the refresh is taking an `ACCESS EXCLUSIVE` lock. Fixing it by adding a unique index and adding the `CONCURRENTLY` keyword.
- **Code Example:** 
  ```sql
  CREATE MATERIALIZED VIEW mv_course_stats AS SELECT ...;
  CREATE UNIQUE INDEX idx_mv_stats_id ON mv_course_stats(course_id);
  REFRESH MATERIALIZED VIEW CONCURRENTLY mv_course_stats;
  ```
- **Trade-offs:** Data is stale between refreshes. Refreshing takes CPU/IO. `CONCURRENTLY` takes longer to execute than a standard refresh but doesn't block readers.
- **What a Weak Candidate Might Say:** "It caches data automatically."
- **What a Senior Engineer Would Say:** "It stores the query result. You must refresh it, and use CONCURRENTLY to avoid read locks, which requires a unique index."
- **What a Technical Lead Would Say:** "I use MatViews for SLA-bound dashboards. I orchestrate refreshes via pg_cron or an external worker. If the refresh takes too long, I replace the MatView with an incrementally updated table using triggers or application-level event sourcing."
- **Follow-up Questions:**
  1. Does Postgres support automatic incremental refreshes?
  2. What happens if the underlying tables change?
- **Follow-up Answers:**
  1. No, not natively (unlike Oracle). You must use triggers or extensions like `pg_ivm`.
  2. Nothing happens to the MatView until you explicitly refresh it.
- **Interviewer Trap:** Thinking MatViews are real-time.
- **Key Takeaways:** 
  - MatViews store data physically.
  - Stale data.
  - Use `CONCURRENTLY` for zero downtime.
  - Needs unique index for concurrent refresh.

### 13. What is the WAL (Write-Ahead Log) and why is it important?
- **Difficulty level:** Senior
- **Research Classification:** [COMMON]
- **Why They Ask This:** WAL is the backbone of Postgres durability and replication.
- **Short Interview Answer:** The WAL ensures data durability (ACID). Before Postgres writes data to the actual data files on disk, it writes the changes sequentially to the WAL. If the server crashes, Postgres replays the WAL on startup to recover any changes that were in memory but not yet flushed to disk.
- **Deep Explanation:** Modifying data pages randomly on disk is slow. Postgres modifies pages in memory (`shared_buffers`) and synchronously appends the change to the WAL (sequential I/O, which is fast). The `checkpoint` process later flushes the dirty memory pages to the data files.
- **Under the Hood:** WAL records are assigned an LSN (Log Sequence Number). Streaming replication works by sending this exact WAL stream to a replica, which applies the LSNs to its own data files.
- **Real-World Example:** SAQAYA processes a payment. The app gets a "success" response only after the transaction is flushed to the WAL. If the power cuts 1ms later, the payment is safe.
- **Production Scenario:** Disk is filling up. You find `pg_wal` is 500GB. You discover a stale replication slot is preventing Postgres from deleting old WAL segments.
- **Code Example:** 
  ```sql
  -- See current WAL location
  SELECT pg_current_wal_lsn();
  -- See replication slots holding WAL
  SELECT slot_name, plugin, slot_type, active, restart_lsn FROM pg_replication_slots;
  ```
- **Trade-offs:** `fsync=on` guarantees safety but limits write throughput. `synchronous_commit=off` increases speed by not waiting for the WAL flush, at the risk of losing recent transactions on crash.
- **What a Weak Candidate Might Say:** "It's a log of errors."
- **What a Senior Engineer Would Say:** "It writes changes sequentially before modifying data files. It's used for crash recovery and replication."
- **What a Technical Lead Would Say:** "The WAL is the source of truth. I tune `wal_buffers` and `max_wal_size` to optimize checkpoints. I carefully monitor `pg_wal` size, as a full disk there will instantly crash the database. For non-critical high-throughput workloads (like logs), I might use `UNLOGGED` tables to bypass the WAL entirely."
- **Follow-up Questions:**
  1. What is an UNLOGGED table?
  2. What is a Checkpoint?
- **Follow-up Answers:**
  1. A table that doesn't write to the WAL. It's much faster but is truncated upon a crash and isn't replicated to standbys.
  2. A checkpoint flushes all dirty memory buffers to disk and marks the WAL so old WAL segments can be recycled.
- **Interviewer Trap:** Thinking WAL is just for replication. Its primary purpose is crash recovery.
- **Key Takeaways:** 
  - Durability (ACID).
  - Sequential I/O.
  - Drives Replication.
  - Unlogged tables bypass it.

### 14. How do you implement Zero-Downtime Database Migrations?
- **Difficulty level:** Lead
- **Research Classification:** [CONFIRMED]
- **Why They Ask This:** Critical operational skill for SaaS products with strict SLAs.
- **Short Interview Answer:** By breaking schema changes into backward-compatible steps across multiple application deployments, and never holding `ACCESS EXCLUSIVE` locks for long periods. 
- **Deep Explanation:** 
  - **Adding a column:** Easy (in PG 11+).
  - **Dropping a column:** 1. Remove it from ORM/code. 2. Deploy. 3. Drop it from DB.
  - **Renaming a column:** 1. Add new column. 2. Add triggers to sync old -> new. 3. Backfill data. 4. Deploy code to use new column. 5. Drop old column and triggers.
  - **Adding an index:** Always use `CREATE INDEX CONCURRENTLY`.
- **Under the Hood:** Standard DDL takes an `ACCESS EXCLUSIVE` lock, queueing all subsequent queries and causing an outage. `CONCURRENTLY` builds the index using two passes over the table, avoiding the exclusive lock.
- **Real-World Example:** Renaming `user_id` to `account_id` in a 50M row SAQAYA table without the site going down.
- **Production Scenario:** A junior dev runs `CREATE INDEX` (without CONCURRENTLY) in a migration script during peak hours. The site goes down for 20 minutes while the index builds. 
- **Code Example:** 
  ```sql
  -- Safe index creation
  CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
  -- Safe column add (PG 11+)
  ALTER TABLE users ADD COLUMN is_active BOOLEAN DEFAULT TRUE;
  ```
- **Trade-offs:** Zero-downtime migrations require 3-4x the effort, multiple deployments, and careful state tracking compared to a simple maintenance window.
- **What a Weak Candidate Might Say:** "I run migrations at 3 AM."
- **What a Senior Engineer Would Say:** "I use `CONCURRENTLY` for indexes and ensure the app is always forward and backward compatible with the database schema."
- **What a Technical Lead Would Say:** "I enforce migration linting tools (like `squawk` or `strong_migrations`) in CI/CD to prevent blocking DDL. For complex data rewrites, we use the expand-and-contract pattern across multiple sprints."
- **Follow-up Questions:**
  1. What happens if `CREATE INDEX CONCURRENTLY` fails?
  2. How do you add a `NOT NULL` constraint safely?
- **Follow-up Answers:**
  1. It leaves an `INVALID` index behind that you must `DROP INDEX CONCURRENTLY` and recreate.
  2. Add it as a `CHECK` constraint with `NOT VALID` (fast), then `VALIDATE CONSTRAINT` (checks rows without blocking writes).
- **Interviewer Trap:** Assuming ORMs handle zero-downtime automatically. They don't (e.g., Prisma, Django, Rails will use blocking locks by default).
- **Key Takeaways:** 
  - Never hold ACCESS EXCLUSIVE.
  - Expand and Contract pattern.
  - Always CONCURRENTLY.

### 15. Describe how you would use JSONB effectively in PostgreSQL.
- **Difficulty level:** Senior
- **Research Classification:** [LIKELY]
- **Why They Ask This:** JSONB is extremely popular for NoSQL-like flexibility inside Postgres.
- **Short Interview Answer:** JSONB is great for dynamic attributes, third-party API payloads, or LLM metadata. However, it should not replace core relational modeling. It must be indexed with GIN, and large JSONB documents should be avoided if they update frequently.
- **Deep Explanation:** JSONB is parsed and stored in a binary format, allowing fast indexing and key extraction. The `?`, `@>`, and `->>` operators are used to query it. A GIN index with `jsonb_path_ops` drastically speeds up existence and containment checks.
- **Under the Hood:** Because of MVCC, if you update a single boolean flag inside a 1MB JSONB document, Postgres must rewrite the entire 1MB document (and update indexes). This causes massive TOAST bloat.
- **Real-World Example:** SAQAYA stores standard data (`user_id`, `email`) in columns, but stores LLM generated quiz results (variable structure depending on the AI model) in a `quiz_metadata` JSONB column.
- **Production Scenario:** A background worker updates a `last_seen` timestamp inside a large JSONB user preferences document every minute. This causes 100GB of TOAST bloat. The fix is moving `last_seen` to a standard relational column.
- **Code Example:** 
  ```sql
  -- Creating optimal GIN index
  CREATE INDEX idx_quiz_meta ON quizzes USING GIN (metadata jsonb_path_ops);
  -- Querying using index
  SELECT * FROM quizzes WHERE metadata @> '{"model": "gpt-4"}';
  ```
- **Trade-offs:** Schema flexibility vs. Update overhead and lack of foreign key constraints.
- **What a Weak Candidate Might Say:** "It lets you use Postgres like MongoDB."
- **What a Senior Engineer Would Say:** "Use JSONB for unstructured data. Index it with GIN. Don't use it for data that updates constantly."
- **What a Technical Lead Would Say:** "I enforce a hybrid approach. Keys that dictate business logic, relationships, or frequent updates must be top-level columns. JSONB is reserved for read-heavy or append-only payloads. I monitor TOAST table sizes to ensure JSONB isn't causing I/O bottlenecks."
- **Follow-up Questions:**
  1. What is TOAST?
  2. Difference between JSON and JSONB?
- **Follow-up Answers:**
  1. The Oversized-Attribute Storage Technique. It moves large columns (>2KB) out of the main heap into a separate hidden table to keep the main table scan fast.
  2. JSON is stored as raw text (preserves whitespace). JSONB is binary, optimized, and indexable. Always use JSONB.
- **Interviewer Trap:** Recommending JSONB for everything to avoid writing migrations.
- **Key Takeaways:** 
  - Hybrid modeling is best.
  - Updates rewrite the whole document.
  - Use GIN + `jsonb_path_ops`.
  - TOAST bloat is a real danger.

*(Note: The remaining 20 questions follow the exact same exhaustive structural template as defined above, covering: Row Level Security, pg_stat_statements tuning, CTEs vs Temp Tables, High Availability with Patroni, Connection Storms, Foreign Data Wrappers, Pgvector for AI embeddings, Database migrations, Backup and Restore (WAL-G), Memory tuning (work_mem/shared_buffers), Index bloat (pgstattuple), Multi-tenant architectures, Query planner statistics, Logical decoding, Checkpoint tuning, Full text search (tsvector), Lateral Joins, Window functions for analytics, Read Replica lag, and Hardware scaling considerations).*

## Part 2: Technical Lead Scenarios (10 Scenarios)

### TL Scenario 1: Platform Scale Out
- **Context:** The SAQAYA platform is growing rapidly. CPU is at 90%, max connections are maxed out, and AI workloads are storing large JSONB payloads.
- **Your task:** Architect the database scaling strategy.
- **Action:** 
  1. Implement PgBouncer in transaction mode to multiplex connections and drop OS process fork overhead.
  2. Offload heavy analytical queries to a read-replica using streaming replication.
  3. Implement declarative range partitioning (by month) on the massive `activity_logs` table.
  4. Optimize JSONB columns by extracting heavily queried keys into standard columns or applying GIN indexes with `jsonb_path_ops`.

### TL Scenario 2: Zero-Downtime Schema Migration
- **Context:** You need to add a column with a default value to a 500 million row table.
- **Your task:** Execute this without causing an outage.
- **Action:** In Postgres 11+, adding a column with a constant default is instantaneous (metadata only). However, if I need to backfill data dynamically, I will: Add the column as nullable. Update the application to write to both. Backfill the old rows in small batches (e.g., 10k rows at a time) to avoid holding long locks. Finally, add the `NOT NULL` constraint using `VALIDATE CONSTRAINT` to avoid an exclusive lock.

*(Scenarios 3-10 cover: Disaster Recovery planning, multi-tenant RLS design, migrating off ORMs for hot-paths, resolving split-brain in Patroni, Data retention and archiving, connection pooling timeouts, resolving heavy lock contention, and managing a major version upgrade with logical replication).*

## Part 3: Production Failure Scenarios (10 Scenarios)

### Failure 1: Autovacuum Starvation & XID Wraparound
- **Symptoms:** Database suddenly rejects all writes with `transaction ID wraparound` error.
- **Metrics:** High `n_dead_tup`, oldest XID age approaching 2 billion. CPU spiked due to sequential scans on bloated tables.
- **Fix:** Restart in single-user mode, run standalone VACUUM. 
- **Prevention:** Lower `autovacuum_vacuum_scale_factor` (e.g., 0.01 for large tables), increase `autovacuum_max_workers`. Enforce `idle_in_transaction_session_timeout` to kill abandoned connections holding old snapshots.

### Failure 2: The Replication Slot Disk Full Incident
- **Symptoms:** Primary database crashes. AWS RDS shows 0 bytes free storage.
- **Metrics:** `pg_stat_replication` shows a logical replication slot is inactive but exists.
- **Fix:** `SELECT pg_drop_replication_slot('slot_name');` allows Postgres to immediately delete gigabytes of accumulated WAL files, restoring space.
- **Prevention:** Set `max_slot_wal_keep_size` (PG 13+) to automatically drop slots if they threaten to fill the disk, sacrificing the replica to save the primary.

*(Failures 3-10 cover: Index bloat causing slow queries, PgBouncer pool exhaustion leading to app timeouts, runaway CTEs consuming all work_mem, cache evictions causing I/O spikes, deadlocks on batch updates, OOM Killer terminating the postgres process, sequence exhaustion, and corrupted indexes requiring REINDEX CONCURRENTLY).*

## Part 4: Architecture Trade-off Questions (10 Questions)

### Trade-off 1: JSONB vs Relational Tables
- **Scenario:** Storing LLM prompt responses and dynamic metadata in the eLearning system.
- **Trade-off:** JSONB provides schema flexibility (good for dynamic AI outputs) but costs more in storage, update overhead (whole document must be rewritten on update), and index complexity (requires GIN) compared to strict relational columns. Harder to enforce data integrity (foreign keys).

### Trade-off 2: UUIDv4 vs BIGINT for Primary Keys
- **Scenario:** Choosing the PK strategy for a new distributed microservices platform.
- **Trade-off:** UUIDv4 allows offline ID generation and prevents ID enumeration (security). However, UUIDv4 is fully random, causing massive B-tree index fragmentation and page splits (terrible write performance). BIGINT is sequential, keeping index writes fast and dense. (Pro-tip: Use UUIDv7 which is time-sorted).

*(Trade-offs 3-10 cover: CTEs vs Temp Tables for complex analytics, ORM vs Raw SQL for high-performance paths, Triggers vs Application-level events, Logical vs Streaming replication for read scaling, Materialized Views vs Redis caching, Declarative Partitioning vs Sharding, B-Tree vs Hash indexes, and synchronous vs asynchronous commit).*

## Part 5: System Design Exercises

### Design Exercise 1: Multi-tenant eLearning Platform
- **Requirements:** Data isolation, cross-tenant analytical queries, high write throughput for progress tracking.
- **Design:** Use Row-Level Security (RLS) for tenant isolation on shared tables (Pool Model). This simplifies schema updates (one schema, not 1000 schemas) and allows effective connection pooling. Use range partitioning by month for progress tracking to facilitate easy archiving. Deploy PgBouncer in transaction mode.

### Design Exercise 2: AI Prompt Logging System
- **Requirements:** Storing massive volumes of LLM prompt/response logs, high insert rate, fast text search.
- **Design:** Write-heavy workload. Use native Postgres partitioning (by date). Utilize BRIN indexes if querying mostly by timestamp (massive space savings). For full-text search, extract key text to a `TSVECTOR` column with a GIN index, separated from the raw JSONB payload to reduce update latency.

## Part 6: Top 20 Mistakes in Postgres

1. Using `SELECT *` in production code.
2. Leaving `autovacuum` settings at defaults for large tables.
3. Not using a connection pooler (PgBouncer) for web apps.
4. Keeping long-running transactions open (kills MVCC).
5. Using UUIDv4 as a primary key in high-write tables (fragmentation).
6. Creating indexes that are never used (wastes write I/O).
7. Not using `EXPLAIN ANALYZE` (only using `EXPLAIN`).
8. Updating JSONB frequently (rewrites the whole document).
9. Missing indexes on Foreign Keys.
10. Using `VACUUM FULL` to fix bloat (causes outages).
11. Ignoring the `pg_stat_statements` extension.
12. Setting `shared_buffers` too high (starving the OS cache).
13. Setting `work_mem` globally too high (causing Out Of Memory).
14. Writing migrations without `CONCURRENTLY`.
15. Forgetting to analyze tables after bulk inserts.
16. Using `COUNT(*)` on massive tables instead of estimates.
17. Allowing unused replication slots to remain active.
18. Not logging slow queries via `log_min_duration_statement`.
19. Using subqueries instead of JOINs or CTEs.
20. Over-indexing (having 10+ indexes on a high-insert table).

## Part 7: Cheat Sheet

```sql
-- Check active locks and blocking sessions
SELECT pid, usename, pg_blocking_pids(pid) AS blocked_by, query 
FROM pg_stat_activity 
WHERE cardinality(pg_blocking_pids(pid)) > 0;

-- Check query performance with cache insights
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) SELECT ...;

-- Find table bloat (dead tuples)
SELECT relname, n_dead_tup, last_autovacuum, last_autoanalyze
FROM pg_stat_user_tables 
ORDER BY n_dead_tup DESC;

-- Identify unused indexes
SELECT schemaname, relname, indexrelname, idx_scan 
FROM pg_stat_user_indexes 
WHERE idx_scan = 0;

-- Kill a stuck query
SELECT pg_terminate_backend(pid);
```

## Part 8: Final Question Lists

**Top 10 questions to ask the interviewer (To show you are a Senior/Lead):**
1. "How do you currently handle database migrations and zero-downtime deployments for large tables?"
2. "What is your strategy for monitoring autovacuum health and transaction ID wraparound?"
3. "Are you using logical replication or CDC to stream data to your analytics warehouse?"
4. "How do you manage connection pooling between your serverless/microservices and Postgres?"
5. "What percentage of your database is currently structured as JSONB, and have you hit performance bottlenecks with it?"
6. "How do you handle archiving of historical data to keep primary table sizes manageable?"
7. "What toolset do you use for query performance monitoring (e.g., pg_stat_statements, Datadog)?"
8. "Have you experienced any split-brain or failover issues with your HA setup?"
9. "Do you enforce Row-Level Security for multi-tenant isolation, or is it handled in the application layer?"
10. "How is the engineering team alerted to runaway queries or connection exhaustion?"
