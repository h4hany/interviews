# Java & Spring Boot Interview Questions & Answers (50+)

---

## Java fundamentals

### 1. What is the difference between JDK, JRE, and JVM?
**Answer:** **JVM** (Java Virtual Machine) runs bytecode. **JRE** (Java Runtime Environment) = JVM + core libraries; needed to run Java apps. **JDK** (Java Development Kit) = JRE + compiler (javac) and tools; needed to develop.

### 2. Explain the difference between `==` and `equals()` in Java.
**Answer:** `==` compares references (identity) for objects; for primitives it compares values. `equals()` is for logical equality; override it (and `hashCode()`) for your classes. Default `Object.equals()` is same as `==`.

### 3. What is the difference between `String`, `StringBuilder`, and `StringBuffer`?
**Answer:** **String** is immutable. **StringBuilder** is mutable, not thread-safe, use for single-threaded string building. **StringBuffer** is mutable and thread-safe (synchronized); use when shared across threads.

### 4. What are the main principles of OOP in Java?
**Answer:** Encapsulation (hide state, expose behavior), Inheritance (is-a, `extends`), Polymorphism (same interface, different behavior; overriding, overloading), Abstraction (interfaces, abstract classes).

### 5. Difference between abstract class and interface (before and after Java 8)?
**Answer:** Abstract class: can have state, constructors, and mixed abstract/concrete methods; single inheritance. Interface: contract only; before Java 8 only abstract methods; from Java 8 can have `default` and `static` methods; multiple inheritance. From Java 9 interfaces can have private methods.

### 6. What is the difference between `final`, `finally`, and `finalize`?
**Answer:** **final:** modifier for class (no subclass), method (no override), variable (no reassignment). **finally:** block that runs after try/catch (unless JVM exits). **finalize:** deprecated method on Object called by GC before collection; do not rely on it.

### 7. Explain Java’s access modifiers.
**Answer:** **private:** same class only. **default (package-private):** same package. **protected:** same package + subclasses. **public:** everywhere.

### 8. What is the difference between `throw` and `throws`?
**Answer:** **throws** declares that a method may throw checked exceptions; caller must handle or declare. **throw** actually throws an exception instance.

### 9. What are checked and unchecked exceptions?
**Answer:** **Checked:** extend `Exception` (not RuntimeException); must be caught or declared. **Unchecked:** extend `RuntimeException`; no mandate. Use checked for recoverable, caller-handled cases; unchecked for programming errors.

### 10. What is the difference between `ArrayList` and `LinkedList`?
**Answer:** **ArrayList:** resizable array; O(1) get/set, amortized O(1) add at end; slow add/remove in middle. **LinkedList:** doubly linked list; O(1) add/remove at ends; O(n) get by index. Prefer ArrayList for most list use cases.

---

## Java collections & generics

### 11. What is the difference between `HashMap` and `Hashtable`?
**Answer:** **HashMap:** allows null key/value (one null key), not thread-safe, preferred. **Hashtable:** no nulls, thread-safe (synchronized). For concurrent use prefer `ConcurrentHashMap`.

### 12. How does `HashMap` work internally?
**Answer:** Array of buckets; each bucket can be a list or (from Java 8) tree (if list size &gt; 8). Key’s `hashCode()` and then `equals()` determine bucket and key match. Load factor (default 0.75) triggers resize when exceeded.

### 13. What is the difference between `HashSet` and `TreeSet`?
**Answer:** **HashSet:** hash-based; O(1) add/contains; unordered. **TreeSet:** red-black tree; O(log n) add/contains; sorted by natural order or Comparator.

### 14. What is the difference between `Comparable` and `Comparator`?
**Answer:** **Comparable:** natural order; single method `compareTo(this, other)`; implement on the class. **Comparator:** external comparison; `compare(a, b)`; use for multiple orderings or when you can’t change the class.

### 15. What are generics and type erasure?
**Answer:** Generics provide compile-time type safety; type parameters are erased at runtime (replaced by Object or bounds). So you cannot do `new T()` or get `T.class` at runtime.

---

## Java concurrency

### 16. What is the difference between `Thread` and `Runnable`?
**Answer:** **Runnable** is an interface (one method `run()`); preferred because you’re not using inheritance. **Thread** is a class that can take a Runnable; extending Thread ties your logic to one thread type.

### 17. What is the difference between `synchronized` and `ReentrantLock`?
**Answer:** **synchronized:** keyword; automatic lock release; no fairness or tryLock. **ReentrantLock:** explicit lock; can be fair, tryLock, multiple conditions; more control.

### 18. What is the volatile keyword?
**Answer:** Guarantees visibility of writes across threads (no caching in CPU). Does not guarantee atomicity (e.g. i++ still needs synchronization or AtomicInteger).

### 19. What is the difference between `wait()` and `sleep()`?
**Answer:** **wait():** on Object; releases monitor; must be in synchronized block; another thread calls `notify()`/`notifyAll()`. **sleep():** on Thread; does not release lock; just pauses for time.

### 20. What is the Executor framework?
**Answer:** `Executor`, `ExecutorService`, `ThreadPoolExecutor` for managing thread pools. Submit tasks (Runnable/Callable); get Futures; control lifecycle (shutdown, awaitTermination). Prefer over raw Threads.

### 21. What is the difference between `CyclicBarrier` and `CountDownLatch`?
**Answer:** **CountDownLatch:** one-shot; threads await until count reaches zero. **CyclicBarrier:** reusable; N threads wait at barrier until all arrive, then all proceed.

### 22. What is `ConcurrentHashMap` and how does it allow concurrent access?
**Answer:** Thread-safe HashMap; segments or (in Java 8+) CAS + synchronized on bucket; allows concurrent reads and limited concurrent writes without locking the whole map.

---

## Spring Boot basics

### 23. What is Spring Boot and why use it?
**Answer:** Opinionated framework on top of Spring; auto-configuration, embedded server, starter dependencies, production-ready features (actuator, metrics). Reduces boilerplate and gets an app running quickly.

### 24. What is dependency injection (DI) and inversion of control (IoC)?
**Answer:** **IoC:** framework controls flow and creates/manages objects. **DI:** dependencies are injected (constructor/setter/field) instead of created inside the class. Enables loose coupling and testability.

### 25. What are the different types of dependency injection in Spring?
**Answer:** Constructor (preferred; required dependencies, immutability), setter (optional), field (not recommended; hard to test). Constructor injection is the default in Spring’s recommendation.

### 26. What is the difference between `@Component`, `@Service`, `@Repository`, and `@Controller`?
**Answer:** All are stereotypes that register a bean. **@Repository:** persistence; exception translation. **@Service:** business logic. **@Controller:** web MVC controller. **@Component:** generic. They differ mainly in semantics and some special handling.

### 27. What is the difference between `@Autowired` and constructor injection?
**Answer:** Constructor injection: explicit, immutable, required; no need for `@Autowired` on single constructor. Field/setter `@Autowired` is implicit and optional; harder to test and can create circular dependency issues.

### 28. What is a Spring Bean and what is the Bean lifecycle?
**Answer:** Bean = object managed by Spring container. Lifecycle: instantiation → population of properties → BeanNameAware → BeanFactoryAware → Pre-initialization (BeanPostProcessor) → InitializingBean / @PostConstruct → custom init → Post-initialization → ready → (container shutdown) DisposableBean / @PreDestroy.

### 29. What is the difference between `@Configuration` and `@Component`?
**Answer:** **@Configuration:** class is a source of bean definitions; `@Bean` methods are proxied so calling them returns the same singleton. **@Component:** class itself is a bean; no special handling of `@Bean` methods.

### 30. What is the default scope of a Spring Bean? What other scopes exist?
**Answer:** Default is **singleton** (one per container). Others: **prototype** (new instance each time), request, session, application (Servlet), websocket. For web only: request, session, etc.

---

## Spring MVC & REST

### 31. What is the DispatcherServlet?
**Answer:** Front controller in Spring MVC; receives all requests, dispatches to handlers (controllers), resolves views, handles exceptions. Central entry point for web layer.

### 32. What is the difference between `@Controller` and `@RestController`?
**Answer:** **@Controller:** returns view names or ModelAndView unless method is annotated with @ResponseBody. **@RestController:** @Controller + @ResponseBody on every method; for REST APIs that return data (JSON/XML).

### 33. What is the difference between `@PathVariable` and `@RequestParam`?
**Answer:** **@PathVariable:** part of URL path (e.g. `/users/{id}`). **@RequestParam:** query parameter (e.g. `?page=1`).

### 34. How do you handle exceptions in Spring MVC?
**Answer:** **@ExceptionHandler** in a controller for that controller. **@ControllerAdvice** (or @RestControllerAdvice) for global handling. Return ResponseEntity or custom error DTO with status and body.

### 35. What is the purpose of `@Transactional`?
**Answer:** Declarative transaction management; method runs in a transaction (begin, commit/rollback on exception). Propagation (e.g. REQUIRED, REQUIRED_NEW) and isolation can be configured.

### 36. What is the difference between `@RequestParam` and `@RequestBody`?
**Answer:** **@RequestParam:** one or more query/form parameters. **@RequestBody:** deserializes request body (e.g. JSON) into an object.

---

## Spring Data & JPA

### 37. What is Spring Data JPA?
**Answer:** Abstraction over JPA; repository interfaces with method names or @Query for implementation. Reduces boilerplate (CRUD, pagination, custom queries).

### 38. What is the difference between `findById()` and `getOne()`?
**Answer:** **findById():** returns Optional; hits DB immediately. **getOne():** returns a lazy proxy; DB access when entity is first used. Prefer findById for simple lookups.

### 39. What is the N+1 problem and how do you fix it?
**Answer:** One query for a list, then N queries for associations (e.g. orders per user). Fix: **fetch join** (JPQL), **@EntityGraph**, or **@BatchSize**; or use DTOs/projections with a single query.

### 40. What is the difference between `CrudRepository` and `JpaRepository`?
**Answer:** **CrudRepository:** basic CRUD. **JpaRepository:** extends PagingAndSortingRepository and adds flush, batch delete, etc. Use JpaRepository when you need JPA-specific features.

### 41. How do you write a custom query in Spring Data JPA?
**Answer:** Method name (e.g. `findByStatusAndDate`), **@Query** (JPQL or native), or **Specification** for dynamic queries.

### 42. What is lazy vs eager loading?
**Answer:** **Eager:** association loaded with entity (can cause N+1 if many entities). **Lazy:** loaded when accessed (default for collections); can cause LazyInitializationException outside transaction. Use fetch join or DTO when you need associations.

---

## Spring Security

### 43. What is Spring Security and what does it provide?
**Answer:** Authentication (who you are) and authorization (what you can do). Provides filters, user details, password encoding, session management, method security, OAuth2/JWT support.

### 44. What is the difference between authentication and authorization?
**Answer:** **Authentication:** verifying identity (e.g. login). **Authorization:** verifying permission to access a resource (e.g. role-based, method-level).

### 45. How would you secure a REST API (e.g. with JWT)?
**Answer:** Stateless: client sends JWT in header; filter validates token and sets security context. Use Spring Security with JWT filter; configure public vs protected endpoints; handle refresh token if needed.

### 46. What is CSRF and how does Spring Security handle it?
**Answer:** Cross-Site Request Forgery: attacker tricks user’s browser into sending requests. Spring can use CSRF token for state-changing requests. For stateless APIs (JWT) CSRF is often disabled.

---

## Spring Boot advanced

### 47. What is Spring Boot Actuator?
**Answer:** Production-ready features: health, metrics, info, env, etc. Endpoints exposed over HTTP or JMX. Use for monitoring and operations; secure and limit exposure in production.

### 48. How do you externalize configuration (e.g. for different environments)?
**Answer:** **application.properties / application.yml**, **application-{profile}.yml**, environment variables, **@Value**, **@ConfigurationProperties**. Order: env vars override properties files.

### 49. What is the difference between `@SpringBootApplication` and manual configuration?
**Answer:** **@SpringBootApplication** = @Configuration + @EnableAutoConfiguration + @ComponentScan. Auto-configuration sets up beans based on classpath and properties; you can override with your own beans.

### 50. How do you run a task on application startup?
**Answer:** **CommandLineRunner** or **ApplicationRunner** (implement and register as bean). Or **@EventListener(ApplicationReadyEvent.class)**. Or **@PostConstruct** on a bean (runs after DI).

### 51. What is the difference between `@Valid` and `@Validated`?
**Answer:** **@Valid:** JSR-303/380; used for nested validation and on method parameters. **@Validated:** Spring; used for method-level validation (e.g. @Validated on class + @Min on parameter). Both trigger validation.

### 52. How do you implement caching in Spring Boot?
**Answer:** Add **spring-boot-starter-cache** and a cache provider (e.g. Caffeine, Redis). Use **@EnableCaching** and **@Cacheable**, **@CacheEvict**, **@CachePut** on methods. Configure cache names and TTL.

### 53. What is the difference between `@Async` and multi-threading with Executor?
**Answer:** **@Async:** declarative; method runs in a thread from a task executor (default or configured). Good for fire-and-forget or returning Future. Executor: programmatic control. Both use a thread pool underneath.

### 54. How do you handle database migrations in Spring Boot?
**Answer:** **Flyway** or **Liquibase** with Spring Boot; migrations as SQL or XML in resources. Versioned; run on startup or via command. Prefer Flyway for simple versioned SQL.

### 55. What is the purpose of `@Profile`?
**Answer:** Beans or config are active only when the given profile(s) are active (e.g. `@Profile("dev")`, `@Profile("prod")`). Use for environment-specific beans (e.g. mock vs real client).

---

## Quick reference

| Topic | Key points |
|-------|------------|
| Java OOP | Encapsulation, inheritance, polymorphism, abstract vs interface |
| Collections | ArrayList vs LinkedList, HashMap vs Hashtable, HashSet vs TreeSet |
| Concurrency | synchronized, volatile, Executor, ConcurrentHashMap |
| Spring DI | Constructor injection, @Component stereotypes, bean lifecycle |
| Spring MVC | DispatcherServlet, @RestController, @PathVariable, @RequestBody |
| Spring Data | N+1 fix (fetch join, EntityGraph), CrudRepository vs JpaRepository |
| Security | Authentication vs authorization, JWT, CSRF |
| Boot | Actuator, profiles, @Transactional, caching, @Async |
