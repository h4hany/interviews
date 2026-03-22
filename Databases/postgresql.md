# PostgreSQL Interview Questions

## 1. What is PostgreSQL?

**Answer:**
PostgreSQL is an advanced, open-source, object-relational database management system (ORDBMS) that extends the SQL language with features that safely store and scale complex data workloads.

## 2. What are the key features of PostgreSQL?

**Answer:**
- **ACID Compliance**: Full ACID transaction support
- **Advanced Data Types**: JSON, JSONB, Array, Hstore, UUID, XML
- **Extensibility**: Custom functions, operators, data types
- **Full-Text Search**: Built-in full-text search capabilities
- **Geospatial Data**: PostGIS extension for geographic objects
- **Concurrency**: MVCC (Multi-Version Concurrency Control)
- **Replication**: Streaming replication, logical replication
- **Partitioning**: Table partitioning for large tables
- **Window Functions**: Advanced analytical functions

## 3. What is the difference between PostgreSQL and MySQL?

**Answer:**

| Feature | PostgreSQL | MySQL |
|---------|------------|-------|
| **Type** | ORDBMS (Object-Relational) | RDBMS (Relational) |
| **ACID** | Full ACID compliance | ACID with InnoDB only |
| **Data Types** | Advanced (JSON, Array, Custom) | Basic types |
| **Complex Queries** | Excellent support | Limited |
| **Full-Text Search** | Built-in | Requires MyISAM |
| **Extensibility** | Highly extensible | Limited |
| **Performance** | Better for complex queries | Faster for simple reads |
| **JSON Support** | Native JSON/JSONB | JSON (limited) |
| **Window Functions** | Full support | Limited (MySQL 8.0+) |

## 4. What is JSONB in PostgreSQL?

**Answer:**
JSONB (JSON Binary) is a binary format for storing JSON data in PostgreSQL.
- *Example*: Storing dynamic user "Settings" where different users have different configuration flags (e.g., `{"theme": "dark", "notifications": true}`). Using JSONB allows you to query for all users who have `theme: "dark"` efficiently.

**Example:**
```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    data JSONB
);

INSERT INTO products (data) VALUES 
('{"name": "Laptop", "price": 999, "specs": {"ram": "16GB", "storage": "512GB"}}');

-- Query JSONB
SELECT data->>'name' FROM products;
SELECT data->'specs'->>'ram' FROM products;

-- Index JSONB
CREATE INDEX idx_data ON products USING GIN (data);
```

## 5. What is the difference between JSON and JSONB?

**Answer:**

| Feature | JSON | JSONB |
|---------|------|-------|
| **Storage** | Text format (exact copy) | Binary format (decomposed) |
| **Input** | Preserves whitespace, key order | Removes whitespace, sorts keys |
| **Indexing** | Limited | Full GIN index support |
| **Performance** | Slower (parsing on each access) | Faster (pre-parsed) |
| **Size** | Smaller (text) | Larger (binary) |
| **Use Case** | When you need exact copy | When you need to query/index |

**Example:**
```sql
-- JSON preserves exact formatting
SELECT '{"b": 2, "a": 1}'::JSON;  -- Keeps order and spacing

-- JSONB normalizes
SELECT '{"b": 2, "a": 1}'::JSONB;  -- Sorts keys: {"a": 1, "b": 2}
```

## 6. What is MVCC (Multi-Version Concurrency Control) in PostgreSQL?

**Answer:**
MVCC is a concurrency control method that allows multiple transactions to access the database simultaneously without blocking each other.

**How it works:**
- Each transaction sees a snapshot of data at transaction start time.
- Updates create new versions of rows (don't overwrite).
- Old versions are kept until no longer needed.
- Readers never block writers, writers never block readers.
- *Example*: While an admin is running a 10-minute "Monthly Revenue" query, regular users can still make purchases and update the database without being blocked or seeing half-finished calculations.

**Benefits:**
- High concurrency
- No read locks needed
- Consistent snapshots
- Better performance for read-heavy workloads

## 7. What is a transaction in PostgreSQL?

**Answer:**
A transaction is a sequence of operations performed as a single unit of work. It follows ACID properties:
- **Atomicity**: All or nothing
- **Consistency**: Valid state transitions
- **Isolation**: Transactions don't interfere
- **Durability**: Committed changes are permanent

**Example:**
```sql
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;  -- Both succeed or both fail
```

## 8. What are the transaction isolation levels in PostgreSQL?

**Answer:**
PostgreSQL supports four isolation levels:

1. **READ UNCOMMITTED**: Not supported (treated as READ COMMITTED)
2. **READ COMMITTED** (Default): Each query sees only committed data
3. **REPEATABLE READ**: Transaction sees consistent snapshot
4. **SERIALIZABLE**: Highest isolation, prevents all anomalies

**Example:**
```sql
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN;
SELECT * FROM accounts WHERE id = 1;  -- Sees snapshot
-- Other transactions can commit, but this transaction won't see them
COMMIT;
```

## 9. What is a sequence in PostgreSQL?

**Answer:**
A sequence is a database object that generates a sequence of unique integers. It's often used for auto-incrementing primary keys.

**Example:**
```sql
-- Create sequence
CREATE SEQUENCE user_id_seq;

-- Use in table
CREATE TABLE users (
    id INTEGER DEFAULT nextval('user_id_seq') PRIMARY KEY,
    name VARCHAR(100)
);

-- Or use SERIAL (creates sequence automatically)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,  -- Automatically creates sequence
    name VARCHAR(100)
);
```

## 10. What is the difference between SERIAL, BIGSERIAL, and SMALLSERIAL?

**Answer:**
- **SERIAL**: 32-bit integer (1 to 2,147,483,647)
- **BIGSERIAL**: 64-bit integer (1 to 9,223,372,036,854,775,807)
- **SMALLSERIAL**: 16-bit integer (1 to 32,767)

**Use Case:**
- **SMALLSERIAL**: Small tables (< 32K rows)
- **SERIAL**: Most common use case
- **BIGSERIAL**: Very large tables (millions/billions of rows)

## 11. What is a trigger in PostgreSQL?

**Answer:**
A trigger is a function that automatically executes when a specified event occurs (INSERT, UPDATE, DELETE).

**Example:**
```sql
-- Create function
CREATE OR REPLACE FUNCTION update_modified_time()
RETURNS TRIGGER AS $$
BEGIN
    NEW.modified_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER update_timestamp
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_modified_time();
```

## 12. What is a stored procedure vs function in PostgreSQL?

**Answer:**

| Feature | Function | Stored Procedure |
|---------|----------|------------------|
| **Return Value** | Must return a value | Can return void or result set |
| **Transaction** | Cannot commit/rollback | Can commit/rollback |
| **Calling** | SELECT function_name() | CALL procedure_name() |
| **Use Case** | Calculations, transformations | Complex operations with transactions |

**Example:**
```sql
-- Function
CREATE FUNCTION calculate_total(price NUMERIC, quantity INT)
RETURNS NUMERIC AS $$
BEGIN
    RETURN price * quantity;
END;
$$ LANGUAGE plpgsql;

SELECT calculate_total(10.5, 3);  -- Returns 31.5

-- Stored Procedure (PostgreSQL 11+)
CREATE PROCEDURE transfer_money(from_id INT, to_id INT, amount NUMERIC)
AS $$
BEGIN
    UPDATE accounts SET balance = balance - amount WHERE id = from_id;
    UPDATE accounts SET balance = balance + amount WHERE id = to_id;
    COMMIT;
END;
$$ LANGUAGE plpgsql;

CALL transfer_money(1, 2, 100);
```

## 13. What is an array in PostgreSQL?

**Answer:**
PostgreSQL supports native array data types, allowing you to store multiple values in a single column.

**Example:**
```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    tags TEXT[]  -- Array of text
);

INSERT INTO products (name, tags) VALUES 
('Laptop', ARRAY['electronics', 'computers', 'gaming']);

-- Query arrays
SELECT * FROM products WHERE 'electronics' = ANY(tags);
SELECT name, array_length(tags, 1) FROM products;
```

## 14. What is a materialized view in PostgreSQL?

**Answer:**
A materialized view is a physical copy of query results stored on disk. Unlike regular views, materialized views store data and need to be refreshed.
- *Example*: A complex dashboard query that joins 10 tables and takes 30 seconds to run. You save it as a Materialized View that refreshes every hour. Now, the dashboard loads in 0.1 seconds for all users.

**Example:**
```sql
-- Create materialized view
CREATE MATERIALIZED VIEW monthly_sales AS
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    SUM(total) AS total_sales
FROM orders
GROUP BY DATE_TRUNC('month', order_date);

-- Query materialized view (fast!)
SELECT * FROM monthly_sales;

-- Refresh when data changes
REFRESH MATERIALIZED VIEW monthly_sales;

-- Can create indexes on materialized views
CREATE INDEX idx_monthly_sales_month ON monthly_sales(month);
```

## 15. What is the difference between a view and a materialized view?

**Answer:**

| Feature | View | Materialized View |
|---------|------|-------------------|
| **Storage** | No storage (virtual) | Stores data on disk |
| **Performance** | Slower (executes query each time) | Faster (pre-computed) |
| **Freshness** | Always current | Needs refresh |
| **Indexing** | Cannot index | Can create indexes |
| **Use Case** | Simple queries, always fresh | Complex queries, can tolerate stale data |

## 16. What is table partitioning in PostgreSQL?

**Answer:**
Table partitioning divides a large table into smaller, more manageable pieces (partitions) based on a partition key.

**Types:**
- **Range Partitioning**: Partition by range (dates, numbers)
- **List Partitioning**: Partition by list of values
- **Hash Partitioning**: Partition by hash function

**Example:**
```sql
-- Create partitioned table
CREATE TABLE orders (
    id SERIAL,
    order_date DATE,
    customer_id INT,
    total NUMERIC
) PARTITION BY RANGE (order_date);

-- Create partitions
CREATE TABLE orders_2023_q1 PARTITION OF orders
    FOR VALUES FROM ('2023-01-01') TO ('2023-04-01');

CREATE TABLE orders_2023_q2 PARTITION OF orders
    FOR VALUES FROM ('2023-04-01') TO ('2023-07-01');

-- Query automatically routes to correct partition
SELECT * FROM orders WHERE order_date = '2023-02-15';
```

## 17. What is an index in PostgreSQL?

**Answer:**
An index is a data structure that improves the speed of data retrieval operations on a table.

**Types of Indexes:**
- **B-tree**: Default, for equality and range queries
- **Hash**: For equality queries only
- **GIN (Generalized Inverted Index)**: For arrays, JSONB, full-text search
- **GiST (Generalized Search Tree)**: For geometric data, full-text search
- **BRIN (Block Range Index)**: For large tables with sorted data
- **SP-GiST**: For non-balanced data structures

**Example:**
```sql
-- Create B-tree index
CREATE INDEX idx_users_email ON users(email);

-- Create GIN index for JSONB
CREATE INDEX idx_products_data ON products USING GIN (data);

-- Create partial index
CREATE INDEX idx_active_users ON users(email) WHERE active = true;
```

## 18. What is the difference between B-tree and GIN indexes?

**Answer:**

| Feature | B-tree | GIN |
|---------|--------|-----|
| **Use Case** | Standard columns | Arrays, JSONB, full-text |
| **Query Type** | Equality, range, sorting | Contains, array operations |
| **Size** | Smaller | Larger |
| **Update Speed** | Faster | Slower |
| **Example** | `WHERE id = 5` | `WHERE tags @> ARRAY['tag']` |

## 19. What is EXPLAIN and EXPLAIN ANALYZE in PostgreSQL?

**Answer:**
- **EXPLAIN**: Shows the query execution plan without running the query
- **EXPLAIN ANALYZE**: Actually runs the query and shows actual execution statistics

**Example:**
```sql
EXPLAIN SELECT * FROM users WHERE email = 'test@example.com';

-- Output shows:
-- Seq Scan, Index Scan, Join type, etc.

EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';

-- Shows actual execution time, rows, buffers, etc.
```

## 20. What is VACUUM in PostgreSQL?

**Answer:**
VACUUM reclaims storage occupied by dead tuples (deleted/updated rows) and updates statistics used by the query planner.

**Types:**
- **VACUUM**: Reclaims space, doesn't lock table
- **VACUUM FULL**: Reclaims space and defragments (locks table, slower)
- **VACUUM ANALYZE**: VACUUM + updates statistics

**Example:**
```sql
-- Regular vacuum
VACUUM users;

-- Vacuum and analyze
VACUUM ANALYZE users;

-- Vacuum full (defragments)
VACUUM FULL users;

-- Auto-vacuum (enabled by default)
-- PostgreSQL automatically runs VACUUM based on configuration
```

## 21. What is the difference between VACUUM and VACUUM FULL?

**Answer:**

| Feature | VACUUM | VACUUM FULL |
|---------|--------|-------------|
| **Space Reclamation** | Marks space as reusable | Actually reclaims space |
| **Table Lock** | No lock | Exclusive lock |
| **Speed** | Fast | Slow |
| **Disk Space** | Doesn't reduce file size | Reduces file size |
| **Use Case** | Regular maintenance | When disk space is critical |

## 22. What is a foreign key constraint in PostgreSQL?

**Answer:**
A foreign key constraint ensures referential integrity by enforcing that values in a column must exist in the referenced table.

**Example:**
```sql
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    total NUMERIC
);

-- ON DELETE options:
-- CASCADE: Delete related rows
-- RESTRICT: Prevent deletion if referenced
-- SET NULL: Set foreign key to NULL
-- NO ACTION: Default, similar to RESTRICT
```

## 23. What is a check constraint in PostgreSQL?

**Answer:**
A check constraint ensures that values in a column meet a specific condition.

**Example:**
```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    price NUMERIC CHECK (price > 0),
    discount NUMERIC CHECK (discount >= 0 AND discount <= 100)
);

-- Or table-level constraint
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    order_date DATE,
    ship_date DATE,
    CHECK (ship_date >= order_date)
);
```

## 24. What is a unique constraint in PostgreSQL?

**Answer:**
A unique constraint ensures that all values in a column (or combination of columns) are unique.

**Example:**
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE,
    username VARCHAR(50) UNIQUE
);

-- Or composite unique constraint
CREATE TABLE user_roles (
    user_id INT,
    role_id INT,
    UNIQUE(user_id, role_id)  -- Combination must be unique
);
```

## 25. What is a partial index in PostgreSQL?

**Answer:**
A partial index is an index built on a subset of a table, defined by a WHERE clause. It's smaller and faster than a full index.

**Example:**
```sql
-- Index only active users
CREATE INDEX idx_active_users_email ON users(email) 
WHERE active = true;

-- Index only recent orders
CREATE INDEX idx_recent_orders ON orders(order_date) 
WHERE order_date > '2023-01-01';

-- Query automatically uses partial index
SELECT * FROM users WHERE active = true AND email = 'test@example.com';
```

## 26. What is a covering index in PostgreSQL?

**Answer:**
A covering index (INCLUDE columns) includes additional columns in the index to satisfy queries without accessing the table.

**Example:**
```sql
-- Index includes email and name
CREATE INDEX idx_users_covering ON users(id) INCLUDE (email, name);

-- Query can be satisfied from index alone
SELECT id, email, name FROM users WHERE id = 123;
-- No need to access table!
```

## 27. What is a full-text search in PostgreSQL?

**Answer:**
PostgreSQL provides built-in full-text search capabilities using tsvector and tsquery types.

**Example:**
```sql
-- Create full-text search column
ALTER TABLE articles ADD COLUMN search_vector tsvector;

-- Create trigger to update search vector
CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON articles
FOR EACH ROW EXECUTE FUNCTION 
tsvector_update_trigger(search_vector, 'pg_catalog.english', title, content);

-- Create GIN index
CREATE INDEX idx_articles_search ON articles USING GIN (search_vector);

-- Search
SELECT * FROM articles 
WHERE search_vector @@ to_tsquery('english', 'postgresql & database');
```

## 28. What is PostGIS?

**Answer:**
PostGIS is a spatial database extender for PostgreSQL that adds support for geographic objects and spatial queries.
- *Example*: An app like Uber uses PostGIS to find the 5 nearest drivers to a user's current GPS location (latitude/longitude) using a single SQL query.

**Example:**
```sql
-- Enable PostGIS
CREATE EXTENSION postgis;

-- Create table with geometry
CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    location GEOGRAPHY(POINT, 4326)
);

-- Insert location
INSERT INTO locations (name, location) VALUES 
('Office', ST_GeogFromText('POINT(-122.4194 37.7749)'));

-- Find locations within distance
SELECT name FROM locations 
WHERE ST_DWithin(
    location, 
    ST_GeogFromText('POINT(-122.4194 37.7749)'),
    1000  -- 1000 meters
);
```

## 29. What is replication in PostgreSQL?

**Answer:**
Replication is the process of copying data from one PostgreSQL server (primary) to one or more servers (replicas) for high availability and read scaling.

**Types:**
- **Streaming Replication**: Real-time replication of WAL (Write-Ahead Log)
- **Logical Replication**: Replicates specific tables/databases
- **Synchronous Replication**: Waits for replica confirmation
- **Asynchronous Replication**: Doesn't wait (default)

## 30. What is the difference between streaming and logical replication?

**Answer:**

| Feature | Streaming Replication | Logical Replication |
|---------|----------------------|---------------------|
| **Granularity** | Entire database | Specific tables |
| **Level** | Physical (block-level) | Logical (row-level) |
| **Use Case** | High availability, backup | Selective replication, upgrades |
| **Version** | Can be different versions | Must be same major version |
| **Filtering** | No | Yes (can filter tables) |

## 31. What is a WAL (Write-Ahead Log) in PostgreSQL?

**Answer:**
WAL is a log file that records all changes to data files before they are written to disk. It ensures durability and enables replication.

**Benefits:**
- **Durability**: Changes are logged before commit
- **Replication**: Replicas read WAL to stay in sync
- **Crash Recovery**: Can replay WAL to recover
- **Point-in-Time Recovery**: Restore to any point in time

## 32. What is pg_dump and pg_restore?

**Answer:**
- **pg_dump**: Creates a backup of a PostgreSQL database
- **pg_restore**: Restores a database from a backup file

**Example:**
```bash
# Backup database
pg_dump -U username -d database_name -F c -f backup.dump

# Restore database
pg_restore -U username -d database_name backup.dump

# Backup as SQL
pg_dump -U username -d database_name -f backup.sql

# Restore SQL
psql -U username -d database_name -f backup.sql
```

## 33. What is a schema in PostgreSQL?

**Answer:**
A schema is a namespace that contains database objects (tables, views, functions, etc.). It provides logical organization and access control.

**Example:**
```sql
-- Create schema
CREATE SCHEMA sales;

-- Create table in schema
CREATE TABLE sales.orders (
    id SERIAL PRIMARY KEY,
    total NUMERIC
);

-- Access with schema prefix
SELECT * FROM sales.orders;

-- Set search path
SET search_path TO sales, public;
SELECT * FROM orders;  -- Now finds sales.orders
```

## 34. What is the difference between CHAR, VARCHAR, and TEXT in PostgreSQL?

**Answer:**

| Type | Storage | Use Case |
|------|---------|----------|
| **CHAR(n)** | Fixed length, padded with spaces | When length is always the same |
| **VARCHAR(n)** | Variable length, up to n characters | When length varies but has max |
| **TEXT** | Variable length, unlimited | When length is unknown or very long |

**Note:** In PostgreSQL, VARCHAR and TEXT are essentially the same performance-wise. TEXT is often preferred for simplicity.

## 35. What is a window function in PostgreSQL?

**Answer:**
Window functions perform calculations across a set of rows related to the current row, without grouping.

**Example:**
```sql
-- ROW_NUMBER: Assign sequential numbers
SELECT 
    name,
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) as rank
FROM employees;

-- RANK: Rank with gaps for ties
SELECT 
    name,
    salary,
    RANK() OVER (ORDER BY salary DESC) as rank
FROM employees;

-- LAG/LEAD: Access previous/next row
SELECT 
    date,
    sales,
    LAG(sales) OVER (ORDER BY date) as previous_sales,
    LEAD(sales) OVER (ORDER BY date) as next_sales
FROM daily_sales;
```

## 36. What is the difference between ROW_NUMBER, RANK, and DENSE_RANK?

**Answer:**

| Function | Behavior |
|---------|----------|
| **ROW_NUMBER()** | Sequential numbers, no ties |
| **RANK()** | Ranks with gaps (1, 2, 2, 4) |
| **DENSE_RANK()** | Ranks without gaps (1, 2, 2, 3) |

**Example:**
```sql
-- Data: [100, 90, 90, 80]
-- ROW_NUMBER: 1, 2, 3, 4
-- RANK: 1, 2, 2, 4
-- DENSE_RANK: 1, 2, 2, 3
```

## 37. What is a common table expression (CTE) in PostgreSQL?

**Answer:**
A CTE is a temporary result set that exists only for the duration of a query. It improves readability and can be recursive.

**Example:**
```sql
-- Simple CTE
WITH high_sales AS (
    SELECT customer_id, SUM(total) as total
    FROM orders
    GROUP BY customer_id
    HAVING SUM(total) > 1000
)
SELECT c.name, h.total
FROM customers c
JOIN high_sales h ON c.id = h.customer_id;

-- Recursive CTE
WITH RECURSIVE employee_hierarchy AS (
    -- Base case
    SELECT id, name, manager_id, 1 as level
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive case
    SELECT e.id, e.name, e.manager_id, eh.level + 1
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.id
)
SELECT * FROM employee_hierarchy;
```

## 38. What is a lateral join in PostgreSQL?

**Answer:**
A LATERAL join allows a subquery in the FROM clause to reference columns from preceding tables in the same FROM clause.

**Example:**
```sql
-- Without LATERAL (doesn't work)
SELECT u.name, recent_orders.*
FROM users u,
(SELECT * FROM orders WHERE user_id = u.id ORDER BY created_at DESC LIMIT 3) recent_orders;

-- With LATERAL (works)
SELECT u.name, recent_orders.*
FROM users u,
LATERAL (
    SELECT * FROM orders 
    WHERE user_id = u.id 
    ORDER BY created_at DESC 
    LIMIT 3
) recent_orders;
```

## 39. What is a prepared statement in PostgreSQL?

**Answer:**
A prepared statement is a SQL template that's parsed and planned once, then executed multiple times with different parameters.

**Benefits:**
- **Performance**: Parse/plan once, execute many times
- **Security**: Prevents SQL injection
- **Efficiency**: Reduces overhead

**Example:**
```sql
-- Prepare statement
PREPARE get_user AS
SELECT * FROM users WHERE id = $1;

-- Execute with parameters
EXECUTE get_user(123);
EXECUTE get_user(456);

-- Deallocate
DEALLOCATE get_user;
```

## 40. What is connection pooling in PostgreSQL?

**Answer:**
Connection pooling maintains a cache of database connections that can be reused, reducing the overhead of establishing connections.

**Tools:**
- **pgBouncer**: Lightweight connection pooler
- **PgPool-II**: Advanced connection pooler with load balancing
- **Application-level**: Connection pools in application code

**Benefits:**
- Reduces connection overhead
- Limits maximum connections
- Improves performance

## 41. What is the difference between INNER JOIN and LEFT JOIN?

**Answer:**

| Join Type | Result |
|----------|--------|
| **INNER JOIN** | Only matching rows from both tables |
| **LEFT JOIN** | All rows from left table + matching rows from right |
| **RIGHT JOIN** | All rows from right table + matching rows from left |
| **FULL OUTER JOIN** | All rows from both tables |

**Example:**
```sql
-- INNER JOIN: Only users with orders
SELECT u.name, o.total
FROM users u
INNER JOIN orders o ON u.id = o.user_id;

-- LEFT JOIN: All users, even without orders
SELECT u.name, o.total
FROM users u
LEFT JOIN orders o ON u.id = o.user_id;
```

## 42. What is a subquery in PostgreSQL?

**Answer:**
A subquery is a query nested inside another query. It can be used in SELECT, FROM, WHERE, and HAVING clauses.

**Types:**
- **Scalar Subquery**: Returns single value
- **Row Subquery**: Returns single row
- **Table Subquery**: Returns multiple rows

**Example:**
```sql
-- Scalar subquery
SELECT name, 
       (SELECT COUNT(*) FROM orders WHERE user_id = users.id) as order_count
FROM users;

-- EXISTS subquery
SELECT * FROM users
WHERE EXISTS (
    SELECT 1 FROM orders WHERE user_id = users.id
);

-- IN subquery
SELECT * FROM users
WHERE id IN (SELECT user_id FROM orders WHERE total > 100);
```

## 43. What is the difference between EXISTS and IN?

**Answer:**

| Feature | EXISTS | IN |
|---------|--------|-----|
| **NULL Handling** | Handles NULLs correctly | NULL in list causes issues |
| **Performance** | Stops at first match | Checks all values |
| **Use Case** | When checking existence | When matching specific values |
| **Subquery** | Can return any columns | Must return one column |

**Example:**
```sql
-- EXISTS: Stops when finds first match
SELECT * FROM users u
WHERE EXISTS (
    SELECT 1 FROM orders o WHERE o.user_id = u.id
);

-- IN: Checks all values
SELECT * FROM users
WHERE id IN (SELECT user_id FROM orders);
```

## 44. What is a self-join in PostgreSQL?

**Answer:**
A self-join is a join where a table is joined with itself.

**Example:**
```sql
-- Find employees and their managers
SELECT 
    e.name as employee,
    m.name as manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;

-- Find all pairs of employees in same department
SELECT 
    e1.name as employee1,
    e2.name as employee2
FROM employees e1
JOIN employees e2 ON e1.department_id = e2.department_id
WHERE e1.id < e2.id;  -- Avoid duplicates and self-pairs
```

## 45. What is a correlated subquery?

**Answer:**
A correlated subquery references columns from the outer query. It's executed once for each row processed by the outer query.

**Example:**
```sql
-- Find employees with salary above department average
SELECT e1.name, e1.salary
FROM employees e1
WHERE e1.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e1.department_id  -- Correlated!
);
```

## 46. What is the difference between UNION and UNION ALL?

**Answer:**

| Feature | UNION | UNION ALL |
|---------|-------|-----------|
| **Duplicates** | Removes duplicates | Keeps duplicates |
| **Performance** | Slower (sorts and removes duplicates) | Faster |
| **Use Case** | When duplicates don't matter | When you want all rows |

**Example:**
```sql
-- UNION: Removes duplicates
SELECT name FROM users
UNION
SELECT name FROM customers;

-- UNION ALL: Keeps duplicates
SELECT name FROM users
UNION ALL
SELECT name FROM customers;
```

## 47. What is a deadlock in PostgreSQL?

**Answer:**
A deadlock occurs when two or more transactions are waiting for each other to release locks, creating a circular dependency.

**Example:**
```sql
-- Transaction 1
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;  -- Waits for lock

-- Transaction 2 (concurrent)
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE id = 2;
UPDATE accounts SET balance = balance + 100 WHERE id = 1;  -- Deadlock!
```

**PostgreSQL automatically detects and resolves deadlocks by rolling back one transaction.**

## 48. What is table locking in PostgreSQL?

**Answer:**
PostgreSQL uses various lock modes to control concurrent access:
- **ACCESS SHARE**: Allows SELECT
- **ROW SHARE**: Allows SELECT, FOR UPDATE
- **ROW EXCLUSIVE**: Allows INSERT, UPDATE, DELETE
- **SHARE**: Prevents schema changes
- **EXCLUSIVE**: Prevents all operations except SELECT
- **ACCESS EXCLUSIVE**: Prevents all operations

**Example:**
```sql
-- Explicit lock
BEGIN;
LOCK TABLE users IN SHARE MODE;
-- Do operations
COMMIT;
```

## 49. What is the difference between DELETE and TRUNCATE?

**Answer:**

| Feature | DELETE | TRUNCATE |
|---------|--------|----------|
| **Speed** | Slower (row by row) | Faster (removes all at once) |
| **WHERE Clause** | Can use WHERE | Cannot use WHERE |
| **Rollback** | Can be rolled back | Can be rolled back (in transaction) |
| **Triggers** | Fires triggers | Doesn't fire triggers |
| **Auto-increment** | Doesn't reset | Resets sequence |
| **Locks** | Row-level locks | Table-level lock |

**Example:**
```sql
-- DELETE: Removes specific rows
DELETE FROM users WHERE active = false;

-- TRUNCATE: Removes all rows
TRUNCATE TABLE users;
```

## 50. What is the difference between TIMESTAMP and TIMESTAMPTZ?

**Answer:**

| Type | Timezone | Storage |
|------|----------|---------|
| **TIMESTAMP** | No timezone (assumes server timezone) | 8 bytes |
| **TIMESTAMPTZ** | With timezone (converts to UTC) | 8 bytes |

**Example:**
```sql
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP,        -- No timezone
    created_at_tz TIMESTAMPTZ   -- With timezone
);

-- TIMESTAMP: Stores as-is
INSERT INTO events (created_at) VALUES ('2023-01-01 12:00:00');

-- TIMESTAMPTZ: Converts to UTC
INSERT INTO events (created_at_tz) VALUES ('2023-01-01 12:00:00-05');
-- Stored as UTC internally
```

## 51. What is a function vs procedure in PostgreSQL?

**Answer:**

| Feature | Function | Procedure |
|---------|----------|-----------|
| **Return** | Must return value | Can return void or result set |
| **Transaction** | Cannot commit/rollback | Can commit/rollback |
| **Calling** | `SELECT function()` | `CALL procedure()` |
| **Use Case** | Calculations | Complex operations |

## 52. What is a domain in PostgreSQL?

**Answer:**
A domain is a user-defined data type based on an existing type with optional constraints.

**Example:**
```sql
-- Create domain
CREATE DOMAIN email_address AS VARCHAR(255)
CHECK (VALUE ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Use domain
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email email_address  -- Uses domain with validation
);
```

## 53. What is a rule in PostgreSQL?

**Answer:**
A rule is a mechanism for defining query rewrite rules. It's an older feature, views are generally preferred.

**Example:**
```sql
-- Create rule
CREATE RULE update_users AS
ON UPDATE TO users
DO ALSO
INSERT INTO user_audit (user_id, action, timestamp)
VALUES (NEW.id, 'UPDATE', NOW());
```

## 54. What is the difference between pg_dump and pg_basebackup?

**Answer:**

| Feature | pg_dump | pg_basebackup |
|---------|---------|---------------|
| **Type** | Logical backup | Physical backup |
| **Format** | SQL or custom | Binary copy |
| **Level** | Database/table level | Cluster level |
| **Use Case** | Backup specific databases | Full cluster backup |
| **Restore** | Can restore to different version | Must restore to same version |

## 55. What is autovacuum in PostgreSQL?

**Answer:**
Autovacuum is a background process that automatically runs VACUUM and ANALYZE on tables to maintain database health.

**Benefits:**
- Automatically reclaims dead tuple space
- Updates table statistics
- Prevents transaction ID wraparound
- Maintains database performance

**Configuration:**
```sql
-- Check autovacuum settings
SHOW autovacuum;
SHOW autovacuum_vacuum_threshold;
SHOW autovacuum_analyze_threshold;
```

## 56. What is a tablespace in PostgreSQL?

**Answer:**
A tablespace is a location where PostgreSQL stores database objects (tables, indexes).

**Example:**
```sql
-- Create tablespace
CREATE TABLESPACE fast_disk LOCATION '/fast/disk/path';

-- Create table in tablespace
CREATE TABLE large_table (
    id SERIAL PRIMARY KEY,
    data TEXT
) TABLESPACE fast_disk;
```

## 57. What is the difference between HAVING and WHERE?

**Answer:**

| Clause | When Used | Purpose |
|--------|-----------|---------|
| **WHERE** | Before grouping | Filters rows |
| **HAVING** | After grouping | Filters groups |

**Example:**
```sql
-- WHERE: Filters before grouping
SELECT department, AVG(salary)
FROM employees
WHERE salary > 50000  -- Filters individual rows
GROUP BY department;

-- HAVING: Filters after grouping
SELECT department, AVG(salary)
FROM employees
GROUP BY department
HAVING AVG(salary) > 50000;  -- Filters groups
```

## 58. What is a generated column in PostgreSQL?

**Answer:**
A generated column is a column whose value is automatically computed from other columns.

**Example:**
```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    price NUMERIC,
    quantity INT,
    total_price NUMERIC GENERATED ALWAYS AS (price * quantity) STORED
);

-- total_price is automatically calculated
INSERT INTO products (price, quantity) VALUES (10, 5);
-- total_price = 50 automatically
```

## 59. What is a check constraint with a function?

**Answer:**
You can use functions in check constraints for complex validation.

**Example:**
```sql
-- Create function
CREATE FUNCTION valid_email(email TEXT) RETURNS BOOLEAN AS $$
BEGIN
    RETURN email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
END;
$$ LANGUAGE plpgsql;

-- Use in constraint
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) CHECK (valid_email(email))
);
```

## 60. What is the difference between pg_stat and pg_statio?

**Answer:**

| View | Information |
|------|-------------|
| **pg_stat_*** | Statistics about table/index usage |
| **pg_statio_*** | I/O statistics (disk reads/writes) |

**Example:**
```sql
-- Table statistics
SELECT * FROM pg_stat_user_tables WHERE relname = 'users';

-- I/O statistics
SELECT * FROM pg_statio_user_tables WHERE relname = 'users';
```

## 61. What is a partial unique index?

**Answer:**
A partial unique index enforces uniqueness only on a subset of rows.

**Example:**
```sql
-- Only one active user per email
CREATE UNIQUE INDEX idx_active_user_email 
ON users(email) 
WHERE active = true;

-- Multiple inactive users can have same email
-- But only one active user per email
```

## 62. What is the difference between COPY and \copy in PostgreSQL?

**Answer:**

| Command | Location | Permissions |
|---------|----------|-------------|
| **COPY** | Server-side | Requires superuser or file permissions |
| **\copy** | Client-side | Uses client file system |

**Example:**
```sql
-- COPY: Server-side (requires file on server)
COPY users FROM '/path/on/server/users.csv' CSV HEADER;

-- \copy: Client-side (uses client file)
\copy users FROM '/path/on/client/users.csv' CSV HEADER
```

## 63. What is a recursive query in PostgreSQL?

**Answer:**
A recursive query uses a recursive CTE to process hierarchical or graph data.

**Example:**
```sql
-- Find all managers in hierarchy
WITH RECURSIVE manager_hierarchy AS (
    -- Base case: top-level managers
    SELECT id, name, manager_id, 0 as level
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive: find subordinates
    SELECT e.id, e.name, e.manager_id, mh.level + 1
    FROM employees e
    JOIN manager_hierarchy mh ON e.manager_id = mh.id
)
SELECT * FROM manager_hierarchy;
```

## 64. What is the difference between INNER JOIN and CROSS JOIN?

**Answer:**

| Join Type | Result |
|-----------|--------|
| **INNER JOIN** | Only matching rows (with condition) |
| **CROSS JOIN** | Cartesian product (all combinations) |

**Example:**
```sql
-- INNER JOIN: Only matching
SELECT * FROM users u
INNER JOIN orders o ON u.id = o.user_id;

-- CROSS JOIN: All combinations
SELECT * FROM users
CROSS JOIN products;
-- If 10 users and 5 products = 50 rows
```

## 65. What is a composite type in PostgreSQL?

**Answer:**
A composite type is a user-defined type that groups multiple fields together.

**Example:**
```sql
-- Create composite type
CREATE TYPE address AS (
    street VARCHAR(100),
    city VARCHAR(50),
    zip_code VARCHAR(10)
);

-- Use in table
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    address address
);

-- Insert
INSERT INTO customers (name, address) VALUES 
('John', ('123 Main St', 'New York', '10001')::address);

-- Query
SELECT name, (address).city FROM customers;
```

## 66. What is the difference between pg_dump and pg_dumpall?

**Answer:**

| Tool | Scope | Use Case |
|------|-------|----------|
| **pg_dump** | Single database | Backup specific database |
| **pg_dumpall** | Entire cluster | Backup all databases, roles, etc. |

**Example:**
```bash
# pg_dump: Single database
pg_dump -U user -d mydb -f mydb_backup.sql

# pg_dumpall: Entire cluster
pg_dumpall -U user -f cluster_backup.sql
```

## 67. What is a GIN index and when to use it?

**Answer:**
GIN (Generalized Inverted Index) is used for:
- **Arrays**: Fast array containment queries
- **JSONB**: Efficient JSONB queries
- **Full-text search**: Text search operations

**Example:**
```sql
-- GIN index for array
CREATE INDEX idx_tags ON products USING GIN (tags);

-- Query using index
SELECT * FROM products WHERE tags @> ARRAY['electronics'];

-- GIN index for JSONB
CREATE INDEX idx_data ON products USING GIN (data);

-- Query JSONB
SELECT * FROM products WHERE data @> '{"category": "electronics"}';
```

## 68. What is the difference between SERIAL and IDENTITY?

**Answer:**

| Feature | SERIAL | IDENTITY |
|---------|--------|----------|
| **Standard** | PostgreSQL-specific | SQL standard |
| **Control** | Less control | More control (CACHE, CYCLE) |
| **PostgreSQL** | Older syntax | Newer (PostgreSQL 10+) |

**Example:**
```sql
-- SERIAL (old way)
CREATE TABLE users (
    id SERIAL PRIMARY KEY
);

-- IDENTITY (SQL standard, PostgreSQL 10+)
CREATE TABLE users (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY
);

-- IDENTITY with options
CREATE TABLE users (
    id INT GENERATED ALWAYS AS IDENTITY 
    (START WITH 1 INCREMENT BY 1 CACHE 20) PRIMARY KEY
);
```

## 69. What is a foreign data wrapper (FDW) in PostgreSQL?

**Answer:**
FDW allows PostgreSQL to access data stored in external data sources (other databases, files, APIs).

**Example:**
```sql
-- Install FDW extension
CREATE EXTENSION postgres_fdw;

-- Create foreign server
CREATE SERVER foreign_db
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'remote_host', dbname 'remote_db');

-- Create foreign table
CREATE FOREIGN TABLE remote_users (
    id INT,
    name VARCHAR(100)
) SERVER foreign_db;

-- Query foreign table
SELECT * FROM remote_users;
```

## 70. What is the difference between pg_stat_statements and pg_stat_activity?

**Answer:**

| View | Information |
|------|-------------|
| **pg_stat_activity** | Current active connections and queries |
| **pg_stat_statements** | Historical query statistics (requires extension) |

**Example:**
```sql
-- Current activity
SELECT pid, usename, query, state 
FROM pg_stat_activity 
WHERE state = 'active';

-- Query statistics (requires extension)
CREATE EXTENSION pg_stat_statements;
SELECT query, calls, total_time, mean_time 
FROM pg_stat_statements 
ORDER BY total_time DESC 
LIMIT 10;
```

## 71. What is table inheritance in PostgreSQL?

**Answer:**
PostgreSQL supports table inheritance, where child tables inherit columns from parent tables.

**Example:**
```sql
-- Parent table
CREATE TABLE vehicles (
    id SERIAL PRIMARY KEY,
    brand VARCHAR(50),
    year INT
);

-- Child tables
CREATE TABLE cars (
    doors INT
) INHERITS (vehicles);

CREATE TABLE trucks (
    cargo_capacity INT
) INHERITS (vehicles);

-- Query parent (gets all children)
SELECT * FROM vehicles;  -- Returns cars and trucks

-- Query only parent
SELECT * FROM ONLY vehicles;  -- Only vehicles, not children
```

## 72. What is the difference between pg_restore and psql for restoring?

**Answer:**

| Method | Format | Features |
|--------|--------|----------|
| **pg_restore** | Custom format (.dump) | Parallel restore, selective restore |
| **psql** | SQL format (.sql) | Simple, readable, sequential |

**Example:**
```bash
# pg_restore: Custom format
pg_restore -d newdb -j 4 backup.dump  # Parallel with 4 jobs

# psql: SQL format
psql -d newdb -f backup.sql
```

## 73. What is a check constraint with subquery?

**Answer:**
PostgreSQL allows subqueries in check constraints (though with limitations).

**Example:**
```sql
-- Ensure order total matches sum of items
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    total NUMERIC,
    CHECK (
        total = (
            SELECT SUM(price * quantity) 
            FROM order_items 
            WHERE order_id = id
        )
    )
);
```

## 74. What is the difference between pg_stat and pg_catalog?

**Answer:**

| Schema | Purpose |
|--------|---------|
| **pg_catalog** | System catalog (tables, functions, types) |
| **pg_stat** | Statistics views (performance, usage) |

**Example:**
```sql
-- System catalog
SELECT * FROM pg_catalog.pg_tables;

-- Statistics
SELECT * FROM pg_stat_user_tables;
```

## 75. What is a partial index with expression?

**Answer:**
A partial index can use expressions in the WHERE clause.

**Example:**
```sql
-- Index only uppercase emails
CREATE INDEX idx_uppercase_emails 
ON users(email) 
WHERE email = UPPER(email);

-- Index only recent records
CREATE INDEX idx_recent_orders 
ON orders(created_at) 
WHERE created_at > CURRENT_DATE - INTERVAL '1 year';
```

## 76. What is the difference between pg_dump formats?

**Answer:**

| Format | Extension | Features |
|--------|-----------|----------|
| **Plain** | .sql | Human-readable, can edit |
| **Custom** | .dump | Compressed, parallel restore |
| **Directory** | directory/ | Multiple files, parallel restore |
| **Tar** | .tar | Compressed, single file |

**Example:**
```bash
# Plain SQL
pg_dump -F p -f backup.sql mydb

# Custom format
pg_dump -F c -f backup.dump mydb

# Directory format
pg_dump -F d -f backup_dir mydb
```

## 77. What is a functional index in PostgreSQL?

**Answer:**
A functional index is created on the result of a function or expression.

**Example:**
```sql
-- Index on function result
CREATE INDEX idx_lower_email ON users(LOWER(email));

-- Query uses index
SELECT * FROM users WHERE LOWER(email) = 'test@example.com';

-- Index on expression
CREATE INDEX idx_full_name ON users((first_name || ' ' || last_name));
```

## 78. What is the difference between pg_stat and pg_stat_database?

**Answer:**

| View | Scope |
|------|-------|
| **pg_stat_*** | Per-table/index statistics |
| **pg_stat_database** | Per-database statistics |

**Example:**
```sql
-- Database-level stats
SELECT * FROM pg_stat_database WHERE datname = 'mydb';

-- Table-level stats
SELECT * FROM pg_stat_user_tables;
```

## 79. What is a check constraint with multiple conditions?

**Answer:**
Check constraints can have multiple conditions using AND/OR.

**Example:**
```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    price NUMERIC,
    discount NUMERIC,
    CHECK (
        price > 0 AND 
        discount >= 0 AND 
        discount <= 100 AND
        (discount = 0 OR price > discount)
    )
);
```

## 80. What is the difference between pg_dump and logical replication?

**Answer:**

| Feature | pg_dump | Logical Replication |
|---------|---------|---------------------|
| **Type** | One-time backup | Continuous replication |
| **Use Case** | Backup/restore | Real-time sync |
| **Latency** | N/A | Low latency |
| **Granularity** | Database/table | Table level |

## 81. What is a check constraint with a function call?

**Answer:**
You can use immutable functions in check constraints.

**Example:**
```sql
-- Create immutable function
CREATE FUNCTION is_valid_phone(phone TEXT) RETURNS BOOLEAN AS $$
BEGIN
    RETURN phone ~ '^[0-9]{10}$';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Use in constraint
CREATE TABLE contacts (
    id SERIAL PRIMARY KEY,
    phone VARCHAR(20) CHECK (is_valid_phone(phone))
);
```

## 82. What is the difference between pg_stat and pg_statio_user_tables?

**Answer:**

| View | Information |
|------|-------------|
| **pg_stat_user_tables** | Table access statistics (scans, tuples) |
| **pg_statio_user_tables** | I/O statistics (heap/blocks read/written) |

**Example:**
```sql
-- Access stats
SELECT * FROM pg_stat_user_tables;

-- I/O stats
SELECT * FROM pg_statio_user_tables;
```

## 83. What is a check constraint with a date comparison?

**Answer:**
Check constraints can compare dates.

**Example:**
```sql
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    start_date DATE,
    end_date DATE,
    CHECK (end_date >= start_date)
);

CREATE TABLE reservations (
    id SERIAL PRIMARY KEY,
    check_in DATE,
    check_out DATE,
    CHECK (check_out > check_in AND check_in >= CURRENT_DATE)
);
```

## 84. What is the difference between pg_dump and continuous archiving?

**Answer:**

| Feature | pg_dump | Continuous Archiving |
|---------|---------|---------------------|
| **Type** | Logical backup | Physical backup (WAL) |
| **Recovery** | Point-in-time | Point-in-time recovery |
| **Setup** | Simple | Complex |
| **Use Case** | Regular backups | High availability |

## 85. What is a check constraint with array operations?

**Answer:**
You can use array operations in check constraints.

**Example:**
```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    tags TEXT[],
    CHECK (array_length(tags, 1) > 0 AND array_length(tags, 1) <= 10)
);
```

## 86. What is the difference between pg_stat and EXPLAIN ANALYZE?

**Answer:**

| Tool | When | Information |
|------|------|-------------|
| **pg_stat_*** | Runtime statistics | Historical usage patterns |
| **EXPLAIN ANALYZE** | Query planning | Single query execution plan |

## 87. What is a check constraint with JSONB operations?

**Answer:**
You can validate JSONB in check constraints.

**Example:**
```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    data JSONB,
    CHECK (data ? 'name' AND data ? 'price')
);
```

## 88. What is the difference between pg_dump and streaming replication?

**Answer:**

| Feature | pg_dump | Streaming Replication |
|---------|---------|----------------------|
| **Type** | Backup tool | Replication method |
| **Real-time** | No | Yes |
| **Use Case** | Backup | High availability |
| **Format** | SQL/custom | WAL streaming |

## 89. What is a check constraint with string functions?

**Answer:**
You can use string functions in check constraints.

**Example:**
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50),
    CHECK (LENGTH(username) >= 3 AND LENGTH(username) <= 20)
);
```

## 90. What is the difference between pg_stat and pg_locks?

**Answer:**

| View | Information |
|------|-------------|
| **pg_stat_*** | Usage statistics |
| **pg_locks** | Current lock information |

**Example:**
```sql
-- Check current locks
SELECT * FROM pg_locks WHERE NOT granted;
```

## Summary

PostgreSQL is a powerful, feature-rich database with:
- Advanced data types (JSONB, Arrays, Custom types)
- Full ACID compliance
- Excellent performance for complex queries
- Extensibility (custom functions, operators, types)
- Built-in full-text search
- Geospatial support (PostGIS)
- Advanced indexing (GIN, GiST, BRIN)
- Window functions and CTEs
- Replication and high availability


