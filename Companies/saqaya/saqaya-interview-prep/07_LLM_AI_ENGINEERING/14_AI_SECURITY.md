# AI Security & Data Privacy

## 1. Data Privacy with LLMs
When using public APIs (OpenAI, Anthropic), you are sending your application's data outside your VPC.
### Key Considerations:
- **Zero Data Retention Policies:** Ensure you are using Enterprise tiers. OpenAI's API (unlike ChatGPT) does not train on customer data by default, but you must ensure your enterprise agreement explicitly stipulates Zero Data Retention (ZDR) if handling sensitive PII or PHI.
- **PII Scrubbing:** If you cannot guarantee ZDR, implement a middleware layer (e.g., AWS Comprehend, Presidio) to detect and mask PII (names, SSNs, emails) *before* it hits the LLM API, and unmask it when the response returns.

## 2. Model Access Control (RAG Security)
**The Problem:** You build an internal RAG bot that can search your company's Confluence and Google Drive. An intern asks, "What is the CEO's salary?" The LLM retrieves the HR document and tells them.
**The Fix:** The LLM itself has no concept of permissions. Access control MUST happen at the retrieval layer.
1. When embedding documents, store the ACL (Access Control List) metadata in the vector database.
2. When the user queries, pass their identity/roles to the vector database.
3. The vector database filters the search space *before* returning chunks to the LLM. 
If the chunks aren't retrieved, the LLM can't leak the data.

## 3. Threat Modeling: LLM Vulnerabilities
According to OWASP Top 10 for LLMs:
- **LLM01: Prompt Injection** (See `15_PROMPT_INJECTION.md`).
- **LLM02: Insecure Output Handling:** Treating LLM output as safe, leading to XSS or SQL injection if the LLM generates malicious code that the backend executes.
- **LLM03: Training Data Poisoning:** If you fine-tune, malicious actors might poison the dataset.
- **LLM04: Model Denial of Service:** Attackers sending complex, token-heavy requests to exhaust your API budget (Wallet Exhaustion) or compute resources.

## 4. API Key Management & Proxying
**NEVER** put OpenAI API keys in frontend code (React/Mobile apps). 
All LLM requests must go through your backend or an LLM Gateway (like Cloudflare AI Gateway, Kong, or LiteLLM Proxy).
- **Why?** To enforce rate limits per user, mask the API key, apply guardrails, and track costs.

## 5. Insecure Output Handling Mitigation
If an LLM is asked to generate HTML, markdown, or SQL, it might generate malicious payloads (either by hallucination or via prompt injection).
- **SQL:** Never let an LLM run SQL directly. Let it generate the query string, but execute it using read-only database credentials with restricted scope.
- **HTML/JS:** Always sanitize LLM output using tools like `DOMPurify` before rendering it in a browser, just as you would with any user-generated content.

---

## Interview Questions

**Q1: We are building a medical summarization app. Doctors will paste patient notes into our app, which uses OpenAI to summarize them. What are the engineering and security steps required to make this compliant?**
**A:** 
1. **Compliance (HIPAA):** We cannot use standard OpenAI accounts. We must sign a BAA (Business Associate Agreement) with OpenAI or use Azure OpenAI with a BAA.
2. **Data Retention:** Ensure Zero Data Retention is enforced at the API level so patient data is never stored on OpenAI servers.
3. **Anonymization Layer:** Implement an on-premise or VPC-bound pre-processing step (like Microsoft Presidio) to detect and redact PHI (names, DoB) replacing them with tokens (e.g., `[PATIENT_NAME]`) before it hits the API.
4. **Access Logging:** Implement strict audit logging for every request, tying the action to the specific doctor's IAM identity.

**Q2: What is "Wallet Exhaustion" in the context of LLM applications, and how do you prevent it?**
**A:** Wallet Exhaustion (or Economic DoS) occurs when an attacker spams an LLM endpoint, causing the application to rack up massive API bills with the provider (OpenAI/Anthropic). 
To prevent it:
1. Implement strict per-user Rate Limiting and Token Quotas at the API Gateway.
2. Require authentication for all LLM routes.
3. Implement CAPTCHAs or Web Application Firewalls (WAF) to block bot traffic.
4. Set hard spending limits / billing alerts on the provider dashboard so the API shuts down rather than bankrupting the company.
