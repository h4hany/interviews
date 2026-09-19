# Retries, Timeouts & Circuit Breakers

## 1. LLM-Specific Retry Strategies
LLM APIs are notoriously flaky due to massive compute demands. Transient errors (500s, 502s) and rate limits (429s) are common.

### Exponential Backoff with Jitter
Never retry immediately. Wait 1s, then 2s, then 4s. Add "jitter" (randomized variance) to prevent the "thundering herd" problem where all your failing instances retry at the exact same millisecond and take down the provider again.

**Python Example (Tenacity):**
```python
from tenacity import retry, wait_random_exponential, stop_after_attempt
import openai

@retry(wait=wait_random_exponential(min=1, max=60), stop=stop_after_attempt(5))
def call_llm_with_retry(messages):
    return openai.chat.completions.create(
        model="gpt-4o",
        messages=messages
    )
```

## 2. Timeout Design
LLM calls can hang or take 60+ seconds for long generations. You must define strict timeouts.
- **Connection Timeout:** Time to establish the TCP connection (e.g., 5s).
- **Read Timeout (TTFT):** Time waiting for the *first* token. If the model is congested, it might take 20s to start generating. (e.g., 15s).
- **Total Timeout:** Maximum time allowed for the whole generation (e.g., 60s).

If a timeout occurs, you can fall back to a faster, smaller model (e.g., GPT-4o-mini).

## 3. Circuit Breakers
If OpenAI goes down completely, hammering their API and waiting 10 seconds for a timeout on every request will exhaust your application's connection pool and crash your backend.
**Circuit Breaker Pattern:**
If X requests fail sequentially within Y seconds, "open" the circuit. All subsequent requests immediately fail (or instantly route to Anthropic/Azure) without even trying OpenAI, giving it time to recover. After a cooldown, "half-open" the circuit to test one request.

**TypeScript Example (using `opossum`):**
```typescript
import CircuitBreaker from 'opossum';
import { callOpenAI } from './llm';

const options = {
  timeout: 30000, // 30s timeout per request
  errorThresholdPercentage: 50, // Open circuit if 50% of requests fail
  resetTimeout: 30000 // Wait 30s before trying again
};

const breaker = new CircuitBreaker(callOpenAI, options);

breaker.fallback(() => {
  return callAnthropicFallback(); // Route to backup provider immediately
});

async function handleRequest(prompt: string) {
  return await breaker.fire(prompt);
}
```

## 4. Idempotency for LLM Calls
If a client sends a request, the LLM starts processing (costing money), but the client drops the connection (e.g., mobile user loses signal). If they reconnect and retry, you don't want to run the expensive prompt again.
**Solution:** Use Idempotency Keys. Hash the prompt or generate a UUID on the client. Cache the generated response against this key. If the same key is seen again, return the cached result.

## 5. Streaming Timeout Patterns
When streaming, the HTTP connection stays open. You must monitor the *time between chunks*. If the stream stalls for 10 seconds mid-sentence, you should abort the connection and handle the partial response or retry.

---

## Interview Questions

**Q1: Our backend is crashing with "Connection Pool Exhausted" errors during OpenAI outages. How do you fix this?**
**A:** During an outage, LLM requests hit their maximum timeouts (e.g., 60 seconds). This keeps our server's worker threads/connections tied up waiting for a response that will never come. New incoming traffic queues up, eventually exhausting the connection pool and taking down the whole API. 
To fix this, I would implement a **Circuit Breaker**. If failure rates or latency exceed a threshold, the circuit trips. Subsequent requests will immediately fail-fast (or route to a fallback provider) within 10ms instead of 60s, keeping our worker threads free and the core application healthy.

**Q2: We are hitting our token rate limits (HTTP 429) consistently. Retries are just making it worse. What's the architectural fix?**
**A:** Standard exponential backoff isn't enough if the basal throughput exceeds the provider limit. We need to implement a Queue-based asynchronous architecture.
Incoming user requests are pushed to a message broker (Kafka/RabbitMQ/SQS). Worker nodes pull from this queue at a strictly rate-limited pace (e.g., max 500 tokens per minute). If the queue backs up, we communicate the delay to the user asynchronously (via websockets or polling). Additionally, we can implement dynamic routing to shift excess load to secondary API keys or different cloud regions.
