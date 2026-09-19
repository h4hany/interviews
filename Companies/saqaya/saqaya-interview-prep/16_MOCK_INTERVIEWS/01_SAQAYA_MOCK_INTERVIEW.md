# SAQAYA Mock Interview Simulation

This mock interview is designed to simulate a full Technical Lead interview at SAQAYA, focusing on LLM platform design, AI-assisted engineering, and leadership.

## Interview Structure (60 Minutes)
- **Introduction & Past Experience (10 mins)**
- **Technical Deep-Dive & Architecture (20 mins)**
- **System Design & Coding Scenario (20 mins)**
- **Leadership & Code Review (10 mins)**

---

## Question 1: System Architecture & LLM Provider Abstraction
**Time Allocation:** 8 minutes

**Question:**
"We are building an eLearning platform that heavily relies on LLMs for grading, tutor chatbots, and content generation. Initially, we used OpenAI, but we want to build a provider-agnostic abstraction layer to route to Anthropic or self-hosted models for cost and privacy. How would you design this abstraction layer?"

**Ideal Answer:**
1. **Core Interface:** Define a standard `LLMClient` interface with methods like `generate_text`, `chat_stream`, `embed`.
2. **Provider Implementations:** Implement OpenAI, Anthropic, and local (e.g., vLLM) adapters adhering to the interface. Normalize inputs (messages, temperature) and outputs (tokens, choices).
3. **Router/Gateway Component:** Build a router (e.g., LiteLLM or custom API Gateway) that selects the provider based on:
   - Request type (complex reasoning -> GPT-4, quick summary -> Claude Haiku)
   - Fallback logic (retry Anthropic if OpenAI rate limits)
4. **Data Normalization:** Map provider-specific errors to internal standard errors.
5. **Observability:** Track token usage, latency, and costs per provider.

**Scoring Criteria:**
- **Strong:** Mentions specific patterns (Adapter, Strategy), handles streaming, addresses error handling/retries, and includes observability.
- **Average:** Basic interface idea but lacks detail on routing strategy or streaming normalization.
- **Red Flags:** Recommends hardcoding or completely switching without a fallback layer. Ignoring latency/streaming.

---

## Question 2: AI-Assisted Engineering Adoption
**Time Allocation:** 5 minutes

**Question:**
"You are tasked with increasing the engineering team's velocity by adopting AI-assisted tools like GitHub Copilot and Codeium. How do you roll this out safely and measure its impact?"

**Ideal Answer:**
1. **Security & Privacy Policy:** Ensure we have Enterprise licenses with zero data retention policies. Establish clear guidelines on what code can/cannot be sent.
2. **Phased Rollout:** Start with a pilot group (power users) to establish best practices.
3. **Training & Prompt Discipline:** Create an internal wiki/guild for prompt engineering, sharing effective prompts for writing tests, refactoring, or generating boilerplate.
4. **Metrics:** 
   - *Qualitative:* Developer satisfaction (surveys).
   - *Quantitative:* PR cycle time, test coverage increase, PR acceptance rate (avoiding raw SLOC count which AI inflates).
5. **Quality Guardrails:** Emphasize that developers remain accountable. AI code requires the same rigorous code review and CI/CD checks.

**Scoring Criteria:**
- **Strong:** Focuses on security/compliance first, proposes meaningful metrics (cycle time, satisfaction) over vanity metrics (lines of code).
- **Red Flags:** Suggests tracking lines of code generated. Ignores security/data privacy concerns.

---

## Question 3: Production Incident Handling (LLM Rate Limits)
**Time Allocation:** 7 minutes

**Question:**
"It's 2 PM on a Tuesday, peak usage for our platform. Suddenly, users report the AI tutor is failing to respond. You check Datadog and see 429 Too Many Requests from our primary LLM provider. Walk me through your incident response."

**Ideal Answer:**
1. **Acknowledge & Triage:** Acknowledge the alert, declare an incident, and assemble a quick war room.
2. **Immediate Mitigation (Containment):** 
   - Activate the kill switch or circuit breaker to fallback to a secondary provider (e.g., Anthropic or a cached fallback).
   - If no secondary provider is available, implement graceful degradation (e.g., display a friendly UI message rather than spinning loaders).
3. **Investigation:** Check if it's a provider-side issue (status page) or an internal bug (e.g., an infinite loop of prompt retries).
4. **Resolution:** Wait for provider recovery or stabilize on the fallback. 
5. **Post-Mortem:** Write a blameless post-mortem. Action items: implement provider fallback routing, better circuit breakers, and user-level rate limiting to prevent noisy neighbors from exhausting global quotas.

**Scoring Criteria:**
- **Strong:** Uses standard incident management framework. Prioritizes mitigation (fallback) before deep investigation. Proposes concrete long-term fixes.
- **Red Flags:** Spends time debugging *why* the 429 happened before stopping the bleeding for users.

---

## Question 4: Mock Coding Challenge (TypeScript)
**Time Allocation:** 15 minutes

**Question:**
"Write a TypeScript function that acts as a circuit breaker for an asynchronous API call (like calling an LLM). It should track failures and open the circuit if failures exceed a threshold. After a timeout, it should allow one test request."

**Ideal Answer Outline:**
```typescript
type CircuitState = 'CLOSED' | 'OPEN' | 'HALF_OPEN';

class CircuitBreaker {
    private state: CircuitState = 'CLOSED';
    private failureCount = 0;
    private nextAttempt = 0;

    constructor(
        private threshold: number, 
        private resetTimeoutMs: number
    ) {}

    async execute<T>(action: () => Promise<T>): Promise<T> {
        if (this.state === 'OPEN') {
            if (Date.now() > this.nextAttempt) {
                this.state = 'HALF_OPEN';
            } else {
                throw new Error("Circuit is OPEN");
            }
        }

        try {
            const result = await action();
            this.reset();
            return result;
        } catch (error) {
            this.recordFailure();
            throw error;
        }
    }

    private recordFailure() {
        this.failureCount++;
        if (this.failureCount >= this.threshold) {
            this.state = 'OPEN';
            this.nextAttempt = Date.now() + this.resetTimeoutMs;
        }
    }

    private reset() {
        this.failureCount = 0;
        this.state = 'CLOSED';
    }
}
```

**Scoring Criteria:**
- **Strong:** Clean, idiomatic TS. Handles the half-open state correctly. Understands async/await deeply.
- **Red Flags:** Messy state management, fails to handle promise rejections.

---

## Question 5: Code Review Scenario
**Time Allocation:** 10 minutes

**Scenario:**
"A mid-level developer submits a PR that directly calls the OpenAI SDK inside a React component's `useEffect`. It stores the API key in a standard `.env` file that is prefixed with `VITE_` or `NEXT_PUBLIC_`."

**Question:** How do you handle this code review?

**Ideal Answer:**
1. **Security Risk (Immediate Block):** Explain that prefixing the API key exposes it to the client side. Any user can steal the key. This is a P0 security risk.
2. **Architecture Correction:** Guide the developer to move the OpenAI call to a backend API route (e.g., Next.js API route or separate backend). The frontend should only call our internal API.
3. **Tone:** Be constructive and educational, not punitive. "Great initiative getting this feature working! However, there's a critical security concern here..."
4. **Follow-up:** Suggest implementing a Backend-For-Frontend (BFF) pattern.

**Scoring Criteria:**
- **Strong:** Immediately identifies the security flaw. Provides actionable, empathetic feedback. Suggests the architectural fix.
- **Red Flags:** Misses the client-side API key leak. Is overly harsh or toxic in review comments.

---

## Question 6: Technical Debt & Prioritization
**Time Allocation:** 5 minutes

**Question:**
"The team is pushing hard for a product launch, but you notice the LLM prompt management is becoming a mess of hardcoded strings scattered across the codebase. How do you balance fixing this tech debt versus delivering the features?"

**Ideal Answer:**
1. **Assess Impact:** Is the current state slowing down development or causing bugs? If so, it needs immediate attention.
2. **Incremental Refactoring (Boy Scout Rule):** Don't halt feature work. Introduce a centralized `PromptRegistry` and require all *new* prompts to use it. Migrate old ones as developers touch those files.
3. **Negotiation:** Discuss with Product. "If we spend 2 days centralizing prompts now, we can iterate on the new tutor feature 50% faster next week."

**Scoring Criteria:**
- **Strong:** Pragmatic approach. Doesn't stop the world for a rewrite. Negotiates with business stakeholders using business value.
- **Red Flags:** Demands a full rewrite immediately, ignoring business deadlines.
