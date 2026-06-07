# Procore — Company Research & Construction Domain Knowledge

---

## Procore at a Glance

| Attribute | Detail |
|-----------|--------|
| **Founded** | 2002 |
| **Ticker** | NYSE: PCOR |
| **Revenue** | ~$1.37B trailing (2026) |
| **Industry** | Construction Management Software (SaaS) |
| **HQ** | Carpinteria, CA — offices in Cairo, Egypt and worldwide |
| **CEO** | Ajei Gopal (ex-Ansys) |
| **Users** | Millions — owners, GCs, subcontractors, architects, engineers |
| **Core Values** | **Openness, Optimism, Ownership** |

---

## Technology Stack

| Layer | Technology |
|-------|-----------|
| **Backend** | Ruby on Rails (since 2002) |
| **Database** | PostgreSQL |
| **Caching** | Redis |
| **Background Jobs** | Sidekiq |
| **Infrastructure** | Kubernetes, AWS |
| **Observability** | OpenTelemetry, Honeycomb, Datadog |
| **Open Source** | Blueprinter (JSON serializer), active Rails contributor |
| **Architecture** | Modular monolith → transitioning to SOA |
| **AI Platform** | Procore Helix (intelligence layer), Procore Assist (AI assistant) |

---

## Engineering Culture

- **Modular Monolith Philosophy** — extract services only when team ownership, deployment independence, or scaling characteristics justify it
- **Observability First** — as they scale microservices, observability is treated as a first-class concern
- **TDD & Code Quality** — strong emphasis on testing, code review, and developer experience
- **AI Integration** — AI is a core workflow, not just a feature; Procore Assist handles photo analysis for safety, is multilingual, and mobile-first
- **Decision Making** — decisions made at the appropriate level, not strictly top-down

---

## Construction Domain Terminology

Understanding these concepts is critical for system design and architecture interviews:

### RFI (Request for Information)
A formal question from a contractor/subcontractor to the architect or owner seeking clarification about drawings, specs, schedules, or project conditions.

**Typical States:** Draft → Open → Under Review → Answered → Closed / Rejected

**Key Attributes:** Subject, question, due date, responsible contractor, "ball-in-court" user, attachments, official response, audit trail.

### Submittal
A workflow where contractors submit materials, drawings, shop drawings, or product data for review/approval by the architect or owner.

**Typical States:** Draft → Submitted → In Review → Revise & Resubmit → Approved → Closed

**Key Attributes:** Specification section, review steps, sequential/parallel approvals, attachments.

### Punch List / Punch Items
A list of tasks that must be completed or corrected before a construction project is considered finished. Typically created during the final walkthrough.

**Key Attributes:** Item description, location/area, assignee (responsible contractor), photos, status, priority, verification.

### Daily Log
A record of daily activities on a construction site: work completed, weather, workforce count, deliveries, visitors, notes, incidents.

### Drawing / Drawing Set
Construction plans and blueprints. The "current set" is the latest approved version. Teams must always work from the current version.

**Key Concept:** Version control for drawings is critical — building from outdated drawings causes costly rework.

### Budget / Cost Code
Financial tracking for construction projects. Budget line items are organized by cost codes. Change orders modify the budget.

### Change Order
A formal document that modifies the scope, cost, or timeline of a construction contract. Must be tracked with audit trails.

### Inspection
Formal verification that work meets specifications and code requirements. May be done by internal teams or external inspectors.

### Correspondence
Formal communication between project parties. Must be tracked for legal and contractual purposes.

---

## Procore Product Coverage

| Module | Description |
|--------|-------------|
| **Project Management** | Tasks, schedules, calendars, meetings |
| **Quality & Safety** | Inspections, observations, incidents |
| **Financial Management** | Budgets, contracts, invoices, change orders |
| **Document Management** | Drawings, specs, photos, version control |
| **BIM** | 3D model coordination |
| **Field Productivity** | Daily logs, time tracking, T&M tickets |
| **Analytics** | Dashboards, reports, insights |
| **Integrations** | 500+ partners, marketplace, public API |

---

## Multi-Party Collaboration Model

Procore serves **multiple types of companies** on the same project:

```text
Owner (Client)
  └── General Contractor (GC)
        ├── Subcontractor A (Electrical)
        ├── Subcontractor B (Plumbing)
        └── Subcontractor C (HVAC)
  └── Architect
  └── Consultant / Engineer
```

**Implications for Architecture:**
- **Multi-tenancy** — data isolation between companies
- **Project-scoped permissions** — different roles on different projects
- **Cross-company collaboration** — users from different companies work on the same RFI/submittal
- **Audit trails** — decisions have contractual/legal impact
- **Complex permission models** — RBAC + project context + company context

---

## Key Domain Questions to Prepare

When an interviewer gives you a system design problem, frame your thinking around:

1. **Who are the users?** (GC, subcontractor, architect, owner, field worker)
2. **What is the workflow lifecycle?** (states, transitions, approvals)
3. **What data needs to be strongly consistent?** (status changes, official answers, financial data)
4. **What can be eventually consistent?** (notifications, search, analytics)
5. **What has contractual/legal significance?** (audit logs, version history, change orders)
6. **Does this need offline/mobile support?** (field workers have poor connectivity)
7. **How do permissions work?** (project-scoped, role-based, multi-company)
