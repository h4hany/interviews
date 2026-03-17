# TypeScript Interview Questions

## 1. What is TypeScript?

**Answer:**
TypeScript is a statically typed superset of JavaScript that compiles to plain JavaScript. It adds optional type annotations, interfaces, classes, and other features to JavaScript.

## 2. What are the benefits of TypeScript over JavaScript?

**Answer:**
- **Type Safety**: Catches errors at compile time
- **Better IDE Support**: Autocomplete, refactoring, navigation
- **Documentation**: Types serve as documentation
- **Refactoring**: Safer refactoring with type checking
- **Early Error Detection**: Finds bugs before runtime
- **Better for Large Projects**: Easier to maintain

## 3. What is the difference between TypeScript and JavaScript?

**Answer:**

| Feature | JavaScript | TypeScript |
|---------|------------|------------|
| **Type System** | Dynamic (runtime) | Static (compile-time) |
| **Type Checking** | No | Yes |
| **Compilation** | Direct execution | Compiles to JavaScript |
| **File Extension** | .js | .ts |
| **Error Detection** | Runtime | Compile-time |

## 4. What are the basic data types in TypeScript?

**Answer:**
TypeScript includes all JavaScript types plus additional ones:

**Primitive Types:**
- `number`: Numbers (integers and floats)
- `string`: Text
- `boolean`: True/false
- `null`: Null value
- `undefined`: Undefined value
- `symbol`: Unique identifier

**Additional Types:**
- `any`: Any type (disables type checking)
- `void`: No return value
- `never`: Value that never occurs
- `unknown`: Type-safe alternative to any
- `object`: Non-primitive type

**Example:**
```typescript
let age: number = 30;
let name: string = "John";
let isActive: boolean = true;
let data: any = "can be anything";
let value: unknown = "unknown type";
```

## 5. What is the difference between `any` and `unknown`?

**Answer:**

| Feature | `any` | `unknown` |
|---------|-------|-----------|
| **Type Checking** | Disabled | Enabled (must check before use) |
| **Assignment** | Can assign to anything | Cannot assign without type assertion |
| **Method Calls** | Allowed | Not allowed without type check |
| **Safety** | Unsafe | Type-safe |

**Example:**
```typescript
let value1: any = "hello";
value1.toUpperCase();  // OK (no type checking)

let value2: unknown = "hello";
// value2.toUpperCase();  // Error: must check type first
if (typeof value2 === "string") {
    value2.toUpperCase();  // OK after type check
}
```

## 6. What is type inference in TypeScript?

**Answer:**
Type inference allows TypeScript to automatically determine the type of a variable based on its value.

**Example:**
```typescript
// TypeScript infers number
let age = 30;  // type: number

// TypeScript infers string
let name = "John";  // type: string

// TypeScript infers array type
let numbers = [1, 2, 3];  // type: number[]

// Explicit type annotation
let count: number = 10;  // explicit type
```

## 7. What is a type annotation?

**Answer:**
Type annotation explicitly specifies the type of a variable, parameter, or return value.

**Example:**
```typescript
// Variable annotation
let age: number = 30;

// Function parameter and return annotation
function add(a: number, b: number): number {
    return a + b;
}

// Array annotation
let numbers: number[] = [1, 2, 3];

// Object annotation
let user: { name: string; age: number } = {
    name: "John",
    age: 30
};
```

## 8. What is an interface in TypeScript?

**Answer:**
An interface defines the structure of an object, specifying what properties and methods it should have.

**Example:**
```typescript
interface User {
    id: number;
    name: string;
    email: string;
    age?: number;  // Optional property
}

// Use interface
let user: User = {
    id: 1,
    name: "John",
    email: "john@example.com"
    // age is optional, can omit
};

// Interface with methods
interface Calculator {
    add(a: number, b: number): number;
    subtract(a: number, b: number): number;
}
```

## 9. What is the difference between interface and type?

**Answer:**

| Feature | Interface | Type |
|---------|-----------|------|
| **Extends** | `extends` keyword | Intersection (`&`) |
| **Merging** | Can be merged (declaration merging) | Cannot be merged |
| **Use Case** | Object shapes | Unions, intersections, primitives |
| **Computed Properties** | Not supported | Supported |

**Example:**
```typescript
// Interface
interface User {
    name: string;
}

// Can extend interface
interface Admin extends User {
    role: string;
}

// Type
type Status = "active" | "inactive" | "pending";

// Union types
type ID = number | string;

// Interface merging
interface Window {
    customProperty: string;
}
interface Window {
    anotherProperty: number;
}
// Merged into one interface
```

## 10. What are union types in TypeScript?

**Answer:**
Union types allow a value to be one of several types.

**Example:**
```typescript
// Union of types
let id: number | string;
id = 123;      // OK
id = "abc";    // OK
// id = true;  // Error

// Union in function
function printId(id: number | string) {
    if (typeof id === "string") {
        console.log(id.toUpperCase());
    } else {
        console.log(id);
    }
}

// Union of literal types
type Status = "pending" | "approved" | "rejected";
let status: Status = "pending";
```

## 11. What are intersection types in TypeScript?

**Answer:**
Intersection types combine multiple types into one, requiring the value to satisfy all types.

**Example:**
```typescript
interface Person {
    name: string;
    age: number;
}

interface Employee {
    employeeId: number;
    department: string;
}

// Intersection: must have both Person and Employee properties
type Staff = Person & Employee;

let staff: Staff = {
    name: "John",
    age: 30,
    employeeId: 123,
    department: "Engineering"
};
```

## 12. What are generics in TypeScript?

**Answer:**
Generics allow you to create reusable components that work with multiple types.

**Example:**
```typescript
// Generic function
function identity<T>(arg: T): T {
    return arg;
}

let output1 = identity<string>("hello");  // type: string
let output2 = identity<number>(123);       // type: number

// Generic interface
interface Box<T> {
    value: T;
}

let stringBox: Box<string> = { value: "hello" };
let numberBox: Box<number> = { value: 123 };

// Generic class
class Container<T> {
    private items: T[] = [];
    
    add(item: T) {
        this.items.push(item);
    }
    
    get(index: number): T {
        return this.items[index];
    }
}
```

## 13. What is a tuple in TypeScript?

**Answer:**
A tuple is an array with a fixed number of elements, where each element has a specific type.

**Example:**
```typescript
// Tuple: fixed length, specific types
let person: [string, number] = ["John", 30];

// Access elements
let name = person[0];  // string
let age = person[1];   // number

// Tuple with optional elements
let optionalTuple: [string, number?] = ["John"];

// Named tuple (TypeScript 4.0+)
let namedTuple: [name: string, age: number] = ["John", 30];
```

## 14. What is an enum in TypeScript?

**Answer:**
An enum is a way to define a set of named constants.

**Example:**
```typescript
// Numeric enum
enum Status {
    Pending,    // 0
    Approved,   // 1
    Rejected    // 2
}

let status: Status = Status.Approved;

// String enum
enum Direction {
    Up = "UP",
    Down = "DOWN",
    Left = "LEFT",
    Right = "RIGHT"
}

// Const enum (inlined at compile time)
const enum Size {
    Small,
    Medium,
    Large
}
```

## 15. What is the difference between `const` and `readonly`?

**Answer:**

| Feature | `const` | `readonly` |
|---------|---------|------------|
| **Scope** | Variable | Property |
| **Reassignment** | Cannot reassign variable | Cannot reassign property |
| **Use Case** | Variables, arrays, objects | Class/interface properties |

**Example:**
```typescript
// const: cannot reassign
const name = "John";
// name = "Jane";  // Error

const arr = [1, 2, 3];
arr.push(4);  // OK (modifying array)
// arr = [];  // Error (reassigning)

// readonly: cannot reassign property
class User {
    readonly id: number;
    readonly name: string;
    
    constructor(id: number, name: string) {
        this.id = id;
        this.name = name;
    }
}

let user = new User(1, "John");
// user.name = "Jane";  // Error
```

## 16. What is type assertion in TypeScript?

**Answer:**
Type assertion tells TypeScript to treat a value as a specific type (you know more than TypeScript).

**Example:**
```typescript
// Angle bracket syntax
let value: any = "hello";
let strLength: number = (<string>value).length;

// As syntax (preferred in JSX)
let strLength2: number = (value as string).length;

// Assertion with unknown
let unknownValue: unknown = "hello";
let str = (unknownValue as string).toUpperCase();
```

## 17. What is a class in TypeScript?

**Answer:**
TypeScript classes support access modifiers, abstract classes, and more features than JavaScript classes.

**Example:**
```typescript
class User {
    // Public (default)
    public name: string;
    
    // Private
    private id: number;
    
    // Protected
    protected email: string;
    
    // Readonly
    readonly createdAt: Date;
    
    constructor(name: string, id: number, email: string) {
        this.name = name;
        this.id = id;
        this.email = email;
        this.createdAt = new Date();
    }
    
    // Public method
    public getName(): string {
        return this.name;
    }
    
    // Private method
    private getId(): number {
        return this.id;
    }
}
```

## 18. What are access modifiers in TypeScript?

**Answer:**
Access modifiers control the visibility of class members:
- **`public`**: Accessible everywhere (default)
- **`private`**: Accessible only within the class
- **`protected`**: Accessible within class and subclasses

**Example:**
```typescript
class Base {
    public publicProp = "public";
    private privateProp = "private";
    protected protectedProp = "protected";
}

class Derived extends Base {
    test() {
        this.publicProp;      // OK
        // this.privateProp;  // Error
        this.protectedProp;   // OK (subclass)
    }
}
```

## 19. What is an abstract class in TypeScript?

**Answer:**
An abstract class cannot be instantiated directly and may contain abstract methods that must be implemented by subclasses.

**Example:**
```typescript
abstract class Animal {
    abstract makeSound(): void;  // Must be implemented
    
    move(): void {
        console.log("Moving...");
    }
}

class Dog extends Animal {
    makeSound(): void {
        console.log("Woof!");
    }
}

// let animal = new Animal();  // Error: cannot instantiate abstract class
let dog = new Dog();  // OK
```

## 20. What is method overloading in TypeScript?

**Answer:**
Method overloading allows a function to have multiple signatures with different parameter types.

**Example:**
```typescript
function add(a: number, b: number): number;
function add(a: string, b: string): string;
function add(a: any, b: any): any {
    return a + b;
}

add(1, 2);        // Returns number
add("a", "b");   // Returns string
```

## 21. What is a namespace in TypeScript?

**Answer:**
A namespace is a way to organize code and avoid naming conflicts.

**Example:**
```typescript
namespace MathUtils {
    export function add(a: number, b: number): number {
        return a + b;
    }
    
    export function multiply(a: number, b: number): number {
        return a * b;
    }
}

MathUtils.add(1, 2);
```

## 22. What are decorators in TypeScript?

**Answer:**
Decorators are a special kind of declaration that can be attached to classes, methods, properties, etc. (experimental feature).

**Example:**
```typescript
// Enable decorators in tsconfig.json: "experimentalDecorators": true

function log(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const original = descriptor.value;
    descriptor.value = function(...args: any[]) {
        console.log(`Calling ${propertyKey}`);
        return original.apply(this, args);
    };
}

class Calculator {
    @log
    add(a: number, b: number): number {
        return a + b;
    }
}
```

## 23. What is the difference between `interface` and `class`?

**Answer:**

| Feature | Interface | Class |
|---------|-----------|-------|
| **Compilation** | Removed (no JS output) | Compiled to JS |
| **Implementation** | Cannot have implementation | Can have implementation |
| **Instantiation** | Cannot instantiate | Can instantiate |
| **Use Case** | Contracts, shapes | Implementation, behavior |

## 24. What are utility types in TypeScript?

**Answer:**
Utility types are built-in generic types that help manipulate types.

**Common Utility Types:**
- **`Partial<T>`**: Makes all properties optional
- **`Required<T>`**: Makes all properties required
- **`Readonly<T>`**: Makes all properties readonly
- **`Pick<T, K>`**: Selects specific properties
- **`Omit<T, K>`**: Removes specific properties
- **`Record<K, V>`**: Creates object type with keys K and values V

**Example:**
```typescript
interface User {
    id: number;
    name: string;
    email: string;
}

// Partial: all optional
type PartialUser = Partial<User>;
// { id?: number; name?: string; email?: string; }

// Required: all required
type RequiredUser = Required<PartialUser>;

// Pick: select properties
type UserPreview = Pick<User, "id" | "name">;
// { id: number; name: string; }

// Omit: remove properties
type UserWithoutEmail = Omit<User, "email">;
// { id: number; name: string; }

// Record: create object type
type UserMap = Record<string, User>;
// { [key: string]: User }
```

## 25. What is `keyof` in TypeScript?

**Answer:**
`keyof` is an operator that returns a union of all property names of a type.

**Example:**
```typescript
interface User {
    id: number;
    name: string;
    email: string;
}

type UserKeys = keyof User;  // "id" | "name" | "email"

function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
    return obj[key];
}

let user: User = { id: 1, name: "John", email: "john@example.com" };
let name = getProperty(user, "name");  // Type-safe!
```

## 26. What is `typeof` in TypeScript?

**Answer:**
`typeof` operator gets the type of a value or variable.

**Example:**
```typescript
let user = {
    id: 1,
    name: "John"
};

// typeof gets the type
type UserType = typeof user;
// { id: number; name: string; }

// Use with functions
function createUser() {
    return { id: 1, name: "John" };
}

type ReturnType = typeof createUser;  // Function type
type User = ReturnType<typeof createUser>;  // Return value type
```

## 27. What is `infer` in TypeScript?

**Answer:**
`infer` is used in conditional types to infer types from other types.

**Example:**
```typescript
// Extract return type
type ReturnType<T> = T extends (...args: any[]) => infer R ? R : never;

function getString(): string {
    return "hello";
}

type StringReturn = ReturnType<typeof getString>;  // string

// Extract array element type
type ArrayElement<T> = T extends (infer U)[] ? U : never;
type NumberArray = ArrayElement<number[]>;  // number
```

## 28. What are conditional types in TypeScript?

**Answer:**
Conditional types select one of two types based on a condition.

**Example:**
```typescript
type IsArray<T> = T extends any[] ? true : false;

type Test1 = IsArray<number[]>;    // true
type Test2 = IsArray<string>;      // false

// Non-nullable type
type NonNullable<T> = T extends null | undefined ? never : T;

type Test3 = NonNullable<string | null>;  // string
```

## 29. What is module resolution in TypeScript?

**Answer:**
Module resolution is how TypeScript resolves import statements to files.

**Strategies:**
- **`classic`**: Legacy resolution (not recommended)
- **`node`**: Node.js resolution (default)
- **`bundler`**: For bundlers like webpack

**Example:**
```json
// tsconfig.json
{
    "compilerOptions": {
        "moduleResolution": "node"  // or "bundler"
    }
}
```

## 30. What is the difference between `import` and `import type`?

**Answer:**

| Feature | `import` | `import type` |
|---------|----------|---------------|
| **Runtime** | Included in output | Removed (type-only) |
| **Use Case** | Values and types | Types only |
| **Tree Shaking** | May include code | Always removed |

**Example:**
```typescript
// Regular import (may include runtime code)
import { User, createUser } from "./user";

// Type-only import (removed at compile time)
import type { User } from "./user";
import { createUser } from "./user";
```

## 31. What is a declaration file (.d.ts)?

**Answer:**
Declaration files provide type information for JavaScript libraries that don't have TypeScript types.

**Example:**
```typescript
// my-library.d.ts
declare module "my-library" {
    export function doSomething(): void;
    export interface Config {
        apiKey: string;
    }
}

// Usage
import { doSomething } from "my-library";
```

## 32. What is `strict` mode in TypeScript?

**Answer:**
Strict mode enables all strict type checking options for maximum type safety.

**Options:**
- `strictNullChecks`: Null and undefined are separate types
- `strictFunctionTypes`: Stricter function type checking
- `strictPropertyInitialization`: Properties must be initialized
- `noImplicitAny`: Error on implicit any
- `noImplicitThis`: Error on implicit this

**Example:**
```json
// tsconfig.json
{
    "compilerOptions": {
        "strict": true  // Enables all strict checks
    }
}
```

## 33. What is the difference between `==` and `===` in TypeScript?

**Answer:**
Same as JavaScript:
- **`==`**: Loose equality (type coercion)
- **`===`**: Strict equality (no type coercion)

**TypeScript encourages `===` for type safety.**

## 34. What are mapped types in TypeScript?

**Answer:**
Mapped types create new types by transforming properties of existing types.

**Example:**
```typescript
interface User {
    id: number;
    name: string;
    email: string;
}

// Make all properties optional
type Optional<T> = {
    [P in keyof T]?: T[P];
};

type OptionalUser = Optional<User>;
// { id?: number; name?: string; email?: string; }

// Make all properties readonly
type Readonly<T> = {
    readonly [P in keyof T]: T[P];
};
```

## 35. What is `this` typing in TypeScript?

**Answer:**
`this` typing allows you to specify the type of `this` in functions and methods.

**Example:**
```typescript
class Calculator {
    value = 0;
    
    add(this: Calculator, n: number): Calculator {
        this.value += n;
        return this;  // Enables method chaining
    }
    
    multiply(this: Calculator, n: number): Calculator {
        this.value *= n;
        return this;
    }
}

let calc = new Calculator();
calc.add(5).multiply(2);  // Method chaining
```

## 36. What is a type guard in TypeScript?

**Answer:**
A type guard narrows the type within a conditional block.

**Example:**
```typescript
// typeof type guard
function isString(value: unknown): value is string {
    return typeof value === "string";
}

function process(value: unknown) {
    if (isString(value)) {
        // TypeScript knows value is string here
        value.toUpperCase();
    }
}

// instanceof type guard
class Dog {
    bark() {}
}

function isDog(animal: any): animal is Dog {
    return animal instanceof Dog;
}
```

## 37. What is the difference between `let`, `const`, and `var` in TypeScript?

**Answer:**
Same as JavaScript, but with type checking:
- **`var`**: Function-scoped, hoisted
- **`let`**: Block-scoped, not hoisted
- **`const`**: Block-scoped, cannot reassign

**TypeScript encourages `const` and `let`, discourages `var`.**

## 38. What are rest parameters in TypeScript?

**Answer:**
Rest parameters allow functions to accept an indefinite number of arguments.

**Example:**
```typescript
function sum(...numbers: number[]): number {
    return numbers.reduce((a, b) => a + b, 0);
}

sum(1, 2, 3, 4);  // 10

// With type safety
function createUser(name: string, ...roles: string[]): User {
    return { name, roles };
}
```

## 39. What are default parameters in TypeScript?

**Answer:**
Default parameters provide default values for function parameters.

**Example:**
```typescript
function greet(name: string = "Guest"): string {
    return `Hello, ${name}!`;
}

greet();           // "Hello, Guest!"
greet("John");     // "Hello, John!"

// With type annotation
function multiply(a: number, b: number = 1): number {
    return a * b;
}
```

## 40. What is the difference between `null` and `undefined` in TypeScript?

**Answer:**

| Feature | `null` | `undefined` |
|---------|--------|-------------|
| **Type** | `null` type | `undefined` type |
| **Intent** | Explicitly no value | Value not assigned |
| **Use Case** | Intentional absence | Uninitialized |

**Example:**
```typescript
let value1: string | null = null;        // Explicitly null
let value2: string | undefined;          // Undefined (not assigned)

// With strictNullChecks
function process(value: string | null | undefined) {
    if (value !== null && value !== undefined) {
        // TypeScript knows value is string here
        value.toUpperCase();
    }
}
```

## 41. What is a namespace vs module in TypeScript?

**Answer:**

| Feature | Namespace | Module |
|---------|-----------|--------|
| **Organization** | Internal organization | External organization |
| **File** | Can span multiple files | One file per module |
| **Use Case** | Legacy code, internal | Modern, external |
| **Import** | `/// <reference>` | `import/export` |

**Example:**
```typescript
// Namespace (legacy)
namespace MyApp {
    export class User {}
}

// Module (modern)
// user.ts
export class User {}

// app.ts
import { User } from "./user";
```

## 42. What is declaration merging in TypeScript?

**Answer:**
Declaration merging allows multiple declarations with the same name to be merged into one.

**Example:**
```typescript
// Interface merging
interface User {
    name: string;
}
interface User {
    age: number;
}
// Merged: { name: string; age: number; }

// Namespace merging
namespace MyApp {
    export function func1() {}
}
namespace MyApp {
    export function func2() {}
}
// Merged namespace has both func1 and func2
```

## 43. What is a type alias?

**Answer:**
A type alias creates a new name for a type.

**Example:**
```typescript
// Simple type alias
type ID = number;
type Name = string;

// Complex type alias
type User = {
    id: ID;
    name: Name;
    email: string;
};

// Union type alias
type Status = "pending" | "approved" | "rejected";

// Function type alias
type Handler = (event: Event) => void;
```

## 44. What is the difference between `interface` extending and type intersection?

**Answer:**

| Feature | Interface Extend | Type Intersection |
|---------|------------------|-------------------|
| **Syntax** | `extends` | `&` |
| **Merging** | Can merge | Cannot merge |
| **Error Messages** | Better | Can be complex |

**Example:**
```typescript
// Interface extend
interface A {
    a: string;
}
interface B extends A {
    b: number;
}

// Type intersection
type A = { a: string };
type B = A & { b: number };
```

## 45. What are template literal types?

**Answer:**
Template literal types allow you to create string types using template literal syntax.

**Example:**
```typescript
type EventName<T extends string> = `on${Capitalize<T>}`;

type ClickEvent = EventName<"click">;  // "onClick"
type ChangeEvent = EventName<"change">;  // "onChange"

// Complex example
type ApiEndpoint = `api/${string}/${string}`;
let endpoint: ApiEndpoint = "api/users/123";  // OK
```

## 46. What is `satisfies` operator in TypeScript?

**Answer:**
The `satisfies` operator (TypeScript 4.9+) ensures a value matches a type without changing the inferred type.

**Example:**
```typescript
const config = {
    apiUrl: "https://api.example.com",
    timeout: 5000
} satisfies Config;

// Type is inferred as { apiUrl: string; timeout: number }
// But also satisfies Config interface
```

## 47. What is the difference between `private` and `#` private fields?

**Answer:**

| Feature | `private` | `#` (Private Fields) |
|---------|-----------|---------------------|
| **Standard** | TypeScript-only | JavaScript standard |
| **Runtime** | No runtime enforcement | Runtime enforcement |
| **Compilation** | Removed (public in JS) | Preserved in JS |

**Example:**
```typescript
class User {
    private id: number;        // TypeScript-only
    #email: string;            // JavaScript private field
    
    constructor(id: number, email: string) {
        this.id = id;
        this.#email = email;
    }
}
```

## 48. What is `readonly` modifier?

**Answer:**
The `readonly` modifier prevents reassignment of properties.

**Example:**
```typescript
interface User {
    readonly id: number;
    name: string;
}

let user: User = { id: 1, name: "John" };
// user.id = 2;  // Error: cannot assign to readonly
user.name = "Jane";  // OK

// Readonly array
let numbers: readonly number[] = [1, 2, 3];
// numbers.push(4);  // Error
// numbers[0] = 10;  // Error
```

## 49. What is type narrowing?

**Answer:**
Type narrowing is when TypeScript infers a more specific type based on control flow analysis.

**Example:**
```typescript
function process(value: string | number) {
    if (typeof value === "string") {
        // TypeScript narrows to string
        value.toUpperCase();
    } else {
        // TypeScript narrows to number
        value.toFixed(2);
    }
}

// Discriminated unions
type Circle = { kind: "circle"; radius: number };
type Square = { kind: "square"; side: number };
type Shape = Circle | Square;

function area(shape: Shape): number {
    if (shape.kind === "circle") {
        // TypeScript knows it's Circle
        return Math.PI * shape.radius ** 2;
    } else {
        // TypeScript knows it's Square
        return shape.side ** 2;
    }
}
```

## 50. What is the `as const` assertion?

**Answer:**
`as const` makes a value deeply readonly and infers the most specific type possible.

**Example:**
```typescript
// Without as const
let colors = ["red", "green", "blue"];
// Type: string[]

// With as const
let colors = ["red", "green", "blue"] as const;
// Type: readonly ["red", "green", "blue"]

// Object as const
const config = {
    apiUrl: "https://api.example.com",
    timeout: 5000
} as const;
// All properties are readonly and literal types
```

## Summary

TypeScript adds static typing to JavaScript, providing:
- Type safety and early error detection
- Better IDE support and tooling
- Advanced type features (generics, utility types, conditional types)
- Gradual adoption (can use JavaScript in TypeScript)
- Compile-time checks without runtime overhead


