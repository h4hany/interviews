# Node.js Interview Guide

A comprehensive collection of Node.js interview questions and answers, from fundamentals to advanced topics (event loop, worker threads, performance, security, and production).

---

## Table of Contents

1. [Basics & Runtime](#1-basics--runtime)
2. [Modules (CommonJS vs ESM)](#2-modules-commonjs-vs-esm)
3. [Event Loop & Asynchronous Model](#3-event-loop--asynchronous-model)
4. [Core Modules & APIs](#4-core-modules--apis)
5. [Streams & Buffers](#5-streams--buffers)
6. [Process, Cluster & Worker Threads](#6-process-cluster--worker-threads)
7. [Express.js](#7-expressjs)
8. [Security & Best Practices](#8-security--best-practices)
9. [Performance & Debugging](#9-performance--debugging)
10. [Advanced Topics](#10-advanced-topics)

---

## 1. Basics & Runtime

### 1. What is Node.js?
**Answer:**  
Node.js is a runtime environment built on Chrome's V8 JavaScript engine. It allows JavaScript to be executed server-side, enabling full-stack JavaScript development. It uses a **non-blocking, event-driven I/O model** and runs on a **single thread** (with optional worker threads and clustering for CPU/multi-core use). Key traits: async by default, npm ecosystem, and use of `libuv` for I/O and the event loop.  
**Priority: 5**

---

## 2. Modules (CommonJS vs ESM)

### 2. What are the main differences between CommonJS and ES Modules in Node.js?
**Answer:**  
- **CommonJS**: `require()` and `module.exports`; loaded **synchronously** at runtime; **dynamic** (can be conditional); default in Node for `.js` unless `"type": "module"` or `.mjs`.  
- **ES Modules (ESM)**: `import` and `export`; **static** (analyzed at parse time); support **tree-shaking**; native in Node from v12+ (`.mjs` or `"type": "module"` in `package.json`).  
- ESM has top-level `await`; CommonJS does not. Mixing both in one app requires care (e.g. `createRequire` for CJS in ESM).  
**Priority: 5**

---

## 3. Event Loop & Asynchronous Model

### 3. How does the Node.js event loop work?
**Answer:**  
The event loop (implemented in **libuv**) runs in a single thread and processes work in **phases**:  
1. **Timers** – `setTimeout` / `setInterval` callbacks  
2. **Pending callbacks** – deferred I/O callbacks  
3. **Idle, prepare** – internal use  
4. **Poll** – retrieve new I/O events; execute I/O callbacks; may block here  
5. **Check** – `setImmediate()` callbacks  
6. **Close callbacks** – e.g. `socket.on('close')`  

Between phases, **microtasks** run: `process.nextTick()` queue first, then **Promise** callbacks. This allows Node to handle many I/O operations concurrently without multi-threading.  
**Priority: 5**

### 4. What are the differences between `process.nextTick()`, `setImmediate()`, and `setTimeout()`?
**Answer:**  
- **`process.nextTick()`**: Runs after the current operation, **before** the event loop continues to the next phase. Highest priority; can starve I/O if overused.  
- **`setImmediate()`**: Runs in the **check** phase (after I/O). Good for deferring work until after I/O callbacks.  
- **`setTimeout(fn, 0)`**: Schedules in the **timers** phase; runs after I/O and `setImmediate` in typical order.  
**Priority: 4**

### 5. How does Node.js handle asynchronous I/O?
**Answer:**  
Node.js uses **libuv** for I/O: network and some OS APIs use **non-blocking** system calls and the event loop; **file I/O** and CPU-bound work can use a **thread pool** (default size 4). When I/O completes, callbacks (or promise resolution) are queued and run on the main thread, so the event loop is not blocked during waits.  
**Priority: 4**

### 6. What is the role of `libuv` in Node.js?
**Answer:**  
**libuv** is a C library that provides Node.js with: the **event loop**, **thread pool** for file and CPU-bound ops, async TCP/UDP/DNS, file system abstraction, and cross-platform APIs. It sits between V8/JavaScript and the OS.  
**Priority: 3**

---

## 7. Express.js

### 7. Explain the concept of middleware in Express.js.
**Answer:**
Middleware are functions that have access to `req`, `res`, and `next()`. They can modify requests/responses, execute code, or terminate request-response cycles. They are used for tasks like logging, authentication, or error handling.  
**Priority: 5**

### 8. What is the difference between `app.use()` and `app.get()` in Express.js?
**Answer:**  
- **`app.use()`**: Applies middleware to all HTTP methods (and optionally to paths).
- **`app.get()`**: Registers a handler for GET requests for a specific route.  
**Priority: 5**

### 9. How can you handle errors in Express middleware?
**Answer:**
Use middleware with **four parameters**: `(err, req, res, next)`. Express treats 4-arg middleware as error handlers. Call `next(err)` from route handlers or other middleware to pass errors to it; then log and send an appropriate response (e.g. status code and message).  
**Priority: 5**

### 10. How do you handle file uploads in Express.js?
**Answer:**
Use middleware like **multer** to parse `multipart/form-data`. Configure storage (disk or memory), limits, and file filters; then use `upload.single('field')` or `upload.array('field')` in routes and access files on `req.file` / `req.files`.  
**Priority: 4**

---

## 4. Core Modules & APIs (selected)

### 11. How do you manage environment variables in a Node.js app?
**Answer:**  
Use **dotenv**: `require('dotenv').config()` (or `import 'dotenv/config'`) to load a `.env` file into `process.env`. Never commit `.env`; use `.env.example` as a template. In production, set env vars in the host/container.  
**Priority: 4**

### 12. What is the difference between synchronous and asynchronous code in Node.js?
**Answer:**
Synchronous code blocks the event loop until execution completes. Asynchronous code allows Node.js to handle other operations while waiting for I/O using callbacks, promises, or `async/await`.  
**Priority: 5**

---

## 6. Process, Cluster & Worker Threads

### 13. What is the `cluster` module in Node.js and when would you use it?
**Answer:**  
The **cluster** module creates child processes that share the same server port. A primary process distributes incoming connections to workers (round-robin on most platforms). Use it to utilize multiple CPU cores and improve throughput for I/O-bound HTTP servers.  
**Priority: 3**

---

## 8. Security & Best Practices

### 14. How can you secure an Express.js application?
**Answer:**
Use HTTPS, input validation, rate limiting, Helmet middleware, authentication, CORS headers, and sanitization libraries to prevent XSS, CSRF, and injection attacks.  
**Priority: 5**

---

## 5. Streams & Buffers

### 15. What are streams in Node.js?
**Answer:**  
Streams are abstractions for reading/writing data in chunks. Types: **Readable** (e.g. `fs.createReadStream`), **Writable**, **Duplex**, **Transform**. They support backpressure and reduce memory use for large data.  
**Priority: 4**

### 16. Explain the use of `async/await` in Node.js.
**Answer:**
`async/await` simplifies handling asynchronous code. An `async` function returns a promise, and `await` pauses execution until the promise resolves or rejects.  
**Priority: 5**

### 17. How do you validate incoming requests in Express.js?
**Answer:**
Use libraries like `Joi`, `express-validator`, or `zod` to define validation schemas and apply them to requests.  
**Priority: 5**

### 18. What is the purpose of `body-parser` in Express.js?
**Answer:**
`body-parser` parses incoming request bodies and makes them available under `req.body`. Now built-in with `express.json()` and `express.urlencoded()`.  
**Priority: 4**

### 19. What is middleware chaining in Express.js?
**Answer:**
Multiple middleware functions can be chained for a route by calling `next()`. Each middleware runs in sequence until a response is sent or an error occurs.  
**Priority: 4**

### 20. How do you implement authentication in an Express app?
**Answer:**
Use middleware like `passport.js` or JWTs with `jsonwebtoken`. Validate credentials, create sessions or tokens, and protect routes.  
**Priority: 5**

### 21. What is CORS and how do you handle it in Express.js?
**Answer:**
CORS (Cross-Origin Resource Sharing) is a browser security feature. Use the `cors` middleware to allow or restrict origins in Express.  
**Priority: 5**

### 22. What is the difference between `req.params`, `req.query`, and `req.body`?
**Answer:**
- `req.params`: Route parameters (`/users/:id`)
- `req.query`: URL query string (`?sort=desc`)
- `req.body`: Request body (POST/PUT data)  
  **Priority: 5**

### 23. How do you handle sessions in Express?
**Answer:**
Use `express-session` middleware. Store sessions in memory, Redis, or a database. Sessions can persist login state across requests.  
**Priority: 4**

### 24. What is `req.app` and how is it used?
**Answer:**
`req.app` references the Express app instance, useful inside routers or middleware to access app-level settings or configurations.  
**Priority: 3**

---

## 9. Performance & Debugging

### 25. What are some ways to optimize performance in a Node.js application?
**Answer:**  
Use caching (Redis, in-memory), async I/O everywhere, compression (gzip), minimize middleware, cluster for multi-core, connection pooling and query optimization for DBs, and streams for large payloads.  
**Priority: 4**

### 26. What tools or strategies do you use to test a Node.js/Express application?
**Answer:**
Use `Mocha`, `Jest`, `Supertest` for HTTP testing. Structure tests for unit, integration, and E2E. Use CI tools for automation.  
**Priority: 5**

### 27. How would you handle rate limiting in an Express app?
**Answer:**
Use `express-rate-limit` middleware to define limits per IP over a time window to prevent abuse.  
**Priority: 4**

### 28. What is the difference between `res.send()`, `res.json()`, and `res.end()`?
**Answer:**
- `res.send()`: Sends any type of response.
- `res.json()`: Sends a JSON response.
- `res.end()`: Ends the response without data.  
  **Priority: 4**

### 29. How do you structure a large Express.js application for scalability and maintainability?
**Answer:**
Use MVC or layered architecture. Organize code into modules (routes, controllers, services, models). Use routers, config files, dependency injection, and testing.  
**Priority: 5**

### 30. How do you debug a Node.js application in production?
**Answer:**
Use logging (`winston`, `pino`), APM tools (New Relic, Datadog), and monitoring (PM2). Avoid `console.log` in production. Use structured logs and alerts.  
**Priority: 4**

### 31. What is the difference between `require()` and `import` in Node.js?
**Answer:**
- `require()`: CommonJS syntax, synchronous, dynamic loading, can be called conditionally.
- `import`: ES6 module syntax, static analysis, asynchronous, must be at top level, supports tree-shaking.
**Priority: 5**

### 32. What is the difference between `module.exports` and `exports` in Node.js?
**Answer:**
- `module.exports`: The actual object that gets exported.
- `exports`: A reference to `module.exports`. Assigning to `exports` directly doesn't work; you must use `module.exports`.
**Priority: 4**

### 33. What is the `Buffer` class in Node.js?
**Answer:**
`Buffer` is a global class for handling binary data. It's used for working with file systems, network protocols, and other binary data streams.  
**Priority: 4**

### 34. What is the difference between `setImmediate()` and `process.nextTick()`?
**Answer:**
- `process.nextTick()`: Executes in the current phase, before any I/O events.
- `setImmediate()`: Executes in the next iteration of the event loop, after I/O events.
- `process.nextTick()` has higher priority than `setImmediate()`.  
**Priority: 5**

### 35. What is the `fs` module in Node.js?
**Answer:**
The `fs` module provides file system operations. It has both synchronous (`fs.readFileSync`) and asynchronous (`fs.readFile`) methods.  
**Priority: 4**

### 36. What is the difference between `fs.readFile()` and `fs.readFileSync()`?
**Answer:**
- `fs.readFile()`: Asynchronous, non-blocking, uses callbacks or promises.
- `fs.readFileSync()`: Synchronous, blocking, returns the result directly.
**Priority: 4**

### 37. What is the `path` module in Node.js?
**Answer:**
The `path` module provides utilities for working with file and directory paths, handling cross-platform path differences.  
**Priority: 3**

### 38. What is the difference between `__dirname` and `__filename` in Node.js?
**Answer:**
- `__dirname`: The directory name of the current module.
- `__filename`: The absolute path of the current module file.
**Priority: 4**

### 39. What is the `os` module in Node.js?
**Answer:**
The `os` module provides operating system-related utility methods for getting system information like CPU, memory, network interfaces, etc.  
**Priority: 3**

### 40. What is the difference between `child_process.spawn()` and `child_process.exec()`?
**Answer:**
- `spawn()`: Launches a new process, returns a stream, better for long-running processes.
- `exec()`: Executes a command in a shell, buffers output, returns all output at once, better for short commands.
**Priority: 3**

### 41. What is the `util` module in Node.js?
**Answer:**
The `util` module provides utility functions like `util.promisify()` to convert callback-based functions to promises, `util.inherits()` for inheritance, etc.  
**Priority: 3**

### 42. What is the difference between `EventEmitter` and regular events in Node.js?
**Answer:**
`EventEmitter` is a class that provides the ability to emit and listen to custom events. Many Node.js core modules inherit from `EventEmitter`.  
**Priority: 4**

### 43. What is the `crypto` module in Node.js?
**Answer:**
The `crypto` module provides cryptographic functionality including hash functions, encryption, decryption, and digital signatures.  
**Priority: 4**

### 44. What is the difference between `http` and `https` modules in Node.js?
**Answer:**
- `http`: Creates HTTP servers and makes HTTP requests.
- `https`: Creates HTTPS servers and makes HTTPS requests (with SSL/TLS encryption).
**Priority: 4**

### 45. What is the `querystring` module in Node.js?
**Answer:**
The `querystring` module provides utilities for parsing and formatting URL query strings.  
**Priority: 3**

### 46. What is the difference between `readable` and `writable` streams in Node.js?
**Answer:**
- **Readable streams**: Can be read from (e.g., `fs.createReadStream()`).
- **Writable streams**: Can be written to (e.g., `fs.createWriteStream()`).
- **Duplex streams**: Both readable and writable.
- **Transform streams**: Duplex streams that can modify data as it passes through.
**Priority: 4**

### 47. What is `pipe()` in Node.js streams?
**Answer:**
`pipe()` connects readable streams to writable streams, automatically handling backpressure and data flow.  
**Priority: 4**

### 48. What is the difference between `process.env` and `process.argv` in Node.js?
**Answer:**
- `process.env`: Object containing environment variables.
- `process.argv`: Array containing command-line arguments.
**Priority: 4**

### 49. What is the `url` module in Node.js?
**Answer:**
The `url` module provides utilities for URL resolution and parsing, including parsing query strings and pathnames.  
**Priority: 3**

### 50. What is the difference between `setTimeout()` and `setInterval()` in Node.js?
**Answer:**
- `setTimeout()`: Executes a function once after a specified delay.
- `setInterval()`: Executes a function repeatedly at specified intervals.
**Priority: 4**

### 51. What is the `zlib` module in Node.js?
**Answer:**
The `zlib` module provides compression and decompression functionality using Gzip, Deflate, and Brotli algorithms.  
**Priority: 3**

### 52. What is the difference between `process.nextTick()` and `setImmediate()` in terms of execution order?
**Answer:**
`process.nextTick()` callbacks are executed before `setImmediate()` callbacks. `nextTick` has the highest priority in the event loop.  
**Priority: 5**

### 53. What is the `events` module in Node.js?
**Answer:**
The `events` module provides the `EventEmitter` class, which is used to handle events in Node.js. Many core modules inherit from `EventEmitter`.  
**Priority: 4**

### 54. What is the difference between `Buffer.alloc()` and `Buffer.from()`?
**Answer:**
- `Buffer.alloc(size)`: Creates a new buffer of specified size, filled with zeros.
- `Buffer.from(data)`: Creates a new buffer from existing data (string, array, etc.).
**Priority: 3**

### 55. What is the `dns` module in Node.js?
**Answer:**
The `dns` module provides DNS lookup and resolution functionality, including methods to resolve hostnames to IP addresses.  
**Priority: 3**

### 56. What is the difference between `require.resolve()` and `require()`?
**Answer:**
- `require()`: Loads and executes a module.
- `require.resolve()`: Returns the resolved path of a module without loading it.
**Priority: 3**

### 57. What is the `net` module in Node.js?
**Answer:**
The `net` module provides an asynchronous network API for creating TCP servers and clients.  
**Priority: 3**

### 58. What is the difference between `process.exit()` and `process.kill()`?
**Answer:**
- `process.exit(code)`: Exits the current process with an exit code.
- `process.kill(pid, signal)`: Sends a signal to another process.
**Priority: 3**

### 59. What is the `readline` module in Node.js?
**Answer:**
The `readline` module provides an interface for reading data from a readable stream (like `process.stdin`) one line at a time.  
**Priority: 3**

### 60. What is the difference between `cluster.fork()` and `child_process.fork()`?
**Answer:**
- `cluster.fork()`: Creates worker processes that share server ports (for load balancing).
- `child_process.fork()`: Creates a new Node.js process with an IPC channel.
**Priority: 3**

### 61. What is the `worker_threads` module in Node.js?
**Answer:**
The `worker_threads` module allows you to run JavaScript operations in parallel using threads, useful for CPU-intensive tasks.  
**Priority: 3**

### 62. What is the difference between `util.promisify()` and `util.callbackify()`?
**Answer:**
- `util.promisify()`: Converts a callback-based function to a promise-based function.
- `util.callbackify()`: Converts a promise-based function to a callback-based function.
**Priority: 3**

### 63. What is the `vm` module in Node.js?
**Answer:**
The `vm` module provides APIs for compiling and running JavaScript code in a V8 virtual machine context, useful for sandboxing.  
**Priority: 2**

### 64. What is the difference between `stream.Readable` and `stream.Writable`?
**Answer:**
- `stream.Readable`: Base class for readable streams (data flows out).
- `stream.Writable`: Base class for writable streams (data flows in).
**Priority: 4**

### 65. What is the `tls` module in Node.js?
**Answer:**
The `tls` module provides an implementation of Transport Layer Security (TLS) and Secure Socket Layer (SSL) protocols.  
**Priority: 3**

### 66. What is the difference between `fs.stat()` and `fs.statSync()`?
**Answer:**
- `fs.stat()`: Asynchronous, returns file stats via callback or promise.
- `fs.statSync()`: Synchronous, returns file stats directly.
**Priority: 3**

### 67. What is the `punycode` module in Node.js?
**Answer:**
The `punycode` module provides encoding and decoding of Punycode strings (used for internationalized domain names).  
**Priority: 2**

### 68. What is the difference between `process.stdout` and `process.stderr`?
**Answer:**
- `process.stdout`: Standard output stream (for normal output).
- `process.stderr`: Standard error stream (for error messages).
**Priority: 3**

### 69. What is the `string_decoder` module in Node.js?
**Answer:**
The `string_decoder` module provides an API for decoding `Buffer` objects into strings in a way that preserves multi-byte UTF-8 characters.  
**Priority: 2**

### 70. What is the difference between `require.cache` and module caching?
**Answer:**  
`require.cache` is an object that stores cached modules. When you `require()` a module, Node.js checks the cache first before loading it. Deleting a key from `require.cache` forces a fresh load on next `require()`.  
**Priority: 3**

---

## 10. Advanced Topics

### 71. What are the event loop phases in order, and where do Promises and nextTick run?
**Answer:**  
Order: **timers** → **pending callbacks** → **idle/prepare** → **poll** → **check** → **close callbacks**. After each phase, before moving to the next, Node runs **microtasks**: first the entire `process.nextTick` queue, then the **Promise** callback queue. So nextTick and Promise callbacks run between phases, not in a dedicated phase.  
**Priority: 5**

### 72. How can you block the event loop, and how do you avoid it?
**Answer:**  
Blocking: long **synchronous** CPU work (heavy loops, `JSON.parse` on huge payloads, crypto in main thread), or **synchronous** I/O (`*Sync` fs methods). Avoid: use async I/O, move CPU-heavy work to **worker_threads** or **child_process**, break work into chunks with `setImmediate`/nextTick, and avoid large sync operations in request handlers.  
**Priority: 5**

### 73. When would you use Worker Threads vs Cluster vs child_process?
**Answer:**  
- **worker_threads**: Same process, shared memory (SharedArrayBuffer), best for **CPU-bound** JS work (hashing, image processing, heavy computation).  
- **cluster**: Multiple **processes** sharing a port; good for scaling **I/O-bound** HTTP servers across CPU cores.  
- **child_process**: Run other programs or scripts; **spawn** for streaming/long-lived, **exec** for short commands with buffered output; no shared memory.  
**Priority: 5**

### 74. What is backpressure in streams, and how do you handle it?
**Answer:**  
**Backpressure** occurs when the writable side is slower than the readable side; without handling, memory can grow. Handle it: use `stream.pipe()` (it handles backpressure), or check `writable.write()` return value and pause the readable with `readable.pause()` when it’s `false`, then resume on `drain`.  
**Priority: 4**

### 75. How does Node handle uncaught exceptions and unhandled promise rejections?
**Answer:**  
- **uncaughtException**: Emitted when an exception bubbles to the event loop. Listen on `process.on('uncaughtException')`. Default behavior is to exit; you can log and exit gracefully. Avoid long-running logic in the handler.  
- **unhandledRejection**: Emitted when a Promise rejects and no `.catch()` handles it. Listen on `process.on('unhandledRejection')`. Always handle or log and decide whether to exit.  
**Priority: 5**

### 76. What is the thread pool in Node.js, and what uses it?
**Answer:**  
**libuv** provides a thread pool (default **4** threads, configurable via `UV_THREADPOOL_SIZE`). It’s used for: **fs** (most file ops), **dns.lookup**, **crypto** (pbkdf2, randomBytes, etc.), and **zlib** (async compression). Network I/O and timers do **not** use the thread pool.  
**Priority: 4**

### 77. How do you profile and find performance bottlenecks in a Node app?
**Answer:**  
Use **built-in**: `node --inspect` and Chrome DevTools (Profiler, CPU), `node --cpu-prof` to generate a CPU profile. Use **clinic.js** (flame graphs), **0x** for flame graphs. Measure event loop lag, memory with `process.memoryUsage()` or heap snapshots. Use APM tools (New Relic, Datadog) in production.  
**Priority: 4**

### 78. What are the differences between Node’s `http` server and frameworks like Express or Fastify?
**Answer:**  
**http**: Low-level; you handle routing, parsing, and middleware yourself. **Express**: Large ecosystem, middleware model, familiar API; can be slower and less strict. **Fastify**: Plugin-based, schema-based validation, generally faster and lower overhead. Choose by team familiarity, performance needs, and ecosystem.  
**Priority: 4**

### 79. What is the purpose of `domain` and why is it deprecated?
**Answer:**  
**domain** was used to group async operations and catch errors in that group. It’s **deprecated** because it didn’t work well with Promises, could hide errors, and had unclear semantics. Use **async/await** with try/catch, explicit error handlers, and `process.on('uncaughtException'/'unhandledRejection')` instead.  
**Priority: 2**

### 80. How do you implement graceful shutdown in a Node server?
**Answer:**  
Listen for **SIGTERM/SIGINT**. Stop accepting new connections (e.g. `server.close()`), finish in-flight requests, close DB/Redis/queue connections, then `process.exit(0)`. Use timeouts to force exit if shutdown hangs. Example: `process.on('SIGTERM', () => { server.close(() => process.exit(0)); });`  
**Priority: 5**

### 81. What is the V8 engine and how does it relate to Node?
**Answer:**  
**V8** is Google’s open-source JavaScript engine (used in Chrome and Node). It compiles JS to machine code, handles memory (heap, garbage collection), and provides the execution environment. Node wraps V8 with **libuv** (event loop, I/O) and a set of C++ bindings to expose APIs (fs, net, http, etc.).  
**Priority: 4**

### 82. How does garbage collection work in Node (V8), and what are major vs minor GC?
**Answer:**  
V8 uses **generational GC**. **Minor (Scavenge)**: quick, runs often, collects young generation (short-lived objects). **Major (Mark-Sweep/Compact)**: collects full heap, runs less often, can cause longer pauses. Avoid holding large references unnecessarily; use `--expose-gc` and `global.gc()` only for testing.  
**Priority: 3**

### 83. What is the difference between `exports` and `module.exports` when exporting a single function?
**Answer:**  
`module.exports` is what `require()` actually returns. `exports` is a reference to `module.exports`. If you do `exports = function() {}`, you reassign the local `exports` and the module still exports the original `module.exports`. To export a single function, use `module.exports = function() {}`.  
**Priority: 5**

### 84. How do you run TypeScript in Node without precompiling?
**Answer:**  
Use **ts-node** (compile on the fly), or Node’s native **--experimental-strip-types** (Node 22+) to run TS after stripping types, or **tsx** for a faster experience. For production, precompile with `tsc` and run the emitted JS.  
**Priority: 4**

### 85. What are process signals (SIGTERM, SIGINT, SIGKILL), and how do you handle them?
**Answer:**  
- **SIGINT**: Ctrl+C; interrupt.  
- **SIGTERM**: Polite request to terminate (e.g. from process manager).  
- **SIGKILL**: Cannot be caught; force kill.  
Handle SIGINT/SIGTERM for graceful shutdown (close server, flush logs, close DB). You cannot handle SIGKILL.  
**Priority: 4**

### 86. What is the `--max-old-space-size` flag and when do you use it?
**Answer:**  
It sets V8’s **max old generation heap size** in MB (e.g. `node --max-old-space-size=4096` for 4GB). Use it when the process needs more memory than default (~1.5–2GB on 64-bit) to avoid "JavaScript heap out of memory" in long-running or memory-heavy apps.  
**Priority: 4**

### 87. How do you implement request timeouts and avoid hanging requests?
**Answer:**  
Set **timeouts** on the server (e.g. `server.requestTimeout`, `server.headersTimeout` in `http`). For outbound requests, use `AbortController` + `setTimeout` with `fetch` or set `timeout` on client (e.g. axios). Use middleware that rejects or responds after a max time.  
**Priority: 4**

### 88. What is the Event Loop Lag and how do you measure it?
**Answer:**  
**Event loop lag** is the delay between scheduling a callback and it actually running. Measure by recording timestamps in setImmediate and comparing to expected time. High lag means the loop is busy (CPU or too many callbacks). Use **event-loop-stats** or custom setImmediate ping; monitor in APM.  
**Priority: 3**

### 89. How do you share state between Worker Threads?
**Answer:**  
Use **SharedArrayBuffer** for numeric data (e.g. TypedArrays) so workers can read/write shared memory. For other state, use **MessageChannel** or **parentPort.postMessage** to send data; no shared object heap between workers. Atomics can synchronize access to SharedArrayBuffer.  
**Priority: 4**

### 90. What is the difference between `setTimeout(fn, 0)` and `setImmediate(fn)` in the main module?
**Answer:**  
In the **main module**, execution order can vary: both are scheduled after the current script and after I/O. In **I/O callbacks**, setImmediate always runs before setTimeout(0). So for “after current and I/O,” prefer **setImmediate** for clarity.  
**Priority: 4**

### 91. How do you implement a health check endpoint for a Node API?
**Answer:**  
Expose a route (e.g. `GET /health`) that returns 200 and optionally JSON with status (e.g. `{ "status": "ok", "db": "connected" }`). Optionally check DB, cache, or queue connectivity. Use for load balancers and orchestrators (Kubernetes liveness/readiness). Keep it cheap and fast.  
**Priority: 5**

### 92. What is the purpose of `NODE_ENV` and common values?
**Answer:**  
**NODE_ENV** is a convention for the environment (development, production, test). **production** often enables caching, minimal stack traces, and optimizations. **development** enables verbose logging and dev tools. **test** for test runners. Set in the shell or in your process manager (PM2, systemd, Docker).  
**Priority: 5**

### 93. How do you prevent prototype pollution in Node/Express?
**Answer:**  
Avoid merging user input directly onto objects (e.g. `Object.assign(req.body, ...)`). Use **allowlist** for known keys, use **Map** for user-driven keys, freeze prototypes in sensitive paths, and use libraries that sanitize (e.g. schema validation). Validate and sanitize before using as object keys.  
**Priority: 4**

### 94. What is the Node.js LTS schedule and why does it matter?
**Answer:**  
**LTS** (Long Term Support) versions get bug fixes and security updates for a defined period (e.g. 30 months). **Current** gets features and short support. Prefer LTS in production for stability and security. Check nodejs.org for exact dates (e.g. Active LTS, Maintenance).  
**Priority: 4**

### 95. How do you implement idempotency for API endpoints?
**Answer:**  
Client sends an **idempotency key** (header or body). Server stores it (e.g. in Redis or DB) with the response or status. For duplicate requests with the same key, return the stored response without re-executing the operation. Set TTL on keys to avoid unbounded growth.  
**Priority: 4**

### 96. What is the difference between `readFile` and `createReadStream` for large files?
**Answer:**  
**readFile**: Loads the **entire file** into memory; can cause high memory use or OOM for large files. **createReadStream**: Reads in **chunks**; uses streams and backpressure, constant memory. Prefer **createReadStream** (and piping) for large files and responses.  
**Priority: 5**

### 97. How do you secure secrets (API keys, DB passwords) in a Node app?
**Answer:**  
Use **environment variables** (e.g. from `.env` in dev, from host/container in prod). Never commit secrets. Use secret managers (AWS Secrets Manager, HashiCorp Vault) in production. Restrict file permissions for `.env`. Rotate secrets and use least-privilege access.  
**Priority: 5**

### 98. What is the `AsyncLocalStorage` API and when do you use it?
**Answer:**  
**AsyncLocalStorage** (from `async_hooks`) provides **request-scoped** or async-context storage. You can store request ID, user, or other context and access it in any downstream async code without passing arguments. Use for logging, tracing, and request context in async flows.  
**Priority: 4**

### 99. How do you implement retries with exponential backoff for external APIs?
**Answer:**  
On failure, retry with increasing delay (e.g. 1s, 2s, 4s) and a max retry count. Use **async/await** in a loop or a library (e.g. **p-retry**, **bottleneck**). Respect **Retry-After** if the server sends it. Use for transient failures only; fail fast for 4xx (except 429).  
**Priority: 4**

### 100. What are the trade-offs of using PM2 vs running Node directly in production?
**Answer:**  
**PM2**: Process management, clustering, restarts on crash, logs, monitoring, startup scripts. **Plain Node**: Simpler, fewer dependencies; you handle restarts (e.g. systemd, Docker restart policy) and logging. Use PM2 when you want built-in process management and ops features; use plain Node in containers/orchestrators.  
**Priority: 4**
