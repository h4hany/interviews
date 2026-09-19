# Python for Technical Leads

## 1. Python Internals & CPython

### Memory Management & Garbage Collection
**What & How it works internally:**
Python manages memory through a private heap containing all Python objects and data structures. The core mechanism is **Reference Counting**, augmented by a **Generational Garbage Collector** (GC) to detect reference cycles.
- **Reference Counting:** Every object has an `ob_refcnt` field. It increments when assigned, passed to a function, or added to a container. It decrements when a variable goes out of scope, is deleted (`del`), or reassigned. When `ob_refcnt` reaches 0, the memory is immediately deallocated.
- **Generational GC:** Deals with reference cycles. Python has 3 generations. New objects start in gen 0. If they survive a GC run, they promote to older generations. The GC runs more frequently on gen 0.

**Trade-offs & Failure Modes:**
- *Trade-off:* Reference counting provides deterministic destruction but incurs overhead for every assignment. The GC adds pause times but prevents memory leaks from cycles.
- *Failure Mode:* Large object graphs with cycles can cause memory spikes before the GC runs. Unmanaged C extensions can leak memory outside Python's control.

### The Global Interpreter Lock (GIL)
**What:** A mutex that protects access to Python objects, preventing multiple native threads from executing Python bytecodes simultaneously.
**Why:** CPython's memory management (specifically reference counting) is not thread-safe.
**Impact:** CPU-bound multithreaded Python code does not scale across multiple cores. I/O-bound code scales fine because the GIL is released during I/O operations. (Note: PEP 703 aims to make the GIL optional).

## 2. Concurrency Models

| Feature | `asyncio` (Coroutines) | `threading` | `multiprocessing` |
|---------|------------------------|-------------|-------------------|
| **Best For** | Massive I/O bound, Web sockets | I/O bound, Blocking APIs | CPU bound tasks |
| **GIL Bound?**| Yes (Single thread) | Yes | No (Separate processes) |
| **Overhead** | Very low | Medium (OS context switch) | High (Process creation, IPC) |

**Code Example: `asyncio` and `concurrent.futures` integration**
```python
import asyncio
import concurrent.futures
import time

def cpu_bound_task(n: int) -> int:
    return sum(i * i for i in range(n))

async def main():
    loop = asyncio.get_running_loop()
    
    # Run CPU-bound task in a ProcessPoolExecutor to bypass GIL
    with concurrent.futures.ProcessPoolExecutor() as pool:
        result = await loop.run_in_executor(pool, cpu_bound_task, 10_000_000)
        print(f"Result: {result}")

if __name__ == "__main__":
    asyncio.run(main())
```

## 3. Advanced Type Hints

### Protocols (Structural Subtyping)
Unlike inheritance (Nominal subtyping), Protocols define required methods structurally.

```python
from typing import Protocol, runtime_checkable

@runtime_checkable
class Notifier(Protocol):
    def send(self, message: str) -> bool: ...

class EmailNotifier:
    def send(self, message: str) -> bool:
        print(f"Email: {message}")
        return True

def broadcast(notifier: Notifier, msg: str) -> None:
    notifier.send(msg)

broadcast(EmailNotifier(), "System up") # Type-checks perfectly
```

### TypeVar, Generic, and ParamSpec
Used to type decorators or functions that transform callables while preserving their signature.

```python
from typing import Callable, TypeVar, ParamSpec
import time

P = ParamSpec('P')
R = TypeVar('R')

def timing_decorator(func: Callable[P, R]) -> Callable[P, R]:
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
        start = time.perf_counter()
        result = func(*args, **kwargs)
        print(f"Took {time.perf_counter() - start:.4f}s")
        return result
    return wrapper
```

## 4. Python vs TypeScript for Backend

**When to choose TypeScript:**
- Full-stack teams already writing React/Angular/Vue.
- Highly concurrent I/O with complex data transformations.
- Rich domain modeling with advanced structural typing (Union types, mapped types).

**When to choose Python:**
- Heavy data science, AI, ML, or numerical computing workloads.
- Need to leverage the PyData ecosystem (Pandas, NumPy, PyTorch, LangChain).
- Fast prototyping and scripting requirements.

## 5. Interview Questions

**Q1: Explain how you would debug a memory leak in a production Python API.**
*Answer:* I would first identify if it's a Python object leak or a C-level leak. I'd use `tracemalloc` to capture snapshots of memory allocations at different times and compare them to find where allocations are growing. Use `gc.get_objects()` or `objgraph` to visualize reference cycles. For production, I'd expose a debug endpoint that dumps memory profiling stats, secured behind admin auth.

**Q2: How do you handle CPU-bound tasks in a FastAPI (async) application?**
*Answer:* If I run a CPU-bound task directly in an async endpoint, it blocks the event loop. I would use `asyncio.get_running_loop().run_in_executor()` with a `ProcessPoolExecutor`. This offloads the CPU work to a separate process, avoiding the GIL. For heavier workloads, I'd use Celery or ARQ backed by Redis.
