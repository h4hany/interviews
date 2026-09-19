# TypeScript for Technical Leads: Deep Dive & Interview Prep

## 1. Advanced TypeScript Type System

### 1.1 Type-Level Programming (Generics, Conditional, Mapped, Template Literal)
**What:** TypeScript's type system is Turing complete. It allows computation at compile-time to enforce strict runtime invariants without runtime overhead.
**Why:** To create highly reusable, deeply type-safe utility functions and generic components that adapt based on the shape of their inputs.
**Internals:** The TS compiler builds an Abstract Syntax Tree (AST) and performs structural subtyping. Conditional types (`T extends U ? X : Y`) defer resolution until `T` is known.
**Trade-offs:** High type complexity drastically increases compilation time (tsserver lag) and lowers developer velocity if type errors become unreadable.
**Tech Lead Perspective:** Limit type gymnastics to library code or core abstractions (e.g., API clients). Application logic should have explicit, simple types.

```typescript
// Production Example: DeepPartial with Mapped and Conditional Types
export type DeepPartial<T> = T extends Builtin
  ? T
  : T extends Map<infer K, infer V>
  ? Map<K, DeepPartial<V>>
  : T extends ReadonlyMap<infer K, infer V>
  ? ReadonlyMap<K, DeepPartial<V>>
  : T extends WeakMap<infer K, infer V>
  ? WeakMap<K, DeepPartial<V>>
  : T extends Set<infer U>
  ? Set<DeepPartial<U>>
  : T extends ReadonlySet<infer U>
  ? ReadonlySet<DeepPartial<U>>
  : T extends WeakSet<infer U>
  ? WeakSet<DeepPartial<U>>
  : T extends Array<infer U>
  ? T extends IsTuple<T>
    ? { [K in keyof T]?: DeepPartial<T[K]> }
    : Array<DeepPartial<U>>
  : T extends Promise<infer U>
  ? Promise<DeepPartial<U>>
  : T extends {}
  ? { [K in keyof T]?: DeepPartial<T[K]> }
  : Partial<T>;

// Template Literal Types for routing
type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';
type Endpoint = `/api/v1/${string}`;
type Route = `${HttpMethod} ${Endpoint}`;

const validRoute: Route = "POST /api/v1/users"; // OK
```

### 1.2 Discriminated Unions & Type Narrowing
**What:** Using a common literal property (discriminant) to distinguish between object types in a union.
**Why:** Safest way to model domain states (e.g., State Machines) and API responses.
**Production Behavior:** Zero runtime overhead; relies strictly on JS `switch`/`if`.

```typescript
// Production Example: Domain Events
type PaymentEvent = 
  | { type: 'AUTHORIZED'; amount: number; authId: string }
  | { type: 'CAPTURED'; amount: number; captureId: string }
  | { type: 'FAILED'; reason: string; code: number };

function handlePayment(event: PaymentEvent) {
  switch (event.type) {
    case 'AUTHORIZED':
      // TS knows event has authId here
      console.log(event.authId);
      break;
    case 'FAILED':
      console.log(event.reason);
      break;
    default:
      // Exhaustiveness checking
      const _exhaustiveCheck: never = event;
      return _exhaustiveCheck;
  }
}
```

## 2. Error Handling Patterns

### 2.1 Result Types vs Exceptions
**What:** Using discriminated unions to return errors as values instead of throwing them, similar to Rust's `Result` or Go's error handling.
**Why:** `throw` breaks control flow and TypeScript does not have typed throws. Returning errors makes error handling explicit and statically verifiable.

```typescript
// Production Example: Result Type
type Success<T> = { success: true; data: T };
type Failure<E> = { success: false; error: E };
type Result<T, E = Error> = Success<T> | Failure<E>;

const parseUser = (json: string): Result<User, ValidationError> => {
  try {
    const data = JSON.parse(json);
    const parsed = UserSchema.safeParse(data);
    if (!parsed.success) {
      return { success: false, error: new ValidationError(parsed.error) };
    }
    return { success: true, data: parsed.data };
  } catch (e) {
    return { success: false, error: new ValidationError("Invalid JSON") };
  }
};
```

### 2.2 Branded Types (Nominal Typing)
**What:** TS is structurally typed. Branded types simulate nominal typing (where `UserId` and `OrderId` are distinct, even if both are `string`).

```typescript
type Brand<K, T> = K & { __brand: T };
type UserId = Brand<string, 'UserId'>;
type OrderId = Brand<string, 'OrderId'>;

function createOrder(user: UserId): OrderId { /*...*/ return "ord_123" as OrderId; }

const uid = "usr_456" as UserId;
const oid = "ord_789" as OrderId;
// createOrder(oid); // TS Error: OrderId is not assignable to UserId
```

## 3. Strict Mode & Compiler Options
A Technical Lead must enforce `strict: true`. Key flags:
- `strictNullChecks`: Prevents null/undefined from being assignable to everything. Eliminates "cannot read property of undefined".
- `noImplicitAny`: Forces explicit typing, preventing accidental fallback to `any`.
- `exactOptionalPropertyTypes`: Distinguishes between property missing and property explicitly set to `undefined`.
- `noUncheckedIndexedAccess`: Adds `undefined` to the return type of array/object index signatures. Crucial for runtime safety.

**Compilation Performance:** 
- `skipLibCheck`: Skips type checking of `.d.ts` files. Essential for speed.
- `isolatedModules`: Ensures each file can be transpiled safely by tools like Babel, SWC, or esbuild without needing type context.

## 4. Runtime vs Compile-Time Type Checking
**Problem:** TS types disappear at runtime. External inputs (API payloads, DB reads) bypass TS checks.
**Solution:** Validation libraries like Zod, TypeBox, or Runtypes.

```typescript
import { z } from "zod";

const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  role: z.enum(["ADMIN", "USER"])
});

// Extract TS type from Schema
type User = z.infer<typeof UserSchema>;

export const createUser = async (req: Request, res: Response) => {
  // Runtime validation enforcing type safety at the boundary
  const parsed = UserSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json(parsed.error);
  
  const user: User = parsed.data; // Fully typed here
  // ...
};
```

## 5. TypeScript Governance for Tech Leads
**Monorepo Setup (Yarn Workspaces / Turborepo):**
- Use Project References (`composite: true`) to isolate build caches per package.
- Base `tsconfig.base.json` extended by packages.

**ESM vs CJS:**
- Node ecosystem is moving to ESM. Set `"module": "NodeNext", "moduleResolution": "NodeNext"` for pure ESM.
- Trade-off: ESM requires explicit file extensions in relative imports (`import { x } from "./utils.js"`).

## 6. Interview Questions

### Question 1: Type vs Interface
**What the interviewer is testing:** Understanding of TS fundamentals and compiler behavior.
**Short answer:** They are mostly interchangeable, but `type` can represent unions/primitives, while `interface` supports declaration merging and is often slightly faster for the TS compiler to cache.
**Detailed answer:** Interfaces are strictly for object shapes. They remain open, meaning multiple declarations of the same interface will merge. Types are closed and can represent any valid TS type (unions, mapped types).
**Strong Technical Lead answer:** "In our style guide, we mandate `interface` for public API contracts and domain models to leverage declaration merging for module augmentation (e.g., extending Express Request). We use `type` aliases for unions, mapped types, and utility types. Furthermore, interfaces offer slightly better compiler performance in huge codebases due to how TS caches structural checks."

### Question 2: Handling Any vs Unknown
**What the interviewer is testing:** Safe handling of dynamic payloads.
**Strong Technical Lead answer:** "`any` disables the type checker entirely—it's a virus that spreads through the codebase. I ban `any` using ESLint. `unknown` is the type-safe counterpart. It forces developers to perform type narrowing (using `typeof`, `instanceof`, or Zod schemas) before operating on the value. For legacy code migrations, we might temporarily use `any`, but strict PR policies prevent new ones."
