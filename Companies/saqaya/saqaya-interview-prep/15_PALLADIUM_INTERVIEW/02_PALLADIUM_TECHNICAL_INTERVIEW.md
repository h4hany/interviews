# PALLADIUM TECHNICAL INTERVIEW GUIDE

## 1. How Palladium Evaluates Technical Candidates

### The Core Difference
Palladium is **not** a software engineering company; they are a global impact and development finance firm. Technology is a *means to an end*, not the product itself. 

Therefore, they evaluate technical candidates differently than a FAANG company or a pure SaaS startup.
- **Less emphasis on:** LeetCode hard algorithms, microsecond latency optimization, cutting-edge experimental frameworks.
- **High emphasis on:** Pragmatism, reliability, security, data privacy, cross-cultural communication, and the ability to translate technical constraints to non-technical domain experts.

They want a **Partner**, not just a "code monkey." They need someone who understands the *Why* behind the software.

---

## 2. Demonstrating Domain Understanding

To stand out, you must show you grasp their world:
- **Acknowledge the End User**: The end user isn't someone on a 5G iPhone in Silicon Valley. It might be a healthcare worker in rural Sub-Saharan Africa or a teacher in Southeast Asia.
- **Focus on Impact**: Frame your technical decisions around the outcomes. "I chose a monolithic architecture initially because it reduced operational overhead, allowing us to deliver the pilot program to the NGO two months faster."
- **Mention Compliance Proactively**: Show you are aware of GDPR, HIPAA, and localized data sovereignty laws.

---

## 3. The Art of Translation (Crucial Skill)

You will likely be interviewed by or work closely with Program Directors, Finance Experts, and Development Specialists. You must translate technical concepts effectively.

### Example 1: Explaining Database Architecture to a Program Director
**Don't say**: "We are using a distributed PostgreSQL cluster with read replicas and asynchronous replication to reduce latency."
**Do say**: "We're setting up a central hub for our data, with 'carbon copies' placed closer to the users in different countries. This ensures that when a user in Kenya opens the app, it loads instantly because they are reading from a local copy, while all the data remains perfectly synced with HQ."

### Example 2: Explaining LLM Costs to a Finance Director
**Don't say**: "The API charges $15 per million output tokens for Sonnet 3.5, and our context window is growing, so inference costs will spike."
**Do say**: "The AI charges us based on how much it has to 'read' and how much it has to 'write.' Right now, we are forcing it to read an entire textbook every time a user asks a simple question. I plan to build a summary system so it only reads the relevant chapter, which will cut our monthly AI bill by 70% without losing accuracy."

### Example 3: Explaining Security to a Compliance Officer
**Don't say**: "We encrypt data at rest using AES-256 and use TLS 1.3 in transit with IAM roles for access."
**Do say**: "We treat sensitive data like money in a bank. It is transported in an armored car (secure connection) and stored in a vault (encrypted storage). Furthermore, we use a strict keycard system (IAM) so only authorized staff can open specific safe deposit boxes, and every access is logged for audits."

---

## 4. Key Technical Domains for Palladium

### A. Low-Bandwidth and Offline Environments
A massive challenge in development work is poor connectivity.
- **Questions they might ask**: "How do you design a mobile web app for users who frequently lose internet connection?"
- **Your Answers**: 
  - **Service Workers**: Implementing PWA (Progressive Web App) standards to cache static assets.
  - **Optimistic UI**: The app reflects user actions immediately and syncs data in the background when the connection returns.
  - **Local Storage/IndexedDB**: Storing form submissions locally and queueing them for upload.
  - **Asset Optimization**: Serving highly compressed images (WebP), minified code, and avoiding heavy client-side frameworks if unnecessary.

### B. Data Privacy & Security
Working with vulnerable populations requires immense care with data.
- **Questions they might ask**: "How do you handle Personally Identifiable Information (PII) in a multi-country platform?"
- **Your Answers**:
  - **Data Residency**: Storing data in specific AWS regions to comply with local laws (e.g., storing EU data in Frankfurt).
  - **Anonymization**: Stripping PII from analytical databases. Only application databases hold real names, and only for authorized use.
  - **Role-Based Access Control (RBAC)**: Ensuring a project manager in country A cannot see the beneficiary data of country B.

### C. Multi-Language and Localization Support
- **Questions they might ask**: "How do you architect a system to support English, French, Swahili, and Arabic (RTL)?"
- **Your Answers**:
  - **i18n Frameworks**: Using standard internationalization libraries (like `react-i18next`).
  - **Database Design for i18n**: Storing translations efficiently (e.g., a `translations` table or JSONB columns for multi-language fields).
  - **UI/UX**: Designing the frontend to gracefully handle Right-To-Left (RTL) languages and text expansion (German words are much longer than English).

---

## 5. Showing You Are a Partner

- **Ask "Why" before "How"**: When given a technical scenario, first ask about the business goal. "Before deciding on the database, can I ask how many users will be on this platform and what their primary goal is?"
- **Propose Incremental Value**: Development projects often have strict budgets and timelines. Emphasize Agile delivery—shipping a V1 quickly to validate assumptions, rather than spending 6 months building a perfect system nobody uses.
- **Empathy**: Show patience and empathy for non-technical users who might struggle with complex interfaces. Focus on simple, intuitive UX.
