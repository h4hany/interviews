1. What is Node.js?
### **Answer:**
Node.js is a runtime environment built on Chrome's V8 JavaScript engine. It allows JavaScript to be executed server-side, enabling full-stack JavaScript development. It's known for its non-blocking, event-driven architecture.  
**Priority: 5**

2. What are the main differences between CommonJS and ES Modules in Node.js?
### **Answer:**
CommonJS uses `require()` and `module.exports`, while ES Modules use `import` and `export`. ES Modules are static and support tree-shaking, whereas CommonJS is dynamic. ES Modules are natively supported from Node.js v12+.  
**Priority: 5**

3. How does the Node.js event loop work?
### **Answer:**
The event loop processes asynchronous callbacks in phases (timers, pending callbacks, idle/prepare, poll, check, close callbacks). It allows Node.js to handle many operations concurrently without multi-threading.  
**Priority: 5**

4. What are the differences between `process.nextTick()`, `setImmediate()`, and `setTimeout()`?
### **Answer:**
- `process.nextTick()`: Runs immediately after the current operation completes, before the event loop continues.
- `setImmediate()`: Runs in the check phase, after I/O events.
- `setTimeout()`: Schedules execution after a delay.  
  **Priority: 4**

5. How does Node.js handle asynchronous I/O?
### **Answer:**
Node.js offloads I/O tasks to the thread pool (via `libuv`), and uses callbacks, promises, or `async/await` to manage responses without blocking the event loop.  
**Priority: 4**

6. What is the role of `libuv` in Node.js?
### **Answer:**
`libuv` is a C library that provides Node.js with asynchronous I/O and handles the event loop, thread pool, and low-level system tasks like networking and file system access.  
**Priority: 3**

7. Explain the concept of middleware in Express.js.
### **Answer:**
Middleware are functions that have access to `req`, `res`, and `next()`. They can modify requests/responses, execute code, or terminate request-response cycles. They are used for tasks like logging, authentication, or error handling.  
**Priority: 5**

8. What is the difference between `app.use()` and `app.get()` in Express.js?
### **Answer:**
- `app.use()` applies middleware to all HTTP methods.
- `app.get()` handles only GET requests for a specific route.  
  **Priority: 5**

9. How can you handle errors in Express middleware?
### **Answer:**
Define error-handling middleware with four parameters: `(err, req, res, next)`. You can log the error and send an appropriate response to the client.  
**Priority: 5**

10. How do you handle file uploads in Express.js?
### **Answer:**
Use middleware like `multer` to parse `multipart/form-data` for file uploads. Define routes that handle and store the uploaded files.  
**Priority: 4**

11. How do you manage environment variables in a Node.js app?
### **Answer:**
Using the `dotenv` package to load variables from a `.env` file into `process.env`. Example: `require('dotenv').config()`.  
**Priority: 4**

12. What is the difference between synchronous and asynchronous code in Node.js?
### **Answer:**
Synchronous code blocks the event loop until execution completes. Asynchronous code allows Node.js to handle other operations while waiting for I/O using callbacks, promises, or `async/await`.  
**Priority: 5**

13. What is the `cluster` module in Node.js and when would you use it?
### **Answer:**
The `cluster` module allows creating child processes to utilize multiple CPU cores. It's used to improve performance and handle concurrent requests more efficiently.  
**Priority: 3**

14. How can you secure an Express.js application?
### **Answer:**
Use HTTPS, input validation, rate limiting, Helmet middleware, authentication, CORS headers, and sanitization libraries to prevent XSS, CSRF, and injection attacks.  
**Priority: 5**

15. What are streams in Node.js?
### **Answer:**
Streams are interfaces for reading or writing data piece-by-piece. Types include Readable, Writable, Duplex, and Transform. They improve performance for large data processing.  
**Priority: 4**

16. Explain the use of `async/await` in Node.js.
### **Answer:**
`async/await` simplifies handling asynchronous code. An `async` function returns a promise, and `await` pauses execution until the promise resolves or rejects.  
**Priority: 5**

17. How do you validate incoming requests in Express.js?
### **Answer:**
Use libraries like `Joi`, `express-validator`, or `zod` to define validation schemas and apply them to requests.  
**Priority: 5**

18. What is the purpose of `body-parser` in Express.js?
### **Answer:**
`body-parser` parses incoming request bodies and makes them available under `req.body`. Now built-in with `express.json()` and `express.urlencoded()`.  
**Priority: 4**

19. What is middleware chaining in Express.js?
### **Answer:**
Multiple middleware functions can be chained for a route by calling `next()`. Each middleware runs in sequence until a response is sent or an error occurs.  
**Priority: 4**

20. How do you implement authentication in an Express app?
### **Answer:**
Use middleware like `passport.js` or JWTs with `jsonwebtoken`. Validate credentials, create sessions or tokens, and protect routes.  
**Priority: 5**

21. What is CORS and how do you handle it in Express.js?
### **Answer:**
CORS (Cross-Origin Resource Sharing) is a browser security feature. Use the `cors` middleware to allow or restrict origins in Express.  
**Priority: 5**

22. What is the difference between `req.params`, `req.query`, and `req.body`?
### **Answer:**
- `req.params`: Route parameters (`/users/:id`)
- `req.query`: URL query string (`?sort=desc`)
- `req.body`: Request body (POST/PUT data)  
  **Priority: 5**

23. How do you handle sessions in Express?
### **Answer:**
Use `express-session` middleware. Store sessions in memory, Redis, or a database. Sessions can persist login state across requests.  
**Priority: 4**

24. What is `req.app` and how is it used?
### **Answer:**
`req.app` references the Express app instance, useful inside routers or middleware to access app-level settings or configurations.  
**Priority: 3**

25. What are some ways to optimize performance in a Node.js application?
### **Answer:**
- Use caching
- Use asynchronous operations
- Use compression
- Reduce middleware
- Load balance using clusters
- Optimize database queries  
  **Priority: 4**

26. What tools or strategies do you use to test a Node.js/Express application?
### **Answer:**
Use `Mocha`, `Jest`, `Supertest` for HTTP testing. Structure tests for unit, integration, and E2E. Use CI tools for automation.  
**Priority: 5**

27. How would you handle rate limiting in an Express app?
### **Answer:**
Use `express-rate-limit` middleware to define limits per IP over a time window to prevent abuse.  
**Priority: 4**

28. What is the difference between `res.send()`, `res.json()`, and `res.end()`?
### **Answer:**
- `res.send()`: Sends any type of response.
- `res.json()`: Sends a JSON response.
- `res.end()`: Ends the response without data.  
  **Priority: 4**

29. How do you structure a large Express.js application for scalability and maintainability?
### **Answer:**
Use MVC or layered architecture. Organize code into modules (routes, controllers, services, models). Use routers, config files, dependency injection, and testing.  
**Priority: 5**

30. How do you debug a Node.js application in production?
### **Answer:**
Use logging (`winston`, `pino`), APM tools (New Relic, Datadog), and monitoring (PM2). Avoid `console.log` in production. Use structured logs and alerts.  
**Priority: 4**

31. What is the difference between `require()` and `import` in Node.js?
### **Answer:**
- `require()`: CommonJS syntax, synchronous, dynamic loading, can be called conditionally.
- `import`: ES6 module syntax, static analysis, asynchronous, must be at top level, supports tree-shaking.
**Priority: 5**

32. What is the difference between `module.exports` and `exports` in Node.js?
### **Answer:**
- `module.exports`: The actual object that gets exported.
- `exports`: A reference to `module.exports`. Assigning to `exports` directly doesn't work; you must use `module.exports`.
**Priority: 4**

33. What is the `Buffer` class in Node.js?
### **Answer:**
`Buffer` is a global class for handling binary data. It's used for working with file systems, network protocols, and other binary data streams.  
**Priority: 4**

34. What is the difference between `setImmediate()` and `process.nextTick()`?
### **Answer:**
- `process.nextTick()`: Executes in the current phase, before any I/O events.
- `setImmediate()`: Executes in the next iteration of the event loop, after I/O events.
- `process.nextTick()` has higher priority than `setImmediate()`.  
**Priority: 5**

35. What is the `fs` module in Node.js?
### **Answer:**
The `fs` module provides file system operations. It has both synchronous (`fs.readFileSync`) and asynchronous (`fs.readFile`) methods.  
**Priority: 4**

36. What is the difference between `fs.readFile()` and `fs.readFileSync()`?
### **Answer:**
- `fs.readFile()`: Asynchronous, non-blocking, uses callbacks or promises.
- `fs.readFileSync()`: Synchronous, blocking, returns the result directly.
**Priority: 4**

37. What is the `path` module in Node.js?
### **Answer:**
The `path` module provides utilities for working with file and directory paths, handling cross-platform path differences.  
**Priority: 3**

38. What is the difference between `__dirname` and `__filename` in Node.js?
### **Answer:**
- `__dirname`: The directory name of the current module.
- `__filename`: The absolute path of the current module file.
**Priority: 4**

39. What is the `os` module in Node.js?
### **Answer:**
The `os` module provides operating system-related utility methods for getting system information like CPU, memory, network interfaces, etc.  
**Priority: 3**

40. What is the difference between `child_process.spawn()` and `child_process.exec()`?
### **Answer:**
- `spawn()`: Launches a new process, returns a stream, better for long-running processes.
- `exec()`: Executes a command in a shell, buffers output, returns all output at once, better for short commands.
**Priority: 3**

41. What is the `util` module in Node.js?
### **Answer:**
The `util` module provides utility functions like `util.promisify()` to convert callback-based functions to promises, `util.inherits()` for inheritance, etc.  
**Priority: 3**

42. What is the difference between `EventEmitter` and regular events in Node.js?
### **Answer:**
`EventEmitter` is a class that provides the ability to emit and listen to custom events. Many Node.js core modules inherit from `EventEmitter`.  
**Priority: 4**

43. What is the `crypto` module in Node.js?
### **Answer:**
The `crypto` module provides cryptographic functionality including hash functions, encryption, decryption, and digital signatures.  
**Priority: 4**

44. What is the difference between `http` and `https` modules in Node.js?
### **Answer:**
- `http`: Creates HTTP servers and makes HTTP requests.
- `https`: Creates HTTPS servers and makes HTTPS requests (with SSL/TLS encryption).
**Priority: 4**

45. What is the `querystring` module in Node.js?
### **Answer:**
The `querystring` module provides utilities for parsing and formatting URL query strings.  
**Priority: 3**

46. What is the difference between `readable` and `writable` streams in Node.js?
### **Answer:**
- **Readable streams**: Can be read from (e.g., `fs.createReadStream()`).
- **Writable streams**: Can be written to (e.g., `fs.createWriteStream()`).
- **Duplex streams**: Both readable and writable.
- **Transform streams**: Duplex streams that can modify data as it passes through.
**Priority: 4**

47. What is `pipe()` in Node.js streams?
### **Answer:**
`pipe()` connects readable streams to writable streams, automatically handling backpressure and data flow.  
**Priority: 4**

48. What is the difference between `process.env` and `process.argv` in Node.js?
### **Answer:**
- `process.env`: Object containing environment variables.
- `process.argv`: Array containing command-line arguments.
**Priority: 4**

49. What is the `url` module in Node.js?
### **Answer:**
The `url` module provides utilities for URL resolution and parsing, including parsing query strings and pathnames.  
**Priority: 3**

50. What is the difference between `setTimeout()` and `setInterval()` in Node.js?
### **Answer:**
- `setTimeout()`: Executes a function once after a specified delay.
- `setInterval()`: Executes a function repeatedly at specified intervals.
**Priority: 4**

51. What is the `zlib` module in Node.js?
### **Answer:**
The `zlib` module provides compression and decompression functionality using Gzip, Deflate, and Brotli algorithms.  
**Priority: 3**

52. What is the difference between `process.nextTick()` and `setImmediate()` in terms of execution order?
### **Answer:**
`process.nextTick()` callbacks are executed before `setImmediate()` callbacks. `nextTick` has the highest priority in the event loop.  
**Priority: 5**

53. What is the `events` module in Node.js?
### **Answer:**
The `events` module provides the `EventEmitter` class, which is used to handle events in Node.js. Many core modules inherit from `EventEmitter`.  
**Priority: 4**

54. What is the difference between `Buffer.alloc()` and `Buffer.from()`?
### **Answer:**
- `Buffer.alloc(size)`: Creates a new buffer of specified size, filled with zeros.
- `Buffer.from(data)`: Creates a new buffer from existing data (string, array, etc.).
**Priority: 3**

55. What is the `dns` module in Node.js?
### **Answer:**
The `dns` module provides DNS lookup and resolution functionality, including methods to resolve hostnames to IP addresses.  
**Priority: 3**

56. What is the difference between `require.resolve()` and `require()`?
### **Answer:**
- `require()`: Loads and executes a module.
- `require.resolve()`: Returns the resolved path of a module without loading it.
**Priority: 3**

57. What is the `net` module in Node.js?
### **Answer:**
The `net` module provides an asynchronous network API for creating TCP servers and clients.  
**Priority: 3**

58. What is the difference between `process.exit()` and `process.kill()`?
### **Answer:**
- `process.exit(code)`: Exits the current process with an exit code.
- `process.kill(pid, signal)`: Sends a signal to another process.
**Priority: 3**

59. What is the `readline` module in Node.js?
### **Answer:**
The `readline` module provides an interface for reading data from a readable stream (like `process.stdin`) one line at a time.  
**Priority: 3**

60. What is the difference between `cluster.fork()` and `child_process.fork()`?
### **Answer:**
- `cluster.fork()`: Creates worker processes that share server ports (for load balancing).
- `child_process.fork()`: Creates a new Node.js process with an IPC channel.
**Priority: 3**

61. What is the `worker_threads` module in Node.js?
### **Answer:**
The `worker_threads` module allows you to run JavaScript operations in parallel using threads, useful for CPU-intensive tasks.  
**Priority: 3**

62. What is the difference between `util.promisify()` and `util.callbackify()`?
### **Answer:**
- `util.promisify()`: Converts a callback-based function to a promise-based function.
- `util.callbackify()`: Converts a promise-based function to a callback-based function.
**Priority: 3**

63. What is the `vm` module in Node.js?
### **Answer:**
The `vm` module provides APIs for compiling and running JavaScript code in a V8 virtual machine context, useful for sandboxing.  
**Priority: 2**

64. What is the difference between `stream.Readable` and `stream.Writable`?
### **Answer:**
- `stream.Readable`: Base class for readable streams (data flows out).
- `stream.Writable`: Base class for writable streams (data flows in).
**Priority: 4**

65. What is the `tls` module in Node.js?
### **Answer:**
The `tls` module provides an implementation of Transport Layer Security (TLS) and Secure Socket Layer (SSL) protocols.  
**Priority: 3**

66. What is the difference between `fs.stat()` and `fs.statSync()`?
### **Answer:**
- `fs.stat()`: Asynchronous, returns file stats via callback or promise.
- `fs.statSync()`: Synchronous, returns file stats directly.
**Priority: 3**

67. What is the `punycode` module in Node.js?
### **Answer:**
The `punycode` module provides encoding and decoding of Punycode strings (used for internationalized domain names).  
**Priority: 2**

68. What is the difference between `process.stdout` and `process.stderr`?
### **Answer:**
- `process.stdout`: Standard output stream (for normal output).
- `process.stderr`: Standard error stream (for error messages).
**Priority: 3**

69. What is the `string_decoder` module in Node.js?
### **Answer:**
The `string_decoder` module provides an API for decoding `Buffer` objects into strings in a way that preserves multi-byte UTF-8 characters.  
**Priority: 2**

70. What is the difference between `require.cache` and module caching?
### **Answer:**
`require.cache` is an object that stores cached modules. When you `require()` a module, Node.js checks the cache first before loading it.  
**Priority: 3**
