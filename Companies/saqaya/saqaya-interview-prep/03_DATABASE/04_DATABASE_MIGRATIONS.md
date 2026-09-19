# Database Migrations - Technical Lead Level

## 1. Migration Strategies for Production

### Zero-Downtime Migrations
The golden rule: **Never break backward compatibility**. The application and database deployments are never perfectly synchronized.
- **Phase 1**: Add the new schema (e.g., a new column). Do not drop the old one. Deploy the new DB schema. Old app version continues working.
- **Phase 2**: Deploy the new app version. It writes to both old and new columns, and reads from the new column.
- **Phase 3**: Backfill old data.
- **Phase 4**: Deploy another app version that no longer uses the old column.
- **Phase 5**: Drop the old column in a future DB migration.

### Handling DDL Locks
PostgreSQL uses multi-version concurrency, but schema changes (DDL) require locks.
- `ALTER TABLE ... ADD COLUMN` (without a default, or with a default in PG 11+): Extremely fast.
- `CREATE INDEX`: Locks the table against writes. ALWAYS use `CREATE INDEX CONCURRENTLY` in production.
- `ALTER TABLE ... ALTER COLUMN TYPE`: Requires rewriting the table. Takes an `AccessExclusiveLock`. Huge downtime for large tables.

## 2. Tools
- **Alembic (Python)**: Excellent for SQLAlchemy. Generates migrations based on model diffs.
- **Prisma (TypeScript)**: `prisma migrate deploy`. Declarative schema, generates SQL.
- **Flyway / Liquibase**: Standard for Java/Enterprise. SQL-first.

## 3. Safe Schema Evolution Patterns

### Renaming a Column safely
1. Add new column.
2. Add triggers to sync old column -> new column on INSERT/UPDATE.
3. Backfill data in chunks.
4. Update app to read/write new column.
5. Drop trigger, drop old column.

### Changing a Column Type safely
1. Add a new column with the new type.
2. Use triggers to cast and sync data.
3. Backfill.
4. Update app.
5. Drop old column, rename new column.

## 4. Migration CI/CD Integration
- Migrations must be run automatically in CI/CD pipeline before or during the application deployment.
- **Pre-deployment checks**: Use tools like `squawk` or `pganalyze` to lint migrations in CI (e.g., fail the build if a migration contains `DROP TABLE` or lacks `CONCURRENTLY` on index creation).

## Interview Questions

## Question 1: Adding a Default Value to a Large Table
### What the interviewer is testing
Knowledge of PostgreSQL version-specific optimizations and zero-downtime operations.

### Short answer
In PostgreSQL 11 and later, adding a column with a constant default value is instant and safe. Prior to PG 11, it would lock and rewrite the entire table.

### Detailed answer
Before PG 11, `ALTER TABLE users ADD COLUMN is_active BOOLEAN DEFAULT TRUE` would take an AccessExclusiveLock, rewrite every page of the table to include the new boolean, and block all reads/writes. For a 100GB table, this means total outage.
In PG 11+, PostgreSQL simply stores the default value in the system catalog (`pg_attribute`). When reading a row that doesn't have the column physically present on disk, it dynamically injects the default value. It completes in milliseconds.

### Strong Technical Lead answer
"If we are on PG 11+, adding a constant default is O(1) and safe for production. However, if the default is a volatile expression (like `DEFAULT random()`), it will still rewrite the table. In that case, I would execute a multi-step zero-downtime migration: 1. Add the column without a default (instant). 2. ALTER the column to set the default for future rows. 3. Write a background script to batch-UPDATE existing rows in small chunks (e.g., 1000 at a time) and `COMMIT` in between to avoid lock contention and massive WAL generation."

## Question 2: Blue-Green Database Deployments
### What the interviewer is testing
Architectural knowledge of deployment strategies, data replication, and rollback handling.

### Short answer
Blue-green for relational databases is exceptionally difficult due to state. We generally prefer rolling forward with backward-compatible schema changes on a single database over true blue-green DB deployments. However, if required, we use Logical Replication.

### Detailed answer
In app Blue-Green, you spin up App V2, switch traffic, and if it fails, switch back.
If you try this with DBs: DB Green gets the new schema. You switch traffic. App V2 writes new data to DB Green. If you have to rollback, how do you get those new writes back to DB Blue (the old schema)?
To do true Blue-Green DB deployments, you must set up **bi-directional logical replication** between Blue and Green, transforming the data on the fly. This is notoriously fragile, prone to conflicts, and complex.

### Strong Technical Lead answer
"I strongly advise against full Blue-Green database deployments for regular feature releases due to the immense complexity of bi-directional synchronization and split-brain scenarios. Instead, I enforce the Expand-and-Contract pattern. The single production database is always forward and backward compatible with both the N and N-1 application versions. We deploy the DB changes via CI/CD, then do a Blue-Green deployment of the application tier. If the app needs rollback, the DB schema is already compatible. If a migration is flawed, we write a fixing 'roll-forward' migration rather than attempting DB rollbacks."

### Follow-up questions
- How do you handle long-running data backfills on massive tables without causing performance issues?
### Follow-up answers
- Backfills must be batched. I write a script to process records by Primary Key ranges (e.g., `WHERE id BETWEEN 1 AND 1000`), executing the update, doing a `pg_sleep(0.1)` to yield I/O and let autovacuum catch up, and committing. I never use a single massive `UPDATE` statement because it creates one giant transaction, generating immense WAL, risking out-of-memory, and holding a lock that blocks autovacuum from clearing dead tuples, leading to table bloat.
