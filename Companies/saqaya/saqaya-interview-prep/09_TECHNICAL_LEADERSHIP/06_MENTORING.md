# Mentoring and Growing Engineers

## 1. Overview
The most scalable thing a Technical Lead can do is level up the engineers around them. If a TL is constantly the bottleneck for critical tasks, they are failing at mentoring and delegation. 

## 2. Forms of Technical Mentoring

### 2.1 Code Review as Mentoring
Code reviews are not just for catching bugs; they are a primary teaching tool.
- **Explain the "Why":** Don't just say "Change this loop to a map." Say, "Using `map` here avoids mutating the array, which prevents a whole class of concurrency bugs. Here is a link to an article on immutability."
- **Praise:** Point out exceptionally good code. "This abstraction is really clean, great job."

### 2.2 Pair Programming
- **Driver/Navigator Model:** The junior engineer should almost always be the "Driver" (typing). The TL is the "Navigator" (guiding the architecture). If the TL drives, the junior just watches a movie and learns nothing.
- **When to Pair:** Use pairing for complex architectural setup, debugging nasty race conditions, or exploring a new framework.

### 2.3 Delegation and Risk
You cannot grow a Senior Engineer without giving them tasks where they *might* fail.
- **The "Waterline" Principle:** If an engineer makes a mistake that causes a minor UI bug (above the waterline), let them make it and learn. If they are about to drop the production database (below the waterline), intervene immediately.
- **Scaffolding:** For a mid-level engineer taking on a huge feature, the TL should define the API contracts and data models, and then delegate the implementation of the internals.

## 3. Technical Growth Plans
Work with the Engineering Manager to identify technical gaps.
- If an engineer is great at frontend but wants to learn backend, assign them cross-functional tickets and pair them with a strong backend engineer.
- Encourage engineers to lead technical presentations (Lunch & Learns) on topics they recently learned.

## 4. Interview Questions

### Question 1: How do you identify when an engineer is ready to be promoted from Mid-level to Senior, and how do you help them get there?
**What they are testing:** Mentoring philosophy, understanding of role expectations, proactive leadership.
**Short Answer:** A Senior engineer can handle ambiguity and design systems, not just execute tasks. I help them get there by delegating larger, less-defined problems and coaching them through the architectural design phase.
**Detailed Answer:** A mid-level engineer says, "Give me a well-defined Jira ticket and I will build it perfectly." A Senior engineer says, "Here is a vague business problem; let me design a system to solve it." To bridge this gap, I change how I assign work. I stop giving the engineer exact technical specs. Instead, I give them the business requirement and ask them to write an RFC (Request for Comments) proposing an architecture. I review their RFC, point out edge cases they missed (like scaling or data migration), and iterate. Once the design is solid, they lead the implementation. By pushing them into system design and cross-team communication, I build a case for their promotion.
**Strong TL Answer:** Clearly distinguishes between *execution* (mid-level) and *system design/ambiguity resolution* (senior). Shows a structured approach to leveling up the engineer.

### Question 2: You delegate a critical feature to a mid-level engineer to help them grow, but they are falling behind and the deadline is approaching. What do you do?
**What they are testing:** Balancing mentoring with delivery, identifying failure, avoiding the "hero" anti-pattern.
**Strong TL Answer:** I do *not* take the keyboard away and code it myself. That destroys their confidence and teaches them I will always rescue them. First, I identify the blocker—is it a lack of domain knowledge, a tooling issue, or poor time management? I switch to intensive pair programming. I act as the navigator to guide them through the complex logic, but they keep typing. We break the remaining work into micro-tasks. If the deadline is still in jeopardy, I communicate the delay to stakeholders immediately. We might descale the feature (cut a non-essential part) to hit the deadline. After the launch, we do a 1-on-1 retrospective to understand why the estimation was off and how to improve next time.
