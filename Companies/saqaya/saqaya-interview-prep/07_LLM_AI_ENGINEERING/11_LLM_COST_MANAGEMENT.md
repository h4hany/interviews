# LLM Cost Management

## 1. Token Economics
LLM APIs charge based on Tokens (usually per 1,000 or 1,000,000 tokens).
- **Input Tokens (Prompt):** The text you send to the model. Generally cheaper (e.g., $5 / 1M tokens).
- **Output Tokens (Completion):** The text the model generates. Much more expensive due to the autoregressive compute cost (e.g., $15 / 1M tokens).

As a Tech Lead, monitoring and optimizing these two numbers is critical to maintaining unit economics.

## 2. Model Downsizing & Routing
Do not use GPT-4o or Claude 3.5 Sonnet for everything.
- **Classification / Extraction:** GPT-4o-mini, Claude Haiku, or fine-tuned Llama-3-8B. (Cost drops from $5/1M to $0.15/1M).
- **Complex Reasoning:** Route only the hardest tasks to frontier models based on semantic routing or user tier.

## 3. Prompt Optimization for Cost
Every word in the system prompt is sent on *every single request*.
1. **Minify Prompts:** Remove polite filler. "Please if you don't mind, could you..." -> "Action:".
2. **Context Window Management:** In RAG, do not send the entire document. Retrieve only the top 3 most relevant chunks. Sending 10,000 tokens of context when only 500 are needed wastes money.
3. **Chat History Truncation:** Do not send the entire 50-message chat history. Use a sliding window (last 5 messages) or summarize the older history into a single paragraph.

## 4. Caching Strategies (Native vs. Application)
### Application Caching
(See `10_LLM_SCALABILITY.md`). Caching exact or semantic matches in Redis to avoid the API call entirely. Cost = $0.

### Provider-Native Prompt Caching
Anthropic and OpenAI offer native caching. If you send the same large system prompt or context (e.g., a massive PDF or codebase) repeatedly, the provider caches the KV states.
- **Impact:** Input token costs drop by 50-80%, and latency drops significantly.
- **Implementation:** Structure your prompts so the static, cacheable data (system instructions, documents) is at the *beginning* of the prompt, and the dynamic user data is at the *end*.

## 5. Batch API Pricing
For asynchronous, non-time-critical workloads (e.g., tagging historical data, nightly reports), use the provider's Batch API.
- **Cost:** Usually a 50% discount.
- **Latency:** Results returned within 24 hours.

## 6. Cost Observability & Alerting
You cannot optimize what you cannot measure.
- **Tagging:** Every LLM API request must include metadata headers (e.g., `user_id`, `feature_name`, `environment`).
- **Monitoring Tools:** Use Helicone, LangSmith, or Datadog to aggregate these tags.
- **Alerting:** Set budgets. "If feature X spends > $500 in 24h, trigger PagerDuty."

**TypeScript Tagging Example:**
```typescript
import { OpenAI } from 'openai';

const client = new OpenAI();

async function generate(prompt: string, userId: string, feature: string) {
  const response = await client.chat.completions.create({
    model: 'gpt-4o',
    messages: [{ role: 'user', content: prompt }],
  }, {
    // Inject headers for observability tools like Helicone
    headers: {
      'Helicone-User-Id': userId,
      'Helicone-Property-Feature': feature,
    }
  });
  return response;
}
```

---

## Interview Questions

**Q1: We deployed a new RAG feature. Users love it, but our OpenAI bill skyrocketed to $10,000/month. We need to reduce this by 80% without significantly degrading the UX. Walk me through your strategy.**
**A:**
1. **Switch Models (Immediate 90% reduction):** Test GPT-4o-mini or Claude Haiku. Often, if the RAG context is high quality, the reasoning requirement is low. Mini models are an order of magnitude cheaper.
2. **Implement Native Caching:** Ensure our system prompt and core retrieved documents are placed at the beginning of the context window to hit Anthropic/OpenAI's native prompt cache.
3. **Reduce Context Size:** Audit our vector retrieval. Are we sending 20 chunks when the answer is usually in the top 3? I would aggressively tune the top-k threshold.
4. **Semantic Caching (Application Layer):** Implement Redis semantic caching. Many users ask the exact same onboarding or support questions. Bypassing the LLM entirely for 30% of traffic yields pure savings.
5. **Summarize Chat History:** Instead of appending the full conversation array (which grows linearly in tokens on every turn), implement a sliding window of the last 4 turns.

**Q2: How do you handle cost allocation for a multi-tenant SaaS application using LLMs?**
**A:** Every LLM call must be tagged with the `tenant_id`. We wrap the provider SDK (e.g., using LiteLLM or a custom proxy) to intercept every response, extract the `usage.total_tokens`, multiply it by the known model cost rate, and emit a metric to our time-series database (Prometheus/Datadog) tagged with `tenant_id`. We then create dashboards to monitor margin-per-tenant and implement hard quotas in the application logic to prevent a single abusive tenant from running up the bill.
