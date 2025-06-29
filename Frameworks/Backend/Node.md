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
