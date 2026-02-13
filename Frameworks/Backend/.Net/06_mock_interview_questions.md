# FAANG-Level Mock Interview Questions
## Principal Backend Engineer - BrandOS Edition

> **Target**: Staff/Principal Backend Engineer interviews at FAANG, EU tech companies  
> **Format**: Complete questions with ideal answers, evaluation rubrics, and BrandOS examples

---

## Table of Contents

1. [System Design Questions](#system-design-questions)
2. [Backend Architecture Questions](#backend-architecture-questions)
3. [Distributed Systems Questions](#distributed-systems-questions)
4. [Performance & Scalability Questions](#performance--scalability-questions)
5. [Production Incident Scenarios](#production-incident-scenarios)
6. [Code Review Scenarios](#code-review-scenarios)
7. [Architecture Redesign Questions](#architecture-redesign-questions)

---

## System Design Questions

### Question 1: Design a Multi-Tenant SaaS Platform

**Interview Stage**: System Design (90% probability)  
**Difficulty**: Principal  
**Time**: 45 minutes

#### Question

"Design a multi-tenant SaaS platform like BrandOS that supports 10,000 tenants with 1M daily active users. Each tenant can have up to 10,000 users. The platform handles e-commerce, inventory, finance, and HR operations. Focus on scalability, data isolation, and cost efficiency."

#### Ideal Answer Structure

**1. Clarify Requirements (5 min)**
- Functional: Multi-tenancy, e-commerce, inventory, finance, HR
- Non-functional: 10K tenants, 1M DAU, < 200ms latency, 99.9% availability
- Constraints: $50K/month budget, 6 months to MVP

**2. High-Level Design (10 min)**
- Load balancer → API servers → Database (primary + replicas)
- Redis cache, RabbitMQ for events
- Multi-tenancy: Row-level security with tenant_id

**3. Detailed Design (20 min)**
- Database schema with tenant_id on all tenant-scoped tables
- Caching strategy (permissions, feature flags)
- Event-driven architecture (outbox pattern)
- API design with tenant resolution

**4. Scale the System (5 min)**
- Read replicas for scaling reads
- Horizontal scaling for API servers
- Redis cluster for cache
- Database sharding by tenant_id for large scale

**5. Handle Failures (3 min)**
- Database failover (read replicas)
- Cache fail-open
- Outbox pattern for guaranteed delivery

**6. Tradeoffs (2 min)**
- Row-level vs separate databases (chose row-level for cost)
- Strong vs eventual consistency (CP for financial, AP for analytics)

#### Evaluation Rubric

**Principal-Level Answer**:
- ✅ Identifies multi-tenancy strategy with tradeoffs
- ✅ Designs for 10x-100x scale
- ✅ Handles failures gracefully
- ✅ Makes explicit tradeoffs
- ✅ Considers cost vs performance

**Senior-Level Answer**:
- ✅ Good design, but limited scale thinking
- ✅ Some tradeoff analysis
- ⚠️ May miss failure scenarios

**Weak Answer**:
- ❌ No multi-tenancy strategy
- ❌ Doesn't consider scale
- ❌ No failure handling
- ❌ No tradeoff analysis

#### What Separates Principal from Senior

**Principal**:
- Thinks in orders of magnitude (10x, 100x, 1000x)
- Makes explicit tradeoffs (cost vs isolation)
- Designs for evolution (can migrate to separate DBs)
- Considers business constraints (budget, timeline)

**Senior**:
- Good technical design
- Some scale thinking
- Less explicit about tradeoffs
- Less business awareness

#### Follow-up Questions

**Q: How would you handle a tenant with 100K users?**
- Separate database for large tenants
- Dedicated infrastructure
- Custom scaling strategy

**Q: How do you prevent tenant A from accessing tenant B's data?**
- TenantInterceptor enforces isolation at save time
- Global query filter at query time
- Defense in depth (multiple layers)

**Q: How would you migrate a tenant to a separate database?**
- Create new database
- Migrate data (background job)
- Update routing
- Verify data integrity
- Switch traffic gradually

#### Real BrandOS Example

```csharp
// BrandOS uses row-level security with tenant_id
public class TenantInterceptor : SaveChangesInterceptor
{
    public override InterceptionResult<int> SavingChanges(...)
    {
        var tenantId = _tenantProvider.GetTenantId();
        foreach (var entry in context.ChangeTracker.Entries<BaseEntity>())
        {
            if (entry.State == EntityState.Modified)
            {
                if (entry.Entity.TenantId != tenantId)
                {
                    throw new UnauthorizedAccessException("Tenant isolation violation");
                }
            }
        }
    }
}
```

---

### Question 2: Design a High-Throughput Event Processing System

**Interview Stage**: System Design (70% probability)  
**Difficulty**: Principal  
**Time**: 45 minutes

#### Question

"Design a system to process 100,000 events per second from BrandOS. Events include order confirmations, inventory updates, payment receipts, and analytics events. The system must guarantee at-least-once delivery and support real-time analytics."

#### Ideal Answer

**1. Clarify (5 min)**
- 100K events/sec, at-least-once, real-time analytics
- Events: 100 bytes - 10KB, some critical (payments), others best-effort

**2. High-Level (10 min)**
- Outbox pattern → Kafka → Stream processors → Storage
- Separate topics by event type and priority

**3. Detailed (20 min)**
- Kafka with 100 partitions (1K events/sec per partition)
- Kafka Streams for real-time processing
- Time-series database (InfluxDB) for analytics
- Idempotency for at-least-once

**4. Scale (5 min)**
- Kafka: Add partitions, consumers
- Stream processors: Auto-scale
- Storage: Shard by tenant_id

**5. Failures (3 min)**
- Kafka replication (3 replicas)
- Consumer failure: Rebalancing
- Processing failure: Dead-letter queue

**6. Tradeoffs (2 min)**
- Kafka vs RabbitMQ (chose Kafka for throughput)
- At-least-once vs exactly-once (chose at-least-once + idempotency)

#### Evaluation Rubric

**Principal**:
- ✅ Understands throughput requirements
- ✅ Designs for 100K events/sec
- ✅ Handles at-least-once with idempotency
- ✅ Real-time vs batch processing

**Senior**:
- ✅ Good design
- ⚠️ May not scale to 100K/sec
- ⚠️ Less idempotency focus

#### Real BrandOS Example

```csharp
// BrandOS uses outbox pattern for guaranteed delivery
public async Task DispatchAsync(IDomainEvent domainEvent)
{
    var outboxMessage = new OutboxMessage
    {
        Type = domainEvent.GetType().Name,
        Content = JsonSerializer.Serialize(domainEvent)
    };
    
    await _outboxRepository.AddAsync(outboxMessage);
    await _context.SaveChangesAsync(); // Atomic with business data
    
    // Background job processes outbox (eventual delivery)
}
```

---

## Backend Architecture Questions

### Question 3: Explain Clean Architecture in BrandOS

**Interview Stage**: Architecture (80% probability)  
**Difficulty**: Staff/Principal  
**Time**: 30 minutes

#### Question

"Explain how BrandOS implements Clean Architecture. What are the benefits and tradeoffs?"

#### Ideal Answer

**Clean Architecture Layers**:
1. **Domain**: Entities, value objects, domain events (no dependencies)
2. **Application**: Use cases, handlers, DTOs (depends on Domain)
3. **Infrastructure**: Data access, external services (depends on Domain, Application)
4. **API**: Controllers, middleware (depends on Application, Infrastructure)

**Dependency Rule**: Dependencies point inward
```
API → Application → Domain
Infrastructure → Application → Domain
```

**Benefits**:
- **Testability**: Domain logic testable without infrastructure
- **Flexibility**: Can swap infrastructure (EF Core → Dapper)
- **Maintainability**: Clear separation of concerns

**Tradeoffs**:
- **Complexity**: More layers, more indirection
- **Overhead**: DTOs, mappers, interfaces
- **Learning Curve**: Team needs to understand layers

**BrandOS Example**:
```csharp
// Domain (no dependencies)
public class Order : AggregateRoot
{
    public void Confirm()
    {
        AddDomainEvent(new OrderConfirmedEvent(this));
    }
}

// Application (depends on Domain)
public interface ICreateOrderHandler
{
    Task<Result<Order>> HandleAsync(CreateOrderDto dto);
}

// Infrastructure (implements Application)
public class CreateOrderHandler : ICreateOrderHandler
{
    private readonly IOrderRepository _repository;
    
    public async Task<Result<Order>> HandleAsync(CreateOrderDto dto)
    {
        var order = new Order(dto.CustomerId, dto.Items);
        order.Confirm();
        await _repository.AddAsync(order);
        return Result.Success(order);
    }
}
```

#### Evaluation Rubric

**Principal**:
- ✅ Explains dependency rule
- ✅ Discusses benefits and tradeoffs
- ✅ Can evolve architecture
- ✅ Understands when to break rules

**Senior**:
- ✅ Understands layers
- ⚠️ Less tradeoff analysis
- ⚠️ May not understand evolution

---

## Distributed Systems Questions

### Question 4: How do you ensure idempotency in BrandOS?

**Interview Stage**: Distributed Systems (80% probability)  
**Difficulty**: Principal  
**Time**: 30 minutes

#### Question

"Explain how BrandOS ensures idempotency for payment processing. What happens if a client retries a payment request?"

#### Ideal Answer

**Idempotency Strategy**:
1. **Idempotency Key**: Client provides unique key per operation
2. **Check Before Processing**: Lookup in idempotency store
3. **Store Result**: Cache response for 24 hours
4. **Return Cached**: If already processed, return same result

**BrandOS Implementation**:
```csharp
public async Task<PaymentResult> ProcessPaymentAsync(
    PaymentRequest request, 
    string idempotencyKey)
{
    // Check if already processed
    var existing = await _idempotencyService.GetResponseAsync(idempotencyKey);
    if (existing != null)
    {
        return JsonSerializer.Deserialize<PaymentResult>(existing);
    }
    
    // Process payment
    var result = await _paymentGateway.ChargeAsync(request);
    
    // Store result
    await _idempotencyService.MarkAsProcessedAsync(
        idempotencyKey, 
        JsonSerializer.Serialize(result)
    );
    
    return result;
}
```

**Database-Level Idempotency**:
```sql
-- Unique constraint on idempotency_key
CREATE UNIQUE INDEX idx_payments_idempotency_key ON payments (idempotency_key);

-- Insert fails if duplicate (idempotent)
```

**Middleware**:
```csharp
// IdempotencyMiddleware checks header
var idempotencyKey = context.Request.Headers["Idempotency-Key"];
if (!string.IsNullOrEmpty(idempotencyKey))
{
    var cached = await _idempotencyService.GetResponseAsync(idempotencyKey);
    if (cached != null)
    {
        return cached; // Return same response
    }
}
```

#### Evaluation Rubric

**Principal**:
- ✅ Multiple layers of idempotency
- ✅ Handles edge cases (concurrent requests)
- ✅ Database-level enforcement
- ✅ Understands TTL and cleanup

**Senior**:
- ✅ Basic idempotency
- ⚠️ May miss concurrent requests
- ⚠️ Less database-level thinking

---

## Performance & Scalability Questions

### Question 5: How would you scale BrandOS to 10M users?

**Interview Stage**: Scalability (70% probability)  
**Difficulty**: Principal  
**Time**: 30 minutes

#### Question

"BrandOS currently handles 1M users. How would you scale it to 10M users? What are the bottlenecks and how do you address them?"

#### Ideal Answer

**Bottleneck Analysis**:

**1. Database (Current: Single instance)**
- **10M Users**: Needs read replicas, sharding
- **Solution**: 
  - Read replicas for reads (80% of traffic)
  - Shard by tenant_id (10 shards = 1K tenants per shard)
  - Connection pooling optimization

**2. Application Servers (Current: Assumed single)**
- **10M Users**: Needs horizontal scaling
- **Solution**: Stateless design allows unlimited instances
- **Load Balancing**: Round-robin or least connections

**3. Cache (Current: Single Redis)**
- **10M Users**: Needs Redis cluster
- **Solution**: Redis cluster (3 masters, 3 replicas)
- **Sharding**: Automatic by key hash

**4. Message Queue (Current: Single RabbitMQ)**
- **10M Users**: Needs cluster or Kafka
- **Solution**: RabbitMQ cluster or migrate to Kafka

**Migration Strategy**:
1. **Phase 1**: Add read replicas (2 weeks)
2. **Phase 2**: Horizontal scale API servers (1 week)
3. **Phase 3**: Redis cluster (1 week)
4. **Phase 4**: Database sharding (4 weeks)
5. **Phase 5**: Kafka migration (4 weeks)

**Feature Flags**: Gradual rollout
```csharp
if (await _featureFlag.IsEnabledAsync("use-read-replicas"))
{
    return await _readDb.Orders.FindAsync(id);
}
else
{
    return await _writeDb.Orders.FindAsync(id);
}
```

#### Evaluation Rubric

**Principal**:
- ✅ Identifies all bottlenecks
- ✅ Provides migration strategy
- ✅ Uses feature flags for gradual rollout
- ✅ Measures before/after

**Senior**:
- ✅ Identifies some bottlenecks
- ⚠️ Less migration strategy
- ⚠️ May suggest big-bang migration

---

## Production Incident Scenarios

### Question 6: Database is Slow

**Interview Stage**: Problem Solving (60% probability)  
**Difficulty**: Principal  
**Time**: 30 minutes

#### Scenario

"BrandOS production database is experiencing high latency (5 seconds for simple queries). Users are complaining. How do you diagnose and fix this?"

#### Ideal Answer

**Diagnosis Process**:

**1. Check Monitoring** (2 min)
- Slow query logs (BrandOS has SlowQueryInterceptor)
- Database connection pool usage
- CPU, memory, disk I/O
- Active queries

**2. Identify Root Cause** (5 min)
```sql
-- Check active queries
SELECT pid, query, state, wait_event_type, wait_event
FROM pg_stat_activity
WHERE state != 'idle';

-- Check slow queries
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Check locks
SELECT * FROM pg_locks WHERE NOT granted;
```

**3. Common Causes**:
- **Missing Indexes**: Full table scans
- **Lock Contention**: Deadlocks, long-running transactions
- **Connection Pool Exhaustion**: Too many connections
- **N+1 Queries**: Multiple queries instead of one
- **Large Result Sets**: Fetching too much data

**4. Immediate Fixes** (5 min)
- **Kill Long-Running Queries**: `SELECT pg_terminate_backend(pid)`
- **Add Missing Indexes**: Based on slow query analysis
- **Increase Connection Pool**: If exhausted
- **Enable Query Caching**: For repeated queries

**5. Long-Term Fixes** (10 min)
- **Read Replicas**: Route reads to replicas
- **Query Optimization**: Rewrite slow queries
- **Connection Pooling**: Use PgBouncer
- **Monitoring**: Alert on slow queries

**BrandOS Tools**:
```csharp
// SlowQueryInterceptor already logs slow queries
if (stopwatch.Elapsed > _slowQueryThreshold)
{
    _logger.LogWarning(
        "Slow query detected: {Duration}ms - {CommandText}",
        stopwatch.ElapsedMilliseconds,
        command.CommandText);
}
```

#### Evaluation Rubric

**Principal**:
- ✅ Systematic diagnosis
- ✅ Uses monitoring tools
- ✅ Immediate + long-term fixes
- ✅ Prevents recurrence

**Senior**:
- ✅ Good diagnosis
- ⚠️ May miss some tools
- ⚠️ Less prevention focus

---

## Code Review Scenarios

### Question 7: Review This Code

**Interview Stage**: Code Review (50% probability)  
**Difficulty**: Staff/Principal  
**Time**: 20 minutes

#### Code

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

#### Ideal Review

**Issues**:
1. **N+1 Queries**: 1 query for orders + N queries for items + N queries for customers
2. **No Pagination**: Loads all orders into memory
3. **Missing Index**: May not have index on tenant_id
4. **No Error Handling**: Exceptions not handled

**Fixes**:
```csharp
// ✅ Fixed: Eager loading, pagination, error handling
public async Task<PagedResult<Order>> GetOrdersAsync(
    int tenantId, 
    int page, 
    int pageSize)
{
    try
    {
        var total = await _db.Orders
            .Where(o => o.TenantId == tenantId)
            .CountAsync();
        
        var orders = await _db.Orders
            .Include(o => o.Items) // Eager load items
            .Include(o => o.Customer) // Eager load customer
            .Where(o => o.TenantId == tenantId)
            .OrderByDescending(o => o.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
        
        return new PagedResult<Order>(orders, total, page, pageSize);
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Error fetching orders for tenant {TenantId}", tenantId);
        throw;
    }
}
```

#### Evaluation Rubric

**Principal**:
- ✅ Identifies N+1, pagination, indexing
- ✅ Provides fixes with explanations
- ✅ Considers performance, memory, errors
- ✅ Suggests monitoring

**Senior**:
- ✅ Identifies some issues
- ⚠️ May miss pagination or indexing
- ⚠️ Less comprehensive

---

## Architecture Redesign Questions

### Question 8: Migrate from Monolith to Microservices

**Interview Stage**: Architecture (40% probability)  
**Difficulty**: Principal  
**Time**: 45 minutes

#### Question

"BrandOS is currently a modular monolith. How would you migrate it to microservices? What's the strategy and what are the challenges?"

#### Ideal Answer

**Migration Strategy**:

**1. Identify Boundaries** (5 min)
- **Identity Service**: Authentication, authorization
- **Business Service**: Products, inventory, orders
- **Finance Service**: Payments, settlements, wallets
- **Analytics Service**: Reports, dashboards

**2. Database First** (10 min)
- Split databases before splitting services
- Keep foreign key references as integers (not actual FKs)
- Migrate data gradually

**3. Extract Services** (15 min)
- **Strangler Fig Pattern**: Gradually extract modules
- **Feature Flags**: Route traffic gradually
- **API Gateway**: Route to old or new service

**4. Challenges** (10 min)
- **Distributed Transactions**: Use saga pattern
- **Data Consistency**: Eventual consistency
- **Service Communication**: HTTP, message queue
- **Deployment**: Independent deployments
- **Testing**: Integration tests across services

**5. Migration Plan** (5 min)
- **Phase 1**: Extract Identity (2 months)
- **Phase 2**: Extract Business (3 months)
- **Phase 3**: Extract Finance (2 months)
- **Phase 4**: Extract Analytics (1 month)

**BrandOS Current State**:
```
BrandOS.API (Monolith)
├── Identity Module
├── Business Module
├── Finance Module
└── Analytics Module
```

**Target State**:
```
API Gateway
├── Identity Service
├── Business Service
├── Finance Service
└── Analytics Service
```

#### Evaluation Rubric

**Principal**:
- ✅ Identifies service boundaries
- ✅ Provides migration strategy
- ✅ Addresses challenges
- ✅ Gradual migration plan

**Senior**:
- ✅ Good technical design
- ⚠️ Less migration strategy
- ⚠️ May suggest big-bang migration

---

## Conclusion

### Key Takeaways

1. **System Design**: Clarify → Design → Scale → Failures → Tradeoffs
2. **Architecture**: Understand layers, dependencies, tradeoffs
3. **Distributed Systems**: Idempotency, consistency, fault tolerance
4. **Performance**: Identify bottlenecks, optimize, measure
5. **Incidents**: Diagnose systematically, fix immediately, prevent long-term
6. **Code Review**: N+1, pagination, indexing, error handling
7. **Migration**: Gradual, feature flags, measure impact

### Practice Strategy

1. **Practice System Design**: 2-3 questions per week
2. **Review BrandOS Code**: Understand real implementations
3. **Study Patterns**: Outbox, saga, circuit breaker
4. **Mock Interviews**: Practice with timer
5. **Review Mistakes**: Learn from weak answers

---

**Remember**: Principal engineers don't just know the answer. They explain tradeoffs, consider scale, handle failures, and think long-term.



