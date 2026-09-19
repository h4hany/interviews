# Technical Communication

## 1. Overview
A Tech Lead's most important tool is not their IDE, it's their ability to communicate. Code is read far more often than it is written, and systems are only as good as the team's shared understanding of them.

## 2. Writing Technical Documents

### 2.1 RFCs (Request for Comments)
- **Purpose:** Propose a solution to a problem and gather feedback before implementation.
- **Structure:**
  - **Context:** Why are we doing this?
  - **Proposed Solution:** High-level architecture.
  - **Alternative Solutions:** What else did you consider and why were they rejected?
  - **Rollout Plan:** How do we deploy this safely?

### 2.2 ADRs (Architecture Decision Records)
- **Purpose:** Document a decision that has already been made so future engineers understand the *why*. Keeps historical context intact when team members leave.

## 3. Presenting to Non-Technical Stakeholders
- **Start with the "Why":** Executives don't care about the tech stack; they care about business value (revenue, cost reduction, risk mitigation).
- **Use Visuals:** A simple Mermaid.js block diagram is worth 1,000 words. Show the system at a high level; abstract away the database types or specific protocols.

## 4. Meeting Facilitation
- **No Agenda, No Meeting:** If a meeting is scheduled without a clear agenda and expected outcome, a TL should push back.
- **Time-boxing:** In technical debates, set a timer. "We will discuss this for 10 minutes. If we don't have a decision, we take it offline to an RFC."
- **Inclusion:** Actively ask for input from the quietest engineers in the room. They often have the best insights but won't talk over loud individuals.

## 5. Interview Questions

### Question 1: How do you explain a highly technical architectural change to the CEO or VP of Product?
**What they are testing:** Translation skills, empathy for the audience, focus on business value.
**Short Answer:** I abstract away the implementation details and focus entirely on the business impact: cost, speed, reliability, and risk. I use analogies they understand.
**Detailed Answer:** I once had to explain why we needed to migrate from a monolithic database to read-replicas. I didn't talk about connections pooling or IOPS. I told the VP of Product: "Imagine our app is a busy restaurant. Right now, we have one kitchen door for both taking orders and bringing out food, and it's causing a traffic jam. This migration is like building a separate door just for the waiters to bring food out. It will cost us two weeks of engineering time, but it will guarantee the app doesn't crash during the Black Friday rush." I focus on the ROI of the technical work.
**Strong TL Answer:** Excellent use of analogy. Clearly ties the technical work (read-replicas) to a business outcome (surviving Black Friday).

### Question 2: How do you ensure knowledge is shared effectively across a distributed or remote engineering team?
**What they are testing:** Documentation practices, asynchronous communication skills, reducing silos.
**Strong TL Answer:** I rely heavily on asynchronous, written communication. Tribal knowledge is the enemy of a remote team. I enforce the rule that "if it's not documented, it doesn't exist." We use ADRs to record all major decisions in the git repo. I also organize bi-weekly "Tech Demos" where engineers record a 5-minute loom video showing off a new pattern or tool they built, so others can watch it in their own time zone. Finally, I ensure our READMEs are robust enough that a new hire can spin up the environment without needing to ping someone on Slack.
