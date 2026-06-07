# Ruby Internals & Runtime — GVL, GC, Ractors, Concurrency

> Deep runtime questions for Staff/Principal-level interviews.

---

## 1. Global VM Lock (GVL)

The GVL (formerly GIL) is a mutex that prevents multiple Ruby threads from executing Ruby bytecode simultaneously. Only one thread holds the GVL at a time.

### Why It Exists
- Ruby's memory management (GC) and C extensions are not thread-safe
- Simplifies VM internals — no fine-grained locking needed
- Ensures compatibility with C libraries

### Impact on Rails Scaling

| Workload | Threads Help? | Why |
|----------|--------------|-----|
| **CPU-bound** | No (concurrent, not parallel) | Threads compete for GVL |
| **I/O-bound** | Yes | GVL released during I/O (DB queries, HTTP, file ops, `sleep`) |

### Thread State Transitions (Database Read)
1. **GVL Held** — thread runs Ruby code to assemble SQL query
2. **Drop GVL** — calls `rb_thread_call_without_gvl`, thread marked as `BLOCKED_IO`
3. **Kernel I/O Wait** — OS blocks thread on socket; another thread acquires GVL
4. **Wake & Re-acquire** — data returns on socket, thread queues for GVL re-acquisition

### Scaling Implications
- For CPU-heavy work → multiple **processes** (Puma workers, Sidekiq processes)
- For I/O work → **threads** are effective (Puma threads, Sidekiq threads)
- Rule: "Fork for CPU, thread for I/O"

> Common mistake: Thinking `Thread.new` gives parallelism for Ruby computation. It gives concurrency, not parallelism.

---

## 2. Garbage Collector (RGenGC)

### How It Works
Ruby uses **mark-and-sweep** with **generational collection** and **incremental marking**.

### Generational GC
- **Young generation** — new objects, collected frequently (minor GC)
- **Old generation** — objects that survive multiple minor GCs, collected less often (major GC)
- Objects are "promoted" from young to old after surviving several collections

### 3-Color Marking
- **White** — unvisited, candidate for collection
- **Grey** — reachable, but children not yet visited
- **Black** — reachable, all children visited

### Write Barrier (wb_protected)
- When an old-generation object references a new-generation object, the write barrier marks the old object for re-examination
- This prevents false collection of new objects referenced only by old objects
- `wb_protected` objects use write barriers; `wb_unprotected` objects are always checked in minor GC

### Tuning for Rails
```ruby
# Environment variables for GC tuning
RUBY_GC_HEAP_INIT_SLOTS=600000       # pre-allocate heap slots
RUBY_GC_HEAP_FREE_SLOTS_MIN_RATIO=0.20
RUBY_GC_HEAP_FREE_SLOTS_MAX_RATIO=0.40
RUBY_GC_MALLOC_LIMIT=64000000
```

### Impact on Production
- Large heaps = longer GC pauses
- Frequent object allocation = frequent minor GC
- Memory bloat from eager loading large datasets
- Monitor: GC time, allocation rate, heap size, RSS

---

## 3. Ractors (Ruby 3+)

### What Are Ractors?
Ruby's actor model for true parallelism — each Ractor has its own GVL and isolated object space.

### Memory Layout Differences

| Feature | Threads | Ractors |
|---------|---------|---------|
| GVL | Shared (one per process) | Separate (one per Ractor) |
| Object Space | Shared | Isolated |
| Parallelism | No (for CPU-bound) | Yes |
| Shared State | Direct access (race-prone) | Copy/Move/Freeze only |

### Object Sharing Rules
- **Copy** — deep serialization via Marshal (expensive)
- **Move** — sender loses reference, receiver gains it
- **Deeply Frozen** — shared freely (frozen strings, numbers, modules)

### Ractor::IsolationError
Thrown when:
- Accessing global variable (`$var`) or class variable (`@@var`) with mutable reference
- Reading/writing instance variables of objects outside current Ractor
- Dynamically modifying methods in a class from within a Ractor

### Practical Limitation
Ractors are not yet fully adopted in typical Rails web request handling due to the isolation constraints.

---

## 4. Concurrency Models in Rails

### Puma Server Model
```text
Puma Process (Master)
  ├── Worker 1 (forked process)
  │     ├── Thread 1
  │     ├── Thread 2
  │     └── Thread N
  ├── Worker 2
  └── Worker M
```

- Each worker is a separate OS process (true parallelism)
- Each worker has multiple threads (concurrency for I/O)
- Thread count should match DB connection pool size

### Sidekiq Concurrency
- Single process with configurable thread count (default 25)
- Effective for I/O-bound jobs
- For CPU-bound jobs, use multiple Sidekiq processes

### Fiber Scheduler (Ruby 3.1+)
- Lightweight cooperative concurrency
- Useful for high-concurrency I/O scenarios
- Not widely adopted in Rails yet

---

## 5. Memory Management

### Common Causes of Memory Bloat in Rails
- Loading too many AR objects (`User.all.each`)
- Inefficient serializers with deeply nested objects
- Unbounded arrays/hashes in memory
- Class variables or global caches as memory leaks
- Large file processing without streaming
- High concurrency with large per-request allocations

### Diagnosis
- Monitor RSS memory, GC time, allocation hotspots
- Use `memory_profiler` gem for allocation analysis
- Use `derailed_benchmarks` for boot-time memory
- Check `ObjectSpace.count_objects` for heap analysis

### Fixes
- `find_each` / `find_in_batches` for large datasets
- `pluck` instead of loading full AR objects
- Stream large files/exports
- Reduce object allocations in hot paths
- Tune Puma workers/threads based on memory limits

---

## 6. Method Lookup & Method Missing

### Method Lookup Chain
```text
Object → Class → Included Modules (last wins) → Superclass → ... → BasicObject
```

### `method_missing` and `respond_to_missing?`
```ruby
class DynamicFinder
  def method_missing(method_name, *args)
    if method_name.to_s.start_with?("find_by_")
      field = method_name.to_s.sub("find_by_", "")
      where(field => args.first).first
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.start_with?("find_by_") || super
  end
end
```

**Always override `respond_to_missing?`** when using `method_missing`.

---

## Interview Quick Reference

| Question | Answer |
|----------|--------|
| What is the GVL? | Mutex preventing parallel Ruby bytecode execution. Threads help for I/O, not CPU. |
| How does Ruby GC work? | Generational mark-and-sweep with 3-color marking and write barriers. |
| What are Ractors? | Actor-based parallelism with isolated object spaces and separate GVLs. |
| Why does Puma use both processes and threads? | Processes for CPU parallelism, threads for I/O concurrency. |
| How do you debug memory issues? | Monitor RSS/GC, use memory_profiler, batch with find_each, pluck scalars. |
