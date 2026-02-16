# Backend Problem Solving
## Principal Engineer Interview Preparation - BrandOS Edition

> **Target**: Staff/Principal Backend Engineer interviews  
> **Focus**: Concurrency, performance, debugging, optimization  
> **Format**: Problem scenarios with optimal solutions

---

## Table of Contents

1. [Concurrency Problems](#concurrency-problems)
2. [Performance Tuning](#performance-tuning)
3. [Memory Optimization](#memory-optimization)
4. [Debugging Production Issues](#debugging-production-issues)
5. [Designing Efficient APIs](#designing-efficient-apis)
6. [Data Structure Tradeoffs](#data-structure-tradeoffs)
7. [Scaling Slow Services](#scaling-slow-services)
8. [Refactoring Complex Backend](#refactoring-complex-backend)

---

## Concurrency Problems

### Problem 1: Race Condition in Inventory Reservation

**Scenario**: 
"BrandOS checkout reserves inventory, but during flash sales, multiple users can reserve the same item, causing overselling."

**Current Code**:
```csharp
public async Task<bool> ReserveInventoryAsync(int productVariantId, int quantity)
{
    var stock = await _db.InventoryStocks
        .Where(s => s.ProductVariantId == productVariantId)
        .FirstOrDefaultAsync();
    
    if (stock.AvailableQuantity < quantity)
        return false;
    
    stock.ReservedQuantity += quantity;
    stock.AvailableQuantity -= quantity;
    await _db.SaveChangesAsync();
    
    return true;
}
```

**Problem**: Race condition - two requests can read same AvailableQuantity, both succeed, overselling occurs.

**Solution 1: Optimistic Locking** (Recommended)
```csharp
public async Task<bool> ReserveInventoryAsync(int productVariantId, int quantity)
{
    using var transaction = await _db.BeginTransactionAsync();
    try
    {
        // Lock row for update (pessimistic lock)
        var stock = await _db.InventoryStocks
            .Where(s => s.ProductVariantId == productVariantId)
            .FirstOrDefaultAsync();
        
        if (stock == null || stock.AvailableQuantity < quantity)
        {
            await transaction.RollbackAsync();
            return false;
        }
        
        stock.ReservedQuantity += quantity;
        stock.AvailableQuantity -= quantity;
        await _db.SaveChangesAsync();
        await transaction.CommitAsync();
        
        return true;
    }
    catch (DbUpdateConcurrencyException)
    {
        // Another request reserved inventory
        await transaction.RollbackAsync();
        return false;
    }
}
```

**Solution 2: Database-Level Lock**
```sql
-- Use SELECT FOR UPDATE to lock row
SELECT * FROM inventory_stocks 
WHERE product_variant_id = @id 
FOR UPDATE;

-- Then update
UPDATE inventory_stocks 
SET reserved_quantity = reserved_quantity + @quantity,
    available_quantity = available_quantity - @quantity
WHERE product_variant_id = @id 
  AND available_quantity >= @quantity;
```

**Solution 3: Atomic Update**
```csharp
// Single atomic operation
var rowsAffected = await _db.Database.ExecuteSqlRawAsync(@"
    UPDATE inventory_stocks
    SET reserved_quantity = reserved_quantity + {0},
        available_quantity = available_quantity - {0}
    WHERE product_variant_id = {1}
      AND available_quantity >= {0}
", quantity, productVariantId);

return rowsAffected > 0;
```

**Tradeoffs**:
- **Optimistic Locking**: Better for low contention, may retry
- **Pessimistic Locking**: Better for high contention, holds lock
- **Atomic Update**: Simplest, database handles concurrency

**BrandOS Implementation**: Use optimistic locking with RowVersion for concurrency tokens.

---

### Problem 2: Deadlock in Order Processing

**Scenario**:
"BrandOS processes orders and updates inventory. Sometimes deadlocks occur when processing multiple orders concurrently."

**Current Code**:
```csharp
// Transaction 1: Order A, then Inventory
BEGIN;
UPDATE orders SET status = 'Processing' WHERE id = 1;
UPDATE inventory_stocks SET quantity = quantity - 10 WHERE product_id = 100;
COMMIT;

// Transaction 2: Inventory, then Order B (different order)
BEGIN;
UPDATE inventory_stocks SET quantity = quantity - 5 WHERE product_id = 100;
UPDATE orders SET status = 'Processing' WHERE id = 2;
COMMIT;

// Deadlock! Different lock order
```

**Solution: Consistent Lock Ordering**
```csharp
// Always lock in same order (by ID)
public async Task ProcessOrderAsync(int orderId, int productId)
{
    var lockOrder = new[] { orderId, productId }.OrderBy(id => id);
    
    using var transaction = await _db.BeginTransactionAsync();
    try
    {
        foreach (var id in lockOrder)
        {
            if (id == orderId)
            {
                await LockOrderAsync(orderId);
            }
            else
            {
                await LockInventoryAsync(productId);
            }
        }
        
        // Process order
        await ProcessOrderInternalAsync(orderId, productId);
        
        await transaction.CommitAsync();
    }
    catch (Exception)
    {
        await transaction.RollbackAsync();
        throw;
    }
}
```

**Alternative: Reduce Lock Scope**
```csharp
// Process inventory first (smaller scope), then order
public async Task ProcessOrderAsync(int orderId, int productId)
{
    // Reserve inventory (short transaction)
    var reserved = await ReserveInventoryAsync(productId, quantity);
    if (!reserved) throw new OutOfStockException();
    
    try
    {
        // Create order (separate transaction)
        var order = await CreateOrderAsync(orderId, productId);
        return order;
    }
    catch (Exception)
    {
        // Compensating action: Release reservation
        await ReleaseInventoryAsync(productId, quantity);
        throw;
    }
}
```

**BrandOS Implementation**: Use consistent lock ordering or saga pattern for distributed operations.

---

## Performance Tuning

### Problem 3: Slow API Endpoint

**Scenario**:
"BrandOS GetOrders endpoint takes 5 seconds to load. Users are complaining."

**Current Code**:
```csharp
public async Task<List<Order>> GetOrdersAsync(int tenantId)
{
    var orders = await _db.Orders
        .Where(o => o.TenantId == tenantId)
        .ToListAsync();
    
    foreach (var order in orders)
    {
        order.Items = await _db.OrderItems
            .Where(i => i.OrderId == order.Id)
            .ToListAsync();
        order.Customer = await _db.Customers
            .FindAsync(order.CustomerId);
    }
    
    return orders;
}
```

**Problems**:
1. N+1 queries (1 for orders + N for items + N for customers)
2. No pagination (loads all orders)
3. Missing index (may not have index on tenant_id)
4. SELECT * (fetches unnecessary columns)

**Solution**:
```csharp
public async Task<PagedResult<OrderDto>> GetOrdersAsync(
    int tenantId, 
    int page, 
    int pageSize)
{
    // 1. Add pagination
    var total = await _db.Orders
        .Where(o => o.TenantId == tenantId)
        .CountAsync();
    
    // 2. Eager load related data (single query with JOINs)
    var orders = await _db.Orders
        .Include(o => o.Items) // Eager load items
        .Include(o => o.Customer) // Eager load customer
        .Where(o => o.TenantId == tenantId)
        .OrderByDescending(o => o.CreatedAt)
        .Skip((page - 1) * pageSize)
        .Take(pageSize)
        .Select(o => new OrderDto // Project to DTO (only needed columns)
        {
            Id = o.Id,
            TotalAmount = o.TotalAmount,
            Status = o.Status,
            Items = o.Items.Select(i => new OrderItemDto
            {
                Id = i.Id,
                Quantity = i.Quantity
            }).ToList(),
            CustomerName = o.Customer.Name
        })
        .ToListAsync();
    
    return new PagedResult<OrderDto>(orders, total, page, pageSize);
}

// 3. Add index
CREATE INDEX idx_orders_tenant_created ON orders (tenant_id, created_at DESC);
```

**Performance Improvement**:
- **Before**: 5 seconds (N+1 queries, no pagination)
- **After**: 50ms (single query with JOINs, pagination)
- **Improvement**: 100x faster

**BrandOS Implementation**: Use Include() for eager loading, pagination for all list endpoints.

---

### Problem 4: Memory Leak in Background Job

**Scenario**:
"BrandOS OutboxProcessorJob memory usage grows over time, eventually causing OutOfMemoryException."

**Current Code**:
```csharp
public class OutboxProcessorJob : BackgroundService
{
    private readonly List<OutboxMessage> _processedMessages = new();
    
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var messages = await _outboxRepository.GetUnprocessedMessagesAsync(100);
            
            foreach (var message in messages)
            {
                await ProcessMessageAsync(message);
                _processedMessages.Add(message); // Memory leak!
            }
            
            await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
        }
    }
}
```

**Problem**: `_processedMessages` list grows indefinitely, never cleared.

**Solution**:
```csharp
public class OutboxProcessorJob : BackgroundService
{
    // Remove the list - no need to store processed messages
    // Process and forget
    
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            using var scope = _serviceProvider.CreateScope();
            var outboxRepository = scope.ServiceProvider.GetRequiredService<IOutboxRepository>();
            
            var messages = await outboxRepository.GetUnprocessedMessagesAsync(100);
            
            foreach (var message in messages)
            {
                try
                {
                    await ProcessMessageAsync(message, scope);
                    await outboxRepository.MarkAsProcessedAsync(message.Id);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error processing message {MessageId}", message.Id);
                    await outboxRepository.MarkAsFailedAsync(message.Id, ex.Message);
                }
            }
            
            await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
        }
    }
}
```

**Additional Fixes**:
- Use `using var scope` to dispose services
- Don't store processed messages
- Process in batches, dispose after each batch

**BrandOS Implementation**: Background jobs use scoped services, don't store state.

---

## Memory Optimization

### Problem 5: High Memory Allocation in Hot Path

**Scenario**:
"BrandOS GetPermissions endpoint is called millions of times per day. High memory allocation causes GC pressure."

**Current Code**:
```csharp
public async Task<Permissions> GetPermissionsAsync(int userId)
{
    var cacheKey = $"permissions:user:{userId}"; // String allocation
    var cached = await _cache.GetAsync<Permissions>(cacheKey);
    if (cached != null) return cached;
    
    var permissions = await _db.Permissions
        .Where(p => p.UserId == userId)
        .ToListAsync(); // List allocation
    
    await _cache.SetAsync(cacheKey, permissions);
    return permissions;
}
```

**Optimizations**:

**1. Use ValueTask for Synchronous Paths**:
```csharp
public async ValueTask<Permissions> GetPermissionsAsync(int userId)
{
    var cacheKey = $"permissions:user:{userId}";
    var cached = await _cache.GetAsync<Permissions>(cacheKey);
    if (cached != null)
        return cached; // No allocation if synchronous
    
    // Allocation only if async path
    var permissions = await _db.Permissions
        .Where(p => p.UserId == userId)
        .ToListAsync();
    
    await _cache.SetAsync(cacheKey, permissions);
    return permissions;
}
```

**2. Use IAsyncEnumerable for Large Results**:
```csharp
public async IAsyncEnumerable<Permission> GetPermissionsAsync(int userId)
{
    await foreach (var permission in _db.Permissions
        .Where(p => p.UserId == userId)
        .AsAsyncEnumerable())
    {
        yield return permission; // No intermediate list allocation
    }
}
```

**3. Object Pooling for Temporary Objects**:
```csharp
// Use ArrayPool for temporary buffers
var buffer = ArrayPool<byte>.Shared.Rent(1024);
try
{
    // Use buffer
    ProcessBuffer(data, buffer);
}
finally
{
    ArrayPool<byte>.Shared.Return(buffer);
}
```

**BrandOS Implementation**: Use ValueTask for cache lookups, IAsyncEnumerable for large results.

---

## Debugging Production Issues

### Problem 6: Intermittent Timeouts

**Scenario**:
"BrandOS API intermittently times out. Some requests succeed, others fail. No clear pattern."

**Diagnosis Process**:

**1. Check Logs**:
```csharp
// Look for patterns in logs
- Time of day (peak hours?)
- Specific endpoints (certain endpoints?)
- Tenant-specific (certain tenants?)
- Error messages (database timeouts? external service timeouts?)
```

**2. Check Metrics**:
```csharp
// Check monitoring
- Database connection pool usage (exhausted?)
- Response time percentiles (p95, p99)
- Error rate (spikes?)
- External service latency
```

**3. Check Database**:
```sql
-- Check active queries
SELECT pid, query, state, wait_event_type, wait_event
FROM pg_stat_activity
WHERE state != 'idle';

-- Check locks
SELECT * FROM pg_locks WHERE NOT granted;

-- Check slow queries
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

**4. Common Causes**:
- **Connection Pool Exhaustion**: Too many connections
- **Long-Running Queries**: Blocking other queries
- **Lock Contention**: Deadlocks, long transactions
- **External Service Slowdown**: Third-party API slow
- **Cache Stampede**: Multiple requests miss cache simultaneously

**Solution**:
```csharp
// 1. Add timeouts
var timeoutPolicy = Policy.TimeoutAsync(TimeSpan.FromSeconds(30));

// 2. Add circuit breakers
var circuitBreaker = Policy
    .Handle<TimeoutException>()
    .CircuitBreakerAsync(5, TimeSpan.FromSeconds(30));

// 3. Add retries with backoff
var retryPolicy = Policy
    .Handle<TimeoutException>()
    .WaitAndRetryAsync(3, retryAttempt => 
        TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)));

// 4. Monitor connection pool
_logger.LogInformation("Connection pool: {Used}/{Total}", 
    _db.Database.GetConnection().State, 
    _db.Database.GetConnection().ConnectionString);
```

**BrandOS Implementation**: Use SlowQueryInterceptor, health checks, monitoring.

---

## Designing Efficient APIs

### Problem 7: Inefficient Bulk Operations

**Scenario**:
"BrandOS needs to update 10,000 orders. Current implementation makes 10,000 individual API calls, taking 5 minutes."

**Current Code**:
```csharp
// Client makes 10,000 individual calls
for (int i = 0; i < 10000; i++)
{
    await httpClient.PutAsync($"/api/orders/{orderIds[i]}", content);
}
```

**Solution 1: Batch Endpoint**
```csharp
[HttpPost("api/orders/batch")]
public async Task<IActionResult> UpdateOrdersBatch([FromBody] List<UpdateOrderDto> orders)
{
    // Process in batches (100 at a time)
    const int batchSize = 100;
    for (int i = 0; i < orders.Count; i += batchSize)
    {
        var batch = orders.Skip(i).Take(batchSize);
        await _db.Orders.BulkUpdateAsync(batch);
    }
    
    return Ok();
}

// Client makes 1 call with 10,000 orders
await httpClient.PostAsync("/api/orders/batch", batchContent);
```

**Solution 2: Bulk Update SQL**
```csharp
// Use bulk update SQL
await _db.Database.ExecuteSqlRawAsync(@"
    UPDATE orders
    SET status = CASE id
        WHEN 1 THEN 'Shipped'
        WHEN 2 THEN 'Shipped'
        ...
    END
    WHERE id IN (1, 2, ...)
");
```

**Solution 3: Background Job**
```csharp
// Queue bulk operation as background job
await _backgroundJobClient.EnqueueAsync(() => 
    UpdateOrdersBulkAsync(orderIds, updates));

// Process in background
public async Task UpdateOrdersBulkAsync(List<int> orderIds, Dictionary<int, string> updates)
{
    // Process in batches
    const int batchSize = 1000;
    for (int i = 0; i < orderIds.Count; i += batchSize)
    {
        var batch = orderIds.Skip(i).Take(batchSize);
        await ProcessBatchAsync(batch, updates);
    }
}
```

**Performance Improvement**:
- **Before**: 5 minutes (10,000 individual calls)
- **After**: 10 seconds (1 batch call)
- **Improvement**: 30x faster

**BrandOS Implementation**: Use batch endpoints for bulk operations.

---

## Data Structure Tradeoffs

### Problem 8: Choosing Data Structure for Cache

**Scenario**:
"BrandOS needs to cache user permissions. Should we use Dictionary, ConcurrentDictionary, or Redis?"

**Analysis**:

**Option 1: Dictionary** (In-Memory)
```csharp
private readonly Dictionary<int, Permissions> _cache = new();
```
- ✅ Fast (O(1) lookup)
- ❌ Not thread-safe
- ❌ Not shared across instances
- ❌ Lost on restart

**Option 2: ConcurrentDictionary** (In-Memory, Thread-Safe)
```csharp
private readonly ConcurrentDictionary<int, Permissions> _cache = new();
```
- ✅ Fast (O(1) lookup)
- ✅ Thread-safe
- ❌ Not shared across instances
- ❌ Lost on restart

**Option 3: Redis** (Distributed)
```csharp
await _redis.SetAsync($"permissions:{userId}", permissions);
```
- ✅ Shared across instances
- ✅ Persists across restarts
- ✅ TTL support
- ⚠️ Network latency (~1ms)
- ⚠️ Additional infrastructure

**Decision Matrix**:

| Factor | Dictionary | ConcurrentDictionary | Redis |
|--------|-----------|---------------------|-------|
| **Speed** | Fastest | Fast | Fast (with network) |
| **Thread-Safe** | ❌ | ✅ | ✅ |
| **Shared** | ❌ | ❌ | ✅ |
| **Persistence** | ❌ | ❌ | ✅ |
| **Complexity** | Low | Low | Medium |

**BrandOS Choice**: Redis (shared across instances, TTL support, persistence)

**When to Use Each**:
- **Dictionary**: Single-instance, read-only, no concurrency
- **ConcurrentDictionary**: Single-instance, concurrent reads
- **Redis**: Multiple instances, shared cache, TTL needed

---

## Scaling Slow Services

### Problem 9: Scaling Background Job Processing

**Scenario**:
"BrandOS OutboxProcessorJob processes 100 messages every 5 seconds. At 10x scale, it can't keep up (1,000 messages/second needed)."

**Current Implementation**:
```csharp
public class OutboxProcessorJob : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var messages = await _outboxRepository.GetUnprocessedMessagesAsync(100);
            foreach (var message in messages)
            {
                await ProcessMessageAsync(message);
            }
            await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
        }
    }
}
```

**Scaling Strategies**:

**1. Increase Batch Size**:
```csharp
// Process 1000 messages per batch (instead of 100)
var messages = await _outboxRepository.GetUnprocessedMessagesAsync(1000);
```

**2. Reduce Delay**:
```csharp
// Process every 1 second (instead of 5)
await Task.Delay(TimeSpan.FromSeconds(1), stoppingToken);
```

**3. Multiple Workers** (Leader Election):
```csharp
public class OutboxProcessorJob : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            // Only leader processes messages
            var isLeader = await _distributedLock.TryAcquireAsync("outbox-processor");
            if (isLeader)
            {
                await ProcessOutboxAsync(stoppingToken);
                await _distributedLock.RenewAsync("outbox-processor");
            }
            else
            {
                await Task.Delay(TimeSpan.FromSeconds(10), stoppingToken);
            }
        }
    }
}
```

**4. Partition Processing**:
```csharp
// Partition by tenant_id, each worker processes different partition
var partition = _workerId % _totalWorkers;
var messages = await _outboxRepository.GetUnprocessedMessagesAsync(
    100, 
    partition, 
    _totalWorkers);
```

**5. Parallel Processing**:
```csharp
// Process messages in parallel (with concurrency limit)
var semaphore = new SemaphoreSlim(10); // Max 10 concurrent
var tasks = messages.Select(async message =>
{
    await semaphore.WaitAsync();
    try
    {
        await ProcessMessageAsync(message);
    }
    finally
    {
        semaphore.Release();
    }
});
await Task.WhenAll(tasks);
```

**Performance Improvement**:
- **Before**: 100 messages/5s = 20 messages/sec
- **After**: 1000 messages/1s = 1000 messages/sec (with multiple workers)
- **Improvement**: 50x faster

**BrandOS Implementation**: Use leader election or partition processing for scaling.

---

## Refactoring Complex Backend

### Problem 10: Monolithic Service Needs Refactoring

**Scenario**:
"BrandOS OrderService has 2,000 lines of code, handles orders, payments, inventory, and notifications. It's hard to test and maintain."

**Current Code**:
```csharp
public class OrderService
{
    public async Task<Order> CreateOrderAsync(OrderDto dto)
    {
        // 500 lines of code
        // Handles: validation, inventory, payment, notification, logging
    }
}
```

**Refactoring Strategy**:

**1. Extract Handlers** (Command Pattern):
```csharp
// Separate handlers for each operation
public interface ICreateOrderHandler
{
    Task<Result<Order>> HandleAsync(CreateOrderDto dto);
}

public class CreateOrderHandler : ICreateOrderHandler
{
    private readonly IInventoryService _inventory;
    private readonly IPaymentService _payment;
    private readonly INotificationService _notification;
    
    public async Task<Result<Order>> HandleAsync(CreateOrderDto dto)
    {
        // Validate
        var validationResult = await ValidateAsync(dto);
        if (!validationResult.IsSuccess) return Result.Failure(validationResult.Error);
        
        // Reserve inventory
        var inventoryResult = await _inventory.ReserveAsync(dto.Items);
        if (!inventoryResult.IsSuccess) return Result.Failure("Out of stock");
        
        // Process payment
        var paymentResult = await _payment.ProcessAsync(dto.PaymentMethod, dto.TotalAmount);
        if (!paymentResult.IsSuccess) return Result.Failure("Payment failed");
        
        // Create order
        var order = new Order(dto.CustomerId, dto.Items);
        await _repository.AddAsync(order);
        
        // Send notification (async, don't fail if it fails)
        _ = Task.Run(() => _notification.SendOrderConfirmationAsync(order));
        
        return Result.Success(order);
    }
}
```

**2. Extract Services**:
```csharp
// Separate services for each concern
public interface IInventoryService
{
    Task<Result> ReserveAsync(List<OrderItem> items);
}

public interface IPaymentService
{
    Task<Result<Payment>> ProcessAsync(PaymentMethod method, decimal amount);
}

public interface INotificationService
{
    Task SendOrderConfirmationAsync(Order order);
}
```

**3. Use Domain Events**:
```csharp
// Order raises domain event, handlers process it
public class Order : AggregateRoot
{
    public void Confirm()
    {
        Status = OrderStatus.Confirmed;
        AddDomainEvent(new OrderConfirmedEvent(this));
    }
}

// Separate handler for notifications
public class OrderConfirmedEventHandler
{
    public async Task HandleAsync(OrderConfirmedEvent evt)
    {
        await _notificationService.SendOrderConfirmationAsync(evt.Order);
    }
}
```

**Benefits**:
- ✅ Single Responsibility (each class has one job)
- ✅ Testable (can test each handler independently)
- ✅ Maintainable (changes isolated to one handler)
- ✅ Reusable (services can be used by other handlers)

**BrandOS Implementation**: Use handler pattern, domain events, separate services.

---

## Conclusion

### Key Takeaways

1. **Concurrency**: Use locks, transactions, atomic operations
2. **Performance**: Optimize queries, use caching, pagination
3. **Memory**: Reduce allocations, use pooling, streaming
4. **Debugging**: Systematic diagnosis, use monitoring
5. **APIs**: Design for efficiency, use batching
6. **Data Structures**: Choose based on requirements
7. **Scaling**: Horizontal scaling, partitioning, parallel processing
8. **Refactoring**: Extract handlers, services, use events

### Practice Problems

1. Design a thread-safe cache
2. Optimize a slow database query
3. Debug a memory leak
4. Design an efficient bulk API
5. Refactor a monolithic service

---

**Remember**: Problem-solving is about systematic thinking, not memorizing solutions. Understand the problem, analyze options, choose the best solution, and explain your reasoning.



