# Risks of AI-Generated Code

## 1. Overview
As a Technical Lead, you are the final line of defense for the system's integrity. AI code generation introduces new vectors of risk that require updated mitigation strategies. 

## 2. Security Risks
- **Hallucinated Packages:** AI might suggest importing a package that doesn't exist (e.g., `requests-async` instead of `httpx`). Malicious actors monitor AI models, generate these hallucinated package names, and upload malware to npm/PyPI under those names. This is a severe supply chain attack vector.
- **Insecure Defaults:** AI models are often trained on outdated StackOverflow posts. They might generate code using `MD5` for hashing passwords, disable SSL verification (`verify=False`), or write vulnerable SQL queries if not explicitly told to use an ORM.
- **Secrets Leakage:** If engineers paste proprietary code or API keys into consumer-grade AI tools (like standard ChatGPT), that data may be used for model training and exposed to competitors.

## 3. Legal and Compliance Risks
- **Intellectual Property (IP) Infringement:** Generative AI is trained on public code. It occasionally regurgitates exact snippets of GPL-licensed code. If this ends up in a proprietary, closed-source codebase, it violates the license and exposes the company to lawsuits.
- **Data Privacy:** Using customer data in prompts violates GDPR/CCPA. 

## 4. Architectural and Code Quality Risks
- **The "Spaghetti by a Thousand Cuts" Problem:** AI is great at local optimization (writing a function) but terrible at global optimization (system architecture). Relying heavily on AI can lead to highly duplicated code, missing abstractions, and a fragmented architecture.
- **Tech Debt Acceleration:** AI allows teams to write tech debt 10x faster. 
- **Obsolete Patterns:** AI might confidently recommend a React Class Component or an outdated Redux pattern in 2024 because its training data is skewed towards historical volume.

## 5. Mitigation Strategies (TL Responsibilities)
1. **Tooling Contracts:** Only use Enterprise AI tools with explicit "Zero Data Retention" and "No Training" agreements (e.g., GitHub Copilot Business).
2. **SCA and SAST:** Mandatory Software Composition Analysis (SCA) to catch malicious hallucinated packages, and Static Application Security Testing (SAST) to catch insecure patterns (SQLi, XSS) before merge.
3. **License Scanning:** Automated checks in CI/CD to detect copy-left licenses (GPL) in the dependency tree.
4. **Architectural Guardrails:** Enforce ADRs (Architecture Decision Records) *before* coding begins. AI fills in the blocks, but the human draws the blueprint.

## 6. Interview Questions

### Question 1: What are the main security risks associated with AI-generated code, and how do you mitigate them as a Tech Lead?
**What they are testing:** Understanding of modern security threats (supply chain, AI hallucinations) and implementation of automated guardrails.
**Short Answer:** The main risks are hallucinated dependencies (leading to supply chain attacks), insecure code patterns (like SQL injection or weak crypto), and IP/Secrets leakage via prompts.
**Detailed Answer:** To mitigate IP leakage, I ensure we only use enterprise AI licenses with data-privacy guarantees. To combat insecure code, I treat AI code exactly like untrusted user input—it must pass rigorous CI/CD checks. I implement SAST tools (like Semgrep or SonarQube) to catch vulnerable patterns like hardcoded credentials or disabled SSL. For the hallucinated dependency risk, I enforce dependency lockfiles and use SCA tools (like Snyk) to verify package legitimacy. Finally, I train the team that AI output is a *draft*, and they own the final security posture.
**Strong TL Answer:** Highlights that AI doesn't create entirely new *types* of software bugs, but it drastically increases the *velocity* at which junior engineers can introduce traditional bugs, requiring a shift towards automated, shift-left security tooling.

### Question 2: Your company wants to ban AI tools entirely due to copyright infringement concerns. As a TL, how do you handle this conversation with leadership?
**What they are testing:** Stakeholder management, risk vs reward evaluation, knowledge of AI copyright landscape.
**Strong TL Answer:** I would validate their concerns—IP leakage and GPL contamination are real risks. However, I would argue that banning AI entirely puts us at a massive competitive disadvantage in terms of engineering velocity. Instead, I would propose a compromise: We procure an Enterprise AI solution (like Copilot Business or AWS Q) which includes IP indemnification (the provider covers legal costs if sued for copyright) and guarantees our code isn't used for training. I would also implement license scanning in our CI pipeline. This addresses the legal risk while preserving the productivity gains.
