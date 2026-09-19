# LAST DAY REVISION GUIDE

This guide is designed for the final 24 hours before your technical lead interviews. Follow the structured review schedule to ensure maximum retention and readiness without burning out.

## SAQAYA Interview - Last 24 Hours

### Morning Review: Core Technical Concepts (2 hours)

#### 1. TypeScript Deep Dive
- **Advanced Types**: Remember how to use `infer` in conditional types. Be ready to write a custom mapped type.
  - Example: `type ReturnType<T> = T extends (...args: any[]) => infer R ? R : any;`
  - Template literal types for routing: `type Route = \`/api/\${string}\`;`
- **Event Loop & Async**: 
  - Call Stack -> Microtask Queue (Promises, `queueMicrotask`) -> Macrotask Queue (`setTimeout`, I/O).
  - Node.js specific phases: Timers, Pending, Idle/Prepare, Poll, Check (`setImmediate`), Close.
- **Async Patterns**: 
  - `Promise.all` vs `Promise.allSettled`.
  - Avoid `forEach` with `async/await`; use `for...of` or `Promise.all(arr.map(...))`.
  - Memory leak prevention in long-running async operations.

#### 2. PostgreSQL Deep Dive
- **MVCC (Multi-Version Concurrency Control)**: 
  - How Postgres avoids locks for reads. `UPDATE` is essentially `DELETE` + `INSERT`.
  - Understand `VACUUM` and dead tuples.
- **Indexing**: 
  - B-Tree (default, good for ranges/equality), Hash (equality only), GIN (for JSONB/arrays), GiST (full text/geo).
  - Covering indexes (`INCLUDE` clause) for index-only scans.
- **EXPLAIN ANALYZE**: 
  - Difference between `EXPLAIN` (estimate) and `EXPLAIN ANALYZE` (actual execution).
  - Look for: Seq Scans (not always bad on small tables), loops, buffer usage (`BUFFERS` option).
- **Isolation Levels**: 
  - Read Committed (default), Repeatable Read, Serializable.
  - Serialization anomalies and how higher levels prevent them.

#### 3. AWS Services Review
- **VPC**: Subnets (Public vs Private), NAT Gateways (cost trap!), Security Groups (stateful) vs NACLs (stateless).
- **ECS (Elastic Container Service)**: 
  - EC2 vs Fargate. Fargate is serverless compute for containers.
  - Task Definitions (CPU/Memory/IAM Roles) vs Services (desired count/load balancers).
- **RDS (Relational Database Service)**: 
  - Multi-AZ (sync replication for HA) vs Read Replicas (async replication for read scaling).
- **IAM (Identity and Access Management)**: 
  - Roles over Users. Principle of Least Privilege. AssumeRole workflows.
- **SQS (Simple Queue Service)**: 
  - Standard (at-least-once, best-effort ordering) vs FIFO (exactly-once, strict ordering, lower throughput).
  - Visibility timeout: MUST be longer than consumer processing time.

#### 4. CI/CD & DevOps
- **GitHub Actions**: 
  - Reusable workflows. Matrix builds for testing across Node versions. Caching dependencies.
- **Docker**: 
  - Multi-stage builds to minimize final image size (e.g., compile TS in stage 1, copy `dist` to stage 2).
  - Understand layer caching (copy `package.json` before `src/`).
- **Terraform**: 
  - State management (`backend "s3"` with DynamoDB locking).
  - Modules for DRY infrastructure. `plan` vs `apply`.

---

### Afternoon Review: LLM Architecture & Design (2 hours)

#### 1. LLM Platform Architecture
- **Mental Map**: Draw this on a whiteboard.
  - Client -> API Gateway -> Auth/Rate Limiting -> App Server -> Provider Abstraction -> LLM API (OpenAI/Anthropic).
  - Async Path: App Server -> SQS -> Background Worker -> Vector DB (Pinecone) / DB (RDS).
- **RAG Pipeline**: 
  - Ingestion: Document -> Chunking -> Embedding Model -> Vector DB.
  - Retrieval: Query -> Embedding -> Similarity Search -> Reranking -> Context injection -> LLM.

#### 2. Provider Abstraction Design
- **Key Interfaces**:
  ```typescript
  interface LLMProvider {
    generate(prompt: string, config: ModelConfig): Promise<LLMResponse>;
    stream(prompt: string, config: ModelConfig): AsyncGenerator<string, void, unknown>;
  }
  interface ModelConfig {
    temperature?: number;
    maxTokens?: number;
    // ...
  }
  ```
- **Why?** Avoid vendor lock-in. Handle provider-specific rate limits, errors (e.g., `429 Too Many Requests`), and fallback logic gracefully.

#### 3. Prompt Discipline Framework
- Separation of instructions, context, and user input.
- XML tags for structure: `<context>`, `<instructions>`, `<user_input>`.
- System prompts vs User prompts.
- Versioning prompts: Store them in Git or a CMS, not hardcoded in scattered functions.

#### 4. Cost Management Approach
- **Tracking**: Calculate tokens *before* and *after* API calls. Store usage per user/tenant in the DB.
- **Caching**: Semantic caching (e.g., exact match in Redis, or semantic match with embeddings).
- **Model Routing**: Use cheaper models (GPT-4o-mini, Haiku) for simple tasks (routing, summarization), and heavy models (GPT-4o, Sonnet 3.5) for complex reasoning.

#### 5. Structured Outputs (Zod & Pydantic)
- **TypeScript (Zod)**: Use Zod schemas to validate LLM JSON outputs. Use `zodToJsonSchema` to pass to LLM function calling.
- **Python (Pydantic)**: Pydantic v2 is lightning fast (Rust core). Use `Instructor` or native OpenAI structured outputs with Pydantic models.

---

### Evening Review: Behavioral & Numbers (1 hour)

#### 1. Your 7 STAR Stories
*Practice these aloud in front of a mirror.*
1. **The Architecture Overhaul**: Moving from monolith to microservices/serverless. (Highlights system design, scaling).
2. **The Major Outage**: A time you brought down prod or responded to a severe incident. (Highlights calm under pressure, debugging, blameless post-mortem).
3. **The Stubborn Stakeholder**: Convincing product/business to prioritize tech debt or change a requirement. (Highlights communication, business acumen).
4. **The Mentorship Success**: Helping a junior engineer level up. (Highlights leadership, empathy).
5. **The Tight Deadline**: Delivering a critical feature under pressure. (Highlights scope management, prioritization).
6. **The LLM Implementation**: Integrating AI into a traditional system. (Highlights modern tech, managing non-deterministic behavior).
7. **The Security/Performance Fix**: Identifying and resolving a major bottleneck or vulnerability. (Highlights deep technical knowledge).

#### 2. Key Numbers to Remember
- **Typical API latency**: P50 < 50ms, P99 < 200ms.
- **LLM API latency**: GPT-4 ~5-30s, Claude ~3-20s (depending on output length). Time-to-first-token (TTFT) is critical for streaming (~0.5s - 1s).
- **PostgreSQL connections**: ~100 per instance typical. Use PgBouncer for connection pooling if higher.
- **ECS Fargate**: ~30s task startup (use provisioned capacity or keep warm if critical).
- **S3 read latency**: ~20-50ms (use CloudFront for faster delivery).
- **SQS visibility timeout**: match processing time + buffer (e.g., if max processing is 30s, set timeout to 60s).
- **Token costs (approx)**: 
  - GPT-4o: ~$2.50 / 1M input, ~$10.00 / 1M output.
  - Claude 3.5 Sonnet: ~$3.00 / 1M input, ~$15.00 / 1M output.
  - GPT-4o-mini: ~$0.15 / 1M input, ~$0.60 / 1M output.
- **Redis**: sub-ms latency, 100K+ ops/sec.

---

### Key Frameworks to Employ During the Interview

#### System Design Framework (RE-AD-T)
1. **R**equirements (Functional & Non-Functional).
2. **E**stimation (Scale, QPS, Storage).
3. **A**PI Design (Endpoints, payloads).
4. **D**atabase/Architecture (High-level components, data models).
5. **T**rade-offs & Deep Dives (Bottlenecks, scaling, failure modes).

#### Technical Decision Framework (POT-RR)
1. **P**roblem Statement (What are we solving?).
2. **O**ptions (At least 2-3 realistic choices).
3. **T**rade-offs (Pros/Cons of each).
4. **R**ecommendation (Your choice and why).
5. **R**eversibility (How hard is it to change our minds later? Two-way vs one-way door).

#### Incident Response Framework
1. **Detect**: Alarms, monitoring, user reports.
2. **Triage**: Assess severity, impact, assemble team.
3. **Mitigate**: Stop the bleeding (rollback, scale up, block traffic). *Do this before fixing.*
4. **Fix**: Root cause analysis, deploy actual patch.
5. **Post-mortem**: Blameless review. What happened? How do we prevent it?

#### Behavioral Framework (STAR)
- **S**ituation: Context.
- **T**ask: Your specific responsibility.
- **A**ction: What *you* actually did (use "I", not "we").
- **R**esult: Quantifiable impact (saved $X, improved latency by Y%).

---

### Confidence Builders
- **You have 8+ years of production experience.** You've seen systems fail. You know what works in reality, not just on a whiteboard.
- **You have shipped LLM-powered features.** You understand the gap between a LangChain tutorial and production LLM engineering.
- **You know TypeScript, Python, PostgreSQL, AWS deeply.** You are not a novice; you are a seasoned engineer.
- **You can articulate trade-offs clearly.** This is the #1 signal of a Staff/Lead engineer.
- **You are interviewing THEM as much as they interview you.** You have choices. Assess if they meet *your* standards.

---
---

## PALLADIUM Interview - Last 24 Hours

### Morning Review: Understanding Palladium
- **What Palladium does**: Global impact firm. Development finance, managing complex projects in 90+ countries. Clients include USAID, FCDO (UK), DFAT (Australia).
- **Innovative Finance**: 
  - Development Impact Bonds (DIBs): Investors pay upfront, outcomes funders pay investors back *if* targets are met.
  - Blended Finance: Mixing public/philanthropic funds with private capital to de-risk investments.
- **eLearning Domain Basics**: SCORM compliance, LMS (Learning Management Systems), localized content delivery, tracking completion and engagement in low-bandwidth areas.
- **Data Privacy & Compliance**: GDPR, HIPAA (if health data), local data residency laws in developing nations.

### Afternoon Review: The "Translation" Skill
- **Stakeholder communication stories**: Prepare examples of explaining a complex technical constraint to a non-technical director without using jargon.
- **How you translate tech to business**: "Instead of saying 'our database is locked', I explain 'our filing cabinet is currently being reorganized, so we can't pull new files right now.'"
- **How you work with domain experts**: Engineers don't know development finance. Emphasize your ability to listen to Subject Matter Experts (SMEs), extract business rules, and codify them.
- **Remote work effectiveness**: Examples of asynchronous communication, managing across time zones, robust documentation.

### Evening Review: Mission & Alignment
- **Mission alignment talking points**: Why do you want to work for an impact-driven organization? Connect your tech skills to real-world outcomes (e.g., improving education access).
- **Cultural sensitivity**: Examples of working with diverse, global teams. Respecting different communication styles and holidays/timezones.

---

### Questions to Ask THEM

#### For Saqaya (Engineering / AI Focus)
1. "Given your focus on AI-native delivery, how do you balance the non-deterministic nature of LLMs with enterprise clients' expectations of strict reliability?"
2. "How are the four disciplines (Pilot, Atlas, Owl, Raven) structured in practice? Do engineers rotate, or are they dedicated to one?"
3. "What is the biggest technical bottleneck Saqaya is facing right now as you scale?"
4. "How do you handle prompt versioning and regression testing for your LLM pipelines?"
5. "Can you walk me through the lifecycle of a typical project from the Atlas phase to Pilot?"
6. "How do you evaluate build vs. buy for foundational AI tooling internally?"
7. "What does success look like for a Tech Lead in the first 90 days here?"

#### For Palladium (Domain / Impact Focus)
1. "In your eLearning initiatives, how do you handle content delivery in regions with intermittent or very low-bandwidth internet?"
2. "How does the engineering team collaborate with domain experts (like health or finance specialists) to capture complex business rules?"
3. "What are the most challenging data privacy or compliance hurdles you face when deploying solutions globally?"
4. "How do you measure the 'impact' of the software platforms you build? What are the key metrics?"
5. "Can you describe a time when technology had to pivot drastically due to changing realities on the ground in a developing nation?"
6. "How is the engineering organization structured to support projects across 90+ countries?"
7. "What is the biggest technical debt challenge the team is currently working to resolve?"
