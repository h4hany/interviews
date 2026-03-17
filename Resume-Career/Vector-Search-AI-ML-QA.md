# Vector Search & AI/ML Interview Q&A

Condensed from Staff/Principal-level prep. Covers vector DBs, embeddings, RAG, and LLM systems.

---

## Vector databases & search

**Q: What is a vector database, and how does it differ from a relational database?**  
**A:** A vector database stores high-dimensional vectors (embeddings) and uses indexes (e.g. HNSW, IVFFlat) for **similarity search** (e.g. cosine similarity, approximate nearest neighbor). Relational DBs are built for structured data and exact queries. Vector DBs are for semantic search, recommendations, and RAG.

**Q: Explain HNSW (Hierarchical Navigable Small World).**  
**A:** Graph-based index for approximate nearest neighbor (ANN) search. Builds a multi-layer graph; search starts at the top (sparse) and moves down to finer layers. Good recall and query speed; higher build cost than IVFFlat.

**Q: What is pgvector and when would you use it vs Pinecone/Weaviate?**  
**A:** pgvector is a PostgreSQL extension for vector similarity search. Use it when you want vectors and relational data in one ACID database (simpler ops, one system). Use standalone vector DBs when you need very large scale, dedicated ANN infrastructure, or managed vector-only service.

**Q: Cosine similarity vs Euclidean distance for embeddings?**  
**A:** **Cosine** measures angle (orientation); good for text semantics when magnitude doesn’t matter. **Euclidean** measures straight-line distance; sensitive to magnitude. For normalized embeddings, they are often equivalent up to a monotonic transform.

---

## Embeddings & ranking

**Q: What are Bi-Encoders vs Cross-Encoders?**  
**A:** **Bi-Encoders** encode query and item separately; fast retrieval over large corpora. **Cross-Encoders** take (query, item) together; slower but more accurate. Common pattern: retrieve with Bi-Encoders, re-rank with Cross-Encoders.

**Q: How do you reduce latency in a vector recommendation system?**  
**A:** Multi-tier caching (e.g. Redis for hot embeddings and results), efficient indexing (HNSW/IVFFlat), filter-by-metadata before vector search, and two-stage pipeline: fast ANN then light re-ranking.

**Q: How do you manage token costs in LLM workflows?**  
**A:** Shorter prompts, smaller/cheaper models for simple tasks, caching for repeated queries, token budgeting and monitoring, and hybrid flows (e.g. rule-based when possible, LLM when needed).

---

## RAG & LLMs

**Q: What is RAG and why use it?**  
**A:** Retrieval-Augmented Generation: retrieve relevant documents (e.g. via vector search), then pass them as context to the LLM. Grounds answers in your data, reduces hallucination, and keeps knowledge up to date without retraining.

**Q: How do you mitigate hallucinations in LLM-based systems?**  
**A:** RAG (ground in retrieved facts), lower temperature, structured output (JSON mode, function calling), and self-consistency or verification steps where feasible.

**Q: OpenAI API vs self-hosted (e.g. Ollama)?**  
**A:** OpenAI: high quality and ease of use; cost and data privacy concerns. Ollama: lower cost, data stays on-prem, lower latency for local inference; you manage infrastructure and GPUs.

---

## Evaluation & production

**Q: How do you evaluate vector search quality?**  
**A:** Recall@K, MRR, NDCG; human relevance judgments; A/B tests on downstream metrics (clicks, conversions). Combine offline metrics with online experiments.

**Q: Embedding caching strategy?**  
**A:** Multi-tier TTL cache: e.g. Redis for hot embeddings, persistent store for colder ones. Reduces repeated calls to embedding APIs (e.g. 80%+ reduction in OpenAI calls for repeated content).

**Q: Async AI pipelines (e.g. with Sidekiq)?**  
**A:** Offload embedding generation, batch inference, and heavy model calls to background jobs so the request path stays fast and the system remains responsive under load.

---

## Quick reference

| Topic            | Key point                                              |
|------------------|--------------------------------------------------------|
| Vector DB        | Similarity search over embeddings; HNSW, IVFFlat       |
| pgvector         | Vectors inside PostgreSQL; good when you need ACID   |
| Bi vs Cross      | Bi: fast retrieval; Cross: accurate re-ranking         |
| RAG              | Retrieve + context → LLM; less hallucination           |
| Cost/latency     | Caching, smaller models, two-stage retrieval/re-rank  |
