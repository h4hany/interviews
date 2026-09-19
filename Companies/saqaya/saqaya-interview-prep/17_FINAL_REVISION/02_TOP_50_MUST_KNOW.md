# Top 50 Must-Know Concepts

A quick reference guide for the most critical concepts for a Technical Lead / LLM Engineer role.

## Architecture & System Design

1. **CAP Theorem**
   - *Explanation:* A distributed system can only provide two of three guarantees: Consistency, Availability, and Partition Tolerance. Since network partitions (P) are inevitable, you must trade off between C and A.
   - *Talking Point:* Discuss how relational databases lean towards C, while NoSQL (like DynamoDB) lean towards A (Eventual Consistency).

2. **Circuit Breaker Pattern**
   - *Explanation:* Prevents an application from repeatedly trying to execute an operation that is likely to fail, allowing the system to recover. 
   - *Talking Point:* Essential for LLM API calls. States are Closed (normal), Open (failing, block calls), Half-Open (testing recovery).

3. **Backend-For-Frontend (BFF)**
   - *Explanation:* Creating separate backend services tailored to the needs of specific frontends (e.g., one for Web, one for Mobile) to prevent over-fetching and aggregate data.
   - *Talking Point:* Great for security (hiding API keys) and formatting data for React components.

## Data & Databases

4. **Vector Databases (KNN vs ANN)**
   - *Explanation:* Databases optimized for storing and querying high-dimensional vectors. K-Nearest Neighbors (KNN) is exact but slow. Approximate Nearest Neighbors (ANN, e.g., HNSW algorithm) is fast but slightly less accurate.
   - *Talking Point:* Crucial for RAG. Mention Pinecone, Qdrant, or pgvector.

5. **ACID Properties**
   - *Explanation:* Atomicity (all or nothing), Consistency (valid state), Isolation (concurrent transactions don't interfere), Durability (saved permanently).
   - *Talking Point:* Why PostgreSQL is reliable for financial or core business logic.

6. **Indexing (B-Trees)**
   - *Explanation:* Data structures that improve the speed of data retrieval operations on a database at the cost of additional writes and storage space.
   - *Pitfall:* Over-indexing slows down write operations.

## LLM Engineering

7. **Retrieval-Augmented Generation (RAG)**
   - *Explanation:* Enhancing LLM prompts with data retrieved from a database to ground the response and reduce hallucination.
   - *Talking Point:* Discuss chunking strategies, embedding models, and vector search.

8. **Semantic Chunking**
   - *Explanation:* Breaking text into chunks based on meaning (sentences, paragraphs) rather than arbitrary character counts, preserving context for the LLM.

9. **Temperature & Top-P**
   - *Explanation:* Parameters controlling LLM randomness. High temperature = creative/random. Low temperature = deterministic/focused. Top-P restricts token selection to a cumulative probability threshold.

10. **System Prompts vs User Prompts**
    - *Explanation:* System prompts set the overarching behavior, persona, and guardrails. User prompts are the specific queries.
    - *Pitfall:* Mixing instructions into user prompts makes them vulnerable to prompt injection.

## Leadership & Process

11. **Blameless Post-Mortems**
    - *Explanation:* Analyzing incidents by focusing on systemic failures, process gaps, and tooling rather than pointing fingers at individuals.
    - *Talking Point:* "You don't fire an engineer for taking down prod; you fix the system that allowed one engineer to take down prod."

12. **DORA Metrics**
    - *Explanation:* The four key metrics for DevOps performance: Deployment Frequency, Lead Time, MTTR, Change Failure Rate.
    - *Talking Point:* The standard way to measure engineering team velocity safely.

13. **Architecture Decision Records (ADRs)**
    - *Explanation:* Short documents capturing important architectural decisions, context, and consequences.
    - *Talking Point:* The best way to resolve technical disputes and document institutional memory.
