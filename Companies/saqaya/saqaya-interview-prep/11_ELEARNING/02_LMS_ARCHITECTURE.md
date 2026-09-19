# LMS Technical Architecture

A Learning Management System is a complex suite of highly integrated components. Modern LMS architectures have moved from monoliths (like early Moodle) to microservices or modular monoliths to handle scale and flexibility.

## Core Components Architecture

```mermaid
graph TD
    Client[Web/Mobile Client] --> API_GW[API Gateway]
    
    API_GW --> Auth[Identity & Access (RBAC)]
    API_GW --> Catalog[Course Catalog Service]
    API_GW --> Delivery[Content Delivery Service]
    API_GW --> Progress[Progress & Tracking Service]
    API_GW --> Assessment[Assessment Engine]
    
    Delivery --> Content_Store[(S3/CDN Content Storage)]
    
    Progress --> Kafka[Event Bus/Kafka]
    Assessment --> Kafka
    
    Kafka --> Reporting[Reporting & Analytics Service]
    Kafka --> Notification[Notification Service (Email/Push)]
    
    Reporting --> Data_Warehouse[(Data Warehouse)]
```

### 1. Multi-Tenancy Models
B2B LMS platforms serve multiple organizations.
- **Database per tenant:** Highest isolation, highest cost, hardest to schema-migrate. Used for strict compliance (healthcare/gov).
- **Schema per tenant:** Good balance in PostgreSQL. Data is isolated logically.
- **Shared Schema (Tenant ID column):** Most common for SaaS. Lowest cost, easiest to query across tenants, but requires strict row-level security (RLS) to prevent data leaks.

### 2. User Roles and Permissions (RBAC)
eLearning has deeply hierarchical permission models.
- Roles: Super Admin, Tenant Admin, Instructor, Manager, Learner, Parent.
- Implementation: Use robust policy engines (e.g., OPA - Open Policy Agent) or mature RBAC libraries. Evaluating "Can Manager X view the grades of Learner Y for Course Z" requires traversing organizational graphs.

### 3. Content Storage and Delivery
- **Assets:** Videos, PDFs, Images stored in Object Storage (S3) served via CDN (CloudFront) to ensure low latency globally.
- **Video Streaming:** Never serve raw MP4s. Use HLS (HTTP Live Streaming) or DASH. This allows adaptive bitrate streaming (dropping quality on poor connections) and makes it harder to pirate content.
- **Metadata:** Course structures, titles, tags stored in the relational database.

### 4. Progress Tracking Engine
Must record state accurately. If a user refreshes the page, they must resume the video exactly at `00:14:32`.
- High write volume. Needs fast data stores (Redis or fast RDBMS writes).
- Often uses Event Sourcing: Store every interaction (`video_started`, `video_paused`, `quiz_submitted`), then calculate the current state by replaying events.

### 5. Assessment Engine
Handles quizzes and exams.
- **Integrity:** State must be saved continuously so dropped connections don't lose answers.
- **Scoring:** Synchronous (multiple choice) vs Asynchronous (essay peer-review).
- **Data Model:** Highly normalized to handle question banks, randomization of options, and historical versions of questions.

### 6. Integration Patterns
LMS systems never exist in isolation.
- **HRIS Integration (Workday, SAP):** Syncing user accounts, roles, and org charts via SCIM or daily batch SFTP.
- **CRM Integration (Salesforce):** For selling courses.
- **Webhooks:** Pushing real-time events (e.g., `certification_achieved`) to external systems.

## Interview Questions
**Q: How would you design a scalable video progression tracking system to ensure a user has actually watched a video and didn't just skip to the end?**
*A: I would not rely solely on the video player's `onEnded` event, as that can be manipulated or triggered by seeking. Instead, I'd implement a "heartbeat" architecture. The client sends a small payload every 10 seconds to an endpoint containing the current playhead position. The backend validates this against the previous ping to ensure the jump is valid (e.g., < 12 seconds difference). These high-throughput pings can be ingested via a message queue (Kafka/Kinesis) or directly into a fast store like Redis, and then aggregated into the persistent database periodically to calculate true "watched time."*

**Q: Discuss the trade-offs of using a Microservices vs Modular Monolith architecture for a new LMS startup.**
*A: For a startup, I strongly advocate for a Modular Monolith. An LMS domain is highly cohesive—progress tracking relies heavily on the content structure; reporting relies on everything. Splitting into microservices too early introduces distributed data management, complex distributed transactions (e.g., creating a user and assigning a course simultaneously), and deployment overhead. A Modular Monolith enforces strict internal boundaries between domains (Catalog, Progress, Assessment) but keeps them in a single deployment and database. We can break out specific services (like video transcoding or report generation) into microservices later when scaling demands it.*
