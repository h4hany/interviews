# SAQAYA LLM/AI Engineering Interview Questions

This document covers the most critical LLM-specific questions you will face during a Technical Lead interview at SAQAYA, focusing on platform ownership, architecture, and production discipline.

---

## 1. How would you design the generation platform architecture?

**What they're testing:** 
Can you think beyond a single `import openai` script? Do you understand enterprise-grade AI architecture (gateways, routing, caching, observability)?

**Strong Technical Lead Answer:**
"I design generation platforms as a centralized middleware layer—an 'AI Gateway'—that sits between our internal microservices and external LLM providers. 

The architecture consists of four main layers:
1. **API Gateway & Auth:** All internal services call this gateway. It enforces rate limits per tenant/service and handles auth.
2. **Router & Abstraction Layer:** Services don't ask for 'GPT-4'; they ask for a capability like `reasoning-heavy` or `fast-extraction`. The router translates this, manages fallback chains (if OpenAI is down, seamlessly hit Anthropic), and load-balances across multiple API keys or Azure regions.
3. **Value-Add Middleware:**
   - **Semantic Cache (Redis):** Hashes queries to bypass the LLM for repeated questions.
   - **Guardrails:** Scans incoming prompts for PII/Injection and outgoing responses for toxicity.
   - **Prompt Registry:** Fetches versioned prompt templates dynamically.
4. **Async Observability:** Every request is tagged. Token usage, latency, and costs are pumped into Datadog/LangSmith asynchronously so we don't block the critical path."

**Common Mistakes:** 
Designing a monolithic backend where every service directly integrates provider SDKs. Ignoring async/streaming patterns.

**Follow-up Questions:** 
- How do you handle streaming responses through this gateway?
- Where does RAG happen in this architecture?

---

## 2. How do you implement provider abstraction?

**What they're testing:** 
Do you understand the trade-offs of vendor lock-in versus "lowest common denominator" APIs?

**Strong Technical Lead Answer:**
"Provider abstraction is critical for reliability and cost control. I implement it using an interface pattern, often leaning on tools like LiteLLM for Python, but extending it for TypeScript.

The key is defining an internal unified standard (usually mirroring OpenAI's Chat Completions format because it's the industry standard). The abstraction layer takes this standard payload and translates it to Anthropic's XML-heavy format or Gemini's format.

However, the major challenge is **Tool Calling/Structured Outputs**. Providers handle JSON schemas differently. Therefore, our abstraction layer must strictly enforce JSON schema validation (via Zod/Pydantic) *after* the provider responds, implementing automatic retry loops if the provider hallucinates the schema."

**TypeScript Example:**
```typescript
interface LLMRequest {
  messages: Array<{role: string, content: string}>;
  schema?: z.ZodTypeAny; // Unified structured output request
}

class ProviderRouter {
  async execute(req: LLMRequest, tier: 'fast' | 'smart'): Promise<any> {
    const providers = tier === 'smart' 
      ? [new OpenAIProvider('gpt-4o'), new AnthropicProvider('claude-3-5')]
      : [new OpenAIProvider('gpt-4o-mini')];

    for (const provider of providers) {
      try {
        const response = await provider.generate(req);
        // Schema validation happens here, centrally
        if (req.schema) return req.schema.parse(JSON.parse(response));
        return response;
      } catch (e) {
        console.warn(`${provider.name} failed. Falling back...`);
      }
    }
    throw new Error("All providers exhausted.");
  }
}
```

---

## 3. Walk me through your approach to prompt discipline.

**What they're testing:** 
Do you treat prompts as fragile strings or as robust production code?

**Strong Technical Lead Answer:**
"Prompt discipline means treating prompts exactly like production code. 
1. **Versioning:** Prompts live in a version-controlled registry, not hardcoded in backend logic.
2. **Separation of Concerns:** We use strict templating (Jinja/Handlebars) to isolate the system instructions from user data variables, utilizing XML delimiters to prevent prompt injection.
3. **Automated Evaluation:** You cannot deploy a prompt change simply by merging a PR. The CI pipeline must run the new prompt against a 'Golden Dataset' of 500 edge cases. If the accuracy drops, or if token usage spikes by 20%, the deployment is blocked.
4. **Observability:** Every prompt execution in prod is tagged with `prompt_version: v2.1`. If we see a spike in latency or user complaints, we can instantly rollback the prompt template via the registry without deploying a new backend binary."

---

## 4. How do you manage LLM costs in production?

**What they're testing:** 
LLMs can bankrupt a startup. Do you have a systematic approach to unit economics?

**Strong Technical Lead Answer:**
"Cost management happens at three levels: Architecture, Prompting, and Observability.
1. **Architecture (Routing & Caching):** The easiest way to save money is not making the call. I implement Semantic Caching via Redis to catch duplicate queries. For the calls we must make, we use dynamic routing—sending 80% of routine tasks (like extraction) to GPT-4o-mini ($0.15/1M) and saving Claude 3.5 Sonnet ($15/1M) only for complex reasoning tasks.
2. **Prompting (Prompt Caching):** For heavy RAG workloads, I ensure the static system prompt and context chunks are placed at the *beginning* of the context window to hit Anthropic/OpenAI's native prompt cache, dropping input token costs by 50-80%. I also enforce chat history truncation—we don't send 50 turns of history, we slide the window to the last 4 turns.
3. **Observability:** I enforce tagging `tenant_id` and `feature_id` on every API call. We pipe this into our telemetry to build dashboards showing 'Margin per Tenant', allowing us to implement hard rate limits on abusive users."

---

## 5. How do you ensure structured outputs are reliable?

**What they're testing:** 
LLMs output unstructured text. Software needs JSON. How do you bridge the gap reliably?

**Strong Technical Lead Answer:**
"Reliability here requires three layers of defense:
1. **Constrained Decoding:** Wherever possible, I use OpenAI's Strict Structured Outputs (or `instructor` for other models). This forces the inference engine to only generate tokens that mathematically comply with the JSON schema, eliminating syntax errors entirely.
2. **Runtime Validation:** You can never trust the LLM output in strongly-typed code. I parse every LLM string through Pydantic (Python) or Zod (TypeScript). This guarantees that types are correct (e.g., we actually got an integer, not the string '42').
3. **Self-Correction Loops:** If validation fails (e.g., the LLM missed a required field), we catch the `ValidationError`, and programmatically send the exact error message back to the LLM in a new prompt: 'Your JSON failed validation: [Error]. Fix it.' We allow a maximum of 3 retries before failing gracefully."

**Python Example:**
```python
from pydantic import BaseModel, ValidationError
import json

def reliable_generation(prompt: str, schema: BaseModel, retries=3):
    messages = [{"role": "user", "content": prompt}]
    for _ in range(retries):
        response_str = call_llm(messages)
        try:
            return schema.model_validate_json(response_str)
        except ValidationError as e:
            messages.append({"role": "assistant", "content": response_str})
            messages.append({"role": "user", "content": f"JSON Validation Error: {e.json()}. Fix it."})
    
    raise Exception("LLM failed to output valid schema.")
```

---

## 6. How do you handle LLM provider outages?

**What they're testing:** 
System reliability and defensive programming.

**Strong Technical Lead Answer:**
"LLM APIs are notoriously flaky. My approach is:
1. **Exponential Backoff + Jitter:** For transient 429s (Rate Limits) or 502s, implement backoff. Jitter is critical to prevent thundering herd problems when the API recovers.
2. **Circuit Breakers:** If OpenAI goes completely down, timing out requests for 60 seconds will exhaust our server's connection pool and crash our entire application. A circuit breaker detects the failure rate, trips open, and instantly fails-fast (or routes to Anthropic) for subsequent requests, protecting our worker threads.
3. **Fallback Chains:** Abstracted routers automatically shift traffic to Azure OpenAI or Anthropic if the primary provider is degraded.
4. **Degraded UI Mode:** If all providers are down, the frontend must gracefully inform the user, disabling the AI features rather than showing infinite spinners."

---

## 7. How do you evaluate LLM output quality?

**What they're testing:** 
Do you know how to measure the unmeasurable (natural language)?

**Strong Technical Lead Answer:**
"Evaluating LLMs requires a multi-tiered approach:
1. **Deterministic Metrics:** For classification or extraction, we use exact match, JSON validation pass rates, and schema adherence.
2. **LLM-as-a-Judge (Offline):** For open-ended generation (like RAG), we use frameworks like RAGAS. We take production logs, and use GPT-4 to grade the output on 'Faithfulness' (did it hallucinate outside the context?) and 'Answer Relevance' (did it answer the prompt?).
3. **Human-in-the-loop (Online):** We track implicit and explicit user signals in production. Explicit: Thumbs up/down. Implicit: Did the user immediately regenerate the response? Did they copy the text to their clipboard? 

We aggregate these metrics in LangSmith/Datadog to detect quality drift over time or after model updates."

---

## 8. How do you handle prompt injection in production?

**What they're testing:** 
Security mindset and understanding of LLM vulnerabilities.

**Strong Technical Lead Answer:**
"Prompt injection is fundamentally unsolvable at the model layer right now, so we must mitigate it architecturally.
1. **Role Separation:** Use the Chat API's `system` vs `user` roles strictly. Models are heavily RLHF'd to prioritize system instructions over user data.
2. **Data Delimiting:** We wrap all untrusted user data in strict XML tags (e.g., `<user_data>`) and explicitly instruct the model to ignore any instructions found within those tags.
3. **Guardrail Middleware:** For highly sensitive applications, we run the prompt through a smaller, fast classifier model (or Azure Content Safety) to detect jailbreak intent *before* sending it to the main model.
4. **Tool Sandboxing:** This is the most critical. If an LLM has access to tools (like `delete_database`), it must operate on the Principle of Least Privilege. Destructive tools MUST have a 'Human-in-the-Loop' confirmation step. An injected prompt might convince the LLM to call `delete_database`, but the execution pauses pending human approval."
