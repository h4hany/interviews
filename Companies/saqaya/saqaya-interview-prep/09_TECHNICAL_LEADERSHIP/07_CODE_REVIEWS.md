# Code Reviews & Quality

## 1. Overview
The Code Review (PR Review) process is the primary gatekeeper of codebase quality and the engine of technical culture. A Technical Lead defines *how* this process works.

## 2. The Purpose of Code Review
1. **Defect Detection:** Catching logical bugs, security flaws, and edge cases.
2. **Knowledge Sharing:** Ensuring more than one person understands a piece of code.
3. **Standardization:** Enforcing architectural patterns and style.

## 3. Code Review Best Practices (For the TL)

### 3.1 The Review Hierarchy
When reviewing a PR, look at these in order of importance. Do not comment on typos if the architecture is entirely wrong.
1. **Architecture & Logic:** Is this the right approach? Does it handle scale? Are there race conditions?
2. **Security & Performance:** SQL injection risks? N+1 query problems? Un-indexed database lookups?
3. **Testing:** Are there meaningful unit/integration tests? Do they cover negative cases?
4. **Readability:** Are variable names descriptive? Is the cognitive complexity low?
5. **Style/Syntax:** (This should be handled by automated linters, not humans).

### 3.2 Review Culture and Tone
- **Nitpicks:** If a comment is minor and shouldn't block the merge, explicitly prefix it with `Nit:` (e.g., "Nit: We usually put constants at the top of the file, but feel free to ignore").
- **Ask, Don't Tell:** Instead of "This is wrong, use a Set," try "What happens to the performance here if the array has 10,000 items? Would a Set be more efficient?" Socratic questioning promotes learning.
- **Praise:** Call out elegant solutions.

## 4. Scaling the Code Review Process
- **Small PRs:** Enforce a soft limit (e.g., 400 lines of code max). Massive PRs get "LGTM" (Looks Good To Me) rubber-stamps because reviewers are overwhelmed.
- **Automation:** The TL must fiercely automate. Humans should never argue about tabs vs spaces, unused imports, or missing semicolons. Use Prettier, ESLint, SonarQube, and CI checks.
- **Time Management:** Encourage engineers to review code twice a day (e.g., morning and after lunch) rather than immediately breaking their flow state for every Slack ping, while ensuring PRs don't sit unreviewed for days.

## 5. Interview Questions

### Question 1: How do you handle a situation where a code review turns into a heated, multi-day argument between two engineers?
**What they are testing:** Conflict resolution, process management, recognizing communication breakdown.
**Short Answer:** I immediately move the conversation out of text (GitHub/Slack) and into a synchronous video call to de-escalate. 
**Detailed Answer:** When a PR has 30+ comments going back and forth, text communication has failed. Nuance and tone are lost, and egos get involved. I will intervene by messaging them: "Let's jump on a quick 15-minute huddle." On the call, I have the author explain what they are trying to achieve, and the reviewer explain their specific concern. Often, they are talking past each other. I facilitate a compromise. If it's a matter of opinion (not a bug), I lean towards letting the author's code pass—the author owns the execution. I then remind the team of the "disagree and commit" philosophy and ensure the PR is merged or closed that day.
**Strong TL Answer:** Identifies that *asynchronous text* is the root cause of the escalation. Shows bias for action (moving to a call) and closure (getting the PR merged).

### Question 2: Your team is complaining that code reviews are taking too long, and features are getting backed up waiting for approval. How do you fix this?
**What they are testing:** Process optimization, identifying bottlenecks, balancing velocity and quality.
**Strong TL Answer:** I look at the data first. Are PRs sitting idle, or are there too many rounds of revisions? If they are sitting idle, I establish a team SLA (e.g., all PRs must receive a first pass review within 24 hours). I might also implement a "review buddy" system for specific sprints. If the delay is caused by endless revisions, the PRs are likely too large or the requirements were vague. I would enforce a strict size limit on PRs to reduce reviewer cognitive load. Finally, I would check if we are arguing over things a machine should catch. If so, I dedicate time to beefing up our CI pipeline with better linters and formatters to remove subjective debates.
