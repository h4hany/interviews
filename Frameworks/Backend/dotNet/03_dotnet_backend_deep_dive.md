# .NET Backend Deep Dive
## Advanced Topics for Principal Engineer Interviews - BrandOS Edition

> **Target**: Staff/Principal Backend Engineer interviews focusing on .NET expertise  
> **Focus**: CLR internals, performance, concurrency, production debugging  
> **Format**: Deep technical questions with BrandOS codebase examples

---

## Table of Contents

1. [CLR Internals & Memory Management](#clr-internals--memory-management)
2. [Garbage Collection Deep Dive](#garbage-collection-deep-dive)
3. [async/await Internals](#asyncawait-internals)
4. [Threading & Concurrency](#threading--concurrency)
5. [Performance Tuning](#performance-tuning)
6. [Task vs ValueTask](#task-vs-valuetask)
7. [Span & Memory](#span--memory)
8. [Object Pooling](#object-pooling)
9. [Middleware Pipeline](#middleware-pipeline)
10. [Dependency Injection Internals](#dependency-injection-internals)
11. [Exception Handling at Scale](#exception-handling-at-scale)
12. [Logging & Observability](#logging--observability)
13. [Clean Architecture in BrandOS](#clean-architecture-in-brandos)
14. [SOLID Principles Applied](#solid-principles-applied)
15. [Production Debugging](#production-debugging)
16. [Performance Bottleneck Detection](#performance-bottleneck-detection)

---

## CLR Internals & Memory Management

### Question 1: Explain the .NET Memory Model

**Interview Stage**: Technical Deep Dive (60% probability)  
**Difficulty**: Principal  
**Why Asked**: Tests understanding of runtime fundamentals

#### Strong Answer

**.NET Memory Model**:

1. **Managed Heap**: Objects allocated on heap, managed by GC
2. **Stack**: Value types, method parameters, local variables
3. **Generation-Based GC**: Gen 0 (young), Gen 1 (middle), Gen 2 (old)
4. **Large Object Heap (LOH)**: Objects > 85KB

**BrandOS Example**:
```csharp
// This creates objects on the heap
public async Task<Order> CreateOrderAsync(CreateOrderDto dto)
{
    // dto is on stack (reference), object is on heap
    var order = new Order(dto.CustomerId, dto.Items); // Heap allocation
    
    // List<T> allocates on heap
    var items = new List<OrderItem>(); // Heap allocation
    
    // String interning (heap, but optimized)
    var status = "Pending"; // May be interned
    
    await _db.Orders.AddAsync(order);
    await _db.SaveChangesAsync();
    
    return order; // Reference returned, object stays on heap
}
```

**Memory Layout**:
```
Stack (per thread):
  - dto (reference, 8 bytes on 64-bit)
  - order (reference, 8 bytes)
  - items (reference, 8 bytes)

Heap:
  - Order object (~100 bytes)
  - OrderItem[] array (~200 bytes)
  - String objects (varies)
```

#### Follow-up Questions

**Q: What happens when you pass a struct vs class?**
```csharp
// Struct: copied on stack
public void ProcessOrder(OrderDto order) // Copy of struct
{
    order.Amount = 100; // Modifies copy, not original
}

// Class: reference passed
public void ProcessOrder(Order order) // Reference (8 bytes)
{
    order.Amount = 100; // Modifies original object
}
```

**Q: How does boxing work?**
```csharp
int value = 42; // Stack
object boxed = value; // Heap allocation (boxing)
int unboxed = (int)boxed; // Unboxing (copy from heap to stack)
```

#### Weak Answer Example

❌ "Objects are stored in memory. The GC cleans them up."

**Why Weak**: No understanding of heap/stack, generations, or memory layout.

#### FAANG Evaluation

**Strong Candidate**:
- Explains heap vs stack
- Understands GC generations
- Knows when allocations happen
- Can optimize allocations

**Weak Candidate**:
- Vague understanding
- No knowledge of memory model
- Can't optimize

---

## Garbage Collection Deep Dive

### Question 2: Explain .NET Garbage Collection

**Interview Stage**: Technical Deep Dive (70% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for high-performance systems

#### Strong Answer

**.NET GC Process**:

1. **Mark Phase**: Traverse object graph, mark reachable objects
2. **Sweep Phase**: Free unmarked objects
3. **Compact Phase**: Move objects to reduce fragmentation

**Generations**:
- **Gen 0**: New objects (survives ~1 GC)
- **Gen 1**: Survived Gen 0 GC (survives ~10 GCs)
- **Gen 2**: Long-lived objects (collected rarely)

**GC Modes**:
- **Workstation**: Optimized for UI responsiveness
- **Server**: Optimized for throughput (multiple GC threads)

**BrandOS Configuration**:
```csharp
// In Program.cs or appsettings.json
// Server GC for better throughput
<PropertyGroup>
  <ServerGarbageCollection>true</ServerGarbageCollection>
  <ConcurrentGarbageCollection>true</ConcurrentGarbageCollection>
</PropertyGroup>
```

**GC Triggers**:
1. **Allocation Pressure**: Gen 0 full
2. **Memory Pressure**: System low on memory
3. **Manual**: `GC.Collect()` (rarely needed)

**BrandOS Example - Avoiding Allocations**:
```csharp
// ❌ Bad: Allocates on every call
public async Task<List<Order>> GetOrdersAsync()
{
    var orders = new List<Order>(); // Heap allocation
    // ... populate
    return orders;
}

// ✅ Better: Use IAsyncEnumerable (no intermediate list)
public async IAsyncEnumerable<Order> GetOrdersAsync()
{
    await foreach (var order in _db.Orders.AsAsyncEnumerable())
    {
        yield return order; // No intermediate allocation
    }
}

// ✅ Best: Use ArrayPool for temporary arrays
var buffer = ArrayPool<byte>.Shared.Rent(1024);
try
{
    // Use buffer
}
finally
{
    ArrayPool<byte>.Shared.Return(buffer);
}
```

#### Follow-up Questions

**Q: When should you call GC.Collect()?**
```csharp
// ❌ Almost never in production code
// Only in:
// 1. Unit tests (to verify disposal)
// 2. After large one-time operations
// 3. Memory profiling scenarios

// Example: After processing large batch
await ProcessLargeBatchAsync();
GC.Collect(2, GCCollectionMode.Forced, blocking: true);
```

**Q: How do you measure GC pressure?**
```csharp
// Use performance counters or EventSource
var gen0Collections = GC.CollectionCount(0);
var gen1Collections = GC.CollectionCount(1);
var gen2Collections = GC.CollectionCount(2);

// Monitor in production
_logger.LogInformation(
    "GC Collections - Gen0: {Gen0}, Gen1: {Gen1}, Gen2: {Gen2}",
    gen0Collections, gen1Collections, gen2Collections);
```

#### Weak Answer Example

❌ "GC automatically cleans up memory. You don't need to worry about it."

**Why Weak**: Doesn't understand GC impact on performance, when to optimize.

#### FAANG Evaluation

**Strong Candidate**:
- Understands generations
- Knows GC modes
- Can optimize allocations
- Monitors GC in production

**Weak Candidate**:
- Thinks GC is magic
- No optimization knowledge

---

## async/await Internals

### Question 3: How does async/await work under the hood?

**Interview Stage**: Technical Deep Dive (80% probability)  
**Difficulty**: Staff/Principal  
**Why Asked**: Critical for async code understanding

#### Strong Answer

**State Machine Transformation**:

The compiler transforms `async` methods into state machines:

```csharp
// Original code
public async Task<Order> GetOrderAsync(int id)
{
    var order = await _db.Orders.FindAsync(id);
    return order;
}

// Compiler generates (simplified):
public Task<Order> GetOrderAsync(int id)
{
    var stateMachine = new GetOrderAsyncStateMachine
    {
        _id = id,
        _builder = AsyncTaskMethodBuilder<Order>.Create(),
        _state = -1
    };
    stateMachine._builder.Start(ref stateMachine);
    return stateMachine._builder.Task;
}

private struct GetOrderAsyncStateMachine : IAsyncStateMachine
{
    public int _state;
    public AsyncTaskMethodBuilder<Order> _builder;
    public int _id;
    private TaskAwaiter<Order> _awaiter;
    
    public void MoveNext()
    {
        if (_state == 0)
        {
            // After await
            var order = _awaiter.GetResult();
            _builder.SetResult(order);
            return;
        }
        
        // Before await
        _awaiter = _db.Orders.FindAsync(_id).GetAwaiter();
        if (!_awaiter.IsCompleted)
        {
            _state = 0;
            _awaiter.OnCompleted(MoveNext);
            return;
        }
        
        // Synchronously completed
        var result = _awaiter.GetResult();
        _builder.SetResult(result);
    }
}
```

**Key Points**:
1. **State Machine**: Tracks execution state
2. **SynchronizationContext**: Captures context (UI thread, etc.)
3. **ConfigureAwait(false)**: Skips context capture (better performance)

**BrandOS Example - ConfigureAwait(false)**:
```csharp
// ✅ Good: Skip context capture in library code
public async Task<Order> GetOrderAsync(int id)
{
    // No need to return to original context (ASP.NET doesn't have one)
    var order = await _db.Orders.FindAsync(id).ConfigureAwait(false);
    return order;
}

// ❌ Unnecessary in ASP.NET Core (no SynchronizationContext)
public async Task<Order> GetOrderAsync(int id)
{
    var order = await _db.Orders.FindAsync(id); // Context capture unnecessary
    return order;
}
```

**Performance Impact**:
- **Allocation**: State machine struct (usually stack-allocated)
- **Overhead**: ~50-100 bytes per async method
- **Benefit**: Non-blocking I/O, better scalability

#### Follow-up Questions

**Q: When should you use ConfigureAwait(false)?**
```csharp
// ✅ Always in library code (BrandOS.Infrastructure, BrandOS.Application)
public async Task ProcessAsync()
{
    await _httpClient.GetAsync(url).ConfigureAwait(false);
    await _db.SaveChangesAsync().ConfigureAwait(false);
}

// ⚠️ In UI code, you might need context
public async Task LoadDataAsync()
{
    await _api.GetDataAsync(); // Needs UI context
    UpdateUI(); // Must run on UI thread
}
```

**Q: What's the difference between Task and ValueTask?**
```csharp
// Task: Always heap-allocated
public async Task<Order> GetOrderAsync(int id)
{
    return await _db.Orders.FindAsync(id); // Heap allocation
}

// ValueTask: Can be stack-allocated if synchronous
public async ValueTask<Order> GetOrderAsync(int id)
{
    var cached = _cache.Get(id);
    if (cached != null)
        return cached; // No allocation (synchronous path)
    
    return await _db.Orders.FindAsync(id); // Allocation only if async
}
```

#### Weak Answer Example

❌ "async/await makes code run in parallel. It's like threads."

**Why Weak**: Confuses async with parallelism, doesn't understand state machines.

#### FAANG Evaluation

**Strong Candidate**:
- Understands state machines
- Knows ConfigureAwait(false)
- Understands performance implications
- Can optimize async code

**Weak Candidate**:
- Thinks async = parallel
- No understanding of internals

---

## Threading & Concurrency

### Question 4: Explain thread safety in .NET

**Interview Stage**: Technical Deep Dive (70% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for concurrent systems

#### Strong Answer

**Thread Safety Concepts**:

1. **Atomic Operations**: `Interlocked` class
2. **Locks**: `lock`, `Monitor`, `Mutex`
3. **Concurrent Collections**: `ConcurrentDictionary`, `ConcurrentQueue`
4. **Immutable Data**: Prevents race conditions

**BrandOS Example - Thread-Safe Cache**:
```csharp
// ❌ Not thread-safe
public class CacheService
{
    private readonly Dictionary<string, object> _cache = new();
    
    public void Set(string key, object value)
    {
        _cache[key] = value; // Race condition if multiple threads
    }
}

// ✅ Thread-safe with lock
public class CacheService
{
    private readonly Dictionary<string, object> _cache = new();
    private readonly object _lock = new();
    
    public void Set(string key, object value)
    {
        lock (_lock)
        {
            _cache[key] = value;
        }
    }
}

// ✅ Better: Use ConcurrentDictionary
public class CacheService
{
    private readonly ConcurrentDictionary<string, object> _cache = new();
    
    public void Set(string key, object value)
    {
        _cache[key] = value; // Thread-safe, no lock needed
    }
}
```

**BrandOS Example - Background Job Thread Safety**:
```csharp
// Background job processes outbox messages
public class OutboxProcessorJob : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            // Each iteration uses new scope (thread-safe)
            using var scope = _serviceProvider.CreateScope();
            var repository = scope.ServiceProvider.GetRequiredService<IOutboxRepository>();
            
            // Process batch (no shared state)
            var messages = await repository.GetUnprocessedMessagesAsync(100);
            foreach (var message in messages)
            {
                await ProcessMessageAsync(message); // No race conditions
            }
            
            await Task.Delay(_interval, stoppingToken);
        }
    }
}
```

**Deadlock Prevention**:
```csharp
// ❌ Deadlock risk
lock (lockA)
{
    lock (lockB) // Another thread might have lockB, waiting for lockA
    {
        // ...
    }
}

// ✅ Always acquire locks in same order
var locks = new[] { lockA, lockB }.OrderBy(l => l.GetHashCode());
lock (locks[0])
{
    lock (locks[1])
    {
        // ...
    }
}
```

#### Follow-up Questions

**Q: How do you handle concurrent database updates?**
```csharp
// BrandOS uses optimistic concurrency (RowVersion)
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
    // Handle conflict (refresh and retry, or return error)
    await ex.Entries[0].ReloadAsync();
    // Retry or return conflict error
}
```

**Q: When should you use async vs parallel?**
```csharp
// async: I/O-bound operations (non-blocking)
public async Task<Order> GetOrderAsync(int id)
{
    return await _db.Orders.FindAsync(id); // I/O, use async
}

// Parallel: CPU-bound operations
public void ProcessOrders(Order[] orders)
{
    Parallel.ForEach(orders, order =>
    {
        CalculateTax(order); // CPU-bound, use parallel
    });
}
```

#### Weak Answer Example

❌ "Just use locks everywhere. That makes it thread-safe."

**Why Weak**: Doesn't understand deadlocks, performance impact, or better alternatives.

#### FAANG Evaluation

**Strong Candidate**:
- Understands different synchronization primitives
- Knows when to use each
- Avoids deadlocks
- Optimizes for performance

**Weak Candidate**:
- Uses locks everywhere
- Doesn't understand alternatives
- Creates deadlocks

---

## Performance Tuning

### Question 5: How do you optimize .NET backend performance?

**Interview Stage**: Technical Deep Dive (60% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for high-scale systems

#### Strong Answer

**Performance Optimization Strategies**:

1. **Reduce Allocations**: Use structs, pooling, Span<T>
2. **Optimize Database Queries**: Indexes, compiled queries, pagination
3. **Caching**: Redis, in-memory cache
4. **Async I/O**: Non-blocking operations
5. **Connection Pooling**: Reuse connections

**BrandOS Example - Reducing Allocations**:
```csharp
// ❌ Allocates string on every call
public string GetCacheKey(int tenantId, int userId)
{
    return $"permissions:tenant:{tenantId}:user:{userId}"; // Heap allocation
}

// ✅ Use string interpolation (compiler optimizes)
public string GetCacheKey(int tenantId, int userId)
{
    return $"permissions:tenant:{tenantId}:user:{userId}"; // Still allocates, but optimized
}

// ✅ Better: Use ReadOnlySpan<char> for parsing
public int ParseId(ReadOnlySpan<char> input)
{
    // No allocation for substring operations
    var idPart = input.Slice(10); // No allocation
    return int.Parse(idPart);
}
```

**BrandOS Example - Database Optimization**:
```csharp
// ❌ N+1 query problem
public async Task<List<Order>> GetOrdersWithItemsAsync()
{
    var orders = await _db.Orders.ToListAsync();
    foreach (var order in orders)
    {
        order.Items = await _db.OrderItems
            .Where(i => i.OrderId == order.Id)
            .ToListAsync(); // N queries!
    }
    return orders;
}

// ✅ Use Include (eager loading)
public async Task<List<Order>> GetOrdersWithItemsAsync()
{
    return await _db.Orders
        .Include(o => o.Items) // Single query with JOIN
        .ToListAsync();
}

// ✅ Better: Use compiled queries for hot paths
private static readonly Func<ApplicationDbContext, int, Task<Order?>> GetOrderById =
    EF.CompileAsyncQuery((ApplicationDbContext db, int id) =>
        db.Orders.FirstOrDefault(o => o.Id == id));

public async Task<Order?> GetOrderAsync(int id)
{
    return await GetOrderById(_db, id); // Compiled, faster
}
```

**BrandOS Example - Caching**:
```csharp
// Cache permissions (accessed frequently)
public async Task<Permissions> GetPermissionsAsync(int userId)
{
    var cacheKey = $"permissions:user:{userId}";
    
    // Check cache first
    var cached = await _cache.GetAsync<Permissions>(cacheKey);
    if (cached != null) return cached;
    
    // Fetch from database
    var permissions = await _db.Permissions
        .Where(p => p.UserId == userId)
        .ToListAsync();
    
    // Cache for 30 minutes
    await _cache.SetAsync(cacheKey, permissions, TimeSpan.FromMinutes(30));
    
    return permissions;
}
```

#### Follow-up Questions

**Q: How do you profile .NET applications?**
```csharp
// Use dotMemory, PerfView, or Application Insights
// Or use built-in EventSource

// Example: Measure method execution time
var stopwatch = Stopwatch.StartNew();
try
{
    await ProcessOrderAsync(order);
}
finally
{
    stopwatch.Stop();
    _logger.LogInformation("ProcessOrder took {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);
}
```

**Q: What's the performance impact of LINQ?**
```csharp
// ❌ LINQ allocates enumerators
var orders = orders.Where(o => o.Status == "Pending")
    .OrderBy(o => o.CreatedAt)
    .ToList(); // Multiple allocations

// ✅ Use compiled queries for hot paths
var pendingOrders = await GetPendingOrdersQuery(_db).ToListAsync();
```

#### Weak Answer Example

❌ "Just add more servers. That fixes performance."

**Why Weak**: Doesn't understand root causes, can't optimize code.

#### FAANG Evaluation

**Strong Candidate**:
- Understands allocation impact
- Optimizes database queries
- Uses caching effectively
- Profiles and measures

**Weak Candidate**:
- Throws hardware at problems
- Doesn't measure
- No optimization knowledge

---

## Task vs ValueTask

### Question 6: When should you use ValueTask instead of Task?

**Interview Stage**: Technical Deep Dive (40% probability)  
**Difficulty**: Principal  
**Why Asked**: Tests understanding of performance optimizations

#### Strong Answer

**ValueTask Benefits**:
- **No Allocation**: If method completes synchronously
- **Better Performance**: For hot paths
- **Tradeoff**: Slightly more complex

**When to Use ValueTask**:
1. Method often completes synchronously
2. Hot path (called millions of times)
3. Library code (not public API)

**BrandOS Example**:
```csharp
// ✅ Good: ValueTask for cache lookup (often synchronous)
public async ValueTask<Permissions?> GetPermissionsAsync(int userId)
{
    var cacheKey = $"permissions:user:{userId}";
    
    // Synchronous path (no allocation)
    var cached = await _cache.GetAsync<Permissions>(cacheKey);
    if (cached != null)
        return cached; // Returns ValueTask, no allocation
    
    // Async path (allocation only if needed)
    var permissions = await _db.Permissions
        .Where(p => p.UserId == userId)
        .FirstOrDefaultAsync();
    
    if (permissions != null)
    {
        await _cache.SetAsync(cacheKey, permissions);
    }
    
    return permissions;
}

// ❌ Task is fine for mostly-async operations
public async Task<Order> GetOrderAsync(int id)
{
    // Always async, Task is appropriate
    return await _db.Orders.FindAsync(id);
}
```

**Performance Impact**:
- **ValueTask (sync)**: 0 allocations
- **Task (async)**: ~100 bytes per call
- **ValueTask (async)**: ~100 bytes (same as Task)

#### Follow-up Questions

**Q: Can you await ValueTask multiple times?**
```csharp
// ✅ Yes, but only once if it wraps a Task
var valueTask = GetPermissionsAsync(userId);
var result1 = await valueTask; // OK
var result2 = await valueTask; // OK if synchronous, throws if async
```

**Q: When is ValueTask not appropriate?**
```csharp
// ❌ Don't use ValueTask for public APIs that are always async
public async ValueTask<Order> CreateOrderAsync(OrderDto dto)
{
    // Always async, Task is better (simpler API)
    return await _db.Orders.AddAsync(order);
}
```

#### Weak Answer Example

❌ "ValueTask is always faster than Task."

**Why Weak**: Doesn't understand when ValueTask helps vs when it doesn't.

#### FAANG Evaluation

**Strong Candidate**:
- Understands when ValueTask helps
- Knows tradeoffs
- Uses appropriately

**Weak Candidate**:
- Uses ValueTask everywhere
- Doesn't understand when it helps

---

## Span & Memory

### Question 7: Explain Span<T> and Memory<T>

**Interview Stage**: Technical Deep Dive (30% probability)  
**Difficulty**: Principal  
**Why Asked**: Tests understanding of zero-allocation optimizations

#### Strong Answer

**Span<T> and Memory<T>**:
- **Span<T>**: Stack-only, zero-allocation slicing
- **Memory<T>**: Heap-allocated, can be stored
- **Use Case**: Parsing, string manipulation, buffer operations

**BrandOS Example - String Parsing**:
```csharp
// ❌ Allocates substrings
public int ParseTenantId(string header)
{
    var parts = header.Split(':'); // Allocates array and strings
    return int.Parse(parts[1]);
}

// ✅ Zero allocation with Span
public int ParseTenantId(ReadOnlySpan<char> header)
{
    var colonIndex = header.IndexOf(':');
    var idSpan = header.Slice(colonIndex + 1); // No allocation
    return int.Parse(idSpan);
}
```

**BrandOS Example - Buffer Operations**:
```csharp
// Process large buffers without allocation
public void ProcessBuffer(ReadOnlySpan<byte> buffer)
{
    // Slice without allocation
    var header = buffer.Slice(0, 16);
    var body = buffer.Slice(16);
    
    ProcessHeader(header);
    ProcessBody(body);
}
```

#### Follow-up Questions

**Q: When can't you use Span<T>?**
```csharp
// ❌ Can't store Span in fields (stack-only)
public class Parser
{
    private Span<char> _buffer; // Error: Can't store Span in class
}

// ✅ Use Memory<T> instead
public class Parser
{
    private Memory<char> _buffer; // OK: Can store Memory
}
```

#### Weak Answer Example

❌ "Span is like an array but faster."

**Why Weak**: Doesn't understand zero-allocation benefits or stack-only restrictions.

---

## Object Pooling

### Question 8: When and how do you use object pooling?

**Interview Stage**: Technical Deep Dive (30% probability)  
**Difficulty**: Principal  
**Why Asked**: Tests understanding of allocation optimization

#### Strong Answer

**Object Pooling**:
- **Use Case**: Frequently allocated objects (StringBuilder, byte arrays)
- **Benefit**: Reduces GC pressure
- **Tradeoff**: Slightly more complex code

**BrandOS Example - StringBuilder Pooling**:
```csharp
// ❌ Allocates StringBuilder on every call
public string BuildCacheKey(int tenantId, int userId)
{
    var sb = new StringBuilder(); // Allocation
    sb.Append("permissions:tenant:");
    sb.Append(tenantId);
    sb.Append(":user:");
    sb.Append(userId);
    return sb.ToString();
}

// ✅ Use ArrayPool for temporary buffers
public void ProcessData(byte[] data)
{
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
}
```

**BrandOS Example - HttpClient Pooling**:
```csharp
// ✅ HttpClientFactory pools connections
builder.Services.AddHttpClient("default")
    .ConfigurePrimaryHttpMessageHandler(() => new HttpClientHandler
    {
        MaxConnectionsPerServer = 10 // Connection pooling
    });
```

#### Follow-up Questions

**Q: When is pooling not worth it?**
```csharp
// ❌ Not worth pooling rarely-allocated objects
public class OrderService
{
    private readonly ObjectPool<Order> _orderPool; // Overhead > benefit
}

// ✅ Pool frequently-allocated objects
public class StringService
{
    private readonly ObjectPool<StringBuilder> _sbPool; // Worth it
}
```

---

## Middleware Pipeline

### Question 9: Explain ASP.NET Core middleware pipeline

**Interview Stage**: Technical Deep Dive (50% probability)  
**Difficulty**: Staff  
**Why Asked**: Critical for understanding request processing

#### Strong Answer

**Middleware Pipeline**:
- **Order Matters**: Executes in registration order
- **Request/Response**: Can modify both
- **Short-Circuit**: Can end pipeline early

**BrandOS Middleware Order**:
```csharp
// Program.cs - Order is critical!
app.UseHttpsRedirection();
app.UseMiddleware<SecureHeadersMiddleware>(); // 1. Security headers
app.UseMiddleware<CorrelationIdMiddleware>(); // 2. Correlation ID
app.UseMiddleware<IdempotencyMiddleware>(); // 3. Idempotency (before rate limiting)
app.UseMiddleware<RateLimitingMiddleware>(); // 4. Rate limiting
app.UseMiddleware<RoleEscalationProtectionMiddleware>(); // 5. Security
app.UseMiddleware<MetricsMiddleware>(); // 6. Metrics
app.UseMiddleware<RequestLoggingMiddleware>(); // 7. Logging
app.UseMiddleware<TenantResolverMiddleware>(); // 8. Tenant resolution
app.UseMiddleware<TenantStateEnforcementMiddleware>(); // 9. Tenant validation
app.UseMiddleware<GlobalExceptionHandlerMiddleware>(); // 10. Exception handling (last)
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
```

**Why This Order**:
1. **Security First**: Headers, rate limiting before processing
2. **Observability Early**: Correlation ID, metrics, logging
3. **Business Logic Last**: Tenant resolution, exception handling

**BrandOS Example - Custom Middleware**:
```csharp
public class TenantResolverMiddleware
{
    private readonly RequestDelegate _next;
    
    public TenantResolverMiddleware(RequestDelegate next)
    {
        _next = next;
    }
    
    public async Task InvokeAsync(HttpContext context, ITenantProvider tenantProvider)
    {
        // Resolve tenant from subdomain, header, or JWT
        var tenantId = ResolveTenantId(context);
        tenantProvider.SetTenantId(tenantId);
        context.Items["TenantId"] = tenantId;
        
        // Continue pipeline
        await _next(context);
    }
}
```

#### Follow-up Questions

**Q: How do you short-circuit the pipeline?**
```csharp
// Don't call _next(context)
public async Task InvokeAsync(HttpContext context)
{
    if (context.Request.Path.StartsWithSegments("/health"))
    {
        await context.Response.WriteAsync("OK");
        return; // Short-circuit, don't call _next
    }
    
    await _next(context);
}
```

---

## Dependency Injection Internals

### Question 10: Explain .NET Dependency Injection

**Interview Stage**: Technical Deep Dive (60% probability)  
**Difficulty**: Staff  
**Why Asked**: Critical for understanding architecture

#### Strong Answer

**DI Container**:
- **Service Lifetime**: Singleton, Scoped, Transient
- **Registration**: Add services to container
- **Resolution**: Container creates and injects dependencies

**BrandOS Service Lifetimes**:
```csharp
// Singleton: One instance for application lifetime
builder.Services.AddSingleton<IConnectionMultiplexer>(sp =>
{
    return ConnectionMultiplexer.Connect(connectionString);
});

// Scoped: One instance per HTTP request
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
builder.Services.AddScoped<ITenantProvider, TenantProvider>();

// Transient: New instance every time
builder.Services.AddTransient<IValidator<CreateOrderDto>, CreateOrderDtoValidator>();
```

**Why Each Lifetime**:
- **Singleton**: Expensive to create (Redis, HTTP clients)
- **Scoped**: Request-scoped (DbContext, UnitOfWork)
- **Transient**: Stateless, cheap to create (validators)

**BrandOS Example - Scoped Services**:
```csharp
// DbContext is scoped (one per request)
builder.Services.AddDbContext<ApplicationDbContext>(options =>
{
    // Scoped lifetime
});

// UnitOfWork uses same DbContext instance
public class UnitOfWork : IUnitOfWork
{
    private readonly ApplicationDbContext _context; // Same instance as controller
}
```

#### Follow-up Questions

**Q: What happens if you inject a Scoped service into a Singleton?**
```csharp
// ❌ Error: Can't inject scoped into singleton
builder.Services.AddSingleton<BadService>(sp =>
{
    var dbContext = sp.GetRequiredService<ApplicationDbContext>(); // Error!
});

// ✅ Use IServiceScopeFactory
public class BackgroundJob
{
    private readonly IServiceScopeFactory _scopeFactory;
    
    public async Task ProcessAsync()
    {
        using var scope = _scopeFactory.CreateScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>(); // OK
    }
}
```

---

## Exception Handling at Scale

### Question 11: How do you handle exceptions in production?

**Interview Stage**: Technical Deep Dive (70% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for reliability

#### Strong Answer

**Exception Handling Strategy**:
1. **Global Exception Handler**: Catch all unhandled exceptions
2. **Structured Logging**: Log with context
3. **Error Responses**: Consistent error format
4. **Monitoring**: Alert on high error rates

**BrandOS Global Exception Handler**:
```csharp
public class GlobalExceptionHandlerMiddleware
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            await HandleExceptionAsync(context, ex);
        }
    }
    
    private async Task HandleExceptionAsync(HttpContext context, Exception ex)
    {
        // Log with context
        _logger.LogError(ex,
            "Unhandled exception: {Path}, Tenant: {TenantId}, User: {UserId}",
            context.Request.Path,
            context.Items["TenantId"],
            context.User?.Identity?.Name);
        
        // Return consistent error response
        context.Response.StatusCode = 500;
        await context.Response.WriteAsJsonAsync(new
        {
            code = 500,
            message = "An error occurred",
            // Don't expose internal details in production
            details = _env.IsDevelopment() ? ex.ToString() : null
        });
    }
}
```

**BrandOS Exception Types**:
```csharp
// Domain exceptions (business logic)
public class OutOfStockException : Exception { }
public class InvalidTenantException : Exception { }

// Infrastructure exceptions (retry-able)
public class TransientException : Exception { }

// Handle differently
try
{
    await ProcessOrderAsync(order);
}
catch (OutOfStockException ex)
{
    return BadRequest("Item out of stock"); // 400
}
catch (TransientException ex)
{
    // Retry with exponential backoff
    await RetryAsync(() => ProcessOrderAsync(order));
}
```

#### Follow-up Questions

**Q: How do you prevent exception swallowing?**
```csharp
// ❌ Bad: Swallows exception
try
{
    await SendEmailAsync();
}
catch
{
    // Swallowed!
}

// ✅ Good: Log and handle
try
{
    await SendEmailAsync();
}
catch (Exception ex)
{
    _logger.LogError(ex, "Failed to send email");
    // Don't fail request if email fails (best-effort)
}
```

---

## Clean Architecture in BrandOS

### Question 12: Explain Clean Architecture in BrandOS

**Interview Stage**: Architecture (80% probability)  
**Difficulty**: Principal  
**Why Asked**: Tests understanding of architecture patterns

#### Strong Answer

**BrandOS Clean Architecture Layers**:

1. **Domain**: Entities, value objects, domain events (no dependencies)
2. **Application**: Use cases, handlers, DTOs (depends on Domain)
3. **Infrastructure**: Data access, external services (depends on Domain, Application)
4. **API**: Controllers, middleware (depends on Application, Infrastructure)

**Dependency Rule**: Dependencies point inward
```
API → Application → Domain
Infrastructure → Application → Domain
```

**BrandOS Example**:
```csharp
// Domain (no dependencies)
public class Order : AggregateRoot
{
    public void Confirm()
    {
        // Business logic
        AddDomainEvent(new OrderConfirmedEvent(this));
    }
}

// Application (depends on Domain)
public interface ICreateOrderHandler
{
    Task<Result<Order>> HandleAsync(CreateOrderDto dto);
}

// Infrastructure (implements Application interface)
public class CreateOrderHandler : ICreateOrderHandler
{
    private readonly IOrderRepository _repository; // Infrastructure
    private readonly IUnitOfWork _unitOfWork; // Infrastructure
    
    public async Task<Result<Order>> HandleAsync(CreateOrderDto dto)
    {
        var order = new Order(dto.CustomerId, dto.Items); // Domain
        order.Confirm(); // Domain logic
        await _repository.AddAsync(order);
        await _unitOfWork.SaveChangesAsync();
        return Result.Success(order);
    }
}

// API (depends on Application)
[HttpPost]
public async Task<IActionResult> CreateOrder(CreateOrderDto dto)
{
    var result = await _createOrderHandler.HandleAsync(dto);
    return result.IsSuccess 
        ? Ok(result.Value) 
        : BadRequest(result.Error);
}
```

**Benefits**:
- **Testability**: Domain logic testable without infrastructure
- **Flexibility**: Can swap infrastructure (EF Core → Dapper)
- **Maintainability**: Clear separation of concerns

---

## SOLID Principles Applied

### Question 13: How does BrandOS apply SOLID principles?

**Interview Stage**: Architecture (60% probability)  
**Difficulty**: Principal  
**Why Asked**: Tests understanding of design principles

#### Strong Answer

**SOLID in BrandOS**:

**S - Single Responsibility**:
```csharp
// ✅ Each class has one responsibility
public class OrderService // Handles order business logic
public class PaymentService // Handles payment processing
public class NotificationService // Handles notifications
```

**O - Open/Closed**:
```csharp
// ✅ Open for extension, closed for modification
public interface IPaymentProcessor
{
    Task<PaymentResult> ProcessAsync(PaymentRequest request);
}

public class StripePaymentProcessor : IPaymentProcessor { }
public class PayPalPaymentProcessor : IPaymentProcessor { }
// Can add new processors without modifying existing code
```

**L - Liskov Substitution**:
```csharp
// ✅ Subtypes must be substitutable for base types
public interface IRepository<T>
{
    Task<T?> GetByIdAsync(int id);
}

public class OrderRepository : IRepository<Order>
{
    // Can be used anywhere IRepository<Order> is expected
}
```

**I - Interface Segregation**:
```csharp
// ✅ Small, focused interfaces
public interface IReadRepository<T>
{
    Task<T?> GetByIdAsync(int id);
    Task<IEnumerable<T>> GetAllAsync();
}

public interface IWriteRepository<T>
{
    Task AddAsync(T entity);
    Task UpdateAsync(T entity);
}

// Clients only depend on interfaces they use
```

**D - Dependency Inversion**:
```csharp
// ✅ Depend on abstractions, not concretions
public class OrderService
{
    private readonly IOrderRepository _repository; // Interface, not concrete class
    private readonly IEventBus _eventBus; // Interface
    
    // Can swap implementations without changing OrderService
}
```

---

## Production Debugging

### Question 14: How do you debug production issues?

**Interview Stage**: Technical Deep Dive (50% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for production support

#### Strong Answer

**Debugging Strategy**:
1. **Logs**: Structured logging with correlation IDs
2. **Metrics**: Performance counters, custom metrics
3. **Tracing**: Distributed tracing (OpenTelemetry)
4. **Profiling**: Memory dumps, CPU profiling

**BrandOS Logging**:
```csharp
// Structured logging with context
_logger.LogInformation(
    "Processing order {OrderId} for tenant {TenantId}",
    orderId, tenantId);

// Correlation ID for request tracking
var correlationId = context.Request.Headers["X-Correlation-Id"];
using (_logger.BeginScope(new Dictionary<string, object>
{
    ["CorrelationId"] = correlationId,
    ["TenantId"] = tenantId
}))
{
    // All logs in this scope include correlation ID
}
```

**BrandOS Metrics**:
```csharp
// Custom metrics
private static readonly Counter ProcessedOrders = 
    Metrics.CreateCounter("orders_processed_total");

public async Task ProcessOrderAsync(Order order)
{
    var stopwatch = Stopwatch.StartNew();
    try
    {
        await ProcessAsync(order);
        ProcessedOrders.Inc();
    }
    finally
    {
        stopwatch.Stop();
        _logger.LogInformation("ProcessOrder took {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);
    }
}
```

---

## Performance Bottleneck Detection

### Question 15: How do you identify performance bottlenecks?

**Interview Stage**: Technical Deep Dive (60% probability)  
**Difficulty**: Principal  
**Why Asked**: Critical for optimization

#### Strong Answer

**Bottleneck Detection**:
1. **Profiling**: dotMemory, PerfView, Application Insights
2. **Logging**: Slow query logging, request timing
3. **Metrics**: Response times, throughput, error rates
4. **Load Testing**: Simulate production load

**BrandOS Slow Query Detection**:
```csharp
// SlowQueryInterceptor logs queries > 1 second
public class SlowQueryInterceptor : DbCommandInterceptor
{
    public override async ValueTask<InterceptionResult<DbDataReader>> ReaderExecutingAsync(
        DbCommand command,
        CommandEventData eventData,
        InterceptionResult<DbDataReader> result,
        CancellationToken cancellationToken = default)
    {
        var stopwatch = Stopwatch.StartNew();
        var actualResult = await base.ReaderExecutingAsync(command, eventData, result, cancellationToken);
        stopwatch.Stop();
        
        if (stopwatch.Elapsed > _threshold)
        {
            _logger.LogWarning(
                "Slow query detected: {CommandText}, Duration: {ElapsedMs}ms",
                command.CommandText, stopwatch.ElapsedMilliseconds);
        }
        
        return actualResult;
    }
}
```

**BrandOS Request Timing**:
```csharp
// MetricsMiddleware tracks request duration
public class MetricsMiddleware
{
    public async Task InvokeAsync(HttpContext context)
    {
        var stopwatch = Stopwatch.StartNew();
        await _next(context);
        stopwatch.Stop();
        
        _logger.LogInformation(
            "Request {Method} {Path} took {ElapsedMs}ms, Status: {StatusCode}",
            context.Request.Method,
            context.Request.Path,
            stopwatch.ElapsedMilliseconds,
            context.Response.StatusCode);
    }
}
```

---

## Conclusion

### Key Takeaways

1. **Understand Internals**: CLR, GC, async/await state machines
2. **Optimize Allocations**: Use ValueTask, Span, pooling
3. **Profile Everything**: Measure before optimizing
4. **Handle Exceptions**: Global handler, structured logging
5. **Follow SOLID**: Clean architecture, testability

### Practice Questions

1. Explain the difference between `Task` and `ValueTask`
2. How does the GC work? When does it run?
3. What's the performance impact of `async/await`?
4. How do you prevent memory leaks in .NET?
5. Explain the middleware pipeline execution order

---

**Remember**: Deep .NET knowledge separates Principal engineers from Senior engineers. Understand not just how to use features, but how they work internally.



