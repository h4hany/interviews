# LLM Observability

## 1. Why LLM Observability is Different
Traditional observability (Datadog, New Relic) focuses on CPU, memory, HTTP status codes, and latency.
LLM observability requires tracking text payloads, token counts, semantic quality, and multi-step reasoning chains. If a user complains "The AI gave me a bad answer," standard APM tools cannot help you debug it because the HTTP request was a `200 OK`.

## 2. Key Metrics to Track
1. **Token Usage & Cost:** Tracked by `model`, `user_id`, and `feature_name`.
2. **Latency (TTFT & Total):** Time to First Token (critical for streaming UX) and Total Generation Time.
3. **User Feedback:** Explicit thumbs up/down, or implicit (e.g., user copied the generated text, user immediately regenerated).
4. **Quality / Pass Rates:** For structured outputs, how often does validation fail?

## 3. The Tracing Stack
When using complex systems like RAG or Agents, a single user request might trigger 5 different LLM calls and 2 database searches.

### The Trace Tree
- **Trace:** The overall user request.
  - **Span 1 (Retrieval):** Embedding the query, searching Pinecone.
  - **Span 2 (LLM):** Generating the answer using context.
  - **Span 3 (Guardrail):** Checking the answer for toxicity.

Tools like **Langfuse, LangSmith, and Helicone** visualize this tree, showing the exact prompt, response, latency, and cost of *every step*.

## 4. Implementation Patterns

### Python Example (using Langfuse)
```python
from langfuse.decorators import observe
from openai import OpenAI

client = OpenAI()

@observe() # Automatically creates a span for this function
def retrieve_documents(query: str):
    # vector DB logic
    return ["Doc 1", "Doc 2"]

@observe() # Creates another span
def generate_answer(query: str, docs: list):
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": f"Context: {docs}. Query: {query}"}]
    )
    return response.choices[0].message.content

@observe() # The root trace
def handle_user_request(query: str):
    docs = retrieve_documents(query)
    answer = generate_answer(query, docs)
    return answer
```

## 5. Drift Detection & Quality Monitoring
Over time, LLM behavior changes (models are secretly updated, or user behavior shifts).
- **Automated Evaluations in Prod:** Run a sample (1%) of production logs through an "LLM-as-a-judge" pipeline nightly to score relevance, tone, and correctness.
- **A/B Test Analysis:** Route 50% of traffic to Prompt A and 50% to Prompt B. Compare the average user feedback score in your observability dashboard.

---

## Interview Questions

**Q1: A user reports that the chatbot gave them a completely hallucinated answer yesterday at 2 PM. How do you investigate this using your observability stack?**
**A:** 
1. Search the observability platform (e.g., LangSmith) for traces attached to that `user_id` around 2 PM.
2. Open the specific trace to see the full execution tree.
3. Check the **Retrieval Span**: Did the vector database return the correct context? If the context was wrong, it's an embedding/search issue, not an LLM hallucination.
4. Check the **Generation Span**: If the correct context was provided, look at the exact prompt sent to the LLM. Did the prompt lack strict instructions to ground its answer? 
5. Add this specific query to our regression test suite to ensure future prompt updates fix this behavior.

**Q2: We want to switch from GPT-4 to Claude 3.5 Sonnet to save costs. How do we ensure this doesn't degrade user experience in production?**
**A:** We use Shadow Deployment and Observability.
1. Implement the abstraction layer to route to Claude.
2. Shadow mode: Route the user's traffic to GPT-4 (and return it to the user), but asynchronously send the *same* prompt to Claude and log both responses to our observability tool.
3. Run an automated LLM-as-a-judge evaluator over the paired outputs, scoring Claude's answers against GPT-4's.
4. If Claude's win-rate is > 95%, we transition to a 10% canary rollout in production, actively monitoring explicit user thumbs-up/down metrics.
