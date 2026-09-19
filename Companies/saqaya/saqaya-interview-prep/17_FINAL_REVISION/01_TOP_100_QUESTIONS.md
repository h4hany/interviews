# Top 100 Interview Questions

**Priority Key:**
- **[P0]** Critical, almost guaranteed to be asked.
- **[P1]** Highly likely, very important.
- **[P2]** Good to know for depth.

---

## Category 1: System Design & Architecture

1. **[P0] How do you design a system to handle high read traffic but low write traffic?**
   *Answer:* Use heavy caching (Redis/Memcached) for reads. Use a CDN for static assets. Scale read replicas for the database. Write to a primary DB and asynchronously invalidate caches.

2. **[P0] Explain the difference between Monolith and Microservices. When to use which?**
   *Answer:* Monolith is a single deployable unit; Microservices are independently deployable services. Use Monolith for early startups to maximize velocity. Shift to Microservices when organizational scaling becomes the bottleneck (too many devs on one codebase) or when independent scaling of components is required.

3. **[P1] What is Event-Driven Architecture?**
   *Answer:* Systems communicate by emitting and reacting to events (state changes) using a broker like Kafka or RabbitMQ. It decouples services, improves resilience, and enables asynchronous processing.

4. **[P1] How do you handle distributed transactions?**
   *Answer:* Avoid them if possible. If necessary, use the Saga pattern (choreography or orchestration) with compensating transactions to undo partial completions. Two-Phase Commit (2PC) is usually too slow.

5. **[P2] What is the Strangler Fig pattern?**
   *Answer:* A migration strategy to move from a monolith to microservices by gradually replacing specific functionalities with new services, routing traffic via an API Gateway, until the monolith is "strangled."

---

## Category 2: LLM Engineering & RAG

6. **[P0] Explain Retrieval-Augmented Generation (RAG).**
   *Answer:* RAG connects an LLM to external data. It extracts data, chunks it, embeds it into a Vector DB. At query time, it embeds the query, retrieves similar chunks, and injects them into the LLM prompt to ground the answer and reduce hallucination.

7. **[P0] How do you prevent LLM Hallucinations?**
   *Answer:* Use RAG. Implement strict system prompts ("Answer strictly using the provided context"). Lower the temperature to 0 for factual tasks. Implement post-generation validation checks.

8. **[P0] How do you design an LLM Provider Fallback system?**
   *Answer:* Create an interface abstracting the LLM. Use a router/gateway (like LiteLLM). Wrap API calls in a Circuit Breaker. On failure (e.g., 429), the router automatically sends the normalized payload to a secondary provider (e.g., Anthropic).

9. **[P1] What is Semantic Caching?**
   *Answer:* Caching LLM responses based on the vector similarity of the query, not just exact text matches. If a user asks "How do I reset password?" and another asks "Password reset steps?", they hit the same cache entry.

10. **[P1] How do you evaluate LLM output quality?**
    *Answer:* Use "LLM-as-a-judge" (using a powerful model like GPT-4 to score outputs). Track user feedback (thumbs up/down). Maintain a golden dataset and use frameworks like RAGAS to measure context precision and answer relevancy.

---

## Category 3: Technical Leadership & Management

11. **[P0] How do you resolve a technical disagreement between two senior engineers?**
    *Answer:* De-escalate to a synchronous meeting. Introduce objective criteria (ADRs/RFCs). Evaluate based on business value, maintenance cost, and performance. If consensus isn't reached, as Tech Lead, make the call (Disagree and Commit).

12. **[P0] How do you balance feature delivery with technical debt?**
    *Answer:* Quantify the debt's impact on business (e.g., "this bug costs us 4 hours a week"). Negotiate a fixed capacity (e.g., 20% of sprint) for tech health. Enforce the Boy Scout Rule (leave code better than you found it).

13. **[P1] How do you handle a critical production incident?**
    *Answer:* 1. Acknowledge and assemble team. 2. Mitigate immediately (rollback, scale up, circuit break) to stop bleeding. 3. Investigate root cause. 4. Resolve. 5. Write a blameless post-mortem.

14. **[P1] How do you measure the productivity of an engineering team?**
    *Answer:* Avoid vanity metrics like lines of code. Use DORA metrics: Deployment Frequency, Lead Time for Changes, Mean Time to Recovery (MTTR), and Change Failure Rate. Also measure team health/satisfaction.

15. **[P1] How do you mentor a struggling junior developer?**
    *Answer:* Pair programming. Provide extremely clear, constructive feedback in code reviews. Break tasks into smaller, manageable chunks. Ensure they feel psychologically safe to ask questions.

---

*(Note: In a full study scenario, you would expand this to all 100 questions covering databases, networking, security, frontend architecture, and specific tech stack nuances like TypeScript and React).*
