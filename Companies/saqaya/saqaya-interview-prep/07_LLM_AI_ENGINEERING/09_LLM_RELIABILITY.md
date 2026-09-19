# LLM Reliability

## 1. What is LLM Reliability?
Unlike traditional deterministic software (where `add(2, 2)` always returns `4`), LLMs are fundamentally probabilistic. The same prompt can yield different outputs, structures, or logic across multiple calls. 
Building a *reliable* LLM system means engineering the architecture surrounding the LLM to handle, mitigate, and correct this non-determinism so the end-user experiences a consistent, dependable product.

## 2. Handling Non-Determinism
### Temperature Control
Set `temperature=0` (or as close to 0 as possible) for tasks requiring factual extraction, classification, or strict formatting. Note: Even at `T=0`, floating-point math across GPUs can introduce slight non-determinism, though OpenAI's `seed` parameter helps mitigate this.

### Self-Correction Loops
Implement application-level logic that validates the LLM's output. If validation fails, automatically re-prompt the LLM with the error message.
*See `04_STRUCTURED_OUTPUTS.md` for implementation details.*

## 3. Guardrails & Output Validation
You cannot trust the raw string output of an LLM. It must pass through "Guardrails" before being presented to the user or downstream systems.

### Guardrails Types:
- **Structural Guardrails:** Enforcing JSON/XML formats (Pydantic, Zod).
- **Semantic Guardrails:** Ensuring the content aligns with policy (e.g., checking if the generated text is toxic, off-topic, or competitors are mentioned).
- **Factual Guardrails:** For RAG, using a secondary smaller model to verify that the generated answer is strictly entailed by the retrieved context.

**Python Example using `NeMo-Guardrails` concepts:**
```python
def check_toxicity(text: str) -> bool:
    # Fast, cheap classifier model or regex
    return fast_classifier(text) > 0.8

def reliable_generation(prompt: str):
    response = call_llm(prompt)
    
    if check_toxicity(response):
        return "I'm sorry, I cannot generate an appropriate response for that query."
        
    return response
```

## 4. Quota Management & Degraded Mode
When an LLM provider goes down, or you hit hard quota limits, a reliable system degrades gracefully rather than crashing.

### Fallback to Cheaper/Faster Models
If GPT-4o fails or times out, seamlessly route the request to Claude 3.5 Haiku. (See Provider Abstraction).

### Degraded Mode Operations
If all LLM APIs are down, the UI should gracefully inform the user. Alternatively, cache common queries statically. 
If you are generating a daily report via LLM, and the API fails, fall back to a deterministic, template-based statistical report (no natural language generation, just raw numbers).

## 5. Health Monitoring (Liveness vs Readiness)
Standard health checks (`/health`) just check if the web server is running. For LLM applications, you need deep health checks.
- **Dependency Health:** Is the OpenAI API actually reachable? (Ping `https://api.openai.com/v1/models`).
- **Semantic Health:** Is the model generating garbage? Run a synthetic prompt (e.g., "Reply with exactly 'OK'") every 5 minutes. If it returns something else, alert on-call.

---

## Interview Questions

**Q1: Our LLM pipeline occasionally outputs competitors' names in its marketing copy, which violates brand guidelines. How do you reliably prevent this in production?**
**A:** I would implement a multi-layered guardrail approach.
1. **Prompt Level:** Add strict negative constraints in the system prompt: "NEVER mention competitors like X, Y, or Z."
2. **Output Validation (Regex/Lexical):** Implement a fast, deterministic post-processing step. Check the generated string against a dictionary of competitor names. If found, automatically retry the generation.
3. **Semantic Guardrail:** For subtle references, pass the output to a fast, cheap model (like Haiku) with the prompt: "Does this text refer to any competing brands? Yes/No." If yes, discard and retry.

**Q2: We use an LLM to classify user intents for our chatbot. It works 95% of the time, but 5% of the time it generates intents that don't exist in our system, breaking the router. How do we fix this?**
**A:** This is a classic non-determinism failure. 
1. The immediate fix is using **Constrained Decoding** (OpenAI Strict Structured Outputs or `instructor` with Pydantic/Zod enums). This mathematically forces the LLM to only output valid tokens from our predefined Enum list of intents.
2. If constrained decoding isn't available, we implement a fallback router: if the LLM outputs an unknown intent, catch the exception, and default to the "Human Handoff" or "Clarification" intent rather than crashing the application.
