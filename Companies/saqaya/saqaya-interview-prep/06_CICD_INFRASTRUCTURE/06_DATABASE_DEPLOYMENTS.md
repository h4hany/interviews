# Database Deployments (PostgreSQL)

## Schema Migration in the Pipeline
Infrastructure as Code applies to databases too. Never modify schemas manually via DataGrip/pgAdmin in production.
- Use migration tools (Flyway, Liquibase, Prisma Migrate, Alembic).
- Migrations are versioned SQL scripts (e.g., `V1__init.sql`, `V2__add_users.sql`).
- The CI/CD pipeline runs these scripts against the database *before* the application code is deployed.

## Zero-Downtime Schema Changes (Expand and Contract Pattern)
Relational DB schemas are rigid. To achieve zero-downtime, migrations must be broken into multiple, backward-compatible steps across multiple deployments.

**Example: Renaming a column from `first_name` to `given_name`.**
1. **Deployment 1 (Expand):** Add the new column `given_name`. App continues writing to `first_name`.
2. **Deployment 2 (Migrate):** Deploy app code that writes to *both* columns. Run a background script to backfill old data from `first_name` to `given_name`.
3. **Deployment 3 (Shift):** Deploy app code that reads/writes *only* to `given_name`.
4. **Deployment 4 (Contract):** Drop the old column `first_name`.

## Large Table Alterations in PostgreSQL
Running `ALTER TABLE` on a massive table can lock the table, causing downtime.
- **Adding a column with a default value:** In PG 11+, this is fast and doesn't require a table rewrite.
- **Creating Indexes:** ALWAYS use `CREATE INDEX CONCURRENTLY`. This builds the index in the background without locking writes to the table. (Standard `CREATE INDEX` locks the table for writes).

## Database Backups Before Deployment
- Always take a snapshot (AWS RDS Snapshot) before applying major schema migrations.
- **RTO (Recovery Time Objective):** How long does it take to restore the snapshot if the migration corrupts data? For massive DBs, restoring can take hours.

## Database Rollback Strategies
- **Forward-Fix (Preferred):** If a migration causes a non-critical bug, write a *new* migration to fix it and deploy forward.
- **Down Migrations:** Writing `down.sql` scripts to revert `up.sql`. Highly risky in production. If an `up` migration drops data, a `down` migration cannot magically bring it back.
- **Restore from Snapshot:** The nuclear option. Data written between the snapshot time and the rollback time will be permanently lost.

## Database CI/CD
- **Linting:** Use tools like `squawk` to lint SQL for dangerous operations (e.g., missing `CONCURRENTLY` on index creation).
- **Ephemeral DBs:** CI should spin up a fresh PostgreSQL docker container, run all migrations from V1 to V_Current, and ensure they apply cleanly.

## Interview Questions
**Q: How do you add an index to a 100GB table in production without taking the application down?**
A: Use PostgreSQL's `CREATE INDEX CONCURRENTLY`. It takes longer to build because it requires multiple scans of the table, but it allows read and write operations to continue uninterrupted during the build process.

**Q: Why are "down" migrations dangerous in production?**
A: Because state changes are often destructive. If I deploy a migration that drops a table, rolling back the application code and running the "down" migration will recreate an *empty* table. The data is gone. Therefore, stateful rollbacks must be handled via data restoration from backups or avoided entirely using the expand-and-contract pattern.
