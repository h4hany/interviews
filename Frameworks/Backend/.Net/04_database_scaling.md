# Database Scaling & Optimization
## Principal Engineer Interview Preparation - BrandOS Edition

> **Target**: Staff/Principal Backend Engineer interviews  
> **Focus**: Database scaling, query optimization, concurrency, performance  
> **Format**: Deep technical questions with BrandOS PostgreSQL examples

---

## Table of Contents

1. [Indexing Strategy](#indexing-strategy)
2. [Query Optimization](#query-optimization)
3. [Deadlocks & Concurrency](#deadlocks--concurrency)
4. [Isolation Levels](#isolation-levels)
5. [Transaction Strategy](#transaction-strategy)
6. [Read Replicas](#read-replicas)
7. [Partitioning & Sharding](#partitioning--sharding)
8. [Handling Large Datasets](#handling-large-datasets)
9. [Caching vs Database](#caching-vs-database)
10. [Consistency vs Availability](#consistency-vs-availability)
11. [Migration Strategy](#migration-strategy)
12. [Schema Evolution](#schema-evolution)
13. [Avoiding N+1 Queries](#avoiding-n1-queries)
14. [Database Performance Tuning](#database-performance-tuning)
15. [Real Issues from BrandOS](#real-issues-from-brandos)

---

## Indexing Strategy

### Question 1: Design indexes for BrandOS orders table

**Interview Stage**: Database Design (70% probability)  
**Difficulty**: Staff/Principal  
**Why Asked**: Tests understanding of query patterns and indexing

#### Strong Answer

**Index Design Principles**:
1. **Index on WHERE clauses**: Most selective first
2. **Composite indexes**: Order matters (left-prefix rule)
3. **Covering indexes**: Include columns in SELECT
4. **Avoid over-indexing**: Each index slows writes

**BrandOS Orders Table**:
```sql
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    tenant_id INT NOT NULL,
    customer_id INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    total_amount DECIMAL(18,2),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP,
    INDEX idx_tenant_created (tenant_id, created_at DESC),
    INDEX idx_tenant_status (tenant_id, status),
    INDEX idx_customer_created (customer_id, created_at DESC)
);
```

**Why These Indexes**:
1. **idx_tenant_created**: Most queries filter by tenant_id, then sort by created_at
2. **idx_tenant_status**: Filter by tenant + status (e.g., "pending orders")
3. **idx_customer_created**: Customer order history

**Query Patterns**:
```sql
-- Uses idx_tenant_created
SELECT * FROM orders 
WHERE tenant_id = 123 
ORDER BY created_at DESC 
LIMIT 20;

-- Uses idx_tenant_status
SELECT * FROM orders 
WHERE tenant_id = 123 AND status = 'Pending';

-- Uses idx_customer_created
SELECT * FROM orders 
WHERE customer_id = 456 
ORDER BY created_at DESC;
```

**Index Selection**:
- **B-tree**: Default, good for range queries
- **Hash**: Equality only, faster for exact matches
- **GIN**: Full-text search, JSON queries
- **BRIN**: Large tables with sorted data

#### Follow-up Questions

**Q: When should you use a partial index?**
```sql
-- Index only active orders (smaller, faster)
CREATE INDEX idx_tenant_active_orders 
ON orders (tenant_id, created_at DESC) 
WHERE status = 'Active';

-- Reduces index size by 80% if most orders are historical
```

**Q: How do you measure index effectiveness?**
```sql
-- PostgreSQL: EXPLAIN ANALYZE
EXPLAIN ANALYZE
SELECT * FROM orders 
WHERE tenant_id = 123 
ORDER BY created_at DESC 
LIMIT 20;

-- Look for:
-- - Index Scan (good)
-- - Seq Scan (bad, needs index)
-- - Index Only Scan (best, covering index)
```

#### Weak Answer Example

❌ "Index everything. More indexes = faster queries."

**Why Weak**: Doesn't understand write performance impact, index selection.

#### FAANG Evaluation

**Strong Candidate**:
- Understands query patterns
- Designs indexes based on access patterns
- Knows when to use different index types
- Measures effectiveness

**Weak Candidate**:
- Indexes everything
- Doesn't understand tradeoffs
- No measurement

---

## Query Optimization

### Question 2: Optimize a slow query in BrandOS

**Interview Stage**: Performance (80% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for production performance

#### Strong Answer

**Query Optimization Process**:
1. **Identify**: Slow query logging
2. **Analyze**: EXPLAIN ANALYZE
3. **Optimize**: Indexes, query rewrite, pagination
4. **Measure**: Before/after comparison

**BrandOS Slow Query Example**:
```sql
-- ❌ Slow: Full table scan
SELECT o.*, c.name, c.email
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE o.tenant_id = 123
  AND o.created_at >= '2024-01-01'
ORDER BY o.created_at DESC;

-- Problem: No index on (tenant_id, created_at)
-- Solution: Add composite index
CREATE INDEX idx_orders_tenant_created 
ON orders (tenant_id, created_at DESC);

-- ✅ Optimized: Uses index
-- Execution time: 50ms → 5ms
```

**BrandOS Query Optimization Techniques**:

**1. Use EXPLAIN ANALYZE**:
```sql
EXPLAIN ANALYZE
SELECT * FROM orders 
WHERE tenant_id = 123 
ORDER BY created_at DESC 
LIMIT 20;

-- Output:
-- Limit (cost=0.43..12.45 rows=20) (actual time=0.123..0.456 rows=20)
--   -> Index Scan using idx_tenant_created on orders
--         Index Cond: (tenant_id = 123)
-- Planning Time: 0.123 ms
-- Execution Time: 0.456 ms
```

**2. Avoid SELECT ***:
```sql
-- ❌ Fetches all columns (unnecessary data transfer)
SELECT * FROM orders WHERE tenant_id = 123;

-- ✅ Select only needed columns
SELECT id, customer_id, total_amount, status 
FROM orders 
WHERE tenant_id = 123;
```

**3. Use Pagination**:
```sql
-- ❌ Fetches all rows, then limits
SELECT * FROM orders 
WHERE tenant_id = 123 
ORDER BY created_at DESC 
LIMIT 20 OFFSET 1000; -- Slow for large offsets

-- ✅ Use cursor-based pagination
SELECT * FROM orders 
WHERE tenant_id = 123 
  AND created_at < '2024-01-15'
ORDER BY created_at DESC 
LIMIT 20; -- Fast, consistent
```

**4. Avoid N+1 Queries** (see section below)

**5. Use EXISTS instead of COUNT**:
```sql
-- ❌ Counts all rows
SELECT COUNT(*) FROM orders 
WHERE tenant_id = 123 AND status = 'Pending';

-- ✅ Stops at first match
SELECT EXISTS(
    SELECT 1 FROM orders 
    WHERE tenant_id = 123 AND status = 'Pending'
);
```

#### Follow-up Questions

**Q: How do you optimize JOINs?**
```sql
-- Ensure foreign keys are indexed
CREATE INDEX idx_orders_customer_id ON orders (customer_id);

-- Use INNER JOIN when possible (faster than LEFT JOIN)
SELECT o.*, c.name
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id
WHERE o.tenant_id = 123;
```

**Q: When should you denormalize?**
```sql
-- Normalized (3NF)
orders: id, customer_id, total_amount
customers: id, name, email

-- Denormalized (for read performance)
orders: id, customer_id, customer_name, customer_email, total_amount

-- Tradeoff: Faster reads, slower writes, data duplication
```

#### Weak Answer Example

❌ "Just add more indexes. That fixes everything."

**Why Weak**: Doesn't understand query analysis, when indexes help vs when they don't.

---

## Deadlocks & Concurrency

### Question 3: How do you prevent deadlocks in BrandOS?

**Interview Stage**: Concurrency (60% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for multi-tenant systems

#### Strong Answer

**Deadlock Prevention**:
1. **Lock Ordering**: Always acquire locks in same order
2. **Short Transactions**: Minimize lock hold time
3. **Index Locks**: Use indexes to reduce lock contention
4. **Isolation Levels**: Use appropriate level (not always SERIALIZABLE)

**BrandOS Deadlock Scenario**:
```sql
-- Transaction 1
BEGIN;
UPDATE orders SET status = 'Processing' WHERE id = 1;
UPDATE inventory_stocks SET quantity = quantity - 10 WHERE product_id = 100;
COMMIT;

-- Transaction 2 (concurrent)
BEGIN;
UPDATE inventory_stocks SET quantity = quantity - 5 WHERE product_id = 100;
UPDATE orders SET status = 'Processing' WHERE id = 1;
COMMIT;

-- Deadlock! Different lock order
```

**Solution - Lock Ordering**:
```csharp
// Always lock in same order (by ID)
public async Task ProcessOrderAsync(int orderId, int productId)
{
    var lockOrder = new[] { orderId, productId }.OrderBy(id => id);
    
    using var transaction = await _db.BeginTransactionAsync();
    try
    {
        // Lock in sorted order
        foreach (var id in lockOrder)
        {
            if (id == orderId)
            {
                await _db.Orders
                    .Where(o => o.Id == id)
                    .ExecuteUpdateAsync(o => o.SetProperty(x => x.Status, "Processing"));
            }
            else
            {
                await _db.InventoryStocks
                    .Where(s => s.ProductId == id)
                    .ExecuteUpdateAsync(s => s.SetProperty(x => x.Quantity, x => x.Quantity - 10));
            }
        }
        
        await transaction.CommitAsync();
    }
    catch (DbUpdateConcurrencyException)
    {
        await transaction.RollbackAsync();
        throw;
    }
}
```

**BrandOS Optimistic Concurrency**:
```csharp
// Use RowVersion for optimistic locking
public class BaseEntity
{
    public byte[] RowVersion { get; protected set; } // Concurrency token
}

// EF Core detects conflicts
try
{
    await _db.SaveChangesAsync();
}
catch (DbUpdateConcurrencyException ex)
{
    // Another transaction modified the row
    // Refresh and retry, or return conflict error
    await ex.Entries[0].ReloadAsync();
    // Retry logic or return 409 Conflict
}
```

#### Follow-up Questions

**Q: How do you detect deadlocks?**
```sql
-- PostgreSQL: Check for deadlocks in logs
-- Or query pg_stat_database for deadlock count

SELECT datname, deadlocks 
FROM pg_stat_database 
WHERE datname = 'brandos';
```

**Q: What's the difference between deadlock and lock timeout?**
```csharp
// Deadlock: Circular wait (PostgreSQL detects and aborts)
// Lock timeout: Waits too long for lock (configure timeout)

// Set lock timeout
await _db.Database.ExecuteSqlRawAsync("SET lock_timeout = '5s'");
```

---

## Isolation Levels

### Question 4: Explain database isolation levels

**Interview Stage**: Database Fundamentals (70% probability)  
**Difficulty**: Staff/Principal  
**Why Asked**: Critical for understanding concurrency

#### Strong Answer

**ACID Isolation Levels** (from least to most strict):

1. **READ UNCOMMITTED**: Can read uncommitted data (dirty reads)
2. **READ COMMITTED**: Can only read committed data (default in PostgreSQL)
3. **REPEATABLE READ**: Same read returns same data (prevents non-repeatable reads)
4. **SERIALIZABLE**: Highest isolation (prevents phantom reads)

**PostgreSQL Default**: READ COMMITTED

**BrandOS Example - READ COMMITTED**:
```csharp
// Default isolation level
using var transaction = await _db.BeginTransactionAsync(
    IsolationLevel.ReadCommitted);

// Transaction 1
var order = await _db.Orders.FindAsync(1); // Reads committed data
// Another transaction commits changes to order
var order2 = await _db.Orders.FindAsync(1); // May read different data (non-repeatable read)

await transaction.CommitAsync();
```

**BrandOS Example - REPEATABLE READ**:
```csharp
// Prevents non-repeatable reads
using var transaction = await _db.BeginTransactionAsync(
    IsolationLevel.RepeatableRead);

var order = await _db.Orders.FindAsync(1); // Snapshot taken
// Another transaction commits changes
var order2 = await _db.Orders.FindAsync(1); // Same data (snapshot isolation)

await transaction.CommitAsync();
```

**When to Use Each**:
- **READ COMMITTED**: Most cases (default, good performance)
- **REPEATABLE READ**: Need consistent reads (financial calculations)
- **SERIALIZABLE**: Critical consistency (rare, high overhead)

**BrandOS Financial Transactions**:
```csharp
// Use REPEATABLE READ for financial operations
public async Task<Result> ProcessPaymentAsync(PaymentRequest request)
{
    using var transaction = await _db.BeginTransactionAsync(
        IsolationLevel.RepeatableRead);
    
    try
    {
        // Consistent read of balance
        var wallet = await _db.Wallets.FindAsync(request.WalletId);
        if (wallet.Balance < request.Amount)
            return Result.Failure("Insufficient balance");
        
        // Deduct amount
        wallet.Balance -= request.Amount;
        await _db.SaveChangesAsync();
        
        await transaction.CommitAsync();
        return Result.Success();
    }
    catch (Exception)
    {
        await transaction.RollbackAsync();
        throw;
    }
}
```

#### Follow-up Questions

**Q: What are phantom reads?**
```sql
-- Transaction 1
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT COUNT(*) FROM orders WHERE tenant_id = 123; -- Returns 100

-- Transaction 2 (commits)
INSERT INTO orders (tenant_id, ...) VALUES (123, ...);
COMMIT;

-- Transaction 1 (same query)
SELECT COUNT(*) FROM orders WHERE tenant_id = 123; -- Still returns 100 (REPEATABLE READ prevents phantom reads)
COMMIT;
```

**Q: How does PostgreSQL implement isolation?**
- **MVCC (Multi-Version Concurrency Control)**: Each transaction sees a snapshot
- **No locks for reads**: Reads don't block writes
- **Write locks**: Only writes lock rows

---

## Transaction Strategy

### Question 5: Design transaction boundaries for BrandOS checkout

**Interview Stage**: System Design (80% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for data consistency

#### Strong Answer

**Transaction Design Principles**:
1. **Keep transactions short**: Minimize lock time
2. **One business operation = one transaction**: Atomicity
3. **Avoid long-running transactions**: Can cause deadlocks
4. **Use compensating actions**: For distributed transactions

**BrandOS Checkout Transaction**:
```csharp
public async Task<Order> CheckoutAsync(CheckoutRequest request)
{
    // Single transaction for atomicity
    using var transaction = await _db.BeginTransactionAsync();
    try
    {
        // 1. Reserve inventory (must be atomic with order creation)
        foreach (var item in request.Items)
        {
            var stock = await _db.InventoryStocks
                .Where(s => s.ProductVariantId == item.ProductVariantId)
                .FirstOrDefaultAsync();
            
            if (stock.AvailableQuantity < item.Quantity)
            {
                throw new OutOfStockException();
            }
            
            stock.ReservedQuantity += item.Quantity;
            stock.AvailableQuantity -= item.Quantity;
        }
        
        // 2. Create order (same transaction)
        var order = new Order(request.CustomerId, request.Items);
        await _db.Orders.AddAsync(order);
        
        // 3. Create order items
        foreach (var item in request.Items)
        {
            var orderItem = new OrderItem(order.Id, item.ProductVariantId, item.Quantity);
            await _db.OrderItems.AddAsync(orderItem);
        }
        
        // 4. Save all changes atomically
        await _db.SaveChangesAsync();
        await transaction.CommitAsync();
        
        // 5. Async operations (outside transaction)
        _ = Task.Run(async () =>
        {
            await SendConfirmationEmailAsync(order); // Best-effort, don't fail checkout
            await PublishEventAsync(new OrderConfirmedEvent(order)); // Outbox pattern
        });
        
        return order;
    }
    catch (Exception)
    {
        await transaction.RollbackAsync();
        throw;
    }
}
```

**Why This Design**:
- **Atomic**: Inventory reservation + order creation in one transaction
- **Short**: Transaction only includes critical operations
- **Resilient**: Email/events are async (don't block checkout)

**Distributed Transactions (Saga Pattern)**:
```csharp
// For operations spanning multiple services
public async Task<Order> CheckoutWithPaymentAsync(CheckoutRequest request)
{
    // Step 1: Create order (local transaction)
    var order = await CreateOrderAsync(request);
    
    try
    {
        // Step 2: Process payment (external service)
        var payment = await _paymentGateway.ChargeAsync(request.PaymentMethod, order.TotalAmount);
        
        // Step 3: Update order with payment
        order.PaymentId = payment.Id;
        await _db.SaveChangesAsync();
        
        return order;
    }
    catch (PaymentFailedException)
    {
        // Compensating action: Cancel order
        await CancelOrderAsync(order.Id);
        throw;
    }
}
```

#### Follow-up Questions

**Q: When should you use distributed transactions?**
```csharp
// ❌ Avoid: Two-phase commit (2PC) is slow and complex
// ✅ Use: Saga pattern (compensating actions)

// Saga example:
// 1. Reserve inventory (local transaction)
// 2. Charge payment (external service)
// 3. If payment fails: Release inventory (compensating action)
```

---

## Read Replicas

### Question 6: Design read replica strategy for BrandOS

**Interview Stage**: Scalability (70% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for scaling reads

#### Strong Answer

**Read Replica Strategy**:
1. **Primary**: All writes
2. **Replicas**: Read-only, async replication
3. **Routing**: Route reads to replicas, writes to primary

**BrandOS Read Replica Setup**:
```csharp
// Connection strings
var primaryConnection = "Host=db-primary;Database=brandos;...";
var replicaConnection = "Host=db-replica;Database=brandos;...";

// DbContext factory
public class ApplicationDbContextFactory
{
    private readonly string _writeConnection;
    private readonly string _readConnection;
    
    public ApplicationDbContext CreateWriteContext()
    {
        return new ApplicationDbContext(_writeConnection);
    }
    
    public ApplicationDbContext CreateReadContext()
    {
        return new ApplicationDbContext(_readConnection);
    }
}

// Usage in services
public class OrderService
{
    public async Task<Order> GetOrderAsync(int id) // Read
    {
        using var context = _dbFactory.CreateReadContext(); // Replica
        return await context.Orders.FindAsync(id);
    }
    
    public async Task<Order> CreateOrderAsync(Order order) // Write
    {
        using var context = _dbFactory.CreateWriteContext(); // Primary
        await context.Orders.AddAsync(order);
        await context.SaveChangesAsync();
        return order;
    }
}
```

**Replication Lag Considerations**:
```csharp
// Problem: Replica may be slightly behind primary
// Solution: Read-after-write consistency

public async Task<Order> CreateOrderAsync(Order order)
{
    // Write to primary
    using var writeContext = _dbFactory.CreateWriteContext();
    await writeContext.Orders.AddAsync(order);
    await writeContext.SaveChangesAsync();
    
    // Read from primary (not replica) for immediate consistency
    return await writeContext.Orders.FindAsync(order.Id);
}

// For subsequent reads, replica is fine (eventual consistency acceptable)
```

**Load Balancing Reads**:
```csharp
// Round-robin across replicas
private readonly ApplicationDbContext[] _readContexts;
private int _currentReplica = 0;

public ApplicationDbContext GetReadContext()
{
    var context = _readContexts[_currentReplica];
    _currentReplica = (_currentReplica + 1) % _readContexts.Length;
    return context;
}
```

#### Follow-up Questions

**Q: How do you handle replica failures?**
```csharp
// Health check replicas
public async Task<ApplicationDbContext> GetReadContext()
{
    foreach (var replica in _replicas)
    {
        if (await IsHealthyAsync(replica))
        {
            return replica;
        }
    }
    
    // Fallback to primary if all replicas down
    return _primaryContext;
}
```

**Q: When should you read from primary?**
```csharp
// Read-after-write scenarios
// - User creates order, immediately views it
// - Financial data (need latest balance)

// Use replica for:
// - Historical data
// - Reports
// - Analytics
```

---

## Partitioning & Sharding

### Question 7: Design database sharding for BrandOS

**Interview Stage**: Scalability (50% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for massive scale

#### Strong Answer

**Sharding Strategy**:
1. **Shard Key**: tenant_id (natural shard key for multi-tenant)
2. **Shard Count**: 10 shards (1,000 tenants per shard)
3. **Routing**: Hash tenant_id to shard

**BrandOS Sharding Design**:
```csharp
// Shard router
public class ShardRouter
{
    private readonly int _shardCount = 10;
    private readonly Dictionary<int, string> _shardConnections;
    
    public string GetShardConnection(int tenantId)
    {
        var shardId = tenantId % _shardCount;
        return _shardConnections[shardId];
    }
}

// Usage
public class OrderRepository
{
    public async Task<Order> GetOrderAsync(int tenantId, int orderId)
    {
        var connection = _shardRouter.GetShardConnection(tenantId);
        using var context = new ApplicationDbContext(connection);
        return await context.Orders
            .Where(o => o.Id == orderId && o.TenantId == tenantId)
            .FirstOrDefaultAsync();
    }
}
```

**Cross-Shard Queries**:
```csharp
// Problem: Can't JOIN across shards
// Solution: Application-level aggregation

public async Task<decimal> GetTotalRevenueAsync(int tenantId, DateOnly date)
{
    // Query all shards (if tenant data spans shards - rare for tenant-based sharding)
    var tasks = _shards.Select(async shard =>
    {
        using var context = new ApplicationDbContext(shard.Connection);
        return await context.Orders
            .Where(o => o.TenantId == tenantId && o.CreatedAt.Date == date)
            .SumAsync(o => o.TotalAmount);
    });
    
    var results = await Task.WhenAll(tasks);
    return results.Sum();
}
```

**Partitioning (Single Database)**:
```sql
-- Partition orders table by date
CREATE TABLE orders_2024_01 PARTITION OF orders
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE orders_2024_02 PARTITION OF orders
FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Benefits:
-- - Faster queries (only scan relevant partition)
-- - Easier archiving (drop old partitions)
-- - Better maintenance (vacuum individual partitions)
```

#### Follow-up Questions

**Q: How do you rebalance shards?**
```csharp
// When shard becomes too large:
// 1. Create new shard
// 2. Migrate tenant data (background job)
// 3. Update routing
// 4. Verify data integrity
// 5. Switch traffic
```

**Q: What's the difference between sharding and partitioning?**
- **Sharding**: Multiple databases (horizontal scaling)
- **Partitioning**: Single database, multiple tables (logical separation)

---

## Handling Large Datasets

### Question 8: How do you handle large datasets in BrandOS?

**Interview Stage**: Performance (60% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for production systems

#### Strong Answer

**Large Dataset Strategies**:
1. **Pagination**: Limit result sets
2. **Streaming**: Process in chunks
3. **Archiving**: Move old data to cold storage
4. **Aggregation**: Pre-compute summaries

**BrandOS Pagination**:
```csharp
// ❌ Bad: Loads all rows into memory
public async Task<List<Order>> GetOrdersAsync(int tenantId)
{
    return await _db.Orders
        .Where(o => o.TenantId == tenantId)
        .ToListAsync(); // Loads all orders!
}

// ✅ Good: Pagination
public async Task<PagedResult<Order>> GetOrdersAsync(
    int tenantId, 
    int page, 
    int pageSize)
{
    var total = await _db.Orders
        .Where(o => o.TenantId == tenantId)
        .CountAsync();
    
    var orders = await _db.Orders
        .Where(o => o.TenantId == tenantId)
        .OrderByDescending(o => o.CreatedAt)
        .Skip((page - 1) * pageSize)
        .Take(pageSize)
        .ToListAsync();
    
    return new PagedResult<Order>(orders, total, page, pageSize);
}

// ✅ Better: Cursor-based pagination (no OFFSET)
public async Task<List<Order>> GetOrdersAsync(
    int tenantId, 
    DateTime? before = null)
{
    var query = _db.Orders
        .Where(o => o.TenantId == tenantId);
    
    if (before.HasValue)
    {
        query = query.Where(o => o.CreatedAt < before.Value);
    }
    
    return await query
        .OrderByDescending(o => o.CreatedAt)
        .Take(20)
        .ToListAsync();
}
```

**BrandOS Streaming**:
```csharp
// Process large datasets in chunks
public async Task ProcessAllOrdersAsync(int tenantId)
{
    const int batchSize = 1000;
    var lastId = 0;
    
    while (true)
    {
        var batch = await _db.Orders
            .Where(o => o.TenantId == tenantId && o.Id > lastId)
            .OrderBy(o => o.Id)
            .Take(batchSize)
            .ToListAsync();
        
        if (batch.Count == 0) break;
        
        foreach (var order in batch)
        {
            await ProcessOrderAsync(order);
        }
        
        lastId = batch.Last().Id;
    }
}
```

**BrandOS Archiving**:
```csharp
// Move old data to archive table
public async Task ArchiveOldOrdersAsync(DateOnly beforeDate)
{
    // 1. Copy to archive table
    await _db.Database.ExecuteSqlRawAsync(@"
        INSERT INTO orders_archive
        SELECT * FROM orders
        WHERE created_at < {0}
    ", beforeDate);
    
    // 2. Delete from main table
    await _db.Database.ExecuteSqlRawAsync(@"
        DELETE FROM orders
        WHERE created_at < {0}
    ", beforeDate);
}
```

---

## Caching vs Database

### Question 9: When should you cache vs query the database?

**Interview Stage**: Architecture (80% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for performance decisions

#### Strong Answer

**Caching Strategy**:
1. **Cache Hot Data**: Frequently accessed, rarely changed
2. **Cache Expensive Queries**: Complex joins, aggregations
3. **Don't Cache**: Frequently changed, real-time requirements

**BrandOS Caching Examples**:

**✅ Good to Cache**:
```csharp
// Permissions (rarely change, frequently accessed)
public async Task<Permissions> GetPermissionsAsync(int userId)
{
    var cacheKey = $"permissions:user:{userId}";
    var cached = await _cache.GetAsync<Permissions>(cacheKey);
    if (cached != null) return cached;
    
    var permissions = await _db.Permissions
        .Where(p => p.UserId == userId)
        .ToListAsync();
    
    await _cache.SetAsync(cacheKey, permissions, TimeSpan.FromMinutes(30));
    return permissions;
}

// Feature flags (rarely change)
public async Task<bool> IsFeatureEnabledAsync(int tenantId, string feature)
{
    var cacheKey = $"feature:{tenantId}:{feature}";
    var cached = await _cache.GetAsync<bool>(cacheKey);
    if (cached.HasValue) return cached.Value;
    
    var enabled = await _featureFlagService.IsEnabledAsync(tenantId, feature);
    await _cache.SetAsync(cacheKey, enabled, TimeSpan.FromMinutes(15));
    return enabled;
}
```

**❌ Don't Cache**:
```csharp
// Real-time inventory (changes frequently)
public async Task<int> GetAvailableQuantityAsync(int productVariantId)
{
    // Don't cache - need real-time data
    return await _db.InventoryStocks
        .Where(s => s.ProductVariantId == productVariantId)
        .SumAsync(s => s.AvailableQuantity);
}

// User's current cart (changes on every action)
public async Task<Cart> GetCartAsync(int customerId)
{
    // Don't cache - changes too frequently
    return await _db.Carts
        .Include(c => c.Items)
        .FirstOrDefaultAsync(c => c.CustomerId == customerId);
}
```

**Cache Invalidation**:
```csharp
// Invalidate cache when data changes
public async Task UpdatePermissionsAsync(int userId, Permissions permissions)
{
    await _db.Permissions.UpdateAsync(permissions);
    await _db.SaveChangesAsync();
    
    // Invalidate cache
    await _cache.RemoveAsync($"permissions:user:{userId}");
}
```

#### Follow-up Questions

**Q: How do you handle cache stampede?**
```csharp
// Problem: Multiple requests miss cache, all query database
// Solution: Lock during cache refresh

private readonly SemaphoreSlim _cacheLock = new(1, 1);

public async Task<Permissions> GetPermissionsAsync(int userId)
{
    var cacheKey = $"permissions:user:{userId}";
    var cached = await _cache.GetAsync<Permissions>(cacheKey);
    if (cached != null) return cached;
    
    // Only one request fetches from DB
    await _cacheLock.WaitAsync();
    try
    {
        // Double-check (another request might have cached it)
        cached = await _cache.GetAsync<Permissions>(cacheKey);
        if (cached != null) return cached;
        
        var permissions = await _db.Permissions
            .Where(p => p.UserId == userId)
            .ToListAsync();
        
        await _cache.SetAsync(cacheKey, permissions, TimeSpan.FromMinutes(30));
        return permissions;
    }
    finally
    {
        _cacheLock.Release();
    }
}
```

---

## Consistency vs Availability

### Question 10: How do you balance consistency and availability in BrandOS?

**Interview Stage**: Distributed Systems (70% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for understanding CAP theorem

#### Strong Answer

**CAP Theorem**:
- **Consistency**: All nodes see same data
- **Availability**: System remains operational
- **Partition Tolerance**: System works despite network failures

**You can only guarantee 2 of 3**.

**BrandOS Strategy**:
- **CP (Consistency + Partition Tolerance)**: Financial data
- **AP (Availability + Partition Tolerance)**: Caching, analytics

**BrandOS Financial Data (CP)**:
```csharp
// Strong consistency for financial operations
public async Task<Result> ProcessPaymentAsync(PaymentRequest request)
{
    using var transaction = await _db.BeginTransactionAsync(
        IsolationLevel.RepeatableRead); // Strong consistency
    
    try
    {
        var wallet = await _db.Wallets.FindAsync(request.WalletId);
        if (wallet.Balance < request.Amount)
            return Result.Failure("Insufficient balance");
        
        wallet.Balance -= request.Amount;
        await _db.SaveChangesAsync();
        await transaction.CommitAsync();
        
        return Result.Success();
    }
    catch (Exception)
    {
        await transaction.RollbackAsync();
        throw; // Fail rather than return inconsistent data
    }
}
```

**BrandOS Caching (AP)**:
```csharp
// Eventual consistency for caching
public async Task<Permissions> GetPermissionsAsync(int userId)
{
    var cached = await _cache.GetAsync<Permissions>($"permissions:{userId}");
    if (cached != null) return cached; // May be stale, but available
    
    // If cache unavailable, fetch from DB (still available)
    return await _db.Permissions
        .Where(p => p.UserId == userId)
        .ToListAsync();
}
```

**BrandOS Analytics (AP)**:
```csharp
// Eventual consistency for analytics (acceptable delay)
public async Task<SalesMetrics> GetSalesMetricsAsync(int tenantId, DateOnly date)
{
    // May be slightly behind (updated hourly), but always available
    var snapshot = await _db.SalesDailySnapshots
        .FirstOrDefaultAsync(s => s.TenantId == tenantId && s.Date == date);
    
    return snapshot?.Metrics ?? new SalesMetrics(); // Return default if not available
}
```

#### Follow-up Questions

**Q: How do you handle read-after-write consistency?**
```csharp
// Problem: Write to primary, read from replica (may be stale)
// Solution: Read from primary for immediate reads

public async Task<Order> CreateOrderAsync(Order order)
{
    // Write to primary
    await _writeDb.Orders.AddAsync(order);
    await _writeDb.SaveChangesAsync();
    
    // Read from primary (not replica) for immediate consistency
    return await _writeDb.Orders.FindAsync(order.Id);
}

// Subsequent reads can use replica (eventual consistency acceptable)
```

---

## Migration Strategy

### Question 11: How do you handle database migrations in BrandOS?

**Interview Stage**: Operations (50% probability)  
**Difficulty**: Staff  
**Why Asked**: Critical for zero-downtime deployments

#### Strong Answer

**Migration Strategy**:
1. **Backward Compatible**: Add columns as nullable first
2. **Gradual Migration**: Migrate data in batches
3. **Feature Flags**: Roll out gradually
4. **Rollback Plan**: Can revert if issues

**BrandOS Migration Example**:
```csharp
// Migration: Add new column
public partial class AddOrderNotes : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        // Add column as nullable (backward compatible)
        migrationBuilder.AddColumn<string>(
            name: "notes",
            table: "orders",
            nullable: true); // Nullable allows existing rows
        
        // Populate data in background job (gradual migration)
        // Then make NOT NULL in separate migration
    }
    
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropColumn(
            name: "notes",
            table: "orders");
    }
}
```

**Zero-Downtime Migration Process**:
1. **Add Column**: Nullable, no default
2. **Deploy Code**: Handles both old and new schema
3. **Migrate Data**: Background job populates new column
4. **Make Required**: After all data migrated
5. **Remove Old Code**: After all instances updated

**BrandOS Migration Scripts**:
```bash
# Create migration
dotnet ef migrations add AddOrderNotes --project src/BrandOS.Infrastructure

# Apply migration (production)
dotnet ef database update --project src/BrandOS.Infrastructure --startup-project src/BrandOS.API

# Or use migration runner (automatic on startup)
# MigrationRunner.ApplyMigrationsAsync() in Program.cs
```

---

## Schema Evolution

### Question 12: How do you evolve database schema without downtime?

**Interview Stage**: Operations (40% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for production systems

#### Strong Answer

**Schema Evolution Principles**:
1. **Additive Changes**: Add columns, don't remove
2. **Backward Compatible**: Old code works with new schema
3. **Gradual Rollout**: Migrate data, then update code
4. **Versioning**: Track schema versions

**BrandOS Schema Evolution**:
```csharp
// Step 1: Add new column (nullable)
ALTER TABLE orders ADD COLUMN notes VARCHAR(500) NULL;

// Step 2: Deploy code that handles both old and new
public class Order
{
    public string? Notes { get; set; } // Nullable, backward compatible
}

// Step 3: Migrate data (background job)
public async Task MigrateOrderNotesAsync()
{
    var orders = await _db.Orders
        .Where(o => o.Notes == null)
        .Take(1000)
        .ToListAsync();
    
    foreach (var order in orders)
    {
        order.Notes = await GenerateNotesAsync(order);
    }
    
    await _db.SaveChangesAsync();
}

// Step 4: Make required (after all data migrated)
ALTER TABLE orders ALTER COLUMN notes SET NOT NULL;

// Step 5: Remove old code (after all instances updated)
```

---

## Avoiding N+1 Queries

### Question 13: How do you prevent N+1 queries in BrandOS?

**Interview Stage**: Performance (90% probability)  
**Difficulty**: Staff  
**Why Asked**: Common performance issue

#### Strong Answer

**N+1 Problem**:
```csharp
// ❌ N+1 queries
public async Task<List<Order>> GetOrdersWithItemsAsync()
{
    var orders = await _db.Orders.ToListAsync(); // 1 query
    
    foreach (var order in orders) // N queries
    {
        order.Items = await _db.OrderItems
            .Where(i => i.OrderId == order.Id)
            .ToListAsync(); // 1 query per order!
    }
    
    return orders; // Total: 1 + N queries
}
```

**Solutions**:

**1. Eager Loading (Include)**:
```csharp
// ✅ Single query with JOIN
public async Task<List<Order>> GetOrdersWithItemsAsync()
{
    return await _db.Orders
        .Include(o => o.Items) // Eager load
        .ToListAsync(); // 1 query with JOIN
}
```

**2. Explicit Loading**:
```csharp
// ✅ Load related data explicitly
public async Task<List<Order>> GetOrdersWithItemsAsync()
{
    var orders = await _db.Orders.ToListAsync(); // 1 query
    
    var orderIds = orders.Select(o => o.Id).ToList();
    var items = await _db.OrderItems
        .Where(i => orderIds.Contains(i.OrderId))
        .ToListAsync(); // 1 query for all items
    
    // Group items by order
    var itemsByOrder = items.GroupBy(i => i.OrderId).ToDictionary(g => g.Key, g => g.ToList());
    foreach (var order in orders)
    {
        order.Items = itemsByOrder.GetValueOrDefault(order.Id, new List<OrderItem>());
    }
    
    return orders; // Total: 2 queries
}
```

**3. Projection (Select)**:
```csharp
// ✅ Select only needed data
public async Task<List<OrderDto>> GetOrdersWithItemsAsync()
{
    return await _db.Orders
        .Select(o => new OrderDto
        {
            Id = o.Id,
            TotalAmount = o.TotalAmount,
            Items = o.Items.Select(i => new OrderItemDto
            {
                Id = i.Id,
                Quantity = i.Quantity
            }).ToList()
        })
        .ToListAsync(); // Single query with JOIN
}
```

**BrandOS Example**:
```csharp
// BrandOS: Get orders with customer info
public async Task<List<Order>> GetOrdersWithCustomerAsync(int tenantId)
{
    return await _db.Orders
        .Include(o => o.Customer) // Eager load customer
        .Where(o => o.TenantId == tenantId)
        .ToListAsync(); // Single query
}
```

---

## Database Performance Tuning

### Question 14: How do you tune PostgreSQL for BrandOS?

**Interview Stage**: Operations (40% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for production performance

#### Strong Answer

**PostgreSQL Tuning Parameters**:

**1. shared_buffers**:
```sql
-- Cache size (25% of RAM for dedicated server)
shared_buffers = 2GB
```

**2. effective_cache_size**:
```sql
-- Estimate of OS cache (50-75% of RAM)
effective_cache_size = 6GB
```

**3. work_mem**:
```sql
-- Memory for sorts and joins (per operation)
work_mem = 64MB
```

**4. maintenance_work_mem**:
```sql
-- Memory for maintenance operations (VACUUM, CREATE INDEX)
maintenance_work_mem = 512MB
```

**5. max_connections**:
```sql
-- Connection pool size
max_connections = 200

-- Use connection pooling (PgBouncer) to reduce connections
```

**BrandOS Connection Pooling**:
```csharp
// EF Core connection pooling (default: 100 connections)
builder.Services.AddDbContext<ApplicationDbContext>(options =>
{
    options.UseNpgsql(connectionString, npgsqlOptions =>
    {
        npgsqlOptions.MaxBatchSize(100); // Batch operations
        npgsqlOptions.CommandTimeout(30); // Timeout
    });
});

// Or use PgBouncer for connection pooling
// connectionString = "Host=pgbouncer;Database=brandos;..."
```

**Monitoring**:
```sql
-- Check slow queries
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Check index usage
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0; -- Unused indexes

-- Check table sizes
SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

---

## Real Issues from BrandOS

### Question 15: Analyze real performance issues in BrandOS

**Interview Stage**: Problem Solving (60% probability)  
**Difficulty**: Principal  
**Why Asked**: Tests ability to diagnose production issues

#### Strong Answer

**Issue 1: Slow Query on Orders Table**

**Symptom**: Orders list page takes 5 seconds to load

**Diagnosis**:
```sql
-- Check query plan
EXPLAIN ANALYZE
SELECT * FROM orders 
WHERE tenant_id = 123 
ORDER BY created_at DESC 
LIMIT 20;

-- Problem: Seq Scan (full table scan)
-- Solution: Add index
CREATE INDEX idx_orders_tenant_created ON orders (tenant_id, created_at DESC);
```

**Issue 2: N+1 Queries in Order Items**

**Symptom**: High database load when loading orders

**Diagnosis**:
```csharp
// Check logs for multiple queries
// Problem: N+1 queries
// Solution: Use Include
var orders = await _db.Orders
    .Include(o => o.Items)
    .ToListAsync();
```

**Issue 3: Connection Pool Exhaustion**

**Symptom**: "Too many connections" errors

**Diagnosis**:
```sql
-- Check active connections
SELECT count(*) FROM pg_stat_activity;

-- Problem: Too many connections
-- Solution: Use connection pooling (PgBouncer)
```

**Issue 4: Deadlocks**

**Symptom**: Intermittent deadlock errors

**Diagnosis**:
```sql
-- Check deadlock count
SELECT datname, deadlocks FROM pg_stat_database WHERE datname = 'brandos';

-- Problem: Different lock order
-- Solution: Always lock in same order (by ID)
```

---

## Conclusion

### Key Takeaways

1. **Index Strategically**: Based on query patterns, not everything
2. **Optimize Queries**: Use EXPLAIN ANALYZE, avoid N+1
3. **Handle Concurrency**: Optimistic locking, proper isolation levels
4. **Scale Reads**: Read replicas, caching
5. **Scale Writes**: Sharding, partitioning
6. **Monitor Everything**: Slow queries, deadlocks, connection pool

### Practice Questions

1. Design indexes for a multi-tenant orders table
2. Optimize a slow query with JOINs
3. Prevent deadlocks in concurrent updates
4. Design read replica strategy
5. Handle N+1 queries in related data

---

**Remember**: Database performance is critical for backend systems. Understand not just SQL, but how databases work internally, how to optimize, and how to scale.



