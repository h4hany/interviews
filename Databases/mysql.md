# MySQL Interview Questions

## 1. What is MySQL?

MySQL is an open-source relational database management system (RDBMS) based on SQL (Structured Query Language). It is
used for managing and storing data in a relational database, supporting various SQL operations like CRUD (Create, Read,
Update, Delete) and advanced queries.

## 2. What are the differences between MySQL and other database systems (e.g., PostgreSQL, SQL Server)?

- **MySQL**: Open-source, widely used, fast read-heavy applications, supports ACID transactions with InnoDB, and simple
  SQL syntax.
- **PostgreSQL**: Open-source, supports advanced features like JSON, GIS data types, custom functions, and full ACID
  compliance.
- **SQL Server**: A commercial product by Microsoft with integrated support for .NET applications, enterprise features,
  and extensive tools for database management.

## 3. What is a primary key in MySQL?

A primary key is a unique identifier for a record in a table. It ensures that each record can be uniquely identified by
its key, and no two records can have the same primary key value. It also enforces entity integrity.

### **Example**:

```sql
CREATE TABLE users
(
    user_id   INT PRIMARY KEY,
    full_name VARCHAR(100)
);
```

## 4. What are foreign keys in MySQL?

A foreign key is a column or a set of columns that creates a relationship between two tables. It ensures referential
integrity by enforcing that values in the foreign key column must exist in the referenced primary key column of another
table.

## 5. What are the different types of indexes in MySQL?

- **Primary Index**: Unique and automatically created for primary keys.
- **Unique Index**: Ensures that values in a column are unique.
- **Regular Index**: A non-unique index that speeds up query retrieval.
- **Full-text Index**: Used for full-text search capabilities.
- **Spatial Index**: Used for spatial data types.

## 6. What is normalization in a database, and why is it important?

Normalization is the process of organizing data in a database to minimize redundancy and dependency. It involves
dividing large tables into smaller ones and ensuring relationships between them. It is important because it reduces the
chances of data anomalies.

### **Example**:

This reduces redundancy by normalizing the address data.

```sql
-- before --
CREATE TABLE users
(
    user_id   INT PRIMARY KEY,
    full_name VARCHAR(100),
    address   VARCHAR(255),
);
-- after --
CREATE TABLE users
(
    user_id   INT PRIMARY KEY,
    full_name VARCHAR(100)
);

CREATE TABLE addresses
(
    id      INT PRIMARY KEY,
    user_id INT,
    address VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users (user_id)
);
```

## 7. What is denormalization, and when should it be used?

Denormalization is the process of combining tables to reduce the number of joins needed in queries, which can improve
performance. It is used when performance needs to be optimized and when read-heavy operations are prioritized over write
consistency.

### **Example**:

```sql
CREATE TABLE users
(
    user_id   INT PRIMARY KEY,
    full_name VARCHAR(100),
    address   VARCHAR(255),
);
```

## 8. What are joins in SQL? Name the different types of joins.

A join is used to combine rows from two or more tables based on a related column.

![My Image](../static/images/mysql-join.png)

The different types of joins are:

- **Inner Join**: Returns only matching rows from both tables.
- **Left Join (or Left Outer Join)**: Returns all rows from the left table and matching rows from the right table.
- **Right Join (or Right Outer Join)**: Returns all rows from the right table and matching rows from the left table.
- **Full Join (or Full Outer Join)**: Returns all rows when there is a match in either the left or right table.

```sql

-- INNER JOIN
SELECT users.full_name, orders.order_id
FROM users
       INNER JOIN orders ON users.user_id = orders.user_id;

-- LEFT JOIN
SELECT users.full_name, orders.order_id
FROM users
       LEFT JOIN orders ON users.user_id = orders.user_id;
```

## 10. What is a subquery, and how is it used in MySQL?

A subquery is a query nested inside another query, often used to retrieve a result that can be used in the outer query.
Subqueries can be used in the `SELECT`, `INSERT`, `UPDATE`, and `DELETE` statements.

```sql

SELECT full_name
FROM users
WHERE user_id IN (SELECT user_id FROM orders WHERE order_id = 101);
```
## 11. What is the difference between `CHAR` and `VARCHAR` data types?

- **CHAR**: A fixed-length string. If the string is shorter than the specified length, it is padded with spaces.
- **VARCHAR**: A variable-length string. It only uses as much space as needed for the data.

## 12. Explain the ACID properties of a transaction.

ACID stands for:

- **Atomicity**: A transaction is all-or-nothing.
- **Consistency**: The database transitions from one valid state to another.
- **Isolation**: Transactions do not interfere with each other.
- **Durability**: Once a transaction is committed, it is permanent.

```sql
START TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
COMMIT;
```
## 13. What is an `AUTO_INCREMENT` field in MySQL?

An `AUTO_INCREMENT` field is used to automatically generate a unique number when a new record is inserted into a table.
It is typically used for primary keys.

## 14. What is the difference between `DELETE`, `TRUNCATE`, and `DROP` statements?

- **DELETE**: Removes rows from a table based on a condition. It can be rolled back.
- **TRUNCATE**: Removes all rows from a table but does not log individual row deletions. It is faster than `DELETE` and
  cannot be rolled back.
- **DROP**: Removes a table or database completely, including its structure.

## 15. What are the different types of relationships in databases (one-to-one, one-to-many, many-to-many)?

- **One-to-One**: One record in a table is related to one record in another table.
- **One-to-Many**: One record in a table is related to many records in another table.
- **Many-to-Many**: Many records in a table are related to many records in another table, often requiring a junction
  table.

## 16. Explain the `GROUP BY` and `HAVING` clauses in MySQL.

- **GROUP BY**: Groups rows that have the same values into summary rows (e.g., SUM, COUNT).
- **HAVING**: Used to filter the results of a `GROUP BY` query, similar to `WHERE`, but for aggregated results.

```sql
SELECT user_id, COUNT(*) AS order_count
FROM orders
GROUP BY user_id
HAVING order_count > 5;
```
## 17. What is the use of the `LIMIT` clause in MySQL?

The `LIMIT` clause is used to specify the number of records to return from a query. It is commonly used to paginate
results.

## 18. What are stored procedures in MySQL, and how are they different from functions?

- **Stored Procedures**: A set of SQL statements that can be executed repeatedly. They can perform actions (
  like `INSERT`, `UPDATE`, etc.).
- **Functions**: Similar to stored procedures but always return a value and cannot perform actions like `INSERT`
  or `UPDATE`.

```sql
-- Procedures
DELIMITER //
CREATE PROCEDURE GetUserOrders(IN userId INT)
BEGIN
    SELECT * FROM orders WHERE user_id = userId;
END //
DELIMITER ;
    -- Function
DELIMITER //    
CREATE FUNCTION GetOrderTotal(orderId INT)
RETURNS DECIMAL(10, 2)
BEGIN
    DECLARE total DECIMAL(10, 2);
    SELECT SUM(price) INTO total FROM order_items WHERE order_id = orderId;
    RETURN total;
END //  
DELIMITER ;
```
## 19. What is the `EXPLAIN` keyword used for in MySQL?

The `EXPLAIN` keyword provides information about how MySQL executes a query, helping optimize query performance by
showing how tables are scanned, joined, and which indexes are used.

## 20. What are triggers in MySQL, and how are they useful?

A trigger is a stored procedure that automatically executes in response to an event (e.g., `INSERT`, `UPDATE`, `DELETE`)
on a table. It helps automate tasks like maintaining audit logs or enforcing data integrity.
(similar to call_back functions in rails but this in the scope of database not coding)
```sql
CREATE TRIGGER before_insert_user
BEFORE INSERT ON users
FOR EACH ROW
SET NEW.created_at = NOW();
```
## 21. What are the different storage engines in MySQL? Explain `InnoDB` and `MyISAM`.

- **InnoDB**: Supports ACID transactions, foreign keys, and row-level locking. It is the default storage engine.
- **MyISAM**: Does not support transactions, foreign keys, or row-level locking. It is faster for read-heavy
  applications.

## 22. How does MySQL handle transactions, and what are the isolation levels available?

MySQL supports transactions to ensure data consistency. The isolation levels are:

- **READ UNCOMMITTED**
- **READ COMMITTED**
- **REPEATABLE READ**
- **SERIALIZABLE**

## 23. What is indexing in MySQL, and how does it improve performance?

An index is a data structure that improves query performance by allowing fast lookup of rows in a table based on the
values of one or more columns.

## 24. What is full-text indexing in MySQL?

Full-text indexing allows efficient searching of textual data in columns. It is typically used for searching large
amounts of text, such as in blog posts or articles.

## 25. How can you optimize a slow MySQL query?

- Analyze and optimize query execution plans using `EXPLAIN`.
- Add appropriate indexes.
- Optimize subqueries.
- Avoid SELECT * and select only required columns.
- Optimize joins and limit the number of rows returned.

```sql
EXPLAIN SELECT * FROM orders WHERE user_id = 1;
```
## 26. What are the best practices for database indexing?

- Index columns frequently used in `WHERE`, `ORDER BY`, and `JOIN` clauses.
- Avoid over-indexing, as it can slow down insert and update operations.
- Use composite indexes where necessary.

## 27. What is a deadlock, and how do you handle it in MySQL?

  A deadlock occurs when two or more transactions block each other by holding locks on resources that the others need.
MySQL automatically detects deadlocks and rolls back one of the transactions. To handle it, ensure transactions are kept
short and avoid circular dependencies.
```sql
-- Transaction 1
START TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;

-- Transaction 2
START TRANSACTION;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;

-- The deadlock occurs when both transactions try to update the same row.
```
## 28. Explain replication in MySQL.

Replication is the process of copying data from one MySQL database (the master) to one or more MySQL databases (the
slaves). It is used for load balancing, backup, and redundancy.

## 29. How can you back up and restore a MySQL database?

- **Backup**: Use the `mysqldump` command to create a backup of the database.
- **Restore**: Use the `mysql` command to import the backup.

## 30. What is partitioning in MySQL, and how can it improve query performance?

Partitioning divides large tables into smaller, more manageable pieces, improving query performance by limiting the
amount of data to scan. It is particularly useful for time-based data, like logs or events.
