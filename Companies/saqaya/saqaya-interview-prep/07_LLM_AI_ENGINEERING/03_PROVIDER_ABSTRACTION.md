# Provider Abstraction & Model Routing

## 1. Why Abstract LLM Providers?
In production, relying directly on `import openai` tightly couples your architecture to a single vendor.
- **Reliability (Vendor Lock-in):** If OpenAI goes down (which happens), your app goes down.
- **Cost Optimization:** Some tasks are simple and can be routed to a cheaper model (e.g., Claude Haiku or GPT-4o-mini).
- **Compliance/Privacy:** Certain sensitive customers might require routing their data through a self-hosted open-source model (Llama 3) or Azure OpenAI rather than public APIs.
- **A/B Testing:** You need to swap models seamlessly to measure performance impacts.

## 2. Abstraction Layer Design
An abstraction layer creates a unified internal API. Regardless of the underlying provider, the input is standardized (e.g., OpenAI chat format) and the output is standardized.

### LiteLLM (Industry Standard)
LiteLLM is a popular open-source Python library and proxy server that standardizes 100+ LLM APIs using the OpenAI format.

**Python Example using LiteLLM:**
```python
from litellm import completion
import os

# Set environment variables for different providers
os.environ["OPENAI_API_KEY"] = "sk-..."
os.environ["ANTHROPIC_API_KEY"] = "sk-ant-..."

def generate_response(prompt: str, model_name: str):
    # The API call looks identical regardless of the model
    response = completion(
        model=model_name, # "gpt-4o", "claude-3-5-sonnet-20240620", "gemini/gemini-1.5-pro"
        messages=[{"role": "user", "content": prompt}]
    )
    return response.choices[0].message.content
```

## 3. Fallback Chains
When a primary model fails (due to downtime, rate limits, or content filtering), the system should automatically retry with a secondary model.

**Python Fallback Implementation:**
```python
from litellm import completion
from litellm.exceptions import RateLimitError, APIConnectionError

fallback_models = ["gpt-4o", "claude-3-5-sonnet-20240620", "azure/gpt-4o"]

def robust_completion(messages):
    for model in fallback_models:
        try:
            print(f"Trying {model}...")
            response = completion(model=model, messages=messages)
            return response
        except (RateLimitError, APIConnectionError) as e:
            print(f"Model {model} failed: {str(e)}. Falling back...")
            continue
    
    raise Exception("All fallback models failed.")
```

## 4. Model Routing
Routing dynamically selects the best model based on the request's characteristics.
- **Complexity Routing:** Use a classifier (or a fast, cheap LLM) to grade the prompt's complexity. Simple tasks -> GPT-4o-mini. Hard reasoning tasks -> Claude 3.5 Sonnet.
- **Semantic Routing:** Embed the incoming prompt and check it against a vector database of cached answers or known intents. If it matches a "customer support" intent, route to Model A.

## 5. TypeScript Implementation Patterns
In TypeScript, you typically define an interface that all provider classes must implement.

```typescript
// 1. Define the standard Interface
export interface ChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

export interface LLMProvider {
  name: string;
  generate(messages: ChatMessage[], temperature?: number): Promise<string>;
  generateStream(messages: ChatMessage[]): AsyncIterable<string>;
}

// 2. Implement OpenAI
export class OpenAIProvider implements LLMProvider {
  name = 'openai';
  private client: OpenAI;
  // ... initialization ...
  async generate(messages: ChatMessage[]): Promise<string> {
    const res = await this.client.chat.completions.create({
        model: 'gpt-4o',
        messages,
    });
    return res.choices[0].message.content!;
  }
  // ... stream implementation ...
}

// 3. Implement Anthropic (translating internal format to Anthropic's format)
export class AnthropicProvider implements LLMProvider {
  name = 'anthropic';
  private client: Anthropic;
  // ... initialization ...
  async generate(messages: ChatMessage[]): Promise<string> {
    // Anthropic extracts System prompt separately
    const systemMessage = messages.find(m => m.role === 'system')?.content || '';
    const userMessages = messages.filter(m => m.role !== 'system');
    
    const res = await this.client.messages.create({
        model: 'claude-3-5-sonnet-20240620',
        system: systemMessage,
        messages: userMessages.map(m => ({ role: m.role as any, content: m.content })),
        max_tokens: 1024
    });
    return (res.content[0] as any).text;
  }
}

// 4. The Router
export class LLMRouter {
  constructor(private providers: LLMProvider[]) {}
  
  async executeWithFallback(messages: ChatMessage[]): Promise<string> {
    for (const provider of this.providers) {
      try {
        return await provider.generate(messages);
      } catch (error) {
        console.warn(`${provider.name} failed, trying next...`);
      }
    }
    throw new Error("All providers failed");
  }
}
```

## 6. Provider-Specific Features vs Common Interface
**The Trade-off:** The lowest common denominator problem. If you abstract everything into standard Chat Completions, you lose provider-specific superpowers (e.g., Gemini's native Video understanding, Anthropic's specific caching headers, OpenAI's strict structured outputs).
**Solution:** The abstraction layer should accept an `**kwargs` or `options` object that allows passing provider-specific parameters which get ignored by other providers.

---

## Interview Questions

**Q1: We are building an LLM router to optimize for cost. How would you design it?**
**A:** I would implement a two-stage routing architecture. 
First, I'd use a fast semantic router (e.g., using fast embeddings and cosine similarity against a vector store of historical requests). If the prompt matches a known, simple task type (like "translate this text" or "summarize this email"), it routes to a fast, cheap model (GPT-4o-mini).
If it's an unrecognized or complex reasoning task (like writing code or complex logic), it routes to a frontier model (GPT-4o / Claude 3.5). 
I'd monitor the user feedback/success rates on the cheaper model and adjust the semantic thresholds dynamically.

**Q2: What is the main engineering challenge when migrating an application heavily reliant on OpenAI's Function Calling over to Anthropic?**
**A:** The primary challenge is the structural difference in how tools are defined and how the model responds. While libraries like LiteLLM map the schemas natively now, the *behavior* of the models differs. Anthropic models often prefer a lot of context in the XML tags or system prompt about *when* to use the tool, whereas OpenAI is heavily RLHF'd to trigger tools just based on the JSON schema. Additionally, error handling for tool failures needs to be adapted because the syntax of the tool-use blocks varies between providers, meaning your parsing logic (if doing it manually) will break. Extensive regression testing (using evaluation datasets) is mandatory before fully cutting over.
