# Stakeholder Management

## 1. Overview
A Technical Lead cannot succeed in a vacuum. You must manage relationships with Product Managers (PMs), Designers, Domain Experts, Executives, and other engineering teams. You are the translator between technical reality and business goals.

## 2. Working with Product Managers (PMs)
- **Partnership, not subservience:** You and the PM are peers. They own the *What* and *Why*; you own the *How* and *When*.
- **Negotiating Scope:** When a PM asks for a feature that takes 4 weeks, a TL should ask, "What is the core value we are trying to deliver?" Often, 80% of the value can be delivered in 1 week by cutting an edge-case requirement.
- **Saying No:** Never just say "No." Say, "Yes, but..." (e.g., "Yes, we can build that, but it means we have to delay the payment gateway integration by a month. Is that the trade-off you want to make?").

## 3. Working with Non-Technical Stakeholders (Executives/Domain Experts)
- **Avoid Jargon:** Don't talk about Kubernetes pods, garbage collection, or React renders. Talk about "reliability," "system load," and "user experience."
- **Use Analogies:** Explain technical debt like financial debt (paying interest in the form of slower delivery). Explain refactoring like rebuilding the foundation of a house.
- **Contextualizing for Palladium Domain Teams:** If working in a specialized domain (e.g., Palladium), you must deeply respect the domain experts. They know the business rules better than you. Your job is to translate their complex domain knowledge into scalable software architecture (Domain-Driven Design).

## 4. Managing Expectations
- **Under-promise, Over-deliver:** Always include buffer time for testing, deployment, and unforeseen technical hurdles (like a third-party API being undocumented).
- **Early Bad News:** If a project is going to be late, communicate it immediately. Stakeholders can manage bad news; they cannot manage surprises.

## 5. Interview Questions

### Question 1: A Product Manager comes to you with an urgent feature request that will derail your current sprint. How do you handle it?
**What they are testing:** Prioritization, negotiation, stakeholder communication, protecting the team.
**Short Answer:** I don't say no, but I force a prioritization decision. I explain the impact on the current sprint and ask the PM to decide what drops off the roadmap to accommodate the urgent request.
**Detailed Answer:** First, I seek to understand the *why*. Is this fixing a critical bug causing revenue loss, or is it a shiny new idea? If it's truly urgent, I map out the cost. I sit down with the PM and say, "We can absolutely pivot to this. However, it will take 3 days, meaning Feature X and Feature Y will not be delivered this sprint." I make the trade-offs highly visible. If they agree to the trade-off, we pivot. If they say "we need it all," I hold the line and explain that engineering time is a fixed constraint. By framing it as a trade-off rather than a refusal, we solve the problem collaboratively.
**Strong TL Answer:** Shows they protect their engineers from context-switching while remaining commercially aware that sometimes business priorities *must* interrupt a sprint.

### Question 2: How do you explain complex technical debt to a non-technical executive who just wants new features?
**What they are testing:** Communication skills, analogy usage, business-value framing.
**Strong TL Answer:** I never use technical terms like "refactoring the ORM" or "migrating to Kubernetes." Executives care about cost, risk, and time-to-market. I explain technical debt using the analogy of a restaurant kitchen. Right now, we are cooking meals (features) very fast, but we never stop to clean the kitchen (tech debt). If we keep doing this, eventually the kitchen will be so messy that it takes an hour to make a simple sandwich, or worse, we get a health code violation (security breach). I frame the request for refactoring time not as an engineering luxury, but as an investment required to maintain our future feature velocity. I'll say, "If we spend 2 weeks fixing this now, the next 3 features you want will take 1 week each instead of 3 weeks each."
