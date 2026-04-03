# 🌀 The Master Guide to Node.js Event Loop & libuv (Complete Edition)

This guide is the definitive resource for mastering the Node.js Event Loop. It covers the internal architecture, the priority of different queues, and provides **14 detailed experiments** to prove exactly how Node.js handles asynchronous code.

---

## 🏗️ 1. The Core Architecture: V8 & libuv

Node.js is built on two primary pillars that allow it to handle high-performance, non-blocking I/O despite being single-threaded for JavaScript execution.

| Component | Responsibility | Language |
| :--- | :--- | :--- |
| **V8 Engine** | Developed by Google. It parses, compiles, and executes JavaScript code. | C++ / JS |
| **libuv** | A C library that provides the Event Loop and the Thread Pool. It manages all async I/O. | C |

![Event Loop Overview](https://files.manuscdn.com/user_upload_by_module/session_file/118300436/gaBOUfYhTwjVXbrw.png)

---

## 🔄 2. The Event Loop Phases

The Event Loop follows a strict sequence. Between **every single callback** in these phases, Node.js checks the **Microtask Queues**.
![Event Loop Phases](https://statics.cdn.200lab.io/2024/07/event-loop-trong-nodejs.png?width=1200)

![Event Loop Phases](https://files.manuscdn.com/user_upload_by_module/session_file/118300436/ZnnaftBHicHTMTqi.png)

### The 6 Major Phases
1.  **Timers:** `setTimeout` and `setInterval` callbacks.
2.  **Pending Callbacks:** System-related callbacks (e.g., TCP errors).
3.  **Idle, Prepare:** Internal use only.
4.  **Poll:** Retrieve new I/O events; execute I/O callbacks.
5.  **Check:** `setImmediate` callbacks.
6.  **Close Callbacks:** `socket.on('close', ...)` callbacks.

---

## ⚡ 3. The Microtask Queues (VIP Priority)

Microtasks are executed **immediately** after the current operation finishes, before the event loop moves to the next phase or even the next callback in the same phase.

1.  **`process.nextTick` Queue:** The absolute highest priority.
2.  **Promise Queue:** Executed after the `nextTick` queue is empty.

![Microtask vs Macrotask](https://files.manuscdn.com/user_upload_by_module/session_file/118300436/zBykzgcBpbxlsQXl.jpg)

---

## 🧪 4. The 14 Master Experiments

These experiments demonstrate the precise rules of the Node.js runtime.

### 1. Synchronous Code Priority
Synchronous code always runs first, blocking any async execution until the call stack is empty.
```javascript
console.log("console.log 1");
process.nextTick(() => console.log("this is process.nextTick 1"));
console.log("console.log 2");
// Output: log 1 -> log 2 -> nextTick 1
```

### 2. `nextTick` vs. Promises
The `nextTick` queue is always exhausted before the Promise queue.
```javascript
process.nextTick(() => console.log("nextTick 1"));
process.nextTick(() => {
  console.log("nextTick 2");
  process.nextTick(() => console.log("inner nextTick"));
});
Promise.resolve().then(() => console.log("Promise 1"));
// Output: nextTick 1 -> nextTick 2 -> inner nextTick -> Promise 1
```

### 3. Microtasks vs. Timer Queue
Microtasks (nextTick + Promises) run before the first timer callback.
```javascript
setTimeout(() => console.log("setTimeout 1"), 0);
process.nextTick(() => console.log("nextTick 1"));
Promise.resolve().then(() => console.log("Promise 1"));
// Output: nextTick 1 -> Promise 1 -> setTimeout 1
```

### 4. Microtask Interleaving in Timers
Microtasks are checked between individual callbacks in the timer queue.
```javascript
setTimeout(() => console.log("setTimeout 1"), 0);
setTimeout(() => {
  console.log("setTimeout 2");
  process.nextTick(() => console.log("inner nextTick inside setTimeout"));
}, 0);
setTimeout(() => console.log("setTimeout 3"), 0);
// Output: setTimeout 1 -> setTimeout 2 -> inner nextTick -> setTimeout 3
```

### 5. Timer FIFO Order
Timers with the same delay are executed in the order they were registered.
```javascript
setTimeout(() => console.log("setTimeout 1"), 1000);
setTimeout(() => console.log("setTimeout 2"), 500);
setTimeout(() => console.log("setTimeout 3"), 0);
// Output: 3 (0ms) -> 2 (500ms) -> 1 (1000ms)
```

### 6. Microtasks vs. I/O Queue
Microtasks run before I/O callbacks.
```javascript
const fs = require("fs");
fs.readFile(__filename, () => console.log("readFile 1"));
process.nextTick(() => console.log("nextTick 1"));
// Output: nextTick 1 -> readFile 1
```

### 7. Timer Anomaly (Top-Level)
The order between `setTimeout(0)` and `setImmediate` at the top level is non-deterministic.
```javascript
setTimeout(() => console.log("setTimeout 1"), 0);
setImmediate(() => console.log("setImmediate 1"));
// Output: Unpredictable (depends on machine performance)
```

### 8. I/O vs. Timers & Microtasks
I/O callbacks run after microtasks and expired timers.
```javascript
fs.readFile(__filename, () => console.log("readFile 1"));
process.nextTick(() => console.log("nextTick 1"));
setTimeout(() => console.log("setTimeout 1"), 0);
for (let i = 0; i < 1000000000; i++) {} // Block to ensure timer expires
// Output: nextTick 1 -> setTimeout 1 -> readFile 1
```

### 9. I/O Polling Behavior
I/O events are polled only after the current phase finishes.
```javascript
fs.readFile(__filename, () => console.log("readFile 1"));
setTimeout(() => console.log("setTimeout 1"), 0);
setImmediate(() => console.log("setImmediate 1"));
for (let i = 0; i < 2000000000; i++) {}
// Output: nextTick -> setTimeout -> setImmediate -> readFile
```

### 10. Check Queue Priority
`setImmediate` (Check Queue) runs after the I/O phase.
```javascript
fs.readFile(__filename, () => {
  console.log("readFile 1");
  setImmediate(() => console.log("inner setImmediate"));
});
setTimeout(() => console.log("setTimeout 1"), 0);
// Output: setTimeout 1 -> readFile 1 -> inner setImmediate
```

### 11. Microtasks inside I/O
Microtasks inside an I/O callback run before the Check phase (`setImmediate`).
```javascript
fs.readFile(__filename, () => {
  console.log("readFile 1");
  setImmediate(() => console.log("inner setImmediate"));
  process.nextTick(() => console.log("inner nextTick"));
});
// Output: readFile 1 -> inner nextTick -> inner setImmediate
```

### 12. Microtask Interleaving in Check Queue
Microtasks are checked between individual `setImmediate` callbacks.
```javascript
setImmediate(() => console.log("setImmediate 1"));
setImmediate(() => {
  console.log("setImmediate 2");
  process.nextTick(() => console.log("process.nextTick 1"));
});
setImmediate(() => console.log("setImmediate 3"));
// Output: setImmediate 1 -> setImmediate 2 -> nextTick 1 -> setImmediate 3
```

### 13. Guaranteeing Timer vs. Immediate
Adding a small delay or blocking code can sometimes make the top-level order deterministic.
```javascript
setTimeout(() => console.log("setTimeout 1"), 0);
setImmediate(() => console.log("setImmediate 1"));
for (let i = 0; i < 1000000000; i++) {} // Forces timer to be ready
// Output: setTimeout 1 -> setImmediate 1
```

### 14. Close Queue Priority
The Close queue is the very last phase of the event loop.
```javascript
const readableStream = fs.createReadStream(__filename);
readableStream.close();
readableStream.on("close", () => console.log("close event"));
setImmediate(() => console.log("setImmediate 1"));
setTimeout(() => console.log("setTimeout 1"), 0);
process.nextTick(() => console.log("nextTick 1"));
// Output: nextTick 1 -> setTimeout 1 -> setImmediate 1 -> close event
```

---

## 🧵 5. libuv Thread Pool vs. OS Kernel

![libuv Thread Pool](https://files.manuscdn.com/user_upload_by_module/session_file/118300436/EyvEvsvgrdimmEpz.png)

*   **OS Kernel:** Handles Network I/O (epoll/kqueue). Extremely efficient.
*   **Thread Pool:** Handles File I/O, Crypto, and DNS lookup. Default size is 4.
    *   *Tip:* Increase with `process.env.UV_THREADPOOL_SIZE = 16`.

---

## 🎓 6. Summary Flowchart

1.  **Sync Code**
2.  **Microtasks** (nextTick -> Promises)
3.  **Timers** (Check microtasks after each)
4.  **I/O Callbacks** (Check microtasks after each)
5.  **Check Phase** (setImmediate - Check microtasks after each)
6.  **Close Phase** (Check microtasks after each)

---
*Master the Loop, Master Node.js.*
