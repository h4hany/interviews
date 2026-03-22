# .NET / C# Interview Questions

## 1. What is .NET?

**Answer:**
.NET is a free, cross-platform, open-source developer platform for building applications. It supports multiple languages (C#, F#, VB.NET) and runs on Windows, Linux, and macOS.

## 2. What is the difference between .NET Framework and .NET Core/.NET?

**Answer:**
- **.NET Framework**: Windows-only, older, monolithic.
- **.NET Core/.NET**: Cross-platform, modular, open-source, faster, modern.

## 3. What is C#?

**Answer:**
C# is a modern, object-oriented programming language developed by Microsoft, part of the .NET ecosystem.

## 4. What is the difference between `value types` and `reference types` in C#?

**Answer:**
- **Value Types**: Stored on stack, copied when assigned.
- **Reference Types**: Stored on heap, reference copied.

> [!TIP]
> **Antigravity Tip**: For extremely high-performance scenarios (like BrandOS's real-time price engine), use **`Span<T>`** or **`Memory<T>`**. These allow you to work with slices of memory without allocating new objects on the heap, significantly reducing Garbage Collection pressure and avoiding the cost of copying large value types.

## 5. What is the difference between `struct` and `class` in C#?

**Answer:**
- **Struct**: Value type, stack allocation, no inheritance, no null (unless nullable).
- **Class**: Reference type, heap allocation, supports inheritance, can be null.

## 6. What is boxing and unboxing in C#?

**Answer:**
- **Boxing**: Converting value type to object (heap allocation).
- **Unboxing**: Converting object back to value type (explicit cast).

### Example:
```csharp
int i = 123;
object o = i;        // Boxing
int j = (int)o;      // Unboxing
```

## 7. What is the difference between `==` and `Equals()` in C#?

**Answer:**
- **`==`**: Compares references for reference types, values for value types.
- **`Equals()`**: Can be overridden, compares values based on implementation.

## 8. What is the difference between `string` and `StringBuilder`?

**Answer:**
- **`string`**: Immutable, creates new object on each modification.
- **`StringBuilder`**: Mutable, efficient for concatenation.

> [!TIP]
> **Antigravity Tip**: If you are building a string within a single method and performance is critical, consider **`stackalloc`** with a `Span<char>` for small strings. For large-scale concatenation across many methods, `StringBuilder` is standard, but always initialize it with an estimated capacity to avoid multiple internal buffer resizes.

## 9. What are access modifiers in C#?

**Answer:**
- **`public`**: Accessible everywhere.
- **`private`**: Accessible only within the class.
- **`protected`**: Accessible within class and derived classes.
- **`internal`**: Accessible within the same assembly.
- **`protected internal`**: Accessible within assembly or derived classes.

## 10. What is the difference between `abstract` and `interface`?

**Answer:**
- **Abstract Class**: Can have implementation, single inheritance, can have fields.
- **Interface**: No implementation (until C# 8.0), multiple inheritance, no fields (until C# 8.0).

## 11. What is the difference between `virtual` and `abstract` methods?

**Answer:**
- **`virtual`**: Can be overridden, has default implementation.
- **`abstract`**: Must be overridden, no implementation in base class.

## 12. What is `async` and `await` in C#?

**Answer:**
`async`/`await` enables asynchronous programming, allowing non-blocking execution of code.

### Example:
```csharp
async Task<string> GetDataAsync()
{
    await Task.Delay(1000);
    return "Data";
}
```

## 13. What is the difference between `Task` and `Task<T>`?

**Answer:**
- **`Task`**: Represents an asynchronous operation that doesn't return a value.
- **`Task<T>`**: Represents an asynchronous operation that returns a value of type T.

## 14. What is the difference between `async void` and `async Task`?

**Answer:**
- **`async void`**: Fire-and-forget, exceptions can't be caught (avoid except event handlers).
- **`async Task`**: Proper async method, exceptions can be caught.

## 15. What is LINQ?

**Answer:**
LINQ (Language Integrated Query) provides query capabilities directly in C#.
- *Example*: Finding all "VIP" customers from a list of 10,000 users: `users.Where(u => u.IsVip).ToList()`. This is much more readable than writing nested `foreach` loops.

### Example:
```csharp
var result = from x in numbers
             where x > 5
             select x * 2;
```

## 16. What is the difference between `IEnumerable` and `IQueryable`?

**Answer:**
- **`IEnumerable`**: In-memory queries, executes immediately.
- **`IQueryable`**: Deferred execution, can be translated to SQL (for databases).

## 17. What is dependency injection in .NET?

**Answer:**
Dependency Injection is a design pattern where dependencies are provided to a class rather than created inside it, promoting loose coupling.

## 18. What is the difference between `AddSingleton`, `AddScoped`, and `AddTransient`?

**Answer:**
- **`AddSingleton`**: One instance for entire lifecycle.
- **`AddScoped`**: One instance per HTTP request.
- **`AddTransient`**: New instance every time.

> [!TIP]
> **Antigravity Tip**: Watch out for **Captive Dependencies**. This happens when you inject a **Scoped** service into a **Singleton** service. Since the Singleton lives forever, the Scoped service (like a DB context) will also live forever, which can cause memory leaks or "DbContext was disposed" errors. .NET Core's default provider checks for this in 'Development' mode, but be vigilant in production.

## 19. What is Entity Framework?

**Answer:**
Entity Framework is an ORM (Object-Relational Mapping) framework that enables .NET developers to work with databases using .NET objects.

## 20. What is the difference between `IEnumerable`, `ICollection`, and `IList`?

**Answer:**
- **`IEnumerable`**: Basic iteration, read-only.
- **`ICollection`**: Adds Count, Add, Remove, Clear.
- **`IList`**: Adds indexing, Insert, RemoveAt.

## 21. What is garbage collection in .NET?

**Answer:**
Garbage Collection automatically manages memory by reclaiming memory from objects that are no longer referenced.

## 22. What is the difference between `using` statement and `IDisposable`?

**Answer:**
- **`using` statement**: Ensures `Dispose()` is called, even if exception occurs.
- **`IDisposable`**: Interface for releasing unmanaged resources.

## 23. What is the difference between `ref` and `out` parameters?

**Answer:**
- **`ref`**: Parameter must be initialized before passing.
- **`out`**: Parameter doesn't need initialization, must be assigned in method.

## 24. What is `yield return` in C#?

**Answer:**
`yield return` creates an iterator, enabling lazy evaluation and memory-efficient iteration.

### Example:
```csharp
IEnumerable<int> GetNumbers()
{
    for (int i = 0; i < 10; i++)
        yield return i;
}
```

## 25. What is the difference between `throw` and `throw ex`?

**Answer:**
- **`throw`**: Preserves stack trace.
- **`throw ex`**: Resets stack trace (loses original exception info).

## 26. What is ASP.NET Core?

**Answer:**
ASP.NET Core is a cross-platform, high-performance web framework for building modern web applications and APIs.

## 27. What is middleware in ASP.NET Core?

**Answer:**
Middleware are components that form a pipeline to handle requests and responses. They execute in sequence.

## 28. What is the difference between `Use`, `Run`, and `Map` in middleware?

**Answer:**
- **`Use`**: Adds middleware to pipeline (can call next).
- **`Run`**: Terminal middleware (doesn't call next).
- **`Map`**: Branches pipeline based on path.

## 29. What is the difference between `AddMvc` and `AddControllers`?

**Answer:**
- **`AddMvc`**: Adds full MVC with views, Razor Pages.
- **`AddControllers`**: Adds only API controllers (lighter, for APIs).

## 30. What is the difference between `ActionResult` and `IActionResult`?

**Answer:**
- **`ActionResult`**: Concrete class, specific return type.
- **`IActionResult`**: Interface, can return various types (Ok, BadRequest, etc.).

## 31. What is attribute routing in ASP.NET Core?

**Answer:**
Attribute routing allows defining routes using attributes on controllers and actions.

### Example:
```csharp
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    [HttpGet("{id}")]
    public IActionResult Get(int id) { }
}
```

## 32. What is the difference between `[FromBody]` and `[FromQuery]`?

**Answer:**
- **`[FromBody]`**: Binds from request body (JSON, XML).
- **`[FromQuery]`**: Binds from query string parameters.

## 33. What is model binding in ASP.NET Core?

**Answer:**
Model binding automatically maps HTTP request data to action method parameters.

## 34. What is validation in ASP.NET Core?

**Answer:**
Validation ensures data meets specified rules using data annotations or FluentValidation.

## 35. What is the difference between `ModelState.IsValid` and custom validation?

**Answer:**
- **`ModelState.IsValid`**: Checks data annotations validation.
- **Custom Validation**: Business logic validation beyond data annotations.

## 36. What is CORS in ASP.NET Core?

**Answer:**
CORS (Cross-Origin Resource Sharing) allows web pages to make requests to different domains.

## 37. What is authentication and authorization in ASP.NET Core?

**Answer:**
- **Authentication**: Verifying who the user is.
- **Authorization**: Determining what the user can do.

## 38. What is JWT in .NET?

**Answer:**
JWT (JSON Web Token) is a token-based authentication mechanism, commonly used in APIs.

## 39. What is the difference between `AddAuthentication` and `AddAuthorization`?

**Answer:**
- **`AddAuthentication`**: Configures authentication schemes.
- **`AddAuthorization`**: Configures authorization policies.

## 40. What is logging in .NET?

**Answer:**
.NET provides built-in logging through `ILogger` interface, supporting multiple log levels and providers.

## 41. What is the difference between `ILogger` and `ILogger<T>`?

**Answer:**
- **`ILogger`**: Generic logger.
- **`ILogger<T>`**: Typed logger (category is type name).

## 42. What is configuration in ASP.NET Core?

**Answer:**
Configuration system allows reading settings from various sources (appsettings.json, environment variables, etc.).

## 43. What is the difference between `IConfiguration` and `IOptions`?

**Answer:**
- **`IConfiguration`**: Raw configuration access.
- **`IOptions<T>`**: Strongly-typed configuration with validation.

## 44. What is health checks in ASP.NET Core?

**Answer:**
Health checks monitor application and dependency health, useful for load balancers and monitoring.

## 45. What is the difference between `AddDbContext` and `AddDbContextPool`?

**Answer:**
- **`AddDbContext`**: Creates new DbContext per request.
- **`AddDbContextPool`**: Reuses DbContext instances (better performance).

## 46. What is the difference between `FirstOrDefault` and `SingleOrDefault`?

**Answer:**
- **`FirstOrDefault`**: Returns first match or default (no exception if multiple).
- **`SingleOrDefault`**: Returns single match or default (throws if multiple).

## 47. What is the difference between `ToList` and `ToArray`?

**Answer:**
- **`ToList`**: Creates List<T> (mutable, better for adding items).
- **`ToArray`**: Creates array (immutable, fixed size).

## 48. What is the difference between `Any` and `Count`?

**Answer:**
- **`Any`**: Returns true if any element exists (stops at first match, efficient).
- **`Count`**: Counts all elements (must iterate all, less efficient for existence check).

## 49. What is the difference between `async` and `Task.Run`?

**Answer:**
- **`async`**: Non-blocking, uses existing thread pool.
- **`Task.Run`**: Offloads work to thread pool, can be used with sync code.

## 50. What is .NET performance best practices?

**Answer:**
- Use `StringBuilder` for string concatenation
- Avoid boxing/unboxing
- Use appropriate collection types
- Implement `IDisposable` correctly
- Use async/await properly
- Avoid blocking async code
- Use connection pooling
- Profile and measure


