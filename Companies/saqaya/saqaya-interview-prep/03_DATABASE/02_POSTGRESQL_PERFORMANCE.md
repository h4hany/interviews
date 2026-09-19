# PostgreSQL Performance - Technical Lead Level

## 1. Query Optimization Techniques

### Execution Plans (EXPLAIN ANALYZE)
Always use `EXPLAIN (ANALYZE, BUFFERS)`.
- **Node Types**:
  - `Seq Scan`: Full table scan. Bad for large tables unless retrieving a large % of rows.
  - `Index Scan`: Scans index, then fetches row from heap.
  - `Index Only Scan`: Scans index, and all required data is in the index. Avoids heap fetch (if visibility map says the page is visible).
  - `Bitmap Index Scan` + `Bitmap Heap Scan`: Good for fetching many rows matching an index. Builds an in-memory bitmap of pages to visit, sorting them to ensure sequential I/O.
- **Buffers**: `shared hit` (read from memory), `read` (read from disk). High `read` indicates you need better caching or indexes.

### Indexing Strategies
- **Partial Indexes**: Index only a subset of data. Saves space and maintenance cost.
  ```sql
  CREATE INDEX idx_active_users ON users(id) WHERE status = 'active';
  ```
- **Covering Indexes (INCLUDE)**: Add payload columns to an index to allow Index Only Scans.
  ```sql
  CREATE INDEX idx_orders_customer ON orders (customer_id) INCLUDE (total_amount);
  ```
- **Expression Indexes**: Index the result of a function.
  ```sql
  CREATE INDEX idx_users_lower_email ON users (lower(email));
  ```

## 2. Bloat Management and Autovacuum Tuning

- **Bloat**: Wasted space in data files (heap) and indexes due to dead tuples.
- **Monitoring**: Use `pgstattuples` extension.
- **Tuning for large databases**:
  ```ini
  # postgresql.conf
  autovacuum_max_workers = 5
  autovacuum_naptime = 15s
  autovacuum_vacuum_cost_limit = 2000 # Make it faster
  # For specific large tables:
  ALTER TABLE large_table SET (autovacuum_vacuum_scale_factor = 0.02);
  ```
- **Fixing Bloat**: `VACUUM FULL` requires an exclusive lock (blocks reads/writes). Use **pg_repack** or **pg_squeeze** for zero-downtime bloat removal.

## 3. Lock Contention and Optimization

- **Monitoring**: Check `pg_stat_activity` where `wait_event_type = 'Lock'`. Check `pg_locks`.
- **Row-level locks**: `SELECT FOR UPDATE` causes contention if held too long. Keep transactions short.
- **DDL Locks**: `ALTER TABLE` operations often require `AccessExclusiveLock`, blocking everything. Use `CONCURRENTLY` where possible (e.g., `CREATE INDEX CONCURRENTLY`).

## 4. Memory Tuning

- **shared_buffers**: Typically 25% of RAM. Doesn't need to be huge because PG relies on the OS page cache.
- **work_mem**: Memory for sorts/hashes per operation, per query. (e.g., 4-16MB). A complex query might use `work_mem` multiple times. Setting it too high globally causes OOM. Use `SET local work_mem = '1GB'` for specific heavy sessions.
- **maintenance_work_mem**: Used for VACUUM, CREATE INDEX. Set high (e.g., 1-2GB) to speed up maintenance.
- **effective_cache_size**: An estimate for the planner of how much memory is available for disk caching (PG buffers + OS cache). Usually 50-75% of RAM. Does not allocate memory.

## Interview Questions

## Question 1: Index Only Scans and Visibility Maps
### What the interviewer is testing
Deep understanding of indexing internals, the MVCC model, and how PG retrieves data.

### Short answer
An Index Only Scan allows PG to satisfy a query entirely from the index without reading the table (heap). However, it relies on the Visibility Map to ensure the tuples referenced in the index are visible to the current transaction.

### Detailed answer
In PostgreSQL, the index contains the data and a pointer to the heap tuple. Because of MVCC, the index does not know if the tuple is visible to the current transaction (it might be deleted, or uncommitted). Normally, PG must visit the heap to check the `xmin`/`xmax` visibility info. An Index Only Scan bypasses the heap fetch ONLY if the page containing the tuple is marked as "all-visible" in the Visibility Map.

### How it works internally
The Visibility Map is a small file tracking which pages contain only tuples known to be visible to all active transactions. VACUUM maintains this map. If a page is modified, its bit in the VM is cleared. During an Index Only Scan, if the VM bit is 0, PG must fetch the heap block to check visibility.

### Real-world example
We added a covering index `CREATE INDEX idx_users_email ON users(email) INCLUDE(name)`. We expected `SELECT email, name FROM users WHERE email='x'` to be instant. However, `EXPLAIN ANALYZE` showed `Heap Fetches: 50000`. The table was heavily updated, and autovacuum wasn't running frequently enough, so the Visibility Map was outdated, forcing heap fetches.

### Trade-offs
Indexes with INCLUDE consume more disk space and write I/O.

### Strong Technical Lead answer
"I use Covering Indexes to enable Index Only Scans for high-throughput read paths. But I always verify using EXPLAIN ANALYZE that `Heap Fetches` is zero or very low. If heap fetches are high, it indicates the Visibility Map is lagging, which means our autovacuum settings for that table are too relaxed. I would aggressively tune autovacuum for that specific table to ensure the VM is updated frequently, realizing the true benefit of the Index Only Scan."

## Question 2: Diagnosing 100% CPU on PostgreSQL
### What the interviewer is testing
Incident response, debugging skills, and knowledge of system views.

### Short answer
I would look at `pg_stat_activity` to find active queries, use OS tools like `top`/`iotop`, check for lock contention, and review `pg_stat_statements` for historically expensive queries.

### Detailed answer
1. **Identify the immediate cause**: Connect and run `SELECT * FROM pg_stat_activity WHERE state = 'active'`. Look for long-running queries, high numbers of connections, or queries waiting on locks.
2. **System level**: Run `top`. Is the CPU consumed by user time (CPU intensive queries, sorting, joining) or system/iowait (thrashing, missing indexes forcing table scans)?
3. **Immediate Mitigation**: If a rogue query is scanning a massive table and sorting in memory/disk, I'll use `pg_cancel_backend(pid)` or `pg_terminate_backend(pid)`.
4. **Root Cause Analysis**: Inspect `pg_stat_statements` to find the most time-consuming queries overall. Run EXPLAIN ANALYZE on them. Usually, 100% CPU is caused by a missing index leading to sequential scans on large tables, or nested loop joins that spiral out of control.

### Strong Technical Lead answer
"During a CPU spike, my priority is restoring service. I immediately check `pg_stat_activity` for query pile-ups or blocking locks. If connection limits are exhausted, it's often a downstream symptom of a slow query holding locks or taking too long. I'll terminate the offending PIDs. Once stable, I use `pg_stat_statements` to grab the query ID, `EXPLAIN` it, and look for missing indexes, outdated statistics (causing bad plans), or insufficient `work_mem` causing disk-based sorts. I also ensure we have pgBouncer configured properly, as connection storms themselves cause massive CPU context switching."
