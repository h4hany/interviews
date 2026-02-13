# FAANG Interview Preparation Kit
## Staff / Principal Backend Engineer

**Candidate:** Hany Sayed Ahmed  
**Focus:** Distributed Systems, Backend, AI Platforms, Performance, Scalability  
**Experience:** 10+ Years  
**Specialization:** AI/ML, Vector Search, Recommendation Engines, High-Performance Systems

---

## Table of Contents
1. [Tell Me About Yourself](#1-tell-me-about-yourself)
2. [System Design - Search Engines](#2-system-design---search-engines)
3. [System Design - AI Recommendation Platform](#3-system-design---ai-recommendation-platform)
4. [Distributed Systems](#4-distributed-systems)
5. [Database & Performance Optimization](#5-database--performance-optimization)
6. [AI/LLM Systems](#6-aillm-systems)
7. [Leadership & Staff Engineering](#7-leadership--staff-engineering)
8. [Coding & Algorithms](#8-coding--algorithms)
9. [Behavioral Questions](#9-behavioral-questions)
10. [Bar Raiser - Deep Technical](#10-bar-raiser---deep-technical)

---

## 1. Tell Me About Yourself

### Q: Tell me about yourself.

**Answer:**

I'm a Staff Software Engineer with over 10 years of experience building scalable backend and AI-driven systems. My core strength is designing high-performance distributed architectures that balance scalability, latency, and cost.

**Recent Impact:**
- Architected a production recommendation engine using OpenAI embeddings and hybrid vector + SQL search that achieved **sub-100ms latency** while reducing AI API usage by **80%** through multi-layer caching
- Initiated migration to Ollama LLM, targeting **<1s inference latency** and **50% cost reduction**
- Optimized PostgreSQL queries and caching, reducing total query time by **40-50%** under heavy load

**Technical Leadership:**
- Lead architecture decisions for AI/ML systems including vector search, embeddings, and LLM workflows
- Mentor engineers and design systems for long-term scalability
- Translate product roadmaps into reliable technical execution

I'm particularly interested in solving large-scale distributed systems and AI infrastructure challenges at FAANG level, where I can leverage my experience in performance optimization, cost efficiency, and building production-grade recommendation engines.

---

## 2. System Design - Search Engines

### Q: Design a global search engine like Google. How do you rank results?

**Answer:**

Ranking is a **multi-stage pipeline** that balances speed and accuracy:

**Stage 1: Candidate Retrieval (Fast & Broad)**
- Use **inverted index** with BM25/TF-IDF for fast scoring
- Retrieve top **1k-10k documents** per query
- Parallel querying across sharded indexes
- Early termination for common queries

**Stage 2: Primary Ranking (Signal Combination)**
Combine multiple signals:
- **Text relevance**: BM25 score + semantic similarity
- **Popularity signals**: CTR, click-through rates, engagement metrics
- **Freshness**: Time-decay factors for recent content
- **Geo proximity**: Location-based relevance (Haversine distance)
- **Content quality**: Domain authority, spam scores
- **Personalization**: User history, preferences

**Stage 3: Re-Ranking (ML-Based)**
- **Learning-to-rank model** (LambdaMART, XGBoost)
- **Neural re-ranking** for semantic understanding
- **Diversity & deduplication**: Ensure variety in results
- **Business rules**: Boost certain content types

**Key Insight:** Use cheap ranking first (BM25), expensive ranking later (ML). This allows us to process billions of queries efficiently.

---

### Q: How do you shard the index?

**Answer:**

**Document-Based Sharding with Consistent Hashing:**

```
hash(doc_id) → shard_id
```

**Benefits:**
- **Even distribution** across shards
- **Automatic rebalancing** when adding/removing shards
- **Query fanout**: Send query to all shards in parallel
- **Merge top-K results** centrally (e.g., merge top 100 from each shard, then re-rank)

**Replication Strategy:**
- Each shard has **3 replicas** for availability
- Read from replicas for load distribution
- Write to primary, replicate asynchronously

**Scaling:**
- Add shards → rebalance using consistent hashing
- No need to rehash all documents, only affected range

---

### Q: How do you avoid hot shards?

**Answer:**

**Prevention:**
1. **Consistent hashing** ensures even distribution
2. **Shard replication** + load balancing across replicas
3. **Cache popular queries** at load balancer level

**Detection:**
- Monitor **QPS, latency, CPU** per shard
- Alert on skew (e.g., shard handling 2x average traffic)

**Remediation:**
1. **Split overloaded shard**: Create new shard, redistribute documents
2. **Dynamic rebalancing**: Move documents during low-traffic periods
3. **Query-level caching**: Cache results for popular queries
4. **Read replicas**: Route reads to less-loaded replicas

**Example:** If "iPhone" queries hit one shard, we can:
- Cache results at CDN/edge
- Split the shard by document type or time range
- Use read replicas for load distribution

---

### Q: How do you handle billions of documents?

**Answer:**

**Distributed Architecture:**
- **Sharded index** across many nodes (hundreds to thousands)
- **Parallel shard querying**: Query all shards simultaneously
- **Merge results** centrally

**Storage Optimization:**
- **Posting list compression**: Delta encoding, variable-byte encoding
- **Tiered storage**: Hot index in RAM, warm in SSD, cold on disk
- **Segment merge & compaction**: Combine small segments, remove deleted docs

**Indexing Strategy:**
- **Incremental indexing**: Update only changed documents
- **Batch updates**: Process updates in batches for efficiency
- **Lazy loading**: Load segments on-demand

**Fault Tolerance:**
- **Replication**: 3x replication for availability
- **Health checks**: Automatic failover to replicas
- **Data redundancy**: Multiple data centers

**Example Scale:**
- 1B documents × 1KB avg = 1TB raw data
- With compression: ~200GB index
- 100 shards = 2GB per shard (fits in RAM)
- Query latency: <100ms with proper caching

---

### Q: Query latency optimization?

**Answer:**

**Target: <100ms p99 latency**

**Strategies:**

1. **Caching**
   - Query result cache (Redis/Memcached)
   - Popular query cache at edge (CDN)
   - Embedding cache for semantic search

2. **Parallel Processing**
   - Parallel shard search
   - Early termination (stop after finding enough results)
   - Skip lists for fast range queries

3. **Approximate Search**
   - ANN (Approximate Nearest Neighbor) for vector search
   - HNSW index for fast similarity search
   - Trade 5% accuracy for 10x speed

4. **Index Optimization**
   - Keep hot index in memory
   - Vector indexes (pgvector) for semantic search
   - Inverted index compression

5. **Query Optimization**
   - Two-stage ranking (fast → accurate)
   - Query normalization (lowercase, stemming)
   - Adaptive timeout (fail fast for slow shards)

6. **Infrastructure**
   - Edge caching (CloudFlare, CloudFront)
   - Read replicas for load distribution
   - Connection pooling

**Real Example:**
- Without optimization: 500ms p99
- With caching + parallel search: 80ms p99
- With ANN + edge cache: 50ms p99

---

## 3. System Design - AI Recommendation Platform

### Q: Design a large-scale recommendation system.

**Answer:**

**Architecture Overview:**

**Offline Pipeline (Batch Processing)**
1. **Data Ingestion**: User interactions, content metadata, ratings
2. **Feature Engineering**: User embeddings, content embeddings, interaction features
3. **Embedding Generation**: Generate embeddings for users and content (OpenAI, custom models)
4. **Model Training**: Train recommendation models (collaborative filtering, deep learning)
5. **Batch Ranking**: Pre-compute top-K recommendations for each user
6. **Feature Store**: Store features for online serving

**Online Serving (Real-Time)**
1. **Candidate Retrieval**: 
   - Vector search (ANN) for semantic similarity
   - Collaborative filtering (user-based, item-based)
   - Content-based filtering
2. **Hybrid Ranking**: 
   - Combine semantic similarity + business signals (ratings, reviews, popularity)
   - Weighted aggregation of multiple signals
3. **Re-Ranking**: 
   - Personalization based on user history
   - Diversity (avoid similar items)
   - Business rules (boost new items, trending)
4. **Caching**: 
   - Cache embeddings (TTL-based)
   - Cache results (user-specific, popular items)
   - Multi-tier caching (L1: in-memory, L2: Redis)

**Scaling Components:**
- **Sharded vector DB**: Distribute vectors across nodes (pgvector, Pinecone, Weaviate)
- **Async embedding pipeline**: Generate embeddings in background (Sidekiq, Celery)
- **Multi-tier caching**: Embedding cache → Result cache → CDN
- **Feature store**: Real-time feature serving (Feast, Tecton)

**A/B Testing:**
- Test different ranking algorithms
- Measure CTR, engagement, revenue
- Gradual rollout (1% → 10% → 100%)

---

### Q: How do you balance latency vs accuracy?

**Answer:**

**Two-Stage Retrieval:**
1. **Fast retrieval** (10-20ms): Use approximate vector search (HNSW) to get top 1000 candidates
2. **Accurate ranking** (50-80ms): Re-rank top 100 with exact similarity + business signals

**Approximate Search:**
- Use **HNSW** (Hierarchical Navigable Small World) for fast ANN
- Trade 2-5% accuracy for 10x speed improvement
- Tune recall@K (e.g., recall@100 = 95%)

**Precomputed Embeddings:**
- Generate embeddings offline, store in vector DB
- Update embeddings incrementally (daily/hourly)
- Avoid real-time embedding generation

**Async Enrichment:**
- Return initial results quickly (50ms)
- Enrich with additional signals asynchronously
- Update UI progressively

**Caching Strategy:**
- Cache heavy queries (popular items, trending)
- Cache embeddings (TTL-based invalidation)
- Cache results (user-specific, time-based)

**Model Selection:**
- Use smaller models for latency-critical paths
- Use larger models for accuracy-critical paths
- Hybrid: small model for retrieval, large model for ranking

**Real Example:**
- Without optimization: 500ms, 95% accuracy
- With two-stage + caching: 80ms, 93% accuracy
- Trade-off: 2% accuracy loss for 6x speed improvement

---

## 4. Distributed Systems (Staff Level)

### Q: How do you design for 100M+ users?

**Answer:**

**Horizontal Scaling:**
- **Stateless services**: No server-side session storage
- **Load balancing**: Round-robin, least connections, geographic routing
- **Auto-scaling**: Scale based on CPU, memory, request rate

**Data Sharding:**
- **User-based sharding**: hash(user_id) → shard
- **Consistent hashing**: Easy to add/remove shards
- **Cross-shard queries**: Use aggregation layer or denormalization

**Caching Strategy:**
- **Multi-layer caching**: 
  - L1: Application cache (in-memory)
  - L2: Distributed cache (Redis cluster)
  - L3: CDN (static content, API responses)
- **Cache invalidation**: TTL-based, event-based, version-based

**Async Processing:**
- **Message queues**: RabbitMQ, Kafka for async tasks
- **Background jobs**: Sidekiq, Celery for heavy processing
- **Event-driven architecture**: Decouple services

**Observability:**
- **Metrics**: Prometheus, Datadog (QPS, latency, error rate)
- **Logging**: Centralized logging (ELK stack)
- **Tracing**: Distributed tracing (Jaeger, Zipkin)
- **Alerting**: PagerDuty, Opsgenie

**Failover & Replication:**
- **Database replication**: Master-slave, multi-region
- **Service replication**: Multiple instances per region
- **Circuit breakers**: Fail fast, prevent cascading failures

**Backpressure Control:**
- **Rate limiting**: Per user, per IP, per endpoint
- **Queue buffering**: Handle traffic spikes
- **Graceful degradation**: Return partial results if services are slow

---

### Q: Prevent cascading failures?

**Answer:**

**Circuit Breaker Pattern:**
- **Open state**: Fail fast, don't call downstream service
- **Half-open state**: Test if service recovered
- **Closed state**: Normal operation
- **Threshold**: Open after 5 failures in 1 minute

**Retry with Exponential Backoff:**
- **Initial delay**: 100ms
- **Max delay**: 5s
- **Max retries**: 3
- **Jitter**: Add randomness to avoid thundering herd

**Bulkhead Isolation:**
- **Separate thread pools** for different services
- **Resource limits**: CPU, memory per service
- **Isolation**: Failure in one service doesn't affect others

**Rate Limiting:**
- **Per service**: Limit requests to downstream services
- **Per user**: Limit requests per user
- **Token bucket**: Allow bursts, limit average rate

**Queue Buffering:**
- **Message queues**: Buffer requests during spikes
- **Backpressure**: Reject requests when queue is full
- **Priority queues**: Process critical requests first

**Graceful Degradation:**
- **Fallback responses**: Return cached data or default values
- **Partial results**: Return what's available, mark missing data
- **Feature flags**: Disable non-critical features during outages

**Health Checks:**
- **Liveness probes**: Is service running?
- **Readiness probes**: Is service ready to serve?
- **Startup probes**: Is service starting up?

**Example:**
- Service A calls Service B
- Service B is slow (500ms → 5s)
- Circuit breaker opens after 5 failures
- Service A returns cached data or default response
- Service B recovers → circuit breaker closes

---

### Q: How do you design idempotent systems?

**Answer:**

**Idempotency Keys:**
- **Request ID**: Client generates unique ID per request
- **Store in database**: Check if request ID exists before processing
- **Return same response**: If request ID exists, return previous response

**Implementation:**

```ruby
def process_payment(request_id, amount)
  # Check if request already processed
  existing = Payment.find_by(request_id: request_id)
  return existing if existing
  
  # Process payment
  payment = Payment.create!(
    request_id: request_id,
    amount: amount,
    status: 'completed'
  )
  
  payment
end
```

**Deduplication Store:**
- **Redis**: Store request IDs with TTL (e.g., 24 hours)
- **Database**: Store request IDs in dedicated table
- **Bloom filter**: Probabilistic check (memory-efficient)

**Idempotent Writes:**
- **Upsert operations**: INSERT ... ON CONFLICT DO UPDATE
- **Versioned updates**: Check version before update
- **Optimistic locking**: Fail if version changed

**Safe Retries:**
- **Idempotent operations**: Safe to retry (GET, PUT, DELETE)
- **Non-idempotent operations**: Use idempotency keys (POST)
- **Idempotency in APIs**: Return same response for same request

**Example:**
- Client sends payment request with ID: "pay-123"
- Server processes payment, stores ID
- Client retries with same ID → Server returns existing payment
- No duplicate charges

---

## 5. Database & Performance (Based on Your CV)

### Q: How do you optimize database performance?

**Answer:**

**Indexing Strategy:**
- **B-tree indexes**: For equality and range queries
- **Hash indexes**: For equality queries only
- **Vector indexes**: pgvector for semantic search (HNSW, IVFFlat)
- **Composite indexes**: For multi-column queries
- **Partial indexes**: For filtered queries

**Query Optimization:**
- **Remove N+1 queries**: Use eager loading (includes, joins)
- **Query profiling**: Use EXPLAIN ANALYZE to identify bottlenecks
- **CTEs & UNION optimization**: Use UNION ALL instead of UNION
- **Parallel queries**: Enable parallel execution for large scans
- **Query result caching**: Cache expensive queries

**Database Design:**
- **Normalization**: Reduce redundancy (3NF)
- **Denormalization**: Trade storage for speed (read-heavy workloads)
- **Partitioning**: Partition large tables by date, region
- **Connection pooling**: Reuse connections (PgBouncer)

**Async Processing:**
- **Background jobs**: Move heavy processing to background (Sidekiq)
- **Batch processing**: Process multiple records in single query
- **Read replicas**: Route reads to replicas, writes to primary

**Real Example:**
- **Before**: 1000ms query time, N+1 queries
- **After**: 500ms query time, eager loading, proper indexes
- **Result**: 50% performance improvement

---

### Q: How did you reduce cost by 80%?

**Answer:**

**Multi-Tier Caching Strategy:**

1. **Embedding Cache** (L1):
   - Cache embeddings for content (TTL: 7 days)
   - Cache embeddings for queries (TTL: 1 day)
   - **Impact**: 70% of queries hit cache → 70% cost reduction

2. **Result Cache** (L2):
   - Cache search results for popular queries (TTL: 1 hour)
   - Cache user-specific recommendations (TTL: 30 min)
   - **Impact**: 20% additional cost reduction

3. **AI Output Cache** (L3):
   - Cache LLM outputs for similar prompts
   - Cache brand analysis, sentiment analysis results
   - **Impact**: 10% additional cost reduction

**Token Optimization:**
- **Prompt compression**: Remove unnecessary context
- **Structured outputs**: Use JSON mode to reduce token usage
- **Batch processing**: Process multiple items in single API call

**Embedding Reuse:**
- Reuse embeddings across different use cases
- Store embeddings in vector DB (pgvector)
- Update embeddings incrementally (not full regeneration)

**TTL Strategy:**
- Short TTL for dynamic content (1 hour)
- Long TTL for static content (7 days)
- Version-based invalidation for content updates

**Result:**
- Before: 1000 API calls/day × $0.10 = $100/day
- After: 200 API calls/day × $0.10 = $20/day
- **80% cost reduction**

---

## 6. AI / LLM Systems (Your Advantage)

### Q: Design semantic search at scale.

**Answer:**

**Architecture:**

**Embedding Pipeline:**
1. **Content ingestion**: Collect documents, products, user queries
2. **Embedding generation**: Use OpenAI text-embedding-3-large or custom models
3. **Embedding storage**: Store in vector database (pgvector, Pinecone)
4. **Incremental updates**: Update embeddings when content changes

**Vector Index:**
- **HNSW (Hierarchical Navigable Small World)**: Fast approximate search
- **IVFFlat**: Faster indexing, slower search
- **Index parameters**: Tune for recall vs speed trade-off

**Hybrid Search:**
- **Keyword search**: BM25/TF-IDF for exact matches
- **Semantic search**: Vector similarity for meaning
- **Combined ranking**: Weighted combination of both scores
- **Example**: 70% semantic + 30% keyword

**Ranking Layer:**
- **Cosine similarity**: Measure vector similarity
- **Business signals**: Boost by ratings, popularity, freshness
- **Personalization**: Adjust based on user history
- **Diversity**: Ensure variety in results

**Caching:**
- **Embedding cache**: Cache embeddings for content (TTL: 7 days)
- **Query cache**: Cache results for popular queries (TTL: 1 hour)
- **Multi-tier**: L1 (in-memory) → L2 (Redis) → L3 (CDN)

**Scaling:**
- **Sharded vector DB**: Distribute vectors across nodes
- **Async indexing**: Generate embeddings in background
- **Read replicas**: Scale reads independently

**Example:**
- Query: "affordable running shoes"
- Keyword search: Finds "running", "shoes"
- Semantic search: Finds "sneakers", "athletic footwear"
- Combined: Returns most relevant results

---

### Q: How do you optimize LLM cost & latency?

**Answer:**

**Token Optimization:**
- **Prompt compression**: Remove unnecessary context
- **Structured outputs**: Use JSON mode to reduce tokens
- **Few-shot examples**: Use minimal examples
- **System prompts**: Keep system prompts concise

**Prompt Engineering:**
- **Clear instructions**: Reduce ambiguity, fewer follow-up questions
- **Output format**: Specify exact format (JSON, markdown)
- **Temperature**: Lower temperature for consistent outputs

**Embedding Reuse:**
- **Cache embeddings**: Don't regenerate for same content
- **Batch processing**: Process multiple items in single call
- **Incremental updates**: Only update changed content

**Caching Outputs:**
- **Cache LLM outputs**: For similar prompts, return cached result
- **TTL-based invalidation**: Invalidate after time period
- **Version-based invalidation**: Invalidate when content changes

**Model Selection:**
- **Smaller models**: Use GPT-4o-mini for simple tasks
- **Larger models**: Use GPT-4 for complex tasks
- **Local LLM fallback**: Use Ollama for cost-sensitive operations

**Batch Inference:**
- **Process multiple items**: Reduce API calls
- **Parallel requests**: Send multiple requests concurrently
- **Rate limiting**: Respect API rate limits

**Real Example:**
- **Before**: 1000 prompts/day × $0.10 = $100/day
- **After**: 200 prompts/day (80% cache hit) × $0.10 = $20/day
- **80% cost reduction**

---

## 7. Leadership & Staff Signals

### Q: Describe a major technical decision you led.

**Answer:**

**Context:**
I led the redesign of a recommendation engine that was experiencing high latency (500ms) and high API costs ($100/day).

**Decision:**
Introduced a hybrid search architecture combining vector similarity with SQL queries, implemented multi-tier caching, and optimized database queries.

**Implementation:**
1. **Hybrid Search**: Combined OpenAI embeddings with PostgreSQL pgvector for semantic search, plus SQL queries for exact matches
2. **Multi-Tier Caching**: 
   - L1: Embedding cache (TTL: 7 days)
   - L2: Result cache (TTL: 1 hour)
   - L3: AI output cache
3. **Query Optimization**: Eager loading, vector indexing, parallel queries, CTEs

**Results:**
- **Latency**: Reduced from 500ms → 80ms (84% improvement)
- **Cost**: Reduced from $100/day → $20/day (80% reduction)
- **Scalability**: Handled 10x traffic increase without issues

**Lessons Learned:**
- Caching is critical for cost optimization
- Hybrid approaches balance accuracy and speed
- Incremental rollout reduces risk

---

### Q: How do you grow engineers?

**Answer:**

**Mentoring:**
- **1-on-1 sessions**: Weekly check-ins, career discussions
- **Code reviews**: Provide constructive feedback, explain patterns
- **Pair programming**: Work together on complex problems

**Architecture Guidance:**
- **Design reviews**: Review system designs before implementation
- **Best practices**: Share patterns, anti-patterns
- **Technology decisions**: Involve engineers in tech choices

**Encourage Ownership:**
- **Own features end-to-end**: From design to deployment
- **Own incidents**: Lead post-mortems, drive improvements
- **Own metrics**: Track and improve system metrics

**Break Down Complex Problems:**
- **Decompose large tasks**: Break into smaller, manageable pieces
- **Incremental delivery**: Ship value continuously
- **Risk mitigation**: Identify and address risks early

**Growth Opportunities:**
- **Stretch assignments**: Assign challenging but achievable tasks
- **Conference talks**: Encourage sharing knowledge
- **Open source**: Contribute to projects

**Example:**
- Junior engineer struggled with system design
- Provided architecture guidance, code reviews
- Assigned ownership of a feature
- Engineer grew to lead similar features independently

---

### Q: How do you design systems for 10 years?

**Answer:**

**Extensible Architecture:**
- **Modular design**: Separate concerns, clear interfaces
- **Plugin architecture**: Easy to add new features
- **API versioning**: Support multiple API versions

**Versioning:**
- **API versioning**: v1, v2, v3 with backward compatibility
- **Data versioning**: Version schemas, migrations
- **Feature flags**: Gradual rollout, easy rollback

**Backward Compatibility:**
- **Deprecation strategy**: Announce → Deprecate → Remove (6-12 months)
- **Migration tools**: Help users migrate to new versions
- **Documentation**: Clear migration guides

**Observability:**
- **Metrics**: Track system health, performance
- **Logging**: Centralized, structured logging
- **Tracing**: Distributed tracing for debugging
- **Alerting**: Proactive monitoring

**Cost Awareness:**
- **Resource optimization**: Right-size infrastructure
- **Cost monitoring**: Track and optimize costs
- **Efficiency metrics**: Cost per request, cost per user

**Modular Design:**
- **Microservices**: Independent services, easy to scale
- **Service boundaries**: Clear ownership, minimal coupling
- **Event-driven**: Decouple services with events

**Example:**
- Designed recommendation engine with plugin architecture
- Added new content types without changing core system
- Migrated to new embedding model without breaking changes
- System handles 10x growth without major rewrites

---

## 8. Bar Raiser — Deep Thinking

### Q: CAP in Search?

**Answer:**

**CAP Theorem:**
- **Consistency**: All nodes see same data
- **Availability**: System responds to requests
- **Partition Tolerance**: System works despite network failures

**For Search Systems:**
- **Prioritize**: **Availability + Partition Tolerance**
- **Accept**: **Eventual Consistency**

**Why:**
- **Search is read-heavy**: Users can tolerate slightly stale results
- **High availability**: Search must be always available
- **Partition tolerance**: Must work across data centers

**Implementation:**
- **Master-slave replication**: Writes to master, reads from replicas
- **Eventual consistency**: Replicas sync asynchronously
- **Conflict resolution**: Last-write-wins, vector clocks

**Example:**
- User updates profile → Master updated immediately
- Search may show old profile for few seconds (eventual consistency)
- Acceptable trade-off for high availability

---

### Q: When NOT to use microservices?

**Answer:**

**When to Avoid:**

1. **Early Stage:**
   - Small team, unclear requirements
   - Premature optimization
   - Start monolithic, extract later

2. **Small Team:**
   - Operational overhead too high
   - Need full-stack developers
   - Microservices require DevOps expertise

3. **High Operational Overhead:**
   - Need service mesh, monitoring, deployment pipelines
   - Small teams can't maintain
   - Monolith is simpler

4. **Tight Coupling:**
   - Services need frequent communication
   - High latency from network calls
   - Better as single service

5. **Simple Application:**
   - CRUD application, no complex logic
   - Microservices add unnecessary complexity
   - Monolith is sufficient

**When to Use:**
- Large team, independent teams
- Different scaling requirements
- Clear service boundaries
- Need independent deployment

**Example:**
- Startup: Start monolithic
- Scale: Extract services when needed
- Don't over-engineer early

---

## 9. Hiring Evaluation (Based on Your CV)

**Strong Signals:**
- Distributed systems expertise
- AI platform engineering
- Performance optimization
- Cost optimization
- Leadership experience
- Production-scale experience

**Possible FAANG Gaps:**
- Billion-scale distributed theory
- Deep consensus (Raft/Paxos)
- Advanced concurrency
- Low-level system design

**Final Hiring Simulation:**
- Coding: PASS
- System Design: STRONG PASS
- Distributed Systems: PASS+
- AI Systems: STRONG PASS
- Leadership: STRONG PASS

**Result:**
→ Strong Hire (Senior)
→ Hire (Staff)
→ Principal possible with deeper distributed prep

---

**Good luck with your FAANG interviews! 🚀**
