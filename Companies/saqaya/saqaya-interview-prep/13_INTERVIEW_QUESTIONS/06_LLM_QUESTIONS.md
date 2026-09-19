# 06 LLM QUESTIONS

## Question 1: LEVEL 4 — Staff/Lead
### Explain the concept of KV Cache in Transformer architectures. How does it impact inference latency, and how do modern optimization techniques like PagedAttention address its bottlenecks?
### What the interviewer is testing
The interviewer is testing your deep understanding of LLM inference mechanics, specifically memory bottlenecks, auto-regressive generation, and state-of-the-art serving optimizations (like vLLM).
### Short answer
KV Cache stores the Key and Value tensors of previously computed tokens to avoid redundant computations during auto-regressive decoding. However, it grows linearly with sequence length and batch size, causing severe memory fragmentation and bottlenecks. Techniques like PagedAttention solve this by paging KV blocks in non-contiguous memory, drastically improving batching efficiency and throughput.
### Detailed answer
In a standard Transformer, generating the $N^{th}$ token requires attending to all $N-1$ previous tokens. Recomputing the Key (K) and Value (V) representations for all past tokens at every step is computationally expensive. The KV Cache solves this by caching these tensors. 
During the "prefill" phase, the entire prompt is processed in parallel, and its KV cache is generated. During the "decode" phase, tokens are generated one by one, and only the new token's KV tensors are computed and appended to the cache.
The problem: The KV cache takes up significant GPU memory. Since sequence lengths are unpredictable, naive memory allocators pre-allocate contiguous chunks of memory based on maximum sequence lengths. This leads to massive internal fragmentation (wasted memory) and external fragmentation, severely limiting the number of requests a GPU can batch concurrently.
### How it works internally
PagedAttention (introduced by vLLM) borrows from OS virtual memory. It divides the KV cache into fixed-size blocks (e.g., storing KV for 16 tokens). These blocks don't need to be physically contiguous in GPU memory. A block table maps logical token positions to physical blocks. As a sequence grows, physical blocks are allocated dynamically on-demand. This reduces memory waste to near zero (only the last block might be partially empty).
### Real-world example
In a production deployment serving a 70B parameter model, we were only able to batch 4 concurrent requests due to OOM errors caused by contiguous KV cache allocation, leading to low GPU utilization (compute bound). By switching to an inference server utilizing PagedAttention (like vLLM or TGI), we could share physical memory blocks and batch 64+ requests concurrently, shifting the bottleneck from memory capacity back to compute, and increasing throughput by 10x.
### Trade-offs
- KV Caching trades memory capacity for computational speed.
- PagedAttention introduces slight overhead for block table lookups and memory management, but the massive gain in batching capabilities far outweighs it.
- Larger block sizes reduce management overhead but increase internal fragmentation.
### Common mistakes
- Confusing KV Cache with traditional caching (like Redis caching responses).
- Not understanding the difference between the Prefill phase (compute bound) and the Decode phase (memory bandwidth bound).
### Strong Technical Lead answer
"KV Cache is essential for auto-regressive generation to prevent recomputing past tokens, but it becomes the primary memory bottleneck in production. As a Tech Lead designing an LLM serving infrastructure, I know that naive contiguous memory allocation kills batching efficiency. I would deploy engines like vLLM that use PagedAttention to page KV blocks dynamically. Furthermore, I'd consider techniques like continuous batching, and if deploying on limited hardware, look into models with Grouped Query Attention (GQA) which natively reduces the KV cache size."
### Follow-up questions
1. How does Grouped Query Attention (GQA) affect KV Cache?
2. What is continuous batching (or iteration-level scheduling)?
3. How would you handle a prompt that exceeds the available KV cache memory?
### Follow-up answers
1. GQA shares K and V heads across multiple Query heads (unlike Multi-Head Attention which has 1:1). This drastically reduces the number of K and V tensors stored in the cache, reducing memory requirements and improving serving throughput.
2. Instead of waiting for all sequences in a batch to finish, continuous batching evicts completed sequences and slots in new requests at the token-level (iteration level), keeping the GPU fully saturated.
3. If memory is exhausted, systems like vLLM swap KV cache blocks from GPU VRAM to CPU RAM, pausing the request until memory frees up, then swapping it back in.
### Interviewer escalation
"Suppose you need to serve a massive context (e.g., 100k tokens) to a single user. PagedAttention helps with batching, but how do you handle the sheer size of the KV cache for a single huge request?"
### Lead-level thinking
A Lead will discuss architectural limits. "For extremely long contexts, even with PagedAttention, a single request's KV cache might exceed VRAM. I would explore RingAttention or Tensor Parallelism to shard the context across multiple GPUs. Alternatively, I'd evaluate Prompt Caching if the prefix is static, or explore architectures like Mamba (SSMs) that maintain constant state size instead of linear KV caches."


## Question 2: LEVEL 6 — Architecture/Trade-off
### Design a system for implementing Retrieval-Augmented Generation (RAG) at enterprise scale. How do you address data staleness and access control?
### What the interviewer is testing
System design for AI, vector database operations, handling complex enterprise constraints (RBAC/ACLs), and data ingestion pipelines.
### Short answer
I would build an asynchronous ingestion pipeline (CDC/Kafka -> Chunking/Embedding -> Vector DB) for data freshness. For access control, I'd attach ACL metadata to chunks in the Vector DB and apply pre-filtering during the vector search phase to ensure users only retrieve documents they are authorized to see.
### Detailed answer
An enterprise RAG system has two main flows: Ingestion and Retrieval.
**Ingestion Pipeline:** 
1. Use Change Data Capture (CDC) or message queues (Kafka) to stream updates from source systems (Confluence, Jira, DBs).
2. Workers process these streams: parsing, chunking (with semantic overlap), and generating embeddings via an API or local model.
3. The chunks, embeddings, and crucial metadata (Document ID, Timestamp, ACLs) are upserted into a Vector DB (e.g., Pinecone, Milvus, Qdrant).
**Retrieval Pipeline:**
1. User submits a query.
2. The orchestrator (e.g., LangChain/LlamaIndex) passes the user's identity to a Policy Service to resolve their groups/roles.
3. The query is embedded.
4. A semantic search is performed on the Vector DB with a metadata filter: `WHERE roles IN (user_roles)`.
5. Top-K results are injected into the prompt and sent to the LLM.
### How it works internally
Vector DBs use algorithms like HNSW (Hierarchical Navigable Small World) for Approximate Nearest Neighbor (ANN) search. When metadata filtering is applied, modern vector DBs do "pre-filtering" (filtering candidates before ANN search) or "single-stage filtering" (integrating filters directly into the graph traversal) to ensure the Top-K results are strictly authorized without compromising search speed.
### Real-world example
We built a RAG system for internal HR documents. Initially, we fetched the Top-20 documents and filtered them post-retrieval based on the user's role. This led to a bug where an entry-level employee queried salary bands; the Top-20 results were all executive-only documents, which were dropped by the post-filter, leaving 0 context for the LLM. We switched to pre-filtering in Qdrant, ensuring the ANN search only traversed nodes the user had access to.
### Trade-offs
- Pre-filtering vs Post-filtering: Pre-filtering is secure and guarantees K results, but complex filters can slow down ANN search. Post-filtering is fast but can result in fewer than K results (or 0) if many documents are restricted.
- Streaming ingestion vs Batch: Streaming ensures low staleness but requires complex distributed systems (Kafka, Flink). Batch is easier but data is stale.
### Common mistakes
- Relying on the LLM to enforce access control ("Don't tell the user if they aren't authorized"). LLMs can be jailbroken; security MUST be at the retrieval level.
- Poor chunking strategy (e.g., splitting in the middle of sentences).
### Strong Technical Lead answer
"For enterprise RAG, security and freshness are paramount. I'd design an event-driven ingestion pipeline using Kafka to ensure near real-time updates to the Vector DB when source documents change. For access control, security must be enforced at the retrieval layer, not the LLM layer. I would embed ACL tags as metadata on vector chunks and leverage Vector DB pre-filtering to strictly limit the search space based on the user's resolved IAM roles. This guarantees no unauthorized data ever enters the LLM's context window."
### Follow-up questions
1. How do you evaluate the quality of your RAG system?
2. What is Hybrid Search and why use it?
3. How do you handle document deletions in the Vector DB?
### Follow-up answers
1. Using frameworks like RAGAS or TruLens to measure Context Relevance (did we retrieve the right info?), Groundedness (did the LLM hallucinate?), and Answer Relevance.
2. Hybrid Search combines Dense Vector Search (semantic meaning) with Sparse Keyword Search (BM25, exact matching). It's crucial for queries involving specific IDs, acronyms, or names where semantic search fails.
3. The ingestion pipeline must handle tombstone events. When a document is deleted, a message is sent to workers to issue a `DELETE` command to the Vector DB using the associated Document ID metadata.
### Interviewer escalation
"The chunking strategy is degrading performance because context is lost across chunk boundaries. How do you fix this without exceeding context limits?"
### Lead-level thinking
A Lead explores advanced RAG techniques. "I would implement a Parent-Child (or Small-to-Big) retrieval strategy. We chunk the document into small pieces for highly accurate embedding and retrieval. However, we store a reference to the larger parent chunk. When a small chunk is matched, we inject the larger parent chunk into the LLM context, providing the missing surrounding context."


*(Note: Additional questions omitted for brevity but follow the exact same structure)*
