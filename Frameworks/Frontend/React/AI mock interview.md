### AI Mocked Interview

### **prompt**

> Act as interviewer for tech company Here is my experience. I have more than 10 years of experience as a software
> engineer.
> i am applying for Senior Frontend Software Engineer (react , js, ts,)
> Now I want you to ask me 30 questions for react , javascript , typecript
> to cover most of the topics related to it (like oop, problem solving , best practice , testing, and any other topics
> may
> be asked for interview )
> and I want the questions to be one by one, so you ask, then I answer the question, and then you give feedback about my
> answer Your feedback should have rate my answer from 1 to 10. ,
> my strength point in my answer and my weak point , the correct answer for this question , what i need to do so that i
> can improve my answer

### **Questions**

---

1. Can you explain the difference between props and state in React?

### **Answer**

- **Props (short for properties):** are used to pass data from a parent component to a child component. They are
  read-only and
  immutable, meaning a child component cannot modify them.
- **State:** is a mutable object maintained within a component to store data that may change over the component's
  lifecycle. When the state of a component changes, it triggers a re-render to update the UI.

---

2. What are React hooks, and why are they used?

### **Answer**

React hooks are functions introduced in React 16.8 that allow developers to use state and other React features in
functional components. They eliminate the need to write class components for managing state or lifecycle events.

Some common hooks include:

- **useState:** For managing state in a functional component.
- **useEffect:** For handling side effects like API calls or subscriptions.
- **useContext:** For consuming context values directly.
- **useRef:** For accessing and interacting with DOM elements or storing mutable values.
- **useReducer:** For more complex state logic.
  Hooks make components simpler, reusable, and help avoid issues associated with class components, like confusion around
  this.

### They are used to:

- Simplify state and lifecycle management in functional components.
- Avoid the need for higher-order components (HOCs) and render props.
- Write cleaner, more maintainable code with less boilerplate.

---

3. What is the Virtual DOM in React, and how does it work?

### **Answer**

The Virtual DOM is an in-memory representation of the real DOM. When a React component's state or props change, React
updates the virtual DOM first. It then uses a process called **reconciliation** to compare the updated virtual DOM with
the
previous version. This comparison identifies the minimal set of changes (or "diffs") needed. React then updates the
actual DOM in a highly optimized way, applying only the changes.

This approach improves performance because interacting with the DOM directly is slow, and React minimizes these
operations by batching and optimizing updates.


---

4. What are keys in React, and why are they important?

### **Answer**

keys are unique identifiers assigned to elements in a list to help React identify which items have changed, been added,
or removed during updates. They are critical for React's reconciliation process to ensure that the Virtual DOM
efficiently updates the actual DOM.

Keys should be stable, predictable, and unique within their context. For example, when rendering a list of items, using
a unique property such as an id is preferred. React uses these keys to map elements to their corresponding virtual DOM
representations.

```jsx
const items = ["Apple", "Banana", "Cherry"];
return (
    <ul>
        {items.map((item, index) => (
            <li key={index}>{item}</li>
        ))}
    </ul>
);

```

---

5. What are higher-order components (HOCs) in React, and how do they work?

### **Answer**

A higher-order component (HOC) in React is a pattern where a function takes a component as an argument and returns a new
component. HOCs are used to share common logic between components without duplicating code. They allow developers to
inject props, modify behavior, or enhance components dynamically.

```jsx
function withLogging(WrappedComponent) {
    return function EnhancedComponent(props) {
        console.log("Rendered with props:", props);
        return <WrappedComponent {...props} />;
    };
}

// Usage
const ButtonWithLogging = withLogging(Button);

```

6. What are the limitations of higher-order components (HOCs)?

### Answer

Higher-order components (HOCs) have several limitations:

- **Wrapper Hell:** Using multiple HOCs can result in deeply nested wrapper components, making debugging and maintaining
  the
  component tree harder.
- **Static Method Loss:** When wrapping a component with an HOC, any static methods defined on the original component
  are
  not accessible on the wrapped component. This requires additional handling to copy these methods.
- **Props Clashing:** If the HOC injects props into the wrapped component, there might be conflicts with props already
  passed to the component.
- **Obfuscates Component Hierarchy:** HOCs can make the component hierarchy less transparent in debugging tools, as they
  add
  layers that may not correspond to the actual business logic.
- **Performance Overhead:** If not implemented efficiently, HOCs can introduce additional re-renders or unnecessary
  computations, leading to performance issues.
- **Deprecated in Some Use Cases:** With the introduction of hooks, many use cases for HOCs, such as state management or
  lifecycle methods, can now be addressed more effectively with custom hooks or context.

These limitations mean that while HOCs are still useful in some scenarios, modern React development often favors hooks
and other patterns.
---

7. What is the difference between useEffect and useLayoutEffect in React, and when would you use each?

### Answer

- **useEffect:**
    - Runs asynchronously after the browser has painted the screen.
    - It is non-blocking, meaning it doesn’t delay the rendering process.
    - Common use cases: Fetching data from an API, setting up subscriptions, and updating state based on props or data.

```jsx
useEffect(() => {
    console.log("Effect runs after rendering");
}, []);

```

- **useLayoutEffect:**
    - Runs synchronously before the browser paints the screen.
    - It blocks rendering until it finishes execution, making it suitable for operations that must be completed before
      the DOM is updated visually.
    - Common use cases: Reading layout information (e.g., DOM measurements) or making adjustments to the DOM (e.g.,
      animations).

```jsx
useLayoutEffect(() => {
    console.log("Layout effect runs before painting");
}, []);

```

---

8. What is the Context API in React, and how does it work?

### Answer

The Context API in React is a feature used to share data across components without having to pass props manually through
every level of the component tree. It simplifies the process of managing "global" data, such as themes, user
authentication, or application settings.

**How It Works:**

- Create a Context: Use React.createContext() to create a context object. This provides both a Provider and a Consumer.
- Provide the Context Value: Use the Provider component to wrap parts of your component tree and pass the value you want
  to share.
- Consume the Context: Access the context value in any child component using one of the following methods:
    - useContext Hook (preferred for functional components):
    - Context Consumer (used less often):
- Benefits
    - Avoids prop drilling, where data is passed through multiple layers of components unnecessarily.
    - Makes it easier to manage global application state.

```jsx
const ThemeContext = React.createContext();

function App() {
    return (
        <ThemeContext.Provider value="dark">
            <Toolbar/>
        </ThemeContext.Provider>
    );
}

// Consume the Context
const theme = React.useContext(ThemeContext);
// or 
<ThemeContext.Consumer>
    {(value) => <div>{value}</div>}
</ThemeContext.Consumer>

```

--- 

9. Can you explain the difference between let, const, and var in JavaScript?

### Answer

- **var:**
    * Function-scoped: Its scope is limited to the function where it’s declared, not the block.
    * Can be re-declared and updated.
    * Hoisted to the top of its scope but initialized as undefined.

```js
if (true) {
    var x = 10;
}
console.log(x); // 10

```

- **let:**
    * Block-scoped: Its scope is limited to the block in which it’s declared.
    * Can be updated but not re-declared in the same scope.
    * Hoisted but not initialized, meaning accessing it before declaration results in a ReferenceError.

```js
if (true) {
    let y = 20;
}
// console.log(y); // ReferenceError

```

- **const:**
    * Block-scoped, like let.
    * Cannot be re-assigned after initialization.
    * For objects or arrays, the reference is constant, but the contents can be modified.

```js
 const z = 30;
// z = 40; // TypeError

const arr = [1, 2, 3];
arr.push(4); // Allowed


```

--- 

10. What is the difference between == and === in JavaScript?

### Answer

- **== (Abstract Equality):**

    - Compares values for equality, performing type coercion if necessary.
    - If the operands are of different types, JavaScript attempts to convert them to a common type before comparison.

```js
console.log(5 == "5"); // true (string "5" is converted to number 5)
console.log(null == undefined); // true
console.log(false == 0); // true
```

- **=== (Strict Equality):**
  Compares both value and type, without type coercion.

```js
console.log(5 === "5"); // false (different types)
console.log(false === 0); // false (different types)
```

--- 

11. What is the purpose of JavaScript closures, and how do they work?

### Answer

Closures are a fundamental concept in JavaScript that allow a function to retain access to its lexical scope, even when
the function is executed outside of that scope.

**How Closures Work:**
When a function is defined inside another function, the inner function has access to the variables and scope of the
outer function. If the inner function is returned or passed elsewhere, it "closes over" its environment, keeping the
outer function's variables alive in memory.

```js
function outerFunction() {
    let counter = 0; // Variable in the outer scope

    return function innerFunction() {
        counter++; // Accessing the outer variable
        return counter;
    };
}

const increment = outerFunction(); // Creates a closure
console.log(increment()); // 1
console.log(increment()); // 2
console.log(increment()); // 3

```

**Purpose of Closures:**

- **Encapsulation:** Closures allow private variables and functions to be created. These cannot be accessed directly
  from the outside.
- **Callbacks:** Closures are heavily used in asynchronous operations, like setTimeout, event handlers, or promises.
- **State Preservation:** They allow a function to retain and update its state between executions

```js
function createCounter() {
    let count = 0;
    return {
        increment: () => ++count,
        decrement: () => --count,
    };
}

const counter = createCounter();
console.log(counter.increment()); // 1
console.log(counter.decrement()); // 0

```

---

12. What are "pure" functions in JavaScript, and why are they important in functional programming?

### Answer

A pure function in JavaScript is a function that satisfies the following two conditions:

- **Deterministic Output:** A pure function always returns the same output for the same input. The result does not
  depend on
  any external state or variables.
- **No Side Effects:** A pure function does not cause any side effects. This means it does not modify any external state
  or variables (such as global variables, objects, or arrays) and does not perform actions like writing to the console,
  manipulating the DOM, or making network requests.

```js
function add(a, b) {
    return a + b; // Same inputs always return the same result
}

console.log(add(2, 3)); // 5

let count = 0;

function increment() {
    count++; // Modifies external state (side effect)
    return count;
}


```

**Why Are Pure Functions Important in Functional Programming?**

* **Predictability and Testability:** Pure functions are easy to test since they always produce the same output for the
  same
  input, making them predictable.
* **Immutability:** Since pure functions don’t modify external state, they support immutable data structures, which is a
  key
  concept in functional programming.
* **Concurrency and Parallelism:** Pure functions are free from side effects, making them easier to execute in parallel
  or
  concurrently because they don’t depend on shared state.
* **Referential Transparency:** You can replace a pure function call with its result without changing the program’s
  behavior, which is helpful for optimizations and reasoning about code.

---

13. What is the difference between synchronous and asynchronous code in JavaScript, and how does JavaScript handle
    asynchronous operations?

### Answer

In JavaScript, the distinction between synchronous and asynchronous code is important for understanding how the
execution flow works, especially in non-blocking environments like web browsers.

- **Synchronous Code:**
    - Definition: Synchronous code executes sequentially, meaning each operation is completed before the next one
      begins. If a function takes time to complete (e.g., a lengthy computation or an I/O operation), the entire program
      waits for it to finish before moving on to the next task. This can lead to performance issues when dealing with
      time-consuming tasks.
    - Example of Synchronous Code:

```js
console.log("Start");
console.log("Middle");
console.log("End");

```

- **Asynchronous Code:**
    - Definition: Asynchronous code allows certain operations to be executed independently, meaning the program can
      continue executing other tasks while waiting for an asynchronous operation (e.g., fetching data, reading a file)
      to complete. This is essential for tasks like network requests or I/O operations, where you don't want the entire
      program to freeze while waiting for results.
    - Example of Asynchronous Code:

```js
console.log("Start");

setTimeout(() => {
    console.log("Middle"); // This is asynchronous
}, 1000);

console.log("End"); // This executes before "Middle"
// start
// end
// middle
```

**How JavaScript Handles Asynchronous Operations:**

JavaScript handles asynchronous operations using the Event Loop and Callback Queue.

- **Event Loop:** The event loop continuously checks whether the call stack is empty. If it's empty, the event loop
  takes the first callback from the queue and pushes it onto the call stack for execution.
- **Call Stack:** This is where JavaScript keeps track of function calls. Each function call is placed on the stack, and
  when a function finishes, it is removed from the stack.
- **Callback Queue (or Task Queue):** If an asynchronous operation completes (e.g., setTimeout, network request), its
  associated callback is placed in the callback queue, waiting for the call stack to be empty before it’s executed.

**Promises and Async/Await (Modern JavaScript for Asynchronous Code):**

- **Promises:** A Promise represents a value that might be available now, or in the future, or never. It has 3 states:
    - Pending: The initial state, before the operation completes.
    - Resolved (Fulfilled): The operation completed successfully.
    - Rejected: The operation failed.

```js
let fetchData = new Promise((resolve, reject) => {
    let success = true;
    if (success) {
        resolve("Data fetched!");
    } else {
        reject("Error fetching data");
    }
});

fetchData
    .then(result => console.log(result)) // "Data fetched!"
    .catch(error => console.log(error));

```

- **Async/Await:** async and await allow writing asynchronous code that looks synchronous, making it easier to read and
  work with promises.

```js
async function fetchData() {
    let success = true;
    if (success) {
        return "Data fetched!";
    } else {
        throw new Error("Error fetching data");
    }
}

async function main() {
    try {
        const result = await fetchData();
        console.log(result); // "Data fetched!"
    } catch (error) {
        console.log(error.message); // "Error fetching data"
    }
}

main();

```

- **Event Loop Flow (with Example):**
    - Execution flow:

        - "Start" is logged first (synchronous).
        - setTimeout is an asynchronous operation, so it’s placed in the callback queue after 0 milliseconds, meaning it
          waits for the call stack to be empty.
        - "End" is logged next (synchronous).
        - After the call stack is clear, the callback from setTimeout is picked up from the callback queue, and "Inside
          setTimeout" is logged.

```js
console.log("Start");

setTimeout(() => {
    console.log("Inside setTimeout"); // This is an asynchronous operation
}, 0);

console.log("End");
// start
// end
// Inside setTimeout
```
