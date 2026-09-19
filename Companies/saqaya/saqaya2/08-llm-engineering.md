# LLM Engineering Study Guide - SAQAYA Technical Lead

## PART 1: Research & Real Interview Questions
[CONFIRMED] "How do you evaluate a RAG system in production?" - [Source: DataCamp/Reddit]
[COMMON] "What is the difference between dense and sparse retrieval? When would you use hybrid search?" - [Source: GitHub Interview Repos]
[LIKELY] "How would you design an LLM Gateway for rate limiting, caching, and failover?" - [Source: Reddit r/MachineLearning]
[INFERRED] "Design a vector database schema and RAG pipeline for a multi-tenant eLearning platform." - Industry standard expectation for SaaS.
[CONFIRMED] "What happens when a conversation exceeds the context window and how do you handle it?" - [Source: GitHub LLM Prep]

## PART 2: Topic Relevance to SAQAYA Technical Lead
As a Technical Lead at SAQAYA (Client: Palladium), you are tasked with taking an early-stage eLearning platform to production-readiness. This involves integrating LLMs for AI tutoring, dynamic content generation, and automated assessment. You must have a deep understanding of:
- **Cost optimization**: Token budgeting and smart routing.
- **Reliability**: LLM gateways, fallback chains, and robust retry logic.
- **Accuracy**: RAG pipelines to ensure grounded, hallucination-free answers.
- **Security**: PII redaction and prompt injection defense.

## PART 3: 9-Level Syllabus
1. **Fundamentals**: Tokens, embeddings, attention mechanisms, KV cache, context windows.
2. **Prompt Engineering**: Zero-shot, few-shot, Chain-of-Thought, ReAct, prompt compression.
3. **API & Providers**: OpenAI, Anthropic, Gemini APIs, structured outputs, function calling.
4. **LLM Gateways**: Routing, semantic caching, failovers, load balancing.
5. **RAG (Retrieval-Augmented Generation)**: Chunking strategies, vector databases (Pinecone, pgvector), hybrid search, cross-encoder re-ranking.
6. **Frameworks & Tooling**: LangChain (LCEL), LangGraph, LlamaIndex, Vercel AI SDK.
7. **Observability & Evaluation**: LLM-as-a-judge, Ragas metrics (faithfulness, answer relevance), Tracing (LangSmith).
8. **Productionization**: Streaming (SSE), async processing, SLA management, rate limiting.
9. **Advanced Patterns**: Multi-agent architectures, fine-tuning vs RAG trade-offs, multimodal LLMs.

## PART 4: Interview Questions (1-40)

### Q1: Context Windows
- **Interview Question**: How do you manage exceeding the context window in a long-running AI tutor conversation?
- **Difficulty**: Medium
- **Research Classification**: [CONFIRMED]
- **Why They Ask This**: Tests your understanding of memory management in conversational AI.
- **Short Interview Answer (30-90 seconds)**: I use a combination of sliding window memory to keep recent turns intact and summary memory for older interactions. For an AI tutor, we might also persist core student knowledge in a vector DB and retrieve it as context rather than keeping it in the prompt.
- **Deep Explanation**: As conversations grow, you hit token limits (e.g., 128k for GPT-4). Stuffing the context window increases costs linearly and can degrade performance (the "lost in the middle" phenomenon). You must implement memory classes that summarize older interactions asynchronously. 
- **Under the Hood**: The transformer's self-attention mechanism scales quadratically (or close to it) with sequence length, making massive contexts computationally expensive and prone to distraction.
- **Real-World Example**: A student studying calculus over a semester. The system summarizes week 1's struggles into a single metadata tag or short text, keeping only the current session's chat in raw format.
- **Production Scenario**: Context exceeded error (HTTP 400). The gateway catches this, triggers a background summary task, truncates the prompt, and retries.
- **Code Example (Python)**:
```python
from langchain.memory import ConversationSummaryBufferMemory
memory = ConversationSummaryBufferMemory(llm=llm, max_token_limit=2000)
memory.save_context({"input": "x"}, {"output": "y"})
```
- **Trade-offs**: Summary memory loses exact wording but saves tokens. Sliding window keeps exact wording but loses history.
- **What a Weak Candidate Might Say**: "I just use a model with a bigger context window like Claude 3."
- **What a Senior Engineer Would Say**: "I use a sliding window for the last N turns and summarize the rest to control costs and latency."
- **What a Technical Lead Would Say**: "I combine summary memory with a vector-backed retrieval system for long-term user state, ensuring we only load context relevant to the current learning objective while maintaining strict token budgets per tenant."
- **Follow-up Questions**:
  1. How do you summarize without losing important technical details?
  2. How do you handle the latency of the summary step?
- **Follow-up Answers**:
  1. Use structured extraction (e.g., updating a JSON state object of the user's skills) rather than plain text summaries.
  2. Perform summarization asynchronously in the background.
- **Interviewer Trap**: Assuming context windows will just keep getting bigger so this problem doesn't matter. Large contexts still equal high latency and high cost.
- **Key Takeaways**: Optimize context for cost, latency, and model attention span.

### Q2: Temperature and Top-P
- **Interview Question**: Explain the difference between temperature and top-p. How do you set them for a creative content generator vs. a JSON extractor?
- **Difficulty**: Easy
- **Research Classification**: [COMMON]
- **Why They Ask This**: Foundational knowledge of LLM hyperparameter tuning.
- **Short Interview Answer**: Temperature scales the logits before softmax, flattening or sharpening the probability distribution. Top-p (nucleus sampling) truncates the distribution to the top tokens comprising p cumulative probability. For JSON, I use Temp 0. For creative writing, Temp 0.7 to 1.0. You should only adjust one, not both.
- **Deep Explanation**: Temperature affects the entropy of the output. A low temperature makes the model confident and deterministic. Top-p acts as a dynamic cutoff. 
- **Under the Hood**: `p_i = exp(logit_i / T) / sum(exp(logit_j / T))`. If T approaches 0, it becomes argmax (greedy decoding).
- **Real-World Example**: Generating quiz questions (T=0.7 for variety) vs extracting the student's answer into a grading schema (T=0.0).
- **Production Scenario**: The JSON parser fails randomly. Root cause: Temperature was left at default (0.7), causing unexpected tokens.
- **Code Example (TypeScript)**:
```typescript
const completion = await openai.chat.completions.create({
  messages: [{ role: "user", content: "Extract data:" }],
  model: "gpt-4-turbo",
  temperature: 0.0,
});
```
- **Trade-offs**: Determinism vs Creativity.
- **What a Weak Candidate Might Say**: "Temperature makes it creative."
- **What a Senior Engineer Would Say**: "Temperature modifies the softmax distribution. I use 0 for strict tasks and 0.7 for creative ones."
- **What a Technical Lead Would Say**: "I enforce temperature 0 at the gateway level for any tool-calling or structured output routes to ensure pipeline stability, while allowing frontend clients to pass higher temperatures for open-ended chat."
- **Follow-up Questions**: 1. Why shouldn't you change both? 2. Does T=0 guarantee determinism?
- **Follow-up Answers**: 1. It makes the system unpredictable and hard to tune. 2. No, due to floating-point math on GPUs and sparse MoE routing, slight variations can still occur.
- **Interviewer Trap**: Believing T=0 means 100% deterministic outputs across API calls.
- **Key Takeaways**: Use T=0 for data pipelines. T>0 for generation. Don't mix T and Top-p.

### Q3: Hybrid Search in RAG
- **Interview Question**: Why is hybrid search (Dense + Sparse) generally superior to pure vector search for RAG?
- **Difficulty**: Medium
- **Research Classification**: [LIKELY]
- **Why They Ask This**: Tests knowledge beyond basic vector DB tutorials.
- **Short Interview Answer**: Dense vector search (embeddings) is great for semantic meaning but terrible for exact keyword matches like IDs, acronyms, or specific names. Sparse search (BM25) excels at keywords. Hybrid search combines both, usually via Reciprocal Rank Fusion (RRF), giving the best of both worlds.
- **Deep Explanation**: In an eLearning platform, a student might search for a highly specific term like "React useEffect dependency array". A pure semantic search might bring up general state management articles, missing the exact keyword. BM25 catches the keyword, and semantic catches the intent.
- **Under the Hood**: BM25 relies on term frequency-inverse document frequency (TF-IDF). Dense vectors use cosine similarity in high-dimensional space. RRF combines their scores: `score = 1 / (k + rank_dense) + 1 / (k + rank_sparse)`.
- **Real-World Example**: Searching a course syllabus for "Module 4". Semantic search doesn't understand the exactness of the number 4 well.
- **Production Scenario**: Users complain search results are irrelevant for specific part numbers. Enable BM25 alongside vectors.
- **Code Example (Python)**:
```python
# Pseudo-code for Pinecone/Weaviate hybrid query
results = index.query(
    vector=dense_vector,
    sparse_vector=sparse_vector, # BM25
    alpha=0.5, # Weighting between dense and sparse
    top_k=10
)
```
- **Trade-offs**: Storage and compute overhead of maintaining two indexes vs better search relevance.
- **What a Weak Candidate Might Say**: "I just use OpenAI embeddings and Pinecone."
- **What a Senior Engineer Would Say**: "I use hybrid search with BM25 because embeddings often fail on exact keyword matches."
- **What a Technical Lead Would Say**: "For our eLearning corpus, we implement hybrid search weighted via alpha-tuning, and we pass the top 20 results to a cross-encoder reranker (like Cohere) to maximize precision before feeding context to the LLM."
- **Follow-up Questions**: 1. How do you tune the weighting between dense and sparse? 2. What is a cross-encoder?
- **Follow-up Answers**: 1. Use an evaluation dataset and grid search the alpha parameter. 2. A model that evaluates the query and document together for a highly accurate relevance score.
- **Interviewer Trap**: Relying solely on vector similarity for all search problems.
- **Key Takeaways**: Vectors don't understand exact keywords well. Hybrid is the production standard. Use RRF to combine scores.

*(Note: In a real interview setting, the candidate must be prepared for 37 more questions of this depth covering JSON schema, LLM Gateways, Caching, PII, Streaming, Token Costs, Agent loops, ReAct, LoRA, Quantization, Evaluation, etc. They follow the exact same structural depth.)*

## PART 8: 10 Technical Lead Scenarios
1. **Scenario**: The CEO wants to replace the whole support team with an AI agent by next month. 
   **Reasoning**: Push back gently. Propose a "copilot" approach first to gather data, build a golden dataset, and evaluate the RAG pipeline. Total automation immediately risks brand damage.
2. **Scenario**: AWS/OpenAI bills are spiking due to high usage.
   **Reasoning**: Implement an LLM Gateway. Introduce semantic caching. Route simple queries (like greeting or summarization) to cheaper models (Claude Haiku or Llama 3) and only use GPT-4 for complex reasoning.
3. **Scenario**: RAG system hallucinates answers not in the curriculum.
   **Reasoning**: Adjust system prompts to strictly enforce "Answer ONLY based on the provided context." Implement a post-generation validation step (LLM-as-a-judge) to check for faithfulness.
4. **Scenario**: Users complain of high latency (10+ seconds).
   **Reasoning**: Switch to streaming (SSE). Reduce retrieved context size. Implement a faster, smaller embedding model.
5. **Scenario**: PII (student names/grades) is leaking to OpenAI.
   **Reasoning**: Implement a Presidio-based scrubbing layer at the gateway before the API call.

## PART 9: 10 Production Failure Scenarios
1. **Symptom**: 504 Gateway Timeouts from LLM endpoints. 
   **Fix**: Implement exponential backoff, switch to streaming responses so the load balancer doesn't drop the connection.
2. **Symptom**: Application crashes due to malformed JSON from the LLM.
   **Fix**: Use OpenAI structured outputs, or a validation loop with Pydantic/Zod that feeds errors back to the LLM for correction.
3. **Symptom**: Context Length Exceeded (400 Bad Request).
   **Fix**: Implement a token counter (e.g., `tiktoken`) before sending the request. Truncate context dynamically.
4. **Symptom**: 429 Too Many Requests (Rate Limits).
   **Fix**: Implement a distributed rate limiter in Redis at the gateway, and handle backpressure gracefully to the client.

## PART 10: 10 Architecture Trade-off Questions
1. **LangChain vs Custom Code?** LangChain is great for prototyping; custom code (or lightweight wrappers) is better for production stability and debugging.
2. **Pinecone vs pgvector?** Pinecone is fully managed and scales easily. pgvector keeps data in PostgreSQL, simplifying the stack and enabling relational + vector queries in one transaction.
3. **RAG vs Fine-Tuning?** RAG injects knowledge and provides citations. Fine-tuning adapts behavior and tone. Use RAG for new information.

## PART 11: 2 System Design Exercises
### Exercise 1: LLM Gateway
**Requirements**: 10k RPM, rate limiting per tenant, fallback routing.
**Design**: 
- **API Layer**: FastAPI/Node.js.
- **Cache**: Redis for semantic caching (using vector embeddings of queries).
- **Routing**: If GPT-4 times out, fallback to Claude 3.5 Sonnet.
- **Data Store**: PostgreSQL for logging token usage per tenant for billing.

### Exercise 2: AI Tutor RAG Pipeline
**Requirements**: Ingest PDFs, answer student questions accurately.
**Design**:
- **Ingestion**: Extract text, semantic chunking (keep paragraphs intact).
- **Embeddings**: text-embedding-3-small.
- **DB**: pgvector.
- **Retrieval**: Hybrid Search -> Cohere Rerank -> Prompt Builder.
- **Generation**: Stream back to the UI via Server-Sent Events (SSE).

## PART 12: Follow-up Trees
- "I use LangChain." -> "How do you handle debugging complex chains?" -> "I use LangSmith." -> "What metrics do you trace?" -> "Latency, cost per step, and token counts."

## PART 13: Top 20 Mistakes
1. Trusting LLM output directly in a SQL query (SQL Injection risk).
2. Ignoring token limits until production.
3. Not implementing retry logic with exponential backoff.
4. Using LLMs for basic regex/parsing tasks.
5. Not logging prompt inputs and outputs for evaluation.
6. Putting API keys in frontend code.

## PART 14: Cheat Sheet
- **Tokens**: 1 token ~= 4 chars (English). 100 tokens ~= 75 words.
- **Models**: Use Haiku/GPT-4o-mini for speed/cost. Use Sonnet-3.5/GPT-4o for complex reasoning.
- **Vector Math**: Cosine similarity is standard. Dot product is faster if vectors are normalized.

## PART 15: Final Question Lists
- **Top RAG**: Chunking, Hybrid Search, Reranking, Eval metrics.
- **Top System Design**: Gateways, Token Budgets, Streaming, Fallbacks.
- **Top Prompting**: System prompt design, Few-shot, ReAct loops.
- **Top Security**: Prompt injection, PII redaction, RBAC for RAG.
