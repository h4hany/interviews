# Python, Django & FastAPI Interview Questions & Answers (50+)

---

## Python fundamentals

### 1. What is the difference between list and tuple?
**Answer:** **List:** mutable, `[]`, use when you need to change the sequence. **Tuple:** immutable, `()`, hashable if elements are; use for fixed data (e.g. keys, return values). Tuples are slightly faster and use less memory.

### 2. What is the difference between `list` and `array` (NumPy)?
**Answer:** **list:** built-in, heterogeneous, no vectorized ops. **NumPy array:** homogeneous, fixed type, vectorized operations, efficient for numerical work. Use list for general data; array for math/scientific computing.

### 3. What is the GIL (Global Interpreter Lock)?
**Answer:** A lock in CPython that allows only one thread to execute Python bytecode at a time.

> [!TIP]
> **Antigravity Tip**: With Python 3.13, we are entering the **No-GIL** era. However, for most Principal-level discussions today, the advice remains: use **Multiprocessing** for CPU-bound tasks and **Asyncio/Threading** for I/O. At BrandOS, we offloaded heavy CSV exports to a background Celery worker (multiprocessing) to avoid blocking the main API thread's GIL.

### 4. What is the difference between `deepcopy` and shallow copy?
**Answer:** **Shallow copy:** new container, but elements are the same references (e.g. `list.copy()`, `copy.copy()`). **Deep copy:** new container and recursively new copies of nested objects (`copy.deepcopy()`).

### 5. What are decorators and how do you write one?
**Answer:** Functions that wrap another function to add behavior (logging, auth, caching). `@decorator` is syntactic sugar for `func = decorator(func)`. Example: `def log(f): return lambda *a, **k: (print('call'), f(*a, **k))`.

### 6. What is the difference between `*args` and `**kwargs`?
**Answer:** **\*args:** variable positional arguments (tuple). **\*\*kwargs:** variable keyword arguments (dict). Use for flexible function signatures and forwarding.

### 7. What are list comprehensions vs generator expressions?
**Answer:** **List comprehension** `[x for x in it]` builds a full list. **Generator expression** `(x for x in it)` yields one item at a time; lazy and memory-efficient. Use generators for large or infinite sequences.

### 8. What is the difference between `__str__` and `__repr__`?
**Answer:** **__str__:** human-readable; used by `str()` and `print()`. **__repr__:** unambiguous, ideally valid Python; used by `repr()` and in debugger. Default __str__ uses __repr__.

### 9. What is the difference between `==` and `is`?
**Answer:** **==** is value equality (calls `__eq__`). **is** is identity (same object in memory). Use `is` for None, True, False; use `==` for values.

### 10. What are context managers and `with`?
**Answer:** Objects that define `__enter__` and `__exit__` for setup/teardown (e.g. open file, lock). `with expr as x:` calls __enter__, assigns to x, then __exit__ on exit. Use `contextlib.contextmanager` for generator-based ones.

---

## Python OOP & advanced

### 11. What is the difference between class method, static method, and instance method?
**Answer:** **Instance method:** receives `self`, instance. **@classmethod:** receives `cls`, class; use for alternate constructors or class-level logic. **@staticmethod:** no cls/self; use for utility tied to class namespace.

### 12. What are duck typing and EAFP?
**Answer:** **Duck typing:** “If it walks and quacks like a duck…” — use object’s interface, not type. **EAFP:** “Easier to Ask Forgiveness than Permission” — try and catch exception instead of checking in advance (e.g. try/except KeyError).

### 13. What is the difference between `range` and `xrange` (Python 2) / `range` (Python 3)?
**Answer:** In Python 3, **range** is lazy (like Python 2 xrange); it doesn’t build a list. So `range(10)**` is memory-efficient. In Python 2, range was a list, xrange was the lazy version.

### 14. What are metaclasses (brief)?
**Answer:** Class of a class; control how a class is created. Rarely needed; use for framework-level behavior (e.g. ORM, registration). Most needs are met by decorators or __init_subclass__.

### 15. What is the difference between `async`/`await` and threading?
**Answer:** **async/await:** single-threaded concurrency for I/O-bound work; cooperative multitasking; use with asyncio. **Threading:** OS threads; limited by GIL for CPU-bound; use for I/O or with multiprocessing for CPU. For many I/O-bound tasks, async is often simpler and lighter.

---

## Django basics

### 16. What is Django’s MVT (Model-View-Template)?
**Answer:** **Model:** data layer (ORM, DB). **View:** logic that handles request and returns response (like controller in MVC). **Template:** presentation (HTML). “View” in Django is closer to “controller” in MVC.

### 17. What is the Django ORM and how do you run raw SQL?
**Answer:** ORM: Python classes map to tables; QuerySet API for queries. Raw SQL: **Model.objects.raw('SELECT ...')** or **connection.cursor()** for full control. Use raw when ORM is insufficient or for complex queries.

### 18. What is the difference between `get()` and `filter()`?
**Answer:** **get():** returns one object; raises DoesNotExist or MultipleObjectsReturned. **filter():** returns QuerySet (lazy); 0 or more. Use get when you expect exactly one; filter for lists.

### 19. What is Django’s migration system?
**Answer:** Migrations are versioned DB schema changes (auto-generated from model changes or hand-written). **makemigrations** creates; **migrate** applies. Keeps schema in sync across envs and history.

### 20. What are Django signals and when to use them?
**Answer:** Decoupled way to run code when certain events occur (e.g. post_save, pre_delete). Use for cross-app logic (e.g. invalidate cache on save). Overuse can make flow hard to follow; prefer explicit calls when possible.

### 21. What is the difference between `select_related` and `prefetch_related`?
**Answer:**- **select_related**: SQL JOIN for single relations. *Example*: `Book.objects.select_related('author')` fetches both in one SQL query.
- Both prevent the N+1 problem.

> [!TIP]
> **Antigravity Tip**: Be careful with `prefetch_related` on large datasets. Since it does a separate query and brings everything into memory to do the join in Python, it can cause **OOM (Out of Memory)** errors if the related table has millions of rows. Always limit the columns with `only()` or use `Prefetch(queryset=...)` to filter the related data at the DB level.

### 22. What is Django’s middleware?
**Answer:** Lightweight plugin that runs on request/response. Order matters. Used for auth, CSRF, session, logging, etc. Process_request, process_response, process_view, process_exception.

### 23. How does Django handle authentication?
**Answer:** **Authentication:** who the user is (User model, session or token). **Authorization:** permissions (user_permissions, group_permissions). **@login_required**, **PermissionRequiredMixin**, or manual checks in views.

### 24. What is the difference between Django’s `Form` and `ModelForm`?
**Answer:** **Form:** manual fields and validation; generic. **ModelForm:** built from a Model; fields, validation, and save() to model. Use ModelForm when form maps to a single model.

### 25. What is Django REST framework (DRF) and why use it?
**Answer:** Toolkit for building REST APIs in Django: serializers, ViewSets, routers, auth (session, token, JWT), throttling, pagination. Speeds up API development and keeps conventions consistent.

---

## Django advanced

### 26. What is Django’s caching framework?
**Answer:** Cache backends (Memcached, Redis, DB, file, local memory). **cache.get/set**, **@cache_page**, **cache template tag**. Use for views, fragments, or low-level keys. Configure CACHES and cache key prefix per env.

### 27. How do you handle background tasks in Django?
**Answer:** Background tasks (Celery with Redis/RabbitMQ):
- *Example*: When a user signs up, you want to send them a "Welcome Email". Instead of making the user wait for the email server to respond, you push a task to Celery and return the "Success" page to the user immediately.

> [!TIP]
> **Antigravity Tip**: For background tasks, always design them to be **Idempotent**. If a task fails halfway and Celery retries it, your system shouldn't send the user two welcome emails or charge them twice. Use a unique "Task-ID" or check the database state before executing side effects.

### 28. What is the N+1 problem in Django ORM and how do you fix it?
**Answer:** One query for a list, then one query per item for a relation. Fix: **select_related** (FK, OneToOne), **prefetch_related** (reverse FK, M2M), or **only()/defer()** to limit columns. Use **Prefetch** for filtered prefetch.

### 29. What is Django’s transaction handling?
**Answer:** **@transaction.atomic** (decorator or context manager): block runs in a transaction; rollback on exception. **ATOMIC_REQUESTS:** wrap each view in a transaction. Use savepoints for nested atomic blocks.

### 30. What is the difference between `create()` and `get_or_create()`?
**Answer:** **create():** always creates; can raise IntegrityError if unique fails. **get_or_create():** returns (object, created); gets existing or creates; uses defaults for creation. Use get_or_create to avoid duplicate creation race when acceptable.

---

## FastAPI basics

### 31. What is FastAPI and why use it?
**Answer:** Modern async Python web framework; built on Starlette and Pydantic. Automatic OpenAPI docs, validation from type hints, async support, dependency injection. Good for high-performance APIs and quick iteration.

### 32. What is the difference between FastAPI and Django/Flask?
**Answer:** **FastAPI:** async-first, Pydantic, OpenAPI out of the box; minimal built-in admin/auth. **Django:** full-stack, ORM, admin, auth; sync by default. **Flask:** minimal, flexible; no built-in validation or async. Use FastAPI for APIs; Django for full apps with admin; Flask for small or custom apps.

### 33. How does FastAPI use type hints for validation?
**Answer:** Request body, query, path parameters use type hints; FastAPI uses **Pydantic** to validate and serialize. Invalid input returns 422 with error details. Example: `def get(id: int, q: str = None): ...`.

### 34. What is FastAPI’s dependency injection system?
**Answer:** Declare dependencies as callables; FastAPI resolves and injects them.
- *Example*: `def get_db(): ...`. In your route, you add `db: Session = Depends(get_db)`. FastAPI automatically calls `get_db` and provides the database connection to your function.

> [!TIP]
> **Antigravity Tip**: Use **Dependency Overriding** for testing. FastAPI's DI system allows you to easily swap a real DB dependency for a mock one in your test suite using `app.dependency_overrides`. This ensures your unit tests are fast and don't require a live database.

### 35. How do you handle errors and exceptions in FastAPI?
**Answer:** **HTTPException** for HTTP errors. **Exception handlers** with @app.exception_handler for custom handling. Unhandled exceptions can return 500; use handler to log and return consistent format.

### 36. What is the difference between sync and async endpoint functions in FastAPI?
**Answer:** **Async:** use when you have I/O-bound async code (e.g. async DB driver); doesn’t block the event loop. **Sync:** runs in thread pool by default; use for sync libraries. Prefer async for new I/O-bound code.

### 37. How do you secure a FastAPI app (e.g. JWT)?
**Answer:** Use **OAuth2PasswordBearer** or custom dependency that reads token (header/cookie), validates JWT, and loads user. Add dependency to protected routes. Use HTTPS and secure cookie if storing token in cookie.

### 38. What is Pydantic and how does FastAPI use it?
**Answer:** Pydantic: validation and serialization using type hints. FastAPI uses it for request body, response_model, and query/path validation. Define **BaseModel** with fields; automatic validation and JSON schema for OpenAPI.

### 39. How do you document APIs in FastAPI?
**Answer:** OpenAPI (Swagger) at **/docs**, ReDoc at **/redoc** by default. Enhance with **summary**, **description**, **response_model**, **responses** on path and dependency. Pydantic models and types drive schema.

### 40. How do you run background tasks after returning a response in FastAPI?
**Answer:** **BackgroundTasks** dependency: add a function with **background_tasks.add_task(func, ...)**. Runs after response is sent. For heavier or durable work use Celery or similar.

---

## FastAPI & Django comparison

### 41. When would you choose Django over FastAPI?
**Answer:** Need full-stack app, admin, ORM, built-in auth, batteries-included. Prefer sync and Django’s ecosystem. Large existing Django codebase.

### 42. When would you choose FastAPI over Django?
**Answer:** Building APIs only; want async, automatic docs, validation from types; high performance; microservices. Prefer modern Python and OpenAPI.

### 43. Can you use Django ORM with FastAPI?
**Answer:** Yes. Use Django outside of request/response (e.g. set up Django and import models). Run Django in sync way or use sync_to_async for async views. Often use SQLAlchemy or separate DB layer with FastAPI for cleaner separation.

---

## Python & Django testing

### 44. What is the difference between unit test and integration test?
**Answer:** **Unit:** one unit (function, class) in isolation; mocks for dependencies. **Integration:** multiple components together (e.g. DB, API). Both matter; unit for logic, integration for flows.

### 45. How do you test Django views and APIs?
**Answer:** **Django test Client:** get/post, assert status, content. **DRF APIClient** for REST. Use **TestCase** (DB) or **SimpleTestCase** (no DB). Factory or fixtures for data. Mock external services.

### 46. What is pytest and how is it different from unittest?
**Answer:** **pytest:** plugin-rich, assert rewriting, fixtures, parametrize; minimal boilerplate. **unittest:** stdlib, class-based, assert methods. Can run unittest-style tests with pytest. Many prefer pytest for readability and features.

---

## Deployment & performance

### 47. How do you deploy a Django app in production?
**Answer:** **WSGI** (e.g. Gunicorn) behind **Nginx** (static, proxy). Or **ASGI** (e.g. Uvicorn/Daphne) for async. Use **collectstatic**, **migrate**, env vars for settings, **ALLOWED_HOSTS**, HTTPS. Use systemd or supervisor for process management.

### 48. How do you deploy a FastAPI app?
**Answer:** **ASGI** server (e.g. **Uvicorn**): `uvicorn main:app`. Behind Nginx for static/SSL. Multiple workers for concurrency. Same ideas: env config, HTTPS, process manager. Can run in Docker/Kubernetes.

### 49. How do you optimize Django ORM queries?
**Answer:** **select_related** / **prefetch_related**; **only()** / **defer()**; **count()** instead of len(queryset); **exists()** for existence; **values()** / **values_list** for subsets; index DB properly; use **QuerySet** in templates to avoid N+1.

### 50. What is connection pooling and how do you use it with Django?
**Answer:** Reuse DB connections instead of opening per request. **django-db-connection-pool** or **pgbouncer** (external). Reduces connection overhead under load. Configure in DATABASES or via pooler.

---

## Quick reference

| Topic | Key points |
|-------|------------|
| Python | list vs tuple, GIL, decorators, *args/**kwargs, comprehensions vs generators |
| Django | MVT, ORM get/filter, migrations, select_related/prefetch_related, signals, middleware |
| DRF | Serializers, ViewSets, auth, throttling |
| FastAPI | Async, Pydantic, DI, OpenAPI, BackgroundTasks |
| Testing | Unit vs integration, Django Client, pytest |
| Deploy | Gunicorn/Uvicorn, Nginx, static, env, DB pool |
