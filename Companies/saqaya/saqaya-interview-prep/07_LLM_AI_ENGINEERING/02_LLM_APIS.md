# LLM APIs and Integration

## 1. OpenAI API Deep Dive

### Chat Completions
The core endpoint (`/v1/chat/completions`). It takes a list of messages (System, User, Assistant) and returns an assistant message.
- **System:** High-level instructions, constraints, and persona.
- **User:** The current query.
- **Assistant:** Past responses (used to maintain conversation history).

### Structured Outputs (Tools / Function Calling)
Allows the model to output JSON matching a specific JSON Schema.
- **When to use:** Extracting structured data, triggering external API calls, querying databases.
- **How it works:** The model is fine-tuned to recognize `tools` in the payload and outputs a `tool_calls` block instead of plain text. In newer API versions (`Strict: true`), OpenAI uses constrained decoding to guarantee 100% schema adherence.

### Vision
Passing `image_url` or base64 strings in the user message content array.
- **Trade-offs:** High token cost (images are chunked into tokens).

## 2. API Comparison (OpenAI vs Anthropic vs Google)

| Feature | OpenAI (GPT-4o) | Anthropic (Claude 3.5) | Google (Gemini 1.5) |
| :--- | :--- | :--- | :--- |
| **Context Window** | 128k | 200k | 1M - 2M |
| **Tool Calling** | Excellent, strict schemas | Very good, uses XML internally | Good, native support |
| **Prompt Caching** | Native, automatic | Explicit via `ephemeral` tags | Context Caching API |
| **Safety Filters** | Standard | Can be overly cautious | Configurable via API |
| **Pricing Model** | Per 1k/1M tokens | Per 1k/1M tokens + Caching | Per 1k/1M tokens + Caching |

## 3. Streaming Responses
### What
Returning tokens to the client as they are generated using Server-Sent Events (SSE).

### Why
Reduces perceived latency (Time to First Token - TTFT). Crucial for UX in chat applications.

### How (Python & TypeScript)

**TypeScript (OpenAI SDK):**
```typescript
import OpenAI from 'openai';

const openai = new OpenAI();

async function streamResponse() {
  const stream = await openai.chat.completions.create({
    model: 'gpt-4o',
    messages: [{ role: 'user', content: 'Write a poem.' }],
    stream: true, // Key parameter
  });

  for await (const chunk of stream) {
    process.stdout.write(chunk.choices[0]?.delta?.content || '');
  }
}
```

**Python (OpenAI SDK):**
```python
from openai import OpenAI
import sys

client = OpenAI()

def stream_response():
    stream = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": "Write a poem."}],
        stream=True,
    )
    for chunk in stream:
        if chunk.choices[0].delta.content is not None:
            sys.stdout.write(chunk.choices[0].delta.content)
            sys.stdout.flush()
```

### Trade-offs & Failure Modes
- **Trade-offs:** Makes error handling harder. If an error occurs mid-stream, the HTTP status is already 200 OK. You must handle stream interruptions gracefully on the client.
- **Tool Calling:** Streaming tool calls requires accumulating JSON chunks and parsing them only when the stream finishes or using a robust streaming JSON parser.

## 4. Token Counting
### Why
Tokens dictate cost and context limits. You must count tokens *before* sending requests to avoid 400 Context Length Exceeded errors and to estimate costs.

### How
Use library-specific tokenizers (e.g., `tiktoken` for OpenAI).

**Python Example:**
```python
import tiktoken

def count_tokens(text: str, model: str = "gpt-4o") -> int:
    encoding = tiktoken.encoding_for_model(model)
    return len(encoding.encode(text))
```

## 5. Rate Limits & Quotas
### Types
- **RPM (Requests per minute):** Number of HTTP calls.
- **TPM (Tokens per minute):** Total tokens (input + output).
- **TPD (Tokens per day):** Daily budget limits.

### Error Handling (HTTP 429)
When hitting rate limits, providers return HTTP 429.
- **Handling:** Implement Exponential Backoff with Jitter. Do not retry immediately.
- **Headers:** Check `x-ratelimit-reset-tokens` headers to know exactly how long to wait.

---

## Interview Questions

**Q1: How do you handle HTTP 429 Rate Limit errors in a high-throughput pipeline?**
**A:** 
1. Use an exponential backoff retry mechanism (e.g., `tenacity` in Python).
2. Read the specific Rate Limit headers returned by the provider (like `retry-after` or `x-ratelimit-reset-requests`) to delay the thread exactly as long as needed rather than guessing.
3. At an architectural level, decouple incoming requests from API calls using a message queue (e.g., SQS, Kafka). Consumers can pull from the queue at a rate configured to stay just under the TPM limit.
4. Distribute load across multiple API keys, organizations, or cloud regions (e.g., Azure OpenAI round-robin routing).

**Q2: You have an application where users can chat with massive PDF documents. The context length is getting too large and costly. How do you optimize the API usage?**
**A:**
1. **Chunking & RAG:** Don't send the whole PDF. Chunk it, embed it, and only retrieve the top-K relevant chunks for the user's specific question.
2. **Prompt Caching:** If using Anthropic or OpenAI, leverage Prompt Caching. If the system prompt + PDF text remains static, subsequent requests from the same user will hit the cache, reducing costs by 50-90% and dropping TTFT significantly.
3. **Summarization chains:** Periodically summarize the chat history rather than passing the raw history array on every turn.
