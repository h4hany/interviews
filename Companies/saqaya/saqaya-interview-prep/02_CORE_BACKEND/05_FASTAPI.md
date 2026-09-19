# FastAPI for Technical Leads

## 1. FastAPI Architecture

### Starlette & Pydantic Foundation
**What:** FastAPI is essentially a wrapper around two powerful libraries:
- **Starlette:** Handles the web parts (routing, request/response, middleware, WebSockets, ASGI).
- **Pydantic:** Handles data validation, serialization, and typing via Python type hints.

**ASGI vs WSGI:**
- **WSGI (Web Server Gateway Interface):** Synchronous. One request per thread/process. E.g., Flask, Django (traditionally).
- **ASGI (Asynchronous Server Gateway Interface):** Standard for async Python web servers. Allows handling multiple requests concurrently on a single thread using non-blocking I/O. E.g., FastAPI, Quart.

### Dependency Injection System
**What & Why:** FastAPI provides a powerful DI system. Dependencies are callables (functions/classes) that get executed before the route handler, and their return value is injected into the handler.
**When to use:** DB connections, authentication checking, shared logic, pagination parameters.

```python
from fastapi import FastAPI, Depends, HTTPException, status
from typing import Annotated

app = FastAPI()

def get_db():
    db = "Database Connection"
    try:
        yield db
    finally:
        print("Closing DB")

def verify_token(token: str):
    if token != "secret":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)
    return {"user_id": 1}

@app.get("/items/")
async def read_items(
    db: Annotated[str, Depends(get_db)],
    user: Annotated[dict, Depends(verify_token)]
):
    return {"db": db, "user": user}
```

## 2. Pydantic v2

Pydantic v2 is rewritten in Rust (via `pydantic-core`), offering massive performance improvements (5-50x faster).

### Validators & Model Configuration
```python
from pydantic import BaseModel, Field, field_validator, model_validator
from datetime import datetime

class UserCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    password: str = Field(..., min_length=8)
    confirm_password: str
    birth_date: datetime

    @field_validator('username')
    @classmethod
    def username_alphanumeric(cls, v: str) -> str:
        if not v.isalnum():
            raise ValueError('must be alphanumeric')
        return v

    @model_validator(mode='after')
    def check_passwords_match(self) -> 'UserCreate':
        if self.password != self.confirm_password:
            raise ValueError('passwords do not match')
        return self
```

## 3. Concurrency & Performance

### Async/Await Best Practices
- **Rule of Thumb:** If an endpoint does network/disk I/O (e.g., DB query, API call) and the library is async (e.g., `httpx`, `asyncpg`), define the endpoint with `async def` and `await` the call.
- **Synchronous blocking operations:** If you must use a blocking sync library (e.g., `requests`, synchronous `SQLAlchemy`), define the endpoint as standard `def`. FastAPI will automatically run it in a separate threadpool to prevent blocking the main event loop.

### Scaling & Deployment (Gunicorn + Uvicorn)
For production, you do not run `uvicorn` directly as the process manager. You use `gunicorn` with `uvicorn` workers.
```bash
gunicorn -k uvicorn.workers.UvicornWorker -c gunicorn_conf.py main:app
```
**Why:** Gunicorn handles process management, restarts crashed workers, and manages the pre-fork model, while Uvicorn handles the ASGI async event loop within each worker.

## 4. Interview Questions

**Q1: How does FastAPI handle a route defined with `def` vs `async def`?**
*Answer:* If you define a route with `async def`, FastAPI runs it directly on the main async event loop. If you run blocking I/O or heavy CPU tasks there, you stall the server. If you define it with `def`, FastAPI intelligently runs it in an external threadpool (using `anyio`). Therefore, a blocking DB call in a `def` endpoint won't block the async event loop for other requests.

**Q2: What happens if an unhandled exception occurs inside a FastAPI background task?**
*Answer:* By default, the exception is logged to stderr, but it will not affect the HTTP response since the task runs after the response is sent. However, background tasks in FastAPI (via Starlette) run in the same event loop. If a background task uses heavy CPU or blocks, it will degrade the performance of the whole API. For robust, retryable tasks, a dedicated queue like Celery is better.
