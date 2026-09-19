# Onvaca — Senior Full-Stack Developer Interview Preparation Guide

> **Company:** Onvaca — a vacation rental marketplace for the MENA region connecting travelers with hosts.  
> **Role:** Senior Full-Stack Developer (5+ years)  
> **Stack:** Node.js, NestJS, Next.js, React, TypeScript, PostgreSQL, MySQL, MongoDB, Redis, GraphQL, REST, AWS  
> **Focus Areas:** Backend-heavy full-stack, marketplace/booking, MENA payments, Arabic/RTL  

---

## 1. Behavioral & General Questions

---

### Q1: Tell me about yourself and your experience as a Full-Stack Developer.

**Answer:**

I'm a Full-Stack Developer with [X] years of experience building web applications end-to-end — from database schema design and backend APIs to responsive, performant frontend UIs. My core stack is **Node.js/NestJS** on the backend and **Next.js/React** on the frontend, with **TypeScript** throughout.

In my most recent role, I worked on [mention a relevant product — e.g., a booking platform, an e-commerce marketplace, or a SaaS platform]. I was responsible for:
- Designing the data model and database schema (PostgreSQL, with Redis for caching and sessions).
- Building REST and GraphQL APIs with NestJS, including authentication, authorization, and input validation.
- Developing the frontend in Next.js with SSR for SEO and fast initial loads.
- Integrating third-party services like payment gateways, maps, and notification providers.
- Mentoring junior developers, conducting code reviews, and improving our CI/CD pipeline.

What excites me about Onvaca is the opportunity to build a marketplace that solves real problems for travelers and hosts in the MENA region — handling multi-currency, localized payment methods, and Arabic/RTL interfaces, which are challenges I find genuinely interesting from both a product and engineering perspective.

---

### Q2: Why are you interested in working at Onvaca?

**Answer:**

Three reasons:

1. **The problem space is compelling.** Vacation rental marketplaces are technically rich — they require solving search and discovery at scale, preventing double-bookings with strong consistency, handling multi-currency payments, and building trust between strangers. These are the kinds of distributed systems problems I love working on.

2. **MENA-specific challenges.** Building for the MENA region adds layers of complexity that most global platforms don't handle well — Arabic/RTL interfaces, local currencies (SAR, AED, EGP), region-specific payment gateways (Tap, Fawry, mada), and cultural expectations around hospitality. I want to help build the platform that finally gets this right for the region.

3. **Early-stage impact.** As a scaling startup, my work at Onvaca would have outsized impact. I wouldn't just be implementing tickets — I'd be shaping the architecture, setting engineering standards, and making foundational decisions that define the platform for years.

---

### Q3: Describe a challenging technical project you led. What was your role, and how did you overcome the challenges?

**Answer:**

*(Tailor this to your real experience. Here is a strong template:)*

At [Company], I led the migration of our booking/order system from a monolithic Rails application to a microservices architecture using NestJS and PostgreSQL.

**The challenge:** Our monolith was hitting scaling limits. During peak hours (Friday evenings), response times would spike above 5 seconds because a single database handled everything — user auth, product catalog, orders, and analytics queries. We were also seeing occasional double-booking issues because the monolith used optimistic locking without proper isolation levels.

**My approach:**
1. **I identified the bounded contexts** using Domain-Driven Design (DDD) principles: User Service, Catalog Service, Order Service, and Payment Service.
2. **I implemented the Strangler Fig pattern** — we didn't rewrite everything at once. We put an API Gateway in front and gradually routed traffic to new NestJS services while the monolith handled the rest.
3. **For the double-booking problem**, I designed a hold-then-confirm flow with Redis distributed locks and PostgreSQL `SELECT ... FOR UPDATE` to guarantee serializability on the booking path.
4. **I set up Kafka** for asynchronous communication between services (e.g., when an order is placed, the Payment Service and Notification Service are notified via events).

**Results:** p99 latency dropped from 5.2s to 380ms. Double-booking incidents went to zero. The team could now deploy services independently, reducing release cycles from weekly to daily.

---

### Q4: How do you mentor junior developers and conduct effective code reviews?

**Answer:**

My approach to mentoring is **teach the "why," not just the "what."** When I review code, I don't just say "change this" — I explain the reasoning behind the suggestion. For example:

- If a junior writes a raw SQL query inside a controller, I don't just move it to a repository. I explain **separation of concerns** — why the controller should only handle HTTP request/response, and the repository handles data access. This way, they internalize the principle and apply it everywhere, not just in the one file I reviewed.

For code reviews specifically, I follow these practices:
- **Review within 24 hours** — blocking PRs kills velocity.
- **Praise what's good** — if someone writes a clean, well-tested function, I call it out. Positive reinforcement matters.
- **Focus on architecture, not style** — linters handle formatting. I focus on: Is the abstraction right? Are there edge cases? Is this testable? Will this scale?
- **Pair programming sessions** — for complex features, I'll pair with a junior for the first hour to establish the pattern, then let them complete it independently. This saves time versus 3 rounds of review.

At my previous role, I set up a **"Tech Talk Tuesday"** where each week a different team member presented a concept (e.g., "How database indexes work" or "Understanding JavaScript event loop"). This created a culture of continuous learning.

---

### Q5: How do you handle disagreements about technical decisions with teammates?

**Answer:**

I treat technical disagreements as healthy — they usually mean both people care about the quality of the solution. My framework:

1. **Make it about data, not opinions.** If someone says "we should use MongoDB" and I think PostgreSQL is better, I don't argue based on preference. I create a comparison matrix: What are the query patterns? Do we need ACID transactions? What's the team's familiarity? Data usually resolves the debate.

2. **Prototype when unsure.** For the cases where the data is inconclusive — say, choosing between REST and GraphQL for a new API — I'll suggest building a small proof-of-concept for both approaches and benchmarking them. A 2-hour spike saves weeks of regret.

3. **Disagree and commit.** If after discussion the team decides to go with an approach I didn't prefer, I fully commit to making it succeed. I never say "I told you so" if it fails. We learn and adjust together.

4. **Document the decision.** I write Architecture Decision Records (ADRs) for important choices — the context, the options considered, the decision, and the consequences. This prevents re-litigating the same debate 6 months later.

---

## 2. NestJS — Backend Architecture

---

### Q6: Explain the core building blocks of NestJS. What are modules, controllers, providers, and how do they work together?

**Answer:**

NestJS is a progressive Node.js framework that uses **decorators and dependency injection** to build well-structured, testable server-side applications. Its architecture is inspired by Angular.

**Modules** (`@Module()`) are the fundamental organizational unit. Every NestJS app has at least one module (the root `AppModule`). A module groups related functionality — controllers, providers, and imports. Think of a module as a bounded context:

```typescript
@Module({
  imports: [TypeOrmModule.forFeature([Listing])], // Import other modules
  controllers: [ListingController],                // Handle HTTP requests
  providers: [ListingService, ListingRepository],  // Business logic + data access
  exports: [ListingService],                       // Make available to other modules
})
export class ListingModule {}
```

**Controllers** (`@Controller()`) handle incoming HTTP requests and return responses. They should be thin — no business logic, just request parsing, validation, and delegating to services:

```typescript
@Controller('listings')
export class ListingController {
  constructor(private readonly listingService: ListingService) {}

  @Get(':id')
  async findOne(@Param('id', ParseUUIDPipe) id: string): Promise<Listing> {
    return this.listingService.findById(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('host')
  async create(@Body() dto: CreateListingDto, @CurrentUser() user: User): Promise<Listing> {
    return this.listingService.create(dto, user.id);
  }
}
```

**Providers** (`@Injectable()`) are the workhorses — services, repositories, factories, helpers. NestJS creates a single instance of each provider (singleton by default) and **injects** it wherever it's needed via constructor injection. This is **Inversion of Control (IoC)**:

```typescript
@Injectable()
export class ListingService {
  constructor(
    @InjectRepository(Listing) private readonly repo: Repository<Listing>,
    private readonly searchService: SearchService, // Auto-injected by NestJS
  ) {}
}
```

**Why this matters for Onvaca:** With a marketplace, you have many distinct domains — listings, bookings, payments, users, messaging, reviews. NestJS modules let you organize each domain independently, with clear boundaries. If the Booking module needs to check availability, it imports the `CalendarModule` and uses its exported `CalendarService`. This keeps the codebase maintainable as it scales.

---

### Q7: Explain Guards, Interceptors, Pipes, and Middleware in NestJS. When do you use each?

**Answer:**

NestJS has a well-defined **request lifecycle pipeline**. Understanding the execution order is critical:

```
Middleware → Guards → Interceptors (before) → Pipes → Route Handler → Interceptors (after) → Exception Filters
```

**Middleware** runs first — it's the same concept as Express middleware. Use it for cross-cutting concerns that apply to every request regardless of the route:
- Logging every incoming request (method, URL, timestamp)
- CORS configuration
- Helmet.js security headers
- Request ID generation for distributed tracing

```typescript
@Injectable()
export class LoggerMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    next();
  }
}
```

**Guards** decide **whether a request should proceed** — they return `true` (allow) or `false` (deny). Use for authentication and authorization:

```typescript
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.get<string[]>('roles', context.getHandler());
    if (!requiredRoles) return true; // No roles required, allow

    const request = context.switchToHttp().getRequest();
    const user = request.user;
    return requiredRoles.some(role => user.role === role);
  }
}

// Usage:
@Post('listings')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('host') // Custom decorator that sets metadata
async createListing(@Body() dto: CreateListingDto) { ... }
```

**Interceptors** wrap the route handler — they execute code **before and after** the handler. Use for:
- Response transformation (wrapping responses in `{ data: ..., meta: ... }`)
- Caching responses
- Logging execution time
- Timeout enforcement

```typescript
@Injectable()
export class TransformInterceptor<T> implements NestInterceptor<T, Response<T>> {
  intercept(context: ExecutionContext, next: CallHandler): Observable<Response<T>> {
    const now = Date.now();
    return next.handle().pipe(
      map(data => ({
        data,
        meta: { timestamp: new Date().toISOString(), duration: `${Date.now() - now}ms` },
      })),
    );
  }
}
```

**Pipes** transform or validate **input data** before it reaches the handler. NestJS has built-in pipes:
- `ValidationPipe` — validates DTOs using `class-validator` decorators
- `ParseIntPipe`, `ParseUUIDPipe` — transform and validate path/query params

```typescript
// DTO with validation
export class CreateBookingDto {
  @IsUUID()
  listingId: string;

  @IsDateString()
  checkIn: string;

  @IsDateString()
  checkOut: string;

  @IsInt()
  @Min(1)
  @Max(20)
  guests: number;
}

// Global validation pipe (in main.ts)
app.useGlobalPipes(new ValidationPipe({
  whitelist: true,     // Strip unknown properties
  forbidNonWhitelisted: true, // Throw if unknown properties sent
  transform: true,     // Auto-transform payloads to DTO instances
}));
```

**Exception Filters** catch unhandled exceptions and format error responses:

```typescript
@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: HttpException, host: ArgumentsHost) {
    const response = host.switchToHttp().getResponse();
    const status = exception.getStatus();
    response.status(status).json({
      statusCode: status,
      message: exception.message,
      timestamp: new Date().toISOString(),
    });
  }
}
```

**For Onvaca, the practical application:**
- **Guard** → `JwtAuthGuard` validates the guest/host is logged in. `RolesGuard` ensures only hosts can create listings, only admins can manage payouts.
- **Interceptor** → `CacheInterceptor` caches search results for 5 minutes. `TimeoutInterceptor` kills long-running requests after 10s.
- **Pipe** → `ValidationPipe` ensures booking dates are valid, guest count is within listing limits.
- **Middleware** → Attach a correlation ID to every request for end-to-end tracing across microservices.

---

### Q8: What is Dependency Injection in NestJS and why is it important?

**Answer:**

Dependency Injection (DI) is a design pattern where a class **receives** its dependencies from an external source rather than **creating** them internally. NestJS has a built-in IoC (Inversion of Control) container that manages this automatically.

**Without DI (tightly coupled — bad):**
```typescript
class BookingService {
  private paymentService: PaymentService;

  constructor() {
    this.paymentService = new PaymentService(); // ← Creates its own dependency
    // What if PaymentService needs a database connection? Now BookingService
    // needs to know about that too. This cascades and becomes unmaintainable.
  }
}
```

**With DI (loosely coupled — good):**
```typescript
@Injectable()
class BookingService {
  constructor(private readonly paymentService: PaymentService) {}
  // NestJS automatically creates PaymentService and injects it.
  // BookingService doesn't know or care HOW PaymentService is created.
}
```

**Why it matters:**

1. **Testability.** In unit tests, you can inject a mock `PaymentService` instead of the real one. You test `BookingService` in isolation without hitting actual payment gateways:

```typescript
const module = await Test.createTestingModule({
  providers: [
    BookingService,
    { provide: PaymentService, useValue: mockPaymentService }, // ← Mock injected
  ],
}).compile();
```

2. **Flexibility.** You can swap implementations without changing consumer code. For example, in development you use a `MockEmailService`, in production a `SendGridEmailService`:

```typescript
@Module({
  providers: [
    {
      provide: 'EmailService',
      useClass: process.env.NODE_ENV === 'production' 
        ? SendGridEmailService 
        : MockEmailService,
    },
  ],
})
```

3. **Singleton management.** NestJS providers are singletons by default — one instance shared across the entire module. This means your database connection pool, Redis client, and Kafka producer are created once and reused, preventing resource leaks.

---

## 3. Next.js & React — Frontend

---

### Q9: Explain the difference between SSR, SSG, and CSR in Next.js. When would you use each for a vacation rental marketplace?

**Answer:**

Next.js gives you **three rendering strategies**, and a well-built marketplace uses all three for different pages:

**Server-Side Rendering (SSR)** — `getServerSideProps`  
The page is generated on the server **on every request**. The HTML is fully rendered before being sent to the browser.

*When to use at Onvaca:* **Search results page.** When a guest searches "Dubai, Dec 1–7, 4 guests," the results depend on real-time availability and pricing. This data changes constantly, so static generation doesn't work. SSR ensures:
- The guest gets fresh, up-to-date results.
- The fully-rendered HTML is great for SEO (Google can crawl search results).
- The first paint is fast (no loading spinner).

```typescript
// pages/search.tsx
export async function getServerSideProps(context) {
  const { lat, lng, checkIn, checkOut, guests } = context.query;
  const listings = await searchService.search({ lat, lng, checkIn, checkOut, guests });
  
  return {
    props: { listings }, // Passed to the page component as props
  };
}
```

**Static Site Generation (SSG)** — `getStaticProps` + `getStaticPaths`  
Pages are generated **at build time** and served as static HTML. Optionally use **Incremental Static Regeneration (ISR)** to re-generate pages in the background after a specified interval.

*When to use at Onvaca:* **Individual listing pages.** A listing page for "Luxury Villa in Dubai Marina" doesn't change every second. We can statically generate it and revalidate every 60 seconds with ISR:

```typescript
// pages/listings/[id].tsx
export async function getStaticPaths() {
  const popularListings = await listingService.getPopular(1000);
  return {
    paths: popularListings.map(l => ({ params: { id: l.id } })),
    fallback: 'blocking', // Generate other pages on-demand at first request
  };
}

export async function getStaticProps({ params }) {
  const listing = await listingService.findById(params.id);
  return {
    props: { listing },
    revalidate: 60, // ISR: regenerate in background every 60 seconds
  };
}
```

This gives you **CDN-speed page loads** (the pre-built HTML is cached at the edge) with data that's at most 60 seconds old — perfectly acceptable for a listing detail page.

**Client-Side Rendering (CSR)** — `useEffect` + client-side data fetching  
The page loads a shell first, then fetches data from the API in the browser.

*When to use at Onvaca:* **User dashboard, booking management, messaging.** These pages are behind authentication, not indexed by search engines, and need real-time interactivity:

```typescript
// pages/dashboard/bookings.tsx
export default function MyBookings() {
  const { data, isLoading } = useSWR('/api/v1/users/me/bookings', fetcher);
  
  if (isLoading) return <BookingSkeleton />;
  return <BookingList bookings={data} />;
}
```

**Summary for Onvaca:**

| Page | Strategy | Why |
| :--- | :--- | :--- |
| Landing page | SSG | Rarely changes, must be fast |
| Listing detail | SSG + ISR (60s) | SEO critical, data changes infrequently |
| Search results | SSR | Real-time availability, SEO important |
| Booking flow | CSR | Interactive, behind auth |
| User dashboard | CSR | Behind auth, real-time data |
| Blog / Help center | SSG | Static content |

---

### Q10: How would you build a responsive, reusable UI component system for a bilingual (Arabic/English) vacation rental platform?

**Answer:**

Building for Arabic/English requires thinking about **three layers**: component architecture, layout direction (RTL/LTR), and internationalization (i18n).

**1. Component Architecture:**

I use a **compound component pattern** with TypeScript for type-safe, reusable components:

```typescript
// components/ListingCard/index.tsx
interface ListingCardProps {
  listing: Listing;
  locale: 'ar' | 'en';
  onWishlist?: (id: string) => void;
}

export function ListingCard({ listing, locale, onWishlist }: ListingCardProps) {
  const t = useTranslations('listing');
  
  return (
    <article className="listing-card">
      <ImageCarousel images={listing.photos} alt={listing.title} />
      <div className="listing-card__body">
        <h3>{locale === 'ar' ? listing.titleAr : listing.title}</h3>
        <p className="listing-card__location">{listing.city}, {listing.country}</p>
        <div className="listing-card__meta">
          <span>{listing.bedrooms} {t('bedrooms')}</span>
          <span>{listing.maxGuests} {t('guests')}</span>
        </div>
        <div className="listing-card__price">
          <PriceDisplay amount={listing.basePrice} currency={listing.currency} locale={locale} />
          <span className="listing-card__per-night">/ {t('night')}</span>
        </div>
        <StarRating rating={listing.avgRating} count={listing.reviewCount} />
      </div>
    </article>
  );
}
```

**2. RTL/LTR Layout with CSS Logical Properties:**

The key insight is: **never use `left` or `right` in CSS.** Use CSS logical properties instead. This makes one stylesheet work for both LTR and RTL:

```css
/* ❌ BAD — breaks in Arabic */
.listing-card__price {
  margin-left: 12px;
  padding-right: 8px;
  text-align: left;
  border-left: 2px solid #ddd;
}

/* ✅ GOOD — works in both LTR and RTL */
.listing-card__price {
  margin-inline-start: 12px;   /* left in LTR, right in RTL */
  padding-inline-end: 8px;     /* right in LTR, left in RTL */
  text-align: start;           /* left in LTR, right in RTL */
  border-inline-start: 2px solid #ddd;
}
```

Set the `dir` attribute on the root HTML element:
```typescript
// pages/_document.tsx
<Html lang={locale} dir={locale === 'ar' ? 'rtl' : 'ltr'}>
```

**3. Internationalization with Next.js:**

Use Next.js built-in i18n routing with `next-intl`:

```typescript
// next.config.js
module.exports = {
  i18n: {
    locales: ['en', 'ar'],
    defaultLocale: 'en',
  },
};
```

This automatically creates `/en/listings/...` and `/ar/listings/...` routes. The `locale` is available in every page via `useRouter().locale`.

**4. Number and Currency Formatting:**

```typescript
// utils/formatPrice.ts
export function formatPrice(amount: number, currency: string, locale: string): string {
  return new Intl.NumberFormat(locale === 'ar' ? 'ar-SA' : 'en-US', {
    style: 'currency',
    currency: currency,
  }).format(amount);
}

// Output examples:
// formatPrice(1500, 'SAR', 'ar') → "١٬٥٠٠٫٠٠ ر.س"
// formatPrice(1500, 'SAR', 'en') → "SAR 1,500.00"
```

---

### Q11: How do you optimize frontend performance in a Next.js application?

**Answer:**

For a listing-heavy marketplace like Onvaca, performance is directly tied to conversion. A 1-second delay in page load can reduce conversions by 7%. Here are the concrete techniques I'd use:

**1. Image Optimization (biggest win):**

Listing photos are the #1 performance bottleneck. Next.js `<Image>` component handles this automatically:

```typescript
import Image from 'next/image';

<Image
  src={listing.photos[0].url}
  alt={listing.title}
  width={600}
  height={400}
  placeholder="blur"       // Show blurred preview while loading
  blurDataURL={listing.photos[0].blurHash}  // Pre-computed blur hash
  loading="lazy"            // Only load when near viewport
  sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
/>
```

This automatically serves WebP format, responsive sizes, and lazy loads images below the fold.

**2. Code Splitting (automatic in Next.js):**

Each page is automatically code-split. For heavy components (e.g., a map with Mapbox GL), use dynamic imports:

```typescript
const MapView = dynamic(() => import('../components/MapView'), {
  loading: () => <MapSkeleton />,
  ssr: false, // Map doesn't need SSR
});
```

**3. Data Fetching Optimization:**

Use **SWR** or **React Query** for client-side data fetching with built-in caching, revalidation, and deduplication:

```typescript
const { data, isLoading } = useSWR(
  `/api/v1/listings/${id}/availability?month=2026-12`,
  fetcher,
  {
    revalidateOnFocus: false,
    dedupingInterval: 60000, // Don't refetch for 60 seconds
  }
);
```

**4. Bundle Size Reduction:**
- Use `@next/bundle-analyzer` to identify large dependencies.
- Replace `moment.js` (330KB) with `date-fns` (tree-shakeable, only import what you use).
- Replace `lodash` with native JS methods or `lodash-es` for tree-shaking.

**5. Core Web Vitals Targets:**

| Metric | Target | How |
| :--- | :--- | :--- |
| **LCP** (Largest Contentful Paint) | < 2.5s | Preload hero image, SSR above-the-fold content |
| **FID** (First Input Delay) | < 100ms | Minimize main-thread blocking JS, code-split |
| **CLS** (Cumulative Layout Shift) | < 0.1 | Set explicit `width`/`height` on images, use font `swap` |

---

## 4. TypeScript

---

### Q12: Why TypeScript over plain JavaScript? Give practical examples of how TypeScript prevents bugs.

**Answer:**

TypeScript adds **static type checking** at compile time, catching errors before they reach production. For a marketplace handling money, this isn't optional — a type error in a payment calculation could cost real money.

**Example 1 — Preventing invalid booking states:**

```typescript
// Without TypeScript: nothing stops you from setting status to "banana"
booking.status = 'banana'; // No error. Deployed. Bug in production.

// With TypeScript: the compiler catches this immediately
type BookingStatus = 'pending' | 'confirmed' | 'cancelled' | 'completed';

interface Booking {
  id: string;
  status: BookingStatus;
  totalPrice: number;
  currency: 'SAR' | 'AED' | 'EGP' | 'USD';
}

booking.status = 'banana'; // ❌ Compile error: '"banana"' is not assignable to type 'BookingStatus'
```

**Example 2 — Preventing null/undefined crashes:**

```typescript
// Without TypeScript: this crashes at runtime if listing.host is null
const hostName = listing.host.name; // TypeError: Cannot read property 'name' of null

// With TypeScript (strict null checks):
interface Listing {
  host: User | null; // Explicitly nullable
}

const hostName = listing.host.name; // ❌ Compile error: 'listing.host' is possibly 'null'
const hostName = listing.host?.name ?? 'Unknown Host'; // ✅ Safe
```

**Example 3 — Type-safe API responses with generics:**

```typescript
// A generic paginated response that works for any entity
interface PaginatedResponse<T> {
  data: T[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}

// Usage:
async function searchListings(query: SearchQuery): Promise<PaginatedResponse<Listing>> { ... }
async function getBookings(userId: string): Promise<PaginatedResponse<Booking>> { ... }

// The compiler knows:
const result = await searchListings(query);
result.data[0].title;     // ✅ TypeScript knows this is a Listing, autocomplete works
result.data[0].checkIn;   // ❌ Compile error: 'checkIn' doesn't exist on Listing
```

**Example 4 — Discriminated unions for payment gateway responses:**

```typescript
type PaymentResult =
  | { status: 'success'; transactionId: string; amount: number }
  | { status: 'failed'; errorCode: string; errorMessage: string }
  | { status: 'requires_action'; redirectUrl: string }; // 3D Secure

function handlePayment(result: PaymentResult) {
  switch (result.status) {
    case 'success':
      console.log(result.transactionId); // ✅ TypeScript knows transactionId exists here
      break;
    case 'failed':
      console.log(result.errorMessage);  // ✅ TypeScript knows errorMessage exists here
      break;
    case 'requires_action':
      redirect(result.redirectUrl);      // ✅ TypeScript knows redirectUrl exists here
      break;
  }
}
```

---

## 5. Databases — PostgreSQL, MySQL, MongoDB

---

### Q13: Compare PostgreSQL and MySQL. When would you choose each?

**Answer:**

Both are mature relational databases, but they have different strengths:

| Feature | PostgreSQL | MySQL |
| :--- | :--- | :--- |
| **Standards compliance** | Very strict SQL compliance | Some deviations from standard SQL |
| **Data types** | Rich: JSONB, arrays, hstore, UUID, PostGIS | Fewer native types (JSON added later) |
| **Geospatial** | PostGIS extension — industry-leading | Basic spatial support |
| **Full-text search** | Built-in tsvector/tsquery | Built-in but simpler |
| **ACID compliance** | Full ACID with MVCC | Full ACID with InnoDB engine |
| **Concurrency** | MVCC — readers never block writers | Row-level locking with InnoDB |
| **Replication** | Streaming replication, logical replication | Built-in replication, Group Replication |
| **Performance** | Better for complex queries, analytics | Slightly faster for simple reads at scale |
| **JSON support** | `JSONB` — binary, indexable, queryable | `JSON` — less performant for queries |

**For Onvaca, I would choose PostgreSQL because:**
1. **PostGIS** — We need geospatial queries for "find listings within 20km of this location." PostGIS is the gold standard.
2. **JSONB** — Listing amenities, house rules, and cancellation policies are semi-structured data. JSONB lets us store these flexibly while still being queryable and indexable.
3. **UUID support** — Native UUID type for primary keys, which is important for distributed systems where auto-increment IDs cause conflicts.
4. **Advanced indexing** — Partial indexes, expression indexes, and GiST/GIN indexes for geospatial and full-text search.

**When I'd choose MySQL:**
- If the team is already deeply experienced with MySQL and the project doesn't need geospatial.
- For very high-throughput, simple CRUD operations (MySQL's InnoDB is slightly faster for simple reads).
- When using AWS Aurora MySQL, which provides exceptional managed scaling.

---

### Q14: Explain database indexing. How do you know which columns to index, and what are the trade-offs?

**Answer:**

An index is a separate data structure (typically a **B-tree** in PostgreSQL/MySQL) that maintains a sorted copy of selected columns, enabling the database to find rows without scanning the entire table.

**Without an index:** Finding a booking by guest ID requires a **full table scan** — reading every row. With 10 million bookings, this takes seconds.  
**With an index on `guest_id`:** The database does a B-tree lookup in O(log n) — milliseconds.

**How I decide which columns to index:**

1. **Columns in WHERE clauses** — If you frequently query `WHERE status = 'confirmed' AND host_id = ?`, create a composite index:
```sql
CREATE INDEX idx_bookings_host_status ON bookings(host_id, status);
```

2. **Columns in JOIN conditions** — Foreign keys like `listing_id` in the `bookings` table should always be indexed.

3. **Columns in ORDER BY** — If you sort listings by `created_at DESC`, an index on `created_at` avoids a sort operation.

4. **Use `EXPLAIN ANALYZE`** — This is the most important tool. It shows the query plan and actual execution time:
```sql
EXPLAIN ANALYZE SELECT * FROM bookings WHERE listing_id = 'uuid-123' AND check_in >= '2026-12-01';
```
If you see `Seq Scan` (sequential scan), you need an index. If you see `Index Scan`, you're good.

**Composite indexes — order matters:**
```sql
-- This index is useful for queries filtering by listing_id, or listing_id + date
-- But NOT for queries filtering by date alone
CREATE INDEX idx_calendar ON calendar(listing_id, date);
```
The **leftmost prefix rule**: a composite index `(A, B, C)` can be used for queries on `(A)`, `(A, B)`, or `(A, B, C)`, but NOT for `(B)` or `(C)` alone.

**Trade-offs:**
- **Reads are faster** — index lookups are O(log n) instead of O(n).
- **Writes are slower** — every INSERT, UPDATE, DELETE must also update the index.
- **Storage cost** — indexes consume disk space (typically 10–30% of the table size).
- **Over-indexing** — too many indexes slow down writes and waste memory. Index only what your queries actually use.

**Partial indexes (PostgreSQL-specific, great for Onvaca):**
```sql
-- Only index active listings, not archived ones
CREATE INDEX idx_active_listings ON listings(city, base_price) WHERE status = 'active';
```
This makes the index smaller and faster because it only includes rows matching the condition.

---

### Q15: When would you use MongoDB alongside PostgreSQL? Give a concrete example.

**Answer:**

I follow a **polyglot persistence** approach — use the right database for the right access pattern.

**Use PostgreSQL for:**
- Bookings, payments, user accounts — anything requiring **ACID transactions** and **relational integrity** (foreign keys).
- You cannot allow a booking to exist without a valid listing and user. Referential integrity enforces this.

**Use MongoDB for:**
- **Activity logs and audit trails** — high write volume, append-only, rarely queried in complex ways. Schema flexibility means you can log different event shapes without migrations:

```json
// User login event
{ "type": "login", "userId": "uuid", "ip": "1.2.3.4", "timestamp": "2026-09-17T..." }

// Booking created event  
{ "type": "booking_created", "bookingId": "uuid", "listingId": "uuid", "amount": 1500, "timestamp": "..." }

// Payment failed event
{ "type": "payment_failed", "bookingId": "uuid", "gateway": "tap", "errorCode": "CARD_DECLINED", "timestamp": "..." }
```

Each event has a different shape. In PostgreSQL, you'd need either a generic `metadata JSONB` column (losing type safety) or separate tables for each event type (migration overhead). MongoDB handles this naturally.

- **User-generated content drafts** — if hosts are composing a listing with amenities, photos, and descriptions, storing the in-progress draft as a flexible document makes sense. Once published, it's written to PostgreSQL as the source of truth.

- **Caching/denormalized views** — though Redis is better for pure caching, MongoDB can serve as a materialized view store for complex aggregations (e.g., "trending listings by city" computed from booking data).

**The key rule:** PostgreSQL is the **source of truth** for critical business data. MongoDB is for **supporting data** where schema flexibility and write throughput matter more than transactional guarantees.

---

### Q16: What is Redis, and how would you use it in a vacation rental marketplace?

**Answer:**

Redis is an **in-memory data structure store** — it keeps everything in RAM, making it extremely fast (sub-millisecond latency for most operations). It supports strings, hashes, lists, sets, sorted sets, and streams.

**For Onvaca, I'd use Redis for 6 specific things:**

**1. Session Management:**
```
SET session:jwt_token_hash user_data EX 86400  // 24-hour session TTL
```
Stateless JWT tokens are validated at the API Gateway, but user profile data (role, preferred language, currency) is cached in Redis to avoid a database hit on every request.

**2. Distributed Locks for Booking (Critical):**
```
SET hold:listing_uuid:2026-12-01:2026-12-07 guest_uuid EX 600 NX
// NX = only set if key doesn't exist (atomic lock)
// EX 600 = auto-expire in 10 minutes (no zombie locks)
```
This prevents two guests from simultaneously booking the same dates. The `NX` flag makes this operation **atomic** — only one caller wins.

**3. Search Result Caching:**
```
SET search:hash(lat,lng,dates,guests,filters) serialized_results EX 300
// Cache popular search queries for 5 minutes
```
The same "Dubai, Dec 1-7, 4 guests" search might be executed thousands of times per hour. Caching it in Redis avoids hitting Elasticsearch every time.

**4. Rate Limiting (Sliding Window):**
Using a sorted set to track request timestamps per user:
```
ZADD rate_limit:user_uuid timestamp timestamp
ZREMRANGEBYSCORE rate_limit:user_uuid 0 (now - 60s)
ZCARD rate_limit:user_uuid  // Count requests in last 60 seconds
```
If count > 100, reject the request with HTTP 429.

**5. Real-Time Messaging (Pub/Sub):**
```
PUBLISH chat:thread_uuid '{"senderId":"uuid","content":"Is parking available?"}'
```
WebSocket servers subscribe to the relevant channels and push messages to connected clients instantly.

**6. Queue for Background Jobs (Bull/BullMQ):**
Redis-backed queues for async tasks:
- Send booking confirmation emails
- Generate invoice PDFs
- Process listing image thumbnails
- Calculate and update listing quality scores

---

## 6. REST & GraphQL APIs

---

### Q17: What is the difference between REST and GraphQL? When would you use each?

**Answer:**

**REST** (Representational State Transfer) uses **resource-based URLs** with HTTP methods. Each endpoint returns a fixed data shape:

```
GET /api/v1/listings/uuid-123        → Full listing object
GET /api/v1/listings/uuid-123/reviews → Reviews for this listing
GET /api/v1/users/uuid-456           → Host profile
```

**GraphQL** uses a **single endpoint** where the client specifies exactly what data it needs:

```graphql
query {
  listing(id: "uuid-123") {
    title
    basePrice
    photos { url }
    host {
      name
      responseRate
    }
    reviews(limit: 5) {
      rating
      comment
    }
  }
}
```

**Key differences:**

| Aspect | REST | GraphQL |
| :--- | :--- | :--- |
| **Over-fetching** | Returns fixed shape — may include unused fields | Client requests exactly what it needs |
| **Under-fetching** | Listing page needs 3 requests (listing + reviews + host) | Single query gets everything |
| **Caching** | Easy — HTTP caching works natively with URLs | Harder — single endpoint, need client-side caching |
| **Versioning** | URL versioning (`/v1/`, `/v2/`) | Schema evolution with `@deprecated` fields |
| **Learning curve** | Low — most developers know it | Higher — query language, schema design, resolvers |
| **File uploads** | Straightforward with multipart | Requires separate handling (multipart spec) |
| **Real-time** | WebSockets or SSE (separate setup) | Built-in Subscriptions |

**For Onvaca, I'd use both:**

- **REST** for simple CRUD operations: creating listings, updating profiles, processing payments. These are well-defined operations with clear request/response shapes. REST is simpler, easier to cache, and every developer knows it.

- **GraphQL** for the **listing detail page** and **search results** — where the frontend needs to fetch deeply nested, related data (listing + host + reviews + availability + nearby listings) in a single request. Without GraphQL, this requires 3–5 REST calls, which hurts mobile performance.

In NestJS, you can run both simultaneously:
```typescript
// app.module.ts
@Module({
  imports: [
    GraphQLModule.forRoot<ApolloDriverConfig>({
      driver: ApolloDriver,
      autoSchemaFile: true,  // Code-first schema generation
    }),
    ListingModule,  // Exports both REST controllers and GraphQL resolvers
  ],
})
```

---

### Q18: How do you design a REST API that is secure, performant, and easy to use?

**Answer:**

I follow these principles:

**1. Consistent URL structure:**
```
GET    /api/v1/listings          → List (with pagination, filtering)
GET    /api/v1/listings/:id      → Get one
POST   /api/v1/listings          → Create
PUT    /api/v1/listings/:id      → Full update
PATCH  /api/v1/listings/:id      → Partial update
DELETE /api/v1/listings/:id      → Delete
```
Use **nouns** (listings), not verbs (getListings). Use **plural** consistently.

**2. Pagination — always:**
```
GET /api/v1/listings?page=2&limit=20

Response:
{
  "data": [...],
  "meta": {
    "total": 1250,
    "page": 2,
    "limit": 20,
    "totalPages": 63
  }
}
```
For high-throughput APIs, prefer **cursor-based pagination** over offset-based (offset becomes slow for large offsets):
```
GET /api/v1/listings?cursor=eyJpZCI6MTAwfQ&limit=20
```

**3. Proper HTTP status codes:**

| Code | Meaning | When |
| :--- | :--- | :--- |
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Validation error (invalid dates, missing fields) |
| 401 | Unauthorized | Missing or invalid JWT |
| 403 | Forbidden | Valid JWT but wrong role (guest trying to access host endpoint) |
| 404 | Not Found | Listing doesn't exist |
| 409 | Conflict | Double-booking attempt |
| 422 | Unprocessable Entity | Semantically invalid (check-out before check-in) |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Unexpected server error |

**4. Consistent error responses:**
```json
{
  "statusCode": 422,
  "error": "Unprocessable Entity",
  "message": "Check-out date must be after check-in date",
  "details": {
    "field": "checkOut",
    "value": "2026-12-01",
    "constraint": "must be after checkIn (2026-12-07)"
  }
}
```

**5. Security:**
- **Authentication:** JWT in `Authorization: Bearer <token>` header (not in query params — those get logged).
- **Input validation:** Validate every input with NestJS `ValidationPipe`. Whitelist allowed fields, reject unknown properties.
- **Rate limiting:** 100 requests/minute per user. Return `Retry-After` header with 429 responses.
- **Idempotency:** For POST/PUT operations that create or modify resources, accept an `Idempotency-Key` header. Store in Redis for 24 hours. If the same key is sent again, return the original response.

---

## 7. Authentication & Authorization

---

### Q19: Explain JWT authentication flow. How do you implement it securely in NestJS?

**Answer:**

JWT (JSON Web Token) is a **stateless** authentication mechanism. The server issues a signed token containing the user's identity, and the client sends it with every request. The server validates the signature without hitting a database.

**The flow:**

```
1. Guest sends:   POST /api/v1/auth/login { email, password }
2. Server:        Validates credentials against database (bcrypt hash comparison)
3. Server:        Creates JWT: { userId, role, iat, exp } signed with secret key
4. Server sends:  { accessToken: "eyJ...", refreshToken: "..." }
5. Client:        Stores accessToken in memory, refreshToken in HTTP-only cookie
6. Client:        Sends accessToken in headers: Authorization: Bearer eyJ...
7. Server:        Validates signature + expiry on every request (no DB hit)
```

**Secure implementation in NestJS:**

```typescript
// auth.module.ts
@Module({
  imports: [
    JwtModule.registerAsync({
      useFactory: (config: ConfigService) => ({
        secret: config.get('JWT_SECRET'),
        signOptions: { expiresIn: '15m' }, // Short-lived access token
      }),
      inject: [ConfigService],
    }),
    PassportModule,
  ],
  providers: [AuthService, JwtStrategy, LocalStrategy],
  controllers: [AuthController],
})
export class AuthModule {}

// jwt.strategy.ts — validates the token on every request
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(config: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: config.get('JWT_SECRET'),
      ignoreExpiration: false,
    });
  }

  async validate(payload: JwtPayload): Promise<UserContext> {
    return { userId: payload.sub, role: payload.role };
  }
}

// jwt-auth.guard.ts
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {}

// Usage on any controller:
@Get('me')
@UseGuards(JwtAuthGuard)
async getProfile(@CurrentUser() user: UserContext) {
  return this.userService.findById(user.userId);
}
```

**Security best practices:**

1. **Short-lived access tokens (15 minutes).** If a token is stolen, the damage window is small.
2. **Refresh tokens in HTTP-only cookies.** JavaScript cannot access HTTP-only cookies, preventing XSS attacks from stealing the refresh token.
3. **Refresh token rotation.** Every time a refresh token is used, issue a new one and invalidate the old one. If an attacker replays an old refresh token, invalidate the entire family (detect replay attacks).
4. **Never store JWTs in `localStorage`.** XSS attacks can read `localStorage`. Store access tokens in memory (JavaScript variable) and refresh tokens in HTTP-only, Secure, SameSite=Strict cookies.
5. **Bcrypt for password hashing** with a cost factor of 12. Never MD5 or SHA-256 (too fast, vulnerable to brute force).

---

### Q20: What is OAuth 2.0, and how does it differ from JWT?

**Answer:**

This is a common misconception — **JWT and OAuth 2.0 are not alternatives. They work at different levels.**

- **OAuth 2.0** is an **authorization framework** — it defines the flow for granting access (e.g., "Login with Google").
- **JWT** is a **token format** — it's the container that carries the user's identity claims.

In practice, OAuth 2.0 often uses JWTs as the token format. Here's how "Login with Google" works for Onvaca:

```
1. Guest clicks "Login with Google" on Onvaca
2. Onvaca redirects to Google's OAuth consent screen
3. Guest authorizes Onvaca to access their name + email
4. Google redirects back to Onvaca with an authorization code
5. Onvaca's backend exchanges the code for an access token (server-to-server)
6. Onvaca reads the user's Google profile (name, email, avatar)
7. Onvaca creates/updates the user in our database
8. Onvaca issues OUR OWN JWT to the guest (not Google's token)
9. Guest is logged in with Onvaca's JWT
```

**The key point:** We never trust Google's token for our own API. We use Google only for **identity verification** (who is this person?), then issue our own JWT with our own claims (`{ userId, role: 'guest' }`).

**NestJS implementation with Passport:**

```typescript
@Injectable()
export class GoogleStrategy extends PassportStrategy(Strategy, 'google') {
  constructor(config: ConfigService) {
    super({
      clientID: config.get('GOOGLE_CLIENT_ID'),
      clientSecret: config.get('GOOGLE_CLIENT_SECRET'),
      callbackURL: config.get('GOOGLE_CALLBACK_URL'),
      scope: ['email', 'profile'],
    });
  }

  async validate(accessToken: string, refreshToken: string, profile: Profile) {
    // Find or create user in our database
    return {
      email: profile.emails[0].value,
      name: profile.displayName,
      avatar: profile.photos[0].value,
      provider: 'google',
      providerId: profile.id,
    };
  }
}
```

---

## 8. Third-Party Integrations

---

### Q21: How do you integrate a payment gateway (like Stripe or Tap) securely?

**Answer:**

Payment integrations require extra care because you're handling real money. The core principles are: **never touch raw card data**, **ensure idempotency**, and **handle webhooks reliably**.

**Architecture:**

```
Guest → Next.js (Stripe/Tap Elements) → Tokenized card → Onvaca Backend → Payment Gateway
```

The frontend uses the gateway's SDK (e.g., Stripe Elements or Tap.js) to collect card details. The raw card number **never touches our servers** — it's tokenized on the client side. We only receive a token.

**NestJS implementation:**

```typescript
@Injectable()
export class StripePaymentGateway implements PaymentGateway {
  private stripe: Stripe;

  constructor(config: ConfigService) {
    this.stripe = new Stripe(config.get('STRIPE_SECRET_KEY'), { apiVersion: '2024-06-20' });
  }

  async charge(dto: ChargeDto): Promise<PaymentResult> {
    try {
      const paymentIntent = await this.stripe.paymentIntents.create({
        amount: Math.round(dto.amount * 100), // Stripe uses cents
        currency: dto.currency.toLowerCase(),
        payment_method: dto.paymentMethodToken,
        confirm: true,
        metadata: {
          bookingId: dto.bookingId,
          guestId: dto.guestId,
        },
      }, {
        idempotencyKey: dto.idempotencyKey, // ← CRITICAL: prevents duplicate charges
      });

      if (paymentIntent.status === 'requires_action') {
        return { status: 'requires_action', redirectUrl: paymentIntent.next_action.redirect_to_url.url };
      }

      return { status: 'success', transactionId: paymentIntent.id, amount: dto.amount };
    } catch (error) {
      return { status: 'failed', errorCode: error.code, errorMessage: error.message };
    }
  }
}
```

**Webhook handling (critical for reliability):**

Payment results are **not** always synchronous. 3D Secure authentication, bank delays, and network issues mean you **must** handle webhooks:

```typescript
@Controller('webhooks')
export class WebhookController {
  @Post('stripe')
  async handleStripeWebhook(@Req() req: RawBodyRequest<Request>) {
    const sig = req.headers['stripe-signature'];
    const event = this.stripe.webhooks.constructEvent(
      req.rawBody,           // Use raw body, not parsed JSON
      sig,
      this.config.get('STRIPE_WEBHOOK_SECRET'),
    );

    switch (event.type) {
      case 'payment_intent.succeeded':
        await this.bookingService.confirmBooking(event.data.object.metadata.bookingId);
        break;
      case 'payment_intent.payment_failed':
        await this.bookingService.handlePaymentFailure(event.data.object.metadata.bookingId);
        break;
    }

    return { received: true }; // Always respond 200 to acknowledge
  }
}
```

**Key security rules:**
1. **Verify webhook signatures** — never trust raw POST data without validating the `stripe-signature` header.
2. **Use idempotency keys** — Stripe/Tap may retry webhooks. Process each event only once (check event ID in database).
3. **Never store card numbers** — use PCI-compliant tokenization. We only store `last4`, `brand`, and the token.

---

### Q22: How do you integrate maps and geocoding for a listing-based platform?

**Answer:**

For a vacation rental marketplace, maps serve two purposes: **guests searching on a map** and **hosts pinpointing their listing location**.

**Frontend (Mapbox GL or Google Maps):**

```typescript
// components/SearchMap.tsx
import Map, { Marker, Popup } from 'react-map-gl';

export function SearchMap({ listings, onBoundsChange }: SearchMapProps) {
  const handleMoveEnd = (evt) => {
    const bounds = evt.target.getBounds();
    // Fetch listings within the new map bounds
    onBoundsChange({
      swLat: bounds.getSouth(),
      swLng: bounds.getWest(),
      neLat: bounds.getNorth(),
      neLng: bounds.getEast(),
    });
  };

  return (
    <Map
      initialViewState={{ latitude: 25.2, longitude: 55.3, zoom: 10 }}
      onMoveEnd={handleMoveEnd}
      mapStyle="mapbox://styles/mapbox/streets-v12"
    >
      {listings.map(listing => (
        <Marker key={listing.id} latitude={listing.lat} longitude={listing.lng}>
          <PricePin price={listing.basePrice} currency={listing.currency} />
        </Marker>
      ))}
    </Map>
  );
}
```

**Backend (Geocoding + Geo-queries):**

When a host creates a listing with an address, we geocode it to lat/lng using a service like Google Geocoding API or Mapbox Geocoding:

```typescript
@Injectable()
export class GeocodingService {
  async geocode(address: string): Promise<{ lat: number; lng: number }> {
    const response = await this.httpService.get(
      `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(address)}.json`,
      { params: { access_token: this.apiKey, limit: 1 } }
    ).toPromise();

    const [lng, lat] = response.data.features[0].center;
    return { lat, lng };
  }
}
```

For geo-queries in PostgreSQL with PostGIS:
```sql
-- Find listings within 20km of a point
SELECT id, title, base_price,
       ST_Distance(location, ST_SetSRID(ST_MakePoint(55.14, 25.08), 4326)) AS distance_meters
FROM listings
WHERE ST_DWithin(
  location,
  ST_SetSRID(ST_MakePoint(55.14, 25.08), 4326),
  20000  -- 20km in meters
)
AND status = 'active'
ORDER BY distance_meters
LIMIT 50;
```

---

## 9. DevOps, CI/CD & AWS

---

### Q23: Describe your experience with Docker and how you'd containerize a NestJS application.

**Answer:**

Docker packages an application and all its dependencies into a portable container that runs identically in development, staging, and production.

**Multi-stage Dockerfile for NestJS (production-optimized):**

```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci                          # Install all deps (including devDependencies)
COPY . .
RUN npm run build                   # Compile TypeScript → JavaScript

# Stage 2: Production
FROM node:20-alpine AS production
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev               # Install only production dependencies
COPY --from=builder /app/dist ./dist # Copy compiled code from builder

# Security: don't run as root
USER node

EXPOSE 3000
CMD ["node", "dist/main.js"]
```

**Why multi-stage?**
- The builder stage has TypeScript compiler, devDependencies (~500MB).
- The production image has only runtime code (~150MB) — 70% smaller, faster deployments, smaller attack surface.

**Docker Compose for local development:**

```yaml
version: '3.8'
services:
  app:
    build: .
    ports: ['3000:3000']
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/onvaca
      - REDIS_URL=redis://redis:6379
    depends_on: [db, redis, elasticsearch]

  db:
    image: postgis/postgis:16-3.4
    environment:
      POSTGRES_DB: onvaca
      POSTGRES_PASSWORD: password
    ports: ['5432:5432']
    volumes: ['pgdata:/var/lib/postgresql/data']

  redis:
    image: redis:7-alpine
    ports: ['6379:6379']

  elasticsearch:
    image: elasticsearch:8.12.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    ports: ['9200:9200']

volumes:
  pgdata:
```

---

### Q24: What AWS services would you use for Onvaca, and why?

**Answer:**

| Service | Purpose | Why |
| :--- | :--- | :--- |
| **ECS (Fargate)** | Run NestJS containers | Serverless containers — no EC2 management, auto-scaling |
| **RDS (PostgreSQL)** | Primary database | Managed PostgreSQL with automated backups, read replicas, Multi-AZ |
| **ElastiCache (Redis)** | Caching + sessions + locks | Managed Redis with clustering, failover, encryption |
| **S3** | Listing photos, user documents | Durable object storage (11 nines of durability) |
| **CloudFront** | CDN for images + Next.js static assets | Edge locations in Dubai, Riyadh, Cairo for low-latency MENA delivery |
| **SQS** | Async job processing | Email sending, image processing, report generation |
| **SES** | Transactional emails | Booking confirmations, password resets |
| **CloudWatch** | Logs + metrics + alerts | Centralized logging, custom metrics, alarm notifications |
| **ALB** | Load balancing | Distribute traffic across ECS tasks, health checks |
| **ECR** | Container registry | Store Docker images, integrated with ECS |
| **Secrets Manager** | API keys, DB passwords | Rotate secrets automatically, access from ECS via IAM |
| **Route 53** | DNS | Domain management with health checks and failover routing |

**Architecture on AWS:**

```
Route 53 → CloudFront → ALB → ECS (Fargate)
                                   ├── NestJS Service (x8 tasks)
                                   ├── WebSocket Service (x4 tasks)
                                   └── Worker Service (x2 tasks)
                                        ├── RDS PostgreSQL (Multi-AZ)
                                        ├── ElastiCache Redis (Cluster)
                                        ├── OpenSearch (Elasticsearch)
                                        └── S3 (listing photos)
```

---

### Q25: Describe a CI/CD pipeline for deploying NestJS to AWS ECS.

**Answer:**

```yaml
# .github/workflows/deploy.yml
name: Deploy to ECS

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci
      - run: npm run lint              # ESLint + Prettier check
      - run: npm run test              # Unit tests
      - run: npm run test:e2e          # Integration tests (against test DB)

  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      # Build Docker image
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: me-south-1  # Bahrain region (closest to MENA)
      
      - uses: aws-actions/amazon-ecr-login@v2
      
      - run: |
          docker build -t onvaca-api .
          docker tag onvaca-api:latest $ECR_REGISTRY/onvaca-api:${{ github.sha }}
          docker push $ECR_REGISTRY/onvaca-api:${{ github.sha }}
      
      # Deploy to ECS (rolling update)
      - uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with:
          task-definition: task-definition.json
          service: onvaca-api
          cluster: onvaca-production
          wait-for-service-stability: true
```

**The pipeline flow:**
1. **On push to `main`** → Run lint, unit tests, and e2e tests.
2. **If tests pass** → Build Docker image, push to ECR.
3. **Deploy** → Update ECS task definition with new image tag, ECS performs a rolling update (zero downtime).
4. **Wait for stability** → The action waits until all new tasks are healthy before marking the deployment as successful.

---

## 10. Performance & Troubleshooting

---

### Q26: A page on Onvaca is loading slowly. Walk me through how you'd diagnose and fix the performance issue.

**Answer:**

I follow a **systematic top-down approach** — start from the user's browser and trace the request path until I find the bottleneck.

**Step 1: Reproduce and measure.**
- Open Chrome DevTools → Network tab. Is it a slow API response (backend) or slow rendering (frontend)?
- If the API response takes 3 seconds, the problem is backend. If the API returns in 200ms but the page still takes 4 seconds, the problem is frontend.

**Step 2: Frontend diagnosis (if frontend):**
- **Lighthouse audit** → Check LCP, FID, CLS scores. Identify large images, render-blocking JS, layout shifts.
- **Bundle analysis** → Run `@next/bundle-analyzer`. Are we shipping a 2MB lodash bundle? Replace with tree-shakeable imports.
- **Network waterfall** → Are we making 15 sequential API calls? Consolidate into 1 GraphQL query or use `Promise.all` for parallel requests.
- **Common fixes:** Lazy load images below the fold, code-split heavy components, use ISR instead of SSR where possible.

**Step 3: Backend diagnosis (if backend):**
- **Check logs (CloudWatch/ELK)** → Is the endpoint throwing errors? Are there timeout warnings?
- **Check APM metrics (Prometheus/Grafana)** → What's the p99 latency for this endpoint? Is it consistently slow or intermittent?
- **Database slow query log** → Enable `log_min_duration_statement = 500` in PostgreSQL. Run `EXPLAIN ANALYZE` on the slow query:

```sql
EXPLAIN ANALYZE 
SELECT * FROM listings 
WHERE city = 'Dubai' AND status = 'active' 
ORDER BY avg_rating DESC 
LIMIT 20;
```

If I see `Seq Scan on listings` (full table scan), the fix is an index:
```sql
CREATE INDEX idx_listings_city_rating ON listings(city, avg_rating DESC) WHERE status = 'active';
```

- **N+1 query problem** → The most common backend performance issue. If fetching 20 listings triggers 20 separate queries for reviews, that's an N+1. Fix with eager loading:

```typescript
// ❌ BAD: N+1 queries
const listings = await listingRepo.find({ where: { city: 'Dubai' } });
// This triggers 20 more queries, one per listing
for (const listing of listings) {
  listing.reviews = await reviewRepo.find({ where: { listingId: listing.id } });
}

// ✅ GOOD: Single query with JOIN
const listings = await listingRepo.find({
  where: { city: 'Dubai' },
  relations: ['reviews', 'host', 'photos'], // Eager load in one query
});
```

- **Missing cache** → Is this endpoint hitting the database on every request? Add Redis caching with appropriate TTL.
- **External service latency** → If the endpoint calls a payment gateway or geocoding API, measure that call specifically. Add a timeout and consider caching the result.

**Step 4: Infrastructure diagnosis:**
- **CPU/memory** → Check ECS task metrics. If CPU is at 95%, we need more instances (auto-scaling).
- **Database connections** → Check connection pool utilization. If all connections are busy, increase pool size or add read replicas.
- **Redis memory** → If Redis is full, it starts evicting keys. Check `maxmemory` and eviction policy.

---

### Q27: How do you write testable code in NestJS? Explain unit testing vs integration testing.

**Answer:**

**Unit tests** test a single function/class in isolation — all dependencies are mocked. They're fast (milliseconds) and catch logic bugs.

```typescript
// booking.service.spec.ts — UNIT TEST
describe('BookingService', () => {
  let service: BookingService;
  let mockCalendarRepo: jest.Mocked<Repository<Calendar>>;
  let mockPaymentService: jest.Mocked<PaymentService>;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        BookingService,
        {
          provide: getRepositoryToken(Calendar),
          useValue: {
            find: jest.fn(),
            save: jest.fn(),
          },
        },
        {
          provide: PaymentService,
          useValue: { charge: jest.fn() },
        },
      ],
    }).compile();

    service = module.get(BookingService);
    mockCalendarRepo = module.get(getRepositoryToken(Calendar));
    mockPaymentService = module.get(PaymentService);
  });

  it('should throw ConflictException if dates are not available', async () => {
    // Arrange: calendar returns dates that are NOT available
    mockCalendarRepo.find.mockResolvedValue([
      { listingId: 'uuid', date: new Date('2026-12-01'), isAvailable: false },
    ]);

    // Act & Assert
    await expect(
      service.createBooking({ listingId: 'uuid', checkIn: '2026-12-01', checkOut: '2026-12-02' }, 'guest-id'),
    ).rejects.toThrow(ConflictException);

    // Payment should NOT be called if dates aren't available
    expect(mockPaymentService.charge).not.toHaveBeenCalled();
  });
});
```

**Integration tests** (e2e) test the full HTTP request → response flow with a real database and real dependencies:

```typescript
// booking.e2e-spec.ts — INTEGRATION TEST
describe('Booking API (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const module = await Test.createTestingModule({
      imports: [AppModule], // Full application module
    }).compile();

    app = module.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ whitelist: true }));
    await app.init();
  });

  it('POST /bookings should create a booking and return 201', () => {
    return request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${guestToken}`)
      .send({
        listingId: testListing.id,
        checkIn: '2026-12-01',
        checkOut: '2026-12-07',
        guests: 4,
      })
      .expect(201)
      .expect(res => {
        expect(res.body.data.status).toBe('confirmed');
        expect(res.body.data.nights).toBe(6);
      });
  });

  it('POST /bookings should return 409 for double-booking', async () => {
    // First booking succeeds
    await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${guestToken}`)
      .send({ listingId: testListing.id, checkIn: '2026-12-01', checkOut: '2026-12-07', guests: 2 })
      .expect(201);

    // Second booking for same dates fails
    await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${anotherGuestToken}`)
      .send({ listingId: testListing.id, checkIn: '2026-12-03', checkOut: '2026-12-05', guests: 2 })
      .expect(409);
  });
});
```

**My testing strategy:**
- **Unit tests** for business logic (price calculations, date validations, booking state transitions).
- **Integration tests** for critical paths (booking flow, payment flow, authentication).
- **Target: 80%+ code coverage** on the backend, with 100% coverage on payment and booking logic.

---

## 11. Collaboration & Leadership

---

### Q28: How do you work with product managers and designers to define and deliver features?

**Answer:**

I believe in **early engineering involvement** — engineers shouldn't receive a fully baked spec and just code it. We should participate in shaping the solution.

**My process:**

1. **Discovery phase:** When a PM brings a feature idea (e.g., "we want to add instant booking"), I ask clarifying questions: What's the success metric? What edge cases have we considered? What happens if a host has instant-book enabled but is away and can't respond?

2. **Technical feasibility check:** I do a quick spike (1–2 hours) to identify technical risks. For instant booking: "This requires changing the booking state machine. Currently all bookings go through 'pending' → host confirms → 'confirmed.' We need a new path that skips the host confirmation step. This affects the booking service, notification service, and the host calendar. Estimate: 5 days."

3. **Design collaboration:** I review designs with the designer and flag technical constraints early: "This animated map transition will be laggy on mobile with 500 markers. Can we cluster markers at this zoom level?" or "This infinite-scroll listing page won't work for SEO. Let's use paginated URLs with a 'Load More' button."

4. **Iterative delivery:** I break the feature into shippable increments. For instant booking: Week 1 → Backend API + database changes. Week 2 → Frontend toggle for hosts. Week 3 → Booking flow UI for guests. Each increment is deployable and testable independently.

5. **Post-launch review:** After launch, I review metrics with the PM. Did instant-book increase conversion? Are hosts happy? Any bugs in production?

---

### Q29: Tell me about a time you had to make a difficult technical trade-off under time pressure.

**Answer:**

*(Template — adapt to your real experience:)*

We were launching a new search feature 2 weeks before a major holiday season (similar to Eid in the MENA context). The ideal solution was to build a full Elasticsearch-powered search with geo-filtering, faceted search, and ML-based ranking. That would take 6 weeks.

**The trade-off:** I proposed a two-phase approach:
- **Phase 1 (2 weeks, before the holiday):** Implement search directly on PostgreSQL using PostGIS for geo-queries and basic filtering. No ML ranking — just sort by rating and distance. This covered 80% of the use case.
- **Phase 2 (4 weeks, after the holiday):** Migrate search to Elasticsearch with proper CDC pipeline, faceted filters, and ranking signals.

**Why this was the right call:**
- We captured holiday traffic (business value) instead of missing the window.
- PostgreSQL search was "good enough" for our scale at the time (50K listings). It would only become a bottleneck at 500K+.
- Phase 1 taught us what users actually search for, which informed the Elasticsearch schema design in Phase 2.

**What I learned:** Perfect is the enemy of shipped. The best architecture is the one that solves today's problem while leaving a clear path to evolve.

---

## 12. Scenario-Based Questions (Onvaca-Specific)

---

### Q30: How would you handle a situation where a guest's payment succeeds but the booking confirmation fails due to a server crash?

**Answer:**

This is a classic **distributed transaction problem** — the payment and booking are in two different systems (Stripe and our PostgreSQL), and a crash between them leaves things in an inconsistent state.

**Solution: Use the Outbox Pattern + Idempotent Retries.**

```
1. Begin PostgreSQL transaction
2. INSERT booking (status = 'payment_processing')
3. INSERT outbox_event (type = 'charge_guest', bookingId, amount, idempotencyKey)
4. COMMIT transaction
5. Background worker reads outbox_event → calls Stripe with idempotencyKey
6. If Stripe succeeds → UPDATE booking status = 'confirmed', DELETE outbox_event
7. If Stripe fails → UPDATE booking status = 'payment_failed', notify guest
```

**Why this works:**
- Steps 2 and 3 are in the **same database transaction** — they either both succeed or both fail. No orphaned payments.
- If the server crashes after step 4 but before step 5, the background worker picks up the outbox event on restart and retries.
- The **idempotency key** ensures that if Stripe was already charged (before the crash), the retry returns the existing payment instead of charging again.
- This guarantees **at-least-once delivery** with **exactly-once processing** (thanks to the idempotency key).

---

### Q31: How would you implement a cancellation policy system where different listings can have different refund rules?

**Answer:**

I'd model cancellation policies as a **strategy pattern** with rules stored in the database:

```typescript
// Database: cancellation_policies table
// id | name           | rules (JSONB)
// 1  | flexible       | { "fullRefundDaysBefore": 1, "partialRefundPct": 0 }
// 2  | moderate       | { "fullRefundDaysBefore": 5, "partialRefundPct": 50 }
// 3  | strict         | { "fullRefundDaysBefore": 14, "partialRefundPct": 0 }
// 4  | non_refundable | { "fullRefundDaysBefore": 0, "partialRefundPct": 0 }

@Injectable()
export class CancellationService {
  calculateRefund(booking: Booking, policy: CancellationPolicy): RefundResult {
    const daysUntilCheckIn = differenceInDays(booking.checkIn, new Date());
    const rules = policy.rules;

    if (daysUntilCheckIn >= rules.fullRefundDaysBefore) {
      return {
        refundAmount: booking.totalPrice,
        refundPercentage: 100,
        reason: `Full refund: cancelled ${daysUntilCheckIn} days before check-in`,
      };
    }

    if (rules.partialRefundPct > 0) {
      const refund = booking.totalPrice * (rules.partialRefundPct / 100);
      return {
        refundAmount: refund,
        refundPercentage: rules.partialRefundPct,
        reason: `Partial refund (${rules.partialRefundPct}%): less than ${rules.fullRefundDaysBefore} days before check-in`,
      };
    }

    return {
      refundAmount: 0,
      refundPercentage: 0,
      reason: 'Non-refundable: cancellation not eligible for refund',
    };
  }
}
```

**Why JSONB for rules?** Different cancellation policies can have different rule shapes (some have sliding-scale refunds, some have cleaning fee exceptions). JSONB gives us flexibility without schema changes. The rules are **validated at write time** using a JSON Schema or class-validator.

---

### Q32: You need to implement a feature where hosts receive payouts in their local currency (e.g., EGP) but guests pay in a different currency (e.g., AED). How would you handle this?

**Answer:**

**The flow:**

1. **At booking time:** Lock the exchange rate. Store both the guest's currency and the host's currency:
```sql
INSERT INTO bookings (
  guest_amount, guest_currency,     -- AED 500 (what guest paid)
  host_amount, host_currency,       -- EGP 7,500 (what host will receive)
  exchange_rate, exchange_locked_at, -- 15.0, 2026-12-01T00:00:00Z
  platform_fee                       -- AED 50 (10% of guest amount)
) VALUES (500, 'AED', 7500, 'EGP', 15.0, NOW(), 50);
```

2. **Locking the rate** protects both parties from currency volatility. If AED/EGP moves 5% after booking, neither party is affected.

3. **At payout time (24h after check-in):** Transfer `host_amount` in `host_currency` to the host's configured bank account via the payment gateway.

4. **Exchange rate source:** Use a treasury API (e.g., Open Exchange Rates, Fixer.io) and add a small markup (1–2%) to cover currency risk. Cache rates in Redis with 1-hour TTL.

```typescript
@Injectable()
export class CurrencyService {
  async convert(amount: number, from: string, to: string): Promise<ConversionResult> {
    const rate = await this.getRate(from, to); // Cached in Redis
    const markup = 1.015; // 1.5% markup for currency risk
    const converted = amount * rate * markup;

    return {
      originalAmount: amount,
      originalCurrency: from,
      convertedAmount: Math.round(converted * 100) / 100,
      convertedCurrency: to,
      rate: rate,
      rateWithMarkup: rate * markup,
      rateLockedAt: new Date(),
    };
  }
}
```

---

*This document covers 32 questions across 12 categories. For system design questions, refer to the companion document: [Vacation Rental Marketplace.md](./Vacation%20Rental%20Marketplace.md)*
