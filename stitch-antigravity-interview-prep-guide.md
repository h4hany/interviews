# Google Stitch → Antigravity: Interview Prep App
### Complete Workflow Guide — Design to Production React App

---

## Table of Contents

1. [What Are These Tools?](#1-what-are-these-tools)
2. [The Full Workflow Overview](#2-the-full-workflow-overview)
3. [PART A — Google Stitch: Design the UI](#part-a--google-stitch-design-the-ui)
   - [Step 1: Open Stitch & Start a Project](#step-1-open-stitch--start-a-project)
   - [Step 2: The Master Stitch Prompt (Your App)](#step-2-the-master-stitch-prompt-your-app)
   - [Screen-by-Screen Prompts](#screen-by-screen-prompts)
   - [Step 3: Export & API Key](#step-3-export--api-key)
4. [PART B — Antigravity: Connect Stitch via MCP](#part-b--antigravity-connect-stitch-via-mcp)
   - [Step 1: Install Antigravity](#step-1-install-antigravity)
   - [Step 2: Install the Stitch MCP Server](#step-2-install-the-stitch-mcp-server)
   - [Step 3: Verify the Connection](#step-3-verify-the-connection)
   - [Step 4: Pull Design DNA](#step-4-pull-design-dna)
5. [PART C — Antigravity: Scaffold the Empty React Project](#part-c--antigravity-scaffold-the-empty-react-project)
   - [The Empty Project Prompt](#the-empty-project-prompt)
   - [Expected Project Structure](#expected-project-structure)
6. [PART D — Build the App: Prompts for Each Feature](#part-d--build-the-app-prompts-for-each-feature)
7. [Tips & Troubleshooting](#tips--troubleshooting)

---

## 1. What Are These Tools?

| Tool | What It Does |
|------|-------------|
| **Google Stitch** | AI design tool — turns natural language prompts into high-fidelity UI screens with real HTML/CSS. Free at [stitch.withgoogle.com](https://stitch.withgoogle.com) |
| **Google Antigravity** | Agent-first IDE (VS Code fork) — an autonomous AI agent that plans, writes, tests, and fixes real code. Free in preview at [antigravity.google](https://antigravity.google) |
| **Stitch MCP** | The bridge — lets Antigravity read your Stitch designs directly, so it converts pixels to code without guessing |

**The workflow in one sentence:** Design every screen in Stitch → connect via MCP → tell Antigravity to build it as a React app using the design files.

---

## 2. The Full Workflow Overview

```
[Google Stitch]          [MCP Bridge]          [Antigravity IDE]
  Design screens    →    API Key + MCP    →    Agent builds React app
  Export DESIGN.md       server install        from your Stitch designs
```

---

## PART A — Google Stitch: Design the UI

### Step 1: Open Stitch & Start a Project

1. Go to [stitch.withgoogle.com](https://stitch.withgoogle.com) and sign in with Google
2. Click **New Project** — name it `interview-prep-hub`
3. Choose **Gemini 2.5 Pro (Experimental)** mode for higher quality output
4. Select **Web App** as your target platform

---

### Step 2: The Master Stitch Prompt (Your App)

Use this as your **first prompt** to establish the overall design system:

```
Design a VS Code-inspired developer interview preparation web application called "PrepHub".

## App Context
This is a personal study tool for a senior backend engineer preparing for Staff-level engineering interviews. It reads markdown files from a GitHub repository and presents them in an interactive, gamified learning experience.

## Design System
- Theme: Dark developer aesthetic — background #0D1117 (GitHub dark), sidebar #161B22, panels #1C2128
- Accent color: Electric cyan #00D4FF as primary interactive color
- Secondary accent: Amber #F0A000 for XP/achievement elements
- Typography: JetBrains Mono for code blocks, IBM Plex Sans for body text, Space Grotesk for headings
- Border radius: 6px for cards, 4px for buttons (sharp, developer tool feel)
- Borders: 1px solid #30363D (GitHub-style subtle separators)

## Layout (Desktop-first, then responsive)
Three-column layout:
1. LEFT SIDEBAR (240px): Collapsible file tree navigator with folder/file icons
2. CENTER (flex): Main content area — markdown renderer with syntax highlighting
3. RIGHT SIDEBAR (280px): Context panel — quiz mode, progress tracker, bookmarks

## Content Types in the App
- System design explanations (with architecture diagrams)
- Code snippets with line-by-line explanations
- STAR behavioral answers
- LeetCode algorithm patterns

## Gamification Elements
- XP points bar at the top (like a game HUD)
- "Streak" flame indicator
- Topic completion percentage rings
- Achievement badge display
```

---

### Screen-by-Screen Prompts

After the master prompt sets the design system, prompt for **each screen individually**:

---

#### Screen 1: Main Layout (Dashboard / Reader View)

```
Generate the main app layout for PrepHub with all three panels visible.

LEFT PANEL — File Tree:
- App logo "PrepHub" with a terminal icon at the top
- Search box: "Search topics..." with CMD+K shortcut hint
- Folder tree with these sections (collapsed by default, expandable):
  📁 System Design (12 files)
  📁 Code Patterns (8 files)  
  📁 Behavioral / STAR (6 files)
  📁 LeetCode 75 (75 files)
- Each file shows: icon, filename, and a small green dot if completed
- Bottom: user avatar, "Hany" username, current XP level badge

CENTER PANEL — Markdown Reader:
- Breadcrumb: Home > System Design > Rate Limiting
- Content area with rendered markdown: headings, code blocks with syntax highlighting in dark theme, tables, blockquotes
- Floating bottom toolbar: Previous / Next topic navigation arrows, bookmark icon, mark as complete checkmark button

RIGHT PANEL — Context:
- "TODAY'S PROGRESS" card: XP earned today (e.g. 340 XP), topics read (3), quiz score (2/3)
- "QUICK QUIZ" card: Shows a flashcard question from the current topic with Show Answer / Skip buttons
- "RELATED TOPICS" list: 3 clickable topic suggestions

TOP BAR:
- XP progress bar spanning full width (Level 4 Engineer — 2340/3000 XP)
- 🔥 5-day streak badge
- Current topic title
- Search icon (opens CMD+K palette)
```

---

#### Screen 2: Search / Command Palette

```
Generate the Command Palette overlay for PrepHub (CMD+K).

Style: Centered modal overlay, dark glass panel 640px wide, blurred background
- Search input at top with magnifier icon and placeholder "Search topics, patterns, concepts..."
- Results appear below instantly (no submit button)
- Each result row: topic icon | topic title | category tag (pill) | match snippet
- Keyboard hint at bottom: ↑↓ navigate • Enter open • Esc close
- Group results by category with subtle section headers
- Show recently viewed topics at the top when search is empty
```

---

#### Screen 3: Quiz / Flashcard Mode

```
Generate the Quiz Mode screen for PrepHub.

Full-screen takeover replacing the center panel only (sidebars remain).

QUIZ CARD (centered, 600px wide):
- Progress: "Question 3 of 10" with a thin progress bar
- Category badge: e.g. "System Design"
- Question text: Large, readable — e.g. "What is the CAP theorem and how does it apply to distributed databases?"
- Card flip animation hint (subtle border glow)
- Two states: QUESTION side and ANSWER side (same card, flipped)

ANSWER SIDE shows:
- Answer text with key terms highlighted in cyan
- Three self-rating buttons: "Got it ✓" (green) | "Almost 〜" (amber) | "Missed ✗" (red)

BOTTOM BAR:
- XP earned this session: "+120 XP"
- "Exit Quiz" link
```

---

#### Screen 4: Progress Dashboard

```
Generate the Progress / Stats Dashboard screen for PrepHub.

Full page replacing the center content area.

HEADER: "Your Progress" with total XP and level displayed prominently

TOP STATS ROW (4 metric cards):
- Topics Completed: 34/101
- Current Streak: 🔥 5 days  
- Quiz Accuracy: 78%
- Study Time: 12h 40m

CATEGORY PROGRESS (circular rings, side by side):
- System Design: 67% (ring in cyan)
- LeetCode Patterns: 28% (ring in amber)
- Behavioral STAR: 83% (ring in green)
- Code Explanations: 45% (ring in purple)

RECENT ACTIVITY FEED:
- Timeline list: icon | "Completed: Consistent Hashing" | "30 min ago" | "+50 XP"

ACHIEVEMENTS SECTION:
- Badge grid: locked badges shown as outlines, unlocked ones filled and glowing
- Example badges: "First Quiz", "7-Day Streak", "System Design Master"
```

---

#### Screen 5: Mobile Responsive View

```
Generate the mobile layout (375px width) for PrepHub.

- Single column layout
- LEFT sidebar hidden behind hamburger menu (slides in from left as overlay)
- RIGHT panel hidden behind a tab bar at the bottom (Quiz / Progress / Related)
- CENTER content takes full width
- TOP BAR: hamburger | PrepHub logo | XP bar (compressed) | streak badge
- Bottom tab bar: 📁 Topics | 🎯 Quiz | 📊 Progress | 🔖 Saved
```

---

### Step 3: Export & API Key

**Get your Stitch API Key:**

1. In Stitch, click your **profile picture** (top right)
2. Go to **Stitch Settings**
3. Click **Create API Key**
4. Copy the key immediately — store it safely (you'll use it once in Antigravity)

**Optional — Export DESIGN.md:**

1. In Stitch, open your project settings
2. Click **Export → DESIGN.md**
3. Save this file — it contains your full design system (colors, fonts, spacing tokens)
4. You'll drop this into your project root in Antigravity

---

## PART B — Antigravity: Connect Stitch via MCP

### Step 1: Install Antigravity

1. Download from [antigravity.google](https://antigravity.google)
2. Install like any app (macOS: drag to Applications, Windows: run `.exe`)
3. Sign in with your **Google account**
4. Click **+ Open Workspace** → select or create your project folder

---

### Step 2: Install the Stitch MCP Server

**Method 1 — MCP Store (Easiest):**

1. In Antigravity, find the **Agent window** on the right side
2. Click the **three dots (⋯)** → select **MCP Servers**
3. Search for `stitch`
4. Click **Install**
5. When prompted, paste your **Stitch API Key**
6. Click **Save**

**Method 2 — Manual config (if MCP store doesn't show Stitch):**

Open `~/.antigravity/mcp-servers.json` and add:

```json
{
  "servers": {
    "stitch": {
      "command": "npx",
      "args": ["@google/stitch-mcp-server"],
      "env": {
        "STITCH_API_KEY": "YOUR_API_KEY_HERE"
      }
    }
  }
}
```

Restart Antigravity after saving.

**Method 3 — npx CLI approach:**

```bash
npx @_davideast/stitch-mcp init
```

This runs a guided wizard that handles auth and MCP config automatically.

---

### Step 3: Verify the Connection

In the Antigravity agent chat, type:

```
List my Stitch projects.
```

If it returns `interview-prep-hub`, the bridge is working. ✅

---

### Step 4: Pull Design DNA

Tell the agent to extract your design system:

```
Use the Stitch MCP to fetch my "interview-prep-hub" project.
Extract the full color palette, typography, spacing tokens, and component styles.
Generate a DESIGN.md file in my project root directory with all design rules formatted for agent use.
```

Review the generated `DESIGN.md` — it will look something like:

```markdown
# PrepHub Design System

## Colors
- Background: #0D1117
- Sidebar: #161B22
- Accent: #00D4FF
...

## Typography
- Headings: Space Grotesk
- Body: IBM Plex Sans
- Code: JetBrains Mono
...
```

---

## PART C — Antigravity: Scaffold the Empty React Project

### The Empty Project Prompt

Use this as your **first Antigravity prompt** to scaffold the entire project structure before building any features:

```
Create a new React application called "PrepHub" — an interview preparation tool that reads markdown files from a GitHub repository and presents them in an interactive VS Code-style reader.

## Tech Stack
- React 18 with TypeScript
- Vite as the build tool
- Tailwind CSS for styling (configured with the DESIGN.md design system)
- React Router v6 for navigation
- Zustand for state management
- react-markdown + rehype-highlight for markdown rendering with syntax highlighting
- No backend — all data is fetched directly from GitHub's raw content API

## Project Structure to Create

```
interview-prep-hub/
├── public/
│   └── favicon.ico
├── src/
│   ├── components/
│   │   ├── layout/
│   │   │   ├── AppShell.tsx          # Three-column layout wrapper
│   │   │   ├── Sidebar.tsx           # Left file tree sidebar
│   │   │   └── ContextPanel.tsx      # Right quiz/progress panel
│   │   ├── reader/
│   │   │   ├── MarkdownRenderer.tsx  # Renders MD with syntax highlight
│   │   │   ├── Breadcrumb.tsx        # Topic breadcrumb nav
│   │   │   └── TopicNav.tsx          # Prev/next topic buttons
│   │   ├── quiz/
│   │   │   ├── FlashCard.tsx         # Flip card component
│   │   │   ├── QuizSession.tsx       # Quiz mode controller
│   │   │   └── RatingButtons.tsx     # Got it / Almost / Missed
│   │   ├── progress/
│   │   │   ├── XPBar.tsx             # Top XP progress bar
│   │   │   ├── StreakBadge.tsx       # Flame streak indicator
│   │   │   ├── CategoryRing.tsx      # Circular progress ring
│   │   │   └── AchievementBadge.tsx  # Badge display
│   │   ├── search/
│   │   │   └── CommandPalette.tsx    # CMD+K search overlay
│   │   └── ui/
│   │       ├── Button.tsx
│   │       ├── Card.tsx
│   │       ├── Badge.tsx
│   │       └── Spinner.tsx
│   ├── pages/
│   │   ├── ReaderPage.tsx            # Main reader view
│   │   ├── ProgressPage.tsx          # Stats dashboard
│   │   └── QuizPage.tsx              # Full quiz mode
│   ├── store/
│   │   ├── progressStore.ts          # Zustand: XP, completed topics, streaks
│   │   ├── quizStore.ts              # Zustand: quiz session state
│   │   └── uiStore.ts                # Zustand: sidebar open, theme, etc.
│   ├── hooks/
│   │   ├── useGitHubContent.ts       # Fetches MD files from GitHub API
│   │   ├── useKeyboardShortcuts.ts   # CMD+K, arrow keys, etc.
│   │   └── useLocalStorage.ts        # Persist progress to localStorage
│   ├── lib/
│   │   ├── github.ts                 # GitHub raw content fetcher
│   │   ├── markdown.ts               # MD parsing utilities
│   │   └── xp.ts                     # XP calculation logic
│   ├── types/
│   │   └── index.ts                  # All TypeScript interfaces
│   ├── styles/
│   │   └── globals.css               # Tailwind base + custom CSS vars
│   ├── config/
│   │   └── repo.ts                   # GitHub repo URL, folder structure
│   ├── App.tsx
│   └── main.tsx
├── DESIGN.md                         # Design system (from Stitch)
├── AGENTS.md                         # Agent instructions for this project
├── tailwind.config.ts
├── tsconfig.json
├── vite.config.ts
└── package.json
```

## Setup Instructions for the Agent
1. Run `npm create vite@latest . -- --template react-ts`
2. Install all dependencies listed above
3. Configure Tailwind with the design tokens from DESIGN.md
4. Create all files listed in the structure above as empty stubs with correct TypeScript interfaces
5. Set up React Router with routes: `/` (reader), `/progress`, `/quiz/:topicId`
6. Configure Zustand stores with their initial state shapes
7. Do NOT build any feature logic yet — just the scaffolding, types, and empty components
8. Write a README.md explaining the project structure

After setup, open the browser preview and confirm Vite starts with no TypeScript errors.
```

---

### Expected Project Structure

After running the scaffold prompt, verify the agent created:

```bash
# Run this in terminal to check
find src -name "*.tsx" -o -name "*.ts" | sort
```

You should see all files listed in the structure. If any are missing, prompt:

```
You missed creating [filename]. Create it now as a stub with the correct TypeScript types.
```

---

## PART D — Build the App: Prompts for Each Feature

Once scaffold is done and the project runs, build features one at a time:

---

### Feature 1: GitHub Content Fetcher

```
Implement the GitHub content fetcher in src/lib/github.ts and src/hooks/useGitHubContent.ts.

The app reads from this public GitHub repo: [YOUR_REPO_URL]

Requirements:
- Fetch the repo's file tree using GitHub's contents API (no auth needed for public repos)
- Group files by their folder into categories (System Design, LeetCode, Behavioral, etc.)
- Fetch individual file content as raw markdown text
- Cache fetched content in memory to avoid re-fetching
- Handle loading and error states

Use the Stitch MCP to fetch the file tree display from my "interview-prep-hub" Stitch project and implement the Sidebar component to match it exactly.
```

---

### Feature 2: Markdown Reader

```
Implement the MarkdownRenderer component.

- Use react-markdown with rehype-highlight for syntax highlighting
- Code blocks should use a dark theme matching our design system
- Support: headings, tables, blockquotes, inline code, images
- Add a "Copy" button that appears on hover over each code block
- Heading anchors: each H2/H3 should have a clickable # link

Use the Stitch MCP to fetch the reader screen design from my "interview-prep-hub" project and match the typography and spacing exactly.
```

---

### Feature 3: XP & Progress System

```
Implement the full XP and progress system.

In src/store/progressStore.ts (Zustand):
- Track completed topic IDs (Set<string>)
- Track XP points (starts at 0)
- Track current streak (days) and last study date
- Persist everything to localStorage using useLocalStorage hook

XP Rules:
- Read a topic: +10 XP
- Complete a topic (mark done): +50 XP
- Quiz correct answer: +25 XP
- Daily streak bonus: +100 XP per day

Implement XPBar.tsx and StreakBadge.tsx components.
Use the Stitch MCP to fetch these components from my "interview-prep-hub" project and match the design exactly.
```

---

### Feature 4: Quiz / Flashcard System

```
Implement the Quiz system.

The quiz generates questions from the currently loaded markdown file.
Use this approach:
- Extract H2/H3 headings from the markdown as question prompts
- The answer is the paragraph immediately following the heading
- Store quiz results in quizStore.ts (Zustand)

Build FlashCard.tsx with a CSS flip animation:
- Front: Question text + category badge
- Back: Answer text with key terms highlighted
- Rating buttons: Got it (+25 XP) / Almost (+10 XP) / Missed (0 XP)

Use the Stitch MCP to fetch the quiz card design from my "interview-prep-hub" project and match the flip card animation and button styles exactly.
```

---

### Feature 5: Command Palette Search

```
Implement the CMD+K command palette search.

Behavior:
- Opens on CMD+K (Mac) / CTRL+K (Windows)
- Searches across all topic titles and content
- Shows results grouped by category (System Design, LeetCode, etc.)
- Keyboard navigation: ↑↓ to move, Enter to open, Esc to close
- Recent topics shown when search is empty

Use fuse.js for fuzzy search across file titles and folder names.

Use the Stitch MCP to fetch the command palette overlay design from my "interview-prep-hub" project and match it exactly.
```

---

## Tips & Troubleshooting

### Stitch Tips

| Problem | Solution |
|---------|----------|
| Design looks generic | Switch to Gemini 2.5 Pro (Experimental) mode, be more specific in prompts |
| Colors wrong | Include exact hex codes in your prompt (e.g. `background #0D1117`) |
| Layout doesn't match | Add pixel measurements: `sidebar 240px wide`, `max-content-width 720px` |
| Components don't align | Do one screen at a time, not multiple screens in one prompt |

### Antigravity Tips

| Problem | Solution |
|---------|----------|
| MCP not showing Stitch | Restart Antigravity after config change, check API key has no spaces |
| Agent builds wrong thing | Always reference the DESIGN.md at start of each prompt |
| TypeScript errors | Prompt: `Fix all TypeScript errors in the current file without changing logic` |
| Agent goes off-track | Prompt: `Stop. Review AGENTS.md and DESIGN.md, then continue` |

### AGENTS.md — Create This File

Drop this file in your project root so the Antigravity agent always has context:

```markdown
# PrepHub — Agent Instructions

## Project
Interview preparation React app reading MD files from GitHub.

## Stack
React 18, TypeScript, Vite, Tailwind CSS, Zustand, React Router v6

## Design Rules
Always reference DESIGN.md for colors, fonts, and spacing.
Never use colors not defined in DESIGN.md.

## Code Rules
- All components must have TypeScript props interfaces
- State goes in Zustand stores, not component useState (except local UI state)
- No inline styles — Tailwind classes only
- Fetch logic goes in hooks/, not in components

## Current Phase
[Update this as you progress: Scaffolding / Feature Build / Polish]
```

---

*Built with Google Stitch + Antigravity — the design-first AI development pipeline, 2026*
