# Engineering Standards

## 1. Overview
A core responsibility of a Technical Lead is establishing, evolving, and enforcing engineering standards. Standards ensure consistency, reduce cognitive load for onboarding, and maintain system quality.

## 2. Types of Standards to Establish

### 2.1 Coding Standards
- **Style Guides:** Adopt industry standards (e.g., Google Python Style Guide, Airbnb JavaScript Style Guide) rather than inventing your own. Enforce via linters (ESLint, Ruff, Prettier, Black) integrated into pre-commit hooks and CI/CD.
- **Error Handling:** Standardize how exceptions are raised, caught, and logged. (e.g., "All API boundaries must catch domain errors and return appropriate HTTP 4xx status codes").
- **Logging & Observability:** Define standard log levels, structured logging formats (JSON), and required context (Trace IDs, User IDs).

### 2.2 Documentation Standards
- **README Driven Development:** Every repository must have a README detailing setup, environment variables, run commands, and architecture overview.
- **Architectural Decision Records (ADRs):** A lightweight markdown format to capture *why* a technical decision was made. Includes: Context, Options Considered, Decision, and Consequences.
- **Code Comments:** Focus on *Why*, not *What*. The code tells you what; the comment tells you why the business rule exists.

### 2.3 Testing Standards
- **Test Pyramid:** Define expectations for Unit, Integration, and E2E tests.
- **Coverage Metrics:** Set realistic minimums (e.g., 70-80%), but emphasize *critical path coverage* over raw percentages.
- **Mocking Boundaries:** Standardize what gets mocked (external HTTP calls, DBs in unit tests) and what uses real instances (Testcontainers for integration tests).

### 2.4 Definition of Done (DoD)
A standard checklist before a feature is considered complete:
- Code is written and passes linting.
- Unit/Integration tests are written and passing.
- CI/CD pipeline is green.
- Code reviewed and approved by at least 1 peer.
- Documentation/Swagger/OpenAPI is updated.
- Observability (metrics/alerts) added for new features.

## 3. How to Implement Standards Without Micromanaging
1. **Automate Everything:** If a standard can be checked by a machine, it should be. Humans should not argue over indentation in PRs.
2. **Tech Radar / RFC Process:** Allow engineers to propose changes to standards via a Request For Comments (RFC) document. This fosters ownership.
3. **Lead by Example:** The TL must adhere to the standards more strictly than anyone else.

## 4. Interview Questions

### Question 1: How do you establish and enforce engineering standards on a new team?
**What they are testing:** Process creation, automation, team buy-in, avoiding dictatorial leadership.
**Short Answer:** I focus on consensus for the "what," and automation for the "how." I use linters, CI checks, and PR templates to enforce standards automatically, removing subjective arguments from code reviews.
**Detailed Answer:** When joining a new team, I don't immediately drop a 50-page rulebook. First, I observe the current pain points. Then, I propose adopting industry-standard style guides (like Airbnb for JS) to avoid bikeshedding. The golden rule is: **Automate enforcement**. We add Prettier, ESLint, and SonarQube to our CI pipeline. If a rule can't be automated, we add it to the PR template as a checklist. To ensure continuous improvement, I introduce ADRs (Architecture Decision Records) so major technical choices are documented. I get buy-in by showing how these standards reduce cognitive load and PR review times.
**Common Mistakes:** Saying "I write a wiki page and tell everyone to read it." (Nobody reads it). Focusing only on syntax rather than architecture or testing.
**Strong TL Answer:** Discusses the psychology of change management. Emphasizes shifting enforcement from humans (which causes friction) to machines (which are objective). Mentions ADRs and Definition of Done.

### Question 2: Your team is arguing endlessly about which testing framework or ORM to use. How do you resolve this and set a standard?
**What they are testing:** Conflict resolution, decision-making frameworks, handling ambiguity.
**Strong TL Answer:** I use the RFC (Request for Comments) process. I ask the strongest proponents of each option to write a short 1-page document outlining the pros, cons, integration costs, and maintenance burden. We then review these against our actual business constraints (time to market, performance needs). If it's a two-way door decision (easily reversible), I might suggest a time-boxed spike (proof of concept). If it's a one-way door, I will eventually make the executive call based on the data, emphasizing that we need to "disagree and commit." Once the decision is made, we document it in an ADR so the debate isn't reopened in 6 months.
