# FAANG-Level System Design: Backend Deep Dive
## BrandOS Edition - Principal Engineer Interview Preparation

> **Target**: Staff/Principal Backend Engineer interviews at FAANG, EU tech companies  
> **Focus**: Scalability, High Availability, Distributed Systems, Backend Architecture  
> **Format**: Complete system design walkthroughs with BrandOS examples

---

## Table of Contents

1. [System Design Interview Framework](#system-design-interview-framework)
2. [Design a Multi-Tenant SaaS Platform](#design-a-multi-tenant-saas-platform)
3. [Design a High-Throughput Event Processing System](#design-a-high-throughput-event-processing-system)
4. [Design a Scalable E-commerce Checkout System](#design-a-scalable-e-commerce-checkout-system)
5. [Design a Real-Time Analytics System](#design-a-real-time-analytics-system)
6. [Design a Distributed Caching Layer](#design-a-distributed-caching-layer)
7. [Design an Idempotent Payment System](#design-an-idempotent-payment-system)
8. [Design a Multi-Region System](#design-a-multi-region-system)
9. [Design a Rate Limiting System](#design-a-rate-limiting-system)
10. [Design a Search System](#design-a-search-system)

---

## System Design Interview Framework

### The 6-Step Process

**1. Clarify Requirements** (5 min)
- Functional requirements
- Non-functional requirements (scale, latency, availability)
- Constraints and assumptions

**2. High-Level Design** (10 min)
- Major components
- APIs
- Data flow

**3. Detailed Design** (20 min)
- Database schema
- Algorithms
- Component interactions

**4. Scale the System** (10 min)
- Identify bottlenecks
- Scaling strategies
- Load balancing
- Caching

**5. Handle Failures** (5 min)
- Single points of failure
- Failure scenarios
- Resilience patterns

**6. Tradeoffs & Alternatives** (5 min)
- What we chose and why
- Alternatives considered
- Future improvements

---

## Design a Multi-Tenant SaaS Platform

### Question

**"Design a multi-tenant SaaS platform like BrandOS that supports 10,000 tenants with 1M daily active users. Each tenant can have up to 10,000 users. The platform handles e-commerce, inventory, finance, and HR operations."**

### Step 1: Clarify Requirements

**Functional Requirements**:
- Multi-tenant isolation (data, configuration, features)
- User authentication and authorization
- E-commerce operations (orders, payments, inventory)
- Financial operations (settlements, wallets)
- HR operations (payroll, attendance)
- Analytics and reporting

**Non-Functional Requirements**:
- **Scale**: 10,000 tenants, 1M DAU
- **Latency**: < 200ms for 95% of requests
- **Availability**: 99.9% uptime (8.76 hours downtime/year)
- **Consistency**: Strong consistency for financial data, eventual for analytics
- **Security**: Complete tenant isolation, GDPR compliant

**Constraints**:
- Budget: $50K/month infrastructure
- Team: 10 engineers
- Timeline: 6 months to MVP

### Step 2: High-Level Design

```
┌─────────────────────────────────────────────────────────────┐
│                        Load Balancer                         │
│                    (AWS ALB / Cloudflare)                    │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
   ┌────▼────┐                  ┌────▼────┐
   │  API    │                  │  API    │
   │ Server  │                  │ Server  │
   │ (Zone 1)│                  │ (Zone 2)│
   └────┬────┘                  └────┬────┘
        │                             │
        └──────────────┬──────────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
   ┌────▼────┐                  ┌────▼────┐
   │  App    │                  │  App    │
   │ Server  │                  │ Server  │
   │ (Zone 1)│                  │ (Zone 2)│
   └────┬────┘                  └────┬────┘
        │                             │
        └──────────────┬──────────────┘
                       │
    ┌──────────────────┼──────────────────┐
    │                  │                  │
┌───▼───┐        ┌─────▼─────┐      ┌─────▼─────┐
│  DB   │        │   Redis   │      │ RabbitMQ │
│Primary│        │  Cluster  │      │ Cluster  │
└───┬───┘        └───────────┘      └──────────┘
    │
┌───▼───┐
│  DB   │
│Replica│
└───────┘
```

**Components**:
1. **Load Balancer**: Routes traffic, SSL termination
2. **API Servers**: Stateless .NET 8 applications
3. **Database**: PostgreSQL with read replicas
4. **Cache**: Redis cluster for hot data
5. **Message Queue**: RabbitMQ for async processing
6. **Background Jobs**: Process outbox, analytics, notifications

### Step 3: Detailed Design

#### 3.1 Multi-Tenancy Strategy

**Decision**: Hybrid approach (row-level + feature-based)

**Row-Level Security**:
```sql
-- All tenant-scoped tables have tenant_id
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    tenant_id INT NOT NULL,
    customer_id INT NOT NULL,
    total_amount DECIMAL(18,2),
    created_at TIMESTAMP,
    INDEX idx_tenant_id (tenant_id)
);

-- Global query filter (EF Core)
modelBuilder.Entity<Order>()
    .HasQueryFilter(o => o.TenantId == _tenantProvider.GetTenantId());
```

**Tenant Isolation Enforcement**:
```csharp
// TenantInterceptor ensures isolation at save time
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
```

**Why This Approach**:
- ✅ Cost-effective (single database)
- ✅ Easy cross-tenant analytics (for platform admin)
- ✅ Simple operations
- ⚠️ Application-level isolation (acceptable for most use cases)
- ✅ Can migrate large tenants to separate databases if needed

#### 3.2 Database Schema Design

**Sharding Strategy**: Shard by tenant_id for large tenants

```sql
-- Small tenants (< 10K users): Shared database
-- Large tenants (> 10K users): Separate database

-- Shard key calculation
shard_id = tenant_id % number_of_shards

-- For 10,000 tenants, 10 shards = 1,000 tenants per shard
```

**Schema Design Principles**:
1. **Normalize for consistency**: Financial data (3NF)
2. **Denormalize for performance**: Analytics tables (star schema)
3. **Partition by date**: Large tables (orders, events)
4. **Index strategically**: tenant_id + common query fields

**Example Schema**:
```sql
-- Orders table (partitioned by date)
CREATE TABLE orders_2024_01 (
    id BIGSERIAL,
    tenant_id INT NOT NULL,
    customer_id INT NOT NULL,
    total_amount DECIMAL(18,2),
    status VARCHAR(50),
    created_at TIMESTAMP,
    PRIMARY KEY (id, created_at),
    INDEX idx_tenant_created (tenant_id, created_at)
) PARTITION BY RANGE (created_at);

-- Inventory stock (hot data, needs fast access)
CREATE TABLE inventory_stocks (
    id SERIAL PRIMARY KEY,
    tenant_id INT NOT NULL,
    product_variant_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    quantity INT NOT NULL,
    reserved_quantity INT DEFAULT 0,
    INDEX idx_tenant_product (tenant_id, product_variant_id),
    INDEX idx_tenant_warehouse (tenant_id, warehouse_id)
);
```

#### 3.3 Caching Strategy

**Multi-Level Cache**:

**L1: In-Memory (Per Instance)**
```csharp
// Fast, but not shared across instances
private readonly MemoryCache _localCache = new();
```

**L2: Redis (Shared)**
```csharp
// Shared across all instances
// Cache keys: tenant:{tenantId}:permissions:{userId}
// TTL: 30 minutes
await _redis.SetAsync($"tenant:{tenantId}:permissions:{userId}", permissions, TimeSpan.FromMinutes(30));
```

**Cache Invalidation**:
```csharp
// When permissions change, invalidate cache
await _redis.RemoveAsync($"tenant:{tenantId}:permissions:{userId}");
```

**Cache-Aside Pattern**:
```csharp
public async Task<Permissions> GetPermissionsAsync(int userId)
{
    // 1. Check cache
    var cached = await _cache.GetAsync<Permissions>($"permissions:{userId}");
    if (cached != null) return cached;
    
    // 2. Fetch from database
    var permissions = await _db.Permissions.Where(p => p.UserId == userId).ToListAsync();
    
    // 3. Store in cache
    await _cache.SetAsync($"permissions:{userId}", permissions, TimeSpan.FromMinutes(30));
    
    return permissions;
}
```

#### 3.4 API Design

**RESTful APIs with Versioning**:
```
GET /api/v1/tenants/{tenantId}/orders
POST /api/v1/tenants/{tenantId}/orders
GET /api/v1/tenants/{tenantId}/orders/{orderId}
```

**Tenant Resolution**:
```csharp
// Middleware resolves tenant from:
// 1. Subdomain: tenant1.brandos.com
// 2. Header: X-Tenant-Id
// 3. JWT claim: tenant_id

public class TenantResolverMiddleware
{
    public async Task InvokeAsync(HttpContext context)
    {
        var tenantId = ResolveTenantId(context);
        context.Items["TenantId"] = tenantId;
        await _next(context);
    }
}
```

### Step 4: Scale the System

#### 4.1 Identify Bottlenecks

**At 1M DAU**:
- **Database**: 10,000 QPS (queries per second)
- **API Servers**: 50,000 RPS (requests per second)
- **Cache**: 100,000 ops/sec
- **Message Queue**: 5,000 messages/sec

#### 4.2 Scaling Strategies

**Database Scaling**:
1. **Read Replicas**: Route 80% of reads to replicas
   ```csharp
   // Read from replica
   var orders = await _readDb.Orders.Where(o => o.TenantId == tenantId).ToListAsync();
   
   // Write to primary
   await _writeDb.Orders.AddAsync(order);
   await _writeDb.SaveChangesAsync();
   ```

2. **Connection Pooling**: 100 connections per instance, 10 instances = 1,000 connections
   ```csharp
   // Connection string
   "Host=db;Database=brandos;Pooling=true;Maximum Pool Size=100"
   ```

3. **Query Optimization**:
   - Indexes on tenant_id + common filters
   - Compiled queries for hot paths
   - Pagination (limit 100 per page)

**Application Scaling**:
- **Horizontal Scaling**: Stateless design allows unlimited instances
- **Load Balancing**: Round-robin or least connections
- **Auto-scaling**: Scale based on CPU/memory (target: 70% CPU)

**Cache Scaling**:
- **Redis Cluster**: 3 masters, 3 replicas
- **Sharding**: Hash by key (Redis handles automatically)
- **Eviction Policy**: LRU (Least Recently Used)

**Message Queue Scaling**:
- **RabbitMQ Cluster**: 3 nodes
- **Queue Sharding**: Separate queues per tenant type
- **Consumer Scaling**: Multiple background job instances

#### 4.3 Load Balancing

**Strategy**: Application Load Balancer (ALB)

**Health Checks**:
```csharp
// Health endpoint
app.MapHealthChecks("/health", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready")
});
```

**Load Balancing Algorithm**:
- **Round Robin**: Simple, even distribution
- **Least Connections**: Better for long-lived connections
- **IP Hash**: Sticky sessions (if needed)

### Step 5: Handle Failures

#### 5.1 Single Points of Failure

**Database (SPOF)**:
- **Mitigation**: Read replicas + automated failover
- **Recovery**: Promote replica to primary (5-10 minutes)

**Cache (SPOF)**:
- **Mitigation**: Redis cluster (automatic failover)
- **Recovery**: Fail-open (return null, fetch from DB)

**Message Queue (SPOF)**:
- **Mitigation**: RabbitMQ cluster + outbox pattern
- **Recovery**: Events queued in outbox, processed when available

#### 5.2 Failure Scenarios

**Scenario 1: Database Primary Fails**
```
1. Health check detects failure
2. Promote read replica to primary (5 min)
3. Update connection strings
4. Application continues (some requests may fail during failover)
```

**Scenario 2: Cache Cluster Fails**
```
1. Cache requests return null
2. Application fetches from database (slower but works)
3. Alert team to investigate
4. Restore cache cluster
```

**Scenario 3: API Server Fails**
```
1. Load balancer health check fails
2. Traffic routed away from failed instance
3. Auto-scaling launches new instance (2-5 min)
4. Application continues
```

#### 5.3 Resilience Patterns

**Circuit Breaker**:
```csharp
// Prevent cascading failures
var circuitBreaker = Policy
    .Handle<Exception>()
    .CircuitBreakerAsync(
        handledEventsAllowedBeforeBreaking: 5,
        durationOfBreak: TimeSpan.FromSeconds(30)
    );

// Use circuit breaker
try
{
    return await circuitBreaker.ExecuteAsync(() => _externalService.CallAsync());
}
catch (BrokenCircuitException)
{
    // Return cached data or default
    return await _cache.GetAsync(key) ?? GetDefaultData();
}
```

**Retry with Exponential Backoff**:
```csharp
var retryPolicy = Policy
    .Handle<TransientException>()
    .WaitAndRetryAsync(
        retryCount: 3,
        sleepDurationProvider: retryAttempt => TimeSpan.FromSeconds(Math.Pow(2, retryAttempt))
    );
```

**Idempotency**:
```csharp
// Ensure operations can be safely retried
public async Task<Order> CreateOrderAsync(CreateOrderDto dto, string idempotencyKey)
{
    // Check if already processed
    var existing = await _idempotencyService.GetResponseAsync(idempotencyKey);
    if (existing != null)
    {
        return JsonSerializer.Deserialize<Order>(existing);
    }
    
    // Process order
    var order = await ProcessOrderAsync(dto);
    
    // Store result
    await _idempotencyService.MarkAsProcessedAsync(idempotencyKey, JsonSerializer.Serialize(order));
    
    return order;
}
```

### Step 6: Tradeoffs & Alternatives

#### 6.1 Multi-Tenancy Strategy

**Chosen**: Row-level security (shared database)

**Alternatives Considered**:
1. **Separate Databases**: Better isolation, but 10x cost
2. **Schema per Tenant**: PostgreSQL limitation (max 10,000 schemas)
3. **Hybrid**: Separate DBs for large tenants (future option)

**Why Chosen**:
- Cost-effective for current scale
- Sufficient isolation for most use cases
- Can evolve to separate DBs if needed

#### 6.2 Database Choice

**Chosen**: PostgreSQL

**Alternatives Considered**:
1. **MySQL**: Similar, but PostgreSQL has better JSON support
2. **MongoDB**: NoSQL, but need ACID for financial data
3. **DynamoDB**: Managed, but vendor lock-in

**Why Chosen**:
- ACID guarantees (critical for financial data)
- JSON support (flexible schema for tenant configs)
- Mature ecosystem
- Can scale with read replicas and sharding

#### 6.3 Caching Strategy

**Chosen**: Redis (cache-aside pattern)

**Alternatives Considered**:
1. **Memcached**: Simpler, but no persistence
2. **In-Memory**: Faster, but not shared across instances
3. **CDN**: For static data, but not for dynamic permissions

**Why Chosen**:
- Shared across instances
- Persistence (survives restarts)
- Rich data structures (sets, hashes, sorted sets)
- Cluster support

### Future Improvements

1. **Microservices**: Extract services when teams grow
2. **Event Sourcing**: Complete audit trail
3. **CQRS**: Separate read/write models for analytics
4. **GraphQL**: Flexible API for mobile clients
5. **Multi-Region**: Lower latency for global users

---

## Design a High-Throughput Event Processing System

### Question

**"Design a system to process 100,000 events per second from BrandOS. Events include order confirmations, inventory updates, payment receipts, and analytics events. The system must guarantee at-least-once delivery and support real-time analytics."**

### Step 1: Clarify Requirements

**Functional Requirements**:
- Process 100K events/sec
- Guarantee at-least-once delivery
- Support real-time analytics (dashboard updates)
- Support batch analytics (daily reports)
- Event replay for debugging

**Non-Functional Requirements**:
- **Latency**: < 100ms for real-time processing
- **Throughput**: 100K events/sec
- **Availability**: 99.9%
- **Durability**: Events must not be lost

**Constraints**:
- Events vary in size (100 bytes - 10KB)
- Some events are critical (payments), others are best-effort (analytics)

### Step 2: High-Level Design

```
┌─────────────┐
│  BrandOS    │
│  API        │
└──────┬──────┘
       │ Domain Events
       │
┌──────▼──────┐
│   Outbox    │
│   Table     │
└──────┬──────┘
       │
┌──────▼──────┐
│ Background  │
│   Job       │
└──────┬──────┘
       │
┌──────▼──────┐      ┌──────────────┐
│   Kafka     │─────▶│  Real-Time   │
│  Cluster    │      │  Processor   │
└──────┬──────┘      └──────────────┘
       │
       ├──────────────┐
       │              │
┌──────▼──────┐  ┌────▼─────┐
│  Analytics  │  │  Batch   │
│  Consumer   │  │ Consumer  │
└─────────────┘  └──────────┘
```

**Components**:
1. **Outbox Table**: Guarantees events are saved with business data
2. **Background Job**: Publishes events to Kafka
3. **Kafka Cluster**: High-throughput message broker
4. **Real-Time Processor**: Stream processing (Kafka Streams / Flink)
5. **Analytics Consumer**: Batch processing for reports
6. **Storage**: Time-series database (InfluxDB) for analytics

### Step 3: Detailed Design

#### 3.1 Event Schema

```json
{
  "eventId": "uuid",
  "eventType": "OrderConfirmed",
  "tenantId": 123,
  "occurredAt": "2024-01-15T10:30:00Z",
  "payload": {
    "orderId": 456,
    "customerId": 789,
    "totalAmount": 100.50
  },
  "metadata": {
    "correlationId": "uuid",
    "source": "BrandOS.API"
  }
}
```

#### 3.2 Kafka Topics

**Topic Strategy**: Separate topics by event type and priority

```
- orders-confirmed (high priority, 10 partitions)
- payments-received (high priority, 10 partitions)
- inventory-updates (medium priority, 5 partitions)
- analytics-events (low priority, 20 partitions)
```

**Partitioning**:
```csharp
// Partition by tenant_id for ordering
var partition = tenantId % numberOfPartitions;

// Ensures events from same tenant are processed in order
await _kafka.ProduceAsync(topic, partition, event);
```

#### 3.3 Processing Architecture

**Real-Time Processing (Kafka Streams)**:
```java
// Process events in real-time
KStream<String, Event> events = builder.stream("orders-confirmed");

events
    .filter((key, event) -> event.getTenantId() == targetTenant)
    .mapValues(event -> calculateMetrics(event))
    .to("analytics-realtime");
```

**Batch Processing (Kafka Consumer)**:
```csharp
// Process events in batches
var consumer = new KafkaConsumer<string, Event>(config);
consumer.Subscribe("analytics-events");

while (true)
{
    var batch = consumer.Consume(TimeSpan.FromSeconds(5));
    if (batch.Count > 0)
    {
        await ProcessBatchAsync(batch);
        consumer.Commit();
    }
}
```

#### 3.4 Guaranteed Delivery

**At-Least-Once Delivery**:
1. **Outbox Pattern**: Events saved in same transaction as business data
2. **Kafka Producer**: `acks=all` (wait for all replicas)
3. **Consumer**: Manual commit (only after processing)

**Idempotency**:
```csharp
// Check if event already processed
var processed = await _idempotencyStore.ExistsAsync(eventId);
if (processed) return; // Skip duplicate

// Process event
await ProcessEventAsync(event);

// Mark as processed
await _idempotencyStore.MarkAsProcessedAsync(eventId);
```

### Step 4: Scale the System

#### 4.1 Kafka Scaling

**Partitioning**: 100 partitions per topic
- 100K events/sec ÷ 100 partitions = 1K events/sec per partition
- Each partition can handle 10K events/sec → 10x headroom

**Replication**: 3 replicas per partition
- Tolerates 2 node failures
- High availability

**Consumer Groups**: Multiple consumers per topic
- Scale horizontally by adding consumers
- Each partition consumed by one consumer (ordering preserved)

#### 4.2 Processing Scaling

**Real-Time Processor**: Kafka Streams auto-scales
- Add more instances → more parallelism
- Stateful processing (windowed aggregations)

**Batch Processor**: Horizontal scaling
- Multiple consumer instances
- Each processes different partitions

### Step 5: Handle Failures

**Kafka Broker Failure**:
- 3 replicas → can lose 2 brokers
- Automatic leader election
- Consumers reconnect automatically

**Consumer Failure**:
- Rebalancing: partitions reassigned to other consumers
- At-least-once: may reprocess some events (idempotency handles this)

**Processing Failure**:
- Dead-letter queue for failed events
- Retry with exponential backoff
- Alert on high failure rate

### Step 6: Tradeoffs

**Chosen**: Kafka (distributed log)

**Alternatives**:
1. **RabbitMQ**: Simpler, but lower throughput (10K/sec)
2. **AWS Kinesis**: Managed, but vendor lock-in
3. **NATS**: Fast, but no persistence

**Why Kafka**:
- High throughput (1M+ events/sec)
- Durability (replicated logs)
- Ordering (per partition)
- Replay capability

---

## Design a Scalable E-commerce Checkout System

### Question

**"Design a checkout system for BrandOS that handles 10,000 concurrent checkouts during a flash sale. The system must prevent overselling, handle payment processing, and send order confirmations."**

### Step 1: Clarify Requirements

**Functional Requirements**:
- Add items to cart
- Calculate totals (with taxes, shipping)
- Reserve inventory (prevent overselling)
- Process payment
- Create order
- Send confirmation email

**Non-Functional Requirements**:
- **Scale**: 10,000 concurrent checkouts
- **Latency**: < 2 seconds end-to-end
- **Availability**: 99.9%
- **Consistency**: Strong (inventory, payments)

**Constraints**:
- Inventory must not oversell
- Payment must be processed exactly once
- Order must be created even if email fails

### Step 2: High-Level Design

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
┌──────▼──────┐
│  API Gateway│
└──────┬──────┘
       │
┌──────▼──────┐
│ Checkout    │
│   Service   │
└──────┬──────┘
       │
   ┌───┴───┐
   │       │
┌──▼──┐ ┌─▼───┐
│Cart │ │Inv  │
│Svc  │ │Svc  │
└──┬──┘ └─┬───┘
   │      │
┌──▼──────▼──┐
│  Database  │
└────────────┘
```

### Step 3: Detailed Design

#### 3.1 Inventory Reservation

**Problem**: Prevent overselling during flash sale

**Solution**: Optimistic locking with reservation

```csharp
public async Task<bool> ReserveInventoryAsync(int productVariantId, int quantity)
{
    using var transaction = await _db.BeginTransactionAsync();
    
    try
    {
        // Lock row for update
        var stock = await _db.InventoryStocks
            .Where(s => s.ProductVariantId == productVariantId)
            .FirstOrDefaultAsync();
        
        if (stock == null || stock.AvailableQuantity < quantity)
        {
            return false; // Out of stock
        }
        
        // Reserve inventory
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

**Alternative**: Pessimistic locking (SELECT FOR UPDATE)
- Slower but simpler
- Better for high contention

#### 3.2 Checkout Flow

**Saga Pattern** (distributed transaction):

```csharp
public async Task<Order> CheckoutAsync(CheckoutRequest request)
{
    var checkoutId = Guid.NewGuid();
    
    try
    {
        // Step 1: Reserve inventory
        var reserved = await ReserveInventoryAsync(request.Items);
        if (!reserved) throw new OutOfStockException();
        
        // Step 2: Calculate totals
        var totals = await CalculateTotalsAsync(request);
        
        // Step 3: Process payment
        var payment = await ProcessPaymentAsync(totals, request.PaymentMethod);
        if (!payment.Success) throw new PaymentFailedException();
        
        // Step 4: Create order
        var order = await CreateOrderAsync(request, payment);
        
        // Step 5: Send confirmation (async, don't fail if email fails)
        _ = Task.Run(() => SendConfirmationEmailAsync(order));
        
        return order;
    }
    catch (Exception)
    {
        // Compensating actions
        await ReleaseReservationAsync(checkoutId);
        await RefundPaymentAsync(checkoutId);
        throw;
    }
}
```

#### 3.3 Idempotency

**Problem**: Client retries → duplicate orders

**Solution**: Idempotency key

```csharp
public async Task<Order> CheckoutAsync(CheckoutRequest request, string idempotencyKey)
{
    // Check if already processed
    var existing = await _idempotencyService.GetResponseAsync(idempotencyKey);
    if (existing != null)
    {
        return JsonSerializer.Deserialize<Order>(existing);
    }
    
    // Process checkout
    var order = await ProcessCheckoutAsync(request);
    
    // Store result
    await _idempotencyService.MarkAsProcessedAsync(
        idempotencyKey, 
        JsonSerializer.Serialize(order)
    );
    
    return order;
}
```

### Step 4: Scale the System

**Database Sharding**: Shard by tenant_id
- 10,000 tenants → 10 shards = 1,000 tenants per shard
- Reduces contention

**Caching**: Cache inventory for hot products
- Redis cache with 1-second TTL
- Reduces database load

**Async Processing**: Move non-critical steps to background
- Email sending → background job
- Analytics → event stream

### Step 5: Handle Failures

**Inventory Reservation Fails**:
- Return error to user
- No compensating action needed (nothing reserved)

**Payment Fails**:
- Release inventory reservation
- Return error to user

**Order Creation Fails**:
- Refund payment
- Release inventory reservation
- Log error for manual review

**Email Fails**:
- Don't fail checkout (email is best-effort)
- Retry in background job
- Alert if retries fail

### Step 6: Tradeoffs

**Chosen**: Optimistic locking for inventory

**Alternatives**:
1. **Pessimistic Locking**: Simpler, but lower throughput
2. **Event Sourcing**: Complete audit trail, but more complex
3. **Separate Inventory Service**: Better isolation, but network calls

**Why Chosen**:
- Higher throughput (no locks held)
- Simpler implementation
- Good enough for current scale

---

## Design a Real-Time Analytics System

### Question

**"Design a real-time analytics system for BrandOS that processes 1M events per day and provides dashboard updates within 1 second of event occurrence."**

### Step 1: Clarify Requirements

**Functional Requirements**:
- Process 1M events/day (~12 events/sec average, 1000/sec peak)
- Real-time dashboard (revenue, orders, inventory)
- Historical analytics (daily, weekly, monthly reports)
- Multi-tenant isolation

**Non-Functional Requirements**:
- **Latency**: < 1 second for real-time updates
- **Throughput**: 1,000 events/sec peak
- **Retention**: 2 years of historical data

### Step 2: High-Level Design

```
┌─────────────┐
│   Events    │
└──────┬──────┘
       │
┌──────▼──────┐
│   Kafka     │
└──────┬──────┘
       │
   ┌───┴───┐
   │       │
┌──▼──┐ ┌─▼───┐
│Real │ │Batch│
│Time │ │Proc │
└──┬──┘ └─┬───┘
   │      │
┌──▼──────▼──┐
│ Time-Series│
│    DB      │
└────────────┘
```

### Step 3: Detailed Design

#### 3.1 Event Processing

**Real-Time Stream Processing** (Kafka Streams):
```java
// Aggregate events in 1-second windows
KStream<String, Event> events = builder.stream("analytics-events");

events
    .groupByKey()
    .windowedBy(TimeWindows.of(Duration.ofSeconds(1)))
    .aggregate(
        () -> new Metrics(),
        (key, event, aggregate) -> aggregate.add(event),
        Materialized.as("metrics-store")
    )
    .toStream()
    .to("realtime-metrics");
```

**Batch Processing** (Daily Aggregation):
```csharp
// Aggregate daily metrics
var dailyMetrics = await _db.AnalyticsEvents
    .Where(e => e.OccurredAt.Date == today)
    .GroupBy(e => e.TenantId)
    .Select(g => new DailyMetrics
    {
        TenantId = g.Key,
        TotalRevenue = g.Sum(e => e.Amount),
        OrderCount = g.Count()
    })
    .ToListAsync();
```

#### 3.2 Storage

**Time-Series Database** (InfluxDB):
```sql
-- Store metrics with tags for fast queries
INSERT INTO metrics,tenant_id=123,metric_type=revenue value=1000.50,time=2024-01-15T10:30:00Z

-- Query real-time metrics
SELECT SUM(value) FROM metrics 
WHERE tenant_id = '123' 
AND time >= now() - 1m
GROUP BY time(1s)
```

**Data Retention**:
- **Real-time**: 24 hours (InfluxDB)
- **Daily aggregates**: 2 years (PostgreSQL)
- **Raw events**: 30 days (Kafka), then archive to S3

#### 3.3 Dashboard API

**Caching Strategy**:
```csharp
// Cache real-time metrics for 1 second
var cacheKey = $"metrics:tenant:{tenantId}:realtime";
var metrics = await _cache.GetAsync<Metrics>(cacheKey);
if (metrics == null)
{
    metrics = await _timeSeriesDb.QueryAsync(/* real-time query */);
    await _cache.SetAsync(cacheKey, metrics, TimeSpan.FromSeconds(1));
}
return metrics;
```

### Step 4: Scale the System

**Kafka**: 10 partitions → 100 events/sec per partition
**Stream Processor**: Auto-scales with Kafka Streams
**Time-Series DB**: Shard by tenant_id

### Step 5: Handle Failures

**Event Loss**: At-least-once delivery (Kafka)
**Processing Failure**: Replay from Kafka
**Storage Failure**: Replicated InfluxDB cluster

### Step 6: Tradeoffs

**Chosen**: Kafka + InfluxDB

**Alternatives**:
1. **Elasticsearch**: Good for search, but slower for time-series
2. **ClickHouse**: Fast, but more complex
3. **PostgreSQL**: Simple, but not optimized for time-series

**Why Chosen**:
- Kafka: High throughput, replay capability
- InfluxDB: Optimized for time-series, fast queries

---

## Design a Distributed Caching Layer

### Question

**"Design a distributed caching layer for BrandOS that supports 100K cache operations per second with 99.9% availability and handles cache invalidation across multiple regions."**

### Step 1: Clarify Requirements

**Functional Requirements**:
- Get/Set operations
- TTL (time-to-live) support
- Cache invalidation
- Multi-region support

**Non-Functional Requirements**:
- **Throughput**: 100K ops/sec
- **Latency**: < 5ms for cache hits
- **Availability**: 99.9%
- **Consistency**: Eventual (acceptable for cache)

### Step 2: High-Level Design

```
┌─────────────┐
│  App (US)   │
└──────┬──────┘
       │
┌──────▼──────┐
│ Redis (US)  │◄───┐
└─────────────┘    │
                   │ Replication
┌─────────────┐    │
│  App (EU)   │    │
└──────┬──────┘    │
       │           │
┌──────▼──────┐    │
│ Redis (EU)  │────┘
└─────────────┘
```

### Step 3: Detailed Design

#### 3.1 Redis Cluster

**Architecture**: Redis Cluster (3 masters, 3 replicas)

**Sharding**: Hash slots (16,384 slots)
- Key → CRC16 → Slot → Node
- Automatic sharding and rebalancing

**Replication**: Each master has 1 replica
- Automatic failover (sentinel)
- High availability

#### 3.2 Cache Patterns

**Cache-Aside**:
```csharp
public async Task<T> GetAsync<T>(string key)
{
    // 1. Check cache
    var cached = await _redis.GetAsync<T>(key);
    if (cached != null) return cached;
    
    // 2. Fetch from database
    var value = await _db.QueryAsync<T>(key);
    
    // 3. Store in cache
    await _redis.SetAsync(key, value, TimeSpan.FromMinutes(30));
    
    return value;
}
```

**Write-Through**:
```csharp
public async Task SetAsync<T>(string key, T value)
{
    // 1. Write to database
    await _db.SaveAsync(key, value);
    
    // 2. Update cache
    await _redis.SetAsync(key, value, TimeSpan.FromMinutes(30));
}
```

**Write-Behind** (Async):
```csharp
public async Task SetAsync<T>(string key, T value)
{
    // 1. Update cache immediately
    await _redis.SetAsync(key, value);
    
    // 2. Write to database asynchronously
    _ = Task.Run(() => _db.SaveAsync(key, value));
}
```

#### 3.3 Cache Invalidation

**Strategy**: TTL + explicit invalidation

```csharp
// Set with TTL
await _redis.SetAsync(key, value, TimeSpan.FromMinutes(30));

// Explicit invalidation
await _redis.RemoveAsync(key);

// Pattern-based invalidation (for related keys)
var keys = await _redis.GetKeysAsync("tenant:123:*");
await _redis.RemoveAsync(keys);
```

**Multi-Region Invalidation**:
```csharp
// Publish invalidation event to all regions
await _messageBus.PublishAsync(new CacheInvalidationEvent
{
    Pattern = "tenant:123:*",
    Regions = new[] { "us", "eu", "asia" }
});

// Each region's cache service listens and invalidates
```

#### 3.4 Cache Warming

**Strategy**: Pre-populate cache for hot data

```csharp
// Warm cache on startup
public async Task WarmCacheAsync()
{
    var hotTenants = await _db.GetHotTenantsAsync();
    foreach (var tenant in hotTenants)
    {
        var permissions = await _db.GetPermissionsAsync(tenant.Id);
        await _redis.SetAsync($"permissions:tenant:{tenant.Id}", permissions);
    }
}
```

### Step 4: Scale the System

**Horizontal Scaling**: Add more Redis nodes
- 3 nodes → 6 nodes → 9 nodes
- Automatic rebalancing

**Connection Pooling**: 100 connections per app instance
- 10 instances × 100 connections = 1,000 connections
- Redis can handle 10K+ connections

### Step 5: Handle Failures

**Node Failure**: Automatic failover (sentinel promotes replica)
**Network Partition**: Redis Cluster handles (majority wins)
**Cache Miss**: Fetch from database (fail-open)

### Step 6: Tradeoffs

**Chosen**: Redis Cluster

**Alternatives**:
1. **Memcached**: Simpler, but no persistence
2. **Hazelcast**: Java-based, in-memory grid
3. **Aerospike**: Fast, but more complex

**Why Chosen**:
- Mature, battle-tested
- Rich data structures
- Persistence (survives restarts)
- Cluster support

---

## Design an Idempotent Payment System

### Question

**"Design a payment processing system for BrandOS that handles 1,000 payments per second, ensures idempotency, and prevents double-charging even if requests are retried."**

### Step 1: Clarify Requirements

**Functional Requirements**:
- Process payments (credit card, wallet, etc.)
- Idempotency (same request = same result)
- Prevent double-charging
- Refund support
- Payment status tracking

**Non-Functional Requirements**:
- **Throughput**: 1,000 payments/sec
- **Latency**: < 500ms
- **Availability**: 99.9%
- **Consistency**: Strong (financial data)

### Step 2: High-Level Design

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │ Idempotency Key
┌──────▼──────┐
│ Payment API │
└──────┬──────┘
       │
┌──────▼──────┐
│ Idempotency │
│   Service   │
└──────┬──────┘
       │
┌──────▼──────┐
│  Payment    │
│  Processor  │
└──────┬──────┘
       │
   ┌───┴───┐
   │       │
┌──▼──┐ ┌─▼───┐
│ DB  │ │PGW  │
└─────┘ └─────┘
```

### Step 3: Detailed Design

#### 3.1 Idempotency Implementation

**Idempotency Key**: Client-provided unique key per payment

```csharp
public async Task<PaymentResult> ProcessPaymentAsync(
    PaymentRequest request, 
    string idempotencyKey)
{
    // 1. Check if already processed
    var existing = await _idempotencyStore.GetAsync(idempotencyKey);
    if (existing != null)
    {
        // Return same result
        return JsonSerializer.Deserialize<PaymentResult>(existing.Response);
    }
    
    // 2. Process payment (with database transaction)
    using var transaction = await _db.BeginTransactionAsync();
    try
    {
        // Lock idempotency key (prevent concurrent processing)
        await _idempotencyStore.LockAsync(idempotencyKey);
        
        // Double-check (another request might have processed it)
        var doubleCheck = await _idempotencyStore.GetAsync(idempotencyKey);
        if (doubleCheck != null)
        {
            return JsonSerializer.Deserialize<PaymentResult>(doubleCheck.Response);
        }
        
        // Process payment
        var result = await _paymentGateway.ChargeAsync(request);
        
        // Store payment record
        var payment = new Payment
        {
            Id = result.PaymentId,
            Amount = request.Amount,
            Status = result.Status,
            IdempotencyKey = idempotencyKey
        };
        await _db.Payments.AddAsync(payment);
        await _db.SaveChangesAsync();
        
        // Store idempotency result
        await _idempotencyStore.StoreAsync(idempotencyKey, JsonSerializer.Serialize(result));
        
        await transaction.CommitAsync();
        return result;
    }
    catch (Exception)
    {
        await transaction.RollbackAsync();
        await _idempotencyStore.UnlockAsync(idempotencyKey);
        throw;
    }
}
```

#### 3.2 Idempotency Storage

**Database Table**:
```sql
CREATE TABLE idempotency_keys (
    idempotency_key VARCHAR(255) PRIMARY KEY,
    response TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    INDEX idx_expires_at (expires_at)
);

-- Cleanup expired keys (background job)
DELETE FROM idempotency_keys WHERE expires_at < NOW();
```

**Redis Cache** (for fast lookup):
```csharp
// Cache idempotency keys for 24 hours
await _redis.SetAsync(
    $"idempotency:{idempotencyKey}",
    response,
    TimeSpan.FromHours(24)
);
```

#### 3.3 Payment Gateway Integration

**Idempotency at Gateway Level**:
```csharp
// Payment gateway also supports idempotency
var charge = await _stripeClient.ChargeAsync(new ChargeRequest
{
    Amount = request.Amount,
    IdempotencyKey = idempotencyKey // Gateway-level idempotency
});
```

**Double Protection**:
1. **Application-level**: Our idempotency service
2. **Gateway-level**: Payment gateway's idempotency

### Step 4: Scale the System

**Database Sharding**: Shard idempotency table by key hash
- 10 shards → 100 payments/sec per shard

**Caching**: Redis for hot idempotency keys
- Reduces database load

**Async Processing**: Non-critical steps (notifications) → background jobs

### Step 5: Handle Failures

**Idempotency Check Fails**:
- Return error (don't process payment)
- Client retries with same key

**Payment Processing Fails**:
- Rollback transaction
- Unlock idempotency key
- Client can retry

**Gateway Timeout**:
- Check gateway status (webhook or polling)
- If charged, store result
- If not charged, allow retry

### Step 6: Tradeoffs

**Chosen**: Database + Redis for idempotency

**Alternatives**:
1. **Redis Only**: Faster, but not durable (data loss on restart)
2. **Database Only**: Durable, but slower
3. **Distributed Lock**: More complex, but better for high contention

**Why Chosen**:
- Redis: Fast lookup (99% of cases)
- Database: Durable storage (backup)
- Good balance of speed and durability

---

## Design a Multi-Region System

### Question

**"Design a multi-region deployment for BrandOS that serves users in US, EU, and Asia with < 100ms latency and 99.99% availability."**

### Step 1: Clarify Requirements

**Functional Requirements**:
- Serve users from 3 regions (US, EU, Asia)
- Data replication across regions
- Failover capability

**Non-Functional Requirements**:
- **Latency**: < 100ms (users served from nearest region)
- **Availability**: 99.99% (52 minutes downtime/year)
- **Consistency**: Eventual (acceptable for most data)

### Step 2: High-Level Design

```
        ┌─────────────┐
        │   CDN       │
        │ (Cloudflare)│
        └──────┬──────┘
               │
    ┌──────────┼──────────┐
    │          │          │
┌───▼───┐  ┌───▼───┐  ┌───▼───┐
│ US    │  │ EU    │  │ Asia  │
│ Region│  │Region │  │Region │
└───┬───┘  └───┬───┘  └───┬───┘
    │          │          │
    └──────────┼──────────┘
               │
        ┌──────▼──────┐
        │  Database   │
        │ Replication │
        └─────────────┘
```

### Step 3: Detailed Design

#### 3.1 Region Selection

**DNS-Based Routing** (GeoDNS):
```
us.brandos.com → US region (Oregon)
eu.brandos.com → EU region (Frankfurt)
asia.brandos.com → Asia region (Singapore)
```

**Load Balancer Routing**:
```csharp
// Route based on user's location
var region = GetUserRegion(httpContext);
var apiUrl = GetApiUrlForRegion(region);
```

#### 3.2 Data Replication

**Database Replication**: PostgreSQL streaming replication
- **Primary**: US region (writes)
- **Replicas**: EU, Asia regions (reads)

**Cache Replication**: Redis replication
- Each region has its own Redis
- Cache invalidation events propagated across regions

**File Storage**: S3 with CloudFront CDN
- Files stored in S3 (US region)
- CDN caches files globally

#### 3.3 Write Strategy

**Write to Primary**:
```csharp
// All writes go to primary (US region)
var order = await _writeDb.Orders.AddAsync(order);
await _writeDb.SaveChangesAsync();

// Replication propagates to other regions (async)
```

**Read from Nearest**:
```csharp
// Read from local replica
var orders = await _readDb.Orders
    .Where(o => o.TenantId == tenantId)
    .ToListAsync();
```

#### 3.4 Failover

**Automatic Failover**:
1. Health check detects primary failure
2. Promote replica to primary (EU or Asia)
3. Update DNS to point to new primary
4. Application continues (some latency during failover)

**Manual Failover** (for maintenance):
1. Promote replica to primary
2. Update connection strings
3. Application switches to new primary

### Step 4: Scale the System

**Each Region**: Independent scaling
- US: 10 instances
- EU: 5 instances
- Asia: 5 instances

**Database**: Read replicas in each region
- Reduces cross-region latency

### Step 5: Handle Failures

**Region Failure**:
- Traffic routed to other regions
- Slight latency increase
- Automatic failover

**Database Primary Failure**:
- Promote replica to primary
- Update connection strings
- Application continues

### Step 6: Tradeoffs

**Chosen**: Active-Passive (primary in US, replicas in EU/Asia)

**Alternatives**:
1. **Active-Active**: All regions accept writes (complex conflict resolution)
2. **Multi-Master**: All regions are primaries (very complex)

**Why Chosen**:
- Simpler (single source of truth)
- Strong consistency
- Good enough for current scale

---

## Design a Rate Limiting System

### Question

**"Design a rate limiting system for BrandOS that prevents abuse, supports different limits per tenant, and handles 100K requests per second."**

### Step 1: Clarify Requirements

**Functional Requirements**:
- Rate limit by IP (100 req/min)
- Rate limit by tenant (1000 req/min)
- Rate limit by user (500 req/min)
- Different limits for different endpoints

**Non-Functional Requirements**:
- **Throughput**: 100K requests/sec
- **Latency**: < 5ms overhead
- **Accuracy**: Token bucket algorithm

### Step 2: High-Level Design

```
┌─────────────┐
│   Request   │
└──────┬──────┘
       │
┌──────▼──────┐
│ Rate Limit  │
│ Middleware  │
└──────┬──────┘
       │
┌──────▼──────┐
│   Redis     │
│  (Counter)  │
└─────────────┘
```

### Step 3: Detailed Design

#### 3.1 Token Bucket Algorithm

**Implementation**:
```csharp
public async Task<bool> CheckRateLimitAsync(string key, int limit, int windowSeconds)
{
    var redisKey = $"ratelimit:{key}";
    var db = _redis.GetDatabase();
    
    // Increment counter
    var current = await db.StringIncrementAsync(redisKey);
    
    // Set expiry on first request
    if (current == 1)
    {
        await db.KeyExpireAsync(redisKey, TimeSpan.FromSeconds(windowSeconds));
    }
    
    // Check if over limit
    return current <= limit;
}
```

**Sliding Window** (more accurate):
```csharp
public async Task<bool> CheckRateLimitSlidingWindowAsync(string key, int limit, int windowSeconds)
{
    var now = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
    var windowStart = now - windowSeconds;
    
    var redisKey = $"ratelimit:{key}";
    var db = _redis.GetDatabase();
    
    // Remove old entries
    await db.SortedSetRemoveRangeByScoreAsync(redisKey, 0, windowStart);
    
    // Count current window
    var count = await db.SortedSetLengthAsync(redisKey);
    
    if (count >= limit)
    {
        return false; // Over limit
    }
    
    // Add current request
    await db.SortedSetAddAsync(redisKey, now, now);
    await db.KeyExpireAsync(redisKey, TimeSpan.FromSeconds(windowSeconds));
    
    return true;
}
```

#### 3.2 Multi-Level Rate Limiting

**IP-Level**:
```csharp
var ipKey = $"ratelimit:ip:{ipAddress}";
var allowed = await CheckRateLimitAsync(ipKey, 100, 60); // 100 req/min
```

**Tenant-Level**:
```csharp
var tenantKey = $"ratelimit:tenant:{tenantId}";
var allowed = await CheckRateLimitAsync(tenantKey, 1000, 60); // 1000 req/min
```

**User-Level**:
```csharp
var userKey = $"ratelimit:user:{userId}";
var allowed = await CheckRateLimitAsync(userKey, 500, 60); // 500 req/min
```

**Endpoint-Level**:
```csharp
var endpointKey = $"ratelimit:endpoint:{endpoint}:{tenantId}";
var allowed = await CheckRateLimitAsync(endpointKey, endpointLimit, 60);
```

#### 3.3 Rate Limit Headers

**Response Headers**:
```csharp
context.Response.Headers.Add("X-RateLimit-Limit", "1000");
context.Response.Headers.Add("X-RateLimit-Remaining", "950");
context.Response.Headers.Add("X-RateLimit-Reset", resetTime.ToString());
```

### Step 4: Scale the System

**Redis Cluster**: Distribute rate limit keys across cluster
- Automatic sharding
- High throughput

**Local Cache**: Cache rate limit status (1 second TTL)
- Reduces Redis load
- Faster responses

### Step 5: Handle Failures

**Redis Failure**: Fail-open (allow requests)
- Rate limiting is protection, not critical path
- Log warning for monitoring

### Step 6: Tradeoffs

**Chosen**: Token bucket with Redis

**Alternatives**:
1. **Fixed Window**: Simpler, but less accurate
2. **Leaky Bucket**: Different algorithm, similar results
3. **In-Memory**: Faster, but not shared across instances

**Why Chosen**:
- Accurate (sliding window)
- Shared across instances (Redis)
- Fast (Redis is fast)

---

## Conclusion

### Key Takeaways

1. **Always Clarify**: Ask questions before designing
2. **Think in Scale**: Design for 10x-100x growth
3. **Handle Failures**: Assume everything will fail
4. **Make Tradeoffs Explicit**: Document why, not just what
5. **Start Simple**: Evolve complexity as needed

### Practice Questions

1. Design a search system for BrandOS products
2. Design a notification system (email, SMS, push)
3. Design a file upload system (S3, CDN)
4. Design a real-time collaboration feature
5. Design a recommendation system

---

**Remember**: System design interviews test your ability to think through complex problems, not memorize solutions. Focus on the process, not the answer.



