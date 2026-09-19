# LLM Engineering Mock Interview

This mock focuses purely on LLM integration, prompt engineering, RAG, and AI system reliability.

## Question 1: Provider Abstraction & Routing
**Question:**
"We want to stop hardcoding OpenAI in our app. We want to route simple summarization tasks to a fast/cheap model, and complex coding tasks to a heavy model. How do you build this?"

**Ideal Answer:**
1. **Intent Detection:** Use a very fast, cheap model (like Haiku or even a local classifier) to classify the user's intent.
2. **Router Component:** Create a central LLM service that takes the prompt and the intent.
3. **Configuration:** Define a configuration map:
   - `intent: "summarize" -> provider: "anthropic", model: "claude-3-haiku"`
   - `intent: "code" -> provider: "openai", model: "gpt-4o"`
4. **Standardized Schema:** Ensure the internal application only speaks a standardized schema (e.g., OpenAI's message format), and the router translates this to the specific provider's API.

## Question 2: RAG Pipeline Optimization
**Question:**
"Our RAG pipeline is returning irrelevant results. Users are asking 'What is X?' and getting chunks of text that just mention the word X in passing. How do you improve retrieval?"

**Ideal Answer:**
1. **Chunking Strategy:** Move from naive character-based chunking to semantic chunking or paragraph-based chunking.
2. **Hybrid Search:** Combine Dense Vector Search (embeddings) with Sparse Keyword Search (BM25/Elasticsearch). Embeddings capture meaning; BM25 captures exact keyword matches. Use Reciprocal Rank Fusion (RRF) to combine the scores.
3. **Re-ranking:** Use a Cross-Encoder (like Cohere Rerank) after the initial retrieval. Fetch top 50 documents, pass them to the reranker, and send only the top 5 to the LLM.
4. **Metadata Extraction:** Extract entities (dates, tags) during ingestion and use them as hard filters before vector search.

## Question 3: Managing Prompt Sprawl
**Question:**
"We have prompts scattered across 50 different microservices and React components. Updating a core system prompt requires coordinating 5 PRs. How do we fix this?"

**Ideal Answer:**
1. **Central Prompt Registry:** Treat prompts as code. Store them in a centralized repository or use a CMS-like tool (Langfuse, promptfoo, or a custom DB table).
2. **Versioning:** Prompts must be versioned. `system_prompt_v1.2`. This allows safe rollbacks.
3. **Separation of Concerns:** Frontend should *never* construct the prompt. The frontend sends the user input; the backend injects it into the versioned prompt template.
4. **Evaluation CI/CD:** Implement prompt testing. When a prompt is updated, run it against a golden dataset of test cases to detect regressions before deploying.

## Question 4: Cost Management
**Question:**
"Our OpenAI bill hit $10,000 this month. How do you investigate and reduce this without sacrificing quality?"

**Ideal Answer:**
1. **Visibility:** First, I need observability. I'd tag requests (using headers or tools like Helicone/Langfuse) by user, feature, and model to see where the spend is coming from.
2. **Model Downgrade:** Evaluate if tasks currently using GPT-4 can be done by GPT-3.5 or Claude Haiku.
3. **Prompt Trimming:** Check if we are sending excessively large context windows. Can we reduce the number of retrieved chunks in our RAG from 10 to 5?
4. **Caching:** Implement Semantic Caching to serve repeated queries without hitting the API.
5. **Batching/Local Models:** For asynchronous background tasks, batch them or move them to self-hosted open-source models (Llama 3).

## Question 5: Handling Structured Output
**Question:**
"We need the LLM to return data in a very strict JSON format to render a UI. It keeps failing, missing brackets, or adding markdown wrapping. How do you guarantee structure?"

**Ideal Answer:**
1. **Function Calling / Tools:** Use the provider's native Function Calling or Structured Output APIs (e.g., OpenAI's JSON mode or tool schemas).
2. **Prompt Instructions:** Explicitly state in the system prompt: "Return ONLY valid JSON. Do not include markdown formatting like ```json."
3. **Validation Layer:** Use Zod or Pydantic in the application code to validate the LLM's response immediately.
4. **Retry Logic:** If validation fails, automatically catch the error, append the validation error to the chat history, and prompt the LLM to fix its own mistake: "Your previous response failed schema validation with error X. Please fix it."
