# Distributed Systems Deep Dive
## Principal Engineer Interview Preparation - BrandOS Edition

> **Target**: Staff/Principal Backend Engineer interviews  
> **Focus**: CAP theorem, consistency, fault tolerance, distributed patterns  
> **Format**: Deep technical questions with BrandOS examples

---

## Table of Contents

1. [CAP Theorem](#cap-theorem)
2. [Consistency Models](#consistency-models)
3. [Eventual Consistency](#eventual-consistency)
4. [Idempotency](#idempotency)
5. [Retries & Backoff](#retries--backoff)
6. [Circuit Breakers](#circuit-breakers)
7. [Saga Pattern](#saga-pattern)
8. [Distributed Transactions](#distributed-transactions)
9. [Message Ordering](#message-ordering)
10. [Exactly-Once vs At-Least-Once](#exactly-once-vs-at-least-once)
11. [Fault Tolerance](#fault-tolerance)
12. [Network Failures](#network-failures)
13. [Split Brain](#split-brain)
14. [Leader Election](#leader-election)
15. [Designing Resilient Systems](#designing-resilient-systems)

---

## CAP Theorem

### Question 1: Explain CAP theorem in the context of BrandOS

**Interview Stage**: Distributed Systems (90% probability)  
**Difficulty**: Principal  
**Why Asked**: Fundamental understanding of distributed systems

#### Strong Answer

**CAP Theorem**: In a distributed system, you can only guarantee 2 of 3:
- **Consistency**: All nodes see the same data
- **Availability**: System remains operational
- **Partition Tolerance**: System works despite network failures

**BrandOS Strategy**:

**CP (Consistency + Partition Tolerance)**:
- **Financial Data**: Wallets, payments, settlements
- **Inventory**: Stock levels (prevent overselling)
- **Tradeoff**: May be unavailable during network partition

```csharp
// Strong consistency for financial operations
public async Task<Result> ProcessPaymentAsync(PaymentRequest request)
{
    using var transaction = await _db.BeginTransactionAsync(
        IsolationLevel.RepeatableRead);
    
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
    catch (DbUpdateConcurrencyException)
    {
        await transaction.RollbackAsync();
        // Fail rather than return inconsistent data (CP)
        throw;
    }
}
```

**AP (Availability + Partition Tolerance)**:
- **Caching**: Permissions, feature flags
- **Analytics**: Sales metrics, reports
- **Tradeoff**: May return stale data

```csharp
// Eventual consistency for caching
public async Task<Permissions> GetPermissionsAsync(int userId)
{
    // Try cache first (may be stale, but available)
    var cached = await _cache.GetAsync<Permissions>($"permissions:{userId}");
    if (cached != null) return cached;
    
    // Fallback to database (still available)
    return await _db.Permissions
        .Where(p => p.UserId == userId)
        .ToListAsync();
}
```

**CA (Consistency + Availability)**:
- **Not possible in distributed systems**: Network partitions always occur
- **Single-node systems**: Can have CA, but not distributed

#### Follow-up Questions

**Q: How do you handle network partitions?**
```csharp
// Detect partition: Health checks fail
// Strategy: Fail closed (CP) or fail open (AP)

// CP: Reject requests during partition
if (!_db.Database.CanConnect())
{
    throw new ServiceUnavailableException("Database unavailable");
}

// AP: Return cached/stale data
if (!_db.Database.CanConnect())
{
    return await _cache.GetAsync<Data>(key) ?? GetDefaultData();
}
```

#### Weak Answer Example

❌ "We use CP for everything. Consistency is always most important."

**Why Weak**: Doesn't understand tradeoffs, when AP is acceptable.

#### FAANG Evaluation

**Strong Candidate**:
- Understands CAP theorem
- Knows when to use CP vs AP
- Makes explicit tradeoffs
- Designs for partition tolerance

**Weak Candidate**:
- Doesn't understand CAP theorem
- No tradeoff analysis
- Doesn't consider partitions

---

## Consistency Models

### Question 2: Explain different consistency models

**Interview Stage**: Distributed Systems (70% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for understanding data guarantees

#### Strong Answer

**Consistency Models** (from strongest to weakest):

1. **Strong Consistency**: All reads see latest write
2. **Sequential Consistency**: Operations appear in some sequential order
3. **Causal Consistency**: Causally related operations appear in order
4. **Eventual Consistency**: Eventually all nodes see same data

**BrandOS Examples**:

**Strong Consistency** (Financial Data):
```csharp
// Read-after-write: Always see latest data
public async Task<Wallet> GetWalletAsync(int walletId)
{
    // Read from primary (not replica) for strong consistency
    return await _writeDb.Wallets.FindAsync(walletId);
}
```

**Eventual Consistency** (Analytics):
```csharp
// Analytics may be slightly behind (acceptable)
public async Task<SalesMetrics> GetSalesMetricsAsync(int tenantId, DateOnly date)
{
    // Snapshot updated hourly (eventual consistency)
    var snapshot = await _db.SalesDailySnapshots
        .FirstOrDefaultAsync(s => s.TenantId == tenantId && s.Date == date);
    
    return snapshot?.Metrics ?? new SalesMetrics();
}
```

**Read-Your-Writes Consistency**:
```csharp
// User always sees their own writes
public async Task<Order> CreateOrderAsync(Order order)
{
    // Write to primary
    await _writeDb.Orders.AddAsync(order);
    await _writeDb.SaveChangesAsync();
    
    // Read from primary (not replica) to see own write
    return await _writeDb.Orders.FindAsync(order.Id);
}
```

#### Follow-up Questions

**Q: How do you implement read-your-writes consistency?**
```csharp
// Track user's last write timestamp
// Route reads to primary if within time window

public async Task<Order> GetOrderAsync(int orderId, int userId)
{
    var lastWrite = await _cache.GetAsync<DateTime>($"lastwrite:{userId}");
    if (lastWrite.HasValue && DateTime.UtcNow - lastWrite.Value < TimeSpan.FromSeconds(5))
    {
        // Read from primary (within 5 seconds of write)
        return await _writeDb.Orders.FindAsync(orderId);
    }
    
    // Read from replica (eventual consistency acceptable)
    return await _readDb.Orders.FindAsync(orderId);
}
```

---

## Eventual Consistency

### Question 3: How do you handle eventual consistency in BrandOS?

**Interview Stage**: Distributed Systems (60% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for distributed systems

#### Strong Answer

**Eventual Consistency**: System will eventually become consistent, but not immediately.

**BrandOS Examples**:

**1. Outbox Pattern** (Eventual Delivery):
```csharp
// Events saved to outbox (same transaction as business data)
public async Task DispatchAsync(IDomainEvent domainEvent)
{
    var outboxMessage = new OutboxMessage
    {
        Type = domainEvent.GetType().Name,
        Content = JsonSerializer.Serialize(domainEvent),
        OccurredOn = domainEvent.OccurredOn
    };
    
    await _outboxRepository.AddAsync(outboxMessage);
    await _context.SaveChangesAsync(); // Atomic with business data
    
    // Background job processes outbox (eventual delivery)
    // Events delivered eventually, not immediately
}
```

**2. Read Replicas** (Eventual Consistency):
```csharp
// Writes to primary, reads from replica (may be slightly behind)
public async Task<Order> CreateOrderAsync(Order order)
{
    // Write to primary
    await _writeDb.Orders.AddAsync(order);
    await _writeDb.SaveChangesAsync();
    
    // Replica will eventually have this data (replication lag: 10-100ms)
    // Subsequent reads from replica may not see this immediately
}
```

**3. Cache Invalidation** (Eventual Consistency):
```csharp
// Cache may be stale until TTL expires or invalidation
public async Task UpdatePermissionsAsync(int userId, Permissions permissions)
{
    await _db.Permissions.UpdateAsync(permissions);
    await _db.SaveChangesAsync();
    
    // Invalidate cache (eventual: may take time to propagate)
    await _cache.RemoveAsync($"permissions:{userId}");
    
    // Cache in other regions may still be stale (eventual consistency)
}
```

**Handling Stale Data**:
```csharp
// Accept stale data for non-critical operations
public async Task<SalesMetrics> GetSalesMetricsAsync(int tenantId)
{
    // Stale data acceptable (updated hourly)
    var cached = await _cache.GetAsync<SalesMetrics>($"metrics:{tenantId}");
    if (cached != null) return cached;
    
    // Fetch from database (may also be slightly stale)
    return await _db.SalesDailySnapshots
        .OrderByDescending(s => s.Date)
        .FirstOrDefaultAsync()?.Metrics ?? new SalesMetrics();
}
```

#### Follow-up Questions

**Q: How do you detect and handle stale data?**
```csharp
// Add version/timestamp to detect staleness
public class CachedData
{
    public object Data { get; set; }
    public DateTime CachedAt { get; set; }
    public int Version { get; set; }
}

// Check staleness
var cached = await _cache.GetAsync<CachedData>(key);
if (cached != null && DateTime.UtcNow - cached.CachedAt < TimeSpan.FromMinutes(5))
{
    return cached.Data; // Fresh enough
}

// Refresh if stale
var fresh = await FetchFreshDataAsync();
await _cache.SetAsync(key, new CachedData { Data = fresh, CachedAt = DateTime.UtcNow });
return fresh;
```

---

## Idempotency

### Question 4: How do you ensure idempotency in BrandOS?

**Interview Stage**: Distributed Systems (80% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for retry-safe operations

#### Strong Answer

**Idempotency**: Same operation can be safely retried without side effects.

**BrandOS Idempotency Implementation**:

**1. Idempotency Key**:
```csharp
// Client provides unique key per operation
public async Task<Order> CreateOrderAsync(CreateOrderDto dto, string idempotencyKey)
{
    // Check if already processed
    var existing = await _idempotencyService.GetResponseAsync(idempotencyKey);
    if (existing != null)
    {
        // Return same result (idempotent)
        return JsonSerializer.Deserialize<Order>(existing);
    }
    
    // Process order
    var order = await ProcessOrderAsync(dto);
    
    // Store result
    await _idempotencyService.MarkAsProcessedAsync(
        idempotencyKey, 
        JsonSerializer.Serialize(order)
    );
    
    return order;
}
```

**2. Database-Level Idempotency**:
```csharp
// Use unique constraint to prevent duplicates
public class Payment
{
    public int Id { get; set; }
    public string IdempotencyKey { get; set; } // Unique constraint
    public decimal Amount { get; set; }
}

// Database enforces uniqueness
CREATE UNIQUE INDEX idx_payments_idempotency_key ON payments (idempotency_key);

// Insert will fail if duplicate (idempotent)
try
{
    await _db.Payments.AddAsync(payment);
    await _db.SaveChangesAsync();
}
catch (DbUpdateException ex) when (ex.IsUniqueConstraintViolation())
{
    // Already processed, fetch existing
    return await _db.Payments
        .FirstOrDefaultAsync(p => p.IdempotencyKey == idempotencyKey);
}
```

**3. Idempotency Middleware**:
```csharp
// BrandOS: IdempotencyMiddleware
public class IdempotencyMiddleware
{
    public async Task InvokeAsync(HttpContext context)
    {
        var idempotencyKey = context.Request.Headers["Idempotency-Key"].FirstOrDefault();
        if (string.IsNullOrEmpty(idempotencyKey)) 
        {
            await _next(context);
            return;
        }
        
        // Check if already processed
        var cached = await _idempotencyService.GetResponseAsync(idempotencyKey);
        if (cached != null)
        {
            // Return cached response
            context.Response.StatusCode = 200;
            await context.Response.WriteAsync(cached);
            return;
        }
        
        // Process request
        await _next(context);
        
        // Store response
        var response = await GetResponseAsync(context);
        await _idempotencyService.MarkAsProcessedAsync(idempotencyKey, response);
    }
}
```

#### Follow-up Questions

**Q: How long should you store idempotency keys?**
```csharp
// Store for reasonable time (24 hours for payments, 1 hour for other operations)
await _cache.SetAsync(
    $"idempotency:{key}",
    response,
    TimeSpan.FromHours(24) // Payments: 24 hours
);
```

**Q: What if idempotency key is reused for different operations?**
```csharp
// Include operation type in key
var key = $"idempotency:{operationType}:{idempotencyKey}";

// Prevents reuse across different operations
```

---

## Retries & Backoff

### Question 5: Design retry strategy for BrandOS

**Interview Stage**: Resilience (70% probability)  
**Difficulty**: Staff  
**Why Asked**: Critical for handling transient failures

#### Strong Answer

**Retry Strategy**:
1. **Exponential Backoff**: Increase delay between retries
2. **Jitter**: Add randomness to prevent thundering herd
3. **Max Retries**: Limit retry attempts
4. **Retryable Errors**: Only retry transient failures

**BrandOS Retry Implementation**:
```csharp
// ResiliencePolicyFactory.cs
public static IAsyncPolicy GetHttpRetryPolicy(ILogger logger)
{
    return HttpPolicyExtensions
        .HandleTransientHttpError() // 5xx, 408, 429
        .OrResult(msg => msg.StatusCode == HttpStatusCode.TooManyRequests)
        .WaitAndRetryAsync(
            retryCount: 3,
            sleepDurationProvider: retryAttempt => 
            {
                // Exponential backoff: 2^retryAttempt seconds
                var delay = TimeSpan.FromSeconds(Math.Pow(2, retryAttempt));
                
                // Add jitter (±20%)
                var jitter = TimeSpan.FromMilliseconds(
                    Random.Shared.Next(-(int)(delay.TotalMilliseconds * 0.2), 
                                      (int)(delay.TotalMilliseconds * 0.2)));
                
                return delay + jitter;
            },
            onRetry: (outcome, timespan, retryCount, context) =>
            {
                logger.LogWarning(
                    "Retry {RetryCount} after {Delay}ms",
                    retryCount, timespan.TotalMilliseconds);
            });
}
```

**Retryable vs Non-Retryable Errors**:
```csharp
// Retryable: Transient failures
- Network timeouts
- 5xx server errors
- 429 Too Many Requests
- Database connection failures

// Non-Retryable: Permanent failures
- 400 Bad Request (client error)
- 401 Unauthorized (auth error)
- 404 Not Found (resource doesn't exist)
- 422 Unprocessable Entity (validation error)
```

**BrandOS Database Retry**:
```csharp
public static IAsyncPolicy GetDatabaseRetryPolicy(ILogger logger)
{
    return Policy
        .Handle<NpgsqlException>(ex => ex.IsTransient) // Transient errors only
        .Or<DbUpdateException>(ex => ex.IsTransient)
        .WaitAndRetryAsync(
            retryCount: 3,
            sleepDurationProvider: retryAttempt => 
                TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)),
            onRetry: (exception, timespan, retryCount, context) =>
            {
                logger.LogWarning(
                    exception,
                    "Database retry {RetryCount} after {Delay}ms",
                    retryCount, timespan.TotalMilliseconds);
            });
}
```

#### Follow-up Questions

**Q: How do you prevent retry storms?**
```csharp
// Use circuit breaker (see next section)
// Or limit retries per time window

private readonly Dictionary<string, int> _retryCounts = new();
private readonly TimeSpan _window = TimeSpan.FromMinutes(1);

public bool ShouldRetry(string key)
{
    var count = _retryCounts.GetValueOrDefault(key, 0);
    if (count > 10) // Max 10 retries per minute
    {
        return false;
    }
    
    _retryCounts[key] = count + 1;
    return true;
}
```

---

## Circuit Breakers

### Question 6: Explain circuit breaker pattern in BrandOS

**Interview Stage**: Resilience (60% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for preventing cascading failures

#### Strong Answer

**Circuit Breaker**: Prevents calls to failing service, allows recovery.

**States**:
1. **Closed**: Normal operation
2. **Open**: Failing, reject requests immediately
3. **Half-Open**: Testing if service recovered

**BrandOS Circuit Breaker**:
```csharp
// ResiliencePolicyFactory.cs
public static IAsyncPolicy<HttpResponseMessage> GetCircuitBreakerPolicy(ILogger logger)
{
    return HttpPolicyExtensions
        .HandleTransientHttpError()
        .CircuitBreakerAsync(
            handledEventsAllowedBeforeBreaking: 5, // Open after 5 failures
            durationOfBreak: TimeSpan.FromSeconds(30), // Stay open for 30s
            onBreak: (result, duration) =>
            {
                logger.LogWarning(
                    "Circuit breaker opened for {Duration}s",
                    duration.TotalSeconds);
            },
            onReset: () =>
            {
                logger.LogInformation("Circuit breaker reset");
            },
            onHalfOpen: () =>
            {
                logger.LogInformation("Circuit breaker half-open (testing)");
            });
}
```

**Usage**:
```csharp
// Wrap external service calls
var httpClient = _httpClientFactory.CreateClient("default");
// HttpClient configured with circuit breaker policy

try
{
    var response = await httpClient.GetAsync("https://external-api.com/data");
    return await response.Content.ReadAsStringAsync();
}
catch (BrokenCircuitException)
{
    // Circuit is open, return cached data or default
    return await _cache.GetAsync<string>("fallback-data") ?? GetDefaultData();
}
```

**Benefits**:
- **Prevents Cascading Failures**: Stops calling failing service
- **Fast Failure**: Immediate rejection when circuit is open
- **Automatic Recovery**: Tests service when circuit is half-open

#### Follow-up Questions

**Q: How do you choose circuit breaker parameters?**
```csharp
// handledEventsAllowedBeforeBreaking: Based on error rate
// - Low traffic: 3-5 failures
// - High traffic: 10-20 failures

// durationOfBreak: Based on service recovery time
// - Fast recovery: 10-30 seconds
// - Slow recovery: 1-5 minutes
```

---

## Saga Pattern

### Question 7: Design saga pattern for BrandOS checkout

**Interview Stage**: Distributed Transactions (50% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for distributed transactions

#### Strong Answer

**Saga Pattern**: Distributed transaction using local transactions + compensating actions.

**BrandOS Checkout Saga**:
```csharp
public async Task<Order> CheckoutAsync(CheckoutRequest request)
{
    var sagaId = Guid.NewGuid();
    
    try
    {
        // Step 1: Reserve inventory (local transaction)
        var reservation = await ReserveInventoryAsync(request.Items, sagaId);
        
        try
        {
            // Step 2: Process payment (external service)
            var payment = await _paymentGateway.ChargeAsync(
                request.PaymentMethod, 
                request.TotalAmount,
                sagaId); // Idempotency key
            
            try
            {
                // Step 3: Create order (local transaction)
                var order = await CreateOrderAsync(request, payment.Id, sagaId);
                
                // Step 4: Confirm reservation (no compensation needed)
                await ConfirmReservationAsync(reservation.Id);
                
                return order;
            }
            catch (Exception)
            {
                // Compensate: Refund payment
                await _paymentGateway.RefundAsync(payment.Id);
                throw;
            }
        }
        catch (Exception)
        {
            // Compensate: Release inventory
            await ReleaseReservationAsync(reservation.Id);
            throw;
        }
    }
    catch (Exception)
    {
        // Saga failed, all compensations executed
        throw;
    }
}
```

**Orchestrated Saga** (Centralized):
```csharp
// Saga orchestrator coordinates steps
public class CheckoutSaga
{
    public async Task<Order> ExecuteAsync(CheckoutRequest request)
    {
        var sagaState = new SagaState { Request = request };
        
        // Step 1
        sagaState.Reservation = await ReserveInventoryAsync(request.Items);
        
        // Step 2
        sagaState.Payment = await ProcessPaymentAsync(request);
        
        // Step 3
        sagaState.Order = await CreateOrderAsync(request, sagaState.Payment.Id);
        
        return sagaState.Order;
    }
    
    public async Task CompensateAsync(SagaState state)
    {
        // Execute compensations in reverse order
        if (state.Order != null)
        {
            await CancelOrderAsync(state.Order.Id);
        }
        
        if (state.Payment != null)
        {
            await RefundPaymentAsync(state.Payment.Id);
        }
        
        if (state.Reservation != null)
        {
            await ReleaseReservationAsync(state.Reservation.Id);
        }
    }
}
```

**Choreographed Saga** (Decentralized):
```csharp
// Each service listens to events and acts
// Order service publishes OrderCreatedEvent
// Inventory service listens and releases reservation
// Payment service listens and processes payment

// More complex, but more decoupled
```

---

## Distributed Transactions

### Question 8: How do you handle distributed transactions in BrandOS?

**Interview Stage**: Distributed Systems (40% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for multi-service operations

#### Strong Answer

**Two-Phase Commit (2PC)**: Not recommended (slow, complex, blocks)

**Better: Saga Pattern** (see above)

**Or: Event-Driven** (Outbox Pattern):
```csharp
// BrandOS: Outbox pattern for distributed transactions
public async Task CreateOrderAsync(Order order)
{
    using var transaction = await _db.BeginTransactionAsync();
    try
    {
        // 1. Save order (local transaction)
        await _db.Orders.AddAsync(order);
        
        // 2. Save event to outbox (same transaction)
        var outboxMessage = new OutboxMessage
        {
            Type = "OrderCreated",
            Content = JsonSerializer.Serialize(new OrderCreatedEvent(order))
        };
        await _db.OutboxMessages.AddAsync(outboxMessage);
        
        // 3. Commit (atomic)
        await _db.SaveChangesAsync();
        await transaction.CommitAsync();
        
        // 4. Background job processes outbox (eventual consistency)
        // Events delivered to other services eventually
    }
    catch (Exception)
    {
        await transaction.RollbackAsync();
        throw;
    }
}
```

**Benefits**:
- **No Distributed Lock**: Each service has local transaction
- **Eventual Consistency**: Events delivered eventually
- **Resilient**: Outbox ensures delivery even if service crashes

---

## Message Ordering

### Question 9: How do you ensure message ordering in BrandOS?

**Interview Stage**: Distributed Systems (30% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for event processing

#### Strong Answer

**Message Ordering Strategies**:

**1. Single Partition** (Kafka):
```csharp
// All messages for same tenant go to same partition
var partition = tenantId % numberOfPartitions;
await _kafka.ProduceAsync(topic, partition, message);

// Consumer processes partition sequentially (ordering preserved)
```

**2. Sequence Numbers**:
```csharp
// Add sequence number to messages
public class OrderEvent
{
    public int SequenceNumber { get; set; }
    public int TenantId { get; set; }
    public OrderData Data { get; set; }
}

// Consumer processes in sequence order
var events = await _messageQueue.GetEventsAsync(tenantId);
var ordered = events.OrderBy(e => e.SequenceNumber);
foreach (var event in ordered)
{
    await ProcessEventAsync(event);
}
```

**3. Idempotency + Timestamps**:
```csharp
// Process events idempotently, ignore out-of-order
public async Task ProcessEventAsync(OrderEvent evt)
{
    // Check if already processed (idempotency)
    if (await _processedEvents.ContainsAsync(evt.Id))
    {
        return; // Already processed, skip
    }
    
    // Process event
    await ApplyEventAsync(evt);
    
    // Mark as processed
    await _processedEvents.AddAsync(evt.Id);
}
```

**BrandOS: Per-Tenant Ordering**:
```csharp
// Ordering only needed per tenant, not globally
// Use tenant_id as partition key in Kafka
var partition = tenantId % partitions;
await _kafka.ProduceAsync("orders", partition, event);

// Each partition processed sequentially
// Ordering preserved per tenant
```

---

## Exactly-Once vs At-Least-Once

### Question 10: Explain exactly-once vs at-least-once delivery

**Interview Stage**: Distributed Systems (50% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for understanding message guarantees

#### Strong Answer

**Delivery Guarantees**:

**At-Least-Once**:
- Message delivered at least once
- May be duplicated
- **Solution**: Idempotency

**Exactly-Once**:
- Message delivered exactly once
- No duplicates
- **Challenge**: Very difficult to guarantee (requires coordination)

**BrandOS: At-Least-Once with Idempotency**:
```csharp
// Kafka: At-least-once delivery
// Messages may be redelivered on failure

// Solution: Idempotent processing
public async Task ProcessMessageAsync(OrderEvent evt)
{
    // Check if already processed
    if (await _idempotencyStore.ExistsAsync(evt.Id))
    {
        return; // Already processed, skip (idempotent)
    }
    
    // Process event
    await ApplyEventAsync(evt);
    
    // Mark as processed
    await _idempotencyStore.MarkAsProcessedAsync(evt.Id);
}
```

**Exactly-Once (Kafka)**:
```csharp
// Enable idempotent producer
var producerConfig = new ProducerConfig
{
    EnableIdempotence = true, // Exactly-once semantics
    Acks = Acks.All,
    MaxInFlightRequestsPerConnection = 1
};

// Consumer: Read committed (only committed messages)
var consumerConfig = new ConsumerConfig
{
    IsolationLevel = IsolationLevel.ReadCommitted
};

// Tradeoff: Lower throughput, higher latency
```

**BrandOS Strategy**: At-least-once + idempotency (simpler, good enough)

---

## Fault Tolerance

### Question 11: How do you design fault-tolerant systems?

**Interview Stage**: System Design (80% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for production systems

#### Strong Answer

**Fault Tolerance Principles**:
1. **Assume Failures**: Everything will fail
2. **Fail Fast**: Detect failures quickly
3. **Fail Gracefully**: Degrade functionality, don't crash
4. **Recover Automatically**: Self-healing systems

**BrandOS Fault Tolerance**:

**1. Health Checks**:
```csharp
// Detect failures early
builder.Services.AddHealthChecks()
    .AddNpgSql(connectionString, name: "postgresql")
    .AddRedis(redisConnection, name: "redis")
    .AddRabbitMQ(rabbitMqConnection, name: "rabbitmq");

// Kubernetes: Restart unhealthy pods
// Load balancer: Route away from unhealthy instances
```

**2. Circuit Breakers** (see above)

**3. Retries with Backoff** (see above)

**4. Timeouts**:
```csharp
// Prevent hanging requests
var timeoutPolicy = Policy.TimeoutAsync(TimeSpan.FromSeconds(30));

await timeoutPolicy.ExecuteAsync(async () =>
{
    return await _externalService.CallAsync();
});
```

**5. Graceful Degradation**:
```csharp
// Cache unavailable? Use database
public async Task<Permissions> GetPermissionsAsync(int userId)
{
    try
    {
        var cached = await _cache.GetAsync<Permissions>($"permissions:{userId}");
        if (cached != null) return cached;
    }
    catch (Exception ex)
    {
        _logger.LogWarning(ex, "Cache unavailable, using database");
    }
    
    // Fallback to database
    return await _db.Permissions
        .Where(p => p.UserId == userId)
        .ToListAsync();
}
```

**6. Bulkheads**:
```csharp
// Isolate failures (don't let one service failure affect others)
// Use separate thread pools, connection pools per service

// Example: Separate HttpClient for each external service
builder.Services.AddHttpClient("payment-service")
    .AddPolicyHandler(GetPaymentRetryPolicy());

builder.Services.AddHttpClient("notification-service")
    .AddPolicyHandler(GetNotificationRetryPolicy());
```

---

## Network Failures

### Question 12: How do you handle network failures?

**Interview Stage**: Distributed Systems (60% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for distributed systems

#### Strong Answer

**Network Failure Scenarios**:
1. **Timeout**: Request takes too long
2. **Connection Refused**: Service unavailable
3. **Network Partition**: Services can't communicate
4. **Partial Failure**: Some requests succeed, others fail

**BrandOS Handling**:

**1. Timeouts**:
```csharp
// Set timeouts on all external calls
var httpClient = new HttpClient
{
    Timeout = TimeSpan.FromSeconds(30)
};

// Or use Polly timeout policy
var timeoutPolicy = Policy.TimeoutAsync(TimeSpan.FromSeconds(30));
```

**2. Retries** (see above)

**3. Circuit Breakers** (see above)

**4. Fallbacks**:
```csharp
// If external service fails, use fallback
try
{
    return await _externalService.GetDataAsync();
}
catch (Exception ex)
{
    _logger.LogWarning(ex, "External service failed, using fallback");
    return await _fallbackService.GetDataAsync();
}
```

**5. Outbox Pattern** (see above): Handles network failures gracefully

---

## Split Brain

### Question 13: How do you prevent split-brain in distributed systems?

**Interview Stage**: Distributed Systems (30% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for cluster management

#### Strong Answer

**Split-Brain**: Network partition causes cluster to split into two groups, each thinking it's the leader.

**Prevention**:
1. **Quorum**: Majority of nodes must agree
2. **Leader Election**: Only one leader at a time
3. **Fencing**: Prevent old leader from acting

**BrandOS: Database Replication**:
```sql
-- PostgreSQL: Use quorum-based replication
-- Primary requires majority of replicas to acknowledge writes

-- Prevent split-brain: Only primary with majority can accept writes
```

**Leader Election** (for background jobs):
```csharp
// Use distributed lock (Redis, etcd, ZooKeeper)
public class LeaderElection
{
    private readonly IDistributedLock _lock;
    
    public async Task<bool> TryAcquireLeadershipAsync()
    {
        // Try to acquire lock (with TTL)
        var acquired = await _lock.TryAcquireAsync("leader", TimeSpan.FromMinutes(5));
        
        if (acquired)
        {
            // Renew lock periodically
            _ = Task.Run(async () =>
            {
                while (true)
                {
                    await Task.Delay(TimeSpan.FromMinutes(2));
                    await _lock.RenewAsync("leader", TimeSpan.FromMinutes(5));
                }
            });
        }
        
        return acquired;
    }
}
```

---

## Leader Election

### Question 14: Design leader election for BrandOS background jobs

**Interview Stage**: Distributed Systems (20% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for avoiding duplicate processing

#### Strong Answer

**Leader Election**: Only one instance processes background jobs.

**BrandOS: Distributed Lock**:
```csharp
// Use Redis distributed lock
public class OutboxProcessorJob : BackgroundService
{
    private readonly IDistributedLock _lock;
    
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            // Try to acquire leadership
            var isLeader = await _lock.TryAcquireAsync("outbox-processor", TimeSpan.FromMinutes(5));
            
            if (isLeader)
            {
                // Process outbox
                await ProcessOutboxAsync(stoppingToken);
                
                // Renew lock
                await _lock.RenewAsync("outbox-processor", TimeSpan.FromMinutes(5));
            }
            else
            {
                // Not leader, wait
                await Task.Delay(TimeSpan.FromSeconds(10), stoppingToken);
            }
        }
    }
}
```

**Alternative: Database-Based**:
```sql
-- Use database row as lock
UPDATE leader_election 
SET leader_id = 'instance-1', last_heartbeat = NOW()
WHERE service_name = 'outbox-processor' 
  AND (leader_id IS NULL OR last_heartbeat < NOW() - INTERVAL '1 minute');

-- Only one instance can update (atomic)
```

---

## Designing Resilient Systems

### Question 15: Design a resilient system for BrandOS

**Interview Stage**: System Design (70% probability)  
**Difficulty**: Principal  
**Why Asked**: Tests overall system design skills

#### Strong Answer

**Resilience Patterns** (all applied in BrandOS):

1. **Retries**: Exponential backoff with jitter
2. **Circuit Breakers**: Prevent cascading failures
3. **Timeouts**: Prevent hanging requests
4. **Bulkheads**: Isolate failures
5. **Health Checks**: Detect failures early
6. **Graceful Degradation**: Fallback to simpler functionality
7. **Idempotency**: Safe retries
8. **Outbox Pattern**: Guaranteed delivery
9. **Leader Election**: Avoid duplicate processing
10. **Monitoring**: Observability for quick recovery

**BrandOS Resilience Architecture**:
```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
┌──────▼──────┐
│ Load Balancer│ (Health checks, failover)
└──────┬──────┘
       │
┌──────▼──────┐
│ API Server  │ (Circuit breakers, retries, timeouts)
└──────┬──────┘
       │
   ┌───┴───┐
   │       │
┌──▼──┐ ┌─▼───┐
│ DB  │ │Cache│ (Fail-open, fallback)
└─────┘ └─────┘
```

**Every external call is wrapped with**:
- Retry policy
- Circuit breaker
- Timeout
- Fallback

---

## Conclusion

### Key Takeaways

1. **CAP Theorem**: Choose CP or AP based on requirements
2. **Idempotency**: Critical for retry-safe operations
3. **Retries**: Exponential backoff with jitter
4. **Circuit Breakers**: Prevent cascading failures
5. **Saga Pattern**: Distributed transactions without 2PC
6. **Outbox Pattern**: Guaranteed message delivery
7. **Fault Tolerance**: Assume failures, design for them

### Practice Questions

1. Design a distributed payment system
2. Handle network partitions in a multi-region system
3. Ensure exactly-once processing of events
4. Design leader election for background jobs
5. Handle split-brain in a database cluster

---

**Remember**: Distributed systems are inherently unreliable. Design for failure, not for success.



