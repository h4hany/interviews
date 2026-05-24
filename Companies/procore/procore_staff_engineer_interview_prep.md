# 🏗️ Procore Technologies — Staff Software Engineer Backend Interview Preparation Package

> **Prepared for**: Back-to-back Runtime Engineering + Software Architecture interviews
> **Company Context**: Construction SaaS platform, millions of users, Ruby on Rails, Kubernetes, AWS, PostgreSQL, OpenTelemetry
> **Target Level**: Staff Engineer (L6+ equivalent)

---

# PART 1 — Ruby/Rails Deep-Dive Questions (150+)

---

## Section A: Ruby Internals (15 Questions)

---

### Q1. Explain Ruby's Global VM Lock (GVL) — what is it, why does it exist, and how does it affect Rails application scaling?

**Answer:**

The GVL (Global VM Lock, formerly GIL) is a mutex that prevents multiple Ruby threads from executing Ruby code simultaneously. Only one thread holds the GVL at a time.

**Why it exists:**
- Ruby's memory management (GC) and C extensions are not thread-safe
- It simplifies VM internals — no need for fine-grained locking throughout the interpreter
- Ensures compatibility with C libraries that aren't thread-safe

**Impact on Rails scaling:**
- **CPU-bound work**: Threads don't help for pure Ruby computation — they're concurrent but not parallel
- **I/O-bound work**: Threads help because the GVL is released during I/O operations (database queries, HTTP requests, file system ops, `sleep`)
- **Puma server**: Uses threads for concurrent request handling — works well because most Rails requests are I/O bound
- **Sidekiq**: Uses threads for concurrent job processing — effective for I/O-bound jobs, less so for CPU-bound

**Scaling implications:**
- For CPU-heavy work, you need multiple processes (Puma workers, Sidekiq processes) not just threads
- The GVL is why Rubyists say "fork for CPU, thread for I/O"
- Ruby 3's Ractor (Guilds) provides true parallelism but adoption in Rails is limited

**Common mistake:** Thinking `Thread.new` gives you parallelism for Ruby computation. It doesn't — it gives concurrency. For true parallelism with CPU work, use multiple processes or Ractors.

---

### Q2. How does Ruby's garbage collector work? What are the different GC modes in Ruby 3.x and how do they affect Rails apps?

**Answer:**

Ruby uses a **mark-and-sweep** garbage collector with generational collection and incremental sweeping.

**Generational GC:**
- **Young generation**: New objects, collected frequently (minor GC)
- **Old generation**: Objects that survived multiple collections, collected less frequently (major GC)
- **Write barriers**: Track references from old to young objects for efficient collection

**Ruby 3.x GC improvements:**
- **Incremental GC**: Breaks major GC into small steps to avoid long pauses
- **Compaction**: `GC.compact` defragments memory, reducing RSS
- **Variable width allocation**: Smaller objects use less memory
- **Non-blocking GC**: Attempts to run GC concurrently with mutator threads

**Tuning for Rails:**
```ruby
# Common production tuning in config/initializers/gc.rb or env vars
GC tune(
  rdoc_gc_params: {
    "RUBY_GC_HEAP_INIT_SLOTS" => 1000000,    # Initial heap slots
    "RUBY_GC_HEAP_FREE_SLOTS" => 500000,     # Minimum free slots
    "RUBY_GC_HEAP_GROWTH_FACTOR" => 1.1,   # Conservative growth
  }
)
```

**Production implications:**
- Major GC pauses cause latency spikes (visible in p99 response times)
- Memory fragmentation increases RSS over time — restart Puma workers periodically
- Use `GC.stat` monitoring to track heap growth and GC time
- Enable `RUBY_GC_PROFILE` for detailed GC metrics

**Interviewer expectation:** You should understand that GC tuning is a tradeoff between memory usage and pause times. More heap = fewer GCs but more memory. Smaller heap = less memory but more frequent GCs.

---

### Q3. What are Ruby's memory allocation patterns? How does memory fragmentation happen and how do you diagnose it?

**Answer:**

Ruby allocates memory in **heap pages**, each containing **slots** (40 bytes default). Objects live in slots.

**Allocation path:**
1. Ruby maintains free slots in a free list
2. When an object is created, it takes a free slot
3. If no free slots, Ruby triggers minor GC to reclaim dead young objects
4. If still no slots, the heap grows
5. Major GC collects old generation when threshold reached

**Fragmentation:**
- Occurs when live objects are scattered across many pages, leaving empty slots that can't be returned to OS
- RSS grows while actual object count stays flat
- Common in long-running Puma workers

**Diagnosis:**
```ruby
# Check fragmentation ratio
GC.stat[:heap_live_slots].to_f / GC.stat[:heap_eden_pages] / 408
# Low ratio = high fragmentation

# Use gctoolgem or similar
# Or use ObjectSpace.dump_all for analysis
```

**Mitigation:**
- `GC.compact` (Ruby 2.7+) — defragments, but has cost
- Periodic Puma worker restart (common pattern: max_requests)
- Reduce object churn (string allocations, temporary arrays)
- Use jemalloc instead of glibc malloc (`LD_PRELOAD=libjemalloc.so`)

**jemalloc is critical for Rails:**
- glibc malloc doesn't return memory to OS efficiently (_malloc_trim issues)
- jemalloc has better fragmentation characteristics
- At Shopify/Procore scale, jemalloc can reduce memory by 20-40%

---

### Q4. Explain the difference between `include`, `extend`, `prepend`, and `refine` in Ruby. When would you use each?

**Answer:**

**`include`:**
- Adds module methods as instance methods of the including class
- Inserts module into ancestor chain *after* the class
- `Foo.ancestors # => [Foo, MyModule, Object]`

**`extend`:**
- Adds module methods as class methods (singleton methods)
- Used for class-level behavior or object-specific behavior
- `obj.extend(MyModule)` adds methods to that specific instance

**`prepend`:**
- Inserts module *before* the class in ancestor chain
- Module's methods "override" class methods — `super` calls the class method
- Critical for instrumentation, caching, AOP patterns
```ruby
module CacheLayer
  def expensive_method
    Rails.cache.fetch(cache_key) { super }
  end
end
class MyService
  prepend CacheLayer
  def expensive_method; ...; end
end
# CacheLayer#expensive_method is called first, super calls MyService#expensive_method
```

**`refine`:**
- Scoped monkey-patching using `using` declaration
- Only active in files that declare `using MyRefinement`
- Safer than global monkey-patches but has performance overhead

**Staff-level insight:** `prepend` is the most powerful and least understood. It's how Rails' `alias_method_chain` was replaced. Understanding ancestor chain manipulation is key for meta-programming and building frameworks.

---

### Q5. How does method lookup work in Ruby? Explain the ancestor chain, singleton classes, and eigenclasses.

**Answer:**

**Method lookup path:**
1. Singleton class (eigenclass) of the object
2. Included modules (in reverse include order, but prepends first)
3. The class itself
4. Prepended modules
5. Parent class
6. Parent's included modules
7. Up to `BasicObject`

**Singleton class (eigenclass):**
Every object has a hidden singleton class that holds object-specific methods:
```ruby
obj = Object.new
def obj.greet; "hello"; end
# 'greet' lives in obj's singleton class
obj.singleton_class.ancestors
```

**Eigenclass of a class:**
Class methods live in the singleton class of the class object:
```ruby
class Foo
  def self.bar; end  # lives in Foo's singleton class
end
# Foo.singleton_class is where 'bar' lives
```

**Ancestor chain with singleton class:**
```ruby
class A; end
class B < A; end
obj = B.new
# obj method lookup:
# obj.singleton_class -> B -> A -> Object -> Kernel -> BasicObject
```

**Staff-level insight:** Understanding this is crucial for:
- Debugging `NoMethodError` and `super` behavior
- Building DSLs and frameworks
- Understanding Rails' `class_attribute`, `delegate`, and concern mechanism
- Implementing decorator patterns without breaking `is_a?`

---

### Q6. What are frozen string literals? Why are they important for Rails performance?

**Answer:**

**Frozen string literals** (`# frozen_string_literal: true` magic comment, or `--enable-frozen-string-literal`) make all string literals in a file immutable.

**Why it matters:**
- Without freezing, every string literal allocation creates a new object
- `"hello"` allocates every time it's executed
- Frozen string literals deduplicate — same content shares one object

**Memory impact:**
- Rails boot allocates thousands of strings (route paths, SQL fragments, error messages)
- Frozen literals can reduce boot memory by 10-20%
- Reduces GC pressure from transient string objects

**In Rails:**
- Rails 5+ adds `# frozen_string_literal: true` to generated files
- Ruby 3.0+ may enable by default (was delayed)
- Use `String.new` or `+""` when you need mutable strings

**Production practice:**
```ruby
# config.ru or boot file
# frozen_string_literal: true
# For gems not using frozen strings, there's limited benefit
# But for application code, always use the magic comment
```

---

### Q7. Explain Ruby's exception handling mechanism. How do `rescue`, `ensure`, `else`, and `retry` work?

**Answer:**

**Basic mechanism:**
```ruby
begin
  risky_operation
rescue SpecificError => e
  handle_error(e)
rescue AnotherError
  handle_another
else
  runs_if_no_exception
ensure
  always_runs (cleanup)
end
```

**Key details:**
- `rescue` without class defaults to `StandardError` (not `Exception`)
- Never `rescue Exception` — catches `SignalException`, `NoMemoryError`, `ScriptError`
- `retry` re-executes the begin block (use with counter to avoid infinite loops)
- `else` runs only if no exception occurred (rarely used)
- `ensure` runs even if `return`, `break`, or `next` is called

**Rails patterns:**
```ruby
# Transaction retry pattern
retries = 3
begin
  ActiveRecord::Base.transaction do
    complex_operation
  end
rescue ActiveRecord::Deadlocked, ActiveRecord::LockWaitTimeout => e
  retries -= 1
  retries > 0 ? retry : raise
end
```

**Staff-level:**
- Understand exception hierarchy: `Exception > StandardError > RuntimeError`
- `raise` without args re-raises `$!` (current exception)
- Custom exceptions should inherit from `StandardError`, not `Exception`
- In Rails controllers, `rescue_from` handles exceptions at the framework level

---

### Q8. How does Ruby's constant lookup work? Explain autoloading, `const_missing`, and Zeitwerk.

**Answer:**

**Constant lookup rules:**
1. Lexical scope (enclosing modules/classes, then outer scopes)
2. Inheritance chain (ancestors)
3. `Object` (for top-level constants)
4. `const_missing` callback

**Zeitwerk (Rails 6+):**
- Replaces classic autoloader
- Uses Ruby's `const_missing` and `Module#autoload`
- Maps file paths to constant names by convention:
  - `app/services/payment/gateway.rb` → `Payment::Gateway`
  - `app/services/payment/gateways/stripe.rb` → `Payment::Gateways::Stripe`

**Key behaviors:**
- `collapse` for directories that shouldn't create namespaces
- `eager_load!` loads everything at boot (production)
- `autoload` loads on first reference (development)

**Common issues:**
- Naming mismatches (`HTTPClient` vs `http_client.rb`)
- Circular dependencies
- Referencing constants in `to_prepare` callbacks before autoload

**Staff-level:**
```ruby
# Custom inflection for Zeitwerk
# config/initializers/zeitwerk.rb
Rails.autoloaders.main.inflector.inflect(
  "payment" => "Payment",
  "ssl" => "SSL"
)
```

---

### Q9. What is the difference between `Proc`, `lambda`, and `block` in Ruby?

**Answer:**

**Block:**
- Not an object — syntax `{ ... }` or `do ... end`
- Passed to methods as implicit last argument
- Can be converted to Proc with `&block` parameter

**Proc:**
- Object of class `Proc`
- Created with `Proc.new { ... }` or `proc { ... }`
- Lenient argument checking (missing args = nil, extra args ignored)
- `return` returns from the enclosing method (not the proc itself)

**Lambda:**
- Also a `Proc` but with `lambda?` = true
- Strict argument checking (wrong arity raises ArgumentError)
- `return` returns from the lambda itself (not enclosing method)
- Behaves more like a method

**Staff-level implications:**
- Use `lambda` for callbacks that should enforce arity
- Use `proc` for flexible callback patterns
- Understand why `return` in a proc can unexpectedly exit your method
- Rails uses blocks extensively in DSLs (routes, migrations, callbacks)

---

### Q10. Explain `Module.new` vs `Class.new`, anonymous classes, and when you'd use them dynamically.

**Answer:**

**Dynamic class/module creation:**
```ruby
# Anonymous module
policy_module = Module.new do
  def can_edit?
    user.admin? || owner?
  end
end
User.include(policy_module)

# Anonymous class
controller_class = Class.new(ApplicationController) do
  def index
    render json: { dynamic: true }
  end
end
```

**Use cases:**
- **STI with dynamic types**: Creating subclasses at runtime
- **Plugin systems**: Dynamic behavior injection
- **Testing**: Anonymous classes for isolated tests
- **DSL construction**: Building classes/modules from configuration

**Staff-level:**
- Anonymous classes have names when assigned to constants
- Used in Rails' `scoped` associations and `class_attribute` implementation
- Understanding this enables building flexible plugin architectures

---

### Q11. How does Ruby handle method_missing and respond_to_missing? Why is the pairing important?

**Answer:**

**`method_missing`:**
- Called when a method isn't found in the ancestor chain
- Enables dynamic method dispatch (ActiveRecord dynamic finders, delegators)
- Powerful but slow — every miss goes through it

**`respond_to_missing?`:**
- Must be paired with `method_missing`
- Ensures `respond_to?` returns true for dynamically handled methods
- Without it, `object.respond_to?(:dynamic_method)` returns false

**Rails example:**
```ruby
class DynamicFinder
  def method_missing(name, *args, &block)
    if name.to_s.start_with?("find_by_")
      column = name.to_s.sub("find_by_", "")
      find_by(column => args.first)
    else
      super
    end
  end

  def respond_to_missing?(name, include_private = false)
    name.to_s.start_with?("find_by_") || super
  end
end
```

**Performance warning:** `method_missing` is 10-50x slower than direct calls. For hot paths, use `define_method` instead.

---

### Q12. Explain Ruby's object model: everything is an object, including classes. What does this mean practically?

**Answer:**

In Ruby, everything that holds a value is an object. This includes:
- Numbers: `1.class # => Integer`
- Classes: `String.class # => Class`, and `Class.class # => Class`
- `nil`: `nil.class # => NilClass`
- `true`/`false`: `TrueClass`/`FalseClass`

**Practical implications:**

**Classes are objects:**
- You can pass classes around as arguments
- Call methods on classes (`String.methods`)
- Classes can have instance variables (class instance variables, different from class variables)

**Metaprogramming:**
```ruby
klass = class_for_name("User")  # User class object
klass.create!(params)           # Call methods on the class object
```

**Singleton methods:**
- Defining a method on an individual object
- Used extensively in testing (mocks, stubs)
- The basis for class methods (methods on class objects)

**Staff-level:** Understanding this enables building flexible systems like Rails' constantize, factory patterns, and plugin architectures.

---

### Q13. What are WeakRef, WeakMap, and finalizers? When would you use them in a Rails app?

**Answer:**

**WeakRef:**
- Holds a reference to an object without preventing GC
- `ref = WeakRef.new(big_object)` — big_object can still be collected
- Used for caches that shouldn't prevent memory cleanup

**WeakMap:**
- Hash-like structure where keys are weak references
- When key object is GC'd, the entry is removed
- Ruby 2.7+ (JRuby has `java.util.WeakHashMap`)

**Finalizers:**
- Callbacks run when an object is garbage collected
- `ObjectSpace.define_finalizer(obj, proc)`
- Used for cleanup of external resources (file handles, native memory)

**Rails use cases:**
- In-memory caches that shouldn't grow unbounded
- Tracking object lifecycle for debugging
- Cleaning up temp files or native resources

**Caution:** Finalizers run unpredictably and on the GC thread. Never do blocking I/O in finalizers.

---

### Q14. How does Ruby's `defined?` keyword work? What are practical use cases?

**Answer:**

`defined?` returns a string description of an expression's definition status, or `nil` if not defined.

```ruby
defined?(Foo)        # "constant" if constant exists
defined?(@var)       # "instance-variable" if set
defined?(local_var)  # "local-variable" if in scope
defined?($!)         # "global-variable"
defined?(nil)        # "nil"
defined?(method_name)# "method" if callable
defined?(1 + 2)      # "expression"
```

**Rails uses:**
- Checking if a constant is loaded before using it (avoid NameError)
- Conditional behavior based on gem availability
- Feature flag checks in configuration

**vs `nil?`:** `defined?` checks if the name exists at all; `nil?` checks if the value is nil. A variable can be defined but nil.

---

### Q15. Explain the difference between `Object#clone` and `Object#dup`, and `Object#freeze` behavior with each.

**Answer:**

**`dup`:**
- Shallow copy — copies the object but not the objects it references
- Does NOT copy singleton class/methods
- Does NOT preserve `frozen` state
- Can be customized via `initialize_copy`

**`clone`:**
- Shallow copy like `dup`
- Copies singleton class/methods
- Preserves `frozen` state
- Can be customized via `initialize_clone`

**Staff-level insight:**
- ActiveRecord overrides `dup` to create new records (no ID)
- Use `deep_dup` for deep copies (Rails extension)
- Freezing cloned objects matters for defensive copying patterns
- Understand when shallow copy isn't enough (nested hashes, associations)

---

## Section B: Rails Internals (20 Questions)

---

### Q16. Explain Rails' request lifecycle from HTTP request to response.

**Answer:**

1. **Web server** (Nginx/ALB) receives HTTP request
2. **Application server** (Puma) accepts the connection
3. **Rack interface** — Puma passes request to Rack
4. **Middleware stack** (`config.middleware`):
   - SSL enforcement, asset serving, cookie/session handling
   - Rails router, exception handling
5. **Routing** (`config/routes.rb`) — matches URL to controller#action
6. **Controller** — `before_action` filters, strong parameters, action execution
7. **Models/ActiveRecord** — business logic, database queries
8. **View rendering** — template compilation, partials, helpers
9. **Response** — status, headers, body back through middleware
10. **Rack** returns to Puma → Nginx → Client

**Staff-level details:**
- Middleware runs in order for request, reverse order for response
- The middleware stack is built at boot and cached
- `ActionDispatch::Routing` is itself middleware
- Controllers are instantiated per-request (not singletons)
- View rendering can happen async for streaming responses

---

### Q17. How does Rails' middleware stack work? How would you add, remove, or insert custom middleware?

**Answer:**

**Architecture:**
- Array of middleware classes that process requests in pipeline
- Each middleware calls `app.call(env)` to pass to next layer
- Pattern: process request → call next → process response

**Configuration:**
```ruby
# config/application.rb or config/environments/*.rb
config.middleware.use MyMiddleware                    # Add at end
config.middleware.insert_before ActionDispatch::Static, MyMiddleware
config.middleware.insert_after Rack::Runtime, MyMiddleware
config.middleware.delete Rack::Runtime
config.middleware.swap ActionDispatch::Static, MyCustomStatic
```

**Custom middleware:**
```ruby
class RequestTimingMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    start = Time.current
    status, headers, body = @app.call(env)
    duration = Time.current - start
    headers["X-Request-Time"] = duration.to_s
    [status, headers, body]
  end
end
```

**Staff-level:** Middleware is the right place for cross-cutting concerns: request ID propagation, metrics, CORS, authentication at the edge. Don't put business logic in middleware.

---

### Q18. Explain Rails' boot process. What happens from `rails s` to first request?

**Answer:**

**Phase 1: Ruby startup**
- Load `config/boot.rb` → Bundler.setup
- Load `config/application.rb` → Your application class

**Phase 2: Framework initialization**
- Require railties (ActiveRecord, ActionController, etc.)
- Load `config/environments/development.rb`
- Run initializers in `config/initializers/` (alphabetical order)

**Phase 3: Autoload/eager load**
- Development: Zeitwerk sets up autoload paths
- Production: `eager_load!` — loads all application code
- Engines mount their code and routes

**Phase 4: Database connection pool**
- Establish connection to PostgreSQL
- Create connection pool (default 5 connections)

**Phase 5: Application server**
- Puma reads `config/puma.rb`
- Forks workers (if cluster mode)
- Each worker loads the application (if preload_app)

**Optimization for production:**
```ruby
# config/puma.rb
preload_app!

on_worker_boot do
  ActiveRecord::Base.establish_connection
  Redis.current = Redis.new(...)
end
```

**Staff-level:** Boot time matters for auto-scaling (Kubernetes HPA) and deployment speed. Use `bootsnap` to cache compiled bytecode, avoid heavy initialization in initializers, and defer non-critical setup.

---

### Q19. How do Rails engines work? When would you use them vs. separate gems?

**Answer:**

**Rails engines** are mini-Rails applications that can be mounted within a host app. They have their own MVC stack, routes, initializers, and migrations.

**Key characteristics:**
- Inherit from `Rails::Engine`
- Can be isolated (separate namespace) or non-isolated
- Mountable in routes: `mount MyEngine::Engine => "/admin"`
- Can share or isolate models/controllers

**When to use:**
- **Modular monolith**: Separate bounded contexts (billing, auth, reporting)
- **Reusable components**: Admin panels, authentication systems
- **Plugin architecture**: Allow third-party extensions

**vs. Gems:**
| Aspect | Engine | Gem |
|--------|--------|-----|
| Has own MVC | Yes | No |
| Routes | Yes | No |
| Migrations | Yes | No |
| Rails integration | Deep | Loose |
| Testable standalone | Somewhat | Yes |

**Staff-level:** At Procore's scale, engines enable team autonomy. Each team owns an engine with its own domain logic, tests, and deployment artifact — while sharing the same deployment unit (modular monolith).

---

### Q20. Explain the difference between `config/application.rb`, environment files, and initializers. In what order do they load?

**Answer:**

**Loading order:**
1. `config/boot.rb` — Bundler
2. `config/application.rb` — Application class definition, framework requires
3. `config/environments/#{Rails.env}.rb` — Environment-specific config
4. `config/initializers/*.rb` — All initializers (alphabetical)
5. `config/after_initialize.rb` or `to_prepare` callbacks

**Best practices:**
- Application.rb: Framework-agnostic config, defaults
- Environment files: Only environment-specific overrides (DB URLs, logging levels)
- Initializers: Feature configuration, third-party gem setup, monkey patches

**Staff-level:** Initializers run once at boot. For code that needs to run on every request in development (or after class reloading), use `ActiveSupport::Reloader.to_prepare` instead of an initializer.

---

### Q21. How does Rails' code reloading work in development? What are the implications?

**Answer:**

**Development reloading:**
- `config.cache_classes = false` enables reloading
- Between requests, changed files are unloaded and reloaded
- Uses `ActiveSupport::Reloader` middleware
- Only reloads autoloaded constants (not initializers, not `require`d files)

**Mechanism:**
1. Request comes in
2. Reloader checks file mtimes against cache
3. Changed files have their constants removed (`remove_const`)
4. New request autoloads fresh versions

**Production:**
- `config.eager_load = true` — loads everything at boot
- `config.cache_classes = true` — no reloading
- `ActiveSupport::Executor` (not Reloader) handles request isolation

**Staff-level implications:**
- Initializers don't reload — put per-request logic in middleware or controllers
- `require` bypasses autoloading — use `require_dependency` for reloadable files
- `to_prepare` runs once before first request, then on every reload
- Thread-safety: reloading is not thread-safe (hence `config.allow_concurrency` considerations)

---

### Q22. How does Rails' routing system work? Explain the journey from URL to controller action.

**Answer:**

**Process:**
1. `ActionDispatch::Routing` middleware receives request
2. Route set (compiled from `config/routes.rb`) is searched
3. First matching route wins (order matters!)
4. Route extracts parameters (`:id`, query params)
5. Controller is instantiated, action method called

**Route compilation:**
- Routes are compiled into a trie-like structure at boot
- Named routes generate URL helpers (`users_path`)
- Constraints can match on regex, lambdas, or request properties

**Staff-level patterns:**
```ruby
# Concerns for reusable routes
concern :commentable do
  resources :comments
end
resources :posts, concerns: :commentable

# Advanced constraints
constraints subdomain: "api" do
  namespace :api do ... end
end

# Direct matches for health checks
direct :health do |opts, request|
  "/healthcheck"
end
```

---

### Q23. Explain `ActiveSupport::Notifications` and how it's used for instrumentation.

**Answer:**

**Pub/sub instrumentation framework built into Rails:**

```ruby
# Subscribe to events
ActiveSupport::Notifications.subscribe("process_action.action_controller") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  StatsD.measure("rails.request", event.duration, tags: { action: event.payload[:action] })
end
```

**Built-in instrumented events:**
- `process_action.action_controller` — Controller action timing
- `sql.active_record` — Database queries
- `render_template.action_view` — View rendering
- `enqueue.active_job` — Job enqueuing
- `cache_read.active_support` — Cache operations

**Custom instrumentation:**
```ruby
ActiveSupport::Notifications.instrument("payment.process", gateway: "stripe") do
  result = process_payment
  { success: result.success?, amount: result.amount }
end
```

**Staff-level:** This is the foundation of Rails observability. New Relic, Datadog, and custom APM all hook into these events. For OpenTelemetry integration, you'd create a subscriber that creates spans from these notifications.

---

### Q24. How do Rails' callbacks work (around, before, after)? What are the dangers?

**Answer:**

**Callback types:**
- `before_action` — runs before action, can halt with `render`/`redirect`
- `after_action` — runs after action, cannot halt
- `around_action` — wraps action execution

**Execution order:**
1. before_actions (in declaration order)
2. around_action (yield triggers action)
3. Action execution
4. around_action (after yield)
5. after_actions (reverse declaration order)

**Dangers:**
- **Hidden control flow**: Logic scattered across callbacks is hard to follow
- **Ordering dependencies**: Fragile, order matters but isn't obvious
- **Testing difficulty**: Hard to test in isolation
- **Infinite loops**: Accidental recursive callbacks

**Staff-level advice:** At Staff level, push back on excessive callbacks. Extract to explicit service calls:
```ruby
# Bad: hidden in before_action
before_action :ensure_project_access

# Better: explicit in action
def show
  authorize! @project
  # ...
end
```

---

### Q25. Explain Rails' parameter wrapping, strong parameters, and how they relate to security.

**Answer:**

**Parameter wrapping:**
- Rails wraps JSON params under a resource key automatically
- POST `{ "name": "John" }` becomes `params[:user][:name]` if model is User

**Strong parameters:**
```ruby
def user_params
  params.require(:user).permit(:name, :email, :role)
end
```
- `require` ensures the key exists (raises otherwise)
- `permit` whitelists allowed attributes (prevents mass assignment)
- Everything else is filtered out

**Security model:**
- Prevents mass assignment vulnerabilities (assigning admin=true)
- Each controller action defines its own parameter contract
- Nested params: `permit(:name, address: [:street, :city])`

**Staff-level:** Never use `permit!` (allows everything). For complex nested forms, build dedicated parameter objects (form objects).

---

### Q26. How does Rails' asset pipeline / Propshaft work? What are the implications for deployment?

**Answer:**

**Asset Pipeline evolution:**
- **Sprockets** (Rails 3-7): Concatenates, minifies, fingerprints assets at compile time
- **Propshaft** (Rails 7+): Simpler — only digests and serves, assumes JS bundling externally
- **jsbundling-rails/cssbundling-rails**: Use esbuild/webpack/rollup externally

**Fingerprinting:**
- `application.css` → `application-digest123.css`
- Enables far-future cache headers (immutable)
- CDN friendly

**Deployment:**
- Assets precompiled during build (`assets:precompile`)
- Must succeed in CI before deployment
- Large asset compilation can slow deployments

**Staff-level:** Propshaft is the modern path — simpler, faster, but requires separate JS bundling. For Procore scale, external bundling (esbuild) is 10-100x faster than webpack.

---

### Q27. Explain CSRF protection in Rails. How does it work, and when would you disable it?

**Answer:**

**Mechanism:**
1. Server generates CSRF token, stores in session
2. Token embedded in forms (`authenticity_token` hidden field) and meta tags
3. For non-GET requests, server validates token matches session
4. `protect_from_forgery` in ApplicationController enables this

**API mode:**
- API-only Rails apps skip CSRF (`protect_from_forgery with: :null_session`)
- APIs use token-based auth (JWT, API keys) instead

**Staff-level:** Never globally disable CSRF. If you need to accept webhooks or API calls, use `skip_before_action :verify_authenticity_token, only: [:webhook]` on specific actions. For SPAs using session auth, use `X-CSRF-Token` header.

---

### Q28. How do Rails sessions work? Compare cookie-based, cache-based, and database-backed sessions.

**Answer:**

**Cookie store (default):**
- Session data serialized, signed (HMAC), optionally encrypted
- Stored client-side — no server storage needed
- 4KB limit, cannot store large objects
- Fast — no external lookup

**Cache store:**
- Session data in Redis/Memcached
- Fast lookup, shared across servers
- Key eviction can log users out unexpectedly

**Database store (activerecord-session_store):**
- Session data in PostgreSQL table
- Persistent, won't be evicted
- Slower — requires DB query per request
- Good for compliance (session audit trail)

**Redis store (redis-actionpack):**
- Best of both worlds: fast, persistent (if configured), shared
- Recommended for production multi-server deployments

**Staff-level:** For Procore scale with millions of users, Redis-backed sessions are standard. Use cookie store only if sessions are tiny (<1KB) and you have no server-side state requirements.

---

### Q29. Explain Rails' I18n system. How would you handle thousands of translation keys at scale?

**Answer:**

**Architecture:**
- Backend stores translations (YAML files, database, Redis)
- `I18n.translate` / `t()` looks up keys by locale
- Supports interpolation, pluralization, scoping

**Scale challenges:**
- YAML files become unmanageable at 1000+ keys
- Loading all translations consumes memory
- Multiple locales multiply the problem

**Solutions:**
- **Lazy loading**: Load translations on demand from DB/cache
- **Backend switch**: `I18n.backend = I18n::Backend::ActiveRecord.new`
- **Caching**: Cache lookup results in Redis
- **CDN for JS translations**: Serve frontend translations via CDN

**Staff-level:** Consider a translation management service (Phrase, Lokalise) with API integration. For performance, cache aggressively and avoid I18n in hot loops.

---

### Q30. How does Rails' STI (Single Table Inheritance) work? What are the tradeoffs?

**Answer:**

**Mechanism:**
- `type` column stores class name
- `Document.find(1)` returns correct subclass based on `type`
- All subclasses share one table with all columns

```ruby
class Document < ApplicationRecord; end
class PdfDocument < Document; end
class WordDocument < Document; end
```

**Pros:**
- Simple queries across all types
- Polymorphic associations work naturally
- Easy to implement

**Cons:**
- Sparse table — many NULL columns
- Can't enforce NOT NULL per subtype
- Hard to add subtype-specific indexes
- Table grows wide with many subtypes

**Alternatives:**
- **Class Table Inheritance**: Separate tables per type with shared parent
- **Delegated Types** (Rails 6.1+): `Entry` delegates to `Message` or `Comment`
- **Polymorphic associations**: `documentable` pattern

**Staff-level:** Avoid STI for more than 3-4 subtypes. Use delegated types or separate tables. STI works well when subtypes are similar (same validations, few unique columns).

---

### Q31. How do Rails concerns work under the hood? What problems do they solve?

**Answer:**

**Implementation:**
```ruby
module Archivable
  extend ActiveSupport::Concern

  included do
    scope :archived, -> { where.not(archived_at: nil) }
  end

  class_methods do
    def archiving_enabled?
      column_names.include?("archived_at")
    end
  end

  def archive!
    update!(archived_at: Time.current)
  end
end
```

**Under the hood:**
- `ActiveSupport::Concern` provides `included` and `class_methods` DSL
- `include` triggers `included` block in the context of the including class
- Handles dependency resolution between concerns

**Problems solved:**
- Extract shared model behavior without deep inheritance
- Avoid fat models by organizing related methods
- Reusable across models (soft deletes, tagging, versioning)

**Staff-level:** Concerns are good for horizontal sharing (mixins). For vertical features (workflows, processes), prefer service objects. Don't use concerns to hide complexity — use them to organize it.

---

### Q32. Explain Rails' `delegate` method and when it's appropriate vs. when it's a code smell.

**Answer:**

**Purpose:** Forward method calls to another object:
```ruby
delegate :name, :email, to: :owner, prefix: true, allow_nil: true
# Creates owner_name, owner_email methods
```

**Appropriate use:**
- Value object composition (`Money` delegates to `amount`)
- Presenter/decorator patterns
- Law of Demeter compliance (don't chain through objects)

**Code smell when:**
- You're delegating 10+ methods — probably wrong abstraction
- You're hiding broken encapsulation
- The delegating object has no behavior of its own (Lazy Class)

**Staff-level:** Delegation is a band-aid for tight coupling. If you find yourself delegating extensively, ask: should these objects be merged? Is the boundary wrong?

---

### Q33. How do Rails' custom validators work? Design a custom validator for a construction-specific domain.

**Answer:**

**Implementation:**
```ruby
class ValidCoordinateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    unless value.is_a?(Hash) && value[:lat].present? && value[:lng].present?
      record.errors.add(attribute, :invalid_coordinate)
      return
    end
    unless (-90..90).cover?(value[:lat].to_f)
      record.errors.add(attribute, :latitude_out_of_range)
    end
    unless (-180..180).cover?(value[:lng].to_f)
      record.errors.add(attribute, :longitude_out_of_range)
    end
  end
end

# Usage
class ConstructionSite < ApplicationRecord
  validates :location, valid_coordinate: true
end
```

**Key points:**
- Inherit from `ActiveModel::EachValidator`
- Implement `validate_each(record, attribute, value)`
- Register with ActiveModel automatically if named correctly

---

### Q34. Explain `ActiveSupport::CurrentAttributes` and when to use it carefully.

**Answer:**

**Purpose:** Per-request thread-isolated attributes:
```ruby
class Current < ActiveSupport::CurrentAttributes
  attribute :user, :organization, :request_id
end

# In controller
Current.user = current_user
Current.request_id = request.uuid

# Anywhere in request
Rails.logger.info "User #{Current.user.id} did action"  # No need to pass user around
```

**Dangers:**
- **Implicit dependencies**: Code appears to have no dependencies but actually requires `Current.user`
- **Testing difficulty**: Must set Current before testing service objects
- **Background jobs**: Current doesn't propagate to jobs — must pass explicitly
- **Thread safety**: While thread-isolated, misuse in fibers or async code can leak

**Staff-level:** Use sparingly for cross-cutting concerns (request ID, tenant context). Never put business-logic dependencies in Current. Prefer explicit parameter passing for service objects.

---

### Q35. How does Rails' `respond_to` and `respond_with` work? What's the modern approach?

**Answer:**

**respond_to:**
```ruby
def show
  @user = User.find(params[:id])
  respond_to do |format|
    format.html
    format.json { render json: @user }
    format.xml { render xml: @user }
  end
end
```

**Modern approach (API mode):**
```ruby
# API controllers skip HTML entirely
class Api::UsersController < ApplicationController
  def show
    user = User.find(params[:id])
    render json: UserSerializer.new(user)
  end
end
```

**Staff-level:** In modern Rails APIs, use explicit `render json:` with serializers (ActiveModel::Serializers, Alba, jbuilder). `respond_to` is legacy — explicit is better than implicit at scale.

---

## Section C: ActiveRecord & PostgreSQL (20 Questions)

---

### Q36. How does ActiveRecord's query interface translate to SQL? Explain the lazy loading mechanism.

**Answer:**

**ActiveRecord uses the Query Chain pattern — queries are lazy:**
```ruby
users = User.where(active: true)           # No query executed - returns Relation
users = users.joins(:orders)               # Still no query - chaining
users = users.order(:created_at)           # Still no query
users = users.limit(10)                    # Still no query
users.to_a                                 # NOW executes: SELECT ... LIMIT 10
```

**Relation objects** are composable query builders. They execute only when:
- `to_a`, `each`, `map`, `first`, `last`, `count`, `pluck` called
- `inspect` in console (triggers `.to_a`)
- Enumerable methods force realization

**Benefits:**
- Composable: Pass scopes between methods
- Testable: Chain conditions without executing
- Optimizable: Rails can defer and optimize the final query

**Staff-level insight:**
- `load` forces execution and caches results
- `find_each` (batching) for memory-efficient iteration
- `explain` shows the generated SQL plan
- Relations are immutable — each chain returns a new Relation

---

### Q37. Explain the N+1 query problem in detail. List every strategy to prevent and detect it.

**Answer:**

**The problem:**
```ruby
# 1 query for users + N queries for each user's orders = N+1 total
users = User.limit(100)
users.each { |u| puts u.orders.count }  # 101 queries!
```

**Prevention strategies:**

1. **`includes` (preload/eager_load):**
```ruby
users = User.includes(:orders).limit(100)
# 2 queries: 1 for users, 1 for all their orders
```

2. **`preload`:** Separate queries (better for has_many)
3. **`eager_load`:** LEFT JOIN (better when filtering on associations)
4. **`joins` + `select`:** For filtering, not loading associations

5. **Counter cache:** `counter_cache: true` on `belongs_to`
```ruby
# orders_count column on users, auto-updated
user.orders_count  # 0 queries - reads cached value
```

6. **`exists?` / `any?` / `count`:** Don't load records when you don't need them

7. **Denormalization:** Store aggregated values in parent record

8. **Materialized views:** For complex reporting queries

**Detection tools:**
- `bullet` gem — development alerts
- `prosopite` gem — production-safe N+1 detection
- Strict loading: `User.strict_loading.includes(:orders)` raises on N+1
- Query log analysis: Look for repeated similar queries
- APM tools (New Relic, Datadog) — trace view shows query counts

**Staff-level:** In a Procore interview, mention you've used prosopite in production with alerting, and that counter caches require careful handling with transactions.

---

### Q38. Explain database transactions in Rails. How do nested transactions, savepoints, and callbacks interact?

**Answer:**

**Basic transaction:**
```ruby
ActiveRecord::Base.transaction do
  user.save!
  account.save!
end  # COMMIT if all succeed, ROLLBACK if any exception
```

**Nested transactions use savepoints:**
```ruby
User.transaction do           # BEGIN
  user.save!
  Account.transaction do      # SAVEPOINT active_record_1
    account.save!
  end                         # RELEASE SAVEPOINT (or ROLLBACK TO)
end                           # COMMIT
```

**Critical behavior:**
- Inner transaction rollback only rolls back to savepoint
- Outer transaction can still commit if inner is rescued
- `ActiveRecord::Rollback` exception only rolls back current transaction level (not re-raised)
- Other exceptions roll back AND re-raise

**Callback interaction:**
- `after_save` runs inside the transaction (can be rolled back)
- `after_commit` runs after COMMIT (cannot be rolled back)
- Use `after_commit` for side effects (emails, cache invalidation, external API calls)
- `after_rollback` for cleanup on failure

**Staff-level:**
```ruby
# Pattern: Use after_commit for anything that must happen exactly once
after_commit :send_welcome_email, on: :create
after_commit :invalidate_cache, on: [:create, :update, :destroy]
```

---

### Q39. How do you design zero-downtime migrations for large PostgreSQL tables (millions+ rows)?

**Answer:**

**The Expand-Contract Pattern:**

**Step 1: Add nullable column (safe, no lock on reads/writes)**
```ruby
class AddStatusToProjects < ActiveRecord::Migration[7.1]
  def up
    add_column :projects, :status, :string  # NULLABLE, no default
    add_index :projects, :status, algorithm: :concurrently  # No table lock
  end
end
```

**Step 2: Dual-write in application code (write to both old and new)**
```ruby
class Project < ApplicationRecord
  def status
    read_attribute(:status) || legacy_status_from_state_column
  end

  def status=(value)
    super
    self.state = value  # Dual-write
  end
end
```

**Step 3: Backfill in batches (avoid long-running transaction)**
```ruby
class BackfillProjectStatus < ApplicationJob
  def perform(batch_size = 1000)
    Project.where(status: nil).find_each(batch_size: batch_size) do |project|
      project.update_column(:status, project.legacy_status)
    end
  end
end
```

**Step 4: Add NOT NULL constraint (after all rows backfilled)**
```ruby
class AddNotNullToProjectStatus < ActiveRecord::Migration[7.1]
  def up
    add_check_constraint :projects, "status IS NOT NULL", name: "projects_status_not_null", validate: false
    # Validate separately (doesn't lock table during initial add)
    validate_check_constraint :projects, name: "projects_status_not_null"
    change_column_null :projects, :status, false
    remove_check_constraint :projects, name: "projects_status_not_null"
  end
end
```

**Step 5: Remove old column (after validation period)**
```ruby
class RemoveStateFromProjects < ActiveRecord::Migration[7.1]
  def up
    safety_assured { remove_column :projects, :state }
  end
end
```

**Tools:** `strong_migrations` gem enforces safe migration patterns.

**Staff-level:** For tables with 100M+ rows at Procore, use `pt-online-schema-change` (Percona) for DDL operations, or PostgreSQL's built-in `pg_repack` for complex changes.

---

### Q40. Explain PostgreSQL's MVCC (Multi-Version Concurrency Control). How does it affect Rails applications?

**Answer:**

**How MVCC works:**
- Every transaction gets a transaction ID (xid)
- `UPDATE` creates a new row version, marks old as "dead"
- `DELETE` marks row as dead, doesn't immediately remove it
- Readers see a consistent snapshot — never blocked by writers
- No read locks needed for SELECT

**Rails implications:**

**1. Long transactions are dangerous:**
```ruby
# Bad: Holding transaction while doing HTTP calls
ActiveRecord::Base.transaction do
  result = ExternalApi.call  # 5 seconds
  record.save!
end  # Transaction held for 5+ seconds, blocking cleanup
```

**2. Dead tuples accumulate:**
- Updated/deleted rows become "dead tuples"
- `VACUUM` reclaims space and marks tuples as reusable
- `autovacuum` runs automatically but may not keep up on busy tables

**3. Transaction ID wraparound:**
- xid is 32-bit, wraps around at ~2 billion
- `VACUUM FREEZE` marks rows as "frozen" (visible to all transactions)
- Failure to freeze = database stops accepting writes!

**Monitoring:**
```sql
-- Check dead tuples
SELECT schemaname, relname, n_dead_tup, n_live_tup, last_autovacuum
FROM pg_stat_user_tables
WHERE n_dead_tup > 10000;

-- Check for wraparound risk
SELECT datname, age(datfrozenxid) FROM pg_database;
-- If age > 1 billion, urgent intervention needed
```

**Staff-level:** At Procore scale, tune autovacuum aggressively for high-churn tables. Use `autovacuum_vacuum_scale_factor = 0.02` (default 0.2 is too high for large tables).

---

### Q41. How would you optimize a slow ActiveRecord query? Walk through your systematic approach.

**Answer:**

**Step 1: Identify the actual query and execution plan**
```ruby
User.includes(:projects, :orders)
    .where("created_at > ?", 1.year.ago)
    .order(last_active_at: :desc)
    .limit(50)
    .explain(:analyze, :buffers)
```

**Step 2: Read EXPLAIN ANALYZE output**
- Check for Sequential Scans on large tables
- Look at actual vs estimated row counts (bad stats?)
- Identify sort operations (memory vs disk)
- Check for Nested Loops that should be Hash Joins

**Step 3: Add appropriate indexes**
```ruby
# Composite index for filter + sort + includes
add_index :users, [:created_at, :last_active_at], 
          include: [:name, :email],  # Covering index
          algorithm: :concurrently
```

**Step 4: Rewrite the query**
```ruby
# Select only needed columns (reduce I/O)
User.select(:id, :name, :email)

# Use pluck for simple lookups
User.where(active: true).pluck(:email)

# Batch processing instead of loading all
User.find_each(batch_size: 1000) { |u| process(u) }
```

**Step 5: Caching strategy**
- Counter caches for aggregates
- Materialized views for complex reports
- Application-level caching (Redis) for frequently accessed data

**Step 6: Connection and database tuning**
- Check connection pool isn't exhausted
- Verify `work_mem` for sorts
- Consider read replicas for SELECT-heavy workloads

**Staff-level:** Always measure before and after. Use `pg_stat_statements` to find the top queries by total time, not just slow individual queries. A query running 100ms but 100K times/day is worse than one running 2s but 10 times/day.

---

### Q42. What are the different PostgreSQL index types and when do you use each?

**Answer:**

**B-Tree (default):**
- Equality (=) and range (<, >, BETWEEN) queries
- Sorting (ORDER BY)
- Most common index type

**Hash:**
- Only equality comparisons
- Slightly faster than B-Tree for =, but rarely worth it
- Not crash-safe before PG 10 (don't use)

**GiST (Generalized Search Tree):**
- Geometric data (PostGIS), range types
- "Nearest neighbor" searches
- Full-text search with `pg_trgm`

**GIN (Generalized Inverted Index):**
- Arrays (`WHERE tags @> ARRAY['ruby']`)
- JSONB (`WHERE data @> '{"key": "value"}'`)
- Full-text search (`to_tsvector` columns)
- Faster reads, slower writes than GiST

**BRIN (Block Range Index):**
- Very large, naturally ordered tables (time-series, logs)
- Tiny index size, but only for correlated data
- `created_at` on append-only tables

**SP-GiST:**
- Partitioned search trees for non-balanced data
- Phone numbers, IP addresses, quadtree spatial

**Staff-level choice guide:**
```ruby
# Standard lookups
add_index :users, :email                          # B-tree

# JSONB queries
add_index :users, :preferences, using: :gin       # GIN

# Array membership
add_index :posts, :tags, using: :gin               # GIN

# Time-series (if table is huge and append-only)
add_index :events, :created_at, using: :brin       # BRIN

# Geographic
add_index :sites, :location, using: :gist          # GiST (PostGIS)
```

---

### Q43. Explain database connection pooling in Rails. How do you tune it for production?

**Answer:**

**Pool architecture:**
- Each Rails process maintains a connection pool
- Pool checkout on request start, checkin at response end
- Threads within a process share the pool
- Default pool size: 5

**Configuration:**
```yaml
# config/database.yml
production:
  pool: <%= ENV.fetch("RAILS_MAX_THREADS", 5) %>
  checkout_timeout: 5
```

**Tuning formula:**
```
Total DB connections = Puma workers × Puma threads + Sidekiq processes × Sidekiq concurrency + Rails console + Rake tasks

Example:
- Puma: 4 workers × 5 threads = 20
- Sidekiq: 2 processes × 10 concurrency = 20
- Console + tasks: ~5
- Total: ~45 connections per app instance

With 10 app servers: 450 total connections
PostgreSQL max_connections default: 100 — you'll hit the limit!
```

**Solutions:**
1. **PgBouncer** (connection pooler) — essential at scale
   - Transaction pooling mode (connection per transaction, not per request)
   - Can handle 10,000+ client connections with 100 actual DB connections

2. **Tune PostgreSQL:**
```
max_connections = 500           # Or higher with PgBouncer
shared_buffers = 25% of RAM
effective_cache_size = 75% of RAM
work_mem = 4MB                  # Per-operation, not global
maintenance_work_mem = 256MB
```

**Staff-level:** PgBouncer is non-negotiable at Procore scale. Use transaction pooling. Monitor `active` vs `idle` connections with `pg_stat_activity`.

---

### Q44. How do you implement database sharding in a Rails application?

**Answer:**

**Horizontal sharding (by tenant):**
```ruby
# config/database.yml
production:
  primary:
    adapter: postgresql
  shard_one:
    adapter: postgresql
    host: shard1.procore.internal
  shard_two:
    adapter: postgresql
    host: shard2.procore.internal

# Rails 6+ built-in support
ActiveRecord::Base.connected_to(shard: :shard_one) do
  Project.create!(...)
end
```

**Determining shard:**
```ruby
# middleware or around_filter
shard = ShardResolver.for(current_organization)
ActiveRecord::Base.connected_to(shard: shard) do
  @controller.call(env)
end
```

**Challenges:**
- Cross-shard queries require application-level JOINs
- Schema migrations must run on all shards
- Connection pool management multiplies
- Re-sharding (splitting a hot shard) is complex

**Alternatives:**
- **Citus** (PostgreSQL extension): Distributed PostgreSQL, handles sharding transparently
- **Schema-based**: One schema per tenant in shared database (Rails multi-tenant gems)
- **Functional partitioning**: Split by entity type (not tenant)

**Staff-level:** For Procore, consider schema-per-tenant or Citus before application-level sharding. Application sharding adds significant operational complexity.

---

### Q45. Explain `find_each` vs `find_in_batches` vs raw `each` with a large dataset. When would you use each?

**Answer:**

**`each` (DON'T for large tables):**
```ruby
User.each { |u| process(u) }  # SELECT * FROM users — loads ALL into memory
```

**`find_each`:**
```ruby
User.find_each(batch_size: 1000) { |u| process(u) }
# SELECT * FROM users ORDER BY id LIMIT 1000
# SELECT * FROM users WHERE id > 1000 ORDER BY id LIMIT 1000
# ... repeats until done
```
- Orders by primary key
- Processes one record at a time
- Memory efficient (only one batch in memory)
- Can't specify custom order

**`find_in_batches`:**
```ruby
User.find_in_batches(batch_size: 1000) do |users|
  bulk_process(users)  # Process array of 1000 users
end
```
- Yields array of records
- Better for bulk operations (bulk insert, bulk API calls)
- Same ordering constraint

**Staff-level:** For 100M+ row tables, even `find_each` can be slow (many queries). Use `cursor` (PostgreSQL server-side cursor) or `COPY` for full-table operations. For updates, consider batch updates with `UPDATE ... WHERE id BETWEEN`.

---

### Q46. What is the purpose of `synchronize` in PostgreSQL migrations? When is it needed?

**Answer:**

`synchronize` is used in multi-database Rails apps to ensure schema consistency:
```ruby
class AddIndexToShards < ActiveRecord::Migration[7.1]
  def change
    add_index :projects, :external_id

    # Propagate to all shards
    ActiveRecord::Base.connection.migration_context.synchronize
  end
end
```

More commonly, the issue is about **schema cache synchronization** in multi-server deployments — ensuring all app servers refresh their schema cache after migrations.

**Staff-level:** In Kubernetes deployments with rolling restarts, old pods may have stale schema caches. Use `ActiveRecord::Base.connection.schema_cache.clear!` after migrations, or restart all pods post-migration.

---

### Q47. Explain `select`, `pluck`, and `pick` in ActiveRecord. When is each appropriate?

**Answer:**

**`select`:**
```ruby
User.select(:id, :name)  # Returns User objects with only id and name loaded
# SELECT "users"."id", "users"."name" FROM "users"
# user.id works, user.email raises MissingAttributeError
```

**`pluck`:**
```ruby
User.pluck(:name)           # Returns array of names: ["Alice", "Bob"]
User.pluck(:id, :name)      # Returns array of arrays: [[1, "Alice"], [2, "Bob"]]
```
- Doesn't instantiate AR objects — fastest for simple lookups
- Goes straight to primitive values
- Can't chain further AR queries after pluck

**`pick` (Rails 6+):**
```ruby
User.where(active: true).pick(:name)  # Returns single value: "Alice"
# Equivalent to pluck(:name).first but more efficient (adds LIMIT 1)
```

**Staff-level:** Use `pluck` for dropdown options, export data, anything that doesn't need full objects. Use `select` when you need AR objects but want to reduce I/O. `pick` for single-value lookups (feature flags, settings).

---

### Q48. How do you handle complex database queries that are difficult to express in ActiveRecord?

**Answer:**

**Options in order of preference:**

1. **Arel (SQL AST manager):**
```ruby
users = User.arel_table
User.where(users[:age].gt(18).and(users[:name].matches("A%")))
```

2. **`find_by_sql` / `select_all`:**
```ruby
User.find_by_sql([
  "SELECT * FROM users WHERE ST_DWithin(location, ST_Point(?, ?), ?)",
  lng, lat, radius
])
```

3. **`from` with subqueries:**
```ruby
User.from(
  User.select("users.*, ROW_NUMBER() OVER (PARTITION BY org_id) as rn"),
  :users
).where("rn <= 5")
```

4. **Database views:**
```ruby
class ActiveProjectReport < ApplicationRecord
  self.table_name = "active_project_reports"  # database view
end
```

5. **Stored procedures** (last resort — harder to version control and test)

**Staff-level:** Prefer database views for complex reporting queries — they're versioned in migrations, optimizable by PostgreSQL, and composable with ActiveRecord. Arel is powerful but underdocumented.

---

### Q49. Explain PostgreSQL's `EXPLAIN ANALYZE` output. How do you read it?

**Answer:**

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT * FROM projects WHERE org_id = 123 ORDER BY updated_at DESC LIMIT 20;
```

**Key fields:**
- **Node type**: `Seq Scan`, `Index Scan`, `Bitmap Heap Scan`, `Hash Join`, `Nested Loop`, `Sort`
- **cost=**: Planner's cost estimate (startup..total)
- **actual time=**: Real execution time in milliseconds
- **rows=**: Estimated rows vs actual rows (should match closely)
- **loops=**: How many times this node executed
- **Buffers**: `shared hit` (cache), `shared read` (disk) — indicates I/O

**Reading order:**
Read from innermost (most indented) to outermost. The innermost nodes execute first.

**Red flags:**
- Seq Scan on large tables with filters → missing index
- Actual rows >> estimated rows → stale statistics (run ANALYZE)
- Sort Method: external merge → not enough work_mem
- Buffers: high shared read → data not in cache, I/O bound
- Nested Loop with high loops on large table → cardinality estimate wrong

**Staff-level:** Always use `EXPLAIN (ANALYZE, BUFFERS)` in production-like environments with production-like data volumes. PostgreSQL's planner makes different decisions based on data distribution.

---

### Q50. How do you implement soft deletes in Rails? Compare `acts_as_paranoid`, `discard`, and custom implementations.

**Answer:**

**`discard` gem (recommended):**
```ruby
class Project < ApplicationRecord
  include Discard::Model
  discard_column :deleted_at
  default_scope -> { kept }  # Optional, explicit is better
end

project.discard!        # Sets deleted_at
Project.kept            # Not discarded
Project.discarded       # Only discarded
project.undiscard!      # Restore
```

**`acts_as_paranoid` (legacy):**
- Uses `default_scope` (problematic — easy to accidentally include deleted records)
- More magic, harder to reason about
- Can cause subtle bugs with associations

**Custom implementation:**
```ruby
class Project < ApplicationRecord
  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

  def destroy
    update!(deleted_at: Time.current, deleted_by: Current.user.id)
  end

  def restore!
    update!(deleted_at: nil, deleted_by: nil)
  end
end
```

**Staff-level:** Prefer `discard` with explicit scopes (no `default_scope`). Add partial indexes for performance:
```ruby
add_index :projects, :org_id, where: "deleted_at IS NULL", name: "idx_active_projects_by_org"
```

---

### Q51. Explain the difference between `lock!`, `with_lock`, optimistic locking, and advisory locks.

**Answer:**

**Pessimistic locking (`with_lock`):**
```ruby
project.with_lock do
  # SELECT * FROM projects WHERE id = 1 FOR UPDATE
  project.update!(budget: project.budget + amount)
end  # Lock released at transaction end
```
- Database-level row lock (FOR UPDATE)
- Blocks other transactions trying to lock same row
- Use for financial operations, inventory, seat selection

**`lock!`:**
```ruby
project.lock!  # Reloads with FOR UPDATE lock
```

**Optimistic locking:**
```ruby
# lock_version integer column
project.update!(name: "New Name")  # WHERE id = 1 AND lock_version = 5
# Raises ActiveRecord::StaleObjectError if version changed
```
- No database lock — detects conflicts at update time
- Better for high-read, low-conflict scenarios
- User-facing retry logic needed

**Advisory locks (PostgreSQL):**
```ruby
# Application-level named locks, not tied to rows
ActiveRecord::Base.connection.execute("SELECT pg_advisory_lock(12345)")
# Useful for preventing duplicate background jobs, distributed cron
```

**Staff-level:** Use pessimistic locks for financial consistency, optimistic for user edits, advisory locks for job deduplication. Always keep lock duration minimal — never hold locks during HTTP calls.

---

### Q52. How do you design and implement database views in Rails? What about materialized views?

**Answer:**

**Regular views (computed on read):**
```ruby
class CreateProjectSummaryView < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL
      CREATE VIEW project_summaries AS
        SELECT 
          p.id,
          p.name,
          COUNT(t.id) as task_count,
          SUM(t.budget) as total_budget
        FROM projects p
        LEFT JOIN tasks t ON t.project_id = p.id
        GROUP BY p.id, p.name
    SQL
  end
end

class ProjectSummary < ApplicationRecord
  self.table_name = "project_summaries"
  # Read-only by default
end
```

**Materialized views (cached, needs refresh):**
```ruby
execute "CREATE MATERIALIZED VIEW project_stats AS ..."
execute "CREATE UNIQUE INDEX idx_project_stats ON project_stats (project_id)"

# Refresh strategies:
# 1. Scheduled (cron)
# 2. Trigger-based
# 3. On-demand
ProjectStat.connection.execute("REFRESH MATERIALIZED VIEW CONCURRENTLY project_stats")
# CONCURRENTLY doesn't block reads, requires unique index
```

**Staff-level:** Materialized views are perfect for Procore's project dashboards — complex aggregations that don't need real-time accuracy. Schedule refresh every 15 minutes. Use `CONCURRENTLY` to avoid blocking reads.

---

### Q53. Explain PostgreSQL's `LATERAL` JOIN and when it's useful in Rails.

**Answer:**

**`LATERAL` allows subqueries to reference columns from preceding tables:**

```sql
-- For each project, get its 5 most recent updates
SELECT p.name, recent_updates.*
FROM projects p
LEFT JOIN LATERAL (
  SELECT * FROM updates 
  WHERE updates.project_id = p.id 
  ORDER BY created_at DESC 
  LIMIT 5
) recent_updates ON true;
```

**In Rails:**
```ruby
# Using Arel or find_by_sql
Project.find_by_sql([
  "SELECT p.*, u.title as latest_update_title
   FROM projects p
   LEFT JOIN LATERAL (
     SELECT title FROM updates 
     WHERE project_id = p.id 
     ORDER BY created_at DESC LIMIT 1
   ) u ON true
   WHERE p.org_id = ?", org_id
])
```

**Use cases:**
- "Top N per group" queries (top 5 updates per project)
- Correlated subqueries that need to return multiple rows
- More efficient than window functions for small N

**Staff-level:** `LATERAL` is often more readable and performant than `ROW_NUMBER() OVER` for "latest per group" queries. PostgreSQL can optimize LATERAL joins better than equivalent correlated subqueries.

---

### Q54. How do you handle JSON/JSONB data in PostgreSQL from Rails? What are best practices?

**Answer:**

**Storage:**
```ruby
create_table :projects do |t|
  t.jsonb :metadata, default: {}, null: false
  t.jsonb :settings, default: {}, null: false
end

# Indexes
add_index :projects, :metadata, using: :gin
add_index :projects, "((metadata->>'external_id'))", name: "idx_projects_external_id"
```

**Querying:**
```ruby
# Exact match
Project.where("metadata @> ?", { source: "import" }.to_json)

# Key existence
Project.where("metadata ? :key", key: "legacy_id")

# Path query
Project.where("metadata->>'status' = ?", "active")

# Combine with GIN index
Project.where("metadata @> ?", { tags: ["urgent"] }.to_json)
```

**Best practices:**
- Use `jsonb` not `json` (binary storage, indexable, more operators)
- Add GIN indexes for containment queries (`@>`, `?`, `?&`)
- Add expression indexes for frequently queried keys
- Don't store everything as JSON — normalized columns are more efficient
- Use `store_accessor` for frequently accessed keys:
```ruby
store_accessor :metadata, :source, :external_id, :legacy_reference
```

**Staff-level:** JSONB is great for flexible schemas, but don't use it to avoid proper data modeling. Index the keys you query — unindexed JSONB queries are full table scans. For data that needs to be joined or constrained, use regular columns.

---

### Q55. What are `timestamptz` vs `timestamp` in PostgreSQL? Which should Rails apps use?

**Answer:**

**`timestamp without time zone` (Rails default — WRONG for most cases):**
- Stores exactly what you insert, no zone conversion
- `"2024-01-01 12:00:00"` stored as-is
- Meaning changes if application timezone changes

**`timestamptz` (timestamp with time zone — RECOMMENDED):**
- Stores as UTC internally
- Converts to session timezone on output
- `"2024-01-01 12:00:00-05"` → stored as `2024-01-01 17:00:00Z`
- Unambiguous regardless of application timezone

**Rails configuration:**
```ruby
# config/application.rb
config.active_record.default_timezone = :utc
config.time_zone = "Pacific Time (US & Canada)"

# Use timestamptz in migrations (Rails 7+ default for PostgreSQL)
t.timestamptz :created_at  # Instead of t.timestamp :created_at
```

**Staff-level:** Always use `timestamptz`. The performance difference is negligible. `timestamp without timezone` causes subtle bugs when applications span multiple timezones — construction projects definitely do.

---

## Section D: Scaling Rails & Background Jobs (15 Questions)

---

### Q56. How would you scale a Rails application from 1K to 1M+ requests per day?

**Answer:**

**Phase 1: Application efficiency (1K-10K requests/day)**
- Fix N+1 queries with `includes`, counter caches
- Add database indexes for slow queries
- Implement caching (Russian doll, fragment, low-level Redis)
- Move slow operations to background jobs (Sidekiq)

**Phase 2: Horizontal scaling (10K-100K/day)**
- Multiple Puma workers: `workers Integer(ENV.fetch('WEB_CONCURRENCY', 4))`
- Database connection pooling + PgBouncer
- Redis for sessions and caching (not just in-memory)
- CDN for static assets (CloudFront)
- Read replicas for SELECT queries:
```ruby
# Automatic replica routing
ActiveRecord::Base.connected_to(role: :reading) do
  Project.count  # Goes to replica
end
```

**Phase 3: Architecture changes (100K-1M+/day)**
- Service extraction for hot paths (document processing, notifications)
- Database partitioning by tenant/date
- Caching at every layer (HTTP, database query, application, CDN)
- Event-driven architecture for decoupling
- Microservices or modular monolith with engines

**Phase 4: Multi-region (1M+/day, global)**
- Read replicas in geographic regions
- Cache warming per region
- Event bus with cross-region replication
- CDN with edge caching

**Staff-level insight:** Don't prematurely optimize. At each phase, identify the actual bottleneck (database, application code, external APIs) before scaling. The right answer always starts with "measure first."

---

### Q57. Explain Russian Doll caching in Rails. How does it work and when does it break down?

**Answer:**

**Mechanism:** Nested fragment caching with cache key versioning:
```erb
<% cache project do %>
  <div class="project">
    <h1><%= project.name %></h1>
    <% cache project.tasks do %>
      <ul>
        <% project.tasks.each do |task| %>
          <% cache task do %>
            <li><%= task.name %></li>
          <% end %>
        <% end %>
      </ul>
    <% end %>
  </div>
<% end %>
```

**How it works:**
- Cache key = `"projects/1-20240101120000"` (includes `updated_at`)
- When project updates, outer cache key changes → re-render everything
- When only one task updates, only that task's fragment re-renders
- Parent fragment is served from cache

**When it breaks down:**
- Highly dynamic content (cache hit rate too low)
- Complex authorization (cache varies by user role — too many variants)
- Cache stampede on invalidation (many requests hit at once when cache expires)
- Memory pressure from too many fragments
- Associations without `touch: true` — cache doesn't invalidate when child changes

**Staff-level fix:**
```ruby
class Task < ApplicationRecord
  belongs_to :project, touch: true  # Updates project.updated_at on save
end
```

---

### Q58. How do you prevent cache stampedes and thundering herd problems?

**Answer:**

**Cache stampede:** Many requests simultaneously hit backend when cache expires.

**Solutions:**

1. **Cache warming:** Pre-populate before expiration
2. **Probabilistic early expiration:**
```ruby
# Expire cache slightly before actual TTL based on probability
ttl = base_ttl * (rand * 0.2 + 0.9)  # 90-110% of TTL
```

3. **Mutex/lease pattern:**
```ruby
# Only one process rebuilds the cache
def fetch_with_lock(key, ttl: 1.hour)
  value = Rails.cache.read(key)
  return value if value

  # Acquire 30-second lock to rebuild
  if Rails.cache.write("lock:#{key}", true, expires_in: 30.seconds, unless_exist: true)
    value = yield
    Rails.cache.write(key, value, expires_in: ttl)
    Rails.cache.delete("lock:#{key}")
  else
    sleep 0.1
    fetch_with_lock(key, ttl: ttl) { yield }
  end
  value
end
```

4. **External expiration:** Don't use TTL — actively invalidate when data changes

**Staff-level:** At Procore scale, use Redis distributed locks (Redlock) or lease-based expiration. For critical paths, consider stale-while-revalidate: serve stale cache while refreshing in background.

---

### Q59. Compare Sidekiq, DelayedJob, Resque, and Solid Queue. What would you choose for Procore?

**Answer:**

| Feature | Sidekiq | DelayedJob | Resque | Solid Queue |
|---------|---------|------------|--------|-------------|
| Storage | Redis | PostgreSQL | Redis | PostgreSQL |
| Concurrency | Threads | Forks | Forks | Threads |
| Speed | Very fast | Moderate | Moderate | Good |
| Reliability | Good (paid for best) | Good (DB persistence) | Good | Best (DB persistence) |
| Monitoring | Excellent | Basic | Basic | Rails-native |
| Complexity | Medium | Low | Medium | Low |

**Sidekiq (current industry standard):**
- Uses threads — memory efficient
- Redis-backed — very fast
- Sidekiq Pro/Enterprise: Batch jobs, unique jobs, encryption
- Requires Redis (another infrastructure dependency)

**Solid Queue (Rails 8+ default, future):**
- PostgreSQL-backed — no Redis needed
- Native Rails integration
- Good for teams wanting fewer infrastructure dependencies

**For Procore (millions of users, high reliability):**
- **Sidekiq Enterprise** is the right choice today
- Redis Sentinel/Cluster for HA
- Batches for large report generation
- Unique jobs prevent duplicate processing
- Rate limiters for external API calls

**Staff-level:** The key consideration is reliability. With Redis, configure persistent queues (`save` AOF) and use Sidekiq's `super_fetch` (Pro) for at-least-once delivery. For financial operations, use database-backed jobs (Solid Queue) or ensure idempotency.

---

### Q60. How do you design idempotent background jobs? Why is this critical at scale?

**Answer:**

**Idempotency:** Running a job multiple times produces the same result as running once.

**Critical because:**
- Jobs retry on failure (duplicate execution risk)
- Distributed systems have at-least-once delivery semantics
- Network timeouts cause "did it process?" uncertainty

**Design patterns:**

1. **Database-level idempotency:**
```ruby
class ProcessPaymentJob
  include Sidekiq::Worker

  def perform(order_id)
    Order.transaction do
      order = Order.lock.find(order_id)
      return if order.payment_processed_at.present?  # Already done

      process_payment(order)
      order.update!(payment_processed_at: Time.current)
    end
  end
end
```

2. **Idempotency keys:**
```ruby
# Store processed keys
Redis.current.setex("idempotency:#{key}", 86400, "processed")
return if Redis.current.exists?("idempotency:#{key}")
```

3. **Natural idempotency:**
```ruby
# Setting status to "active" is idempotent
# Incrementing a counter is NOT idempotent
```

4. **Upsert instead of insert:**
```ruby
# ON CONFLICT DO NOTHING / ON CONFLICT DO UPDATE
Model.upsert({ id: id, status: "completed" }, unique_by: :id)
```

**Staff-level:** Always design for at-least-once delivery. Every job that modifies state must be idempotent. Use database constraints as the source of truth (Redis can lose data).

---

### Q61. Explain Sidekiq's retry mechanism. How do you handle dead letter queues?

**Answer:**

**Retry behavior:**
- Default: 25 retries over ~21 days
- Backoff: Exponential (formula: `(count ** 4) + 15 + (rand(30) * (count + 1))` seconds)
- After 25 failures → moved to Dead queue (Dead Letter Queue)

**Configuration:**
```ruby
class CriticalJob
  include Sidekiq::Worker
  sidekiq_options retry: 5, dead: true, queue: "critical"

  # Custom retry for specific errors
  sidekiq_retry_in do |count, exception|
    case exception
    when ExternalApiError
      (count ** 2) * 60  # 1min, 4min, 9min...
    else
      :discard  # Don't retry
    end
  end
end
```

**Dead letter handling:**
- Sidekiq Web UI for manual inspection/retry
- Morgue pattern: DLQ job triggers alert + stores for analysis
- Automatic replay after bug fix:
```ruby
# Rake task to replay dead jobs
namespace :sidekiq do
  task replay_dead: :environment do
    Sidekiq::DeadSet.new.each do |job|
      job.retry if job.error_class == "FixedBugError"
    end
  end
end
```

**Staff-level:** Monitor DLQ size as a key metric. A growing DLQ indicates systemic problems. Alert on it. For critical jobs, implement a "poison pill" handler that routes failed jobs to a separate queue for manual review.

---

### Q62. How do you handle rate limiting when calling external APIs from background jobs?

**Answer:**

**Sidekiq rate limiter (Enterprise):**
```ruby
class ApiCallJob
  include Sidekiq::Worker
  sidekiq_options throttle: {
    threshold: 100,      # 100 requests
    period: 60,          # per 60 seconds
    key: ->(account_id) { "api_limit:#{account_id}" }
  }
end
```

**Custom token bucket with Redis:**
```ruby
class RateLimiter
  def self.acquire?(key, limit:, window: 60)
    redis = Redis.current
    now = Time.now.to_i

    redis.multi do |pipeline|
      pipeline.zremrangebyscore(key, 0, now - window)
      pipeline.zcard(key)
      pipeline.zadd(key, now, "#{now}-#{SecureRandom.hex(4)}")
      pipeline.expire(key, window)
    end.then do |_, count, _, _|
      count < limit
    end
  end
end
```

**Backoff on rate limit errors:**
```ruby
rescue ExternalApi::RateLimitError => e
  retry_at = Time.at(e.retry_after_timestamp)
  self.class.perform_at(retry_at, args)
end
```

**Staff-level:** Never let rate limit errors bubble up to standard retries (exponential backoff won't match API reset windows). Use scheduled retries aligned with API rate limit windows.

---

### Q63. What are ActionMailer previews and how do you test emails in Rails?

**Answer:**

**Previews:**
```ruby
# test/mailers/previews/user_mailer_preview.rb
class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.welcome_email(User.first)
  end

  def project_invitation
    UserMailer.project_invitation(User.first, Project.first)
  end
end
# Accessible at /rails/mailers in development
```

**Testing:**
```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "welcome email" do
    user = users(:alice)
    email = UserMailer.welcome_email(user)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["noreply@procore.com"], email.from
    assert_equal [user.email], email.to
    assert_match "Welcome", email.subject
  end
end
```

**Staff-level:** Always use `deliver_later` (ActiveJob) in production, not `deliver_now`. Test both the mailer unit and the integration (was the job enqueued?). Use `email-spec` gem for more expressive email assertions.

---

### Q64. Explain `deliver_later` vs `deliver_now`. What are the reliability implications?

**Answer:**

**`deliver_now`:**
- Sends email synchronously
- Blocks the request/response cycle
- Email failure causes request to fail
- Use only in: console, rake tasks, or when email is the primary action

**`deliver_later`:**
- Enqueues ActiveJob
- Non-blocking — request continues immediately
- Job worker sends email independently
- Email failure doesn't affect the request
- Retry logic applies to email delivery

**Reliability patterns:**
```ruby
# Critical email (must send) — use at-least-once delivery
UserMailer.invoice_email(user).deliver_later(priority: :high, wait: 5.minutes)

# Fire-and-forget email — don't fail the request if email fails
begin
  UserMailer.notification(user).deliver_later
rescue Redis::CannotConnectError
  Rails.logger.warn("Email queue unavailable, email skipped")
end
```

**Staff-level:** Never send emails synchronously in request handlers. Even for "critical" emails, use `deliver_later` with a short delay — it gives the transaction time to commit (avoid sending email for rolled-back transactions).

---

### Q65. How do you monitor background job health in production? What are the key metrics?

**Answer:**

**Essential metrics:**

| Metric | Target | Alert Threshold |
|--------|--------|----------------|
| Queue depth (jobs waiting) | < 100 | > 1000 |
| Job processing time (p95) | < 5s per job | > 30s |
| Job failure rate | < 0.1% | > 1% |
| Worker utilization | 60-80% | > 95% or < 10% |
| Retry queue depth | Low | Growing trend |
| DLQ size | 0 | > 10 |
| Latency (time in queue) | < 1s | > 60s |

**Implementation:**
```ruby
# Sidekiq middleware for metrics
class MetricsMiddleware
  def call(worker, job, queue)
    start = Time.current
    yield
  ensure
    duration = Time.current - start
    StatsD.measure("sidekiq.job.duration", duration, tags: { worker: worker.class.name })
    StatsD.increment("sidekiq.job.completed", tags: { worker: worker.class.name, queue: queue })
  end
end

# Sidekiq config
Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add MetricsMiddleware
  end
end
```

**Staff-level:** Dashboard these metrics in Grafana. Alert on queue depth (indicates insufficient workers) and failure rate (indicates code/environment problems). Set up automatic scaling of Sidekiq workers based on queue depth.

---

### Q66. How does database connection management work with background jobs? What can go wrong?

**Answer:**

**Connection lifecycle:**
- Each Sidekiq thread has its own database connection (from the pool)
- Connection checked out when first needed, returned to pool after job completes
- Pool size must be ≥ thread count

**Common problems:**

1. **Pool exhaustion:**
```ruby
# If pool: 5, concurrency: 10 → 5 threads will wait
# Fix: pool size = concurrency + 2 (buffer)
```

2. **Connection leaks:**
- Custom threads that checkout connections but don't check them in
- `ActiveRecord::Base.clear_active_connections!` at end of custom thread

3. **Long-running jobs hold connections:**
```ruby
# Release connection while doing non-DB work
ActiveRecord::Base.connection_pool.release_connection
sleep(10)  # External API call
ActiveRecord::Base.connection_pool.with_connection do
  # Re-acquire when needed
end
```

4. **Prepared statement exhaustion:**
- PostgreSQL default: `max_prepared_transactions = 0`
- Can cause issues with complex transactions

**Staff-level:** Always set `pool` ≥ Sidekiq concurrency. Use `reaping_frequency` to reclaim leaked connections. For long-running jobs, explicitly release connections during I/O waits.

---

### Q67. What strategies do you use for job prioritization and queue segregation?

**Answer:**

**Queue design:**
```ruby
# config/sidekiq.yml
:queues:
  - [critical, 10]    # Highest weight — processed most
  - [default, 5]
  - [low, 2]
  - [mailers, 3]

# Separate workers per queue
critical: bundle exec sidekiq -q critical -c 10
default: bundle exec sidekiq -q default,mailers -c 5
low: bundle exec sidekiq -q low -c 3
```

**Priority patterns:**
- **Critical**: Webhook delivery, payment processing, cache invalidation
- **Default**: Standard business logic, data processing
- **Low**: Report generation, data cleanup, analytics
- **Mailers**: Email delivery (separate to prevent queue blocking)

**Dynamic routing:**
```ruby
# Route based on tenant tier
queue_name = organization.enterprise? ? "critical" : "default"
MyJob.set(queue: queue_name).perform_later(args)
```

**Staff-level:** Separate worker pools per queue so a backlog in one queue doesn't affect others. Enterprise customer jobs go to dedicated queues with more workers. Monitor queue depth per queue.

---

### Q68. How do you handle transactional outbox pattern in Rails? Why is it important?

**Answer:**

**Problem:** Side effects in transactions — if you commit DB changes but job enqueue fails, state is inconsistent.

**Transactional outbox pattern:**
```ruby
# 1. Write event to outbox table in same transaction
ActiveRecord::Base.transaction do
  project.update!(status: "completed")

  OutboxEvent.create!(
    aggregate_type: "Project",
    aggregate_id: project.id,
    event_type: "ProjectCompleted",
    payload: { project_id: project.id, completed_by: user.id }
  )
end  # Both commit together atomically

# 2. Background job polls outbox table and publishes events
class OutboxPublisherJob
  def perform
    OutboxEvent.where(published_at: nil).order(:id).limit(100).each do |event|
      publish_to_kafka(event)
      event.update!(published_at: Time.current)
    end
  end
end
```

**Benefits:**
- DB transaction guarantees consistency
- Outbox job retries if publish fails
- No message loss
- Enables event sourcing

**Staff-level:** This is the gold standard for reliable event publishing in Rails. Use `rails_event_store` gem or implement custom. At Procore scale, this enables reliable cross-service communication.

---

### Q69. How would you implement a recurring job scheduler (like cron) in a distributed Rails environment?

**Answer:**

**Options:**

1. **Whenever gem + cron** (single server — not distributed)
2. **Sidekiq-Cron** (Redis-based, distributed-safe)
```ruby
# config/schedule.yml
my_scheduled_job:
  cron: "0 */6 * * *"  # Every 6 hours
  class: "CleanupOldDataJob"
  queue: low
```

3. **Custom distributed lock** (PostgreSQL advisory locks)
```ruby
class DistributedCronJob
  def perform
    # Only one server runs this
    result = ActiveRecord::Base.connection.execute(
      "SELECT pg_try_advisory_lock(12345)"
    )
    return unless result.first["pg_try_advisory_lock"]

    begin
      run_scheduled_task
    ensure
      ActiveRecord::Base.connection.execute("SELECT pg_advisory_unlock(12345)")
    end
  end
end
```

4. **Kubernetes CronJob** (best for K8s environments)
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: daily-cleanup
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: rails
            command: ["bundle", "exec", "rake", "cleanup:old_data"]
```

**Staff-level:** Use Kubernetes CronJobs for infrastructure-level tasks (backups, cleanup) and Sidekiq-Cron for business-logic recurring jobs. K8s CronJobs provide pod-level isolation and resource limits.

---

### Q70. How do you handle database query timeouts in Rails? At the application and database level?

**Answer:**

**Application level:**
```ruby
# Global statement timeout
ActiveRecord::Base.connection.execute("SET statement_timeout = '5s'")

# Per-query timeout
ActiveRecord::Base.connection.execute("SET LOCAL statement_timeout = '10s'")
Project.where(complex_conditions).to_a

# Rails 7.1+ built-in
Project.timeout(5).where(...)
```

**Database level:**
```
# postgresql.conf
statement_timeout = 30s          # Global default
idle_in_transaction_session_timeout = 60s  # Kill idle transactions
lock_timeout = 5s                # Don't wait long for locks
```

**Controller-level circuit breaker:**
```ruby
begin
  Timeout.timeout(10) do
    @projects = complex_query
  end
rescue Timeout::Error
  @projects = cached_fallback
  @partial_results = true
end
```

**Staff-level:** Set aggressive statement timeouts (5-10s) for web requests. Allow longer (60s) for background jobs. Always handle `ActiveRecord::QueryTimeout` gracefully — don't let it become a 500 error for users.

---

## Section E: API Design, Refactoring & OOP/SOLID (15 Questions)

---

### Q71. How do you design a versioned REST API in Rails? What are best practices?

**Answer:**

**Namespace-based versioning:**
```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :projects, only: [:index, :show, :create, :update]
  end
  namespace :v2 do
    resources :projects  # New behavior
    resources :documents  # New resource
  end
end

# Controllers
app/controllers/api/v1/projects_controller.rb
app/controllers/api/v2/projects_controller.rb
```

**Best practices:**
- Serializers per version (different fields, different structures)
- Shared business logic in service objects (not duplicated)
- Content negotiation: `Accept: application/vnd.procore.v2+json`
- Deprecation headers: `Deprecation: true`, `Sunset: Sat, 01 Jun 2025 00:00:00 GMT`
- API documentation: OpenAPI/Swagger auto-generated

**Breaking vs non-breaking changes:**
- Adding fields: non-breaking (no version bump)
- Removing fields: breaking (new version)
- Changing behavior: breaking (new version)
- Adding endpoints: non-breaking

**Staff-level:** Maintain at most 2 active versions. Use feature flags for gradual migration. Log which clients use old versions for targeted outreach.

---

### Q72. What makes a good service object in Rails? Show before/after of a fat controller refactoring.

**Answer:**

**Bad (fat controller):**
```ruby
class ProjectsController < ApplicationController
  def create
    @project = current_org.projects.build(project_params)

    if @project.save
      # 30+ lines of side effects mixed in
      current_org.users.each do |user|
        ProjectMailer.invitation(user, @project).deliver_later
      end

      ActivityLog.create!(user: current_user, action: "created_project", target: @project)

      if @project.budget > 1_000_000
        NotificationService.notify_admins("Large project created: #{@project.name}")
      end

      ExternalAccountingService.create_project(@project)

      redirect_to @project, notice: "Project created"
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

**Good (service object):**
```ruby
class ProjectsController < ApplicationController
  def create
    result = ProjectCreationService.new(
      organization: current_org,
      creator: current_user,
      params: project_params
    ).call

    if result.success?
      redirect_to result.project, notice: "Project created"
    else
      @project = result.project
      render :new, status: :unprocessable_entity
    end
  end
end

# app/services/project_creation_service.rb
class ProjectCreationService
  Result = Struct.new(:success?, :project, :error, keyword_init: true)

  def initialize(organization:, creator:, params:)
    @organization = organization
    @creator = creator
    @params = params
  end

  def call
    project = @organization.projects.build(@params)

    return Result.new(success?: false, project: project) unless project.valid?

    ActiveRecord::Base.transaction do
      project.save!
      notify_team_members(project)
      log_creation(project)
      notify_admins_if_large(project)
      sync_to_accounting(project)
    end

    Result.new(success?: true, project: project)
  rescue StandardError => e
    Rails.logger.error("Project creation failed: #{e.message}")
    Result.new(success?: false, project: project, error: e)
  end

  private

  def notify_team_members(project)
    ProjectInvitationJob.perform_later(project, @creator)
  end

  def log_creation(project)
    ActivityLogger.log(action: "project_created", actor: @creator, target: project)
  end

  def notify_admins_if_large(project)
    return unless project.budget.to_i > 1_000_000
    AdminNotificationJob.perform_later("Large project: #{project.name}")
  end

  def sync_to_accounting(project)
    AccountingSyncJob.perform_later(project)
  end
end
```

**Staff-level:** The service object:
- Has single responsibility (SRP)
- Returns explicit result objects (don't raise for expected failures)
- Orchestrates, doesn't implement details (delegates to jobs)
- Transaction wraps the critical section
- Side effects happen after persistence

---

### Q73. Explain the SOLID principles and how they apply to Rails applications.

**Answer:**

**S — Single Responsibility Principle:**
- A class should have one reason to change
- Controllers handle HTTP, models handle persistence, services handle business logic
- Break down fat models: `ProjectPricingCalculator`, `ProjectPermissionChecker`

**O — Open/Closed Principle:**
- Open for extension, closed for modification
- Use strategies/policies instead of conditionals:
```ruby
# Bad: Modifying class for each new type
class DocumentProcessor
  def process(doc)
    if doc.pdf?
      process_pdf(doc)
    elsif doc.dwg?
      process_dwg(doc)
    end
  end
end

# Good: Extension via new classes
class DocumentProcessor
  def self.register(handler)
    @handlers ||= {}
    @handlers[handler.mime_type] = handler
  end

  def process(doc)
    handler = self.class.handlers[doc.mime_type]
    handler.new.process(doc)
  end
end

DocumentProcessor.register(PdfHandler)
DocumentProcessor.register(DwgHandler)  # New type without modifying processor
```

**L — Liskov Substitution Principle:**
- Subtypes must be substitutable for their base types
- Don't override methods to throw "not implemented" errors
- Good indicator: inheritance is wrong when child restricts parent's behavior

**I — Interface Segregation Principle:**
- Don't force clients to depend on methods they don't use
- Split large interfaces: `ProjectReadable`, `ProjectWritable`, `ProjectDeletable`

**D — Dependency Inversion Principle:**
- Depend on abstractions, not concretions
- Use dependency injection:
```ruby
class InvoiceGenerator
  def initialize(payment_gateway: StripeGateway.new, tax_calculator: TaxCalculator.new)
    @payment_gateway = payment_gateway
    @tax_calculator = tax_calculator
  end
end

# In tests:
InvoiceGenerator.new(payment_gateway: FakeGateway.new)
```

**Staff-level:** SOLID prevents the "big ball of mud." At Procore scale, violations of SRP and DIP are the most common causes of technical debt.

---

### Q74. What are the common code smells in Rails applications? How do you identify and fix them?

**Answer:**

**1. Fat Model:**
- Model has 500+ lines, 20+ methods
- Fix: Extract service objects, query objects, value objects

**2. Fat Controller:**
- Business logic in controller, not model/service
- Fix: Move to service objects, keep controllers as HTTP adapters

**3. God Object:**
- Class knows/does everything (User model with auth, billing, preferences, notifications)
- Fix: Split into focused classes (UserAuthenticator, UserBilling, UserPreferences)

**4. Feature Envy:**
- Method uses another object's data more than its own
- Fix: Move method to the object it envies

**5. Law of Demeter violations:**
```ruby
# Bad: Chaining through objects
project.owner.company.billing_address.street

# Good: Tell, don't ask
project.owner_address_street  # Encapsulate the chain
```

**6. Shotgun Surgery:**
- One change requires modifying many classes
- Fix: Consolidate related behavior (missing abstraction)

**7. Primitive Obsession:**
- Using strings/integers instead of value objects
```ruby
# Bad: String for money, date ranges, coordinates
project.budget = "150000.50 USD"

# Good: Value objects
project.budget = Money.new(150000.50, :usd)
project.timeline = DateRange.new(start_date, end_date)
```

**Staff-level:** Use tools like `rubycritic`, `flay`, and `flog` to detect smells automatically. Flog scores > 20 indicate complex methods needing refactoring.

---

### Q75. How do you refactor a 2000-line Rails model? Walk through your approach.

**Answer:**

**Step 1: Analyze dependencies**
```bash
# Find what uses each method
grep -r "User\." app/ --include="*.rb" | cut -d: -f2 | sort | uniq -c | sort -rn
```

**Step 2: Categorize methods**
- Authentication/authorization → `UserAuthentication` concern/service
- Billing/subscription → `UserBilling` service
- Profile/preferences → `UserProfile` value object
- Notifications → `UserNotificationPreferences` concern
- Validation logic → Keep in model or form objects

**Step 3: Extract incrementally**
```ruby
# Extract query methods to Query Object
class UserQuery
  def self.recently_active(since: 30.days.ago)
    User.where("last_active_at > ?", since)
  end

  def self.with_overdue_invoices
    User.joins(:invoices).where(invoices: { status: "overdue" })
  end
end

# Extract calculations to Value Object
class UserPermissions
  def initialize(user)
    @user = user
  end

  def can_edit_project?(project)
    @user.admin? || project.members.include?(@user)
  end
end

# Extract services
class UserDeactivationService
  def initialize(user)
    @user = user
  end

  def deactivate!
    ActiveRecord::Base.transaction do
      @user.update!(active: false, deactivated_at: Time.current)
      revoke_access_tokens
      cancel_subscriptions
      notify_team
    end
  end
end
```

**Step 4: Update callers gradually**
- Use deprecation warnings for old methods
- Update tests incrementally
- Feature flag risky changes

**Staff-level:** Never do a big-bang refactor. Extract one category at a time, ship it, monitor, then proceed. Each extraction should be its own PR.

---

### Q76. What is the Transaction Script vs Domain Model pattern? When to use each in Rails?

**Answer:**

**Transaction Script:**
- Organize logic by procedure/script, not by object
- Each operation is a class/method
- Simple, procedural
- Good for: Simple CRUD, straightforward workflows
```ruby
class CreateInvoiceScript
  def self.call(order)
    Invoice.create!(order: order, amount: order.total, due_date: 30.days.from_now)
    order.update!(invoiced: true)
  end
end
```

**Domain Model:**
- Rich objects with behavior and state
- Objects encapsulate business rules
- Good for: Complex domains, many interacting rules
```ruby
class Invoice
  def self.generate_for(order)
    new(order: order, amount: order.calculate_total, due_date: 30.days.from_now)
  end

  def overdue?
    due_date < Date.current && !paid?
  end

  def calculate_late_fee
    amount * 0.015 * days_overdue
  end
end
```

**Rails approach (pragmatic):**
- Use Transaction Script (service objects) for simple operations
- Use Domain Model for core business entities with complex rules
- Most Rails apps use a hybrid: skinny models, service objects for workflows

**Staff-level:** For construction SaaS, use Domain Model for core entities (Projects, Documents, Change Orders) that have complex business rules. Use Transaction Script for utility operations (exports, bulk updates).

---

### Q77. Explain design patterns commonly used in Rails: Decorator, Presenter, Policy, Form Object, Query Object.

**Answer:**

**Decorator/Presenter (view logic):**
```ruby
class ProjectPresenter < SimpleDelegator
  def formatted_budget
    "$#{budget.to_fs(:delimited)}"
  end

  def status_badge_class
    {
      "active" => "badge-success",
      "on_hold" => "badge-warning",
      "completed" => "badge-info"
    }[status]
  end
end

# Usage
presenter = ProjectPresenter.new(project)
presenter.formatted_budget  # "$1,500,000"
```

**Policy (authorization):**
```ruby
class ProjectPolicy
  def initialize(user, project)
    @user = user
    @project = project
  end

  def edit?
    @user.admin? || @project.owner_id == @user.id
  end

  def delete?
    @user.admin?
  end
end

# Controller
authorize! ProjectPolicy.new(current_user, @project).edit?
```

**Form Object (multi-model forms):**
```ruby
class ProjectInvitationForm
  include ActiveModel::Model

  attr_accessor :email, :role, :project_id, :invited_by_id

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: %w[viewer editor admin] }

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      user = User.invite!(email: email)
      ProjectMembership.create!(project_id: project_id, user: user, role: role)
    end
    true
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
    false
  end
end
```

**Query Object (complex queries):**
```ruby
class ProjectSearchQuery
  def initialize(scope = Project.all)
    @scope = scope
  end

  def by_status(status)
    @scope = @scope.where(status: status)
    self
  end

  def by_budget_range(min:, max:)
    @scope = @scope.where(budget: min..max)
    self
  end

  def recently_updated
    @scope = @scope.where("updated_at > ?", 30.days.ago)
    self
  end

  def call
    @scope
  end
end

# Usage
ProjectSearchQuery.new.by_status("active").by_budget_range(min: 100_000).recently_updated.call
```

**Staff-level:** These patterns reduce model bloat. At Procore, use Policy objects for all authorization (Pundit gem), Form objects for multi-step workflows, Query objects for reporting.

---

### Q78. How do you implement the Strategy pattern in Ruby/Rails? Give a concrete example.

**Answer:**

**Problem:** Different calculation algorithms that vary independently.

```ruby
# Strategy interface
module PricingStrategy
  def calculate(project)
    raise NotImplementedError
  end
end

class FixedFeePricing
  include PricingStrategy

  def calculate(project)
    project.fixed_fee_amount
  end
end

class TimeAndMaterialsPricing
  include PricingStrategy

  def calculate(project)
    project.hours_worked * project.hourly_rate + project.materials_cost
  end
end

class CostPlusPricing
  include PricingStrategy

  def calculate(project)
    project.actual_costs * (1 + project.fee_percentage / 100.0)
  end
end

# Context
class ProjectBudgetCalculator
  STRATEGIES = {
    "fixed_fee" => FixedFeePricing,
    "time_and_materials" => TimeAndMaterialsPricing,
    "cost_plus" => CostPlusPricing
  }.freeze

  def initialize(project)
    @project = project
    @strategy = STRATEGIES[project.pricing_type].new
  end

  def total_budget
    @strategy.calculate(@project)
  end
end
```

**Benefits:**
- New pricing type? Add a class, don't modify existing code (OCP)
- Each strategy is independently testable
- No conditional logic scattered through the codebase

---

### Q79. Explain the Template Method pattern in Rails. Where does Rails use it internally?

**Answer:**

**Pattern:** Define algorithm skeleton in base class, subclasses override specific steps.

```ruby
class ReportGenerator
  def generate(project)
    header = build_header(project)
    body = build_body(project)
    footer = build_footer(project)
    format(header, body, footer)
  end

  private

  def build_header(project)
    "Report for: #{project.name}"
  end

  def build_body(project)
    raise NotImplementedError, "Subclasses must implement"
  end

  def build_footer(project)
    "Generated at: #{Time.current}"
  end

  def format(header, body, footer)
    [header, body, footer].join("\n")
  end
end

class BudgetReportGenerator < ReportGenerator
  private

  def build_body(project)
    "Budget: $#{project.budget}\nSpent: $#{project.spent}"
  end
end

class TimelineReportGenerator < ReportGenerator
  private

  def build_body(project)
    "Start: #{project.start_date}\nEnd: #{project.end_date}"
  end
end
```

**Rails internal uses:**
- `ActiveRecord::ConnectionAdapters` — each adapter implements DB-specific methods
- `ActionController::Base` — `process_action` template, subclasses override actions
- `ActionView::Renderer` — different rendering strategies

---

### Q80. What is the difference between Composition and Inheritance? When should you use each?

**Answer:**

**Inheritance:** "is-a" relationship
```ruby
class Animal; end
class Dog < Animal; end  # Dog IS AN Animal
```
- Use for true taxonomic hierarchies
- Rails models inheriting from ApplicationRecord
- Share implementation through base class

**Composition:** "has-a" relationship
```ruby
class Project
  def initialize(pricing_strategy:)
    @pricing_strategy = pricing_strategy
  end
end
# Project HAS A pricing strategy (not IS A pricing strategy)
```
- Use for behavior sharing without hierarchy
- More flexible — can change behavior at runtime
- Favors SRP and DIP

**Staff-level rule:** Prefer composition. Use inheritance only for:
- Framework classes (ActiveRecord, ActionController)
- True taxonomic relationships (not behavior sharing)
- Template method pattern

The "favor composition over inheritance" principle prevents fragile base class problems and deep inheritance hierarchies.

---

### Q81. How do you handle error responses in a Rails API? Design a consistent error format.

**Answer:**

**Consistent error format:**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The request failed validation",
    "details": [
      { "field": "budget", "code": "greater_than", "message": "must be greater than 0" },
      { "field": "name", "code": "blank", "message": "can't be blank" }
    ],
    "request_id": "550e8400-e29b-41d4-a716-446655440000",
    "documentation_url": "https://developers.procore.com/errors/VALIDATION_ERROR"
  }
}
```

**Implementation:**
```ruby
class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  rescue_from Pundit::NotAuthorizedError, with: :forbidden

  private

  def render_error(code:, status:, message:, details: [])
    render json: {
      error: {
        code: code,
        message: message,
        details: details,
        request_id: request.uuid
      }
    }, status: status
  end

  def not_found(error)
    render_error(code: "NOT_FOUND", status: 404, message: error.message)
  end

  def unprocessable_entity(error)
    details = error.record.errors.map { |e| { field: e.attribute, message: e.message } }
    render_error(code: "VALIDATION_ERROR", status: 422, message: "Validation failed", details: details)
  end
end
```

**Staff-level:** Every error response must include `request_id` for traceability. Use structured error codes that clients can handle programmatically. Log full error context server-side.

---

### Q82. How do you implement pagination in a Rails API? Compare offset, cursor, and keyset pagination.

**Answer:**

**Offset pagination (simple, but has performance issues at scale):**
```ruby
# GET /api/projects?page=2&per_page=20
Project.offset((params[:page] - 1) * params[:per_page]).limit(params[:per_page])
# OFFSET 20000 LIMIT 20 — PostgreSQL still scans 20020 rows!
```

**Cursor pagination (best for large datasets):**
```ruby
# GET /api/projects?cursor=eyJpZCI6MTIzfQ==&limit=20
# Decodes to: { "id": 123 }
decoded = Base64.decode64(params[:cursor])
marker = JSON.parse(decoded)

projects = Project.where("id > ?", marker["id"]).order(:id).limit(21)
next_cursor = projects.size > 20 ? Base64.encode64({ id: projects[20].id }.to_json) : nil

render json: {
  data: projects.take(20),
  pagination: { next_cursor: next_cursor }
}
```

**Keyset pagination (for sorted queries):**
```ruby
# GET /api/projects?last_budget=500000&last_id=42
Project.where("budget < ? OR (budget = ? AND id > ?)", 
              params[:last_budget], params[:last_budget], params[:last_id])
       .order(budget: :desc, id: :asc)
       .limit(20)
```

**Comparison:**
| Aspect | Offset | Cursor | Keyset |
|--------|--------|--------|--------|
| Deep page perf | Bad | Good | Good |
| Jump to page | Yes | No | No |
| Total count | Easy | Hard | Hard |
| Sort flexibility | Any | PK only | Multiple cols |

**Staff-level:** Use cursor pagination for infinite scroll and large datasets. Use offset only for small datasets (< 10K rows) where jump-to-page is needed. Never use offset for tables with millions of rows.

---

### Q83. What is HATEOAS and should a Procore API implement it?

**Answer:**

**HATEOAS (Hypermedia as the Engine of Application State):**
API responses include links to related actions:
```json
{
  "id": 1,
  "name": "Office Building",
  "status": "active",
  "_links": {
    "self": { "href": "/api/v1/projects/1" },
    "edit": { "href": "/api/v1/projects/1/edit" },
    "documents": { "href": "/api/v1/projects/1/documents" },
    "change_orders": { "href": "/api/v1/projects/1/change_orders" }
  }
}
```

**For Procore:**
- **Internal APIs**: Skip HATEOAS — adds overhead with limited benefit
- **Public/third-party APIs**: Consider HATEOAS or at least consistent link patterns
- **Better approach**: Provide great OpenAPI documentation with examples

**Staff-level:** Don't implement full HATEOAS unless specifically requested by API consumers. It's academic overhead for most SaaS APIs. Instead, focus on consistent URL patterns and comprehensive documentation.

---

### Q84. How do you handle file uploads in a Rails API at scale? Handle images, PDFs, and large CAD files.

**Answer:**

**Architecture:**
1. Client requests presigned URL from Rails API
2. Rails generates presigned URL (S3) valid for 15 minutes
3. Client uploads directly to S3 (bypassing Rails)
4. Client notifies Rails of completed upload
5. Background job processes the file (thumbnails, virus scan, text extraction)

**Implementation:**
```ruby
class UploadsController < ApplicationController
  def presign
    s3 = Aws::S3::Resource.new
    obj = s3.bucket(ENV["UPLOAD_BUCKET"]).object("uploads/#{SecureRandom.uuid}/#{params[:filename]}")

    url = obj.presigned_url(:put, expires_in: 900, 
                            content_type: params[:content_type],
                            content_length_range: 1..100.megabytes)

    render json: { upload_url: url, file_key: obj.key }
  end

  def confirm
    upload = Upload.create!(
      file_key: params[:file_key],
      filename: params[:filename],
      uploader: current_user,
      status: "pending"
    )

    ProcessUploadJob.perform_later(upload)
    render json: upload, status: :created
  end
end
```

**Processing pipeline:**
```ruby
class ProcessUploadJob
  def perform(upload)
    case upload.content_type
    when /image/
      ImageProcessingService.new(upload).call  # Thumbnails, optimization
    when /pdf/
      PdfProcessingService.new(upload).call    # Text extraction, preview
    when /cad|dwg/
      CadProcessingService.new(upload).call    # Conversion, metadata extraction
    end

    upload.update!(status: "processed", processed_at: Time.current)
  rescue => e
    upload.update!(status: "failed", error_message: e.message)
    raise  # Let Sidekiq retry
  end
end
```

**Staff-level:** Never let large uploads hit your Rails servers. Direct-to-S3 with presigned URLs is essential. Use S3 event notifications (SNS → SQS → Sidekiq) for reliable processing. For CAD files (construction-specific), consider dedicated conversion services (AutoDesk Forge API).

---

## Section F: Testing, TDD & CI/CD (15 Questions)

---

### Q85. What is your testing philosophy for a large Rails application? How do you balance coverage, speed, and value?

**Answer:**

**Test pyramid for Rails:**
```
    /\
   /  \     E2E tests (few, slow, critical paths only)
  /____\
 /      \   Integration tests (controllers, APIs, jobs)
/________\
           Unit tests (models, services, value objects — many, fast)
```

**Rules:**
- Unit tests: < 10ms each, test business logic in isolation
- Integration tests: Test request/response cycles, database interactions
- E2E tests: Only critical user journeys (login → create project → upload doc)

**Coverage targets:**
- Business logic (services, models): 95%+
- Controllers (happy path + common errors): 80%+
- Views/helpers: Test via integration tests, not unit
- Don't chase 100% coverage — chase meaningful assertions

**Speed strategies:**
- Parallel tests (`parallel_tests` gem, `PARALLEL_WORKERS`)
- Test database in RAM (`setup` in `/dev/shm`)
- Stub external APIs (WebMock, VCR)
- Don't test the framework (don't test ActiveRecord's `.save`)
- Preload Rails once (spring, bootsnap)

**Staff-level:** A 5-minute test suite gets run; a 30-minute suite gets skipped. Keep the full suite under 10 minutes with parallelization. Use `focus` tags during development.

---

### Q86. Explain RSpec vs Minitest. When would you choose one over the other for Procore?

**Answer:**

**Minitest:**
- Built into Ruby, ships with Rails
- Fast, simple, fewer dependencies
- xUnit style (assertions) or spec style available
- Better for teams wanting simplicity

**RSpec:**
- DSL-rich: `describe`, `context`, `it`, `let`, `before`
- Better mocking (rspec-mocks)
- Shared examples, custom matchers
- More verbose but more expressive
- Ecosystem: `factory_bot`, `shoulda-matchers`, `rspec-retry`

**For Procore (large established Rails app):**
- RSpec is the industry standard and likely what Procore uses
- RSpec's expressive DSL is worth the overhead for complex domain logic
- Use `let!` sparingly (lazy evaluation can hide performance issues)
- Prefer `describe` + `it` blocks for organization

---

### Q87. How do you test background jobs effectively? What about testing job retries?

**Answer:**

**Testing job logic:**
```ruby
RSpec.describe ProcessPaymentJob, type: :job do
  let(:order) { create(:order) }

  describe "#perform" do
    it "processes the payment" do
      expect(PaymentGateway).to receive(:charge).with(order.total)
      described_class.new.perform(order.id)
    end

    it "is idempotent" do
      order.update!(payment_processed_at: Time.current)
      expect(PaymentGateway).not_to receive(:charge)
      described_class.new.perform(order.id)
    end

    it "handles external API failure" do
      allow(PaymentGateway).to receive(:charge).and_raise(ApiTimeoutError)
      expect { described_class.new.perform(order.id) }.to raise_error(ApiTimeoutError)
      # Sidekiq will retry this
    end
  end
end
```

**Testing job enqueueing:**
```ruby
it "enqueues payment processing" do
  expect { order.checkout! }.to have_enqueued_job(ProcessPaymentJob).with(order.id)
end
```

**Testing retries:**
```ruby
it "retries on transient errors" do
  allow(PaymentGateway).to receive(:charge).and_raise(ApiTimeoutError)

  expect { described_class.new.perform(order.id) }
    .to raise_error(ApiTimeoutError)

  # Verify Sidekiq retry configuration
  expect(described_class.sidekiq_options['retry']).to eq(5)
end
```

---

### Q88. What is the test data strategy you recommend? Fixtures, factories, or something else?

**Answer:**

**FactoryBot (recommended for most Rails apps):**
```ruby
FactoryBot.define do
  factory :project do
    name { "Office Building" }
    budget { 1_000_000 }
    organization
    status { "active" }

    trait :completed do
      status { "completed" }
      completed_at { 1.week.ago }
    end

    trait :with_tasks do
      after(:create) do |project|
        create_list(:task, 5, project: project)
      end
    end
  end
end

# Usage
create(:project, :completed, :with_tasks, name: "Custom Name")
```

**Rules:**
- Use `build` (not `create`) when persistence isn't needed — 10x faster
- Use `build_stubbed` for unit tests that don't touch database
- Create shared traits for common combinations
- Keep factories simple — don't build complex object graphs

**vs Fixtures:**
- Fixtures: Fast (loaded once), but shared mutable state, brittle
- Factories: Flexible, explicit, slower but worth it

**Staff-level:** Use factories. For very large test suites, consider `test_data` gem for pre-seeded reference data (users, organizations) combined with factories for test-specific data.

---

### Q89. How do you test external API integrations without hitting the real API?

**Answer:**

**WebMock (stub HTTP requests):**
```ruby
stub_request(:post, "https://api.stripe.com/v1/charges")
  .with(body: hash_including({ amount: "1000" }))
  .to_return(status: 200, body: { id: "ch_123", status: "succeeded" }.to_json)
```

**VCR (record/real HTTP interactions):**
```ruby
VCR.use_cassette("stripe_charge_success") do
  # First run: Records real HTTP to spec/cassettes/
  # Subsequent runs: Plays back from cassette
  PaymentGateway.charge(amount: 1000)
end
```

**Contract testing (for service-to-service):**
- Pact: Consumer defines expected interaction, provider verifies
- Ensures both sides stay compatible

**Staff-level:** Use WebMock for unit tests (fast, explicit). Use VCR sparingly (cassettes get stale). For critical external APIs, use contract tests. Always test error responses (timeouts, 500s, rate limits).

---

### Q90. Explain TDD. When is it valuable vs. when is it overhead?

**Answer:**

**TDD cycle:**
1. Write a failing test (red)
2. Write minimal code to pass (green)
3. Refactor (keeping tests green)

**Valuable for:**
- Complex business logic (pricing calculations, permission systems)
- Bug fixes (write test reproducing bug, then fix)
- API contracts (test-first ensures clean interfaces)
- Algorithms (forces thinking about edge cases)

**Overhead for:**
- CRUD controllers (testing what Rails already tests)
- UI-heavy features (better tested via E2E)
- Spikes/experiments (throwaway code)
- Simple configuration

**Staff-level:** Don't be dogmatic. TDD is a thinking tool, not a religion. Use it when it helps clarify requirements. For established patterns, writing tests after is fine. The key is having tests, not when you write them.

---

### Q91. How would you set up a CI/CD pipeline for a Rails monolith? What stages and checks?

**Answer:**

**Pipeline stages:**

```yaml
# .circleci/config.yml example
stages:
  - lint            # Rubocop, Brakeman, bundle-audit
  - test            # RSpec (parallel by test file)
  - security        # Dependency vulnerability scan, secret detection
  - build           # Docker image build
  - deploy_staging  # Auto-deploy on main branch
  - e2e             # Cypress/Playwright against staging
  - deploy_prod     # Manual approval or automated canary
```

**Key checks:**
1. **Lint**: `rubocop`, `erb-lint` — style consistency
2. **Static analysis**: `brakeman` (security), `bundler-audit` (CVEs)
3. **Unit + integration tests**: Parallel by timing (split slowest tests)
4. **Database migration test**: Run migrations against clone of prod schema
5. **Asset compilation**: Ensure `assets:precompile` succeeds
6. **Docker build**: Multi-stage build for minimal image
7. **Contract tests**: Verify API compatibility with consumers

**Staff-level:** Use CircleCI's test splitting by timing for optimal parallelization. Store test results for flaky test detection. The pipeline should fail fast (lint first, expensive tests last).

---

### Q92. How do you implement blue-green deployments for a Rails app on Kubernetes?

**Answer:**

**Architecture:**
```
[ALB/Ingress]
    |
[Service selector: version=blue] → [Blue Pods: v1.2.3]
                                  [Green Pods: v1.2.4] (idle, for testing)
```

**Kustomize structure:**
```yaml
# base/deployment.yaml — Deployment with version label
# base/service.yaml — Service without version selector
# overlays/blue/service-patch.yaml — selector version: blue
# overlays/green/service-patch.yaml — selector version: green
```

**Deployment process:**
1. CI builds Docker image, pushes to registry
2. Argo CD updates Green deployment with new image
3. Run smoke tests against Green
4. `kubectl patch service rails-app -p '{"spec":{"selector":{"version":"green"}}}'`
5. Monitor error rate for 30 minutes
6. If issues: patch back to blue (10-second rollback)
7. If stable: scale down blue (kept for 24 hours as safety)

**Database migrations:**
- Run migrations BEFORE switch (must be backward-compatible)
- Use expand-contract pattern for breaking schema changes
- Never run destructive migrations during switch window

**Staff-level:** Argo Rollouts automates canary analysis. For Rails, the critical piece is backward-compatible migrations — never deploy code that requires a migration that hasn't run yet.

---

### Q93. What Git branching strategy do you recommend for a Rails team of 50+ engineers?

**Answer:**

**Trunk-based development (recommended for large teams):**
- Short-lived feature branches (max 1-2 days)
- Merge to `main` multiple times per day
- Feature flags for incomplete features
- No long-lived release branches

```
main: ──●──●──●──●──●──●──●──●──●──●──●──●──●──●──→
         \        /\         /
feature:  ●──●──●  ●──●──●──●
```

**Why not GitFlow:**
- Long-lived branches = merge conflicts, integration risk
- Release branches slow down delivery
- Complex for large teams

**Implementation:**
- Feature flags for WIP: `if FeatureFlag.enabled?(:new_dashboard, user)`
- Automated deploys from main to staging
- Production deploys: canary or daily scheduled

**Staff-level:** Trunk-based development requires investment in feature flags (LaunchDarkly or custom) and automated testing. The payoff is reduced merge conflicts and faster delivery. This is what high-performing teams at Google, Shopify, and Procore use.

---

### Q94. How do you handle database migrations in CI/CD? What safety checks?

**Answer:**

**Pipeline for migrations:**
1. **Lint migrations** (`strong_migrations` gem):
   - Rejects `add_index` without `algorithm: :concurrently`
   - Rejects `add_column` with default on large tables
   - Rejects `rename_column`, `remove_column` without safety checks

2. **Test migrations**:
   ```ruby
   # Clone production schema (sanitized)
   # Run new migrations
   # Verify rollback works
   # Run test suite against migrated schema
   ```

3. **Migration deployment** (separate from code deployment):
   ```bash
   # 1. Deploy migrations
   kubectl run migration-runner --rm -i --image=procore/rails -- bundle exec rails db:migrate

   # 2. Wait and monitor
   # 3. Deploy application code
   kubectl set image deployment/rails-app rails-app=procore/rails:v1.2.4
   ```

4. **Rollback plan:**
   - Migrations must be reversible (`down` method or `reversible`)
   - Keep previous Docker image for instant rollback
   - For breaking migrations, have forward-fix plan (data migration separate from schema)

**Staff-level:** The `strong_migrations` gem is essential at scale. Never let developers run unreviewed migrations against production. Migrations should be their own deploy step, separate from code deploys.

---

### Q95. How do you implement feature flags in a Rails application? What are the dangers?

**Answer:**

**Implementation:**
```ruby
# Simple database-backed
class FeatureFlag
  def self.enabled?(name, actor = nil)
    flag = FeatureFlagRecord.find_by(name: name)
    return false unless flag&.enabled?

    # Percentage rollout
    return false if flag.percentage < 100 && Zlib.crc32(actor.id.to_s) % 100 > flag.percentage

    # User targeting
    return false if flag.target_users.any? && !flag.target_users.include?(actor.id)

    true
  end
end

# Usage in controller
if FeatureFlag.enabled?(:new_project_dashboard, current_user)
  render :new_dashboard
else
  render :legacy_dashboard
end
```

**Dangers:**
- **Flag sprawl**: Hundreds of flags, nobody knows which are active
- **Test matrix explosion**: Testing all flag combinations
- **Cleanup debt**: Flags left in code after feature is fully rolled out
- **Performance**: Flag checks in hot paths need caching

**Best practices:**
- Flag lifecycle: development → staging → percentage rollout → general → removal
- Auto-expire flags (ticket to remove after 30 days of full rollout)
- Use a proper service (LaunchDarkly) at scale

---

### Q96. What is database migration testing and why is it critical?

**Answer:**

**Migration testing verifies:**
1. Migration runs successfully against production-like data
2. Rollback works
3. Application code works with new schema
4. Performance is acceptable (no table locks, reasonable duration)

**Implementation:**
```ruby
# spec/db/migrate/add_status_to_projects_spec.rb
RSpec.describe "AddStatusToProjects", type: :migration do
  let(:previous_version) { 20240101000000 }
  let(:migration_version) { 20240201000000 }

  before do
    # Set up data in old schema
    ActiveRecord::Migrator.run(:down, migration_paths, migration_version)
    create_list(:project, 1000, status: nil)
  end

  it "migrates without error" do
    expect {
      ActiveRecord::Migrator.run(:up, migration_paths, migration_version)
    }.not_to raise_error
  end

  it "backfills all records" do
    ActiveRecord::Migrator.run(:up, migration_paths, migration_version)
    expect(Project.where(status: nil).count).to eq(0)
  end

  it "is reversible" do
    ActiveRecord::Migrator.run(:up, migration_paths, migration_version)
    expect {
      ActiveRecord::Migrator.run(:down, migration_paths, migration_version)
    }.not_to raise_error
  end
end
```

**Staff-level:** Test migrations with production data volumes. A migration that takes 2 seconds with 100 rows can take 2 hours with 100 million rows.

---

### Q97. How do you ensure build reproducibility and dependency stability?

**Answer:**

**Gemfile.lock:**
- Always commit `Gemfile.lock` for applications
- Never for gems (libraries)
- Review lockfile changes in PRs

**Docker:**
```dockerfile
# Pin base image version
FROM ruby:3.3.0-slim-bookworm

# Pin gem versions in Gemfile
gem 'rails', '~> 7.1.0'  # NOT '~> 7.1' (too loose)
```

**Bundler:**
```bash
bundle config set --local deployment true
bundle config set --local frozen true  # Fail if Gemfile.lock out of sync
```

**Private gems:**
- Use GitHub Packages or private gem server
- Don't use `git:` sources in Gemfile (slow, unreliable)

---

### Q98. How do you handle secrets and environment configuration in CI/CD and production?

**Answer:**

**Secrets management:**
- **Development**: `.env` file (never committed)
- **CI**: Repository secrets (GitHub/CircleCI encrypted variables)
- **Production**: Kubernetes Secrets + external secret operator

**Kubernetes pattern:**
```yaml
# External Secrets Operator syncs from AWS Secrets Manager
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: rails-secrets
spec:
  secretStoreRef:
    name: aws-secrets-manager
  target:
    name: rails-app-secrets
  data:
    - secretKey: database_password
      remoteRef:
        key: production/rails/database
        property: password
```

**Rails credentials:**
```bash
EDITOR=vim bin/rails credentials:edit --environment production
# Encrypts with RAILS_MASTER_KEY
```

**Staff-level:** Never commit secrets to git (even encrypted). Rotate secrets regularly. Use short-lived credentials where possible (IAM roles for pods, not static AWS keys).

---

### Q99. How do you handle flaky tests in a large test suite? What are common causes?

**Answer:**

**Common causes:**
1. **Database state leakage**: Test A creates data that affects Test B
   - Fix: Database cleaner, `use_transactional_tests = true`

2. **Time-dependent tests**: `Time.now`, `Date.today`
   - Fix: `travel_to` (ActiveSupport::Testing::TimeHelpers)

3. **Race conditions**: Async code not awaited
   - Fix: `assert_enqueued_jobs`, `perform_enqueued_jobs`

4. **Random ordering**: Tests dependent on execution order
   - Fix: `--order random`, isolate setup

5. **External services**: Real HTTP calls, real Redis
   - Fix: Mock/stub all externals

**Detection:**
```bash
# Run failing test 100 times
for i in {1..100}; do bundle exec rspec spec/flaky_spec.rb; done

# Track flaky tests in CI (rspec-retry with reporting)
```

**Staff-level:** Quarantine consistently flaky tests (move to separate suite, don't block CI). Dedicate time each sprint to fixing root causes. Track flaky test rate as a team metric.

---

## Section G: Kubernetes & AWS (15 Questions)

---

### Q100. How do you deploy a Rails application on Kubernetes? Describe the full architecture.

**Answer:**

**Architecture:**
```
[Route53] → [ALB Ingress Controller] → [NGINX Ingress] → [Rails Service]
                                              ↓
                                        [Puma Pods (HPA)]
                                              ↓
                                    [PostgreSQL (RDS)]
                                    [Redis (ElastiCache)]
                                    [S3 (file storage)]
                                    [Sidekiq Pods (separate deployment)]
```

**Core manifests:**
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rails-app
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    spec:
      containers:
      - name: rails
        image: procore/rails:v1.2.3
        ports:
        - containerPort: 3000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: rails-secrets
              key: database_url
        - name: RAILS_MAX_THREADS
          value: "5"
        - name: WEB_CONCURRENCY
          value: "4"
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "2000m"
        livenessProbe:
          httpGet:
            path: /health/live
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
```

**Key configurations:**
- `WEB_CONCURRENCY`: Puma workers per pod (match CPU cores)
- `RAILS_MAX_THREADS`: Threads per worker (match DB pool)
- Health checks: Separate liveness (restart if dead) and readiness (remove from service if not ready)
- Resources: Set requests for scheduling, limits for protection

---

### Q101. Explain Horizontal Pod Autoscaling (HPA) for Rails. What metrics do you use?

**Answer:**

**CPU-based HPA:**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: rails-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: rails-app
  minReplicas: 4
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300  # Wait 5 min before scaling down
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
```

**Custom metrics (better for Rails):**
```yaml
metrics:
- type: Pods
  pods:
    metric:
      name: puma_requests_per_second
    target:
      type: AverageValue
      averageValue: "50"
- type: External
  external:
    metric:
      name: sidekiq_queue_depth
    target:
      type: Value
      value: "1000"
```

**Staff-level:** CPU is a lagging indicator for Rails (CPU spikes after requests pile up). Use request latency (p95) or custom application metrics for faster scaling reactions. Scale down conservatively — aggressive scale-down causes thrashing.

---

### Q102. How do you manage Rails secrets in Kubernetes? Compare ConfigMaps, Secrets, and external secret managers.

**Answer:**

**ConfigMaps:**
- Non-sensitive configuration (feature flags, timeout values)
- Stored unencrypted in etcd
- Good for: `RAILS_ENV`, `WEB_CONCURRENCY`, log levels

**Kubernetes Secrets:**
- Base64-encoded (not encrypted by default)
- Mounted as files or env vars
- Good for: Database URLs, API keys (basic level)
- **Problem:** Anyone with etcd access can read secrets

**External Secrets Operator (recommended for production):**
- Syncs from AWS Secrets Manager / HashiCorp Vault
- Secrets never stored in git or etcd plaintext
- Automatic rotation support

**AWS integration:**
```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: rails-app
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: ClusterSecretStore
    name: aws-secrets-manager
  target:
    name: rails-app-secrets
    creationPolicy: Owner
  data:
    - secretKey: DATABASE_URL
      remoteRef:
        key: production/rails/database
        property: url
```

**Staff-level:** Use IRSA (IAM Roles for Service Accounts) to give pods access to AWS Secrets Manager without static credentials. Enable envelope encryption for Kubernetes Secrets in etcd.

---

### Q103. What is a Service Mesh and when would you use it with Rails?

**Answer:**

**Service Mesh (Istio/Linkerd):**
- Layer of infrastructure between services
- Handles: mTLS, traffic routing, retries, timeouts, observability
- Implemented as sidecar proxy (Envoy) injected into each pod

**Benefits for Rails:**
- **mTLS**: Automatic service-to-service encryption (no code changes)
- **Traffic splitting**: Canary deployments without application code
- **Retries/Timeouts**: Configurable at mesh level
- **Observability**: Automatic distributed tracing

**When to use:**
- Multi-service architecture (10+ services)
- Strict security requirements (mTLS between all services)
- Complex traffic routing needs

**When NOT to use:**
- Single Rails monolith (overhead without benefit)
- Small teams (operational complexity)
- Early-stage product (focus on product-market fit)

**Staff-level:** For a Rails monolith transitioning to microservices, add a service mesh when you have 5+ services with inter-service communication. Don't add it prematurely — the operational overhead is significant.

---

### Q104. How do you handle zero-downtime deployments with database migrations on Kubernetes?

**Answer:**

**The core problem:**
- New code expects new schema
- Old code runs on old schema
- During rolling deploy, both versions run simultaneously

**Solution — Three-phase migration:**

**Phase 1 (Deploy 1):** Add new column/table (backward-compatible)
```ruby
class AddStatusToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :status, :string  # Nullable, no default
    add_index :projects, :status, algorithm: :concurrently
  end
end
# Both old and new code work fine — old ignores the column
```

**Phase 2 (Deploy 2):** Write to both old and new (dual-write)
```ruby
class Project < ApplicationRecord
  def status
    read_attribute(:status) || legacy_status_calculation
  end

  def status=(value)
    super
    self[:legacy_status] = value  # Dual-write
  end
end
```

**Phase 3 (Deploy 3):** Backfill data, make NOT NULL, remove old

**Kubernetes specifics:**
- Run migrations as `pre-sync` hook in Argo CD (before pod update)
- Use `maxUnavailable: 0` to ensure no traffic loss
- Keep previous replica set for 10 minutes (instant rollback)

**Staff-level:** The expand-contract pattern is non-negotiable at scale. Never deploy code that requires a migration that hasn't been deployed. Never run destructive (column removal) migrations until the old code is fully decommissioned.

---

### Q105. How do you configure health checks for Rails in Kubernetes? What's the difference between liveness and readiness?

**Answer:**

**Liveness probe:** "Is the process alive?"
- Fails → Kubernetes restarts the container
- Should be simple (don't check external dependencies)
- Use `/health/live` that just returns 200 if Rails process responds

**Readiness probe:** "Is the pod ready to accept traffic?"
- Fails → Pod removed from Service endpoints (no traffic)
- Should check dependencies (DB, Redis)
- Use `/health/ready` that checks critical connections

**Implementation:**
```ruby
# config/routes.rb
get "/health/live", to: proc { [200, {}, ["ok"]] }
get "/health/ready", to: "health#ready"

# app/controllers/health_controller.rb
class HealthController < ActionController::Base
  def ready
    checks = {
      database: database_check,
      redis: redis_check
    }

    if checks.values.all?
      render json: { status: "ready", checks: checks }
    else
      render json: { status: "not_ready", checks: checks }, status: 503
    end
  end

  private

  def database_check
    ActiveRecord::Base.connection.execute("SELECT 1")
    true
  rescue
    false
  end

  def redis_check
    Redis.current.ping == "PONG"
  rescue
    false
  end
end
```

**Staff-level:** Keep liveness probes simple and fast. A failing external dependency should trigger readiness (remove from load balancer) not liveness (restart). Restarting won't fix a down database.

---

### Q106. How do you configure Pod Disruption Budgets for Rails applications? Why are they important?

**Answer:**

**Pod Disruption Budget (PDB):**
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: rails-app-pdb
spec:
  minAvailable: 3          # Keep at least 3 pods running
  # OR
  maxUnavailable: 1        # At most 1 pod can be unavailable
  selector:
    matchLabels:
      app: rails-app
```

**Why important:**
- During node upgrades, Kubernetes drains nodes (evicts pods)
- Without PDB, all pods could be evicted simultaneously
- PDB ensures minimum availability during disruptions

**Staff-level:** Set `maxUnavailable: 25%` for web pods, `minAvailable: 1` for critical singletons (job schedulers). PDBs block node drains — ensure your cluster autoscaler respects them.

---

### Q107. What AWS services are commonly used with Rails at scale? Describe the architecture.

**Answer:**

**Typical AWS architecture for Rails:**

| Layer | Service | Purpose |
|-------|---------|---------|
| DNS | Route 53 | Domain management, health checks |
| CDN | CloudFront | Static assets, edge caching |
| Load Balancer | ALB | HTTP routing, SSL termination |
| Compute | EKS / ECS | Kubernetes containers |
| Database | RDS PostgreSQL | Primary database, Multi-AZ |
| Cache | ElastiCache Redis | Sessions, caching, Sidekiq |
| Search | OpenSearch | Full-text search, aggregations |
| Storage | S3 | File uploads, backups, logs |
| Queue | SQS / EventBridge | Async processing, event bus |
| Secrets | Secrets Manager | Credential management |
| Monitoring | CloudWatch + Datadog | Metrics, logs, alerts |
| CI/CD | CodePipeline + ArgoCD | Build and deployment |

**Staff-level:** Use managed services (RDS, ElastiCache) over self-managed to reduce operational burden. Enable Multi-AZ for databases, cross-region backup for disaster recovery.

---

### Q108. How do you optimize AWS costs for a Rails application running on EKS?

**Answer:**

**Compute optimization:**
- Right-size nodes (use Vertical Pod Autoscaler in recommendation mode)
- Spot instances for non-critical workloads (Sidekiq, staging)
- Karpenter for efficient node provisioning (vs Cluster Autoscaler)
- Graviton (ARM) instances — 20-40% cheaper, compatible with Ruby 3.1+

**Database:**
- Reserved instances for steady-state workloads (40-60% savings)
- Read replicas for read-heavy workloads (cheaper than scaling primary)
- Aurora Serverless for variable/dev workloads

**Storage:**
- S3 Intelligent-Tiering for file storage
- Lifecycle policies: move to Glacier after 90 days
- EBS gp3 instead of gp2 (cheaper, more IOPS)

**Caching:**
- CloudFront for static assets (reduces origin load)
- ElastiCache for query result caching (reduces RDS load)

**Staff-level:** Cost optimization is an ongoing process. Tag all resources by team/service. Review AWS Cost Explorer monthly. Set budgets with alerts at 80% of expected spend.

---

### Q109. How do you implement disaster recovery for a Rails application on AWS?

**Answer:**

**RPO/RTO targets:**
- **RPO (Recovery Point Objective):** Max acceptable data loss — target < 5 minutes
- **RTO (Recovery Time Objective):** Max acceptable downtime — target < 30 minutes

**Implementation:**

**Database:**
- RDS Multi-AZ (automatic failover within AZ)
- Cross-region read replica (for full region failure)
- Automated backups (retention: 35 days)
- Point-in-time recovery enabled

**Application:**
- Infrastructure as Code (Terraform) — recreate entire stack
- Container images in ECR (multi-region replication)
- Configuration in Git + Secrets Manager
- Runbook for manual failover steps

**Data:**
- S3 Cross-Region Replication for file storage
- Regular disaster recovery drills (quarterly)

**Staff-level:** Automate failover where possible (RDS Multi-AZ), but practice manual procedures. The worst time to learn DR is during an actual disaster.

---

### Q110. How do you implement network security for Rails on AWS? VPC design, security groups, WAF.

**Answer:**

**VPC design:**
```
VPC (10.0.0.0/16)
├── Public Subnets (10.0.1.0/24, 10.0.2.0/24)     ← ALB, NAT Gateway
├── Private Subnets (10.0.3.0/24, 10.0.4.0/24)    ← Rails pods, Sidekiq
└── Data Subnets (10.0.5.0/24, 10.0.6.0/24)       ← RDS, Redis
```

**Security groups:**
- ALB: Inbound 443 from 0.0.0.0/0
- Rails pods: Inbound 3000 from ALB security group only
- RDS: Inbound 5432 from Rails security group only
- Redis: Inbound 6379 from Rails security group only

**WAF (Web Application Firewall):**
- AWS Managed Rules (Common, Known Bad Inputs, SQL injection)
- Rate limiting per IP
- Geo-blocking if applicable
- Custom rules for construction-specific patterns

**Staff-level:** Defense in depth — security groups + WAF + application-level authorization. Never expose RDS or Redis to public subnets. Use AWS PrivateLink for third-party service integrations.

---

### Q111. How do you set up log aggregation and centralized logging for Rails on Kubernetes?

**Answer:**

**Architecture:**
```
Rails app (stdout JSON) → Fluent Bit (DaemonSet) → CloudWatch / Datadog / Elasticsearch
```

**Rails logging:**
```ruby
# config/environments/production.rb
config.lograge.enabled = true
config.lograge.formatter = Lograge::Formatters::Json.new
config.lograge.custom_options = lambda do |event|
  {
    request_id: event.payload[:request_id],
    user_id: event.payload[:user_id],
    org_id: event.payload[:org_id]
  }
end
```

**Fluent Bit config:**
```yaml
[INPUT]
    Name tail
    Path /var/log/containers/rails-app*.log
    Parser docker
    Tag rails.*

[FILTER]
    Name kubernetes
    Match rails.*
    Merge_Log On
    Keep_Log Off

[OUTPUT]
    Name cloudwatch_logs
    Match rails.*
    region us-east-1
    log_group_name /eks/rails-app
    log_stream_prefix from-fluent-bit-
    auto_create_group On
```

**Staff-level:** Structured JSON logs are essential for querying. Include `request_id` in every log line for correlation. Set log retention (30 days hot, 1 year cold in S3).

---

### Q112. How do you implement auto-scaling at multiple levels for a Rails app on AWS?

**Answer:**

**Three layers of scaling:**

**1. Pod level (HPA):**
```yaml
# Scale pods based on CPU
metrics:
- type: Resource
  resource:
    name: cpu
    target:
      averageUtilization: 70
      type: Utilization
```

**2. Node level (Cluster Autoscaler / Karpenter):**
```yaml
# Karpenter NodePool
apiVersion: karpenter.sh/v1beta1
kind: NodePool
spec:
  template:
    spec:
      requirements:
      - key: node.kubernetes.io/instance-type
        operator: In
        values: ["m6i.large", "m6i.xlarge", "m6g.large"]
      - key: karpenter.sh/capacity-type
        operator: In
        values: ["spot", "on-demand"]
  limits:
    cpu: 1000
    memory: 4000Gi
```

**3. Database level:**
- Read replicas for read scaling
- Aurora Auto Scaling for replica count
- RDS Storage Autoscaling

**Staff-level:** Use Karpenter over Cluster Autoscaler — it provisions nodes faster and uses diverse instance types. Combine spot (70% cheaper) and on-demand for cost optimization. Scale pods first, then nodes.

---

### Q113. What is a Kubernetes Operator and when would you build one for Rails?

**Answer:**

**Operator:** Custom controller that manages complex application lifecycle using Custom Resource Definitions (CRDs).

**When to build:**
- Complex stateful applications (databases, message queues)
- Multi-instance coordination
- Application-specific operational logic

**For Rails, typically NOT needed** — use Helm charts or Kustomize instead.

**Exception — multi-tenant provisioning:**
```yaml
apiVersion: procore.com/v1
kind: OrganizationTenant
metadata:
  name: acme-construction
spec:
  tier: enterprise
  database: dedicated
  region: us-west-2
  backupRetention: 30
```
An operator could watch these resources and provision: RDS instance, S3 bucket, DNS entry, application namespace.

**Staff-level:** Don't build operators for standard Rails deployments. Use them for platform/infrastructure automation (tenant provisioning, database lifecycle).

---

### Q114. How do you handle secrets rotation in a Kubernetes + AWS environment?

**Answer:**

**Automated rotation with AWS Secrets Manager:**
1. Secrets Manager automatically rotates credentials on schedule
2. Lambda function updates the secret and syncs to database
3. External Secrets Operator picks up the new secret
4. Pods get updated secrets via env var reload (requires pod restart for env vars)

**Zero-downtime rotation:**
```ruby
# Support dual credentials during transition
DATABASE_URLS = ENV["DATABASE_URL"].split(",")  # Primary,secondary

def with_failover
  ActiveRecord::Base.establish_connection(DATABASE_URLS.first)
  yield
rescue PG::ConnectionBad
  ActiveRecord::Base.establish_connection(DATABASE_URLS.second)
  yield
end
```

**Staff-level:** Credential rotation without downtime requires the application to support dual credentials. Rotate in stages: add new credential → update apps → remove old credential. Never rotate during peak hours.

---

### Q115. How do you debug a Rails pod that's crashing in Kubernetes?

**Answer:**

**Systematic debugging:**

```bash
# 1. Check pod status and events
kubectl describe pod rails-app-xxx

# 2. Check logs (previous container if crashed)
kubectl logs rails-app-xxx --previous

# 3. Check resource limits (OOMKill?)
kubectl get pod rails-app-xxx -o yaml | grep -A5 "lastState"

# 4. Check events for scheduling issues
kubectl get events --sort-by=.lastTimestamp | grep rails-app

# 5. Shell into running pod
kubectl exec -it rails-app-xxx -- /bin/sh
# Inside: check env vars, test DB connection, run Rails console

# 6. Resource usage
kubectl top pod rails-app-xxx
kubectl top node

# 7. Check for deadlock (thread dump)
kubectl exec rails-app-xxx -- kill -USR1 1  # Puma prints thread dump
```

**Common causes:**
- OOMKill: Increase memory limit or reduce `WEB_CONCURRENCY`
- CrashLoopBackOff: Liveness probe failing, app can't start
- ImagePullBackOff: Wrong image tag, registry auth issue
- Pending: Insufficient cluster resources, node affinity issues

**Staff-level:** Set up alerts for CrashLoopBackOff and OOMKill. Use `k9s` for interactive debugging. Keep a debug image with `curl`, `psql`, `redis-cli` for troubleshooting.

---

## Section H: Observability, OpenTelemetry & Performance (15 Questions)

---

### Q116. What are the three pillars of observability? How do they differ and complement each other?

**Answer:**

**Metrics:** Time-series numeric data (aggregated)
- Request rate, latency percentiles, error rate, queue depth
- Cardinality: low (tens/hundreds of unique time series)
- Use for: dashboards, alerts, trend analysis
- Tools: Prometheus, Datadog, CloudWatch

**Logs:** Timestamped discrete events (structured or unstructured)
- "User 123 created project 456 at 2024-01-01T00:00:00Z"
- Cardinality: high (every log line can be unique)
- Use for: debugging, audit trails, error investigation
- Tools: ELK stack, Datadog Logs, CloudWatch Logs

**Traces:** End-to-end request flows across services
- Shows path: ALB → Rails → PostgreSQL → Redis → External API
- Includes timing for each "span"
- Cardinality: very high (every unique request path)
- Use for: performance analysis, dependency mapping, bottleneck identification
- Tools: Jaeger, Zipkin, Datadog APM, OpenTelemetry

**Complementary use case:**
1. Alert fires on metric (p95 latency > 500ms)
2. Trace shows which service is slow (external API call)
3. Logs show the exact error (timeout on API request to accounting service)

---

### Q117. How do you instrument a Rails application with OpenTelemetry? Describe the setup.

**Answer:**

**Setup:**

```ruby
# Gemfile
gem 'opentelemetry-instrumentation-all'
gem 'opentelemetry-exporter-otlp'
gem 'opentelemetry-sdk'

# config/initializers/opentelemetry.rb
require 'opentelemetry/sdk'
require 'opentelemetry/instrumentation/all'
require 'opentelemetry/exporter/otlp'

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'procore-rails-api'
  c.service_version = ENV['GIT_COMMIT_SHA']
  c.use_all  # Auto-instrument Rails, PG, Redis, Sidekiq, HTTP

  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::OTLP::Exporter.new(
        endpoint: ENV['OTEL_EXPORTER_OTLP_ENDPOINT']
      )
    )
  )
end
```

**Manual instrumentation:**
```ruby
# For custom operations
tracer = OpenTelemetry.tracer_provider.tracer('procore-rails')

tracer.in_span('process_pdf') do |span|
  span.set_attribute('document.id', doc.id)
  span.set_attribute('document.size_mb', doc.file_size / 1.megabyte)

  result = PdfProcessor.new(doc).process

  span.set_attribute('processing.pages', result.page_count)
  span.set_attribute('processing.duration_ms', result.duration_ms)
end
```

**Staff-level:** Auto-instrumentation gives you 80% coverage (framework, database, cache). Manual spans for the remaining 20% — business operations that matter. Always set `service.version` to Git SHA for correlation with deployments.

---

### Q118. What is distributed tracing and how does context propagation work across services?

**Answer:**

**Distributed tracing:** Follows a request across service boundaries, building a trace tree of spans.

**Context propagation:**
```
Browser → [traceparent: 00-abc123-def456-01] 
  → ALB (passes through)
    → Rails API (creates span, propagates)
      → PostgreSQL (separate span)
      → Redis (separate span)
      → Sidekiq job (propagated trace ID)
        → External API call (propagated)
```

**W3C Trace Context header:**
```
traceparent: 00-{trace-id}-{parent-id}-{trace-flags}
traceparent: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01
```

**Propagation in Rails → Sidekiq:**
```ruby
class TracedJob
  include Sidekiq::Worker

  def perform(args)
    parent_context = OpenTelemetry.propagation.extract(args['trace_context'])
    OpenTelemetry::Context.with_current(parent_context) do
      tracer.in_span('job.process') do |span|
        # Job work here
      end
    end
  end
end
```

**Staff-level:** Context propagation is what makes traces useful. Without it, you have isolated spans, not a story. Ensure all outgoing HTTP requests include trace headers. Use OpenTelemetry's propagators (not custom headers).

---

### Q119. What are RED and USE metrics? How do you apply them to Rails?

**Answer:**

**RED (for request-driven services):**
- **Rate:** Requests per second
- **Errors:** Error rate (4xx, 5xx)
- **Duration:** Request latency (p50, p95, p99)

**USE (for resources):**
- **Utilization:** CPU, memory, disk, connection pool
- **Saturation:** Queue depth, wait times
- **Errors:** Resource errors (OOM, connection timeouts, disk full)

**Rails dashboard:**
```
┌─────────────────────────────────────┐
│  Requests/sec: 1,200                │
│  Error rate: 0.2%                   │
│  p95 latency: 180ms                 │
│  p99 latency: 450ms                 │
├─────────────────────────────────────┤
│  DB connections: 45/50 (90%)        │
│  Redis connections: 20/100 (20%)    │
│  Sidekiq queue depth: 150           │
│  Memory: 85%                        │
└─────────────────────────────────────┘
```

**Staff-level:** RED metrics are your service health indicators — alert on them. USE metrics help you predict capacity needs before they become incidents.

---

### Q120. How do you debug a performance issue in production? Walk through your systematic approach.

**Answer:**

**Step 1: Identify the symptom**
- Is it all requests or specific endpoints? (APM trace view)
- Is it a latency spike or gradual degradation? (metrics trend)
- When did it start? (correlate with deployments)

**Step 2: Narrow the scope**
```ruby
# Rails log analysis
# Look for slow queries in logs
Rails.logger.info "[SLOW] #{query} took #{duration}ms" if duration > 1000

# APM trace shows which span is slow
# External API call? Database query? View rendering?
```

**Step 3: Database investigation**
```sql
-- Find slow queries
SELECT query, calls, mean_exec_time, total_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;

-- Check for locks
SELECT * FROM pg_stat_activity WHERE wait_event_type = 'Lock';
```

**Step 4: Application profiling**
```ruby
# rbspy or stackprof for CPU profiling
StackProf.run(mode: :cpu, out: 'tmp/profile.dump') do
  # Slow operation
end

# Memory profiling
MemoryProfiler.report do
  # Operation
end
```

**Step 5: Infrastructure check**
- CPU/memory saturation on pods
- Database connection pool exhaustion
- Redis memory pressure
- External API latency

**Step 6: Fix and verify**
- Rollback recent deploy if correlation found
- Apply fix (index, cache, query rewrite)
- Verify in staging, monitor in production

**Staff-level:** The key is systematic elimination. Don't guess — use data from each layer to narrow down. Most Rails performance issues are database-related (N+1, missing index, slow query).

---

### Q121. What tools do you use for Rails performance profiling? Compare them.

**Answer:**

| Tool | Type | Best For |
|------|------|----------|
| rack-mini-profiler | Request profiling | Development quick checks |
| bullet | N+1 detection | Development |
| prosopite | N+1 detection | Production-safe |
| stackprof | CPU sampling | Production profiling |
| memory_profiler | Heap analysis | Memory leak detection |
| rbspy | CPU flamegraphs | Live production profiling (no code changes) |
| derailed_benchmarks | Boot memory | Reducing memory footprint |
| rack-attack | Request throttling | Rate limiting |

**Production profiling with rbspy:**
```bash
# Attach to running Puma process without restarting
rbspy record --pid $(pgrep -f puma) --file /tmp/rails-profile.svg
# Generates flamegraph showing where CPU time is spent
```

**Staff-level:** Use `rbspy` for live production profiling (zero overhead, safe). Use `stackprof` for detailed analysis when you can reproduce. Use `prosopite` in production with alerting for N+1 detection.

---

### Q122. How do you optimize Rails boot time? Why does it matter?

**Answer:**

**Why it matters:**
- Auto-scaling: Slow boot = slow scale-up during traffic spikes
- Development velocity: Faster tests, faster deploys
- CI pipeline duration

**Optimization strategies:**

1. **bootsnap:**
```ruby
# Gemfile
gem 'bootsnap', require: false

# config/boot.rb
require 'bootsnap/setup'
# Caches compiled bytecode, YAML, path lookups
# Typical improvement: 30-50% faster boot
```

2. **Lazy load gems:**
```ruby
# Don't require at boot
gem 'nokogiri', require: false
# Require only when needed in the class that uses it
```

3. **Defer initialization:**
```ruby
# config/initializers don't all need to run at boot
Rails.application.config.after_initialize do
  # Run after boot completes
end
```

4. **Remove unnecessary initializers:**
- Audit initializers — some run code that's never needed
- Move one-time setup to rake tasks

5. **Profile boot:**
```bash
bundle exec derailed exec perf:bootsnap
bundle exec derailed exec perf:mem
```

**Staff-level:** For Kubernetes, slow boot affects HPA reaction time. Target boot under 10 seconds. Use `readinessProbe.initialDelaySeconds` to match actual boot time.

---

### Q123. What is memory fragmentation in long-running Rails processes? How do you handle it?

**Answer:**

**The problem:**
- Ruby's allocator asks OS for memory but doesn't return it
- Over time, RSS grows while actual object count is flat
- Memory leaks vs fragmentation:
  - **Leak:** Objects accumulate (fix the code)
  - **Fragmentation:** Free memory scattered, can't be returned ( allocator issue)

**Detection:**
```ruby
# Check fragmentation
GC.stat[:heap_live_slots].to_f / GC.stat[:heap_eden_pages]
# Low ratio = high fragmentation

# Full GC report
GC.start(full_mark: true, immediate_sweep: true)
before = GC.stat(:total_freed_objects)
# Run workload
after = GC.stat(:total_freed_objects)
```

**Solutions:**
1. **Use jemalloc:** `LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so`
   - Returns memory to OS more aggressively
   - 20-40% memory reduction typical

2. **Puma worker recycling:**
```ruby
# config/puma.rb
worker_max_requests 10000    # Restart worker after 10K requests
worker_max_requests_variation 1000  # Stagger restarts
```

3. **Compact heap:**
```ruby
# Periodic compaction (Ruby 2.7+)
GC.compact
```

**Staff-level:** Puma worker restarts are the most practical solution. Set max_requests based on your memory growth curve. Monitor memory with `container_memory_working_set_bytes` in Prometheus.

---

### Q124. How do you implement caching at multiple layers in a Rails application?

**Answer:**

**Layer 1: HTTP caching (fastest — CDN/browser)**
```ruby
class ProjectsController < ApplicationController
  def show
    @project = Project.find(params[:id])
    expires_in 5.minutes, public: true  # CDN cacheable
    fresh_when @project  # ETag + Last-Modified
  end
end
```

**Layer 2: Database query cache (per-request)**
```ruby
# Enabled by default in Rails
# Same query in same request = cached
# Cleared at end of request
```

**Layer 3: Low-level cache (Redis/Memcached)**
```ruby
Rails.cache.fetch("project/#{id}/summary", expires_in: 1.hour) do
  project.calculate_complex_summary
end
```

**Layer 4: Russian doll fragment caching**
```erb
<% cache project do %>
  <!-- Cached fragment -->
<% end %>
```

**Layer 5: Application-level memoization**
```ruby
def expensive_calculation
  @expensive_calculation ||= begin
    # Compute once per request
  end
end
```

**Cache invalidation strategies:**
- **TTL:** Expire after fixed time (simple, stale data possible)
- **Active invalidation:** `Rails.cache.delete(key)` when data changes
- **Key-based:** Include version/timestamp in key (cache key changes = automatic miss)

**Staff-level:** Cache invalidation is famously hard. Prefer key-based caching (cache key includes `updated_at`). For critical data, use active invalidation with TTL as safety net.

---

### Q125. How would you implement a custom metrics pipeline for a Rails monolith?

**Answer:**

**Architecture:**
```
Rails app (statsd client) → StatsD aggregator → Prometheus → Grafana
```

**Implementation:**
```ruby
# config/initializers/metrics.rb
$statsd = Statsd.new(ENV['STATSD_HOST'], 8125)
$statsd.namespace = "procore.rails"

# Middleware for request metrics
class MetricsMiddleware
  def call(env)
    start = Time.current
    status, headers, body = @app.call(env)
    duration = (Time.current - start) * 1000

    tags = {
      controller: env['action_dispatch.controller'],
      action: env['action_dispatch.action'],
      status: status
    }

    $statsd.histogram('request.duration_ms', duration, tags: tags)
    $statsd.increment('request.count', tags: tags)

    [status, headers, body]
  end
end
```

**Custom business metrics:**
```ruby
# Track business events
$statsd.increment('project.created', tags: { tier: org.tier, source: 'api' })
$statsd.histogram('project.budget', project.budget, tags: { tier: org.tier })
$statsd.gauge('active_projects', Project.active.count)
```

**Staff-level:** Business metrics are as important as technical metrics. Track "projects created per day," "average project budget," "document uploads per hour" — these tell you about product health, not just system health.

---

### Q126. How do you set up alerting that avoids alert fatigue while catching real issues?

**Answer:**

**Alert hierarchy:**

| Severity | Response | Examples |
|----------|----------|----------|
| P0 (Critical) | Page immediately | Database down, 500 spike, payment failure |
| P1 (High) | Page within 15 min | Error rate > 5%, queue depth growing, latency p99 > 2s |
| P2 (Medium) | Ticket/Triage | Error rate > 1%, disk > 80%, memory pressure |
| P3 (Low) | Review in standup | Capacity planning warnings, minor degradation |

**Best practices:**
- Alert on symptoms (user impact), not causes (CPU usage)
- Use multi-condition alerts (error rate AND request volume)
- Require runbook link for every alert
- Weekly alert review: Which fired? Which were actionable?

**Staff-level:** The goal is "actionable alerts." If an alert fires and the response is "wait and see," it's a bad alert. Track MTTR (Mean Time To Recovery) and MTTD (Mean Time To Detect) as team metrics.

---

### Q127. Explain sampling strategies for distributed tracing at scale.

**Answer:**

**Why sample:** Full tracing generates massive data volume (GBs/hour for high-traffic services).

**Strategies:**

1. **Head-based sampling** (decide at trace start):
```ruby
# Sample 1% of all traces
OpenTelemetry::SDK.configure do |c|
  c.trace_provider.sampler = OpenTelemetry::SDK::Trace::Samplers.trace_id_ratio_based(0.01)
end
# Simple, but might miss rare errors
```

2. **Tail-based sampling** (decide after trace complete):
- Collect all spans temporarily
- Sample based on properties: error? slow? specific user?
- Better for catching anomalies
- Requires more infrastructure (Jaeger with tail sampling)

3. **Rule-based sampling:**
```ruby
# Always trace payment flows, sample 1% of health checks
sampler = OpenTelemetry::SDK::Trace::Samplers.parent_based(
  root: OpenTelemetry::SDK::Trace::Samplers.trace_id_ratio_based(0.1),
  remote_parent_sampled: OpenTelemetry::SDK::Trace::Samplers.always_on,
  local_parent_not_sampled: OpenTelemetry::SDK::Trace::Samplers.always_off
)
```

**Staff-level:** Start with 10% head-based sampling. For high-traffic services, use rule-based: always trace errors, always trace payment flows, sample 1% of routine requests.

---

### Q128. How do you correlate logs, metrics, and traces for effective debugging?

**Answer:**

**Correlation keys:**

```ruby
# Request ID propagated through all systems
request_id = SecureRandom.uuid

# In logs
Rails.logger.info "Processing payment", { request_id: request_id, user_id: user.id }

# In traces
span.set_attribute('request_id', request_id)

# In metrics (as label)
$statsd.increment('payment.processed', tags: { request_id: request_id })
```

**Implementation:**
```ruby
# config/initializers/correlation.rb
class CorrelationMiddleware
  def call(env)
    request_id = env['HTTP_X_REQUEST_ID'] || SecureRandom.uuid
    Current.request_id = request_id

    # Add to all logs
    Rails.logger.tagged(request_id: request_id) do
      # Add to response header
      status, headers, body = @app.call(env)
      headers['X-Request-ID'] = request_id
      [status, headers, body]
    end
  end
end
```

**Observability platform correlation:**
- Logs contain `trace_id` field
- Traces contain `request_id` field
- Metrics are tagged with `request_id`
- Dashboards link: Log → Trace → Metrics

**Staff-level:** Without correlation, you're looking at three separate data sources. With correlation, a slow trace leads you to the exact logs and metrics for that request. This is what makes observability greater than monitoring.

---

### Q129. How do you monitor background job performance with OpenTelemetry?

**Answer:**

**Auto-instrumentation:**
```ruby
# Gemfile
gem 'opentelemetry-instrumentation-sidekiq'

# Auto-creates spans for:
# - job.enqueue
# - job.process
# - job.retry
# - job.error
```

**Custom spans for job internals:**
```ruby
class ProcessReportJob
  include Sidekiq::Worker

  def perform(report_id)
    tracer = OpenTelemetry.tracer_provider.tracer('procore-jobs')
    report = Report.find(report_id)

    tracer.in_span('report.generate_data') do |span|
      data = report.generate_data
      span.set_attribute('report.rows', data.length)
    end

    tracer.in_span('report.upload_to_s3') do |span|
      url = S3Uploader.upload(data)
      span.set_attribute('s3.object_size', data.size)
    end

    tracer.in_span('report.notify_user') do
      ReportMailer.completed(report, url).deliver_later
    end
  end
end
```

**Staff-level:** Job traces should show which step failed and how long each step took. Alert on job duration p95 and error rate per job class.

---

### Q130. What are cardinality concerns with metrics and how do you manage them?

**Answer:**

**The problem:** High-cardinality tags (user_id, request_id, email) create exponential time series growth.

**Example:**
```ruby
# BAD — 1M users = 1M time series
$statsd.increment('api.request', tags: { user_id: user.id })

# GOOD — 4 tiers = 4 time series
$statsd.increment('api.request', tags: { user_tier: user.tier })
```

**Guidelines:**
| Tag Type | Example | Cardinality |
|----------|---------|-------------|
| Low | status, environment | 10-100 ✅ |
| Medium | endpoint, controller | 100-1000 ✅ |
| High | user_id, org_id | 10K+ ⚠️ |
| Extreme | request_id, timestamp | 1M+ ❌ |

**For high-cardinality data:**
- Use traces (designed for high cardinality)
- Use logs (indexed, searchable)
- Aggregate metrics: `user_tier` instead of `user_id`

**Staff-level:** High cardinality can crash Prometheus or generate massive Datadog bills. Review metric tags in PRs. A single high-cardinality metric can cost thousands per month.

---

## Section I: Security, Distributed Systems & Concurrency (15 Questions)

---

### Q131. What are the top security vulnerabilities in Rails applications? How do you mitigate each?

**Answer:**

**1. SQL Injection:**
```ruby
# BAD — string interpolation
User.where("email = '#{params[:email]}")

# GOOD — parameterized queries
User.where(email: params[:email])
User.where("email = ?", params[:email])
```
- Mitigation: Always use parameterized queries, `strong_migrations` checks

**2. XSS (Cross-Site Scripting):**
```ruby
# Rails auto-escapes ERB by default
<%= user.name %>  # Escaped ✓
<%= raw user.name %>  # Dangerous! Only use with sanitized data
```
- Mitigation: Content Security Policy headers, `sanitize` helper

**3. CSRF:**
- Rails `protect_from_forgery` enabled by default
- API mode uses `:null_session` (API keys/JWT instead)

**4. Mass Assignment:**
- Strong parameters prevent unauthorized field updates
- Never use `permit!` in production

**5. Insecure Direct Object Reference (IDOR):**
```ruby
# BAD — no authorization check
@project = Project.find(params[:id])

# GOOD — scoped to user's accessible projects
@project = current_user.projects.find(params[:id])
```

**6. Secret exposure:**
- Use Rails credentials or environment variables
- Never commit secrets to git
- Rotate secrets regularly

**Staff-level:** Security is layers — no single measure is enough. Combine framework protections, code review (security-focused), static analysis (Brakeman), dependency scanning (Dependabot), and penetration testing.

---

### Q132. How do you implement authentication and authorization at scale in a Rails app?

**Answer:**

**Authentication (who are you):**
- Devise gem for session-based auth (proven, feature-rich)
- JWT for API authentication (stateless, scalable)
- SSO/SAML for enterprise (OmniAuth SAML)

**JWT implementation:**
```ruby
class JsonWebToken
  SECRET = Rails.application.credentials.jwt_secret

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET, 'HS256')
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET, true, algorithm: 'HS256')
    HashWithIndifferentAccess.new(decoded.first)
  rescue JWT::DecodeError
    nil
  end
end
```

**Authorization (what can you do):**
- Pundit gem (explicit policy classes — recommended)
- CanCanCan (ability definitions in one file — simpler apps)

**Pundit pattern:**
```ruby
class ProjectPolicy < ApplicationPolicy
  def show?
    user.admin? || record.members.include?(user)
  end

  def update?
    user.admin? || record.owner == user
  end
end

# Controller
authorize @project  # raises Pundit::NotAuthorizedError if false
```

**Staff-level:** At Procore scale, authorization is complex (project-level, organization-level, feature-level). Consider Attribute-Based Access Control (ABAC) for fine-grained permissions. Cache permission checks aggressively (Redis) — authorization is on every request.

---

### Q133. How do you protect against timing attacks and brute force in Rails?

**Answer:**

**Timing attacks:**
```ruby
# BAD — early return leaks information
def authenticate(email, password)
  user = User.find_by(email: email)
  return false unless user  # Attacker learns email exists (different timing)
  user.password == password
end

# GOOD — constant-time comparison
def authenticate(email, password)
  user = User.find_by(email: email)
  stored_hash = user&.password_hash || DummyPassword.hash
  ActiveSupport::SecurityUtils.secure_compare(stored_hash, hash_password(password))
end
```

**Brute force protection:**
```ruby
# Rack::Attack (middleware-level)
Rack::Attack.throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
  req.ip if req.path == '/login' && req.post?
end

Rack::Attack.throttle('logins/email', limit: 5, period: 20.seconds) do |req|
  req.params['email'].to_s.downcase.strip if req.path == '/login' && req.post?
end
```

**Staff-level:** Rate limit by both IP AND account. Use exponential backoff for failed logins. Log and alert on brute force patterns.

---

### Q134. Explain the CAP theorem. How does it apply to a Rails + PostgreSQL + Redis system?

**Answer:**

**CAP theorem:** In a distributed system, you can guarantee at most two of:
- **Consistency (C):** All reads return the most recent write
- **Availability (A):** Every request receives a non-error response
- **Partition tolerance (P):** System continues despite network failures

**In practice:** Network partitions happen (P is mandatory), so you choose CP or AP.

**Rails + PostgreSQL (CP):**
- Synchronous replication = consistency
- If primary fails, replicas may not be promoted instantly = temporary unavailability
- PostgreSQL favors consistency over availability

**Redis (configurable):**
- Default: AP (asynchronous replication, may lose data on failover)
- Can be configured CP (wait for replicas to acknowledge)

**Application choices:**
- Financial transactions (billing): CP — consistency is critical
- Analytics/activity feeds: AP — availability preferred, stale data acceptable
- Sessions: AP — losing a session on partition is acceptable

**Staff-level:** Don't treat CAP as binary. PostgreSQL with synchronous_commit=remote_apply is "mostly CP" with configurable consistency. Understand your consistency requirements per feature, not per system.

---

### Q135. What are the different consistency models? Where does each apply in a SaaS platform?

**Answer:**

| Model | Description | Use Case |
|-------|-------------|----------|
| Strong | All reads see latest write | Financial transactions, permissions |
| Eventual | Reads may see stale data, converge later | Search indexes, analytics |
| Causal | Causally related operations ordered | Comment threads, activity feeds |
| Read-your-writes | User sees their own updates immediately | User profile edits |
| Monotonic reads | Reads don't go backward in time | Pagination, scrolling |

**Rails implementation:**
- Strong: Primary database reads
- Eventual: Read replicas, search indexes, caches
- Read-your-writes: Session stickiness or short-term primary routing after write

**Staff-level:** Most of your app can use eventual consistency (read replicas, cached data). Identify the 5-10% that needs strong consistency and route those to the primary database. Overusing strong consistency limits scalability.

---

### Q136. How do you implement distributed locking in Ruby? When do you need it?

**Answer:**

**Use cases:**
- Preventing duplicate background jobs
- Rate limiting across multiple servers
- Coordinated cache warming

**Redis Redlock:**
```ruby
require 'redlock'

lock_manager = Redlock::Client.new(["redis://localhost:6379"])

lock_info = lock_manager.lock("payment:#{order_id}", 2000)
if lock_info
  begin
    process_payment(order_id)
  ensure
    lock_manager.unlock(lock_info)
  end
else
  Rails.logger.info "Payment #{order_id} already being processed"
end
```

**PostgreSQL advisory locks:**
```ruby
# Database-level, no external dependency
ActiveRecord::Base.connection.execute("SELECT pg_advisory_lock(#{lock_id})")
begin
  yield
ensure
  ActiveRecord::Base.connection.execute("SELECT pg_advisory_unlock(#{lock_id})")
end
```

**Staff-level:** Advisory locks are simpler (no Redis dependency) but don't work across multiple databases. Use Redis for cross-service locking, PostgreSQL for same-DB operations. Always use `ensure` to release locks.

---

### Q137. Explain idempotency keys and how they prevent duplicate operations in distributed systems.

**Answer:**

**Pattern:** Client generates unique key for operation, server ensures operation only executes once for that key.

**Implementation:**
```ruby
class IdempotentAction
  def self.call(key:, &block)
    redis = Redis.current

    # Try to acquire lock
    acquired = redis.set("idempotency:#{key}", "processing", nx: true, ex: 3600)
    raise DuplicateRequestError unless acquired

    begin
      result = block.call
      redis.set("idempotency:#{key}", result.to_json, ex: 86400)
      result
    rescue => e
      redis.del("idempotency:#{key}")  # Allow retry
      raise
    end
  end
end

# Controller
class PaymentsController < ApplicationController
  def create
    result = IdempotentAction.call(key: request.headers['Idempotency-Key']) do
      PaymentService.charge(order: @order, amount: params[:amount])
    end
    render json: result
  rescue DuplicateRequestError
    render json: { status: 'already_processed' }, status: :conflict
  end
end
```

**Staff-level:** Return the same response for duplicate keys (replay the stored result). This makes retries safe. Idempotency keys are essential for payment APIs — never retry without them.

---

### Q138. How do you handle distributed transactions across multiple services?

**Answer:**

**Options (ordered by complexity):**

1. **Avoid distributed transactions** — Design boundaries to not need them

2. **Saga pattern** — Sequence of local transactions with compensating actions:
```
Create Order → Reserve Inventory → Charge Payment → Ship
  └─ fail ─┘  └─ fail, cancel order ─┘  └─ fail, release inventory, refund ─┘
```

3. **Transactional outbox** — As mentioned earlier, guarantee delivery via local DB + background publisher

4. **Two-phase commit** — Coordinated prepare/commit across services. Complex, blocking, rarely used in modern architectures.

**Rails implementation of Saga:**
```ruby
class OrderSaga
  def call(order)
    steps = [
      CreateOrderStep,
      ReserveInventoryStep,
      ChargePaymentStep,
      ScheduleShippingStep
    ]

    completed = []
    steps.each do |step|
      result = step.new(order).call
      if result.success?
        completed << step
      else
        completed.reverse_each(&:compensate)  # Rollback
        return Result.failure(result.error)
      end
    end

    Result.success(order)
  end
end
```

**Staff-level:** Prefer the Saga pattern over 2PC. It's eventually consistent, non-blocking, and aligns with microservices principles. The tradeoff is complexity in compensation logic.

---

### Q139. What is the difference between at-least-once, at-most-once, and exactly-once delivery?

**Answer:**

| Guarantee | Meaning | How to achieve |
|-----------|---------|----------------|
| At-most-once | May not deliver, but never duplicate | Fire and forget |
| At-least-once | Will deliver, may duplicate | Retry until acknowledged |
| Exactly-once | Delivered exactly one time | Idempotency + at-least-once delivery |

**The truth:** Exactly-once delivery doesn't exist in distributed systems. What we achieve is "exactly-once processing" through idempotency.

**In Rails:**
- Sidekiq: At-least-once (jobs may run multiple times)
- ActiveJob with `:async` adapter: At-most-once (fire and forget)
- Exactly-once: Build idempotent jobs + deduplication layer

**Staff-level:** Design for at-least-once delivery + idempotency. This is the only practical approach. Anything else gives you either lost messages or complex, fragile coordination.

---

### Q140. How do you handle backpressure in a system with producers and consumers?

**Answer:**

**Backpressure:** When consumers can't keep up with producers, the system degrades.

**Signs:**
- Queue depth growing continuously
- Memory usage growing (queued messages)
- Consumer lag increasing
- Timeouts as queues fill

**Strategies:**

1. **Bounded queues** (drop or reject when full):
```ruby
# Sidekiq doesn't bound by default — add middleware
class QueueLimiter
  def call(worker, job, queue)
    if Sidekiq::Queue.new(queue).size > 100_000
      raise QueueFullError, "#{queue} is at capacity"
    end
    yield
  end
end
```

2. **Rate limiting producers:**
```ruby
# Circuit breaker on producers
if queue_depth > threshold
  render json: { error: "System busy, try later" }, status: 503
end
```

3. **Scale consumers:**
```yaml
# HPA based on queue depth
metrics:
- type: External
  external:
    metric:
      name: sidekiq_queue_size
    target:
      type: Value
      value: "1000"
```

4. **Shed load:** Drop low-priority jobs when overloaded

**Staff-level:** Backpressure is a sign of architectural mismatch. Either scale consumers, slow producers, or redesign the flow. Don't just add memory — that delays the problem.

---

### Q141. How does concurrency work in Puma? How many threads and workers should you configure?

**Answer:**

**Puma architecture:**
```
Master Process
├── Worker 1 (forked process)
│   ├── Thread 1 → handling request
│   ├── Thread 2 → handling request
│   └── Thread 3 → idle
├── Worker 2 (forked process)
│   ├── Thread 1 → handling request
│   └── Thread 2 → idle
```

**Thread safety:**
- Rails is thread-safe (since Rails 4)
- Your code must be thread-safe (no global mutable state)
- Connection pool must be ≥ thread count

**Configuration formula:**
```ruby
# config/puma.rb
workers Integer(ENV.fetch('WEB_CONCURRENCY', 4))  # Match CPU cores
theads_count = Integer(ENV.fetch('RAILS_MAX_THREADS', 5))
threads threads_count, threads_count

# Pool size = threads (per worker)
# Total DB connections = workers × threads = 4 × 5 = 20 per pod
```

**Staff-level:** More workers for CPU-bound apps, more threads for I/O-bound apps. Rails is typically I/O bound (database queries), so optimize for threads. But GVL limits parallelism, so use multiple workers too.

---

### Q142. What are common thread safety issues in Rails? How do you avoid them?

**Answer:**

**1. Class variables:**
```ruby
# BAD — shared across all threads
class Counter
  @@count = 0  # Race condition!
  def self.increment; @@count += 1; end
end

# GOOD — thread-local or atomic
class Counter
  @count = Concurrent::AtomicFixnum.new
  def self.increment; @count.increment; end
end
```

**2. Mutable constants:**
```ruby
# BAD
EXCLUDED_IPS = []  # Threads can mutate
EXCLUDED_IPS << new_ip  # Race condition

# GOOD
EXCLUDED_IPS = ["10.0.0.1"].freeze
```

**3. Request state in class variables:**
```ruby
# BAD — leaks between requests
class CurrentContext
  @user = nil  # Class variable shared across requests!
end

# GOOD — use RequestStore or CurrentAttributes
class Current < ActiveSupport::CurrentAttributes
  attribute :user
end
```

**4. Lazy initialization:**
```ruby
# BAD — double-checked locking is broken in Ruby
@instance ||= ExpensiveObject.new  # Not atomic

# GOOD — eager initialization or Mutex
@instance = ExpensiveObject.new  # Initialize at boot
```

**Staff-level:** Use `RequestStore` gem for per-request state. Use `concurrent-ruby` for atomic operations. Avoid class-level mutable state entirely.

---

### Q143. How do you implement circuit breakers in a Rails application? When are they useful?

**Answer:**

**Circuit breaker pattern:**
- **Closed:** Requests flow through normally
- **Open:** Requests fail fast (after threshold of failures)
- **Half-open:** Test if service recovered (after timeout)

```ruby
# Using circuitbox gem
class ExternalApiClient
  circuit breaker_options: {
    sleep_window: 30,        # Try again after 30s
    volume_threshold: 10,    # Min requests before tripping
    error_threshold: 50,     # Trip at 50% error rate
    exception_filter: ->(error) { error.is_a?(TimeoutError) }
  } do
    def fetch_data
      HTTP.get("https://api.external.com/data")
    end
  end
end
```

**When to use:**
- Calling external APIs (they will fail)
- Non-critical dependencies (don't let them crash your app)
- Preventing cascade failures

**Staff-level:** Circuit breakers prevent cascade failures. If your email service is down, you don't want it to take down your entire app. Fail fast, degrade gracefully, recover automatically.

---

### Q144. How do you handle rate limiting in a distributed Rails cluster?

**Answer:**

**Token bucket with Redis:**
```ruby
class DistributedRateLimiter
  def self.allow?(key:, limit:, window: 60)
    redis = Redis.current
    now = Time.now.to_i

    redis.multi do |pipeline|
      pipeline.zremrangebyscore(key, 0, now - window)  # Clean old
      pipeline.zcard(key)                              # Count current
      pipeline.zadd(key, now, "#{now}-#{SecureRandom.hex(4)}")
      pipeline.expire(key, window)
    end.then do |_, count, _, _|
      count < limit
    end
  end
end
```

**Fixed window (simpler, allows bursts at boundaries):**
```ruby
current_minute = Time.now.strftime("%Y%m%d%H%M")
key = "rate_limit:#{user_id}:#{current_minute}"
count = redis.incr(key)
redis.expire(key, 60) if count == 1
count <= MAX_REQUESTS_PER_MINUTE
```

**Staff-level:** Sliding window log (token bucket) is most accurate but uses more Redis memory. For most APIs, sliding window counter is a good balance. Rate limit at the edge (API gateway) when possible, not in application code.

---

### Q145. How would you implement an event-driven architecture in a Rails application?

**Answer:**

**Architecture:**
```
Rails App → Event Bus (Kafka/SNS+SQS) → Consumers
                ↓
         Event Store (PostgreSQL outbox)
```

**Implementation with Rails Event Store:**
```ruby
# Gemfile
gem 'rails_event_store'

# Publish event
class ProjectService
  def complete_project(project)
    ActiveRecord::Base.transaction do
      project.update!(status: "completed")

      event_store.publish(
        ProjectCompleted.new(data: { project_id: project.id }),
        stream_name: "Project$#{project.id}"
      )
    end
  end
end

# Subscribe to events
class SendCompletionNotification
  def call(event)
    project = Project.find(event.data[:project_id])
    ProjectMailer.completed(project).deliver_later
  end
end

event_store.subscribe(SendCompletionNotification.new, to: [ProjectCompleted])
```

**Benefits:**
- Loose coupling between features
- Audit trail (event store = source of truth)
- Replay capability
- Parallel processing by different consumers

**Staff-level:** Event-driven architecture enables team autonomy — each team subscribes to events they care about without coordinating deploys. The tradeoff is eventual consistency and operational complexity (managing the event bus).

---

## Section J: Staff-Level Engineering Leadership (15 Questions)

---

### Q146. How do you make technical decisions when there is no clear "best" answer?

**Answer:**

**Decision framework:**

1. **Clarify constraints:** What are the non-negotiables? (time, budget, compliance, team skills)

2. **Identify options:** Generate at least 3 approaches (including "do nothing")

3. **Evaluate against criteria:**
| Criteria | Weight | Option A | Option B | Option C |
|----------|--------|----------|----------|----------|
| Time to implement | 30% | 2 weeks | 1 week | 4 weeks |
| Operational complexity | 25% | Medium | Low | High |
| Scalability ceiling | 25% | 1M users | 100K users | 10M users |
| Team familiarity | 20% | High | Medium | Low |

4. **Document tradeoffs:** Every choice has downsides — be explicit about them

5. **Decide and commit:** Avoid analysis paralysis. Set a decision deadline.

**Staff-level example:**
> "We needed a caching layer. Redis vs Memcached. Redis had more features (pub/sub, persistence) but higher operational complexity. We chose Redis because our team had experience and we'd need pub/sub for future features. The tradeoff was accepting operational overhead, which we mitigated by using AWS ElastiCache."

---

### Q147. How do you balance technical debt repayment with feature delivery?

**Answer:**

**Approaches:**

1. **20% rule:** Reserve 20% of sprint capacity for engineering improvements

2. **Debt taxonomy:**
   - **Toxic debt:** Must fix now (security vulnerabilities, data integrity risks)
   - **High-interest debt:** Fix soon (slowing team velocity, frequent bugs)
   - **Low-interest debt:** Fix opportunistically (code organization, minor refactoring)

3. **Boy scout rule:** Leave code better than you found it (small refactors with every feature)

4. **Refactoring sprints:** Every 4th sprint focused on platform improvements

5. **Track debt impact:** Measure velocity trends, bug rates, incident frequency. Use data to justify investment.

**Staff-level:** Don't frame tech debt as "engineering vs product." Frame it as risk management and velocity investment. Show metrics: "This refactor will reduce incident response time from 2 hours to 15 minutes, saving 10 engineer-hours per incident."

---

### Q148. How do you drive engineering standards across a large organization?

**Answer:**

**Mechanisms:**

1. **Architecture Decision Records (ADRs):**
```markdown
# ADR 012: Use Sidekiq for Background Processing
## Status: Accepted
## Context: We need reliable background job processing...
## Decision: Use Sidekiq Enterprise...
## Consequences: Requires Redis. Licensing cost $X/year...
```

2. **Engineering RFCs:** For significant changes, require an RFC review

3. **Linting and automation:** Standards enforced by CI, not by humans
   - RuboCop rules
   - Brakeman security checks
   - Required test coverage thresholds

4. **Guilds/Working groups:** Cross-team groups for specific concerns (performance, security, frontend)

5. **Internal tech talks:** Share knowledge, celebrate good practices

6. **Code review culture:** Reviewers check for standards compliance

**Staff-level:** Standards work when they're adopted, not imposed. Involve teams in creating standards. Start with "why" not "what." Make compliance the path of least resistance (automated, not manual).

---

### Q149. How do you handle a critical production incident? Walk through your response.

**Answer:**

**Incident response phases:**

**1. Detection (T+0):**
- Alert fires (PagerDuty)
- Acknowledge within 5 minutes

**2. Triage (T+0 to T+5):**
- Assess severity (SEV levels)
- Form incident response channel (Slack)
- Communicate: "We're investigating elevated error rates on Project API"

**3. Mitigation (T+5 to T+30):**
- **Goal:** Stop user impact, not necessarily fix root cause
- Options: Rollback deploy, scale up, enable circuit breaker, redirect traffic
- Communicate every 15 minutes

**4. Resolution (T+30+):**
- Root cause identified and fixed
- Confirm metrics back to normal
- Post "all clear" communication

**5. Post-incident review (within 48 hours):**
- Timeline reconstruction
- Root cause analysis (5 Whys)
- Action items with owners
- Publish internally (blameless)

**Staff-level:** Speed of mitigation is more important than speed of diagnosis. If rollback fixes it, rollback first, investigate after. The best incident response is automated — auto-rollback on error rate threshold.

---

### Q150. How do you mentor senior engineers and help them grow to staff level?

**Answer:**

**Mentoring approach:**

1. **Delegation with visibility:** Give them problems that span teams, not just technical challenges
   - "Lead the caching initiative across all services"
   - "Mentor the new team on our testing patterns"

2. **Explicit skill mapping:**
   - Staff engineers need: technical breadth, organizational influence, ambiguity tolerance
   - Identify gaps, create opportunities to practice

3. **Sponsorship, not just mentorship:**
   - Mention them in leadership meetings
   - Recommend them for high-visibility projects
   - Advocate for their promotion

4. **Feedback culture:**
   - Regular 1:1s focused on growth, not status
   - Specific, actionable feedback
   - "Here's what staff-level looks like — here's the gap"

5. **Model the behavior:**
   - Show how you approach ambiguous problems
   - Share your decision-making process
   - Be vulnerable about your own mistakes

**Staff-level:** Growing senior engineers to staff is a force-multiplier. Your impact as a staff engineer is measured not just by your own output, but by the staff engineers you develop.

---

### Q151. What is your approach to API versioning deprecation and sunsetting?

**Answer:**

**Deprecation lifecycle:**

1. **Announce (T+0):** Blog post, emails, in-app notifications
   - Headers: `Deprecation: true`, `Sunset: Mon, 01 Jan 2025 00:00:00 GMT`

2. **Dual support (T+0 to T+6 months):** Both versions operational
   - Monitor usage of old version
   - Reach out to high-usage clients directly

3. **Brownout (T+6 months):** Intermittent failures for old version
   - "Your client is using a deprecated API version"
   - Forces clients to notice and update

4. **Hard cutoff (T+9 months):** Return 410 Gone
   - Clear error message with migration guide link

**Implementation:**
```ruby
class ApiController < ApplicationController
  before_action :check_api_version

  private

  def check_api_version
    if request.headers['Accept']&.include?('v1') && sunset_date_passed?
      response.headers['Sunset'] = sunset_date.iso8601
      render json: { error: 'API v1 deprecated. See https://developers.procore.com/migration' }, 
             status: :gone
    end
  end
end
```

**Staff-level:** Never sunset an API without direct communication to every known consumer. Use API analytics to identify who's still using old versions. Offer migration assistance for enterprise customers.

---

### Q152. How do you evaluate a new technology for adoption in a production system?

**Answer:**

**Evaluation framework:**

1. **Problem fit:** Does it solve our specific problem better than current approach?
2. **Maturity:** Production usage at similar scale? Active maintenance?
3. **Operational complexity:** What's the ongoing cost?
4. **Team fit:** Does the team have skills to operate it?
5. **Exit strategy:** How hard to remove if it doesn't work?
6. **Ecosystem:** Community, documentation, commercial support?

**Process:**
```
Week 1-2: Research and POC (local)
Week 3-4: Production-like load testing
Week 5-6: Limited production canary (5% traffic)
Week 7-8: Gradual rollout with monitoring
Week 9+: Full rollout or rollback decision
```

**Staff-level:** Default to "boring technology." Only adopt new tech when current solutions clearly fail. The cost of technology is not adoption — it's ongoing operation and team context-switching.

---

### Q153. How do you handle disagreements with other staff engineers or architects about technical direction?

**Answer:**

**Framework for technical disagreements:**

1. **Align on goals:** "We both want a reliable, maintainable system. Let's agree on what we're optimizing for."

2. **Seek data, not opinions:**
   - "Let's prototype both approaches and measure"
   - "What's the operational history of this approach at similar companies?"

3. **Document tradeoffs explicitly:**
   | Criteria | Option A | Option B |
   | Cost | Lower upfront | Higher upfront |
   | Risk | Higher long-term | Lower long-term |

4. **Escalation path:** If still disagreeing after thorough discussion
   - Both present to broader group
   - Engineering director makes decision
   - **Disagree and commit** — support the decision once made

5. **Revisit with new data:** Set a review point to evaluate the decision

**Staff-level:** Technical disagreements are healthy — they mean people care. The red flag is when disagreements become personal or block progress. The goal is the best decision, not winning the argument.

---

### Q154. How do you think about reliability engineering? What SRE practices apply to Rails?

**Answer:**

**SRE principles for Rails:**

1. **Error budgets:** If SLO is 99.9% uptime, you get 43 minutes of downtime/month. If you use it all, freeze releases until reliability improves.

2. **Service Level Objectives (SLOs):**
   - Availability: 99.9% of requests succeed
   - Latency: p95 < 200ms
   - Freshness: Data updated within 5 minutes

3. **Service Level Indicators (SLIs):**
   - Request success rate
   - Request latency distribution
   - Queue processing lag

4. **Eliminating toil:**
   - Automated deployments
   - Auto-remediation for common issues
   - Self-service tooling for teams

5. **Blameless postmortems:** Focus on system improvements, not human error

**Staff-level:** SRE is a practice, not a team. Every Rails engineer should understand SLOs, error budgets, and incident response. Start with SLIs that matter to users, not just system metrics.

---

### Q155. How do you approach long-term technical strategy for a product like Procore?

**Answer:**

**Strategic thinking framework:**

1. **Understand the business:**
   - Where is revenue growing?
   - What are customer pain points?
   - What's the 3-year product vision?

2. **Map technical capabilities to business needs:**
   - "To support international expansion, we need multi-region infrastructure"
   - "To enable enterprise sales, we need SSO and audit logging"

3. **Identify bottlenecks before they hurt:**
   - "Our current architecture supports 1M users. At 5M, we'll need X, Y, Z."
   - Invest in foundations before they become blockers

4. **Build vs buy analysis:**
   - Core differentiators: Build (project management logic)
   - Commodities: Buy (auth, payments, email, analytics)

5. **Create technical roadmap:**
   - Quarterly themes with measurable outcomes
   - Align with product roadmap
   - Reserve capacity for unknowns

**Staff-level:** Technical strategy is not about cool technology — it's about enabling business outcomes. The best technical strategy is invisible to users but enables features they love.

---

---

# PART 2 — Refactoring Interview Exercises (30)

---

## Exercise 1: Fat Controller with Mixed Concerns

### The Bad Code:
```ruby
class InvoicesController < ApplicationController
  def create
    @invoice = Invoice.new(invoice_params)

    if @invoice.save
      # Send email
      InvoiceMailer.created(@invoice).deliver_now

      # Create audit log
      AuditLog.create!(user: current_user, action: "created_invoice", details: @invoice.to_json)

      # Sync to external accounting system
      if @invoice.amount > 10000
        response = HTTP.post("https://accounting.external.com/api/invoices", 
                            json: @invoice.as_json)
        if response.status == 200
          @invoice.update!(external_id: response.parse["id"])
        else
          Rails.logger.error("External sync failed: #{response.body}")
        end
      end

      # Update project budget
      project = @invoice.project
      project.update!(spent_budget: project.spent_budget + @invoice.amount)

      # Notify project members
      project.members.each do |member|
        Notification.create!(user: member, message: "New invoice: #{@invoice.number}")
      end

      redirect_to @invoice, notice: "Invoice created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error("Invoice creation failed: #{e.message}")
    redirect_to new_invoice_path, alert: "Something went wrong"
  end
end
```

### What's Wrong:
- **Violation of SRP:** Controller handles HTTP, business logic, side effects, external API calls
- **Synchronous external API call:** Blocks request, fails if accounting API is down
- **No transaction safety:** If notification fails, invoice is still saved but budget is wrong
- **deliver_now blocks request:** Email sending is synchronous
- **Bare rescue:** Catches all exceptions, hides real errors
- **No idempotency:** Retrying creates duplicate notifications and double-counts budget

### Improved Version:
```ruby
class InvoicesController < ApplicationController
  def create
    result = InvoiceCreationService.call(
      params: invoice_params,
      creator: current_user
    )

    if result.success?
      redirect_to result.invoice, notice: "Invoice created successfully"
    else
      @invoice = result.invoice
      render :new, status: :unprocessable_entity
    end
  end
end

class InvoiceCreationService
  Result = Struct.new(:success?, :invoice, keyword_init: true)

  def self.call(params:, creator:)
    new(params: params, creator: creator).call
  end

  def initialize(params:, creator:)
    @params = params
    @creator = creator
  end

  def call
    invoice = Invoice.new(@params)
    return Result.new(success?: false, invoice: invoice) unless invoice.valid?

    ActiveRecord::Base.transaction do
      invoice.save!
      update_project_spending(invoice)
    end

    enqueue_side_effects(invoice)
    Result.new(success?: true, invoice: invoice)
  rescue ActiveRecord::RecordInvalid => e
    Result.new(success?: false, invoice: invoice)
  end

  private

  def update_project_spending(invoice)
    project = invoice.project
    project.increment!(:spent_budget, invoice.amount)
  end

  def enqueue_side_effects(invoice)
    InvoiceMailer.created(invoice).deliver_later
    AuditLogJob.perform_later(action: "created_invoice", actor: @creator, target: invoice)
    InvoiceExternalSyncJob.perform_later(invoice) if invoice.amount > 10_000
    InvoiceNotificationJob.perform_later(invoice)
  end
end
```

### Why the New Design is Better:
- Service object encapsulates business logic
- Transaction wraps critical operations (invoice + budget update)
- Side effects happen asynchronously via jobs
- Each job is independently retryable and idempotent
- Controller only handles HTTP concerns

### Interviewer Follow-ups:
1. "How would you make this idempotent if the user retries the request?"
2. "What happens if the transaction succeeds but the Sidekiq jobs fail to enqueue?"
3. "How would you handle the external accounting API being down?"

---

## Exercise 2: N+1 Query in a Report

### The Bad Code:
```ruby
class ProjectReportController < ApplicationController
  def show
    @projects = Project.where(organization: current_org).limit(100)

    @report_data = @projects.map do |project|
      {
        name: project.name,
        budget: project.budget,
        spent: project.invoices.sum(:amount),
        task_count: project.tasks.count,
        member_count: project.members.count,
        last_activity: project.activities.order(created_at: :desc).first&.created_at,
        owner_name: project.owner.name,
        owner_email: project.owner.email,
        completion_percentage: project.tasks.where(status: "completed").count.to_f / project.tasks.count * 100
      }
    end
  end
end
```

### What's Wrong:
- **N+1 queries:** For 100 projects: 100× invoices sum + 100× tasks count + 100× members count + 100× activities query + 100× owner load + 100× tasks completed count = 600+ queries
- **Multiple queries per project:** Each attribute triggers a separate database hit
- **No eager loading:** Owner not loaded, associations not preloaded

### Improved Version:
```ruby
class ProjectReportController < ApplicationController
  def show
    @report_data = Project.where(organization: current_org)
      .includes(:owner, :members, :tasks)
      .left_joins(:invoices, :activities)
      .select(
        "projects.*",
        "COALESCE(SUM(invoices.amount), 0) as spent_amount",
        "COUNT(DISTINCT tasks.id) as task_count",
        "COUNT(DISTINCT members_projects.user_id) as member_count",
        "MAX(activities.created_at) as last_activity_at",
        "SUM(CASE WHEN tasks.status = 'completed' THEN 1 ELSE 0 END) as completed_tasks"
      )
      .group("projects.id, users.id")
      .limit(100)
      .map do |project|
        {
          name: project.name,
          budget: project.budget,
          spent: project.spent_amount,
          task_count: project.task_count,
          member_count: project.member_count,
          last_activity: project.last_activity_at,
          owner_name: project.owner.name,
          owner_email: project.owner.email,
          completion_percentage: project.completed_tasks.to_f / project.task_count * 100
        }
      end
  end
end
```

### Alternative (if query is too complex):
```ruby
# Use a materialized view for this report
class ProjectReport < ApplicationRecord
  self.table_name = "project_reports_mv"

  def self.refresh
    connection.execute("REFRESH MATERIALIZED VIEW CONCURRENTLY project_reports_mv")
  end
end

# Schedule refresh every 15 minutes
```

### Interviewer Follow-ups:
1. "What if there are 10,000 projects? Would you still do this in the controller?"
2. "How would you handle this if the query is still too slow after optimization?"
3. "When would a materialized view be better than a complex query?"

---

## Exercise 3: Race Condition in Financial Operation

### The Bad Code:
```ruby
class TransferService
  def self.transfer(from_account_id, to_account_id, amount)
    from_account = Account.find(from_account_id)
    to_account = Account.find(to_account_id)

    if from_account.balance >= amount
      from_account.update!(balance: from_account.balance - amount)
      to_account.update!(balance: to_account.balance + amount)
      Transaction.create!(from: from_account, to: to_account, amount: amount)
      true
    else
      false
    end
  end
end
```

### What's Wrong:
- **Read-modify-write race condition:** Two concurrent transfers can overdraft the account
- **Non-atomic check and update:** Balance check and update are separate operations
- **No database locking:** Concurrent reads see the same balance

### Improved Version:
```ruby
class TransferService
  Result = Struct.new(:success?, :error, keyword_init: true)

  def self.transfer(from_account_id, to_account_id, amount)
    new(from_account_id, to_account_id, amount).call
  end

  def call
    ActiveRecord::Base.transaction do
      # Lock both accounts in consistent order to prevent deadlocks
      from_account, to_account = lock_accounts

      if from_account.balance < @amount
        return Result.new(success?: false, error: "Insufficient funds")
      end

      from_account.update!(balance: from_account.balance - @amount)
      to_account.update!(balance: to_account.balance + @amount)

      LedgerEntry.create!(
        from_account: from_account,
        to_account: to_account,
        amount: @amount,
        occurred_at: Time.current
      )
    end

    Result.new(success?: true)
  rescue ActiveRecord::Deadlocked
    retry if (@retries += 1) < 3
    Result.new(success?: false, error: "Transaction conflict, please retry")
  end

  private

  def lock_accounts
    Account.where(id: [@from_id, @to_id])
           .order(:id)  # Consistent ordering prevents deadlocks
           .lock
           .to_a
           .sort_by { |a| a.id == @from_id ? 0 : 1 }
  end
end
```

### Interviewer Follow-ups:
1. "How would this work with a multi-region database setup?"
2. "What if the transaction table insert fails after the balance updates?"
3. "How would you handle this at scale with thousands of transfers per second?"

---

## Exercise 4: Thread-Unsafe Singleton with Mutable State

### The Bad Code:
```ruby
class ApiRateLimiter
  include Singleton

  def initialize
    @counts = Hash.new(0)
    @reset_at = Time.current + 60
  end

  def allow?(client_id)
    reset_if_needed
    @counts[client_id] += 1
    @counts[client_id] <= 100
  end

  private

  def reset_if_needed
    if Time.current > @reset_at
      @counts = Hash.new(0)
      @reset_at = Time.current + 60
    end
  end
end
```

### What's Wrong:
- **Not thread-safe:** Multiple Puma threads access `@counts` simultaneously
- **Race condition on increment:** `@counts[client_id] += 1` is not atomic
- **Race condition on reset:** One thread resets while another increments
- **Singleton in multi-process environment:** Each Puma worker has its own instance

### Improved Version:
```ruby
class ApiRateLimiter
  def self.allow?(client_id, limit: 100, window: 60)
    new.allow?(client_id, limit: limit, window: window)
  end

  def allow?(client_id, limit:, window:)
    redis = Redis.current
    key = "rate_limit:#{client_id}"
    now = Time.now.to_i

    redis.multi do |pipeline|
      pipeline.zremrangebyscore(key, 0, now - window)
      pipeline.zcard(key)
      pipeline.zadd(key, now, "#{now}-#{SecureRandom.hex(4)}")
      pipeline.expire(key, window)
    end.then do |_, count, _, _|
      count < limit
    end
  end
end
```

### Interviewer Follow-ups:
1. "What if Redis is temporarily unavailable?"
2. "How would you implement a sliding window instead of fixed window?"
3. "How does this work in a multi-region setup?"

---

## Exercise 5: God Object Anti-Pattern

### The Bad Code:
```ruby
class User < ApplicationRecord
  # Auth (200 lines)
  devise :database_authenticatable, :recoverable, :rememberable

  def authenticate(password); ...; end
  def generate_jwt; ...; end
  def verify_two_factor(code); ...; end
  def reset_password(token, new_password); ...; end
  def oauth_login(provider, token); ...; end

  # Billing (150 lines)
  def current_subscription; ...; end
  def can_access_feature?(feature); ...; end
  def process_payment(amount); ...; end
  def generate_invoice; ...; end
  def apply_discount(code); ...; end
  def billing_address; ...; end

  # Notifications (100 lines)
  def notification_preferences; ...; end
  def unread_notification_count; ...; end
  def send_push_notification(message); ...; end
  def mark_notifications_read; ...; end
  def email_notification_enabled?(type); ...; end

  # Project access (150 lines)
  def can_view_project?(project); ...; end
  def can_edit_project?(project); ...; end
  def accessible_projects; ...; end
  def project_role(project); ...; end

  # Profile (100 lines)
  def display_name; ...; end
  def avatar_url; ...; end
  def timezone; ...; end
  def language_preference; ...; end

  # Activity tracking (100 lines)
  def log_activity(action, target); ...; end
  def recent_activity(limit: 20); ...; end
  def activity_count(since: 1.week.ago); ...; end
end
```

### What's Wrong:
- **800+ lines:** Violates SRP massively
- **Mixed concerns:** Auth, billing, notifications, authorization, profile all in one class
- **High coupling:** Any change to billing affects User model tests
- **Difficult to test:** Need to understand entire class to test one method
- **Naming confusion:** `User` does everything

### Improved Version:
```ruby
class User < ApplicationRecord
  # Only core user data and associations
  has_secure_password

  has_one :profile, dependent: :destroy
  has_one :billing_account, dependent: :destroy
  has_many :project_memberships, dependent: :destroy
  has_many :projects, through: :project_memberships
  has_many :notification_preferences, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[active suspended deactivated] }
end

# app/services/user_authenticator.rb
class UserAuthenticator
  def initialize(user)
    @user = user
  end

  def authenticate(password)
    BCrypt::Password.new(@user.password_digest).is_password?(password)
  end

  def generate_jwt(expires_in: 24.hours)
    JwtService.encode(user_id: @user.id, exp: expires_in.from_now.to_i)
  end
end

# app/policies/user_project_policy.rb
class UserProjectPolicy
  def initialize(user, project)
    @user = user
    @project = project
  end

  def can_view?
    @project.members.include?(@user) || @user.admin?
  end

  def can_edit?
    membership&.role.in?(%w[admin editor])
  end

  private

  def membership
    @membership ||= @project.project_memberships.find_by(user: @user)
  end
end

# app/services/billing_service.rb
class BillingService
  def initialize(user)
    @user = user
  end

  def can_access_feature?(feature)
    subscription = @user.billing_account&.current_subscription
    return false unless subscription
    subscription.plan.features.include?(feature.to_s)
  end
end

# app/services/notification_service.rb
class NotificationService
  def initialize(user)
    @user = user
  end

  def unread_count
    @user.notifications.where(read_at: nil).count
  end

  def preferences
    @user.notification_preferences.index_by(&:notification_type)
  end
end
```

### Interviewer Follow-ups:
1. "How do you refactor this incrementally without breaking existing code?"
2. "What order would you extract these concerns?"
3. "How do you handle the transitional period with both old and new code?"

---

## Exercise 6: Deeply Nested Conditionals

### The Bad Code:
```ruby
def can_perform_action?(user, project, action)
  if user.active?
    if project.active?
      if project.organization == user.organization
        if action == "view"
          true
        elsif action == "edit"
          if user.role == "admin" || user.role == "editor"
            if project.status != "archived"
              true
            else
              false
            end
          else
            false
          end
        elsif action == "delete"
          if user.role == "admin"
            if project.invoices.empty?
              true
            else
              false
            end
          else
            false
          end
        else
          false
        end
      else
        false
      end
    else
      false
    end
  else
    false
  end
end
```

### What's Wrong:
- **Cyclomatic complexity:** 2^6 = 64 possible paths
- **Arrow anti-pattern:** Deep nesting makes logic hard to follow
- **Repeated `false` returns:** Violates "tell, don't ask"
- **Implicit guard clauses:** User active? check should be first

### Improved Version:
```ruby
class ProjectPermissionChecker
  def initialize(user, project)
    @user = user
    @project = project
  end

  def can_perform?(action)
    return false unless user_active_and_in_same_org?
    return false unless project_accessible?

    case action.to_sym
    when :view   then true
    when :edit   then can_edit?
    when :delete then can_delete?
    else false
    end
  end

  private

  def user_active_and_in_same_org?
    @user.active? && @project.organization_id == @user.organization_id
  end

  def project_accessible?
    @project.active?
  end

  def can_edit?
    editor_or_admin? && project_not_archived?
  end

  def can_delete?
    admin? && project_has_no_invoices?
  end

  def editor_or_admin?
    @user.role.in?(%w[admin editor])
  end

  def admin?
    @user.role == "admin"
  end

  def project_not_archived?
    @project.status != "archived"
  end

  def project_has_no_invoices?
    @project.invoices.none?
  end
end
```

### Interviewer Follow-ups:
1. "How would you add audit logging to this without cluttering the logic?"
2. "What if permissions need to be checked hundreds of times per request?"
3. "How would you handle role inheritance (editor inherits viewer permissions)?"

---

## Exercise 7: Slow Report Query with Multiple Subqueries

### The Bad Code:
```ruby
class ProjectDashboardQuery
  def self.generate(organization_id)
    projects = Project.where(organization_id: organization_id)

    projects.map do |project|
      {
        project: project,
        total_budget: project.budget,
        total_invoices: Invoice.where(project_id: project.id).count,
        total_invoice_amount: Invoice.where(project_id: project.id).sum(:amount),
        pending_invoices: Invoice.where(project_id: project.id, status: "pending").count,
        paid_invoices: Invoice.where(project_id: project.id, status: "paid").count,
        overdue_invoices: Invoice.where(project_id: project.id, status: "pending")
                                .where("due_date < ?", Date.current).count,
        team_members: User.joins(:project_memberships)
                         .where(project_memberships: { project_id: project.id }).count,
        tasks_total: Task.where(project_id: project.id).count,
        tasks_completed: Task.where(project_id: project.id, status: "completed").count,
        tasks_overdue: Task.where(project_id: project.id)
                         .where("due_date < ? AND status != ?", Date.current, "completed").count,
        recent_activities: Activity.where(project_id: project.id)
                                  .order(created_at: :desc)
                                  .limit(5)
                                  .to_a
      }
    end
  end
end
```

### What's Wrong:
- **12 queries per project:** For 100 projects = 1200 queries
- **N+1 subqueries:** Each `Invoice.where`, `Task.where` is a separate query
- **Loading recent activities per project:** 5 records × 100 projects = 500 activity records

### Improved Version:
```ruby
class ProjectDashboardQuery
  def self.generate(organization_id)
    projects = fetch_projects(organization_id)
    project_ids = projects.map(&:id)

    stats = fetch_aggregate_stats(project_ids)
    activities = fetch_recent_activities(project_ids)

    projects.map do |project|
      build_project_data(project, stats, activities)
    end
  end

  def self.fetch_projects(organization_id)
    Project.where(organization_id: organization_id).to_a
  end

  def self.fetch_aggregate_stats(project_ids)
    Project.where(id: project_ids)
      .left_joins(:invoices, :tasks, :project_memberships)
      .select(
        "projects.id",
        "COUNT(DISTINCT invoices.id) as total_invoices",
        "COALESCE(SUM(invoices.amount), 0) as total_invoice_amount",
        "COUNT(DISTINCT CASE WHEN invoices.status = 'pending' THEN invoices.id END) as pending_invoices",
        "COUNT(DISTINCT CASE WHEN invoices.status = 'paid' THEN invoices.id END) as paid_invoices",
        "COUNT(DISTINCT CASE WHEN invoices.status = 'pending' AND invoices.due_date < CURRENT_DATE THEN invoices.id END) as overdue_invoices",
        "COUNT(DISTINCT project_memberships.user_id) as team_members",
        "COUNT(DISTINCT tasks.id) as tasks_total",
        "COUNT(DISTINCT CASE WHEN tasks.status = 'completed' THEN tasks.id END) as tasks_completed",
        "COUNT(DISTINCT CASE WHEN tasks.due_date < CURRENT_DATE AND tasks.status != 'completed' THEN tasks.id END) as tasks_overdue"
      )
      .group("projects.id")
      .index_by(&:id)
  end

  def self.fetch_recent_activities(project_ids)
    Activity.where(project_id: project_ids)
      .order(created_at: :desc)
      .limit(5)
      .group_by(&:project_id)
  end

  def self.build_project_data(project, stats, activities)
    stat = stats[project.id]
    {
      project: project,
      total_budget: project.budget,
      total_invoices: stat&.total_invoices || 0,
      total_invoice_amount: stat&.total_invoice_amount || 0,
      pending_invoices: stat&.pending_invoices || 0,
      paid_invoices: stat&.paid_invoices || 0,
      overdue_invoices: stat&.overdue_invoices || 0,
      team_members: stat&.team_members || 0,
      tasks_total: stat&.tasks_total || 0,
      tasks_completed: stat&.tasks_completed || 0,
      tasks_overdue: stat&.tasks_overdue || 0,
      recent_activities: activities[project.id] || []
    }
  end
end
```

### Interviewer Follow-ups:
1. "What if this is still too slow for real-time dashboard?"
2. "How would you cache this data?"
3. "What if you need this data for 1000 projects?"

---

## Exercise 8: Poor Error Handling with Silent Failures

### The Bad Code:
```ruby
class DocumentSyncService
  def sync_all
    Document.find_each do |document|
      begin
        response = HTTP.timeout(30).get(document.external_url)
        if response.status.success?
          document.update(content: response.body.to_s, synced_at: Time.current)
        end
      rescue
        # Just skip failed documents
      end
    end
  end
end
```

### What's Wrong:
- **Bare `rescue`:** Catches everything including `SyntaxError`, `SignalException`
- **Silent failure:** Failed documents are silently skipped — data loss
- **No logging:** No way to know which documents failed or why
- **No retry mechanism:** Temporary failures become permanent
- **Timeout too long:** 30 seconds per document × thousands = hours
- **No circuit breaker:** If external service is down, hammers it repeatedly

### Improved Version:
```ruby
class DocumentSyncService
  MAX_RETRIES = 3
  TIMEOUT = 10
  BATCH_SIZE = 100

  def self.sync_all
    new.sync_all
  end

  def sync_all
    failed_ids = []

    Document.needs_sync.find_each(batch_size: BATCH_SIZE) do |document|
      result = sync_one(document)
      failed_ids << document.id unless result
    end

    report_failures(failed_ids)
  end

  def sync_one(document, attempt: 1)
    response = HTTP.timeout(TIMEOUT).get(document.external_url)

    if response.status.success?
      document.update!(content: response.body.to_s, synced_at: Time.current, sync_error: nil)
      true
    else
      handle_failure(document, "HTTP #{response.status}", attempt: attempt)
    end
  rescue HTTP::TimeoutError, HTTP::ConnectionError => e
    handle_failure(document, "#{e.class}: #{e.message}", attempt: attempt, retryable: true)
  rescue HTTP::Error => e
    handle_failure(document, "#{e.class}: #{e.message}", attempt: attempt)
  rescue StandardError => e
    handle_failure(document, "Unexpected: #{e.class}: #{e.message}", attempt: attempt)
    Rails.error.report(e)  # Send to error tracking
  end

  private

  def handle_failure(document, error_message, attempt:, retryable: false)
    if retryable && attempt < MAX_RETRIES
      DocumentSyncJob.perform_in(2**attempt.minutes, document.id, attempt + 1)
      return false  # Will retry
    end

    document.update!(
      sync_error: error_message,
      failed_sync_at: Time.current
    )
    false
  end

  def report_failures(failed_ids)
    return if failed_ids.empty?

    Rails.logger.warn("Document sync: #{failed_ids.size} documents failed",
                      document_ids: failed_ids)

    AlertJob.perform_later(
      severity: :warning,
      message: "#{failed_ids.size} documents failed to sync",
      details: { document_ids: failed_ids.first(50) }
    ) if failed_ids.size > 10
  end
end

class DocumentSyncJob
  include Sidekiq::Worker
  sidekiq_options retry: 3, queue: :low

  def perform(document_id, attempt = 1)
    document = Document.find(document_id)
    DocumentSyncService.new.sync_one(document, attempt: attempt)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info "Document #{document_id} no longer exists, skipping sync"
  end
end
```

### Interviewer Follow-ups:
1. "How would you handle rate limiting from the external service?"
2. "What if there are 1 million documents to sync?"
3. "How do you prevent this job from running forever if external service is down?"

---

## Exercise 9: Inefficient Data Export

### The Bad Code:
```ruby
class ExportController < ApplicationController
  def export_projects
    projects = Project.where(organization: current_org)

    csv_data = CSV.generate do |csv|
      csv << ["ID", "Name", "Budget", "Owner", "Members", "Tasks", "Invoices", "Created"]

      projects.each do |project|
        csv << [
          project.id,
          project.name,
          project.budget,
          project.owner&.name,
          project.members.map(&:name).join(", "),
          project.tasks.count,
          project.invoices.sum(:amount),
          project.created_at
        ]
      end
    end

    send_data csv_data, filename: "projects.csv", type: "text/csv"
  end
end
```

### What's Wrong:
- **N+1 queries:** Each project loads owner, members, tasks count, invoices sum
- **Memory bloat:** Loads all projects into memory, builds entire CSV in memory
- **Request timeout:** Large exports will timeout before completing
- **Blocks web worker:** Long-running request holds Puma thread

### Improved Version:
```ruby
class ExportController < ApplicationController
  def export_projects
    ExportProjectsJob.perform_later(current_org.id, current_user.id)
    render json: { message: "Export queued. You'll receive an email when ready." }
  end
end

class ExportProjectsJob
  include Sidekiq::Worker

  def perform(organization_id, user_id)
    user = User.find(user_id)

    # Stream to temp file (constant memory)
    temp_file = Tempfile.new(["projects_export", ".csv"])

    CSV.open(temp_file.path, "w") do |csv|
      csv << ["ID", "Name", "Budget", "Owner", "Members", "Tasks", "Invoices", "Created"]

      Project.where(organization_id: organization_id)
             .includes(:owner, :members)
             .find_each(batch_size: 500) do |project|
        csv << [
          project.id,
          project.name,
          project.budget,
          project.owner&.name,
          project.members.map(&:name).join(", "),
          project.tasks_count,        # Counter cache
          project.invoices_total_cache, # Cached/precomputed
          project.created_at.iso8601
        ]
      end
    end

    # Upload to S3
    s3_key = "exports/projects/#{organization_id}/#{SecureRandom.uuid}.csv"
    S3_CLIENT.put_object(bucket: BUCKET, key: s3_key, body: File.open(temp_file.path))

    # Notify user
    ExportMailer.ready(user, s3_key).deliver_later
  ensure
    temp_file&.close
    temp_file&.unlink
  end
end
```

### Interviewer Follow-ups:
1. "What if the export needs to include data the user shouldn't see?"
2. "How would you implement progress tracking for large exports?"
3. "How do you handle CSV injection attacks?"

---

## Exercise 10: Mutable Default Arguments

### The Bad Code:
```ruby
class ReportBuilder
  def initialize(filters = [])
    @filters = filters
  end

  def add_filter(filter)
    @filters << filter
  end

  def build
    @filters.each { |f| apply(f) }
    generate_output
  end
end

# Usage:
r1 = ReportBuilder.new
r1.add_filter("date_range")

r2 = ReportBuilder.new  # Gets the same mutable array!
r2.add_filter("status") # Now r1 also has "status" filter!
```

### What's Wrong:
- **Ruby evaluates default arguments once:** `filters = []` creates one array shared across all instances that use the default
- **State leakage:** `r2` modifying default array affects `r1`

### Improved Version:
```ruby
class ReportBuilder
  def initialize(filters = nil)
    @filters = filters || []
  end

  def add_filter(filter)
    @filters << filter
    self  # Fluent interface
  end

  def build
    @filters.each { |f| apply(f) }
    generate_output
  end

  private

  def apply(filter)
    # ...
  end

  def generate_output
    # ...
  end
end

# Usage:
r1 = ReportBuilder.new.add_filter("date_range")
r2 = ReportBuilder.new.add_filter("status")  # Independent instances
```

---

## Exercise 11: Callback Hell

### The Bad Code:
```ruby
class Project < ApplicationRecord
  after_create :create_default_tasks, :notify_owner, :setup_external_integration
  after_update :notify_members_of_changes, :sync_to_accounting_if_budget_changed,
               :update_search_index, :invalidate_cache
  after_destroy :cleanup_files, :remove_external_records, :notify_team_of_deletion

  private

  def create_default_tasks
    ["Planning", "Design", "Construction", "Inspection"].each do |name|
      tasks.create!(name: name, status: "pending")
    end
  end

  def notify_owner
    ProjectMailer.created(self).deliver_now  # Blocks save!
  end

  def setup_external_integration
    response = ExternalApi.create_project(self)
    update_column(:external_id, response["id"])  # Skip callbacks!
  end

  def notify_members_of_changes
    changes = saved_changes
    members.each do |member|
      ProjectMailer.updated(self, member, changes).deliver_now
    end
  end

  def sync_to_accounting_if_budget_changed
    if saved_change_to_budget?
      AccountingApi.sync_project(self)  # HTTP call in callback!
    end
  end

  # ... more callbacks
end
```

### What's Wrong:
- **Hidden control flow:** Side effects scattered across callbacks, invisible to callers
- **Synchronous external calls:** `deliver_now` and HTTP calls block model save
- **Skip callbacks abuse:** `update_column` bypasses validations and callbacks
- **Transaction boundary issues:** Some callbacks run in transaction, some after
- **Testing nightmare:** Need to stub all side effects to test model creation
- **Infinite callback risk:** One callback triggers another model that triggers this one

### Improved Version:
```ruby
class Project < ApplicationRecord
  # No callbacks for business logic
  has_many :tasks, dependent: :destroy
  has_many :project_memberships, dependent: :destroy
  has_many :members, through: :project_memberships
end

class ProjectCreationService
  def initialize(organization:, owner:, params:)
    @organization = organization
    @owner = owner
    @params = params
  end

  def call
    project = build_project
    return Result.failure(project) unless project.valid?

    ActiveRecord::Base.transaction do
      project.save!
      create_default_tasks(project)
    end

    enqueue_post_creation_work(project)
    Result.success(project)
  end

  private

  def build_project
    @organization.projects.build(@params.merge(owner: @owner))
  end

  def create_default_tasks(project)
    default_tasks = ["Planning", "Design", "Construction", "Inspection"]
    default_tasks.each do |name|
      project.tasks.create!(name: name, status: "pending")
    end
  end

  def enqueue_post_creation_work(project)
    ProjectNotificationJob.perform_later(project, "created")
    ExternalIntegrationJob.perform_later(project)
  end
end
```

### Interviewer Follow-ups:
1. "How would you migrate from the callback-based approach incrementally?"
2. "When are callbacks actually appropriate in Rails?"
3. "How do you test the service object?"

---

## Exercise 12: String Concatenation in SQL Queries

### The Bad Code:
```ruby
class SearchController < ApplicationController
  def search
    query = "SELECT * FROM projects WHERE organization_id = #{current_org.id}"

    if params[:status].present?
      query += " AND status = '#{params[:status]}'"
    end

    if params[:min_budget].present?
      query += " AND budget >= #{params[:min_budget]}"
    end

    if params[:search].present?
      query += " AND (name ILIKE '%#{params[:search]}%' OR description ILIKE '%#{params[:search]}%')"
    end

    if params[:sort].present?
      query += " ORDER BY #{params[:sort]} #{params[:direction] || 'ASC'}"
    end

    @projects = Project.find_by_sql(query)
  end
end
```

### What's Wrong:
- **SQL Injection:** Direct string interpolation of user input
- **Order injection:** `params[:sort]` could be any column, or a SQL function
- **No pagination:** Loads all matching records into memory
- **Bypasses ActiveRecord:** No query caching, no prepared statements

### Improved Version:
```ruby
class SearchController < ApplicationController
  ALLOWED_SORT_COLUMNS = %w[name budget created_at updated_at].freeze
  ALLOWED_DIRECTIONS = %w[asc desc].freeze

  def search
    @projects = ProjectQuery.new(current_org.projects)
      .with_status(params[:status])
      .with_min_budget(params[:min_budget])
      .search_text(params[:search])
      .order_by(sort_column, sort_direction)
      .page(params[:page])
      .per(params[:per_page] || 25)
      .call
  end

  private

  def sort_column
    ALLOWED_SORT_COLUMNS.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
    ALLOWED_DIRECTIONS.include?(params[:direction]&.downcase) ? params[:direction].downcase : "desc"
  end
end

class ProjectQuery
  def initialize(scope = Project.all)
    @scope = scope
  end

  def with_status(status)
    @scope = @scope.where(status: status) if status.present?
    self
  end

  def with_min_budget(min_budget)
    @scope = @scope.where("budget >= ?", min_budget) if min_budget.present?
    self
  end

  def search_text(term)
    return self if term.blank?
    @scope = @scope.where("name ILIKE ? OR description ILIKE ?", "%#{term}%", "%#{term}%")
    self
  end

  def order_by(column, direction)
    @scope = @scope.order("#{column} #{direction}")
    self
  end

  def page(page)
    @scope = @scope.page(page)
    self
  end

  def per(count)
    @scope = @scope.per(count)
    self
  end

  def call
    @scope
  end
end
```

### Interviewer Follow-ups:
1. "How would you add full-text search with PostgreSQL?"
2. "How would you handle complex search with multiple filters combined?"
3. "What if you need to search across associations too?"

---

## Exercise 13: Tight Coupling to External Service

### The Bad Code:
```ruby
class PaymentProcessor
  def charge(amount, card_number, expiry, cvv)
    # Direct Stripe integration
    Stripe::Charge.create(
      amount: (amount * 100).to_i,
      currency: 'usd',
      card: {
        number: card_number,
        exp_month: expiry.split('/')[0],
        exp_year: expiry.split('/')[1],
        cvc: cvv
      },
      description: "Payment for project"
    )
  rescue Stripe::CardError => e
    { success: false, error: e.message }
  rescue Stripe::StripeError => e
    Rails.logger.error("Stripe error: #{e.message}")
    { success: false, error: "Payment service unavailable" }
  end

  def refund(charge_id)
    Stripe::Refund.create(charge: charge_id)
  end
end

# Usage everywhere in codebase:
class InvoicePaymentService
  def pay(invoice, card_details)
    result = PaymentProcessor.new.charge(invoice.amount, card_details[:number], ...)
    if result[:success]
      invoice.update!(paid: true)
    else
      invoice.update!(payment_error: result[:error])
    end
  end
end
```

### What's Wrong:
- **Tight coupling to Stripe:** Every payment class depends on Stripe directly
- **Testing difficulty:** Can't test without Stripe credentials/mocks
- **No abstraction:** Switching to Braintree requires changing every caller
- **Raw card handling:** PCI compliance risk — should use tokens
- **Mixed concerns:** Payment processing + error handling + invoice update all in one

### Improved Version:
```ruby
# app/gateways/payment_gateway.rb
class PaymentGateway
  def self.for(provider = :default)
    gateway_class = Rails.configuration.payment_gateway_class
    gateway_class.new
  end
end

# app/gateways/stripe_gateway.rb
class StripeGateway
  def charge(amount:, payment_method_id:, description:)
    stripe_charge = Stripe::PaymentIntent.create(
      amount: to_cents(amount),
      currency: 'usd',
      payment_method: payment_method_id,
      confirm: true,
      description: description
    )

    PaymentResult.success(
      transaction_id: stripe_charge.id,
      status: map_status(stripe_charge.status)
    )
  rescue Stripe::CardError => e
    PaymentResult.declined(error_message: e.message, code: e.code)
  rescue Stripe::StripeError => e
    Rails.logger.error("Payment gateway error", error: e.message)
    PaymentResult.error(error_message: "Payment service temporarily unavailable")
  end

  def refund(transaction_id:)
    Stripe::Refund.create(payment_intent: transaction_id)
    PaymentResult.success(transaction_id: transaction_id)
  rescue Stripe::StripeError => e
    PaymentResult.error(error_message: e.message)
  end

  private

  def to_cents(amount)
    (amount * 100).round
  end

  def map_status(stripe_status)
    { 'succeeded' => :successful, 'processing' => :pending }[stripe_status] || :failed
  end
end

# app/value_objects/payment_result.rb
class PaymentResult
  attr_reader :transaction_id, :status, :error_message, :error_code

  def self.success(transaction_id:, status: :successful)
    new(transaction_id: transaction_id, status: status)
  end

  def self.declined(error_message:, code:)
    new(status: :declined, error_message: error_message, error_code: code)
  end

  def self.error(error_message:)
    new(status: :error, error_message: error_message)
  end

  def initialize(transaction_id: nil, status:, error_message: nil, error_code: nil)
    @transaction_id = transaction_id
    @status = status
    @error_message = error_message
    @error_code = error_code
  end

  def successful?; @status == :successful; end
  def declined?; @status == :declined; end
  def error?; @status == :error; end
end

# app/services/invoice_payment_service.rb
class InvoicePaymentService
  def initialize(gateway: PaymentGateway.for)
    @gateway = gateway
  end

  def pay(invoice:, payment_method_id:)
    result = @gateway.charge(
      amount: invoice.amount,
      payment_method_id: payment_method_id,
      description: "Invoice ##{invoice.number}"
    )

    record_result(invoice, result)
    result
  end

  private

  def record_result(invoice, result)
    ActiveRecord::Base.transaction do
      case result.status
      when :successful
        invoice.update!(status: "paid", paid_at: Time.current, transaction_id: result.transaction_id)
      when :declined
        invoice.update!(status: "payment_declined", last_payment_error: result.error_message)
      else
        invoice.update!(last_payment_error: result.error_message)
      end
    end
  end
end
```

### Interviewer Follow-ups:
1. "How would you add a new payment provider alongside Stripe?"
2. "How do you test this without making real Stripe calls?"
3. "How would you handle webhook verification from multiple providers?"

---

## Exercise 14: Memory Leak from Caching

### The Bad Code:
```ruby
class PriceCalculator
  def initialize
    @cache = {}
  end

  def calculate(project_id)
    return @cache[project_id] if @cache.key?(project_id)

    project = Project.find(project_id)
    materials = MaterialCost.where(project_id: project_id).sum(:cost)
    labor = LaborEntry.where(project_id: project_id).sum(:hours) * project.hourly_rate
    overhead = project.budget * 0.15

    result = materials + labor + overhead
    @cache[project_id] = result
    result
  end
end
```

### What's Wrong:
- **Unbounded cache:** `@cache` grows forever — every project ID is cached
- **No eviction:** Old entries are never removed
- **Memory leak:** In a long-running Sidekiq job or Puma worker, this OOMs eventually
- **No TTL:** Cached values become stale when underlying data changes

### Improved Version:
```ruby
class PriceCalculator
  CACHE_TTL = 1.hour

  def self.calculate(project_id)
    new.calculate(project_id)
  end

  def calculate(project_id)
    Rails.cache.fetch("price_calculation/#{project_id}", expires_in: CACHE_TTL) do
      compute_price(project_id)
    end
  end

  private

  def compute_price(project_id)
    project = Project.find(project_id)
    materials = project.material_costs.sum(:cost)
    labor = project.labor_entries.sum(:hours) * project.hourly_rate
    overhead = project.budget * 0.15

    materials + labor + overhead
  end
end
```

### Interviewer Follow-ups:
1. "How would you invalidate this cache when material costs change?"
2. "What if the calculation takes 30 seconds? How do you prevent cache stampede?"
3. "How would you warm this cache for all active projects?"

---

## Exercise 15: Feature Envy and Law of Demeter Violation

### The Bad Code:
```ruby
class InvoicePdfGenerator
  def generate(invoice)
    pdf = Prawn::Document.new

    pdf.text "Invoice ##{invoice.number}"
    pdf.text "Date: #{invoice.created_at.strftime('%B %d, %Y')}"
    pdf.text "Due: #{invoice.due_date.strftime('%B %d, %Y')}"
    pdf.text ""
    pdf.text "From:"
    pdf.text invoice.project.organization.name
    pdf.text invoice.project.organization.address_line_1
    pdf.text "#{invoice.project.organization.city}, #{invoice.project.organization.state} #{invoice.project.organization.zip}"
    pdf.text ""
    pdf.text "To:"
    pdf.text invoice.project.owner.name
    pdf.text invoice.project.owner.email
    pdf.text ""
    pdf.text "Project: #{invoice.project.name}"
    pdf.text "Line Items:"
    invoice.line_items.each do |item|
      pdf.text "#{item.description}: $#{'%.2f' % item.amount}"
    end
    pdf.text ""
    pdf.text "Subtotal: $#{'%.2f' % invoice.subtotal}"
    pdf.text "Tax: $#{'%.2f' % invoice.tax}"
    pdf.text "Total: $#{'%.2f' % invoice.total}"
    pdf.text ""
    pdf.text "Payment Terms: #{invoice.project.organization.payment_terms}"
    pdf.text "Late Fee: #{invoice.project.organization.late_fee_percentage}% per month"

    pdf.render
  end
end
```

### What's Wrong:
- **Feature Envy:** Generator constantly reaching through `invoice` to `project` to `organization`
- **Law of Demeter violations:** `invoice.project.organization.name` chains through 3 objects
- **Brittle:** If organization address structure changes, this breaks
- **Testing difficulty:** Need full object graph set up to test PDF generation

### Improved Version:
```ruby
class InvoicePdfGenerator
  def generate(invoice)
    context = InvoicePdfContext.new(invoice)

    Prawn::Document.new do |pdf|
      render_header(pdf, context)
      render_parties(pdf, context)
      render_line_items(pdf, context)
      render_totals(pdf, context)
      render_terms(pdf, context)
    end.render
  end

  private

  def render_header(pdf, ctx)
    pdf.text "Invoice ##{ctx.invoice_number}"
    pdf.text "Date: #{ctx.formatted_invoice_date}"
    pdf.text "Due: #{ctx.formatted_due_date}"
  end

  def render_parties(pdf, ctx)
    pdf.text "From:"
    pdf.text ctx.sender_name
    pdf.text ctx.sender_address
    pdf.text ""
    pdf.text "To:"
    pdf.text ctx.recipient_name
    pdf.text ctx.recipient_email
    pdf.text ""
    pdf.text "Project: #{ctx.project_name}"
  end

  def render_line_items(pdf, ctx)
    pdf.text "Line Items:"
    ctx.line_items.each do |item|
      pdf.text "#{item.description}: #{item.formatted_amount}"
    end
  end

  def render_totals(pdf, ctx)
    pdf.text ""
    pdf.text "Subtotal: #{ctx.formatted_subtotal}"
    pdf.text "Tax: #{ctx.formatted_tax}"
    pdf.text "Total: #{ctx.formatted_total}"
  end

  def render_terms(pdf, ctx)
    pdf.text ""
    pdf.text "Payment Terms: #{ctx.payment_terms}"
    pdf.text "Late Fee: #{ctx.late_fee_percentage}% per month"
  end
end

class InvoicePdfContext
  attr_reader :invoice

  def initialize(invoice)
    @invoice = invoice
  end

  # Invoice details
  def invoice_number; invoice.number; end
  def formatted_invoice_date; invoice.created_at.strftime('%B %d, %Y'); end
  def formatted_due_date; invoice.due_date.strftime('%B %d, %Y'); end

  # Sender (delegated to presenter)
  def sender_name; sender.name; end
  def sender_address; sender.formatted_address; end
  def payment_terms; sender.payment_terms; end
  def late_fee_percentage; sender.late_fee_percentage; end

  # Recipient
  def recipient_name; recipient.name; end
  def recipient_email; recipient.email; end

  # Project
  def project_name; invoice.project.name; end

  # Line items
  def line_items
    invoice.line_items.map { |li| LineItemContext.new(li) }
  end

  # Totals
  def formatted_subtotal; format_money(invoice.subtotal); end
  def formatted_tax; format_money(invoice.tax); end
  def formatted_total; format_money(invoice.total); end

  private

  def sender; @sender ||= OrganizationPresenter.new(invoice.project.organization); end
  def recipient; @recipient ||= UserPresenter.new(invoice.project.owner); end

  def format_money(amount)
    "$#{'%.2f' % amount}"
  end
end
```

### Interviewer Follow-ups:
1. "How would you make the PDF template customizable per organization?"
2. "What if you need to generate thousands of PDFs for a report?"
3. "How would you add internationalization to this PDF?"

---

## Exercise 16: Missing Database Indexes

### The Bad Code:
```ruby
# Migration that created these tables without indexes
class CreateProjectsAndTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :status
      t.integer :organization_id
      t.integer :owner_id
      t.decimal :budget
      t.timestamps
    end

    create_table :tasks do |t|
      t.string :name
      t.string :status
      t.integer :project_id
      t.integer :assignee_id
      t.date :due_date
      t.timestamps
    end
  end
end
```

### Common Queries (all slow):
```ruby
# No indexes = sequential scans on large tables
Project.where(organization_id: 123).count  # Seq scan
Task.where(assignee_id: 456).where("due_date < ?", Date.current)  # Seq scan
Project.where(status: "active").order(updated_at: :desc).limit(20)  # Seq scan + sort
Task.joins(:project).where(projects: { organization_id: 123 })  # Seq scan both tables
```

### What's Wrong:
- **No indexes on foreign keys:** Every join is a sequential scan
- **No indexes for filtering:** `WHERE status = ?`, `WHERE due_date < ?` scan entire tables
- **No composite indexes:** Multi-column filters can't use single-column indexes together

### Improved Migration:
```ruby
class AddIndexesToProjectsAndTasks < ActiveRecord::Migration[7.1]
  def change
    # Foreign key indexes (always add these)
    add_index :projects, :organization_id, algorithm: :concurrently
    add_index :projects, :owner_id, algorithm: :concurrently
    add_index :tasks, :project_id, algorithm: :concurrently
    add_index :tasks, :assignee_id, algorithm: :concurrently

    # Filtering indexes
    add_index :projects, :status, algorithm: :concurrently
    add_index :tasks, :status, algorithm: :concurrently

    # Composite indexes for common query patterns
    # WHERE organization_id = ? AND status = ? ORDER BY updated_at DESC
    add_index :projects, [:organization_id, :status, :updated_at], 
              name: "idx_projects_org_status_updated", 
              algorithm: :concurrently

    # WHERE assignee_id = ? AND due_date < ?
    add_index :tasks, [:assignee_id, :due_date], 
              where: "status != 'completed'",
              name: "idx_tasks_assignee_due_active",
              algorithm: :concurrently

    # Partial index for active projects (most queries filter for these)
    add_index :projects, :updated_at,
              where: "status = 'active'",
              name: "idx_active_projects_updated",
              algorithm: :concurrently
  end
end
```

### Interviewer Follow-ups:
1. "How do you add indexes to a table with 100 million rows without downtime?"
2. "When would a covering index (INCLUDE) be better than a regular composite index?"
3. "How do you monitor if an index is actually being used?"

---

## Exercise 17: Inefficient Counter Implementation

### The Bad Code:
```ruby
class Project
  def completion_percentage
    return 0 if tasks.empty?
    (tasks.where(status: "completed").count.to_f / tasks.count) * 100
  end

  def budget_remaining
    invoices.sum(:amount) - budget
  end

  def days_overdue
    return 0 unless due_date && due_date < Date.current
    (Date.current - due_date).to_i
  end

  def team_member_count
    members.count
  end
end

# Dashboard that calls these for 100 projects
@projects.each do |project|
  puts "#{project.name}: #{project.completion_percentage}% done, "        "$#{project.budget_remaining} remaining, #{project.team_member_count} members"
end
```

### What's Wrong:
- **4 queries per project:** For 100 projects = 400 queries
- **Counter cache not used:** `members.count` should use counter cache
- **Repeated calculations:** Same calculations on every dashboard load
- **No caching:** Results not cached even though they change infrequently

### Improved Version:
```ruby
class Project < ApplicationRecord
  # Counter caches
  counter_cache_of :tasks

  # Cached column updates via callbacks (or better, via jobs)
  after_update_commit :update_derived_stats, if: :saved_change_to_status?

  def completion_percentage
    return 0 if tasks_count == 0
    (completed_tasks_count.to_f / tasks_count * 100).round(1)
  end

  def budget_remaining
    budget - total_invoiced_amount
  end

  def days_overdue
    return 0 unless due_date && due_date < Date.current && status != "completed"
    (Date.current - due_date).to_i
  end

  private

  def update_derived_stats
    update_columns(
      completed_tasks_count: tasks.where(status: "completed").count,
      total_invoiced_amount: invoices.sum(:amount)
    )
  end
end

# Migration to add cached columns
class AddCachedColumnsToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :completed_tasks_count, :integer, default: 0
    add_column :projects, :total_invoiced_amount, :decimal, precision: 15, scale: 2, default: 0
    add_column :projects, :tasks_count, :integer, default: 0  # For counter_cache
  end
end

# Dashboard query (single query)
Project.where(organization: current_org)
       .select(:name, :completed_tasks_count, :tasks_count, 
               :budget, :total_invoiced_amount, :members_count)
       .each do |project|
  puts "#{project.name}: #{project.completion_percentage}% done"
end
```

---

## Exercise 18: Brittle Test with External Dependencies

### The Bad Test:
```ruby
RSpec.describe WeatherService do
  describe "#current_temperature" do
    it "returns the current temperature" do
      service = WeatherService.new
      temp = service.current_temperature(zip: "90210")

      expect(temp).to be_a(Float)
      expect(temp).to be > 0
      expect(temp).to be < 150
    end

    it "returns different temperatures for different cities" do
      service = WeatherService.new
      la = service.current_temperature(zip: "90210")
      ny = service.current_temperature(zip: "10001")

      expect(la).not_to eq(ny)
    end
  end
end
```

### What's Wrong:
- **Real HTTP calls:** Tests hit actual weather API (slow, flaky, requires network)
- **Vague assertions:** `be > 0` passes even if API returns wrong data
- **Location-dependent:** Tests fail if run from different locations
- **No error testing:** Doesn't test API failure scenarios
- **State-dependent:** Temperature changes, tests become non-deterministic

### Improved Test:
```ruby
RSpec.describe WeatherService do
  describe "#current_temperature" do
    let(:gateway) { instance_double(WeatherGateway) }
    let(:service) { described_class.new(gateway: gateway) }

    context "when API returns valid data" do
      before do
        allow(gateway).to receive(:fetch_current)
          .with(zip: "90210")
          .and_return({
            temperature: 72.5,
            unit: "F",
            humidity: 45,
            cached: false
          })
      end

      it "returns the temperature" do
        result = service.current_temperature(zip: "90210")
        expect(result.temperature).to eq(72.5)
        expect(result.unit).to eq("F")
      end
    end

    context "when API is unavailable" do
      before do
        allow(gateway).to receive(:fetch_current)
          .and_raise(WeatherGateway::TimeoutError)
      end

      it "returns cached value if available" do
        allow(gateway).to receive(:fetch_cached)
          .with(zip: "90210")
          .and_return({ temperature: 70.0, unit: "F", cached: true })

        result = service.current_temperature(zip: "90210")
        expect(result.temperature).to eq(70.0)
        expect(result).to be_stale
      end

      it "raises unavailable error when no cache" do
        allow(gateway).to receive(:fetch_cached).and_return(nil)

        expect {
          service.current_temperature(zip: "90210")
        }.to raise_error(WeatherService::UnavailableError)
      end
    end

    context "when API returns invalid data" do
      before do
        allow(gateway).to receive(:fetch_current)
          .and_return({ temperature: "invalid", unit: nil })
      end

      it "raises a parse error" do
        expect {
          service.current_temperature(zip: "90210")
        }.to raise_error(WeatherService::ParseError)
      end
    end
  end
end
```

---

## Exercise 19: Missing Authorization Checks

### The Bad Code:
```ruby
class DocumentsController < ApplicationController
  def show
    @document = Document.find(params[:id])
    send_data @document.file_data, filename: @document.filename, type: @document.content_type
  end

  def destroy
    @document = Document.find(params[:id])
    @document.destroy!
    redirect_to project_path(@document.project), notice: "Document deleted"
  end

  def update
    @document = Document.find(params[:id])
    @document.update!(document_params)
    redirect_to @document, notice: "Document updated"
  end

  def download
    @document = Document.find(params[:id])
    redirect_to @document.presigned_url, allow_other_host: true
  end
end
```

### What's Wrong:
- **IDOR vulnerability:** Any authenticated user can access any document by ID
- **No organization scoping:** Document from org A accessible by org B user
- **No role checks:** Viewer can delete documents
- **No audit logging:** No record of who accessed what

### Improved Version:
```ruby
class DocumentsController < ApplicationController
  before_action :load_and_authorize_document, only: [:show, :destroy, :update, :download]

  def show
    authorize! @document, :read?
    AuditLog.log!(action: "document_viewed", actor: current_user, target: @document)
    send_data @document.file_data, filename: @document.filename, type: @document.content_type
  end

  def destroy
    authorize! @document, :delete?

    ActiveRecord::Base.transaction do
      @document.destroy!
      AuditLog.log!(action: "document_deleted", actor: current_user, target: @document)
    end

    redirect_to project_path(@document.project), notice: "Document deleted"
  end

  def update
    authorize! @document, :edit?
    @document.update!(document_params)
    redirect_to @document, notice: "Document updated"
  end

  def download
    authorize! @document, :download?
    AuditLog.log!(action: "document_downloaded", actor: current_user, target: @document)
    redirect_to @document.presigned_url, allow_other_host: true
  end

  private

  def load_and_authorize_document
    @document = current_user.accessible_documents.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    # Log potential probing attempt
    SecurityLog.record!(user: current_user, action: "document_access_denied", target_id: params[:id])
    raise Pundit::NotAuthorizedError, "Document not found or access denied"
  end
end

class User < ApplicationRecord
  def accessible_documents
    Document.joins(:project)
            .where(projects: { organization_id: organization_id })
            .merge(ProjectPolicy::Scope.new(self, Project.all).resolve)
  end
end
```

---

## Exercise 20: Race Condition in Cache-Aside Pattern

### The Bad Code:
```ruby
class ProjectCache
  def self.fetch_with_cache(project_id)
    cached = Rails.cache.read("project/#{project_id}")
    return cached if cached

    project = Project.find(project_id)
    data = serialize(project)
    Rails.cache.write("project/#{project_id}", data, expires_in: 1.hour)
    data
  end

  def self.invalidate(project_id)
    Rails.cache.delete("project/#{project_id}")
  end
end
```

### What's Wrong:
- **Cache stampede:** 100 requests hit simultaneously when cache expires — all 100 hit DB
- **Thundering herd:** DB overwhelmed by simultaneous identical queries
- **No locking:** Multiple processes can simultaneously compute and write same value

### Improved Version:
```ruby
class ProjectCache
  CACHE_TTL = 1.hour
  LOCK_TTL = 30.seconds

  def self.fetch_with_cache(project_id)
    cache_key = "project/#{project_id}"

    # Fast path: cache hit
    cached = Rails.cache.read(cache_key)
    return cached if cached

    # Acquire lock to prevent stampede
    lock_key = "lock:#{cache_key}"
    acquired = Rails.cache.write(lock_key, true, expires_in: LOCK_TTL, unless_exist: true)

    if acquired
      begin
        project = Project.find(project_id)
        data = serialize(project)
        Rails.cache.write(cache_key, data, expires_in: CACHE_TTL)
        data
      ensure
        Rails.cache.delete(lock_key)
      end
    else
      # Another process is computing — wait and try again
      sleep 0.1
      fetch_with_cache(project_id)
    end
  end

  private

  def self.serialize(project)
    {
      id: project.id,
      name: project.name,
      status: project.status,
      budget: project.budget,
      cached_at: Time.current.iso8601
    }
  end
end
```

---

## Exercise 21: Duplicate Logic Across Controllers

### The Bad Code:
```ruby
class ProjectsController < ApplicationController
  def index
    @projects = Project.where(organization: current_org)
    if params[:status].present?
      @projects = @projects.where(status: params[:status])
    end
    if params[:search].present?
      @projects = @projects.where("name ILIKE ?", "%#{params[:search]}%")
    end
    @projects = @projects.order(created_at: :desc).page(params[:page])
  end
end

class Api::V1::ProjectsController < ApplicationController
  def index
    @projects = Project.where(organization: current_org)
    if params[:status].present?
      @projects = @projects.where(status: params[:status])
    end
    if params[:search].present?
      @projects = @projects.where("name ILIKE ?", "%#{params[:search]}%")
    end
    @projects = @projects.order(created_at: :desc).page(params[:page])
    render json: @projects
  end
end

class Admin::ProjectsController < ApplicationController
  def index
    @projects = Project.all
    if params[:status].present?
      @projects = @projects.where(status: params[:status])
    end
    if params[:search].present?
      @projects = @projects.where("name ILIKE ?", "%#{params[:search]}%")
    end
    @projects = @projects.order(created_at: :desc).page(params[:page])
  end
end
```

### Improved Version:
```ruby
# app/queries/project_query.rb
class ProjectQuery
  def self.for(controller)
    new(controller.current_org.projects)
  end

  def self.admin
    new(Project.all)
  end

  def initialize(scope = Project.all)
    @scope = scope
  end

  def filter_by_status(status)
    @scope = @scope.where(status: status) if status.present?
    self
  end

  def search_by_name(term)
    @scope = @scope.where("name ILIKE ?", "%#{term}%") if term.present?
    self
  end

  def ordered(direction: :desc)
    @scope = @scope.order(created_at: direction)
    self
  end

  def paginated(page:, per_page: 25)
    @scope = @scope.page(page).per(per_page)
    self
  end

  def call
    @scope
  end
end

# Usage in controllers:
class ProjectsController < ApplicationController
  def index
    @projects = ProjectQuery.for(self)
      .filter_by_status(params[:status])
      .search_by_name(params[:search])
      .ordered
      .paginated(page: params[:page])
      .call
  end
end

class Api::V1::ProjectsController < ApplicationController
  def index
    @projects = ProjectQuery.for(self)
      .filter_by_status(params[:status])
      .search_by_name(params[:search])
      .ordered
      .paginated(page: params[:page])
      .call
    render json: @projects
  end
end
```

---

## Exercise 22: Synchronous External API in Request Path

### The Bad Code:
```ruby
class ShippingQuotesController < ApplicationController
  def create
    package = Package.find(params[:package_id])

    quotes = []

    # Sequential API calls - each 2-5 seconds
    fedex = FedexApi.get_rate(package.weight, package.dimensions, package.destination)
    quotes << { carrier: "FedEx", rate: fedex[:rate], days: fedex[:transit_days] }

    ups = UpsApi.get_rate(package.weight, package.dimensions, package.destination)
    quotes << { carrier: "UPS", rate: ups[:rate], days: ups[:transit_days] }

    usps = UspsApi.get_rate(package.weight, package.dimensions, package.destination)
    quotes << { carrier: "USPS", rate: usps[:rate], days: usps[:transit_days] }

    render json: quotes.sort_by { |q| q[:rate] }
  rescue => e
    render json: { error: "Unable to get shipping quotes" }, status: 503
  end
end
```

### What's Wrong:
- **15+ second response time:** Sequential API calls block the request
- **All-or-nothing failure:** One carrier down = no quotes at all
- **No timeout handling:** Slow carrier makes request hang indefinitely
- **No caching:** Same package quotes fetched repeatedly

### Improved Version:
```ruby
class ShippingQuotesController < ApplicationController
  TIMEOUT = 5.seconds

  def create
    package = Package.find(params[:package_id])
    cache_key = shipping_cache_key(package)

    quotes = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
      fetch_all_quotes(package)
    end

    render json: quotes.sort_by { |q| q[:rate] }
  end

  private

  def fetch_all_quotes(package)
    carriers = {
      "FedEx" => FedexGateway.new,
      "UPS" => UpsGateway.new,
      "USPS" => UspsGateway.new
    }

    # Parallel execution with timeout and fallback
    results = carriers.map do |name, gateway|
      fetch_with_timeout(name, gateway, package)
    end

    results.compact
  end

  def fetch_with_timeout(carrier_name, gateway, package)
    Timeout.timeout(TIMEOUT) do
      rate = gateway.get_rate(package.to_shipping_params)
      { carrier: carrier_name, rate: rate.amount, days: rate.transit_days, currency: rate.currency }
    end
  rescue Timeout::Error
    Rails.logger.warn("Shipping quote timeout", carrier: carrier_name, package_id: package.id)
    nil
  rescue StandardError => e
    Rails.logger.error("Shipping quote error", carrier: carrier_name, error: e.message)
    nil
  end

  def shipping_cache_key(package)
    "shipping_quotes:#{package.cache_key}:#{package.destination.cache_key}"
  end
end
```

---

## Exercise 23: Data Migration in Model Callback

### The Bad Code:
```ruby
class Project < ApplicationRecord
  after_save :migrate_legacy_data, if: :saved_change_to_status?

  private

  def migrate_legacy_data
    if status == "active" && legacy_id.present?
      # Sync to new system
      LegacyDataMigrator.migrate_project(self)

      # Update external references
      ExternalSystem.where(legacy_project_id: legacy_id).update_all(project_id: id)

      # Notify stakeholders
      Stakeholder.where(legacy_project_id: legacy_id).each do |s|
        s.update!(project_id: id)
        NotificationService.notify(s.user, "Project migrated: #{name}")
      end
    end
  end
end
```

### What's Wrong:
- **Synchronous data migration:** Model save blocks while migration runs
- **External API calls in callback:** Unpredictable latency, failure modes
- **Mass updates in callback:** `update_all` on large tables in save transaction
- **Notification in callback:** Side effect that should be async
- **Non-repeatable:** If migration fails mid-way, partial data state

### Improved Version:
```ruby
class Project < ApplicationRecord
  after_update_commit :trigger_migration, if: :activated_from_legacy?

  private

  def activated_from_legacy?
    saved_change_to_status? && status == "active" && legacy_id.present?
  end

  def trigger_migration
    LegacyProjectMigrationJob.perform_later(id)
  end
end

class LegacyProjectMigrationJob
  include Sidekiq::Worker
  sidekiq_options retry: 5, queue: :migrations

  def perform(project_id)
    project = Project.find(project_id)
    return unless project.legacy_id.present?

    ActiveRecord::Base.transaction do
      migrate_external_references(project)
      migrate_stakeholders(project)
      project.update!(legacy_migration_status: "completed", legacy_migration_completed_at: Time.current)
    end

    notify_stakeholders(project)
  rescue => e
    project.update!(legacy_migration_status: "failed", legacy_migration_error: e.message)
    raise
  end

  private

  def migrate_external_references(project)
    ExternalSystem.where(legacy_project_id: project.legacy_id)
                  .update_all(project_id: project.id)
  end

  def migrate_stakeholders(project)
    Stakeholder.where(legacy_project_id: project.legacy_id)
               .find_each do |stakeholder|
      stakeholder.update!(project_id: project.id)
    end
  end

  def notify_stakeholders(project)
    project.stakeholders.each do |stakeholder|
      MigrationNotificationJob.perform_later(stakeholder.id, project.id)
    end
  end
end
```

---

## Exercise 24: Stringly-Typed Status Field

### The Bad Code:
```ruby
class Invoice < ApplicationRecord
  def status_label
    case status
    when "pending" then "Pending Approval"
    when "approved" then "Approved"
    when "sent" then "Sent to Customer"
    when "paid" then "Paid"
    when "overdue" then "Overdue"
    when "cancelled" then "Cancelled"
    when "disputed" then "Under Dispute"
    when "write_off" then "Written Off"
    else "Unknown"
    end
  end

  def can_edit?
    status == "pending" || status == "disputed"
  end

  def can_send?
    status == "approved"
  end

  def can_mark_paid?
    status == "sent" || status == "overdue"
  end

  def overdue?
    status == "overdue" || (status == "sent" && due_date < Date.current)
  end
end

# Scattered throughout codebase:
Invoice.where(status: "pending").update_all(status: "approved")
if invoice.status == "paid"
# etc.
```

### Improved Version:
```ruby
class Invoice < ApplicationRecord
  enum status: {
    pending: "pending",
    approved: "approved",
    sent: "sent",
    paid: "paid",
    overdue: "overdue",
    cancelled: "cancelled",
    disputed: "disputed",
    write_off: "write_off"
  }

  STATUS_LABELS = {
    pending: "Pending Approval",
    approved: "Approved",
    sent: "Sent to Customer",
    paid: "Paid",
    overdue: "Overdue",
    cancelled: "Cancelled",
    disputed: "Under Dispute",
    write_off: "Written Off"
  }.freeze

  EDITABLE_STATUSES = %w[pending disputed].freeze
  SENDABLE_STATUSES = %w[approved].freeze
  PAYABLE_STATUSES = %w[sent overdue].freeze

  def status_label
    STATUS_LABELS[status.to_sym] || "Unknown"
  end

  def can_edit?; EDITABLE_STATUSES.include?(status); end
  def can_send?; SENDABLE_STATUSES.include?(status); end
  def can_mark_paid?; PAYABLE_STATUSES.include?(status); end

  def overdue?
    return true if overdue?
    sent? && due_date.present? && due_date < Date.current
  end

  # State machine transitions
  def approve!
    raise InvalidStatusTransition, "Can only approve pending invoices" unless pending?
    update!(status: :approved, approved_at: Time.current, approved_by: Current.user)
  end

  def send_to_customer!
    raise InvalidStatusTransition, "Can only send approved invoices" unless approved?
    update!(status: :sent, sent_at: Time.current)
    InvoiceMailer.sent(self).deliver_later
  end
end
```

---

## Exercise 25: HTTP Client Without Timeout or Retry

### The Bad Code:
```ruby
class ExternalApiClient
  BASE_URL = "https://api.partner.com/v1"

  def self.fetch_project_data(external_project_id)
    response = HTTP.get("#{BASE_URL}/projects/#{external_project_id}")
    JSON.parse(response.body)
  end

  def self.update_project_status(external_project_id, status)
    response = HTTP.post(
      "#{BASE_URL}/projects/#{external_project_id}/status",
      json: { status: status }
    )
    response.status == 200
  end

  def self.sync_documents(external_project_id, documents)
    documents.each do |doc|
      response = HTTP.post(
        "#{BASE_URL}/projects/#{external_project_id}/documents",
        json: doc.to_json
      )
      raise "Sync failed" unless response.status == 201
    end
  end
end
```

### What's Wrong:
- **No timeouts:** Requests can hang indefinitely
- **No retries:** Network blip causes permanent failure
- **No error handling:** HTTP errors crash the caller
- **No circuit breaker:** Hammering a failing service makes it worse
- **No logging:** Silent failures, impossible to debug
- **Synchronous document sync:** Slow, blocks caller

### Improved Version:
```ruby
class ExternalApiClient
  BASE_URL = "https://api.partner.com/v1"
  DEFAULT_TIMEOUT = 10
  MAX_RETRIES = 3
  RETRYABLE_ERRORS = [
    HTTP::TimeoutError,
    HTTP::ConnectionError,
    HTTP::RedirectError
  ].freeze

  def self.fetch_project_data(external_project_id)
    new.fetch("/projects/#{external_project_id}")
  end

  def initialize(timeout: DEFAULT_TIMEOUT)
    @timeout = timeout
    @client = HTTP.timeout(connect: timeout / 2, read: timeout)
                   .headers("Content-Type" => "application/json",
                           "Accept" => "application/json",
                           "Authorization" => "Bearer #{api_key}")
  end

  def fetch(path)
    with_retry do
      response = @client.get("#{BASE_URL}#{path}")
      handle_response(response)
    end
  rescue => e
    log_error("GET #{path}", e)
    raise ApiError, "Failed to fetch: #{e.message}"
  end

  def post(path, body)
    with_retry do
      response = @client.post("#{BASE_URL}#{path}", json: body)
      handle_response(response)
    end
  rescue => e
    log_error("POST #{path}", e)
    raise ApiError, "Failed to post: #{e.message}"
  end

  private

  def with_retry(attempt = 1)
    yield
  rescue *RETRYABLE_ERRORS => e
    if attempt < MAX_RETRIES
      sleep(2 ** attempt)  # Exponential backoff
      retry
    end
    raise
  end

  def handle_response(response)
    case response.status
    when 200..299
      JSON.parse(response.body.to_s)
    when 404
      raise NotFoundError, response.parse["error"]
    when 429
      retry_after = response.headers['Retry-After']&.to_i || 60
      raise RateLimitError.new(retry_after: retry_after)
    else
      raise ApiError, "HTTP #{response.status}: #{response.body}"
    end
  end

  def api_key
    Rails.application.credentials.partner_api_key
  end

  def log_error(context, error)
    Rails.logger.error("[ExternalApi] #{context} failed: #{error.class}: #{error.message}")
  end
end
```

---

## Exercise 26: Mutable Default Parameters in Service Objects

### The Bad Code:
```ruby
class ReportGenerator
  def initialize(columns = ["id", "name", "created_at"], filters = {})
    @columns = columns
    @filters = filters
  end

  def add_column(column)
    @columns << column
  end

  def add_filter(key, value)
    @filters[key] = value
  end

  def generate
    scope = Project.all
    @filters.each do |key, value|
      scope = scope.where(key => value)
    end
    scope.select(@columns.join(", "))
  end
end

# Bug manifestation:
gen1 = ReportGenerator.new
gen1.add_column("budget")

gen2 = ReportGenerator.new  # Shares default array!
gen2.generate  # Selects "id, name, created_at, budget" — budget wasn't requested!
```

### Improved Version:
```ruby
class ReportGenerator
  DEFAULT_COLUMNS = ["id", "name", "created_at"].freeze

  def initialize(columns: nil, filters: nil)
    @columns = (columns || DEFAULT_COLUMNS).dup
    @filters = (filters || {}).dup
  end

  def add_column(column)
    @columns << column
    self
  end

  def add_filter(key, value)
    @filters[key] = value
    self
  end

  def generate
    scope = build_scope
    select_columns(scope)
  end

  private

  def build_scope
    scope = Project.all
    @filters.each do |key, value|
      scope = apply_filter(scope, key, value)
    end
    scope
  end

  def apply_filter(scope, key, value)
    case key
    when :status then scope.where(status: value)
    when :min_budget then scope.where("budget >= ?", value)
    when :organization then scope.where(organization: value)
    else scope.where(key => value)
    end
  end

  def select_columns(scope)
    valid_columns = @columns & Project.column_names
    scope.select(valid_columns.join(", "))
  end
end
```

---

## Exercise 27: Inefficient Bulk Operations

### The Bad Code:
```ruby
class BulkProjectUpdater
  def self.update_status(project_ids, new_status)
    project_ids.each do |id|
      project = Project.find(id)
      old_status = project.status
      project.update!(status: new_status)

      ActivityLog.create!(
        user: Current.user,
        action: "status_changed",
        details: { from: old_status, to: new_status, project_id: project.id }
      )

      project.members.each do |member|
        Notification.create!(
          user: member,
          message: "Project #{project.name} status changed to #{new_status}"
        )
      end
    end
  end
end

# Usage: BulkProjectUpdater.update_status([1, 2, 3, ... 1000], "completed")
# 1000 finds + 1000 updates + 1000 activity logs + 1000 * N notifications = 3000+ queries
```

### Improved Version:
```ruby
class BulkProjectUpdater
  BATCH_SIZE = 100

  def self.update_status(project_ids, new_status)
    new(project_ids, new_status).call
  end

  def call
    @project_ids.each_slice(BATCH_SIZE) do |batch_ids|
      process_batch(batch_ids)
    end

    enqueue_notifications
  end

  private

  def process_batch(batch_ids)
    old_values = fetch_current_statuses(batch_ids)

    ActiveRecord::Base.transaction do
      # Single UPDATE for the batch
      Project.where(id: batch_ids).update_all(
        status: @new_status,
        updated_at: Time.current
      )

      # Bulk insert activity logs
      insert_activity_logs(batch_ids, old_values)
    end

    # Queue notifications (don't do in transaction)
    queue_notifications(batch_ids)
  end

  def fetch_current_statuses(batch_ids)
    Project.where(id: batch_ids).pluck(:id, :status).to_h
  end

  def insert_activity_logs(batch_ids, old_values)
    logs = batch_ids.map do |id|
      {
        user_id: Current.user.id,
        action: "status_changed",
        details: { from: old_values[id], to: @new_status, project_id: id }.to_json,
        created_at: Time.current
      }
    end

    ActivityLog.insert_all!(logs)
  end

  def queue_notifications(batch_ids)
    # Single query to get all members, then bulk enqueue
    ProjectMembership.where(project_id: batch_ids)
                     .distinct
                     .pluck(:user_id, :project_id)
                     .each do |user_id, project_id|
      NotificationJob.perform_later(
        user_id: user_id,
        message_template: "project_status_changed",
        project_id: project_id,
        new_status: @new_status
      )
    end
  end
end
```

---

## Exercise 28: Tight Coupling to ActiveRecord in Domain Logic

### The Bad Code:
```ruby
class InvoicePaymentService
  def process_payment(invoice_id, amount, payment_method)
    Invoice.transaction do
      invoice = Invoice.lock.find(invoice_id)

      if invoice.status == "paid"
        raise "Invoice already paid"
      end

      if amount != invoice.amount
        raise "Payment amount does not match invoice"
      end

      payment = Payment.create!(
        invoice: invoice,
        amount: amount,
        method: payment_method,
        status: "processing"
      )

      result = Stripe::Charge.create(
        amount: (amount * 100).to_i,
        currency: "usd",
        source: payment_method
      )

      if result.status == "succeeded"
        payment.update!(
          status: "completed",
          transaction_id: result.id,
          completed_at: Time.current
        )
        invoice.update!(
          status: "paid",
          paid_at: Time.current,
          paid_amount: amount
        )
      else
        payment.update!(status: "failed", failure_reason: result.failure_message)
        raise "Payment failed: #{result.failure_message}"
      end
    end
  rescue Stripe::Error => e
    Rails.logger.error("Stripe error: #{e.message}")
    raise "Payment processing error"
  end
end
```

### What's Wrong:
- **Mixed concerns:** Payment processing, Stripe integration, invoice state all in one
- **No abstraction over payment gateway:** Direct Stripe calls
- **Raw exceptions as control flow:** Using raise for business logic errors
- **No idempotency:** Double-charge risk on retry
- **No audit trail:** Payment record created but no comprehensive logging
- **Lock held during external API call:** Blocks database during Stripe call

### Improved Version:
```ruby
class InvoicePaymentService
  Result = Struct.new(:success?, :payment, :error_code, :error_message, keyword_init: true)

  def initialize(gateway: PaymentGateway.for, audit_logger: AuditLogger)
    @gateway = gateway
    @audit_logger = audit_logger
  end

  def process_payment(invoice_id, amount, payment_method_id)
    invoice = Invoice.find(invoice_id)

    validation = validate(invoice, amount)
    return validation unless validation.success?

    payment = create_pending_payment(invoice, amount, payment_method_id)

    @audit_logger.log(action: "payment_initiated", payment_id: payment.id, invoice_id: invoice_id)

    gateway_result = @gateway.charge(
      amount: amount,
      payment_method_id: payment_method_id,
      idempotency_key: payment.idempotency_key,
      metadata: { invoice_id: invoice_id, payment_id: payment.id }
    )

    finalize_payment(payment, invoice, gateway_result)
  rescue PaymentGateway::Error => e
    @audit_logger.log(action: "payment_gateway_error", error: e.message)
    handle_gateway_error(payment, e)
  end

  private

  def validate(invoice, amount)
    return Result.new(success?: false, error_code: :already_paid) if invoice.paid?
    return Result.new(success?: false, error_code: :amount_mismatch) if amount != invoice.amount
    return Result.new(success?: false, error_code: :cancelled) if invoice.cancelled?
    Result.new(success?: true)
  end

  def create_pending_payment(invoice, amount, payment_method_id)
    Payment.create!(
      invoice: invoice,
      amount: amount,
      payment_method_id: payment_method_id,
      status: "processing",
      idempotency_key: SecureRandom.uuid,
      initiated_at: Time.current
    )
  end

  def finalize_payment(payment, invoice, gateway_result)
    ActiveRecord::Base.transaction do
      case gateway_result.status
      when :successful
        payment.complete!(transaction_id: gateway_result.transaction_id)
        invoice.mark_paid!(amount: payment.amount)
        Result.new(success?: true, payment: payment)
      when :declined
        payment.decline!(reason: gateway_result.error_message)
        Result.new(success?: false, error_code: :declined, error_message: gateway_result.error_message)
      else
        payment.fail!(reason: gateway_result.error_message)
        Result.new(success?: false, error_code: :failed, error_message: gateway_result.error_message)
      end
    end
  end

  def handle_gateway_error(payment, error)
    payment&.fail!(reason: error.message)
    Result.new(success?: false, error_code: :gateway_error, error_message: "Payment service unavailable")
  end
end
```

---

## Exercise 29: Inefficient Recursive Query

### The Bad Code:
```ruby
class Comment < ApplicationRecord
  belongs_to :project
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: "parent_id"

  def nested_replies
    replies.map do |reply|
      {
        comment: reply,
        children: reply.nested_replies
      }
    end
  end
end

# Controller
class CommentsController < ApplicationController
  def index
    @comments = Project.find(params[:project_id]).comments.where(parent_id: nil)
    @nested = @comments.map { |c| { comment: c, children: c.nested_replies } }
  end
end
```

### What's Wrong:
- **N+1 recursion:** Each level of nesting triggers new queries
- **Potential N^2 queries:** Deep thread trees generate enormous query counts
- **Memory bloat:** Entire tree loaded into memory

### Improved Version:
```ruby
class Comment < ApplicationRecord
  belongs_to :project
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: "parent_id"

  # Build tree in Ruby after single query
  def self.for_project_nested(project_id)
    comments = where(project_id: project_id).order(:created_at).to_a
    build_tree(comments)
  end

  def self.build_tree(comments)
    by_parent = comments.group_by(&:parent_id)

    build_node = lambda do |parent_id|
      (by_parent[parent_id] || []).map do |comment|
        {
          id: comment.id,
          body: comment.body,
          author: comment.author_name,
          created_at: comment.created_at,
          children: build_node.call(comment.id)
        }
      end
    end

    build_node.call(nil)  # Root comments have parent_id = nil
  end
end

# PostgreSQL recursive CTE alternative (for very deep trees)
class CommentTreeQuery
  def self.for_project(project_id)
    Comment.find_by_sql([<<~SQL, project_id])
      WITH RECURSIVE comment_tree AS (
        -- Anchor: root comments
        SELECT id, body, author_name, parent_id, created_at, 0 as depth,
               ARRAY[id] as path
        FROM comments
        WHERE project_id = ? AND parent_id IS NULL

        UNION ALL

        -- Recursive: child comments
        SELECT c.id, c.body, c.author_name, c.parent_id, c.created_at, ct.depth + 1,
               ct.path || c.id
        FROM comments c
        INNER JOIN comment_tree ct ON c.parent_id = ct.id
      )
      SELECT * FROM comment_tree ORDER BY path;
    SQL
  end
end
```

---

## Exercise 30: Poorly Designed Background Job with No Error Context

### The Bad Code:
```ruby
class SendNotificationJob
  include Sidekiq::Worker

  def perform(user_id, message)
    user = User.find(user_id)
    NotificationMailer.generic_email(user, message).deliver_now

    # Also send push
    PushService.send(user.device_token, message)

    # Also create in-app notification
    Notification.create!(user: user, message: message)
  rescue => e
    Rails.logger.error("Notification failed: #{e.message}")
  end
end
```

### What's Wrong:
- **Bare rescue:** Catches everything, silently swallows errors
- **No job context in logs:** Can't correlate error with specific notification
- **No retry differentiation:** Network errors should retry, invalid user should not
- **Synchronous delivery:** Email blocks push notification
- **No idempotency:** Retry creates duplicate notifications
- **No circuit breaker:** Push service down blocks all notifications

### Improved Version:
```ruby
class SendNotificationJob
  include Sidekiq::Worker
  sidekiq_options retry: 3, queue: :notifications

  def perform(user_id, message, notification_type = "generic", idempotency_key = nil)
    @user_id = user_id
    @message = message
    @notification_type = notification_type
    @idempotency_key = idempotency_key || "notification:#{user_id}:#{Digest::MD5.hexdigest(message)}"

    return if already_processed?

    user = User.find(user_id)

    # Parallel delivery (they're independent)
    deliver_email(user) if user.email_notifications_enabled?
    deliver_push(user) if user.push_notifications_enabled?
    deliver_in_app(user)

    mark_processed!
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn("Notification job: user #{user_id} not found, skipping")
    # Don't retry — user doesn't exist
  rescue NotificationDeliveryError => e
    Rails.logger.error("Notification delivery failed", 
                       user_id: user_id, error: e.message, channel: e.channel)
    raise  # Let Sidekiq retry
  end

  private

  def already_processed?
    Redis.current.exists?(@idempotency_key)
  end

  def mark_processed!
    Redis.current.setex(@idempotency_key, 86400, "delivered")
  end

  def deliver_email(user)
    mailer = mailer_for_type
    mailer.notification_email(user, @message).deliver_later
  rescue => e
    Rails.logger.error("Email delivery failed", user_id: @user_id, error: e.message)
  end

  def deliver_push(user)
    return unless user.device_token.present?

    PushService.send(user.device_token, @message)
  rescue PushService::Error => e
    Rails.logger.error("Push delivery failed", user_id: @user_id, error: e.message)
    # Don't raise — push failure shouldn't block other channels
  end

  def deliver_in_app(user)
    Notification.create!(
      user: user,
      message: @message,
      notification_type: @notification_type,
      delivered_at: Time.current
    )
  end

  def mailer_for_type
    {
      "invoice" => InvoiceMailer,
      "project" => ProjectMailer,
      "generic" => NotificationMailer
    }[@notification_type] || NotificationMailer
  end
end
```

---

---

# PART 3 — System Design Questions (80+)

---

## How to Approach System Design Interviews

### Framework:
1. **Requirements gathering** (2-3 min) — Clarify functional and non-functional requirements
2. **Capacity estimation** (2-3 min) — Back-of-envelope math
3. **High-level design** (5-10 min) — API, database, basic components
4. **Deep dive** (15-20 min) — Scale, reliability, tradeoffs
5. **Tradeoffs and evolution** (5 min) — What would change at 10x scale?

---

## Category 1: Core SaaS Infrastructure (Questions 1-10)

---

### Q1. Design a multi-tenant SaaS platform like Procore.

**Functional Requirements:**
- Organizations sign up and manage projects
- Role-based access control (admin, editor, viewer)
- Project data isolation between tenants
- Custom fields per tenant (optional)
- API for third-party integrations

**Non-Functional Requirements:**
- 99.9% uptime
- < 200ms p95 API latency
- Support 10,000+ organizations
- Data residency (EU data in EU, US in US)
- Compliance: SOC2, GDPR

**Scale Assumptions:**
- 10M users across 50K organizations
- 100M projects, 1B documents
- 10K API requests/second at peak
- 1TB data growth per day

**High-Level Design:**
```
[CDN] → [ALB] → [Rails API (K8s)] → [PostgreSQL (RDS Multi-AZ)]
              ↓                              ↓
         [Redis (ElastiCache)]      [S3 (Documents)]
              ↓
         [Sidekiq Workers]
              ↓
         [OpenSearch]
```

**Database Design:**
```sql
-- Shared database, tenant-isolated via org_id
tenants (id, name, subdomain, region, plan, created_at)
users (id, tenant_id, email, role, encrypted_password)
projects (id, tenant_id, name, status, budget, metadata_jsonb)
project_members (project_id, user_id, role)
documents (id, project_id, s3_key, filename, size_bytes, content_type)
```

**Key Tradeoffs:**
| Approach | Pros | Cons |
|----------|------|------|
| Shared DB + tenant_id | Simple, cost-efficient | Noisy neighbor risk |
| Schema per tenant | Better isolation | Complex migrations |
| DB per tenant | Full isolation | Expensive, complex ops |

**Common Mistakes:**
- Forgetting tenant scoping in queries (IDOR risk)
- Not handling data residency requirements
- Designing for single-tenant, scaling to multi-tenant later

**Follow-ups:**
- "How would you handle a tenant with 100x more data than average?"
- "How do you run migrations across all tenants?"
- "How do you prevent cross-tenant data leakage?"

---

### Q2. Design a real-time notification system.

**Functional Requirements:**
- In-app notifications, email, push, SMS
- User preference management (opt in/out per channel)
- Notification templates with variables
- Read/unread status tracking
- Batch digest notifications

**Scale:**
- 1M notifications/day
- 10K concurrent WebSocket connections
- < 5s delivery for real-time, 1 hour for digest

**Design:**
```
[Event Source] → [Event Bus (Kafka/SQS)] → [Notification Router]
                                                  ↓
                    ┌─────────────┬───────────────┼──────────────┐
                    ↓             ↓               ↓              ↓
               [WebSocket]  [Email Queue]   [Push Queue]   [SMS Queue]
                    ↓             ↓               ↓              ↓
               [ActionCable]  [SendGrid]    [FCM/APNs]     [Twilio]
```

**Key Decisions:**
- Use transactional outbox for reliable event publishing
- WebSocket via ActionCable or separate Node.js service
- Template rendering in background jobs
- Rate limiting per user per channel

---

### Q3. Design a document management system for construction (like Procore's core feature).

**Functional Requirements:**
- Upload/download files (PDFs, CAD drawings, images)
- Folder structure per project
- Version control for documents
- Permission-based access (view, download, edit)
- Full-text search within documents
- Annotation and commenting on documents
- Virus scanning on upload
- Preview generation (thumbnails, PDF pages)

**Scale:**
- 100M documents, average 5MB = 500TB storage
- 10K uploads/hour peak
- 100K downloads/hour peak

**Design:**
```
[Client] → [Presigned URL] → [S3 Upload]
                                ↓
                         [S3 Event → SQS]
                                ↓
                    ┌───────────┼───────────┐
                    ↓           ↓           ↓
              [Virus Scan] [Thumbnail] [Text Extraction]
                    ↓           ↓           ↓
              [Clean/Quarantine] [CDN]  [OpenSearch]
```

**Database:**
```sql
document_folders (id, project_id, parent_id, name, path)
documents (id, folder_id, name, s3_key, version, size, content_type, 
           checksum, virus_status, text_content, created_by)
document_versions (id, document_id, s3_key, version_number, created_by, comment)
document_permissions (document_id, user_id, permission_level)  -- view, edit, admin
document_annotations (id, document_id, page_number, x, y, content, author_id)
```

---

### Q4. Design an audit logging system that tracks every action in the platform.

**Functional Requirements:**
- Log all CRUD operations with actor, target, before/after values
- Tamper-proof storage
- Queryable by user, resource type, date range, organization
- Export to CSV/PDF for compliance
- Retention: 7 years hot, indefinite cold storage

**Scale:**
- 100M events/day
- 99.99% durability required
- Query response < 2s for 90-day window

**Design:**
```
[Rails App] → [Kafka/Outbox] → [Log Ingestion Service]
                                      ↓
                              ┌───────┴───────┐
                              ↓               ↓
                        [ClickHouse]      [S3 Parquet]
                        (90 days hot)    (7 years cold)
                              ↓
                        [Grafana/Metabase]
```

**Key Decisions:**
- Separate audit database (don't impact production queries)
- Immutable log — append only, no updates/deletes
- Use columnar storage (ClickHouse) for fast aggregations
- Schema: `timestamp, actor_id, actor_type, action, resource_type, resource_id, org_id, before_json, after_json, ip_address, user_agent`

---

### Q5. Design a permissions and authorization service.

**Functional Requirements:**
- Role-based access control (RBAC)
- Resource-level permissions (user can edit Project A but not Project B)
- Permission inheritance (folder permissions propagate to documents)
- Check permissions in < 10ms
- Audit trail of permission changes

**Scale:**
- 10M permission checks/second
- 100M resources, 50M users
- Permission changes: 1K/minute

**Design:**
```
[API Request] → [Policy Engine] → [Permission Cache (Redis)]
       ↓                                ↓
  [Pundit/Policy]              [Cached?]──Yes──→ [Allow/Deny]
       ↓                            No
  [Database]                        ↓
                            [Compute + Cache]
```

**Permission model:**
```sql
roles (id, name, tenant_id, permissions_json)  -- ["project:read", "project:write"]
role_assignments (user_id, role_id, scope_type, scope_id)  -- scope = project or org
resource_permissions (resource_type, resource_id, user_id, permission)
```

**Optimization:**
- Cache user's effective permissions in Redis (TTL: 5 minutes)
- On permission change: invalidate cache, warm if needed
- Use bitmaps for role permissions (compact, fast bitwise ops)

---

### Q6. Design an API rate limiting service.

**Functional Requirements:**
- Per-user, per-organization, per-endpoint rate limits
- Configurable tiers (free: 100/min, pro: 10K/min, enterprise: custom)
- Burst handling with token bucket
- Rate limit headers in responses
- Sliding window for accuracy

**Scale:**
- 100K requests/second
- Rate check < 1ms
- 1M active rate limit keys

**Design:**
```
[API Request] → [Rate Limit Middleware] → [Redis Cluster]
                      ↓
              [Allow/Deny + Headers]
```

**Redis implementation:**
```lua
-- Sliding window log
ZREMRANGEBYSCORE key 0 (now - window)
ZCARD key
ZADD key now member
EXPIRE key window
```

---

### Q7. Design a search system for projects, documents, and users.

**Functional Requirements:**
- Full-text search across projects, documents, users
- Faceted filtering (status, date, organization, type)
- Autocomplete/suggestions
- Fuzzy matching for typos
- Relevance ranking

**Scale:**
- 100M searchable documents
- 10K searches/second
- < 100ms p95 response time

**Design:**
```
[Rails App] → [OpenSearch/Elasticsearch Cluster]
                  ↓
            [Index per entity type]
                  ↓
            [Query → Aggregate → Rank]
```

**Index design:**
```json
{
  "projects": {
    "name": "Office Building Renovation",
    "description": "Complete renovation of 12-story office...",
    "status": "active",
    "organization_id": 123,
    "budget": 5000000,
    "members": ["Alice", "Bob"],
    "created_at": "2024-01-01"
  }
}
```

**Sync strategy:**
- Change Data Capture (CDC) from PostgreSQL → Kafka → OpenSearch
- 1-2 second eventual consistency

---

### Q8. Design a data export and reporting system.

**Functional Requirements:**
- Export projects, invoices, users to CSV/Excel/PDF
- Scheduled reports (daily, weekly, monthly)
- Custom report builder (select fields, filters, group by)
- Large export support (millions of rows)
- Email delivery of reports

**Scale:**
- 10K exports/day
- Largest export: 10M rows
- Must not impact production database

**Design:**
```
[Export Request] → [Queue (SQS)] → [Export Worker]
                                        ↓
                                [Read Replica]
                                        ↓
                                [Stream to S3 CSV]
                                        ↓
                                [Notify via Email]
```

**Key:**
- Use read replica for SELECT queries
- Stream results (don't load all into memory)
- Background job with progress tracking
- Cleanup old exports after 7 days

---

### Q9. Design a webhook delivery system.

**Functional Requirements:**
- Users register webhook URLs for events
- At-least-once delivery guarantee
- Retry with exponential backoff
- Signature verification (HMAC)
- Delivery status dashboard

**Scale:**
- 1M webhook deliveries/day
- 50K registered endpoints
- < 30s latency from event to delivery

**Design:**
```
[Event] → [Webhook Queue (SQS)] → [Delivery Worker]
                                          ↓
                              [HTTP POST to endpoint]
                                          ↓
                              [Success?] → Log and done
                              [Failure?] → Retry Queue (exponential backoff)
                                                  ↓
                                          [Dead Letter Queue after 24h]
```

---

### Q10. Design a feature flag system for gradual rollouts.

**Functional Requirements:**
- Boolean, percentage, user-targeted flags
- A/B testing support
- Real-time flag updates (no deploy needed)
- Audit log of flag changes
- SDK for Rails/JS/iOS/Android

**Scale:**
- 1K flags
- 100K flag evaluations/second
- < 5ms evaluation time
- Flag update propagation < 30 seconds

**Design:**
```
[Flag Admin UI] → [PostgreSQL] → [Cache Warmer]
                                      ↓
                              [Redis (hot flags)]
                                      ↓
                    ┌─────────────────┼─────────────────┐
                    ↓                 ↓                 ↓
              [Rails SDK]      [JS SDK]         [Mobile SDK]
```

**SDK evaluation:**
```ruby
# Local cache + fallback to Redis
Features.enabled?(:new_dashboard, user: current_user)
# 1. Check in-process cache (refreshed every 30s)
# 2. Fallback to Redis
# 3. Default to false if unavailable
```

---

## Category 2: Construction-Specific Systems (Questions 11-20)

---

### Q11. Design a construction project scheduling system (Gantt chart backend).

**Requirements:**
- Tasks with start/end dates, dependencies, milestones
- Critical path calculation
- Resource allocation (crew, equipment)
- Delay propagation through dependency chain
- Baseline vs actual schedule comparison

**Design:**
```sql
tasks (id, project_id, name, start_date, end_date, duration_days, 
       percent_complete, baseline_start, baseline_end, wbs_code)
task_dependencies (task_id, predecessor_id, dependency_type)  -- FS, SS, FF, SF
resources (id, name, type, cost_per_day, max_units)
task_assignments (task_id, resource_id, units)
```

**Critical path algorithm:**
- Forward pass: Calculate early start/finish
- Backward pass: Calculate late start/finish
- Float = Late start - Early start
- Critical path = tasks with zero float

**Scale challenge:** Large projects (10K+ tasks) require efficient graph algorithms. Use topological sort, cache critical path on change.

---

### Q12. Design a construction bidding/RFP system.

**Requirements:**
- Create RFPs with line items (quantities, specifications)
- Contractors submit bids
- Bid comparison and analysis
- Award/negotiation workflow
- Audit trail for compliance

---

### Q13. Design a change order management system.

**Requirements:**
- Create change requests with cost/time impact
- Approval workflow (owner, architect, contractor)
- Version control of changes
- Budget impact tracking
- Integration with project schedule

---

### Q14. Design a daily log/field report system.

**Requirements:**
- Daily reports from job site (weather, crew, activities, issues)
- Photo attachments
- Digital signatures
- Offline support with sync
- Template customization per project

---

### Q15. Design a safety incident tracking system.

**Requirements:**
- Report incidents with severity, type, location
- Investigation workflow
- OSHA compliance reporting
- Trend analysis and dashboards
- Corrective action tracking

---

### Q16. Design a blueprint/drawing management system with version control.

**Requirements:**
- Upload CAD drawings (DWG, PDF)
- Version history with annotations
- Overlay/compare versions
- Hotspot annotations
- Permission-based access

---

### Q17. Design a materials and inventory tracking system.

**Requirements:**
- Track materials ordered, delivered, installed
- Integration with PO system
- On-site inventory management
- Waste tracking
- Cost tracking against budget

---

### Q18. Design a subcontractor management and compliance system.

**Requirements:**
- Subcontractor directory with ratings
- Insurance certificate tracking (expiration alerts)
- Compliance document management
- Payment tracking and lien waivers
- Performance history

---

### Q19. Design a punch list/deficiency tracking system.

**Requirements:**
- Create punch list items with photos, location
- Assign to responsible party
- Status tracking (open, in progress, resolved)
- Walk-through support (mobile)
- Final sign-off workflow

---

### Q20. Design a cost estimation and budget tracking system.

**Requirements:**
- Create estimates with line items
- Track actual costs vs estimated
- Forecast final cost (EAC - Estimate at Completion)
- Variance analysis
- Integration with accounting systems

---

## Category 3: Distributed Systems & Messaging (Questions 21-35)

---

### Q21. Design a distributed event bus for microservices.

### Q22. Design an idempotency service for API endpoints.

### Q23. Design a distributed cron/job scheduler.

### Q24. Design a configuration management service.

### Q25. Design a service discovery and health check system.

### Q26. Design a distributed caching layer with consistency guarantees.

### Q27. Design a circuit breaker service for external API calls.

### Q28. Design a dead letter queue management system.

### Q29. Design an outbox pattern implementation for reliable messaging.

### Q30. Design a CQRS (Command Query Responsibility Segregation) system.

### Q31. Design an event sourcing system for financial transactions.

### Q32. Design a saga orchestration service for long-running transactions.

### Q33. Design a consistent hashing load balancer.

### Q34. Design a leader election service for distributed tasks.

### Q35. Design a distributed rate limiter (token bucket across nodes).

---

## Category 4: Data & Storage (Questions 36-50)

---

### Q36. Design a time-series data store for construction IoT sensors.

### Q37. Design a data warehouse for construction analytics.

### Q38. Design a data pipeline for ETL from operational DB to analytics.

### Q39. Design a file storage system supporting TB-scale CAD files.

### Q40. Design a database sharding strategy for multi-tenant SaaS.

### Q41. Design a backup and disaster recovery system.

### Q42. Design a data retention and archival system (hot/warm/cold).

### Q43. Design a real-time analytics dashboard backend.

### Q44. Design a geospatial data service for construction sites.

### Q45. Design a full-text search system for construction documents.

### Q46. Design a data migration system for zero-downtime upgrades.

### Q47. Design a change data capture (CDC) pipeline.

### Q48. Design a materialized view refresh system.

### Q49. Design a graph database for construction supply chain.

### Q50. Design a blob storage system with deduplication.

---

## Category 5: Reliability & Observability (Questions 51-65)

---

### Q51. Design an OpenTelemetry collection and processing pipeline.

### Q52. Design a distributed tracing storage system.

### Q53. Design a metrics aggregation and alerting system.

### Q54. Design a centralized logging platform.

### Q55. Design a chaos engineering framework.

### Q56. Design an on-call rotation and incident management system.

### Q57. Design a health check and dependency validation service.

### Q58. Design a synthetic monitoring / canary analysis system.

### Q59. Design a performance profiling and optimization platform.

### Q60. Design a database query performance analyzer.

### Q61. Design a cache warming and invalidation service.

### Q62. Design a blue-green deployment orchestration system.

### Q63. Design a database migration safety checker.

### Q64. Design a capacity planning and forecasting system.

### Q65. Design a runbook automation system.

---

## Category 6: Security & Compliance (Questions 66-75)

---

### Q66. Design an authentication service supporting multiple methods.

### Q67. Design an SSO (Single Sign-On) integration system.

### Q68. Design a secrets management service.

### Q69. Design a data encryption system for sensitive fields.

### Q70. Design an audit trail and compliance reporting system.

### Q71. Design a bot detection and prevention system.

### Q72. Design a network security architecture for multi-tenant SaaS.

### Q73. Design a vulnerability scanning and remediation system.

### Q74. Design a data anonymization service for GDPR.

### Q75. Design a certificate management and rotation system.

---

## Category 7: Integration & APIs (Questions 76-82)

---

### Q76. Design an API gateway for a microservices architecture.

### Q77. Design a third-party integration marketplace.

### Q78. Design a webhook management and delivery system.

### Q79. Design an API versioning and deprecation system.

### Q80. Design a GraphQL API for complex construction data queries.

### Q81. Design an API schema evolution and backward compatibility system.

### Q82. Design a real-time collaboration system (like Google Docs for blueprints).

---

## Detailed Breakdown: Q21 (Event Bus) — Example of Full Answer Format

---

### Q21. Design a distributed event bus for microservices.

**Requirements Gathering:**
- "What volume of events?" — 1M events/sec at peak
- "Ordering guarantees?" — Ordering within entity (project events ordered), not global
- "Delivery semantics?" — At-least-once
- "Consumer types?" — Push (webhook), Pull (poll), Stream (real-time)

**Capacity Estimation:**
- 1M events/sec × 1KB avg = 1GB/sec throughput
- Retain 7 days = 604TB storage
- 100 consumer groups

**High-Level Design:**
```
[Producer] → [API Gateway] → [Kafka Cluster]
                                   ↓
                    ┌──────────────┼──────────────┐
                    ↓              ↓              ↓
              [Consumer 1]  [Consumer 2]  [Consumer 3]
              (Analytics)   (Email)       (Search Index)
```

**Kafka Configuration:**
- 3 brokers, replication factor 3
- Topic per event type: `project.created`, `invoice.paid`, `user.joined`
- Partition by entity ID (project-123 always goes to same partition)
- Consumer groups for independent processing

**Deep Dive:**
- **Schema registry:** Avro schemas with evolution rules
- **Dead letter topic:** Failed events after 3 retries
- **Monitoring:** Consumer lag alerts, throughput dashboards
- **Backpressure:** Pause consumption if consumer is slow

**Tradeoffs:**
- Kafka vs RabbitMQ: Kafka for high throughput, RabbitMQ for complex routing
- Partition strategy: Entity ID for ordering, round-robin for load balancing
- Retention: Time-based vs size-based

**Common Mistakes:**
- Not handling schema evolution (breaks consumers)
- No dead letter handling (blocks consumer)
- Assuming global ordering (Kafka has per-partition ordering only)

**Scaling:**
- Add brokers → reassign partitions
- Add consumer instances (must be ≤ partitions for parallelism)

---

## Detailed Breakdown: Q51 (OpenTelemetry Pipeline)

---

### Q51. Design an OpenTelemetry collection and processing pipeline.

**Requirements:**
- Collect traces, metrics, logs from 500 microservices
- 10M spans/second at peak
- 99.99% collection availability
- < 5 minute trace visibility latency
- Retention: 15 days hot, 1 year cold

**Architecture:**
```
[Apps] → [OTel Collector (DaemonSet)] → [OTel Gateway] → [Kafka]
                                                              ↓
                                                    [Processing Pipeline]
                                                              ↓
                                                    [ClickHouse (traces)]
                                                    [VictoriaMetrics (metrics)]
                                                    [S3 (long-term)]
                                                              ↓
                                                        [Grafana]
```

**OTel Collector Configuration:**
```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
    timeout: 1s
    send_batch_size: 1024
  resource:
    attributes:
      - key: cluster
        value: production-us-east
        action: upsert

exporters:
  kafka:
    brokers: kafka-1:9092,kafka-2:9092
    topic: otel-spans
    encoding: otlp_proto

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch, resource]
      exporters: [kafka]
```

**Key Decisions:**
- DaemonSet collectors on each node (local collection, no network hop)
- Gateway collectors for aggregation, tail-based sampling
- Kafka as buffer (absorbs spikes, decouples pipeline)
- ClickHouse for traces (columnar, fast aggregations)

**Sampling:**
- Head-based: 10% default, 100% for errors, 100% for payment flows
- Tail-based: Collect full trace if any span has error or latency > 1s

**Scaling:**
- Collector: HPA based on CPU
- Kafka: Add partitions
- ClickHouse: Add shards

---

## Detailed Breakdown: Q36 (Time-Series IoT)

---

### Q36. Design a time-series data store for construction IoT sensors.

**Requirements:**
- Sensors: Temperature, humidity, vibration, GPS (equipment tracking)
- 100K sensors, 1 reading/minute = 1.6B readings/day
- Query: Last 24h for sensor, aggregates by site
- Retention: 1 year hot, 5 years cold

**Architecture:**
```
[IoT Sensors] → [MQTT Broker] → [Telegraf/Collector] → [TimescaleDB/InfluxDB]
                                                                ↓
                                                        [Grafana Dashboards]
                                                        [Alert Manager]
                                                        [S3 Cold Storage]
```

**Database Schema (TimescaleDB):**
```sql
CREATE TABLE sensor_readings (
    time TIMESTAMPTZ NOT NULL,
    sensor_id TEXT NOT NULL,
    site_id TEXT NOT NULL,
    metric_name TEXT NOT NULL,
    value DOUBLE PRECISION,
    metadata JSONB
);

SELECT create_hypertable('sensor_readings', 'time', chunk_time_interval => INTERVAL '1 day');

-- Compression after 7 days
ALTER TABLE sensor_readings SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'sensor_id, metric_name'
);

-- Continuous aggregates (hourly summaries)
CREATE MATERIALIZED VIEW hourly_avg
WITH (timescaledb.continuous) AS
SELECT 
    time_bucket('1 hour', time) as bucket,
    sensor_id, metric_name,
    AVG(value) as avg_value,
    MAX(value) as max_value,
    MIN(value) as min_value
FROM sensor_readings
GROUP BY bucket, sensor_id, metric_name;
```

**Key Decisions:**
- TimescaleDB (PostgreSQL extension) over InfluxDB: Same operational model as main DB
- Chunk by day: Good balance of insert/query performance
- Compression: 90%+ space reduction
- Continuous aggregates: Pre-computed for fast dashboard queries

---

---

# PART 4 — Staff-Level Behavioral Questions

---

> **Framework for answering:** Use **STAR** (Situation, Task, Action, Result) or **CARL** (Context, Actions, Result, Learnings). For Staff-level interviews, emphasize scope, influence, ambiguity, and cross-organizational impact.

---

## Section A: Leadership & Influence (15 Questions)

---

### Q1. Tell me about a time you influenced a technical decision without having direct authority.

**Model Answer:**

**Context:** At my previous company, the platform team wanted to migrate from PostgreSQL to MongoDB for a new microservice. I believed this was the wrong choice given our team's expertise and the relational nature of the data.

**Actions:**
1. I didn't just say "no" — I built a decision document with evaluation criteria: team expertise, data relationships, operational overhead, migration cost
2. I prototyped both approaches with realistic data schemas and query patterns
3. I scheduled a technical review with both teams, presenting data not opinions: "MongoDB requires 3 new engineers with that expertise; we have 20 PostgreSQL experts"
4. I proposed a compromise: Use PostgreSQL with JSONB columns for flexible schema parts
5. I got buy-in from the engineering director by framing it as risk mitigation, not technology preference

**Result:** We stayed with PostgreSQL. The service launched 2 months earlier than projected with MongoDB. The JSONB compromise gave us flexibility without operational complexity. The decision document became our standard for technology evaluations.

**Learnings:** Influence comes from data and shared goals, not from seniority. Build a compelling case, then find the right forum to present it.

---

### Q2. Describe a situation where you had to convince a team to invest in technical debt repayment.

**Model Answer:**

**Context:** Our Rails monolith had a 2000-line User model. Test suite took 45 minutes. New features were taking 2-3x longer than estimated because of unexpected breakages.

**Actions:**
1. I measured and visualized the cost: "Feature X took 6 days; 4 were spent understanding User model interactions"
2. I created a debt taxonomy: critical (security risk), high (velocity impact), medium (maintenance burden)
3. I proposed 20% time allocation for refactoring with a 6-month roadmap
4. I found a quick win: Extracting billing code reduced User model by 400 lines in 1 week
5. I demonstrated the win: test time reduced by 8 minutes, 2 bug fixes became straightforward

**Result:** Engineering leadership approved the 20% allocation. Over 6 months, we reduced User model to 400 lines. Feature velocity increased 40%. The quick win built trust for larger investments.

**Learnings:** Lead with business impact, not technical purity. Demonstrate value quickly with a prototype or quick win.

---

### Q3. Tell me about a time you made an unpopular technical decision that turned out to be correct.

**Model Answer:**

**Context:** We were choosing between Sidekiq (Redis-based) and DelayedJob (PostgreSQL-based) for background jobs. The team favored DelayedJob because "we already have PostgreSQL."

**Actions:**
1. I built a performance comparison with realistic workloads
2. I highlighted operational concerns: PostgreSQL would need connection pool increases, job table would grow unbounded
3. I addressed the "another service" concern: proposed AWS ElastiCache (managed Redis)
4. I committed to owning the operational burden if it didn't work out
5. I proposed a 2-week trial on staging with clear success criteria

**Result:** Sidekiq performed 5x better on our workload. We adopted it. Two years later, we process 10M jobs/day without issues. The decision document is still referenced.

**Learnings:** When making unpopular decisions, commit to measurable criteria and take ownership of the outcome.

---

### Q4. How do you handle a situation where a junior engineer proposes a solution that won't work?

**Model Answer:**

I guide them to discover why through questions, not by telling them. "That's an interesting approach. What would happen if two users did this simultaneously?" or "How would this handle a million records?" This builds their critical thinking. If time is short, I'll be direct but explain the reasoning: "This won't work at scale because of X, but the intuition about caching is right. Let's explore that direction instead."

---

### Q5. Describe a time you had to lead without being the designated lead.

**Model Answer:**

**Context:** Our team lead was on medical leave during a critical migration. We had a 2-week window to migrate data centers.

**Actions:**
1. I stepped up to coordinate without being asked
2. Created a runbook with hour-by-hour steps, rollback procedures, and decision trees
3. Formed a war room (Slack channel) with clear roles: me coordinating, 3 engineers executing, 1 monitoring
4. Communicated upward: hourly status to VP, immediate escalation for blockers
5. Made the go/no-go decision at each checkpoint based on metrics, not hope

**Result:** Migration completed 6 hours ahead of schedule. Zero customer impact. I was formally promoted to Senior Engineer afterward, and the runbook became the template for future migrations.

---

### Q6. Tell me about a time you identified a systemic issue and drove the fix across multiple teams.

### Q7. How do you handle competing priorities from different stakeholders?

### Q8. Describe how you've mentored someone who went on to exceed your own skills in an area.

### Q9. Tell me about a time you had to say "no" to a feature request from leadership.

### Q10. How do you build trust with teams you don't directly manage?

### Q11. Describe a time you changed the engineering culture of a team or organization.

### Q12. How do you handle being the most experienced engineer on a team?

### Q13. Tell me about a time you had to balance short-term delivery with long-term architecture.

### Q14. Describe how you approach code reviews for senior vs. junior engineers.

### Q15. How do you stay technical while taking on more leadership responsibility?

---

## Section B: Conflict Resolution (10 Questions)

---

### Q16. Tell me about a time you had a significant disagreement with another engineer.

**Model Answer:**

**Context:** A staff engineer wanted to rewrite our authentication system in Go, arguing Ruby was too slow. I believed the rewrite would take 6 months with high risk.

**Actions:**
1. I acknowledged their concern: "Authentication latency matters, I agree"
2. I proposed we measure first: added OpenTelemetry to our auth endpoints
3. Data showed auth took 15ms total; only 3ms was Ruby code, rest was DB and network
4. I proposed a targeted optimization: add connection pooling and caching, estimated 2 weeks
5. We A/B tested both approaches on staging

**Result:** Optimization reduced auth latency to 8ms. Rewrite would have saved 1ms at most. The other engineer agreed the data supported optimization over rewrite. We co-authored a post about the findings.

**Learnings:** Disagreements are resolved with data, not seniority. Always measure before rewriting.

---

### Q17. Describe a time you had to work with someone you didn't get along with.

### Q18. How do you handle feedback you disagree with?

### Q19. Tell me about a time you mediated a conflict between two team members.

### Q20. Describe a time you had to push back on unrealistic deadlines.

### Q21. How do you handle a peer who consistently produces low-quality work?

### Q22. Tell me about a time you had to deliver bad news to your team or manager.

### Q23. How do you handle a situation where someone takes credit for your work?

### Q24. Describe a time you had to override a decision made by your manager.

### Q25. How do you deal with someone who has strong opinions but weak technical skills?

---

## Section C: Production & Reliability (10 Questions)

---

### Q26. Tell me about your most challenging production incident.

**Model Answer:**

**Context:** At 2 AM, our payment processing pipeline stopped. 500 orders stuck in "processing" status. PagerDuty alerted the on-call engineer (me).

**Actions:**
1. **Triage (2:05 AM):** Confirmed scope: payment queue depth spiking, all jobs failing with timeout. SEV-1 declared.
2. **Mitigation (2:15 AM):** Identified root cause — database connection pool exhausted. Immediate fix: scaled Sidekiq workers down to free connections, then increased PgBouncer pool size.
3. **Communication:** Updated status page, notified customer success team, created incident channel.
4. **Resolution (3:30 AM):** Queue processing resumed. Monitored for 1 hour to confirm stability.
5. **Recovery (next day):** Reprocessed 500 stuck orders. Verified no double-charges.

**Post-Incident:**
- Root cause: Previous deploy increased Sidekiq concurrency without increasing connection pool
- Fix: Made pool size auto-calculate based on concurrency settings
- Added alert for connection pool utilization > 80%

**Result:** Incident resolved in 90 minutes. No financial impact due to idempotent payment processing. Prevention measures eliminated this class of failure.

**Learnings:** The proximate cause was a config mismatch. The systemic cause was lack of validation between related configs. We now validate config consistency in CI.

---

### Q27. How do you approach on-call rotations and incident response?

### Q28. Tell me about a time you prevented a major incident before it happened.

### Q29. Describe how you design systems to be debuggable at 3 AM.

### Q30. How do you handle a cascading failure?

### Q31. Tell me about a time you had to make a quick decision with incomplete information during an incident.

### Q32. How do you balance blameless postmortems with accountability?

### Q33. Describe your approach to testing in production (feature flags, canaries).

### Q34. How do you handle data corruption in production?

### Q35. Tell me about a time a system you designed failed unexpectedly.

---

## Section D: Architecture & Technical Strategy (15 Questions)

---

### Q36. Describe a major architectural decision you made and how you evaluated it.

**Model Answer:**

**Context:** Our monolith was struggling — 30-minute deploys, frequent conflicts, slow test suite. We needed to restructure.

**Decision:** Modular monolith (Rails engines) instead of microservices.

**Evaluation:**
| Criteria | Microservices | Modular Monolith |
|----------|--------------|------------------|
| Deploy time | Fast per service | Faster than monolith |
| Team autonomy | High | Medium (shared deploy) |
| Operational complexity | High (10+ services) | Low (1 deploy unit) |
| Cross-module transactions | Distributed (hard) | Same DB (easy) |
| Migration effort | 12+ months | 4-6 months |
| Team expertise | K8s, networking required | Rails knowledge sufficient |

**Decision:** Modular monolith. We could extract to microservices later if needed, but not vice versa.

**Result:** Deploy time went from 30 to 8 minutes. Team autonomy improved with engine boundaries. After 2 years, we extracted 2 engines to actual microservices where the boundary was clear.

**Learnings:** Don't microservice prematurely. Boundaries matter more than deployment units.

---

### Q37. Tell me about a time you chose simplicity over a more elegant solution.

### Q38. How do you approach technology selection for a new project?

### Q39. Describe a time you had to migrate a large amount of data or users.

### Q40. How do you decide between building vs buying?

### Q41. Tell me about a system you designed for 10x growth.

### Q42. How do you approach API design for internal vs external consumers?

### Q43. Describe how you would decompose a monolith into services.

### Q44. How do you handle technical disagreements at the architect/VP level?

### Q45. Tell me about a time you sunset or deprecated a system.

### Q46. How do you stay current with technology trends?

### Q47. Describe your approach to documentation for complex systems.

### Q48. How do you evaluate and adopt open-source software?

### Q49. Tell me about a time you had to reverse a technical decision.

### Q50. How do you think about total cost of ownership for technical choices?

---

## Section E: Procore-Specific & Values-Based (10 Questions)

---

### Q51. Why Procore? What interests you about construction technology?

**Model Answer Framework:**
- Construction is a massive, underserved industry ($12T globally)
- Technology adoption is low — huge opportunity for impact
- Procore's platform approach (connecting all stakeholders) is the right model
- The technical challenges at scale (millions of users, complex workflows) are interesting
- Values alignment: Openness, Ownership, Optimism

---

### Q52. How would you approach improving reliability for a platform serving millions of construction professionals?

### Q53. Tell me about a time you worked on a product with complex, regulated workflows.

### Q54. How would you balance the needs of different construction stakeholders (owners, GCs, subs)?

### Q55. Describe how you would approach building features for an industry that's not traditionally tech-savvy.

### Q56. How do you think about data ownership and privacy in a multi-stakeholder platform?

### Q57. Tell me about a time you had to simplify a complex process for end users.

### Q58. How would you approach international expansion from a technical perspective?

### Q59. Describe how you think about mobile-first design for construction workers in the field.

### Q60. How do you balance innovation with stability in a mission-critical platform?

---

## Section F: Growth & Self-Awareness (10 Questions)

---

### Q61. What's the most significant technical mistake you've made? What did you learn?

**Model Answer:**

Early in my career, I optimized a reporting query by adding a covering index. It made that query 100x faster. But I didn't consider that the index added 5 seconds to every INSERT on that table. Write volume was 1000x read volume, so overall system performance degraded.

I learned: always measure holistic impact, not just the targeted optimization. Now I always test write performance when adding indexes, and I monitor production metrics for 48 hours after any database change.

---

### Q62. How do you handle situations where you don't know the answer?

### Q63. Tell me about a time you received difficult feedback. How did you respond?

### Q64. What are you currently working on improving about yourself?

### Q65. How do you decide when to dive deep vs. delegate?

### Q66. Describe your ideal team and work environment.

### Q67. What's your approach to work-life balance, especially during critical periods?

### Q68. Tell me about a time you failed to meet a commitment.

### Q69. How do you handle imposter syndrome or self-doubt?

### Q70. What do you want to learn in the next 2-3 years?

---

## Section G: Behavioral Quick-Fire (10 Short Questions)

---

### Q71. How do you start your day as a staff engineer?
**Answer:** Review metrics dashboard, check on-call alerts, prioritize deep work blocks, review critical PRs.

### Q72. What's your approach to 1:1s with your manager?
**Answer:** I drive the agenda: blockers, career growth, cross-team issues, strategic questions. I come prepared with specific topics.

### Q73. How do you handle context-switching between deep technical work and meetings?
**Answer:** Block calendar for deep work (mornings), batch meetings (afternoons), protect focus time aggressively.

### Q74. What's your approach to giving feedback to peers?
**Answer:** Situation-behavior-impact framework. Specific, timely, actionable. In private for constructive, in public for praise.

### Q75. How do you handle a situation where you're asked to do something unethical?
**Answer:** Push back immediately and escalate. No feature or deadline justifies ethical compromises.

### Q76. What's your approach to learning a new codebase quickly?
**Answer:** Start with user flows, trace through the code, draw architecture diagrams, ask "why" a lot, find a buddy to pair with.

### Q77. How do you prioritize when everything is urgent?
**Answer:** Ask: What's the user impact? What's reversible? What's the blast radius? Urgent != Important. Focus on user-impacting, irreversible decisions first.

### Q78. What's your approach to writing design documents?
**Answer:** Problem statement first, then constraints, options with tradeoffs, recommendation with risks, rollback plan. One page if possible, five pages max.

### Q79. How do you handle working on a legacy system with poor test coverage?
**Answer:** Characterization tests first (document current behavior), then refactor with tests, then improve. Never refactor without tests.

### Q80. What do you do when you're stuck on a technical problem?
**Answer:** Timebox solo exploration (30 min), then ask for help. Explain what I've tried. Pair with someone. Sleep on it if possible.

---

## Key Tips for Procore Behavioral Interviews

### Procore Values (Openness, Ownership, Optimism):
- **Openness:** Share examples of transparent communication, giving/receiving feedback, open-source contributions
- **Ownership:** Show examples of taking responsibility beyond your role, fixing problems before being asked
- **Optimism:** Demonstrate resilience in difficult situations, finding solutions not just identifying problems

### What Interviewers Look For at Staff Level:
1. **Scope:** Did you influence beyond your immediate team?
2. **Ambiguity:** Can you operate with incomplete information?
3. **Systems thinking:** Do you consider second and third-order effects?
4. **Mentorship:** Are you growing others?
5. **Technical judgment:** Do you make sound tradeoffs?

### Red Flags to Avoid:
- Blaming others for failures
- Making decisions without data
- Being overly attached to specific technologies
- Showing discomfort with ambiguity
- Lacking examples of cross-team collaboration

---

---

# APPENDIX — Quick Reference Cards

---

## Ruby/Rails Quick Reference

| Topic | Key Point |
|-------|-----------|
| GVL | One Ruby thread runs at a time; use processes for CPU parallelism |
| GC | Generational mark-and-sweep; use jemalloc, compact periodically |
| ActiveRecord | Lazy Relations; use `includes` to prevent N+1 |
| Migrations | Use `strong_migrations`; always add indexes concurrently |
| Sidekiq | Idempotent jobs; separate queues; monitor DLQ |
| Caching | Key-based invalidation; Russian doll for nested views |
| Testing | Pyramid: many unit, fewer integration, few E2E |

## PostgreSQL Quick Reference

| Operation | Best Practice |
|-----------|--------------|
| Add index | `algorithm: :concurrently` |
| Add column | Nullable first, backfill, then add constraint |
| Query slow | `EXPLAIN (ANALYZE, BUFFERS)`, check for seq scans |
| Lock row | `SELECT ... FOR UPDATE` in transaction |
| Partition | By time (range) or tenant (list) |
| JSONB | Use GIN index for `@>` containment queries |

## Kubernetes Quick Reference

| Resource | Purpose |
|----------|---------|
| Deployment | Manages pod replicas |
| Service | Load balances across pods |
| Ingress | HTTP routing, TLS termination |
| HPA | Auto-scales pods |
| PDB | Ensures minimum availability during disruptions |
| ConfigMap | Non-sensitive configuration |
| Secret | Sensitive data (base64, not encrypted) |

## OpenTelemetry Quick Reference

| Component | Purpose |
|-----------|---------|
| Trace | End-to-end request flow |
| Span | Single operation within a trace |
| Metric | Aggregated numeric data |
| Log | Discrete event record |
| Collector | Receives, processes, exports telemetry |
| OTLP | OpenTelemetry Protocol for data transport |

---

# Final Preparation Checklist

## Before the Interview:
- [ ] Review Part 1: Can you explain GVL, connection pooling, and Zeitwerk confidently?
- [ ] Review Part 2: Can you identify code smells and propose refactorings quickly?
- [ ] Review Part 3: Can you whiteboard system design with capacity estimation?
- [ ] Review Part 4: Do you have 5-7 strong STAR stories prepared?
- [ ] Research Procore's latest engineering blog posts
- [ ] Prepare 3-5 questions to ask your interviewers

## Day Of:
- [ ] Bring a notebook for diagramming
- [ ] For virtual: Test your camera, microphone, and screen sharing
- [ ] Have water nearby
- [ ] Arrive 10 minutes early (physically or virtually)

## Questions to Ask Interviewers:
1. "What's the most challenging technical problem the team is facing right now?"
2. "How does the team balance feature delivery with technical debt?"
3. "What's your on-call rotation like? How often do pages happen?"
4. "How do engineers typically grow from Senior to Staff at Procore?"
5. "What's the most recent major architectural decision the team made?"

---

*Good luck with your interviews! Remember: the goal is to demonstrate how you think, not just what you know. Show your work, explain tradeoffs, and be collaborative.*

*Document prepared based on real Procore interview experiences, industry best practices, and Staff Engineer interview patterns.*
