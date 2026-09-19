# Human vs. AI Responsibility

## 1. Overview
As AI becomes deeply integrated into the SDLC, the boundaries of responsibility must be explicitly defined. A Technical Lead must establish a culture where AI is viewed as an augmentation tool, not a scapegoat.

## 2. The Core Principle: Human Accountability
**Rule:** The human engineer whose name is on the git commit is 100% responsible for the code, regardless of how it was generated.
- "Copilot wrote it and I didn't notice the bug" is the exact same as "I copied it from StackOverflow and didn't notice the bug." It indicates a failure of engineering rigor.

## 3. Division of Labor: What to Delegate to AI
**AI is best suited for (The "What" and "How"):**
- Boilerplate generation (setting up controllers, routing, DTOs).
- Syntax translation (converting a bash script to Python).
- Generating mock data and scaffolding unit tests.
- Explaining complex regex or cryptic legacy code.
- Generating inline code documentation.

**Humans are strictly responsible for (The "Why" and "Architecture"):**
- Domain modeling (understanding the business rules).
- System architecture and service boundaries.
- Security boundary enforcement (Authentication/Authorization logic).
- Performance trade-offs and database schema design.
- Deciding *what* to test (identifying the critical edge cases).

## 4. Ethical and Professional Considerations
- **Trust vs. Verify:** Engineers must treat AI output as if it were written by a smart but inexperienced junior engineer who sometimes lies confidently (hallucinates). 
- **Skill Atrophy:** There is a risk that reliance on AI prevents junior engineers from struggling through problems, which is how deep learning occurs. Tech Leads must encourage juniors to understand *why* the AI's code works.
- **Bias:** AI models can encode biases. If AI is used to generate logic for user filtering, credit scoring, etc., the human must audit it for fairness and business alignment.

## 5. Building an AI-Aware Engineering Culture
1. **Promote Transparency:** It should be acceptable and encouraged to say, "I used AI to generate this module, here is the prompt I used."
2. **Focus on Prompt Engineering:** Teach the team that coding is shifting toward systems design and precise communication (prompting).
3. **Elevate the Review Process:** Shift the team's focus from writing code to reviewing, verifying, and maintaining systems.

## 6. Interview Questions

### Question 1: How do you handle accountability when a production outage is caused by AI-generated code?
**What they are testing:** Leadership, ownership, blame culture vs. root cause analysis.
**Short Answer:** Accountability always lies with the human engineer who merged the code and the systems that allowed it to deploy. We treat it exactly like human-written code during the blameless post-mortem.
**Detailed Answer:** If AI-generated code causes an outage, I immediately focus on the system, not the AI. The human engineer who committed the code is ultimately responsible, but as a TL, my question is: "Why did our pipeline allow this to reach production?" During the blameless post-mortem, we analyze the failure. Did the engineer blindly trust the AI? Did our automated tests fail to catch a missing edge case? Did code review fail? The remediation is never "blame the AI." The remediation is updating our CI/CD to catch that class of error, adding the missing test case, and reiterating to the team that AI output must be rigorously verified.
**Strong TL Answer:** Refuses to accept the AI as a scapegoat. Pivots the conversation to systemic safeguards, blameless culture, and improving automated testing.

### Question 2: As AI takes over more coding tasks, how do you ensure junior engineers on your team still develop deep technical skills and don't just become "prompt operators"?
**What they are testing:** Mentoring philosophy, understanding of cognitive load and skill development.
**Strong TL Answer:** This is a major risk (skill atrophy). I address this by changing *how* I mentor. I encourage juniors to use AI as a tutor, not just a generator. If they are stuck, I tell them to prompt the AI for an *explanation* of the concept, not just the final code snippet. During code reviews, I probe their understanding deeply: "I see Copilot generated this bitwise operation—can you walk me through how it works?" If they can't explain it, they can't merge it. Furthermore, I assign them debugging tasks and complex architectural design tasks—areas where AI is weak and human critical thinking is required. We want them to evolve into system thinkers, not just code typists.
