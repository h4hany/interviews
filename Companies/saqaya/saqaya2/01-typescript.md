# TypeScript Technical Lead Interview Study Guide (SAQAYA / Palladium)

## 1. Introduction & Context
This guide is tailored for a Technical Lead / Senior Software Engineer role at SAQAYA (Palladium as a client), focusing on TypeScript within an enterprise stack: Node.js, Python, FastAPI, PostgreSQL, AWS, and CI/CD. The domain involves taking an early-stage eLearning / LLM platform to a production-ready state. At this level, TypeScript interviews transcend syntax; they evaluate architectural judgment, type-level safety, mitigating the "runtime gap," and scaling team practices.

## 2. Top 20 Mistakes Senior Engineers Make in TypeScript
1.  **Falling Back to `any`:** Using `any` instead of `unknown`, breaking the entire type inference chain.
2.  **Over-Engineering Types:** Writing "type gymnastics" (complex recursive or deeply mapped types) that Junior developers cannot read or maintain.
3.  **Trusting the Network:** Assuming `fetch` or API responses match the TypeScript interface without runtime validation (Zod, io-ts).
4.  **Misunderstanding Structural Typing:** Forgetting that TypeScript is structurally typed, not nominally typed, leading to unexpected assignability.
5.  **Ignoring the "Runtime Gap":** Believing TypeScript types exist at runtime.
6.  **Mutating Function Parameters:** Not using `Readonly<T>` or `readonly` arrays for immutable data pipelines.
7.  **Overusing `as` Assertions:** Casting types with `as` instead of writing proper type guards, hiding underlying errors.
8.  **Loose `tsconfig.json`:** Failing to enable `strict`, `strictNullChecks`, and `noUncheckedIndexedAccess` from day one.
9.  **Leaking Internal Types:** Exposing deep backend types (like DB entities) directly to the API response without DTOs.
10. **Poor Union Handling:** Using optional properties (`status?: string`) instead of discriminated unions for state modeling.
11. **Bloated Interfaces:** Creating monolithic interfaces instead of composing smaller, focused interfaces.
12. **Ignoring Module Boundaries:** Creating circular dependencies in large monorepos due to lack of `import type`.
13. **Improper Generics:** Using generics just to return `any` or failing to constrain them (`<T extends Base>`).
14. **Forgetting `never`:** Not utilizing the `never` type for exhaustive switch checks in discriminated unions.
15. **Misunderstanding Enums:** Using numeric enums (which are unsafe) instead of string enums or union types.
16. **Class-Heavy TS in Node:** Defaulting to OOP classes when pure functions and interfaces would be simpler and more performant.
17. **Ignoring CI Type Checks:** Running tests but failing to run `tsc --noEmit` in CI pipelines.
18. **Poor Monorepo Configuration:** Messing up Project References (`composite: true`), causing massive build times.
19. **Mixing Null and Undefined:** Not having a team standard on whether to use `null` (database empty) vs `undefined` (missing memory value).
20. **Premature Abstraction:** Building overly complex generic repository patterns instead of starting specific and refactoring.

## 3. TypeScript Cheat Sheet
*   **Structural Typing:** `A` is assignable to `B` if `A` has all properties of `B`.
*   **`any` vs `unknown`:** `any` disables checks. `unknown` forces you to narrow before usage.
*   **Discriminated Unions:** `type State = { status: 'loading' } | { status: 'success', data: Data }`.
*   **Type Guards:** `function isString(val: unknown): val is string { return typeof val === 'string'; }`.
*   **Assertion Functions:** `function assertIsDefined<T>(val: T): asserts val is NonNullable<T> { ... }`.
*   **`keyof` / `typeof`:** `keyof` gets keys of a type as a union. `typeof` extracts the TS type of a JS variable.
*   **Mapped Types:** `{ [K in keyof T]: boolean }`.
*   **Conditional Types:** `T extends U ? X : Y`.
*   **`infer`:** Used in conditionals to extract a type: `T extends Promise<infer U> ? U : T`.
*   **Template Literal Types:** `` type Event = `on${Capitalize<string>}` ``.
*   **Utility Types:** `Partial<T>`, `Required<T>`, `Readonly<T>`, `Pick<T, K>`, `Omit<T, K>`, `Record<K, T>`, `Extract<T, U>`, `Exclude<T, U>`, `NonNullable<T>`, `ReturnType<T>`, `Parameters<T>`.

## 4. Final Question Lists (Top 10 For Each Category)

### Top 10 Core TypeScript
1. How do you safely parse untrusted data from an external LLM API?
2. Explain the difference between structural and nominal typing. How do you simulate nominal typing in TS?
3. How do you design a state machine using discriminated unions for an eLearning course player?
4. When should you use `interface` vs `type` in an enterprise Node.js app?
5. How does `noUncheckedIndexedAccess` prevent production crashes?
6. Explain variance (covariance vs contravariance) in TypeScript.
7. How do you write a custom type guard for a complex nested object?
8. What is the `infer` keyword and when do you use it?
9. How do you prevent prototype pollution using TypeScript?
10. How do you type an EventEmitter securely?

### Top 10 Technical Lead Scenarios
1. Migrate a 200k line JS app to TS without stopping feature work.
2. Resolve a conflict between developers arguing over complex Utility types vs `any`.
3. Design a monorepo structure for a shared UI library and a Next.js/Node.js app.
4. Establish the `tsconfig.json` baseline for a new production service.
5. Standardize error handling boundaries across a microservices architecture.
6. Design the type contract between a Node.js backend and a Python/FastAPI ML service.
7. Handle breaking type changes in an internal npm package used by 5 teams.
8. Enforce zero-runtime-cost abstractions in a high-throughput video streaming service.
9. Coach a junior developer out of using `!` (non-null assertions).
10. Review a PR that introduces heavy class decorators and reflection.

### Top 10 Production Failures
1. A 3rd party API changes its payload, bypassing TS types, causing a frontend crash.
2. A memory leak caused by improper closures in typed event handlers.
3. Node.js backend crashes due to an unhandled rejection masquerading as a type error.
4. `tsc --noEmit` passes in CI, but the app crashes in production due to Babel transpilation differences.
5. A database ORM returns `null` instead of `undefined`, breaking a generic utility.
6. Circular dependencies in type definitions cause the TS compiler to crash on build.
7. A typo in a string enum causes silent data corruption in PostgreSQL.
8. `Promise.all` loses type narrowing, resulting in `any` being written to the DB.
9. A mismatched `import type` causes a runtime `undefined is not a function`.
10. The LLM pipeline returns a generic string instead of JSON, bypassing interface casting.

### Top 10 Architecture / Trade-offs
1. Runtime Validation (Zod) vs. Compile-time casting (`as`).
2. ORM (Prisma/TypeORM) vs. Query Builder (Kysely/Knex) in TypeScript.
3. Monorepo (Turborepo) vs. Polyrepo with NPM packages.
4. Functional Programming (pure functions, interfaces) vs. OOP (classes, DI containers like NestJS).
5. GraphQL (codegen types) vs. REST (OpenAPI schema types).
6. Shared Types package vs. Duplicating types across frontend/backend.
7. `enum` vs. `const as const` objects.
8. Strict Null Checks enabled vs. disabled on legacy codebases.
9. Generating types from the DB schema vs. Generating the DB schema from types.
10. Decorators (experimental) vs. Higher Order Functions for middleware.

## 5. Complete System Design Exercise

### Design an LLM-Powered eLearning Assessment Pipeline
**Context:** You are building a system where students submit free-text answers. A Node.js backend queues the answers. A Python FastAPI service uses an LLM to grade them. The result is returned to the frontend.
**Goal:** Design the type contracts and architecture to ensure 100% type safety and resilience across network boundaries.

**Requirements & Data Model:**
We must model the submission state and ensure the frontend cannot display a grade until the LLM completes.

**Architecture:**
1.  **Frontend (React/TS):** Submits data, polls/listens for completion.
2.  **Backend (Node.js/TS):** Validates input, queues job, manages DB state.
3.  **ML Service (Python/FastAPI):** Processes LLM, returns JSON.

**Type Contracts (Shared Monorepo):**
```typescript
// Shared Types (e.g., packages/types/src/index.ts)

export type AssessmentId = string & { readonly _brand: unique symbol }; // Nominal typing

// Discriminated Union for State
export type AssessmentStatus = 
  | { status: 'PENDING'; submittedAt: string }
  | { status: 'PROCESSING'; startedAt: string; estimatedCompletion: number }
  | { status: 'COMPLETED'; score: number; feedback: string; completedAt: string }
  | { status: 'FAILED'; errorCode: 'LLM_TIMEOUT' | 'CONTENT_FILTER'; retryable: boolean };

export interface AssessmentRecord {
  id: AssessmentId;
  studentId: string;
  questionId: string;
  rawText: string;
  state: AssessmentStatus;
}
```

**Boundary Validation (Node.js):**
```typescript
import { z } from 'zod';

// Validate webhook from Python service
const LLMWebhookSchema = z.object({
  id: z.string(), // Cast to AssessmentId later
  score: z.number().min(0).max(100),
  feedback: z.string(),
});

app.post('/webhook/llm-result', (req, res) => {
  const result = LLMWebhookSchema.safeParse(req.body);
  if (!result.success) {
    // We reject gracefully; invalid states never enter our DB
    return res.status(400).json(result.error);
  }
  
  // Transition state in DB...
});
```

**Trade-offs Discussed:**
*   **Nominal Typing (`_brand`)**: Prevents accidentally passing a `UserId` into a function expecting an `AssessmentId`. Trade-off: slightly ugly creation (`id as AssessmentId`).
*   **Zod at Boundaries**: Adds a slight runtime cost, but eliminates the "runtime gap" where TS thinks the Python service sent a number, but it actually sent a string.
*   **Discriminated Unions for DB vs. API**: SQL DBs don't naturally store unions easily (usually requires a status column and nullable JSONB payload column). The Repository layer must map the DB row back into the strict TypeScript union type.

## 6. Detailed Interview Questions (Categories)

### Category: Advanced Type System & Core TypeScript

---
#### 1. The Runtime Gap and Data Validation
**Interview Question:** You are fetching a JSON payload from an external LLM API. The documentation states it returns `{ score: number, feedback: string }`. How do you type this fetch call, and what are the risks?
**Difficulty Level:** Senior/Lead
**Research Classification:** [COMMON]
**Why They Ask This:** To see if you understand that TypeScript is erased at runtime. Using `as` or `any` here is an immediate red flag for senior candidates.
**Short Interview Answer (30-90s):** "I would fetch the response as `unknown`, not `any`, and never blindly cast it using `as`. Because external APIs can change or fail, I'd use a runtime validation library like Zod or io-ts to parse the JSON. If it passes validation, it becomes strongly typed. If it fails, I can handle the error predictably rather than letting an undefined variable crash the app later."
**Deep Explanation:** TypeScript's greatest vulnerability is the boundary between the typed world and the untyped world (I/O, network, disk). If you write `const data = await fetch().then(r => r.json()) as ExpectedType;`, you are lying to the compiler. If the API returns a string instead of a number for `score`, TS won't complain, but your math operations will yield `NaN` at runtime.
**Under the Hood:** TypeScript types are stripped out during the emit phase. The JavaScript engine has no concept of your `ExpectedType`.
**Real-World Example:** In an LLM eLearning platform, LLMs are notoriously unreliable with JSON output. They might output `{\n "score": "95" \n}` instead of a number.
**Production Scenario:** The LLM API silently updates its model. It now returns `feedback_text` instead of `feedback`. If you used `as`, your frontend renders `undefined`. If you used Zod, the webhook fails validation, triggers an alert, and goes to a dead-letter queue.
**Code Example:**
```typescript
import { z } from 'zod';

const LLMResponseSchema = z.object({
  score: z.number().or(z.string().transform(Number)), // Handle LLM quirks
  feedback: z.string()
});
type LLMResponse = z.infer<typeof LLMResponseSchema>;

async function fetchGrade(): Promise<LLMResponse> {
  const response = await fetch('https://api.openai.com/...');
  const json: unknown = await response.json(); // unknown, not any
  
  // parse() throws if invalid. safeParse() returns a Result type.
  return LLMResponseSchema.parse(json); 
}
```
**Trade-offs:** Zod adds bundle size and minor CPU overhead for parsing. For extreme high-throughput systems, manual type guards might be preferred, but Zod is safer for standard business logic.
**What a Weak Candidate Might Say:** "I would define an interface `LLMResponse` and do `const data = <LLMResponse> await response.json();`."
**What a Senior Engineer Would Say:** "I'd use Zod to validate the schema at runtime, ensuring the type system matches reality."
**What a Technical Lead Would Say:** "I'd implement a standardized boundary validation layer using Zod, ensuring all untrusted I/O is sanitized before entering the domain core. I'd also monitor parsing failures in Datadog to detect silent LLM model drift."
**Follow-up Questions:**
1. What if the payload is massive and Zod parsing blocks the Node event loop?
2. How do you share these Zod schemas with the frontend?
**Follow-up Answers:**
1. For massive payloads, use streams or chunking. Or use a faster validator like `ajv` (JSON Schema) which compiles to raw JS functions.
2. Place the schemas in a shared monorepo package. The frontend can use the same Zod schema for form validation or caching expectations.
**Interviewer Trap:** Asking "Can't you just use an interface to guarantee the type?" No, interfaces don't exist at runtime.
**Key Takeaways:** Always validate boundaries. Prefer `unknown` over `any`. Zod/TypeBox/io-ts are standard in enterprise Node.js.

---
#### 2. Discriminated Unions for State Machines
**Interview Question:** How would you model the state of a video processing job in our eLearning platform? It starts as pending, moves to processing (which has progress percentage), and then either succeeds (has a URL) or fails (has an error code).
**Difficulty Level:** Senior
**Research Classification:** [CONFIRMED]
**Why They Ask This:** To test your ability to make "illegal states unrepresentable."
**Short Interview Answer:** "I would use a discriminated union using a shared literal property like `type` or `status`. This ensures that properties specific to one state, like 'progress', cannot be accessed when the state is 'failed', eliminating a whole class of undefined errors."
**Deep Explanation:** A common anti-pattern is a massive flat interface with optional fields: `{ status: string, progress?: number, url?: string, error?: string }`. This allows invalid states like `{ status: 'success', error: 'failed' }`. A discriminated union solves this by providing distinct interfaces tied together by a constant discriminant.
**Code Example:**
```typescript
type VideoJob =
  | { status: 'PENDING'; enqueuedAt: Date }
  | { status: 'PROCESSING'; progress: number }
  | { status: 'SUCCESS'; videoUrl: string }
  | { status: 'FAILED'; error: string; retryable: boolean };

function handleJob(job: VideoJob) {
  if (job.status === 'PROCESSING') {
    // TS knows job has progress, but NO videoUrl
    console.log(job.progress); 
  } else if (job.status === 'SUCCESS') {
    console.log(job.videoUrl);
  }
}
```
**Key Takeaways:** Never use flat objects with optionals for mutually exclusive states.

---
#### 3. Exhaustiveness Checking with `never`
**Interview Question:** Following up on the VideoJob union, how do you ensure that if another engineer adds a 'CANCELLED' state in the future, the compiler forces them to update the `handleJob` switch statement?
**Difficulty Level:** Senior
**Research Classification:** [LIKELY]
**Why They Ask This:** Proves you understand how to use the compiler as a safety net for future maintenance.
**Short Interview Answer:** "I'd use the `never` type in the `default` case of a switch statement. If a new state is added, the union type is no longer fully narrowed, and TypeScript will throw a compile-time error when trying to assign the unhandled state to `never`."
**Code Example:**
```typescript
function handleJob(job: VideoJob) {
  switch (job.status) {
    case 'PENDING': return '...';
    case 'PROCESSING': return '...';
    case 'SUCCESS': return '...';
    case 'FAILED': return '...';
    default:
      // If 'CANCELLED' is added to the union, job will be typed as { status: 'CANCELLED' } here.
      // You cannot assign an object to type 'never', so the build fails!
      const _exhaustiveCheck: never = job;
      return _exhaustiveCheck;
  }
}
```
**Key Takeaways:** `never` is the bottom type. Using it for exhaustive checks prevents production bugs during large refactors.

---
#### 4. Advanced Utility Types & Mapped Types
**Interview Question:** We have an object of API handler functions. We want to generate a type that represents the return types of all those functions, wrapped in a Promise. How do you do this?
**Difficulty Level:** Lead
**Research Classification:** [COMMON]
**Why They Ask This:** Tests deep understanding of Mapped Types, Conditional Types, and `infer`.
**Short Interview Answer:** "I would use a mapped type to iterate over the keys of the object. For each key, I'd use the `ReturnType` utility to get the function's return type, and then use a conditional type to wrap it in a Promise if it isn't one already."
**Code Example:**
```typescript
type Handlers = {
  getUser: () => { name: string };
  getCourse: () => Promise<{ title: string }>;
};

// The Utility Type
type AsyncResponses<T> = {
  [K in keyof T]: T[K] extends (...args: any[]) => infer R 
    ? (R extends Promise<any> ? R : Promise<R>)
    : never;
};

// Result: { getUser: Promise<{name: string}>, getCourse: Promise<{title: string}> }
type Result = AsyncResponses<Handlers>;
```
**What a Tech Lead Would Say:** "While this is a powerful type-level metaprogramming tool, I'd caution the team to use it sparingly. Deeply nested mapped types can degrade IDE autocomplete performance and make the codebase hostile to junior developers. We should document it heavily."

---
#### 5. Nominal Typing in a Structural World
**Interview Question:** How do you prevent a developer from passing a `CourseId` string into a function that expects a `StudentId` string?
**Difficulty Level:** Senior/Lead
**Research Classification:** [LIKELY]
**Why They Ask This:** Demonstrates understanding of structural typing flaws and how to patch them in domain-driven design.
**Short Interview Answer:** "Since TS is structurally typed, all strings are compatible. I'd use Branding or Flavoring—intersecting the string type with a unique symbol or literal type—to simulate nominal typing."
**Code Example:**
```typescript
type Brand<K, T> = K & { readonly __brand: T };

type CourseId = Brand<string, 'CourseId'>;
type StudentId = Brand<string, 'StudentId'>;

function getCourse(id: CourseId) {}

const myStudentId = 'uuid-123' as StudentId;
// getCourse(myStudentId); // TS ERROR!
```
**Key Takeaways:** Essential for DDD (Domain Driven Design) in Node.js backends.

---
### Category: Node.js & Backend Enterprise Patterns

#### 6. Dependency Injection with TypeScript
**Interview Question:** In a Node.js enterprise backend, how do you handle dependencies between services while maintaining strict type safety and testability?
**Difficulty Level:** Senior
**Research Classification:** [CONFIRMED]
**Why They Ask This:** Architecture question evaluating DI container knowledge vs pure function approaches.
**Deep Explanation:** 
**What a Tech Lead Would Say:** "I prefer constructor injection with interfaces. In TypeScript, interfaces don't exist at runtime, which breaks classical DI containers (like InversifyJS or NestJS) unless you use classes or symbols as injection tokens. My approach is to define an interface for the Repository, and inject a class that implements it into the Service. For testing, I inject a mock object that satisfies the interface."
**Code Example:**
```typescript
interface IUserRepository {
  findById(id: string): Promise<User | null>;
}

// Inversify/NestJS use classes or symbols because TS interfaces vanish.
export const USER_REPOSITORY_TOKEN = Symbol('IUserRepository');

class UserService {
  // Inject interface via constructor
  constructor(private readonly userRepo: IUserRepository) {}
  
  async getUser(id: string) {
    return this.userRepo.findById(id);
  }
}
```

#### 7. Handling Exceptions and Error Types
**Interview Question:** `catch (e)` in TypeScript types `e` as `unknown` or `any`. How do you safely handle errors and maintain typed error channels?
**Difficulty Level:** Senior
**Research Classification:** [COMMON]
**Why They Ask This:** Error handling is famously untyped in TS/JS.
**Short Interview Answer:** "I narrow the `unknown` error using `instanceof` checks against custom Error classes. Alternatively, for complex business logic, I use the Result pattern (like Rust's Result or Either monad) to return errors as values rather than throwing them."
**Code Example:**
```typescript
class DatabaseError extends Error {
  constructor(public query: string, message: string) { super(message); }
}

try {
  await db.query();
} catch (error: unknown) {
  if (error instanceof DatabaseError) {
    logger.error(error.query); // Typed!
  } else if (error instanceof Error) {
    logger.error(error.message);
  } else {
    logger.error('Unknown error', error);
  }
}
```

#### 8. `strictNullChecks` and Database ORMs
**Interview Question:** You use Prisma/TypeORM. A database query returns a user, but some fields are nullable in SQL. How do you handle this mapping to TS?
**Difficulty Level:** Senior
**Research Classification:** [INFERRED]
**Why They Ask This:** Bridging SQL constraints with TS constraints.
**What a Tech Lead Would Say:** "I ensure `strictNullChecks` is on. In SQL, a missing value is `NULL`. In JS, it's often `undefined`. I establish a team standard: `null` is exclusively for database data, `undefined` is for runtime/memory state. I use TS types to strictly enforce that UI components handle the `null` state, often using Nullish Coalescing (`??`) to provide fallbacks at the service boundary."

---
### Category: Technical Lead Scenarios

#### 9. Migration Strategy
**Interview Question:** We have a legacy React/Express app in pure JavaScript. We want to move to TypeScript. How do you plan this?
**Difficulty Level:** Tech Lead
**Research Classification:** [CONFIRMED]
**Short Interview Answer:** "I'd use a progressive, bottom-up approach. First, rename files to `.ts` and enable `allowJs: true`. Set up the CI pipeline to run TS checks. We type the core domain entities and reusable utility functions first. I would NOT mandate 'noImplicitAny' immediately; instead, I'd set a rule that all *new* code must be strict TS, and we gradually refactor old code."

#### 10. The `tsconfig.json` Baseline
**Interview Question:** What are the most important `tsconfig.json` flags for a new production project?
**Difficulty Level:** Lead
**Research Classification:** [COMMON]
**Deep Explanation:**
*   `strict: true`: Enables all strict type checking options.
*   `noUncheckedIndexedAccess: true`: CRITICAL. Forces you to check if `array[0]` exists before using it. Prevents `undefined` crashes.
*   `exactOptionalPropertyTypes: true`: Distinguishes between property not present vs property set to `undefined`.
*   `forceConsistentCasingInFileNames: true`: Prevents "works on Mac, breaks in Linux CI" issues.
*   `isolatedModules: true`: Required if using external bundlers like esbuild or swc.

---
### Category: Production Failure Scenarios

#### 11. Memory Leaks with Typed Callbacks
**Scenario:** A typed EventEmitter in your Node backend is causing memory leaks.
**Cause:** Passing bound class methods to event listeners without removing them. The TS type definition gave a false sense of security.
**Lead Solution:** "TS types don't manage garbage collection. I would enforce a pattern of returning cleanup functions from event registrations, and use WeakMaps or WeakRefs if we must track listener metadata."

#### 12. `Promise.all` Array Narrowing
**Scenario:** Developers used `.filter(Boolean)` on an array of Promises, but TypeScript still thinks the array contains `undefined`.
**Cause:** `Boolean` as a filter doesn't act as a type guard by default in older TS versions.
**Lead Solution:** "Write a custom type guard utility `const isDefined = <T>(val: T | undefined | null): val is T => val !== undefined && val !== null;` and use `.filter(isDefined)`."

#### 13. The Circular Dependency Crash
**Scenario:** The TS compiler hangs or crashes with "heap out of memory" in a large monorepo.
**Cause:** Deep circular dependencies created by exporting interfaces back and forth between modules.
**Lead Solution:** "Enforce `import type { User } from './user'` for all type-only imports, allowing the compiler and bundlers to aggressively tree-shake and avoid circular runtime evaluations. Add `eslint-plugin-import` with `no-cycle`."

---
### Category: Architecture / Trade-offs

#### 14. TypeScript Monorepo Tooling
**Question:** Turborepo vs Nx vs Lerna for our Next.js + Node backend monorepo?
**Trade-off Answer:** "Turborepo is lighter and caches standard npm scripts (like `tsc`) excellently via content hashing. Nx provides heavier, plugin-based generation which is great for Angular but often overkill for standard TS stacks. I prefer Turborepo + pnpm workspaces for speed and simplicity, relying on TS Project References (`composite: true`) only when strictly necessary, as they can complicate the build setup."

#### 15. Generating Types
**Question:** Do you generate TS types from the Database schema, or generate the schema from TS types (Code-first vs DB-first)?
**Trade-off Answer:** "Code-first (like TypeORM with decorators) is developer-friendly but can lead to unoptimized, hidden DB migrations. DB-first (like Prisma or Kysely generating types from introspection) is safer for enterprise. The Database is the ultimate source of truth. Generating types from it ensures your TS code always matches reality."

---
#### 16. Template Literal Types for Routing
**Interview Question:** Design a strictly typed routing function that only accepts valid paths based on a predefined string template (e.g., `/users/:id/posts/:postId`).
**Difficulty Level:** Lead
**Research Classification:** [LIKELY]
**Why They Ask This:** Tests your mastery of Template Literal types and recursive conditional type inference, highly relevant for creating zero-runtime-cost abstractions in frameworks.
**Short Interview Answer:** "I would use template literal types combined with recursive conditional types and the 'infer' keyword to parse the route string at compile time, extracting any segment that starts with a colon into an object type representing the required parameters."
**Deep Explanation:** Template literals allow string manipulation at the type level. By combining `` `${infer Start}/${infer Rest}` ``, we can recursively split a route string. If `Start` extends `` `:${infer Param}` ``, we map that `Param` to a string type.
**Under the Hood:** The compiler evaluates these string recursions up to a certain depth limit. It treats the string like a tuple of characters/segments.
**Real-World Example:** Next.js uses this under the hood for its typed routes. Trpc and Express extensions use it to ensure `req.params.id` is typed properly without manual generics.
**Production Scenario:** A developer changes a route from `/api/v1/course/:courseId` to `/api/v2/course/:id`. If typed manually, they might forget to update the controller interface. With template literal inference, the controller immediately fails to compile because it expects `courseId` but the route infers `id`.
**Code Example:**
```typescript
type ExtractParams<Route extends string> = 
  Route extends `${infer _Start}:${infer Param}/${infer Rest}` ? { [K in Param | keyof ExtractParams<`/${Rest}`>]: string } :
  Route extends `${infer _Start}:${infer Param}` ? { [K in Param]: string } : 
  {};

function navigate<T extends string>(path: T, params: ExtractParams<T>) {}

// navigate('/user/:userId', {}); // ERROR: missing userId
navigate('/user/:userId', { userId: '123' }); // OK!
```
**Trade-offs:** Highly complex type signatures increase compiler workload. If a route string is generated dynamically, this fails completely (requires string literals).
**What a Weak Candidate Might Say:** "I'd just pass a generic `<T>` and hope the user passes the right interface."
**What a Senior Engineer Would Say:** "Template literal types can parse the route. I'd use `ExtractParams` to enforce the contract."
**What a Technical Lead Would Say:** "I'd implement this for core framework boundaries, but I'd abstract the type logic into a separate utility file so junior devs don't have to read it. I'd also monitor TS build times."
**Follow-up Questions:**
1. What happens if the route has an optional parameter?
2. How does this affect TS compiler performance?
3. Can we validate the param type (e.g., must be a UUID)?
**Follow-up Answers:**
1. You'd need to extend the type parser to look for `?` (e.g., `:${infer Param}?`) and make the resulting key optional.
2. It increases instantiation time. Massive route files might hit the recursion limit.
3. At the type level, mostly no, unless using Branded types. Runtime validation is needed for UUID checks.
**Interviewer Trap:** Asking you to implement this for dynamically constructed routes (e.g., `let route = getRoute(); navigate(route, ...)`). TS cannot infer types from non-const runtime strings.
**Key Takeaways:** Template literals are powerful for framework-level typing. Keep them isolated from business logic.

---
#### 17. Safe Database Transactions with Types
**Interview Question:** In an event-driven Node.js system using PostgreSQL, how do you ensure that all database operations within a service method share the same database transaction using TypeScript?
**Difficulty Level:** Senior/Lead
**Research Classification:** [COMMON]
**Why They Ask This:** Tests system architecture, DI, and ensuring data consistency.
**Short Interview Answer:** "I would use a Unit of Work pattern or AsyncLocalStorage. With AsyncLocalStorage, I can store the transaction client in the current asynchronous execution context, and wrap my repository methods in types that either accept an optional transaction client or extract it from the context."
**Deep Explanation:** Passing `tx` (transaction object) through every function argument (prop drilling) pollutes business logic. `AsyncLocalStorage` (Node 14+) allows you to hold state across async boundaries safely. We use TS to strongly type the ALS store.
**Under the Hood:** V8's async hooks track the execution context. TypeScript types the `getStore()` method, ensuring we get a `PoolClient` or `undefined`.
**Real-World Example:** Processing an eLearning payment: Deduct balance, grant course access, emit event. If the event fails, everything must rollback.
**Production Scenario:** A developer forgets to pass the `tx` object to `grantCourse()`. The payment deducts, but the course is not granted because it executed outside the rolled-back transaction. Typed ALS prevents this if repositories are structured to require the context.
**Code Example:**
```typescript
import { AsyncLocalStorage } from 'async_hooks';
import { PoolClient } from 'pg';

const txStorage = new AsyncLocalStorage<PoolClient>();

async function withTransaction(db: Pool, fn: () => Promise<void>) {
  const client = await db.connect();
  try {
    await client.query('BEGIN');
    await txStorage.run(client, fn);
    await client.query('COMMIT');
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
}

class UserRepository {
  async update(id: string) {
    const tx = txStorage.getStore(); 
    const client = tx || globalDbPool; // Fallback or strict requirement
    await client.query('UPDATE users...', [id]);
  }
}
```
**Trade-offs:** ALS adds slight overhead to the event loop. Hides dependencies (anti-pattern for pure DI) but cleans up code.
**What a Weak Candidate Might Say:** "Just pass `tx` to every function."
**What a Senior Engineer Would Say:** "AsyncLocalStorage typed with the DB client resolves prop drilling."
**What a Technical Lead Would Say:** "I prefer explicit 'Unit of Work' classes in DDD, but ALS is a pragmatic Node-native solution. I'd ensure the store type is strictly typed so `txStorage.getStore()` never returns `any`."
**Follow-up Questions:**
1. How does ALS behave with `Promise.all`?
2. What if a repository method is called outside a transaction?
3. How to type the fallback client?
**Follow-up Answers:**
1. Context is preserved across concurrent branches in `Promise.all`.
2. TS can enforce a check if you set the return type of `getStore()` to non-nullable and throw a runtime error if missing.
3. Use a union: `Pool | PoolClient`.
**Interviewer Trap:** Assuming `AsyncLocalStorage` is a TypeScript feature. It's a Node API; TS just provides the generics to type the store.
**Key Takeaways:** Node context + TS Generics = Clean Transactions.

---
#### 18. Migrating from `any` to `unknown` and Beyond
**Interview Question:** A legacy codebase has thousands of `any` types. As a Tech Lead, what is your strategy to eliminate them without halting product delivery?
**Difficulty Level:** Lead
**Research Classification:** [LIKELY]
**Why They Ask This:** Tests leadership, pragmatic refactoring, and deep understanding of `unknown`.
**Short Interview Answer:** "I would implement a 'boy scout rule' with tooling support. I'd use `@typescript-eslint/no-explicit-any` as a warning, enable `strict` on all new modules, and gradually replace `any` with `unknown` at system boundaries, forcing developers to write type guards before usage."
**Deep Explanation:** Banning `any` outright in legacy code breaks the build. Changing `any` to `unknown` is safer because it forces type checking down the line, but it can cause a cascade of TS errors. The strategy is boundary-first: type the database responses and API responses first.
**Under the Hood:** `any` turns off the compiler. `unknown` is a type-safe counterpart; everything is assignable TO `unknown`, but `unknown` is not assignable to anything (except `any` and `unknown`) without a type assertion or narrowing.
**Real-World Example:** An old Express controller casts `req.body` to `any`.
**Production Scenario:** An attacker sends `{ "isAdmin": true }` in `req.body`. Because it's `any`, it spreads into the DB query. Changing `req.body` to `unknown` and passing it through a Zod schema blocks the attack.
**Code Example:**
```typescript
// Legacy:
function process(data: any) {
  return data.value * 2; // Dangerous!
}

// Refactored Step 1:
function processSafe(data: unknown) {
  if (typeof data === 'object' && data !== null && 'value' in data && typeof (data as any).value === 'number') {
     return (data as any).value * 2; 
  }
}

// Refactored Step 2 (Zod):
const Schema = z.object({ value: z.number() });
function processBest(data: unknown) {
  const parsed = Schema.parse(data);
  return parsed.value * 2;
}
```
**Trade-offs:** Narrowing `unknown` adds runtime boilerplate.
**What a Weak Candidate Might Say:** "Turn on `noImplicitAny` and fix all 5,000 errors."
**What a Senior Engineer Would Say:** "Replace `any` with `unknown` and write type guards."
**What a Technical Lead Would Say:** "I'd configure ESLint to prevent new `any` usages. For existing ones, I'd prioritize boundaries (I/O, DB, API). I'd introduce Zod for runtime validation, essentially converting `unknown` to static types automatically."
**Follow-up Questions:**
1. What if a third-party library uses `any`?
2. How to handle `Object.keys()` returning `string[]` instead of `keyof T`?
**Follow-up Answers:**
1. Write an ambient declaration (`.d.ts`) to override the library's types or create an internal wrapper module.
2. `Object.keys()` is typed safely because objects can have excess properties at runtime due to structural typing. You can use a generic wrapper: `(Object.keys(obj) as Array<keyof typeof obj>)`.
**Interviewer Trap:** Suggesting `as unknown as T`. That's just `any` with extra steps.
**Key Takeaways:** Boundaries first. `unknown` forces validation. Tooling drives culture.
