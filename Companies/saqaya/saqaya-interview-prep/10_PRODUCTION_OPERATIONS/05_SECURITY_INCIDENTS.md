# Security Incidents & Vulnerability Management

A Tech Lead must understand how to proactively secure a system and reactively manage security breaches. Security is continuous, not a one-time checklist.

## Security Incident Response
Security incidents differ from operational incidents. While an operational incident prioritizes rapid mitigation (rolling back), a security incident requires preserving evidence and ensuring the attacker is completely eradicated before restoring services.

### Phases:
1. **Identification:** Detecting the breach (e.g., via WAF alerts, anomalous DB access, user reports).
2. **Containment:** Stopping the bleed. (e.g., Disabling compromised accounts, isolating servers from the network, blocking IP ranges). *Crucial: Do not immediately destroy the server; isolate it for forensics.*
3. **Eradication:** Removing the vulnerability and the attacker's footprint (e.g., patching the flaw, rotating all compromised secrets, removing backdoors).
4. **Recovery:** Restoring systems from trusted backups, monitoring heavily for reinfection.
5. **Post-Incident Activity:** Forensics, legal reporting (GDPR, CCPA), and customer notifications.

## Vulnerability Management
- **Dependency Scanning:** Using tools like Dependabot, Snyk, or Trivy in the CI/CD pipeline to block PRs that introduce vulnerable libraries.
- **CVEs (Common Vulnerabilities and Exposures):** Publicly disclosed flaws. You must assess CVEs based on **CVSS (Common Vulnerability Scoring System)** score, but more importantly, **Reachability**. A Critical CVE in a library you use is a non-issue if the vulnerable function is never invoked in your code.
- **SAST (Static Application Security Testing):** Analyzes source code for flaws (e.g., SonarQube).
- **DAST (Dynamic Application Security Testing):** Attacks a running application to find flaws (e.g., OWASP ZAP).

## Key Production Defenses
- **WAF (Web Application Firewall):** AWS WAF or Cloudflare. Protects against SQLi, XSS, and botnets.
- **Least Privilege:** Microservices and IAM roles should only have exactly the permissions they need. (e.g., A worker reading SQS shouldn't have delete access to the main RDS instance).
- **Audit Logging:** Immutably logging security-relevant events (logins, permission changes, data exports). Critical for compliance (SOC2, HIPAA).

## Common Attack Vectors
- **IDOR (Insecure Direct Object Reference):** Failing to verify if the authenticated user has permission to access the requested resource ID.
  *Fix:* Always check authorization at the data access layer: `SELECT * FROM invoices WHERE id = ? AND user_id = ?`
- **Supply Chain Attacks:** Compromised NPM/PyPI packages.
  *Fix:* Pin dependencies, use package lock files, audit updates.
- **SSRF (Server-Side Request Forgery):** An attacker tricks your server into making HTTP requests to internal networks (e.g., AWS Metadata endpoint `169.254.169.254` to steal IAM credentials).
  *Fix:* Restrict outgoing URLs, use IMDSv2 in AWS.

## Interview Questions
**Q: An automated scanner reports a Critical (CVSS 9.8) vulnerability in a logging library your application uses. What is your process?**
*A: I would not panic, but I would treat it urgently. First, verify exploitability—is the vulnerable code path reachable by user input in our context? (e.g., the log4shell vulnerability required user input to be logged). Second, check if a patch is available. If a patch exists, test it in staging and deploy it immediately via an out-of-band hotfix. If no patch exists, look for mitigations (e.g., blocking specific strings at the WAF, disabling the vulnerable feature). Post-mitigation, audit our logs to see if the vulnerability was actively exploited.*

**Q: A developer accidentally committed an AWS access key to a public GitHub repository. What steps do you take?**
*A: 1. Immediately revoke/delete the key in the AWS IAM console. Do not wait to try and delete the commit from GitHub, as bots scrape GitHub instantly.
2. Review AWS CloudTrail logs to see if that specific key was used maliciously since it was committed.
3. If it was used, identify what resources were accessed or modified, and declare a security incident.
4. Rotate the key and provide it securely (via Secrets Manager or HashiCorp Vault) to the application.
5. Implement pre-commit hooks (e.g., git-secrets, Talisman) or GitHub Advanced Security to prevent secrets from being pushed in the future.*
