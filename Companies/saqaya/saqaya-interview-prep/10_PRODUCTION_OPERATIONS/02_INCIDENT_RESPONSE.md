# Incident Response & Management

A robust incident response process is what differentiates a mature engineering organization from a chaotic one. As a Tech Lead, you will often find yourself acting as an Incident Commander or leading the post-mortem process.

## Incident Management Process Overview

The lifecycle of an incident generally follows:
1. **Detection:** Automated alert or customer report.
2. **Response:** Acknowledgment by on-call engineer, severity assessment.
3. **Mitigation:** Stopping the bleeding (e.g., rollback, scaling up, feature flagging).
4. **Resolution:** Finding and fixing the root cause (often happens after mitigation).
5. **Post-Mortem:** Analyzing what happened to prevent recurrence.

## Severity Levels (SEV)
Standardize severities to dictate response SLA and communication channels:
- **SEV-1 (Critical):** Core business flow is completely broken for many users. (e.g., Payments down). All hands on deck. Exec communication required.
- **SEV-2 (High):** Major functionality degraded, but workarounds exist. (e.g., Search is slow, some payments failing).
- **SEV-3 (Medium):** Minor bug affecting a small percentage of users, no data loss.
- **SEV-4 (Low):** Annoyance, cosmetic issue, or internal tool degradation.

## Roles in a Major Incident
For SEV-1/SEV-2 incidents, ICS (Incident Command System) principles apply:
- **Incident Commander (IC):** Drives the incident to resolution. Does *not* write code or query databases. They coordinate, make decisions, and delegate.
- **Operations Lead (Resolver):** The subject matter expert who investigates the issue and implements the fix.
- **Communications Lead:** Handles status pages, executive updates, and customer support messaging.

## Communication During Incidents
- **War Room:** A dedicated Slack channel (e.g., `#inc-20231024-payment-failures`) or Zoom bridge.
- **Status Updates:** The IC should provide cadenced updates (e.g., every 30 mins) detailing: State (Investigating, Mitigating, Monitoring), Current Impact, Next Steps.

## Post-Mortems and Blameless Culture
A post-mortem is a written record of an incident, its impact, actions taken, root cause, and follow-up action items.

**Blameless Culture (Crucial):**
The fundamental premise is that engineers have good intentions and make decisions based on the information available to them at the time. You do not ask "Who caused this?". You ask "What system allowed this to happen?"
- *Bad:* "Bob accidentally dropped the production database because he wasn't paying attention."
- *Good:* "The production database was dropped because production and staging credentials have similar formats and the CLI defaults to production if the environment flag is omitted."

### The 5 Whys Technique
Used to find the root cause, not just the proximate cause.
1. Why did the site go down? -> Because the database became unresponsive.
2. Why did the database become unresponsive? -> Because connection pool was exhausted.
3. Why was the connection pool exhausted? -> Because a new query was running without an index, causing slow locks.
4. Why was it deployed without an index? -> Because our CI pipeline doesn't validate query plans against production schemas.
5. Why doesn't CI validate query plans? -> We disabled that check last year to speed up builds and forgot to re-enable it.
*Root Cause Fix:* Re-enable and optimize schema validation in CI.

## Runbooks and Automation
- **Runbooks (Playbooks):** Step-by-step guides for handling specific, known alerts. E.g., "What to do if Redis memory > 90%".
- **Automation:** If a runbook step is deterministic (e.g., "Restart the pod", "Clear the cache"), it should be automated away eventually.

## Interview Questions
**Q: You are paged at 2 AM for a SEV-1 where the main API is returning 500s. Walk me through your actions.**
*A: First, acknowledge the page. Jump into the war room/channel. Assess impact. If I'm the first responder, assume IC role temporarily. Check recent deployments (last 1-2 hours) as they cause 80% of outages. If there was a deploy, initiate an immediate rollback—mitigation is priority over finding the root cause. If no deploy, check dashboards for spikes in traffic, DB CPU, or memory. Delegate communication if executives join. Once mitigated, preserve logs for the post-mortem.*

**Q: How do you handle a team member who repeatedly causes outages?**
*A: Reiterate that human error is a systems problem. The system should prevent bad code from reaching production. I would review our CI/CD pipeline, PR review processes, and staging environments. Why is the system allowing a single point of failure? Provide training, pair programming, and improve the guardrails, rather than punishing the engineer.*
