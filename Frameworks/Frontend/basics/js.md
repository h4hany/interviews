
# Javascript:

## 1- **What are the different data types in JavaScript?**

JavaScript has six primitive data types:

- Number
- String
- Boolean
- Null
- Undefined
- Symbol

It also has two compound data types:

- Object
- Array

## **2- What is hoisting in JavaScript?**

- Hoisting is a JavaScript concept that refers to the process of moving declarations to the top of their scope.

## 3- **What is the difference between null and undefined?**

- `null`******is an assignment value that
  represents[no value](https://builtin.com/software-engineering-perspectives/javascript-null-check)or
  an[empty value](https://builtin.com/software-engineering-perspectives/javascript-check-if-object-is-empty),
  while`undefined`is a variable that has been declared but not assigned a value.

## **4- What is the purpose of the “this” **keyword in JavaScript?**

- The`this`keyword refers to the object that is executing the current function or method. It allows access to object
  properties and methods within the context of that object.

## **5- What is the difference between == and === operators in JavaScript?**

- The equality`==`operator is a comparison operator that compares two values and returns true if they are equal. The
  strict equality`===`operator is also a comparison operator, but it compares two values and returns true only if they
  are equal and of the same type.

## 6- **What is the difference between “var” and “let” and “const” keywords in JavaScript?**

- Var:
    - Scope:
        - `var` is **function-scoped** or **globally-scoped**. If declared inside a function, it is limited to that
          function. If declared outside any function, it becomes globally available.
        - It is **not block-scoped**, meaning it can be accessed outside of `{}` blocks like `if`, `for`, etc.
    - Hoisting:
        - Variables declared with `var` are **hoisted** to the top of their scope but initialized as `undefined` until
          the code executes. This means you can reference a `var` variable before it is actually declared (but its value
          will be `undefined`).
    - Reassignment:
        - `var` variables can be **redeclared** and **reassigned** within the same scope.
- Let:
    - Scope:
        - `let` is **block-scoped**. It means the variable declared with `let` is only accessible within the block it is
          defined in (inside `{}`).
    - Hoisting:
        - Like `var`, `let` is also hoisted to the top of its block, but **unlike `var`, it is not initialized**.
          Accessing it before the declaration results in a **`ReferenceError`**. This period between hoisting and
          initialization is called the **"temporal dead zone"**.
    - Reassignment:
        - `let` can be **reassigned**, but it **cannot be redeclared** in the same block scope.
- Const:
    - Scope:
        - Like `let`, `const` is also **block-scoped**.
    - Hoisting:
        - `const` is hoisted to the top of its block but remains in the **temporal dead zone** until it is initialized.
          Accessing it before the declaration results in a **`ReferenceError`**.
    - Reassignment:
        - Variables declared with `const` **cannot be reassigned** after their initial assignment. However, if a `const`
          holds an **object** or **array**, the properties or elements of the object or array can still be modified (but
          the reference to the object or array cannot change).
    - **Capacity**: Local Storage has a larger storage capacity compared to cookies. Most modern browsers allow up to *
      *5-10MB** per origin (domain).

## 7- **What are closures in JavaScript ?**

- Closures (`closureFn`) are functions that have access to variables from an outer function even after the outer
  function has finished executing. They “remember” the environment in which they were created.

## **8- What is recursion in JavaScript ?**

- Recursion is a programming technique that allows a function to call itself. Recursion can be used to solve a variety
  of problems, such as finding the factorial of a number or calculating
  the[Fibonacci sequence](https://builtin.com/data-science/fibonacci-sequence).

## 9- Local Storage vs Session Storage vs Cookies

- Local Storage:
    - **Expiration**: Data in Local Storage **persists indefinitely** unless explicitly deleted by JavaScript or the
      user (e.g., clearing browser cache). It does **not expire** when the browser is closed.
    - **Scope**: Local Storage is **scoped per origin** (protocol + domain + port). Data stored here can only be
      accessed by pages from the same origin.
    - **Accessibility**: Local Storage is only accessible by **JavaScript** running in the browser. It is not sent to
      the server with HTTP requests like cookies.
- Session Storage:
    - **Capacity**: Similar to Local Storage, with most browsers allowing **5-10MB** per origin.
    - **Expiration**: Data in Session Storage is **only available for the duration of the page session**. Once the
      browser or tab is closed, the data is deleted.
    - **Scope**: Session Storage is also scoped per origin but is **specific to each tab or window**. This means the
      data is not shared across different tabs or windows, even if they are from the same origin.
    - **Accessibility**: Like Local Storage, Session Storage is only accessible by **JavaScript** on the client side and
      is not sent to the server.
- Cookies:
    - **Capacity**: Cookies have a much smaller capacity, typically limited to **4KB** per cookie. However, there is no
      strict limit on the number of cookies, though the total size across all cookies is limited.
    - **Expiration**: Cookies have an optional `expires` or `max-age` attribute. If not set, cookies will last only for
      the **duration of the session** (similar to Session Storage). If an expiration is set, the cookie will persist
      until that date, even after the browser is closed.
    - **Scope**: Cookies are **sent with every HTTP request** to the server, making them useful for things like
      authentication or tracking. They can be scoped to a specific **domain** and **path** and can be made accessible
      across **subdomains**.
    - **Accessibility**: Cookies are accessible to both **JavaScript** (unless the `HttpOnly` flag is set, which makes
      them accessible only to the server) and the **server** (sent automatically with every HTTP request). Cookies also
      support attributes like `Secure` (only sent over HTTPS) and `SameSite` (controls cross-site request behavior).

## 10- What is Event Loop ?!

The event loop in JavaScript is a mechanism that allows asynchronous tasks to be processed alongside synchronous code,
enabling JavaScript to manage tasks like handling user interactions, network requests, timers, and more in a
non-blocking way. This is essential because JavaScript is single-threaded, meaning it executes one task at a time on a
single call stack.

Here’s a step-by-step breakdown of how the event loop works:

1. **Call Stack**: When JavaScript code is executed, it’s processed line by line, and each function call is added to the
   call stack. The stack is a Last In, First Out (LIFO) data structure, meaning the most recent function added will be
   the first one removed.
2. **Web APIs**: Certain functions, like `setTimeout`, `fetch`, or `DOM events`, don’t go directly onto the call stack.
   Instead, they are passed to the browser's Web APIs, which manage asynchronous tasks like timing, network requests,
   and handling events outside the main JavaScript thread.
3. **Task Queue / Callback Queue**: Once a Web API task completes (e.g., a `fetch` request finishes, or a timer
   expires), the callback associated with it (like the `then` function for a promise) is moved to the task queue. This
   queue is a First In, First Out (FIFO) data structure, where tasks are handled in the order they are added.
4. **Event Loop**: The event loop continuously checks the call stack to see if it’s empty. If it is, the event loop
   pushes the next task from the task queue onto the call stack for execution. This process repeats indefinitely,
   allowing JavaScript to manage asynchronous tasks smoothly.
5. **Microtask Queue**: Promises and certain other high-priority tasks are added to a separate microtask queue. The
   event loop first clears the microtask queue before moving on to the task queue, ensuring that promises and other
   microtasks are processed as soon as possible.

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/addb9cd1-9c34-42b6-b1c1-31f575c62c3f/e6711297-4f5b-478b-958c-7ad62cd238a1/image.png)

- Order of operations:
    - When calling`bar`, a first frame is created containing references to`bar`'s arguments and local variables.
    - When`bar`calls`foo`, a second frame is created and pushed on top of the first one, containing references to`foo`'s
      arguments and local variables.
    - When`foo`returns, the top frame element is popped out of the stack (leaving only`bar`'s call frame).
    - When`bar`returns, the stack is empty.
