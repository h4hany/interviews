# Leadership Behavioral Questions

## 1. Overview
Behavioral interviews assess your past actions to predict future performance. As a Tech Lead, interviewers want to see empathy, resilience, ownership, and the ability to influence without formal authority (unlike an Engineering Manager, a TL often leads peers).

## 2. The STAR Method
Always structure your answers using STAR:
- **Situation:** Set the context briefly (10-15%).
- **Task:** What was the specific challenge or goal? (10%).
- **Action:** What did *you* do? Use "I", not "We" when describing your specific contribution. Highlight leadership and decision-making (60%).
- **Result:** What was the outcome? Use quantifiable metrics if possible. What did you learn? (15-20%).

## 3. Core Leadership Themes to Prepare
Have a STAR story ready for each of these themes:
1. **Handling Failure:** A time your system broke production or a project failed.
2. **Conflict:** A disagreement with a peer or a PM.
3. **Driving Change:** Introducing a new process, tool, or architecture against resistance.
4. **Mentoring:** Helping an underperforming or junior engineer succeed.

## 4. Interview Questions

### Question 1: Tell me about a time you failed or made a significant mistake.
**What they are testing:** Accountability, blameless culture, ability to learn and adapt systems.
**Short Answer:** I deployed a change that caused a partial outage. I took immediate ownership, rolled back the change, led the blameless post-mortem, and implemented an automated check to prevent that class of error from happening again.
**Detailed Answer:** (STAR) *Situation:* I was leading a migration to a new payment provider. *Task:* Cut over the traffic with zero downtime. *Action:* During the cutover, I missed a configuration flag for a specific subset of legacy users, causing their transactions to fail. As soon as alerts fired, I didn't try to hotfix it; I immediately executed our rollback plan. Once the system was stable, I publicly owned the mistake in our team channel. I then led the post-mortem. I focused on the system failure: *Why did our staging environment not catch this?* *Result:* We discovered staging lacked legacy user profiles. I updated our data-seeding script to include them and added a specific E2E test. The cutover succeeded a week later. 
**Strong TL Answer:** Focuses on *systemic* fixes rather than just saying "I'll be more careful next time." Demonstrates psychological safety by owning the mistake publicly.

### Question 2: Tell me about a time you had to influence a team or individual who didn't report to you to adopt a new technology or process.
**What they are testing:** Influence without authority, empathy, change management.
**Strong TL Answer:** (STAR) *Situation:* Our frontend team (which I wasn't on) was struggling with massive, brittle CSS files, slowing down the whole product org. *Task:* Convince them to adopt Tailwind CSS, which they were resistant to because it looked "ugly" in the markup. *Action:* I didn't force a debate. Instead, I spent an afternoon building a replica of our most complex UI component using Tailwind. I scheduled a quick demo and showed them how I built it in 20 minutes without leaving the HTML file, and how the CSS bundle size dropped to almost zero. I acknowledged their aesthetic concerns but asked them to try it on one low-risk page. *Result:* Seeing the developer experience firsthand won them over. They adopted it for the new page, loved the speed, and eventually championed migrating the whole app. I led with data and a working prototype, not just an opinion.
