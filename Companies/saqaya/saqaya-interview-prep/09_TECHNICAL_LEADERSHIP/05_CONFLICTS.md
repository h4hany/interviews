# Managing Conflicts

## 1. Overview
As a Technical Lead, you will frequently navigate disagreements. These can be technical (e.g., REST vs. GraphQL), process-oriented (e.g., Scrum vs. Kanban), or interpersonal. The goal is not to eliminate conflict, but to foster *healthy, data-driven debate* and ensure psychological safety.

## 2. Conflict Resolution Frameworks

### 2.1 Focus on the Problem, Not the Person
Shift the language from "Your design won't work" to "I have concerns about how this design handles peak load." Depersonalize the critique.

### 2.2 Data Over Dogma
When two senior engineers are arguing passionately over an architectural choice, it often devolves into philosophy. 
- **Action:** Stop the argument and ask, "What data do we need to prove which approach is better?" 
- Drive them toward a time-boxed Proof of Concept (PoC) or benchmarking test. Let the compiler/metrics settle the debate.

### 2.3 Disagree and Commit
Borrowed from Amazon's leadership principles. A team can debate fiercely during the design phase (RFCs, whiteboarding). However, once a decision is made by the TL or by consensus, everyone must commit to implementing it to the best of their ability. Sabotaging a chosen path because you disagreed with it is unacceptable.

## 3. Ego Management
- **The TL's Ego:** A strong TL is happy to be proven wrong. If a junior engineer points out a flaw in your design, celebrate it publicly. This sets the culture.
- **The "Brilliant Jerk":** An engineer who produces great code but is toxic in PR reviews, belittling others. A TL must address this immediately in 1-on-1s. Toxicity destroys team velocity far more than great code helps it.

## 4. Decision Authority
- **Consensus is great, but consensus can be slow.** A TL should strive for consensus, but if the team is deadlocked, the TL must make the executive call to break the tie. "Analysis Paralysis" is a failure of leadership.

## 5. Interview Questions

### Question 1: Two senior engineers on your team are completely deadlocked on a major architectural decision. They both have valid points. How do you resolve this?
**What they are testing:** Conflict resolution, decision-making frameworks, breaking deadlocks.
**Short Answer:** I shift the debate from opinions to data by proposing a time-boxed PoC. If a PoC isn't feasible, I map their arguments back to our core business requirements and make an executive decision, asking them to "disagree and commit."
**Detailed Answer:** First, I get them into a synchronous meeting (video or in-person) to stop any toxic back-and-forth in PR comments or Slack. I ask them both to outline the pros and cons of their approach in a shared document. Often, seeing it written down diffuses the emotion. If it's a critical decision, I will ask them to define a metric for success and run a 2-day spike/PoC to test their theories. If the data is still inconclusive, I review the business constraints (e.g., time to market vs. scalability). As the TL, if we are still deadlocked, I will make the final call based on the business priority. I will clearly explain *why* I chose path A, validate the concerns of the engineer advocating for path B, and explicitly ask for their commitment to make path A successful.
**Strong TL Answer:** Emphasizes moving from asynchronous text (which breeds hostility) to synchronous conversation. Focuses on data and business constraints, and isn't afraid to take the responsibility of breaking the tie.

### Question 2: Tell me about a time you made a technical decision that the team strongly disagreed with. How did you handle the pushback?
**What they are testing:** Leadership under pressure, handling unpopular decisions, communication of "the why."
**Strong TL Answer:** (Use STAR method). We needed to standardize our CI/CD pipeline and I chose to enforce a strict linting and coverage rule that broke many existing builds. The team was angry because it slowed down their immediate feature work. I handled it by holding a team meeting to explain the *Why*. I showed data on how many production bugs in the last quarter would have been caught by these rules. I acknowledged their pain and compromised by turning the rules into "warnings" for one week so they could adapt, before switching them to "errors." By explaining the long-term benefit and showing flexibility in the rollout, I gained their buy-in.
