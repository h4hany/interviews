# Working with Ambiguity

## 1. Overview
The transition from Junior to Senior to Lead engineer is marked by the ability to handle increasing levels of ambiguity. 
- Junior: "Here is a technical spec, build it."
- Senior: "Here is a business problem, design the spec and build it."
- Tech Lead: "Here is a vague market opportunity. Figure out if we should build it, how it impacts our architecture, and lead the team to execute it."

## 2. Framework for De-risking Ambiguity

### 2.1 Spikes and Proof of Concepts (PoC)
When the technical path is unknown (e.g., "Can we stream video efficiently to 10k users using this new protocol?"), do not start building the product. 
- **Time-box a Spike:** Give an engineer 2-3 days to build a throwaway prototype. 
- **Goal:** The output is not production code; the output is *information*. Answer the "unknown unknowns."

### 2.2 Prototyping (Tracer Bullets)
Unlike a throwaway PoC, a Tracer Bullet is production code, but it is incredibly thin. It implements the absolute minimum functionality from the frontend all the way to the database, proving the architecture connects properly. You then flesh out the feature.

### 2.3 Risk Management
Identify the biggest technical risk early and tackle it first. If a project relies on a legacy API being fast enough, test the legacy API on Day 1, not Day 30. Fail fast.

## 3. Leading Through Uncertainty
When requirements change rapidly or the company pivots, the team can become demoralized.
- **The TL's Role:** Be the shock absorber. Absorb the chaos from leadership/product, distill it, and present clear, actionable, short-term goals to your engineers to keep them focused.

## 4. Interview Questions

### Question 1: Tell me about a time you had to build a complex feature with very vague requirements. How did you handle it?
**What they are testing:** Requirements gathering, prototyping, iterative development.
**Short Answer:** I did not start coding. I collaborated with stakeholders to define the minimum viable product, built a rapid prototype to get visual feedback, and iterated on the requirements before committing to the final architecture.
**Detailed Answer:** (Use STAR method). We were asked to build a "custom analytics dashboard," but nobody knew what metrics were actually needed. Instead of guessing and building complex data pipelines, I used a rapid prototyping tool (or just hardcoded frontend components) to create three different dashboard variations. I put these in front of the PM and key users. Seeing something tangible immediately crystallized their thinking—they realized they only cared about two specific metrics, not the massive suite they initially requested. By prototyping first, we reduced the backend scope by 80% and delivered a highly targeted feature weeks early.
**Strong TL Answer:** Shows that the solution to ambiguity is often *communication and rapid feedback*, not writing code in a vacuum. Demonstrates scope reduction.

### Question 2: Your team is given a project using a technology stack nobody has used before. How do you ensure success?
**What they are testing:** Risk mitigation, learning agility, project planning.
**Strong TL Answer:** I treat the lack of knowledge as the primary project risk. Before we commit to any delivery timelines, I allocate a one-week "Spike" phase. I pair up the engineers and assign them small, specific tasks in the new stack (e.g., "Team A, figure out how testing works in this framework. Team B, figure out how to connect it to our DB"). At the end of the week, they present their findings to each other. This builds a baseline of shared knowledge and uncovers the "unknown unknowns." Only after this de-risking phase do we attempt to architect the solution and estimate the timeline.
