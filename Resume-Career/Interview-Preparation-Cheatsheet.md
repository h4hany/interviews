# Interview Preparation Cheatsheet — How to Prepare for Any Company

A single reference for **what to do**, **how to study**, **when to schedule**, and **what tools to use** so you can prepare for any interview systematically.

---

## 1. How many days/weeks before should I schedule the interview?

| Your level / situation | Recommended prep before scheduling | Notes |
|------------------------|------------------------------------|--------|
| **Junior (0–2 yrs)** | **4–6 weeks** | Need time for DSA, fundamentals, behavioral. |
| **Mid-level (2–5 yrs)** | **3–4 weeks** | System design + coding + behavioral. |
| **Senior (5–8 yrs)** | **2–3 weeks** | Deep system design, leadership stories. |
| **Staff / Principal (8+ yrs)** | **2–4 weeks** | Architecture, scope, behavioral + bar raiser. |
| **Already prepping (e.g. doing LeetCode)** | **1–2 weeks** | Polish and company-specific only. |
| **Switching stack (e.g. new language)** | **+2–4 weeks** | Add time for language/framework depth. |

**Rule of thumb:** Schedule the first interview (e.g. phone screen) for **at least 2 weeks out** so you have time for a focused sprint. If you need to build fundamentals, use **4–6 weeks** and schedule after you complete at least one full pass of your study plan.

---

## 2. What should I do? Action checklist

### Before you apply
- [ ] **Resume:** Tailor for ATS (keywords, clear bullets, metrics). Use `Resume-Career/Hany Sayed Ahmed - ATS Optimized CV.md` as reference.
- [ ] **LinkedIn:** Headline and “About” aligned with target role; endorsements and recommendations updated.
- [ ] **Portfolio / GitHub:** 1–2 strong projects or contributions that match the role.

### Once you decide to interview
- [ ] **Define scope:** Which companies, which level (e.g. Senior, Staff), which focus (backend, full‑stack, ML).
- [ ] **Pick a study plan** (see below) and block time daily.
- [ ] **Set a target date** for “first interview” and work backward (e.g. 3 weeks out → start today).

### Technical prep
- [ ] **Coding:** LeetCode/Blind 75 or similar; focus on patterns (two pointers, sliding window, DFS/BFS, DP). Use this repo’s **Problem Solving** section.
- [ ] **System design:** 3–5 full designs (e.g. URL shortener, feed, chat). Use **System Design** and **Architecture** sections + playground.
- [ ] **Backend/Frontend:** At least one language + framework you’ll use in the interview (see **Backend** / **Frontend** and new Java, Python Q&A in this repo).
- [ ] **Databases & infra:** Basics (indexes, replication, caching). Use **Databases**, **caching-messaging**, **DevOps** sections.

### Behavioral prep
- [ ] **STAR stories:** 5–7 stories you can adapt (conflict, failure, leadership, trade-off, mentoring, impact).
- [ ] **Company values:** Map your stories to their principles (e.g. Amazon LP). Use **Resume-Career/Behavioral-Interview-QA.md** and **Behavioral-Questions-Answers.md**.
- [ ] **“Tell me about yourself”:** 1–2 minute pitch; practice out loud.

### Week before first interview
- [ ] **Mock interview:** With a friend, Pramp, or AI (e.g. Cursor, ChatGPT). Do at least one full loop (coding + behavioral or system design).
- [ ] **Company research:** Glassdoor, Blind, job description; note 2–3 questions to ask the interviewer.
- [ ] **Logistics:** Quiet space, camera/mic check, stable internet; know the interview format (e.g. CoderPad, shared doc).

---

## 3. Study plan — what to study and in what order

### Phase 1: Foundations (Week 1 if needed, else assume done)
- Programming language you’ll use (syntax, OOP, concurrency).
- Basic data structures: arrays, hash map, linked list, stack, queue, tree, graph.
- Big O and simple time/space analysis.

### Phase 2: Coding (Weeks 1–2)
- **Patterns:** Two pointers, sliding window, binary search, DFS/BFS, dynamic programming, intervals.
- **Practice:** 1–2 problems per day; review solutions and variants. Use **Problem Solving** in this repo.
- **Target:** 50–75 problems with patterns internalized (e.g. Blind 75 or similar list).

### Phase 3: System design (Weeks 2–3)
- **Concepts:** Load balancing, caching, sharding, replication, message queues.
- **Designs:** Do 3–5 end-to-end (requirements → high-level diagram → key components). Use **System Design** and **Architecture** + **System Design** playground.
- **Discuss:** Trade-offs (consistency vs availability, latency vs cost).

### Phase 4: Role-specific depth (Weeks 2–4)
- **Backend:** APIs, DB design, scaling, one stack (e.g. Node, Java/Spring, Python/Django). Use **Backend** and new **Java-Spring-Boot** and **Python-Django-FastAPI** Q&A in this repo.
- **Frontend:** React/Angular, state, performance. Use **Frontend** section.
- **Staff/Principal:** Architecture, cross-team impact, mentoring. Use **Staff-Leadership-QA.md**, **FAANG** and **staff Q&A**.

### Phase 5: Behavioral & company fit (Ongoing)
- **Stories:** Refine 5–7 STAR stories; align with company values.
- **“Tell me about yourself”:** Practice until smooth.
- Use **Behavioral-Interview-QA.md**, **Behavioral-Questions-Answers.md**, and **Behavioral & Leadership** playground.

### Suggested weekly schedule (example: 3-week sprint)
| Week | Focus | Actions |
|------|--------|--------|
| **1** | Coding + language/framework | 1–2 LeetCode/day; read Java or Python Q&A; 1 system design read-through. |
| **2** | System design + behavioral | 2–3 full system design practices; write 5 STAR stories; 1 mock. |
| **3** | Polish + company-specific | Company research; 1–2 mocks; review weak areas; rest before interview. |

---

## 4. AI tooling to support your prep

Using AI tools can speed up review, generate practice questions, and simulate Q&A. Below: **NotebookLM** (recommended for study) and **other tools** in brief.

---

### 4.1 NotebookLM — detailed how-to for interview prep

**What is NotebookLM?**  
NotebookLM is Google’s free AI assistant that answers questions **only from sources you upload**. It does not invent from the whole web, so it’s good for studying your own notes, this repo’s PDFs/markdown, or company docs.

**Why use it for interview prep?**
- Upload this repo’s key files (e.g. exported MD or PDF) and ask “Quiz me on system design” or “Explain this concept in simple terms.”
- Get **citations** to the exact passage it used, so you can verify and deepen in the repo.
- Use **audio overviews** and **flashcards** to review on the go.

**How to use NotebookLM step by step**

1. **Get access**  
   - Go to [NotebookLM](https://notebooklm.google.com) (or search “NotebookLM Google”).  
   - Sign in with your Google account.  
   - No subscription required; free to use.

2. **Create a notebook**  
   - Click **New notebook**.  
   - Give it a name, e.g. “Interview Prep – Backend & System Design”.

3. **Add your sources**  
   - Click **Add source**. You can add:  
     - **PDFs** (e.g. export key MD from this repo to PDF, or upload FAANG/staff Q&A PDF).  
     - **Google Docs** (copy-paste repo content into a Doc and add the Doc).  
     - **Web links** (e.g. a specific company engineering blog).  
     - **YouTube** (e.g. “System design interview” or “Behavioral interview” talks).  
   - For this repo: create a few Google Docs (e.g. “System Design notes”, “Behavioral stories”, “Java Spring Q&A”) and paste the most important content, then add those Docs as sources.  
   - **Limit:** Each notebook has a source limit (e.g. ~50 sources); keep one notebook per “theme” (e.g. one for system design, one for behavioral).

4. **Ask questions**  
   - In the chat box, ask things like:  
     - “Summarize the main system design concepts in these sources.”  
     - “Generate 5 practice behavioral questions based on my stories.”  
     - “Quiz me: what are the trade-offs between consistency and availability?”  
   - Every answer will **cite** the source and passage; click to open and review in context.

5. **Use built-in study features**  
   - **Flashcards:** Ask “Generate flashcards from the system design section” or use the built-in flashcard feature if available in your region.  
   - **Audio overview:** Use “Generate audio overview” to get a spoken summary of your notebook; listen while commuting.  
   - **Learning guide:** Use the guide to get a structured walkthrough of your sources (e.g. “Explain this like I’m preparing for an interview”).

6. **Workflow that fits this repo**  
   - **Option A:** Export 3–5 key MD files (e.g. System Design, Behavioral, one backend Q&A) to PDF and upload.  
   - **Option B:** Copy-paste sections into Google Docs (one Doc per topic), add Docs to NotebookLM, then ask for summaries, quizzes, and “explain in simple terms.”  
   - **Option C:** Add a few high-quality YouTube URLs (system design, behavioral) and ask “Compare what this video says with my notes.”

**Best practices**  
- Keep one notebook per big topic (e.g. “System design”, “Behavioral”, “Java/Spring”) so answers stay focused.  
- Ask for “quiz me” and “give me 3 follow-up questions” to simulate interview pressure.  
- Use citations to double-check and to find the exact place in this repo for deeper reading.

---

### 4.2 Other AI tools (short)

| Tool | Use for interview prep |
|------|-------------------------|
| **ChatGPT / Claude** | Practice coding (paste problem, get solution + explanation), system design discussion, behavioral story feedback. Always re-solve yourself after. |
| **Cursor / Copilot** | Code while studying (e.g. implement a small system design or a LeetCode pattern); ask “explain this snippet” in your IDE. |
| **Pramp** | Free peer mock interviews (coding + behavioral); good for timing and real back-and-forth. |
| **LeetCode Discuss / NeetCode** | Explanations and patterns; use after solving to compare approach. |

Use **NotebookLM** when you want answers **grounded only in your uploaded materials** (this repo + your notes). Use **ChatGPT/Claude** for open-ended practice and feedback, and **Pramp** for live mocks.

---

## 5. Quick reference: where to find what in this repo

| Goal | Where in this repo |
|------|--------------------|
| Study plan & timeline | This file (Interview-Preparation-Cheatsheet.md) |
| Behavioral Q&A (50+) | Resume-Career/Behavioral-Questions-Answers.md |
| Behavioral short + STAR | Resume-Career/Behavioral-Interview-QA.md |
| Staff / leadership | Resume-Career/Staff-Leadership-QA.md |
| FAANG / bar raiser | Resume-Career/FAANG Interview Preparation - Extended Q&A.md, staff Q&A.md |
| System design | System Design/, Architecture/, System Design playground |
| Coding / DSA | Problem Solving/, LeetCode, data-structure, patterns |
| Backend (Node, Rails, .NET) | Frameworks/Backend/, Programming/ |
| Java & Spring Boot (50+ Q) | Frameworks/Backend/Java-Spring-Boot-Interview-QA.md |
| Python, Django, FastAPI (50+ Q) | Frameworks/Backend/Python-Django-FastAPI-Interview-QA.md |
| Databases | Databases/, database playground |
| DevOps / infra | DevOps/, Infrastructure/, DevOps playground |
| Design (SOLID, patterns, OOD) | design/, Design playground |
| Company-specific | Companies/ (Amazon, Oracle, Toters, etc.) |

---

## 6. Final checklist the night before

- [ ] Know the format (coding / system design / behavioral / mix) and duration.  
- [ ] Test camera, mic, and internet; close other apps.  
- [ ] Have 2–3 questions to ask the interviewer.  
- [ ] Review your “tell me about yourself” and 2–3 STAR stories.  
- [ ] Get enough sleep; avoid cramming new topics.

Good luck — you’ve got a single place for what to do, how to study, when to schedule, and how to use tools like NotebookLM. Use this cheatsheet and the rest of the repo as your one source of truth.
