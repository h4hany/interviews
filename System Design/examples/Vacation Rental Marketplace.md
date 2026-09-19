### Design Vacation Rental Marketplace (Airbnb / Booking.com / Onvaca Style)

> **Context:** This design targets a two-sided marketplace connecting travelers (guests) with property hosts for short-term vacation rentals. It is tailored for a MENA-region platform like **Onvaca** — meaning we must handle Arabic/RTL interfaces, multi-currency (SAR, AED, EGP, USD), and MENA payment gateways alongside global best practices from Airbnb and Booking.com.

---

## System Capabilities

- **Property Listing Management:** Hosts can create, update, and delete listings. Each listing includes title, description, photos, amenities, house rules, location (lat/long), pricing, and availability calendar.
- **Search & Discovery:** Guests search properties by location, check-in/check-out dates, number of guests, price range, amenities, and property type. Results are ranked by relevance, quality, and booking probability.
- **Availability & Calendar Management:** Hosts manage per-day availability and dynamic pricing. The system prevents double-bookings with strong consistency guarantees.
- **Booking & Reservation:** Guests can book a listing for specific dates. The system handles the full lifecycle: pending → confirmed → checked-in → completed → cancelled.
- **Payment Processing:** Multi-currency support (SAR, AED, EGP, USD). Escrow-based flow: guest pays → funds held → host paid out after check-in. Integration with MENA gateways (Tap, HyperPay, Fawry) and global gateways (Stripe).
- **User Management:** Registration, authentication (email, phone, social OAuth), profile management for both guests and hosts. Identity verification for trust & safety.
- **Messaging:** Real-time host-guest communication with abuse detection. Pre-booking inquiries and post-booking coordination.
- **Reviews & Ratings:** Two-way review system (guest reviews host, host reviews guest). Reviews are hidden until both parties submit or the window closes, to prevent bias.
- **Notifications:** Push notifications, SMS, and email for booking confirmations, messages, payment updates, and reminders.
- **Admin Dashboard:** Platform operators manage disputes, payouts, content moderation, and analytics.

---

## System Requirements

### Functional Requirements
- System can handle **30K requests per minute** during peak hours (holiday seasons, weekends).
- Support **500,000 active listings** across the MENA region.
- Handle **5,000 concurrent active bookings** being processed at any moment.
- Support **1 million registered users** (guests + hosts).
- Average listing record size: **8 KB** (metadata without images).
- Average booking record size: **5 KB**.
- Images: Each listing has **10–30 photos**, average **300 KB** per photo.
- Logs grow rapidly; assume **1.5 KB** per request log.
- Search latency target: **< 200ms** (p99).
- Booking confirmation latency: **< 500ms**.

### Non-Functional Requirements
- **High Availability:** 99.9% uptime (≤ 8.76 hours downtime/year).
- **Strong Consistency for Bookings:** No double-bookings, ever. *(DDIA: Linearizability required on the booking path.)*
- **Eventual Consistency for Search:** Acceptable if search results are a few seconds stale. *(DDIA: Eventual consistency — replicas converge over time.)*
- **Low Latency:** Sub-200ms for search, sub-500ms for booking.
- **Multi-language/RTL:** Arabic and English interfaces with right-to-left layout support.
- **Multi-currency:** Handle SAR, AED, EGP, USD with locked exchange rates at booking time.
- **Data Durability:** No data loss for bookings and payments (ACID guarantees).

---

## Answer

### High-Level Architecture

According to the requirements, we need a system that can handle 30K requests per minute, support half a million listings with geo-search, and guarantee no double-bookings. We use a **microservices architecture** to isolate concerns and scale independently.

```
                          ┌──────────────┐
                          │   CDN        │ ← Static assets, listing images
                          │ (CloudFront) │
                          └──────┬───────┘
                                 │
┌──────────────┐          ┌──────▼───────┐
│  Next.js App │──────────│  API Gateway │ ← Auth, Rate Limiting, Routing
│  (Frontend)  │          │ (Kong/Nginx) │
└──────────────┘          └──────┬───────┘
                                 │
                    ┌────────────┼────────────┐
                    │            │            │
              ┌─────▼────┐ ┌────▼─────┐ ┌────▼─────┐
              │ Listing  │ │ Booking  │ │ Search   │
              │ Service  │ │ Service  │ │ Service  │
              │ (NestJS) │ │ (NestJS) │ │ (NestJS) │
              └─────┬────┘ └────┬─────┘ └────┬─────┘
                    │           │             │
              ┌─────▼────┐ ┌────▼─────┐ ┌────▼──────┐
              │PostgreSQL│ │PostgreSQL│ │Elastic    │
              │(Listings)│ │(Bookings)│ │Search     │
              └──────────┘ └──────────┘ └───────────┘
                    │           │             ▲
                    │           │             │
                    └───────────┴─────► Kafka/CDC ──► Updates ES index
```

---

### Core Architecture

- **Frontend:**
  - **Web Application:** Built with **Next.js** (React) for SSR/SSG, delivering fast initial loads and SEO for listing pages. TypeScript for type safety.
  - **RTL/Arabic Support:** Use CSS logical properties (`margin-inline-start` instead of `margin-left`) and `dir="rtl"` attribute. Leverage Next.js i18n routing for `/ar/` and `/en/` prefixes.
  - **State Management:** Redux Toolkit or Zustand for client state (search filters, booking cart, user session).
  - **Responsive Design:** Mobile-first approach. Listings, maps, and booking flows must work flawlessly on mobile browsers (majority of MENA traffic is mobile).
  - Serve static files (JS bundles, CSS, images) via a **CDN** (AWS CloudFront) to minimize latency across MENA.
  - Implement **optimistic UI updates** for actions like wishlisting, and **skeleton loading** for search results.

- **Backend:**
  - Use **NestJS** (Node.js) with a modular microservices architecture:
    - **Listing Service:** CRUD for property listings, amenities, photos, house rules.
    - **Booking Service:** Reservation lifecycle, availability checks, hold-then-confirm flow.
    - **Search Service:** Facade over Elasticsearch for geo-search, filtering, ranking.
    - **Payment Service:** Payment processing, escrow management, payouts.
    - **User Service:** Authentication (JWT, OAuth 2.0), profile management, identity verification.
    - **Messaging Service:** Host-guest real-time chat via WebSockets.
    - **Notification Service:** Push, SMS (Twilio), Email (SendGrid/SES).
    - **Calendar Service:** Per-day availability and dynamic pricing management.
    - **Review Service:** Two-way reviews with reveal-after-both-submit logic.
  - Use **NestJS modules** for clean separation: each service is a NestJS module with its own controllers, services, guards, and interceptors.
  - Use **NestJS Guards** for authentication (`@UseGuards(JwtAuthGuard)`) and **Interceptors** for logging, response transformation, and caching.
  - Deploy on **AWS ECS** (containers) or **Kubernetes** for auto-scaling.

- **API Gateway:**
  - Use **Kong** or **AWS API Gateway** to handle:
    - Request routing to appropriate microservices.
    - **JWT validation** at the gateway level (reducing load on services).
    - **Rate limiting** (e.g., 100 requests/minute per user).
    - **Request/response caching** for popular search queries.
  - Support both **REST** (for CRUD operations) and **GraphQL** (for flexible frontend data fetching — e.g., a single query to get listing + host + reviews + availability).

- **Load Balancer:**
  - **AWS ALB** (Application Load Balancer) to distribute requests across multiple NestJS instances.
  - Health checks to automatically remove unhealthy instances.
  - Sticky sessions for WebSocket connections (messaging).

- **Message Queue:**
  - **Apache Kafka** for event-driven architecture:
    - Booking events → trigger payment processing, notification, analytics.
    - Listing updates → trigger Elasticsearch re-indexing (CDC pattern).
    - Payment events → trigger payout scheduling, receipt generation.
  - **AWS SQS** for simpler async tasks: email delivery, image processing, report generation.

---

### Database Design

> **DDIA Concept — Choosing the Right Data Model:**  
> We use a **polyglot persistence** approach. Different data stores for different access patterns. The key insight from DDIA Chapter 2 is: *"Relational databases are great for joins and transactions; document databases are great for self-contained documents; search indexes are great for full-text and geo queries."*

#### Relational Database (PostgreSQL) — Source of Truth

PostgreSQL is the primary database for **all transactional data** requiring ACID guarantees.

**Why PostgreSQL?**
- ACID compliance for bookings and payments (no double-bookings).
- PostGIS extension for geospatial queries (listing locations).
- Strong ecosystem with TypeORM/Prisma for NestJS integration.
- Supports row-level locking for concurrent booking scenarios.

##### Core Tables & Schema

```sql
-- USERS
CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email           VARCHAR(255) UNIQUE NOT NULL,
    phone           VARCHAR(20),
    password_hash   VARCHAR(255) NOT NULL,
    full_name       VARCHAR(255) NOT NULL,
    avatar_url      VARCHAR(500),
    role            VARCHAR(20) NOT NULL DEFAULT 'guest',  -- 'guest', 'host', 'admin'
    id_verified     BOOLEAN DEFAULT FALSE,
    preferred_lang  VARCHAR(5) DEFAULT 'en',    -- 'ar', 'en'
    preferred_currency VARCHAR(3) DEFAULT 'USD', -- 'SAR', 'AED', 'EGP', 'USD'
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);

-- LISTINGS
CREATE TABLE listings (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    host_id         UUID NOT NULL REFERENCES users(id),
    title           VARCHAR(255) NOT NULL,
    title_ar        VARCHAR(255),                -- Arabic title
    description     TEXT NOT NULL,
    description_ar  TEXT,                         -- Arabic description
    property_type   VARCHAR(50) NOT NULL,         -- 'apartment', 'villa', 'chalet', 'studio'
    country         VARCHAR(3) NOT NULL,          -- ISO country code
    city            VARCHAR(100) NOT NULL,
    address         TEXT NOT NULL,
    latitude        DECIMAL(10, 8) NOT NULL,
    longitude       DECIMAL(11, 8) NOT NULL,
    location        GEOGRAPHY(POINT, 4326),       -- PostGIS geospatial column
    max_guests      SMALLINT NOT NULL,
    bedrooms        SMALLINT NOT NULL,
    bathrooms       SMALLINT NOT NULL,
    base_price      DECIMAL(10, 2) NOT NULL,      -- Per-night price in listing currency
    currency        VARCHAR(3) NOT NULL DEFAULT 'SAR',
    cleaning_fee    DECIMAL(10, 2) DEFAULT 0,
    service_fee_pct DECIMAL(5, 2) DEFAULT 10.00,  -- Platform fee percentage
    status          VARCHAR(20) DEFAULT 'draft',  -- 'draft', 'active', 'paused', 'archived'
    avg_rating      DECIMAL(3, 2) DEFAULT 0,
    review_count    INTEGER DEFAULT 0,
    is_instant_book BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- PostGIS spatial index for geo-queries
CREATE INDEX idx_listings_location ON listings USING GIST(location);
CREATE INDEX idx_listings_host ON listings(host_id);
CREATE INDEX idx_listings_status ON listings(status);
CREATE INDEX idx_listings_city ON listings(city);

-- LISTING AMENITIES (many-to-many)
CREATE TABLE amenities (
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100),
    icon    VARCHAR(50)
);

CREATE TABLE listing_amenities (
    listing_id  UUID REFERENCES listings(id) ON DELETE CASCADE,
    amenity_id  INTEGER REFERENCES amenities(id),
    PRIMARY KEY (listing_id, amenity_id)
);

-- LISTING PHOTOS
CREATE TABLE listing_photos (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id  UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    url         VARCHAR(500) NOT NULL,       -- S3 URL
    caption     VARCHAR(255),
    sort_order  SMALLINT DEFAULT 0,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_photos_listing ON listing_photos(listing_id);

-- AVAILABILITY CALENDAR (row-per-day model)
-- This is the KEY table for preventing double-bookings
CREATE TABLE calendar (
    listing_id   UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    date         DATE NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    price        DECIMAL(10, 2),              -- Override base price for this date
    min_nights   SMALLINT DEFAULT 1,
    booking_id   UUID REFERENCES bookings(id), -- NULL if available, FK if booked
    PRIMARY KEY (listing_id, date)
);

-- Composite index for availability range queries
CREATE INDEX idx_calendar_avail ON calendar(listing_id, date, is_available);

-- BOOKINGS
CREATE TABLE bookings (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id      UUID NOT NULL REFERENCES listings(id),
    guest_id        UUID NOT NULL REFERENCES users(id),
    host_id         UUID NOT NULL REFERENCES users(id),
    check_in        DATE NOT NULL,
    check_out       DATE NOT NULL,
    num_guests      SMALLINT NOT NULL,
    nights          SMALLINT NOT NULL,
    base_total      DECIMAL(10, 2) NOT NULL,   -- Sum of per-night prices
    cleaning_fee    DECIMAL(10, 2) DEFAULT 0,
    service_fee     DECIMAL(10, 2) DEFAULT 0,  -- Platform fee
    total_price     DECIMAL(10, 2) NOT NULL,   -- Grand total
    currency        VARCHAR(3) NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'pending',
    -- Status: 'pending' → 'confirmed' → 'checked_in' → 'completed' → 'reviewed'
    --                    → 'cancelled' (from pending or confirmed)
    --                    → 'declined' (by host)
    cancelled_by    VARCHAR(10),               -- 'guest', 'host', 'system'
    cancellation_reason TEXT,
    version         INTEGER DEFAULT 1,         -- Optimistic locking
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_bookings_listing ON bookings(listing_id, check_in, check_out);
CREATE INDEX idx_bookings_guest ON bookings(guest_id);
CREATE INDEX idx_bookings_host ON bookings(host_id);
CREATE INDEX idx_bookings_status ON bookings(status);

-- PAYMENTS (Double-Entry Ledger)
CREATE TABLE payments (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id      UUID NOT NULL REFERENCES bookings(id),
    idempotency_key VARCHAR(255) UNIQUE NOT NULL, -- Prevent duplicate charges
    type            VARCHAR(20) NOT NULL,          -- 'charge', 'refund', 'payout'
    amount          DECIMAL(10, 2) NOT NULL,
    currency        VARCHAR(3) NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'pending',
    -- Status: 'pending' → 'processing' → 'succeeded' → 'failed'
    gateway         VARCHAR(50),                   -- 'stripe', 'tap', 'hyperpay', 'fawry'
    gateway_txn_id  VARCHAR(255),                  -- External transaction ID
    paid_at         TIMESTAMPTZ,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_payments_booking ON payments(booking_id);
CREATE INDEX idx_payments_idempotency ON payments(idempotency_key);

-- REVIEWS (two-way)
CREATE TABLE reviews (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id      UUID NOT NULL REFERENCES bookings(id),
    reviewer_id     UUID NOT NULL REFERENCES users(id),
    reviewee_id     UUID NOT NULL REFERENCES users(id),
    listing_id      UUID NOT NULL REFERENCES listings(id),
    type            VARCHAR(20) NOT NULL,      -- 'guest_to_host', 'host_to_guest'
    rating          SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    cleanliness     SMALLINT CHECK (cleanliness BETWEEN 1 AND 5),
    communication   SMALLINT CHECK (communication BETWEEN 1 AND 5),
    location_rating SMALLINT CHECK (location_rating BETWEEN 1 AND 5),
    value_rating    SMALLINT CHECK (value_rating BETWEEN 1 AND 5),
    comment         TEXT,
    is_visible      BOOLEAN DEFAULT FALSE,     -- Visible only after both submit
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_reviews_listing ON reviews(listing_id);
CREATE INDEX idx_reviews_booking ON reviews(booking_id);

-- MESSAGES
CREATE TABLE messages (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    thread_id   UUID NOT NULL,                  -- Conversation thread
    sender_id   UUID NOT NULL REFERENCES users(id),
    receiver_id UUID NOT NULL REFERENCES users(id),
    booking_id  UUID REFERENCES bookings(id),   -- Optional: linked to a booking
    content     TEXT NOT NULL,
    is_read     BOOLEAN DEFAULT FALSE,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_messages_thread ON messages(thread_id, created_at);
CREATE INDEX idx_messages_receiver ON messages(receiver_id, is_read);
```

> **DDIA Concept — Row-Per-Day Calendar Model (Chapter 2 & 3):**  
> The `calendar` table uses a **row-per-day** model instead of storing date ranges. This makes availability queries trivially fast with a range scan:  
> `SELECT * FROM calendar WHERE listing_id = X AND date BETWEEN '2026-12-01' AND '2026-12-07' AND is_available = TRUE`  
> The composite primary key `(listing_id, date)` creates a natural **B-tree clustered index**, making range scans sequential I/O — the fastest possible read pattern from disk (DDIA Chapter 3: LSM-Trees vs B-Trees).

#### Search Index (Elasticsearch) — Read-Optimized

Elasticsearch stores a **denormalized, read-optimized** copy of listing data for search and discovery.

```json
{
  "listing_id": "uuid-123",
  "title": "Luxury Villa in Dubai Marina",
  "title_ar": "فيلا فاخرة في دبي مارينا",
  "description": "...",
  "property_type": "villa",
  "location": { "lat": 25.0801, "lon": 55.1402 },
  "city": "Dubai",
  "country": "AE",
  "base_price": 450.00,
  "currency": "AED",
  "max_guests": 8,
  "bedrooms": 4,
  "bathrooms": 3,
  "amenities": ["wifi", "pool", "parking", "ac", "kitchen"],
  "avg_rating": 4.7,
  "review_count": 89,
  "is_instant_book": true,
  "host_response_rate": 0.98,
  "photos": ["https://cdn.onvaca.com/..."],
  "available_dates": ["2026-12-01", "2026-12-02", "..."],
  "updated_at": "2026-09-17T00:00:00Z"
}
```

> **DDIA Concept — CQRS and Event-Driven Data Sync (Chapter 11):**  
> We use **Change Data Capture (CDC)** via Kafka Connect / Debezium to stream changes from PostgreSQL to Elasticsearch. This implements the **CQRS** (Command Query Responsibility Segregation) pattern:
> - **Commands** (writes): Go to PostgreSQL → strong consistency, ACID.
> - **Queries** (reads/search): Go to Elasticsearch → optimized for speed, eventually consistent.
> The lag between a listing update in PostgreSQL and its appearance in Elasticsearch is typically **< 2 seconds** — acceptable for search results.

#### Cache Layer (Redis)

- **Session Management:** Store active user sessions with TTL.
- **Availability Cache:** Cache frequently checked availability for popular listings (TTL: 60 seconds).
- **Search Result Cache:** Cache popular search queries (e.g., "Dubai villas Dec 2026") with TTL: 5 minutes.
- **Booking Holds:** Temporary locks on listing dates during the booking flow (TTL: 10 minutes).
- **Rate Limiting:** Track per-user API request counts using Redis sorted sets.
- **Real-time Messaging:** Redis Pub/Sub for broadcasting new messages to connected WebSocket clients.

---

### Storage Estimation

- **For 500,000 listings:**
    - Listing metadata: 500,000 × 8 KB = **4 GB**
    - Calendar data (365 days × 500K listings): 182.5 million rows × 50 bytes = **~9 GB**
    - Amenity mappings: 500,000 × 10 amenities × 20 bytes = **100 MB**

- **For 1,000,000 users:**
    - User profiles: 1,000,000 × 3 KB = **3 GB**

- **For bookings:**
    - Active bookings: 5,000 × 5 KB = **25 MB**
    - Historical bookings: 500K bookings/year × 5 KB = **2.5 GB/year**
    - Store for 3 years = 2.5 GB × 3 = **7.5 GB**

- **For images:**
    - Listing photos: 500,000 listings × 20 photos × 300 KB = **3 TB**
    - User avatars: 1,000,000 × 100 KB = **100 GB**
    - **Total images: ~3.1 TB** (stored in AWS S3, served via CloudFront CDN)

- **For reviews:**
    - 500K reviews × 2 KB = **1 GB**

- **For messages:**
    - 5 million messages/year × 500 bytes = **2.5 GB/year**

- **For logs:**
    - 30K requests/min × 60 min × 24 hrs × 30 days × 1.5 KB = **~2 TB/month**
    - Store for 3 months = **~6 TB**
    - Use log rotation and ship to cold storage (S3 Glacier) after 30 days.

- **Elasticsearch index:**
    - 500K listings × 5 KB (denormalized) = **2.5 GB** (fits in memory for fast queries)

- **Backup:**
    - Daily PostgreSQL backups: ~30 GB (with WAL archiving for point-in-time recovery)
    - Weekly full + daily incremental: **~200 GB** backup storage

- **Total storage: ~12 TB** (with growth based on usage and retention policies)

---

### API Design

> **DDIA Concept — API as a Contract (Chapter 4: Encoding and Evolution):**  
> APIs should be **backward compatible**. Use API versioning (`/api/v1/`, `/api/v2/`). For GraphQL, use `@deprecated` directive on fields you plan to remove. This allows old clients to keep working while new clients use updated fields.

#### REST API Endpoints

```
# ========== LISTINGS ==========
POST   /api/v1/listings                     # Create listing (host)
GET    /api/v1/listings/:id                 # Get listing details
PUT    /api/v1/listings/:id                 # Update listing (host)
DELETE /api/v1/listings/:id                 # Delete listing (host)
GET    /api/v1/listings/:id/calendar        # Get availability calendar
PUT    /api/v1/listings/:id/calendar        # Update availability/pricing
POST   /api/v1/listings/:id/photos          # Upload photos (multipart)
DELETE /api/v1/listings/:id/photos/:photoId # Delete photo

# ========== SEARCH ==========
GET    /api/v1/search?lat=25.08&lng=55.14&check_in=2026-12-01&check_out=2026-12-07&guests=4&min_price=100&max_price=500&amenities=wifi,pool&page=1&limit=20

# ========== BOOKINGS ==========
POST   /api/v1/bookings                     # Create booking (guest)
GET    /api/v1/bookings/:id                 # Get booking details
PUT    /api/v1/bookings/:id/confirm         # Confirm booking (host, if not instant-book)
PUT    /api/v1/bookings/:id/cancel          # Cancel booking
GET    /api/v1/users/me/bookings            # My bookings (guest or host)

# ========== PAYMENTS ==========
POST   /api/v1/payments/charge              # Charge guest for booking
POST   /api/v1/payments/refund              # Process refund
GET    /api/v1/payments/booking/:bookingId  # Payment status

# ========== USERS ==========
POST   /api/v1/auth/register                # Register
POST   /api/v1/auth/login                   # Login (returns JWT)
POST   /api/v1/auth/refresh                 # Refresh token
GET    /api/v1/users/me                     # Current user profile
PUT    /api/v1/users/me                     # Update profile

# ========== REVIEWS ==========
POST   /api/v1/reviews                      # Submit review
GET    /api/v1/listings/:id/reviews         # Get reviews for listing

# ========== MESSAGES ==========
GET    /api/v1/messages/threads              # List conversation threads
GET    /api/v1/messages/threads/:threadId    # Get messages in thread
POST   /api/v1/messages                      # Send message
WS     /ws/messages                          # WebSocket for real-time messaging
```

#### GraphQL API (for flexible frontend queries)

```graphql
type Query {
  listing(id: ID!): Listing
  searchListings(input: SearchInput!): SearchResult!
  myBookings(status: BookingStatus): [Booking!]!
  myMessages: [Thread!]!
}

type Mutation {
  createBooking(input: CreateBookingInput!): Booking!
  cancelBooking(bookingId: ID!, reason: String): Booking!
  submitReview(input: ReviewInput!): Review!
  sendMessage(threadId: ID!, content: String!): Message!
}

type Subscription {
  newMessage(threadId: ID!): Message!
  bookingStatusChanged(bookingId: ID!): Booking!
}
```

---

### Deep Dive #1: Preventing Double-Bookings (The Critical Problem)

> **DDIA Concept — Write Skew and Phantoms (Chapter 7):**  
> The double-booking problem is a textbook case of **write skew**: two transactions both read that dates are available, both decide to book, and both commit — resulting in two bookings for the same dates. This is a **phantom** problem because the rows being checked (available dates) are the same rows being modified.

#### The Problem

Two guests simultaneously try to book the same villa for Dec 1–7:
1. Guest A reads calendar → dates are available ✅
2. Guest B reads calendar → dates are available ✅
3. Guest A writes booking → confirmed ✅
4. Guest B writes booking → confirmed ✅ ← **DOUBLE BOOKING!**

#### The Solution: Hold-Then-Confirm with Pessimistic Locking

```
Guest clicks "Book Now"
        │
        ▼
┌───────────────────────────┐
│ 1. ACQUIRE HOLD (Redis)   │ ← SET listing:uuid:2026-12-01..07 EX 600 NX
│    TTL = 10 minutes       │   (NX = only if NOT exists → atomic lock)
│    If lock exists → FAIL  │
└───────────┬───────────────┘
            │ Lock acquired
            ▼
┌───────────────────────────┐
│ 2. VERIFY AVAILABILITY    │ ← PostgreSQL: SELECT ... FOR UPDATE
│    (Pessimistic lock)     │   Lock rows in calendar table
│    Double-check dates     │
└───────────┬───────────────┘
            │ Dates available
            ▼
┌───────────────────────────┐
│ 3. PROCESS PAYMENT        │ ← Charge guest via payment gateway
│    (with idempotency key) │   If payment fails → release lock
└───────────┬───────────────┘
            │ Payment succeeded
            ▼
┌───────────────────────────┐
│ 4. COMMIT BOOKING         │ ← In a single DB transaction:
│    (ACID Transaction)     │   - INSERT into bookings
│                           │   - UPDATE calendar SET is_available=FALSE
│                           │   - Publish event to Kafka
└───────────┬───────────────┘
            │
            ▼
┌───────────────────────────┐
│ 5. RELEASE HOLD (Redis)   │ ← DEL listing:uuid:2026-12-01..07
│    Send confirmation      │
└───────────────────────────┘
```

**Why this works:**
- **Redis `SET NX`** provides an **atomic distributed lock**. Only one guest can hold dates at a time.
- **PostgreSQL `SELECT ... FOR UPDATE`** provides **pessimistic row-level locking**. If the Redis lock somehow fails (race condition at the millisecond level), the database is the last line of defense.
- **10-minute TTL** ensures abandoned holds don't block inventory forever.
- **Idempotency key** on payments ensures the guest isn't charged twice if the network hiccups.

> **DDIA Concept — Two-Phase Locking (2PL) (Chapter 7):**  
> `SELECT ... FOR UPDATE` implements 2PL at the database level. The transaction acquires locks on the calendar rows and holds them until COMMIT or ROLLBACK. This guarantees **serializability** — the strongest isolation level — for the booking path.

**NestJS Implementation Pattern:**

```typescript
// booking.service.ts
@Injectable()
export class BookingService {
  constructor(
    @InjectRepository(Booking) private bookingRepo: Repository<Booking>,
    @InjectRepository(Calendar) private calendarRepo: Repository<Calendar>,
    private readonly redisService: RedisService,
    private readonly paymentService: PaymentService,
    private readonly dataSource: DataSource,
  ) {}

  async createBooking(dto: CreateBookingDto, guestId: string): Promise<Booking> {
    const lockKey = `hold:${dto.listingId}:${dto.checkIn}:${dto.checkOut}`;
    
    // Step 1: Acquire distributed lock
    const lockAcquired = await this.redisService.set(lockKey, guestId, 'EX', 600, 'NX');
    if (!lockAcquired) {
      throw new ConflictException('These dates are being held by another guest');
    }

    try {
      // Step 2-4: Verify + Pay + Commit in a transaction
      return await this.dataSource.transaction(async (manager) => {
        // Pessimistic lock on calendar rows
        const dates = await manager
          .createQueryBuilder(Calendar, 'c')
          .setLock('pessimistic_write')
          .where('c.listing_id = :listingId', { listingId: dto.listingId })
          .andWhere('c.date >= :checkIn AND c.date < :checkOut', {
            checkIn: dto.checkIn,
            checkOut: dto.checkOut,
          })
          .getMany();

        // Verify ALL dates are available
        if (dates.some(d => !d.isAvailable)) {
          throw new ConflictException('Some dates are no longer available');
        }

        // Process payment
        const payment = await this.paymentService.charge({
          amount: dto.totalPrice,
          currency: dto.currency,
          idempotencyKey: dto.idempotencyKey,
        });

        // Create booking
        const booking = manager.create(Booking, { ...dto, guestId, status: 'confirmed' });
        await manager.save(booking);

        // Mark calendar dates as booked
        await manager
          .createQueryBuilder()
          .update(Calendar)
          .set({ isAvailable: false, bookingId: booking.id })
          .where('listing_id = :listingId AND date >= :checkIn AND date < :checkOut', {
            listingId: dto.listingId,
            checkIn: dto.checkIn,
            checkOut: dto.checkOut,
          })
          .execute();

        return booking;
      });
    } finally {
      // Step 5: Always release the lock
      await this.redisService.del(lockKey);
    }
  }
}
```

---

### Deep Dive #2: Search & Discovery Architecture

> **DDIA Concept — Derived Data Systems (Chapter 11 & 12):**  
> The search index is a **derived data system**. PostgreSQL is the **system of record** (source of truth). Elasticsearch is a **derived view** optimized for a specific query pattern (geo + full-text + faceted search). The data flow is one-directional: PostgreSQL → Kafka → Elasticsearch.

#### Search Flow

```
Guest types "Dubai, 4 guests, Dec 1-7"
        │
        ▼
┌────────────────────────┐
│   Next.js Frontend     │ ← Debounced search input
│   GET /api/v1/search   │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│   Redis Cache Check    │ ← Cache key: hash(lat,lng,dates,guests,filters)
│   TTL: 5 minutes       │   If HIT → return cached results
└───────────┬────────────┘
            │ Cache MISS
            ▼
┌────────────────────────┐
│   Elasticsearch Query  │ ← Geo-distance + date availability + filters
│                        │
│   {                    │
│     "query": {         │
│       "bool": {        │
│         "must": [      │
│           { "geo_distance": { "distance": "20km", ... } },
│           { "range": { "max_guests": { "gte": 4 } } },
│           { "terms": { "available_dates": [...] } }
│         ],             │
│         "filter": [    │
│           { "range": { "base_price": { "gte": 100, "lte": 500 } } },
│           { "terms": { "amenities": ["wifi", "pool"] } }
│         ]              │
│       }                │
│     },                 │
│     "sort": [          │
│       { "_score": "desc" },
│       { "avg_rating": "desc" }
│     ]                  │
│   }                    │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│   Rank & Return        │ ← Apply business ranking (quality score, 
│                        │   response rate, instant book bonus)
│                        │   Cache result in Redis
│                        │   Return paginated results
└────────────────────────┘
```

#### Geo-Indexing Strategy

- Use **Elasticsearch's `geo_point`** field type with `geo_distance` queries.
- Alternatively, use **geohashing** to partition listings into grid cells for efficient spatial queries.
- For map-based search, use **geo_bounding_box** queries when the user pans/zooms the map.

> **DDIA Concept — Partitioning Secondary Indexes (Chapter 6):**  
> Elasticsearch internally partitions (shards) its index. For geo-queries, it uses a **global secondary index** approach — each shard contains listings from all regions, but the geo-spatial index within each shard allows efficient filtering. This avoids the **scatter-gather** problem of document-partitioned indexes where every shard must be queried.

#### Search Ranking Factors

| Factor | Weight | Description |
| :--- | :--- | :--- |
| **Geo Distance** | High | Closer to searched location = ranked higher |
| **Price Match** | High | Within guest's budget |
| **Availability** | Required | Must have dates available |
| **Quality Score** | Medium | avg_rating × review_count |
| **Host Response Rate** | Medium | Faster responders ranked higher |
| **Instant Book** | Low-Medium | Instant book listings get a small boost |
| **Recency** | Low | Recently updated listings get a freshness boost |
| **Photos** | Low | Listings with more/professional photos |

---

### Deep Dive #3: Payment System (Multi-Currency, MENA Gateways)

#### Payment Flow (Escrow Model)

```
Guest books listing (SAR 1,500 / 3 nights)
        │
        ▼
┌─────────────────────────────────────────────────┐
│ 1. CHARGE GUEST                                  │
│    Gateway: Tap (MENA) or Stripe (international) │
│    Amount: SAR 1,500 + SAR 150 service fee       │
│    Total: SAR 1,650                              │
│    Idempotency Key: booking_uuid_v1              │
│    → Funds captured, held in platform account     │
└──────────────────────┬──────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│ 2. ESCROW HOLD                                   │
│    Internal ledger entry:                        │
│    DEBIT  guest_account   SAR 1,650              │
│    CREDIT escrow_account  SAR 1,650              │
│    → Money is "frozen" until payout trigger       │
└──────────────────────┬──────────────────────────┘
                       │
          ┌────────────┴────────────┐
          │                         │
    CHECK-IN + 24hrs           CANCELLATION
          │                         │
          ▼                         ▼
┌──────────────────┐   ┌────────────────────────┐
│ 3a. PAYOUT HOST  │   │ 3b. REFUND GUEST       │
│ DEBIT  escrow    │   │ DEBIT  escrow  SAR X   │
│ CREDIT host_acct │   │ CREDIT guest   SAR X   │
│ Amount: SAR 1,500│   │ (Per cancellation       │
│ Platform keeps:  │   │  policy: full/partial)  │
│ SAR 150 (10% fee)│   └────────────────────────┘
└──────────────────┘
```

#### Multi-Currency Handling

```
Guest pays in AED → Platform stores in SAR → Host receives in EGP

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│ Presentment  │     │   Internal   │     │  Settlement  │
│ Currency     │────▶│   Ledger     │────▶│  Currency    │
│ AED 500      │     │   SAR 490    │     │  EGP 7,500   │
│ (guest sees) │     │(locked rate) │     │ (host gets)  │
└──────────────┘     └──────────────┘     └──────────────┘
```

- **Exchange rate locked at booking time** to protect both parties from volatility.
- Store both `presentment_amount` + `presentment_currency` and `settlement_amount` + `settlement_currency` in the payment record.
- Use treasury APIs (e.g., Open Exchange Rates) to fetch rates, with a small markup to cover currency risk.

#### MENA Payment Gateway Integration

| Gateway | Markets | Methods |
| :--- | :--- | :--- |
| **Tap** | UAE, KSA, Kuwait, Bahrain, Qatar | Cards, Apple Pay, mada, KNET |
| **HyperPay** | KSA, UAE, Egypt, Jordan | Cards, mada, STC Pay, Apple Pay |
| **Fawry** | Egypt | Cash payment at retail points, mobile wallets |
| **Stripe** | Global fallback | International cards, Google Pay, Apple Pay |

**NestJS Payment Service Pattern:**

```typescript
// payment.service.ts — Strategy pattern for multiple gateways
@Injectable()
export class PaymentService {
  private gateways: Map<string, PaymentGateway>;

  constructor(
    private readonly tapGateway: TapGateway,
    private readonly stripeGateway: StripeGateway,
    private readonly hyperpayGateway: HyperPayGateway,
  ) {
    this.gateways = new Map([
      ['tap', tapGateway],
      ['stripe', stripeGateway],
      ['hyperpay', hyperpayGateway],
    ]);
  }

  async charge(dto: ChargeDto): Promise<PaymentResult> {
    const gateway = this.resolveGateway(dto.country, dto.paymentMethod);
    
    // Idempotency: check if this key was already processed
    const existing = await this.paymentRepo.findOne({
      where: { idempotencyKey: dto.idempotencyKey },
    });
    if (existing) return existing; // Return original result, don't charge again
    
    return gateway.charge(dto);
  }

  private resolveGateway(country: string, method: string): PaymentGateway {
    if (['SA', 'AE', 'KW', 'BH', 'QA'].includes(country)) return this.gateways.get('tap');
    if (country === 'EG') return this.gateways.get('hyperpay');
    return this.gateways.get('stripe');
  }
}
```

---

### Deep Dive #4: Real-Time Messaging

#### Architecture

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Next.js     │────▶│  WebSocket   │────▶│   Redis      │
│  Frontend    │     │  Gateway     │     │   Pub/Sub    │
│  (Socket.io) │◀────│  (NestJS WS) │◀────│              │
└──────────────┘     └──────┬───────┘     └──────────────┘
                            │
                     ┌──────▼───────┐
                     │  PostgreSQL  │ ← Persistent storage
                     │  (messages)  │   for message history
                     └──────────────┘
```

- **WebSocket Gateway** (NestJS `@WebSocketGateway()`) handles real-time connections.
- Messages are **persisted to PostgreSQL** for history and **published to Redis Pub/Sub** for instant delivery.
- If the recipient is offline, the message is stored and a **push notification** is sent via FCM/APNs.
- **Abuse detection:** NestJS interceptor scans messages for blocked keywords, spam patterns, and contact info sharing attempts (to prevent off-platform transactions).

---

### Load Balancer & Application Servers

#### Application Server Calculation

To handle 30K requests per minute:
> 30K requests / 60 seconds = **500 requests per second**  
> Assuming each NestJS instance handles ~100 req/s (conservative estimate with DB calls):  
> 500 / 100 = **5 instances minimum**  
> Add 40% buffer for peak traffic: 5 × 1.4 = **7 instances**

Deploy **8–10 NestJS instances** across **2 AWS availability zones** for redundancy.

#### WebSocket Servers (Messaging)

> 5,000 concurrent messaging sessions  
> Each WebSocket server handles ~2,500 connections  
> **2 WebSocket servers minimum**, deploy **4 for redundancy**

---

### Cache Strategy

| Data | Cache Location | TTL | Strategy |
| :--- | :--- | :--- | :--- |
| Search results | Redis | 5 min | Write-behind (invalidate on listing change) |
| Listing details | Redis | 15 min | Cache-aside with lazy loading |
| Availability | Redis | 60 sec | Short TTL (high change frequency) |
| User sessions | Redis | 24 hrs | Write-through |
| Popular listings | Redis | 10 min | Pre-warm on deployment |
| Exchange rates | Redis | 1 hr | Refresh from treasury API |

> **DDIA Concept — Cache Invalidation (Chapter 11):**  
> Cache invalidation is one of the two hard problems in computer science. We use **event-driven invalidation**: when a booking is created, a Kafka event triggers cache deletion for that listing's availability. This is more reliable than TTL-based expiry alone.

---

### Logging & Monitoring

- **Logging Stack:** ELK (Elasticsearch, Logstash, Kibana) or AWS CloudWatch Logs.
  - **Application logs:** Errors, warnings, business events (booking created, payment failed).
  - **Access logs:** API request/response times, status codes.
  - **Audit logs:** Payment transactions, admin actions, account changes (immutable, append-only).

- **Monitoring:** Prometheus + Grafana dashboards.
  - **Business Metrics:** Bookings/hour, search-to-booking conversion rate, average booking value.
  - **Technical Metrics:** p99 latency, error rate, DB connection pool utilization.
  - **Alerting:** PagerDuty/Slack alerts for: error rate > 1%, p99 > 2s, payment failure rate > 5%.

---

### Security

- **Authentication & Authorization:**
  - **JWT** (access tokens, 15-min expiry) + **Refresh Tokens** (7-day expiry, stored in HTTP-only cookies).
  - **OAuth 2.0** for social login (Google, Apple).
  - **RBAC** via NestJS Guards: `@Roles('host')`, `@Roles('admin')`.
  - Phone number verification via OTP (critical for MENA market trust).

- **Data Protection:**
  - Encrypt data at rest (AWS RDS encryption, S3 SSE).
  - Encrypt data in transit (HTTPS/TLS everywhere).
  - PCI DSS compliance for payment data — never store raw card numbers; delegate to payment gateways.
  - GDPR-ready: user data export and deletion endpoints.

- **API Security:**
  - Rate limiting: 100 req/min per user (Redis-based sliding window).
  - Input validation: NestJS `ValidationPipe` with `class-validator` decorators.
  - SQL injection prevention: parameterized queries via TypeORM/Prisma.
  - CORS configuration: whitelist only `*.onvaca.com` origins.
  - Helmet.js middleware for HTTP security headers.

---

### Scaling Strategies

> **DDIA Concept — Partitioning (Chapter 6):**  
> As data grows, a single PostgreSQL instance won't suffice. We use a combination of **vertical partitioning** (splitting tables across databases) and **horizontal partitioning** (sharding within a table).

- **Database Scaling:**
  - **Read Replicas:** Deploy 2–3 PostgreSQL read replicas. Route read queries (listing details, booking history) to replicas; writes (new bookings) to the primary. *(DDIA: Single-leader replication, Chapter 5)*
  - **Table Partitioning:** Partition `bookings` table by month (`PARTITION BY RANGE (created_at)`). Archive bookings older than 2 years to cold storage.
  - **Sharding Strategy:** If traffic exceeds a single primary's capacity, shard by `listing_id` or geographic region (MENA countries). *(DDIA: Key-range vs hash partitioning, Chapter 6)*

- **Application Scaling:**
  - **Auto-scaling:** AWS ECS auto-scaling based on CPU > 70% or request count metrics.
  - **Horizontal scaling:** NestJS services are stateless — add more container instances behind the ALB.
  - **Pre-scaling:** Scale up before known peak periods (Eid holidays, summer vacation season in MENA).

- **Search Scaling:**
  - Elasticsearch cluster with **3 data nodes** and **2 replicas** per shard.
  - If listing count exceeds 5M, increase shards and distribute across more nodes.

- **CDN & Static Assets:**
  - **AWS CloudFront** with edge locations in Dubai, Riyadh, Cairo, Amman.
  - Image optimization pipeline: on upload, generate multiple sizes (thumbnail 150px, medium 600px, large 1200px, WebP format).
  - **Lazy loading** images on the frontend to reduce initial page load.

---

### Handling Key Scenarios (Interview Talking Points)

#### Scenario 1: "What happens during Eid holiday spike?"

Pre-scale infrastructure 24 hours before. Redis warms with popular search queries. CDN caches listing pages. Auto-scaling adds NestJS instances. Elasticsearch read replicas handle the search surge. The booking path (PostgreSQL) remains strongly consistent — we never sacrifice correctness for performance.

#### Scenario 2: "Host updates price during an active booking attempt"

The `SELECT ... FOR UPDATE` lock on calendar rows means the price change is blocked until the booking transaction commits or rolls back. The booking uses the price that was locked at the start of the transaction. The host's update applies after.

#### Scenario 3: "Payment gateway goes down"

The Payment Service uses a **circuit breaker pattern** (NestJS `@nestjs/terminus` or custom). After 5 consecutive failures, the circuit opens and returns an immediate error. The system automatically retries with a fallback gateway (e.g., switch from Tap to Stripe). Pending bookings are held in Redis (10-min TTL) so the guest doesn't lose their hold.

#### Scenario 4: "How do you handle Arabic/RTL?"

- CSS: Use **logical properties** (`margin-inline-start` not `margin-left`). One stylesheet works for both LTR and RTL.
- Next.js: i18n routing (`/ar/listings/...` vs `/en/listings/...`). Use `next-intl` or `next-i18next` for translations.
- Database: Store both `title` and `title_ar` columns. API returns the appropriate one based on `Accept-Language` header.
- Search: Elasticsearch supports Arabic analyzers with stemming and stop words.
- Numbers: Format prices with Arabic numerals (`١٬٥٠٠ ر.س`) when `locale = ar`.

---

### DDIA Concepts Summary — How They Apply

| DDIA Concept | Chapter | How It Applies Here |
| :--- | :--- | :--- |
| **Linearizability** | 9 | Booking path must be linearizable — no stale reads when checking availability |
| **Eventual Consistency** | 5 | Search results can be eventually consistent (ES index lags PostgreSQL by ~2s) |
| **Single-Leader Replication** | 5 | PostgreSQL primary handles all writes; read replicas serve read queries |
| **Partitioning (Sharding)** | 6 | Calendar table partitioned by listing_id; bookings partitioned by date range |
| **B-Tree Indexes** | 3 | Composite index on `(listing_id, date)` for efficient range scans |
| **Write Skew / Phantoms** | 7 | Double-booking is a write-skew anomaly; solved with `SELECT FOR UPDATE` (2PL) |
| **Two-Phase Locking (2PL)** | 7 | `SELECT ... FOR UPDATE` acquires row locks held until COMMIT |
| **Change Data Capture (CDC)** | 11 | Debezium streams PostgreSQL changes to Kafka → Elasticsearch |
| **CQRS** | 11-12 | Writes to PostgreSQL, reads from Elasticsearch (derived data) |
| **Idempotency** | 11 | Payment idempotency keys prevent duplicate charges on retry |
| **Stream Processing** | 11 | Kafka streams power async workflows: notifications, analytics, search sync |
| **Encoding & Evolution** | 4 | API versioning ensures backward compatibility as the system evolves |
| **Fault Tolerance** | 8 | Circuit breakers for external services; retry with exponential backoff |
| **CAP Theorem** | 9 | Booking = CP (consistency over availability). Search = AP (availability over consistency) |

---

### Tech Stack Summary (Aligned with Onvaca Job Description)

| Layer | Technology | Why |
| :--- | :--- | :--- |
| **Frontend** | Next.js, React, TypeScript | SSR for SEO, fast loads, component reusability |
| **State Mgmt** | Redux Toolkit / Zustand | Predictable state for search filters, booking flow |
| **Backend** | NestJS (Node.js), TypeScript | Modular architecture, DI, guards, interceptors |
| **REST API** | NestJS Controllers | CRUD operations, standard endpoints |
| **GraphQL** | NestJS + Apollo | Flexible queries for frontend data needs |
| **Primary DB** | PostgreSQL + PostGIS | ACID for bookings, geospatial for locations |
| **ORM** | TypeORM or Prisma | Schema management, migrations, type-safe queries |
| **Search** | Elasticsearch | Geo-search, full-text, faceted filtering |
| **Cache** | Redis | Sessions, holds, caching, pub/sub, rate limiting |
| **Message Queue** | Apache Kafka | Event streaming, CDC, async processing |
| **File Storage** | AWS S3 | Listing photos, user documents |
| **CDN** | AWS CloudFront | Fast image delivery across MENA |
| **Auth** | JWT + OAuth 2.0 | Stateless auth, social login |
| **Payments** | Tap, HyperPay, Stripe | MENA-specific + global coverage |
| **Containerization** | Docker + AWS ECS | Consistent deployments, auto-scaling |
| **CI/CD** | GitHub Actions | Automated testing and deployment |
| **Monitoring** | Prometheus + Grafana | Real-time metrics and alerting |
| **Logging** | ELK Stack / CloudWatch | Centralized logging and analysis |

---

### Summary

- **Frontend:** Next.js + React SSR/SSG served via CloudFront CDN. Arabic/RTL via CSS logical properties and i18n routing.
- **Backend:** NestJS microservices with modules, guards, interceptors, and DI. REST + GraphQL APIs.
- **Database:** PostgreSQL (source of truth for bookings/payments — ACID) + Elasticsearch (search — eventually consistent) + Redis (cache, sessions, distributed locks).
- **Booking Safety:** Hold-then-confirm pattern with Redis distributed lock + PostgreSQL pessimistic locking (`SELECT FOR UPDATE`). Zero double-bookings guaranteed.
- **Payments:** Escrow model with multi-currency support. Idempotency keys prevent duplicate charges. MENA gateways (Tap, HyperPay, Fawry) + Stripe fallback.
- **Data Pipeline:** Kafka CDC streams PostgreSQL changes to Elasticsearch in near-real-time (< 2s lag).
- **Scaling:** Horizontal auto-scaling with read replicas, table partitioning, and CDN caching. Pre-scale before Eid/holiday peaks.
- **Monitoring:** Prometheus/Grafana for metrics, ELK for logs, PagerDuty for alerts.
- **Security:** JWT + OAuth, RBAC guards, input validation, PCI compliance, encryption at rest and in transit.

---

### Interview Pro Tips

1. **Always start with requirements.** Ask: "How many listings? How many concurrent users? What regions? What consistency guarantees?"
2. **Draw the architecture first.** Boxes and arrows. Label each component. Explain data flow.
3. **Focus on the hard problem.** For a booking system, the hard problem is **preventing double-bookings**. Show you understand write-skew, locking strategies, and ACID transactions.
4. **Explain trade-offs.** Why eventual consistency for search but strong consistency for bookings? Why PostgreSQL for bookings but Elasticsearch for search? Every choice has a "why."
5. **Reference DDIA.** Mentioning concepts like "linearizability," "write skew," "CDC," and "CQRS" shows depth and signals you've studied distributed systems seriously.
6. **Tailor to the company.** For Onvaca: mention MENA payment gateways, Arabic/RTL support, multi-currency handling, and mobile-first design. These details show you've done your homework.
7. **Know your stack.** For this role: NestJS modules/guards/interceptors, TypeORM/Prisma migrations, Next.js SSR vs SSG, Redis caching patterns, PostgreSQL indexing. Be ready to code any of these.
