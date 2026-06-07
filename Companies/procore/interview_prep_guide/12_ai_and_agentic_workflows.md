# AI & Agentic Workflows in Construction

> Procore is heavily investing in AI (Procore Helix, Procore Assist). You must be able to speak about AI beyond just "using ChatGPT to write code."

---

## 1. Using Generative AI as an Engineer

**How to answer "How are you using AI daily?":**

> "I use generative AI as an engineering accelerator, but I do not treat it as a replacement for engineering judgment. I use it for code review preparation, generating test case variations, refactoring ideas, drafting ADRs, and exploring unfamiliar libraries. I still validate the output through tests, security review, and production constraints."

---

## 2. AI Features vs. Agentic Workflows

### AI Feature (Basic)
- Single-turn interaction
- Example: "Summarize this PDF" or "Translate this RFI to Spanish"
- Output is informational

### Agentic Workflow (Advanced)
- Multi-step, goal-oriented
- Can interact with systems, retrieve context, and execute actions
- Uses tools, asks for permission, loops on feedback

**Agentic Workflow capabilities:**
1. Understand the user's goal
2. Break it into steps (Planning)
3. Retrieve relevant context (RAG)
4. Suggest or execute actions using tools (API calls)
5. Ask for human approval when needed
6. Leave an audit trail

---

## 3. Designing an Agentic Workflow for Procore

**Scenario:** Daily Log Assistant for a Construction Site

Instead of a basic AI feature ("Summarize today's notes"), design an agent that acts like a digital assistant for the Superintendent.

### The Workflow
1. **Context Retrieval:** Agent reads project schedule, weather, site notes, photos, RFIs, and subcontractor updates
2. **Analysis:** Detects missing daily log sections or discrepancies
3. **Drafting:** Suggests likely work completed and flags safety incidents/blockers
4. **Human-in-the-Loop:** Asks Superintendent to approve, edit, or reject the draft
5. **Execution:** Submits the official daily log to the database
6. **Audit:** Records what data was used, what changed, and who approved it

### Architecture Layers
1. **Context Retrieval Layer** — vector DB / pgvector for semantic search, heavily permission-filtered
2. **Planning Layer** — LLM orchestrator breaks task into steps
3. **Tool Layer** — defined functions the agent can call (e.g., `get_weather`, `read_schedule`, `draft_log`)
4. **Policy Layer** — enforces permissions, rate limits, safety guardrails
5. **Human-in-the-Loop Layer** — UI block requiring explicit confirmation
6. **Audit Layer** — stores prompt metadata, sources used, and final action

---

## 4. Risks and Guardrails (Crucial for Staff Level)

When discussing AI, always emphasize safety and reliability.

| Risk | Guardrail / Mitigation |
|------|------------------------|
| **Hallucination** | Ground responses in Procore data (RAG). Show citations/links to source documents. |
| **Permission Leakage** | Context retrieval MUST respect the user's project/company role. Never feed unauthorized data into the context window. |
| **Unsafe Actions** | Limit tool permissions. Require explicit human approval (Human-in-the-Loop) for any action that affects records, external users, or contracts. |
| **Lack of Trust** | Transparent audit trails. Explain *why* the AI made a suggestion. |
| **Cost & Latency** | Semantic caching (e.g., querying pgvector for similar cached prompts). Async processing for non-blocking UI. |

---

## 5. Staff-Level Platform Thinking

> "As a Staff Engineer, I would push for reusable AI platform capabilities rather than one-off AI features. That means building common patterns for retrieval, tool execution, authorization, audit logs, evaluation, and prompt management. This lets multiple teams build AI features safely and consistently, rather than every team reinventing RAG."

---

## 6. Personal Story Connection

If asked about your AI experience, leverage your work on the AI recommendation engine:

**Context:** Built an AI-driven platform.
**Action:** Implemented semantic search using vector databases. Optimized API costs and latency by caching embedding similarities (cosine similarity).
**Result:** Delivered sub-100ms response times and drastically reduced LLM API costs.
**Relevance:** Proves you know how to run AI in production efficiently, not just build a prototype.
