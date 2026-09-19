# TECHNICAL INTERVIEW CHEAT SHEET

## 1. TypeScript Quick Reference

### Key Type Patterns
- **Generics**: Reusable components. `function id<T>(arg: T): T { return arg; }`
- **Conditional Types**: `T extends U ? X : Y`
- **Mapped Types**: Create new types by transforming properties. 
  ```typescript
  type Optional<T> = { [K in keyof T]?: T[K] };
  type Readonly<T> = { readonly [K in keyof T]: T[K] };
  ```
- **Template Literal Types**: String manipulation at the type level.
  ```typescript
  type Event = 'click' | 'hover';
  type Handler = `on${Capitalize<Event>}`; // 'onClick' | 'onHover'
  ```

### Common Utility Types
- `Partial<T>`: Makes all properties optional.
- `Required<T>`: Makes all properties required.
- `Pick<T, K>`: Selects a subset of properties.
- `Omit<T, K>`: Removes a subset of properties.
- `Record<K, T>`: Constructs an object type with keys K and values T.
- `Exclude<T, U>`: Excludes types from T that are assignable to U.
- `Extract<T, U>`: Extracts types from T that are assignable to U.
- `NonNullable<T>`: Removes null and undefined.
- `ReturnType<T>`: Gets the return type of a function.

### Error Handling Patterns
- **Result Object (Functional approach)**:
  ```typescript
  type Result<T, E = Error> = { ok: true; value: T } | { ok: false; error: E };
  
  function divide(a: number, b: number): Result<number> {
    if (b === 0) return { ok: false, error: new Error("Divide by zero") };
    return { ok: true, value: a / b };
  }
  ```

---

## 2. Python Quick Reference

### Asyncio Patterns
- `async def` / `await`: Core syntax.
- `asyncio.gather(*coroutines)`: Run concurrently, returns list of results (fails fast if one fails).
- `asyncio.create_task(coro)`: Schedule execution in background.
- `asyncio.Semaphore(limit)`: Concurrency limiting for API calls.
  ```python
  sem = asyncio.Semaphore(5)
  async def fetch_with_limit(url):
      async with sem:
          return await fetch(url)
  ```

### Pydantic v2 Key Features
- Speed: Core rewritten in Rust.
- `@computed_field`: Dynamically calculate fields.
- `model_validate()` / `model_dump()`: Modern methods replacing `.parse_obj()` and `.dict()`.
- `Field(...)`: Validation rules (e.g., `Field(gt=0, le=100)`).
- Annotated types: `age: Annotated[int, Field(gt=0)]`.

### FastAPI Patterns
- Dependency Injection: Uses `Depends()` for DB sessions, auth, etc.
  ```python
  def get_db():
      db = SessionLocal()
      try: yield db
      finally: db.close()
      
  @app.get("/users/")
  def read_users(db: Session = Depends(get_db)):
      pass
  ```
- Background Tasks: Pass `BackgroundTasks` as a parameter to enqueue simple tasks without Celery/Redis.

---

## 3. PostgreSQL Quick Reference

### Key SQL Patterns
- **CTEs (Common Table Expressions)**: Keep queries readable.
  ```sql
  WITH active_users AS (
    SELECT id FROM users WHERE status = 'active'
  )
  SELECT * FROM orders WHERE user_id IN (SELECT id FROM active_users);
  ```
- **Window Functions**: Analytics over partitions.
  ```sql
  SELECT user_id, amount,
         ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY created_at DESC) as latest_order_rank
  FROM orders;
  ```
- **JSONB Operations**:
  - `->` get JSON object, `->>` get text.
  - `@>` contains (e.g., `WHERE data @> '{"status": "active"}'`).
  - Indexing: `CREATE INDEX idx_data ON table USING GIN (data);`

### Index Types & When to Use
| Index Type | Best For | Example Use Case |
|------------|----------|------------------|
| B-Tree | Equality, Ranges (>, <), Sorting | User IDs, Timestamps |
| Hash | Strict equality only (faster than B-Tree) | Session IDs |
| GIN | Arrays, JSONB, Full Text Search | Tags array, flexible JSON querying |
| GiST | Geolocation, specialized full text | PostGIS bounding boxes |
| BRIN | Very large, naturally sorted tables | Timeseries append-only logs |

### EXPLAIN ANALYZE Guide
- `EXPLAIN ANALYZE`: Actually runs the query.
- Look at `cost=X..Y` (X=startup cost, Y=total cost).
- Look at `actual time=X..Y`.
- Red flags: `Seq Scan` on large tables, large differences between `rows` (estimated) and `actual rows` (stats are out of date, run `ANALYZE`).

### Key pg_stat Queries
- Find long-running queries:
  ```sql
  SELECT pid, now() - pg_stat_activity.query_start AS duration, query 
  FROM pg_stat_activity WHERE state != 'idle' ORDER BY duration DESC;
  ```

---

## 4. AWS Quick Reference

### Service Comparison Tables

| Compute | Best For | Pros | Cons |
|---------|----------|------|------|
| EC2 | Long-running, custom OS, predictable | Full control, cheapest | High maintenance |
| ECS/Fargate | Dockerized apps, microservices | No OS to manage, scalable | Slower startup than Lambda |
| Lambda | Event-driven, bursty traffic | Scale to zero, zero maintenance | Cold starts, 15m timeout |

| Storage/DB | Best For | Pros | Cons |
|------------|----------|------|------|
| RDS/Aurora | Relational data, ACID | Managed backups, HA | Connection limits, scaling writes is hard |
| DynamoDB | Key-Value, High read/write throughput | Single-digit ms latency, infinite scale | Complex querying, no joins |
| S3 | Object storage (images, logs, backups) | Cheap, highly durable (11 9s) | Not for block storage |

### Key CLI/Concepts
- `aws sts get-caller-identity`: Who am I?
- Security Groups: Stateful (allow inbound, outbound is automatically allowed).
- NACLs: Stateless (must explicitly allow inbound AND outbound).

---

## 5. LLM Quick Reference

### Provider Comparison

| Provider | Top Model | Best For | Context Window |
|----------|-----------|----------|----------------|
| OpenAI | GPT-4o | General reasoning, strict JSON output | 128k |
| Anthropic | Claude 3.5 Sonnet | Coding, long context analysis, nuanced writing | 200k |
| Google | Gemini 1.5 Pro | Massive context, multimodal | 1M - 2M |

### Token Cost Estimates (Rough per 1M tokens)
- GPT-4o: ~$2.50 in / ~$10.00 out
- GPT-4o-mini: ~$0.15 in / ~$0.60 out
- Claude 3.5 Sonnet: ~$3.00 in / ~$15.00 out

### Key API Patterns
- **Streaming**: Crucial for UX. Returns chunks. Handle disconnects.
- **Function Calling / Tool Use**: Model outputs JSON matching a schema instead of raw text. Application executes tool and returns result to model.

---

## 6. System Design Templates

### Standard System Design Skeleton
1. **Requirements** (Functional, Non-functional, Out of scope)
2. **Back-of-the-envelope Estimation** (Traffic, Storage, Bandwidth)
3. **High-Level Design** (Boxes and arrows)
4. **API Design** (REST/GraphQL/gRPC definitions)
5. **Database Schema** (Tables, relations, NoSQL structures)
6. **Deep Dive / Bottlenecks** (Scaling, Caching, Sharding, Fault Tolerance)

### LLM Platform Template
- **Client App** <-> **API Gateway** (Rate limits by user/tenant)
- **App Servers** (Handles Auth, Business Logic)
- **Prompt Manager** (Fetches versioned prompts)
- **LLM Gateway / Proxy** (Routing, Fallbacks, Retry logic, Cost tracking)
- **Vector DB** (Pinecone/PgVector for RAG context)
- **Async Workers** (SQS + Python workers for background document embedding)

### eLearning Platform Template (Palladium Focus)
- **Client App** (Mobile friendly, offline capabilities via Service Workers)
- **CDN** (CloudFront for caching heavy video/SCORM content globally)
- **App Servers** (Progress tracking, Auth)
- **Relational DB** (Users, Courses, Enrollments, Progress logs)
- **Event Bus / Queue** (Processing completion certificates asynchronously)

---

## 7. Decision Trees

### TypeScript vs Python
- Use **TypeScript** for: Web backends heavily interacting with frontend, strict structural typing, huge monorepos.
- Use **Python** for: Data science, AI/LLM orchestration, heavy background processing, rapid scripting.

### Monolith vs Microservices
- Start with **Modular Monolith**.
- Split to **Microservices** ONLY IF:
  - Independent scaling is required (e.g., video processing vs user auth).
  - Team size requires independent deployments.
  - Different technology stacks are needed (e.g., Node web server + Python ML worker).

### ECS Fargate vs Lambda
- Use **Lambda** for: Event-driven glue (S3 triggers), unpredictable bursty traffic, cron jobs.
- Use **ECS Fargate** for: Consistent API traffic, long-running processes (>15 min), heavy memory requirements, avoiding cold start penalties.

### SQS vs SNS vs EventBridge
- **SQS**: 1:1 async task queue (e.g., send welcome email). Worker pulls.
- **SNS**: 1:N pub/sub (e.g., UserCreated event -> trigger email worker AND analytics worker). Push based.
- **EventBridge**: Complex event routing with filtering rules, SaaS integrations.

### Cache vs No Cache
- **Do not cache** if: Data is highly transactional and must be real-time (financial balances).
- **Cache (Redis/Memcached)** if: Data is read-heavy, slow to compute, and eventual consistency is acceptable. Implement cache invalidation strategy (TTL or event-based).

---

## 8. Key Numbers to Memorize

### Latency Numbers
- L1 Cache Reference: 0.5 ns
- Branch Mispredict: 5 ns
- L2 Cache Reference: 7 ns
- Mutex Lock/Unlock: 25 ns
- Main Memory Reference: 100 ns
- Read 1MB sequentially from memory: 250,000 ns (0.25 ms)
- Read 1MB sequentially from network: 10,000,000 ns (10 ms)
- Read 1MB sequentially from disk (SSD): 1,000,000 ns (1 ms)
- Round trip within same datacenter: 500,000 ns (0.5 ms)
- Packet round trip CA to Netherlands: 150,000,000 ns (150 ms)

### Database / Web specific
- Redis GET/SET: < 1ms
- RDBMS simple query (indexed): 1-5ms
- External API Call over internet: 50-200ms
- LLM API Call (generation): 1000ms - 30,000ms

### Throughput & Storage Rough Estimates
- 1 Char = 1 Byte
- 1 Token = ~4 Chars = ~4 Bytes
- 1 Million Daily Active Users (DAU), 10 requests/day = 10M req/day = ~115 req/sec (QPS).
- 115 QPS is easily handled by a single modern server; no crazy microservices needed for standard CRUD.
