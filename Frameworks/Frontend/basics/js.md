
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

## 11. What are Promises in JavaScript?

**Answer:**
Promises are objects that represent the eventual completion (or failure) of an asynchronous operation. They provide a cleaner way to handle asynchronous code compared to callbacks.

### Example:
```javascript
const promise = new Promise((resolve, reject) => {
    setTimeout(() => {
        resolve("Success!");
    }, 1000);
});

promise.then(result => console.log(result))
       .catch(error => console.error(error));
```

## 12. What is `async/await` in JavaScript?

**Answer:**
`async/await` is syntactic sugar built on top of Promises that makes asynchronous code look and behave more like synchronous code.

### Example:
```javascript
async function fetchData() {
    try {
        const response = await fetch('https://api.example.com/data');
        const data = await response.json();
        return data;
    } catch (error) {
        console.error('Error:', error);
    }
}
```

## 13. What is the difference between `call()`, `apply()`, and `bind()` in JavaScript?

**Answer:**
- **`call()`**: Invokes a function with a specified `this` value and arguments provided individually.
- **`apply()`**: Similar to `call()`, but arguments are provided as an array.
- **`bind()`**: Returns a new function with a specified `this` value and arguments, but doesn't invoke it immediately.

### Example:
```javascript
const person = {
    name: "John",
    greet: function(greeting, punctuation) {
        console.log(`${greeting}, I'm ${this.name}${punctuation}`);
    }
};

const anotherPerson = { name: "Jane" };

// call - arguments individually
person.greet.call(anotherPerson, "Hello", "!");

// apply - arguments as array
person.greet.apply(anotherPerson, ["Hi", "!"]);

// bind - returns new function
const boundGreet = person.greet.bind(anotherPerson);
boundGreet("Hey", "!");
```

## 14. What are arrow functions in JavaScript?

**Answer:**
Arrow functions are a shorter syntax for writing function expressions. They don't have their own `this`, `arguments`, `super`, or `new.target` bindings.

### Example:
```javascript
// Regular function
function add(a, b) {
    return a + b;
}

// Arrow function
const add = (a, b) => a + b;

// Arrow function with single parameter
const square = x => x * x;

// Arrow function with no parameters
const greet = () => "Hello!";
```

## 15. What is the difference between `map()`, `filter()`, and `reduce()` in JavaScript?

**Answer:**
- **`map()`**: Creates a new array by calling a function on every element in the original array.
- **`filter()`**: Creates a new array with elements that pass a test function.
- **`reduce()`**: Reduces an array to a single value by executing a reducer function on each element.

### Example:
```javascript
const numbers = [1, 2, 3, 4, 5];

// map - transform each element
const doubled = numbers.map(n => n * 2); // [2, 4, 6, 8, 10]

// filter - select elements
const evens = numbers.filter(n => n % 2 === 0); // [2, 4]

// reduce - accumulate to single value
const sum = numbers.reduce((acc, n) => acc + n, 0); // 15
```

## 16. What is destructuring in JavaScript?

**Answer:**
Destructuring is a syntax that allows you to extract values from arrays or properties from objects into distinct variables.

### Example:
```javascript
// Array destructuring
const [first, second, third] = [1, 2, 3];

// Object destructuring
const { name, age } = { name: "John", age: 30 };

// With default values
const { name, age = 25 } = { name: "John" };

// Nested destructuring
const { user: { name, email } } = { user: { name: "John", email: "john@example.com" } };
```

## 17. What is the spread operator (`...`) in JavaScript?

**Answer:**
The spread operator allows an iterable (like an array or string) to be expanded in places where zero or more arguments or elements are expected.

### Example:
```javascript
// Spread in arrays
const arr1 = [1, 2, 3];
const arr2 = [...arr1, 4, 5]; // [1, 2, 3, 4, 5]

// Spread in objects
const obj1 = { a: 1, b: 2 };
const obj2 = { ...obj1, c: 3 }; // { a: 1, b: 2, c: 3 }

// Spread in function calls
Math.max(...[1, 2, 3, 4]); // 4
```

## 18. What is the rest parameter in JavaScript?

**Answer:**
The rest parameter allows a function to accept an indefinite number of arguments as an array.

### Example:
```javascript
function sum(...numbers) {
    return numbers.reduce((acc, num) => acc + num, 0);
}

sum(1, 2, 3, 4); // 10
```

## 19. What is the difference between `null` and `undefined`?

**Answer:**
- **`null`**: An intentional absence of value. It's a value that represents "no value" or "empty value". It's an assignment value.
- **`undefined`**: A variable that has been declared but not assigned a value. It's the default value for uninitialized variables.

### Example:
```javascript
let a; // undefined
let b = null; // null

typeof undefined; // "undefined"
typeof null; // "object" (this is a bug in JavaScript)

null === undefined; // false
null == undefined; // true (loose equality)
```

## 20. What is `typeof` operator in JavaScript?

**Answer:**
The `typeof` operator returns a string indicating the type of the unevaluated operand.

### Example:
```javascript
typeof 42; // "number"
typeof "hello"; // "string"
typeof true; // "boolean"
typeof undefined; // "undefined"
typeof null; // "object" (known bug)
typeof {}; // "object"
typeof []; // "object"
typeof function(){}; // "function"
```

## 21. What is `instanceof` operator in JavaScript?

**Answer:**
The `instanceof` operator tests whether an object is an instance of a constructor function or class.

### Example:
```javascript
class Animal {}
class Dog extends Animal {}

const dog = new Dog();

dog instanceof Dog; // true
dog instanceof Animal; // true
dog instanceof Object; // true
```

## 22. What is the difference between `slice()` and `splice()` in JavaScript?

**Answer:**
- **`slice()`**: Returns a shallow copy of a portion of an array without modifying the original array.
- **`splice()`**: Changes the contents of an array by removing or replacing existing elements and/or adding new elements in place.

### Example:
```javascript
const arr = [1, 2, 3, 4, 5];

// slice - doesn't modify original
const sliced = arr.slice(1, 3); // [2, 3]
console.log(arr); // [1, 2, 3, 4, 5] (unchanged)

// splice - modifies original
const spliced = arr.splice(1, 2, 6, 7); // [2, 3]
console.log(arr); // [1, 6, 7, 4, 5] (modified)
```

## 23. What is the difference between `forEach()` and `map()` in JavaScript?

**Answer:**
- **`forEach()`**: Executes a function for each array element. It doesn't return a new array (returns `undefined`).
- **`map()`**: Creates a new array by calling a function on every element. It returns a new array.

### Example:
```javascript
const numbers = [1, 2, 3];

// forEach - side effects only
const result1 = numbers.forEach(n => console.log(n * 2)); // undefined

// map - returns new array
const result2 = numbers.map(n => n * 2); // [2, 4, 6]
```

## 24. What is `JSON.stringify()` and `JSON.parse()` in JavaScript?

**Answer:**
- **`JSON.stringify()`**: Converts a JavaScript object or value to a JSON string.
- **`JSON.parse()`**: Parses a JSON string and constructs the JavaScript value or object described by the string.

### Example:
```javascript
const obj = { name: "John", age: 30 };

// stringify - object to string
const jsonString = JSON.stringify(obj); // '{"name":"John","age":30}'

// parse - string to object
const parsedObj = JSON.parse(jsonString); // { name: "John", age: 30 }
```

## 25. What is the difference between `setTimeout()` and `setInterval()` in JavaScript?

**Answer:**
- **`setTimeout()`**: Executes a function once after a specified delay.
- **`setInterval()`**: Executes a function repeatedly at specified intervals.

### Example:
```javascript
// setTimeout - runs once
setTimeout(() => {
    console.log("This runs once after 1 second");
}, 1000);

// setInterval - runs repeatedly
const intervalId = setInterval(() => {
    console.log("This runs every 1 second");
}, 1000);

// Clear interval
clearInterval(intervalId);
```

## 26. What is `this` binding in JavaScript?

**Answer:**
The value of `this` depends on how a function is called:
- **Global context**: `this` refers to the global object (window in browser, global in Node.js).
- **Object method**: `this` refers to the object that owns the method.
- **Constructor**: `this` refers to the newly created instance.
- **Arrow functions**: `this` is lexically bound (inherited from enclosing scope).

### Example:
```javascript
// Global context
console.log(this); // window (in browser)

// Object method
const obj = {
    name: "John",
    greet: function() {
        return `Hello, I'm ${this.name}`;
    }
};
obj.greet(); // "Hello, I'm John"

// Arrow function (lexical this)
const obj2 = {
    name: "John",
    greet: () => {
        return `Hello, I'm ${this.name}`; // this is window, not obj2
    }
};
```

## 27. What is the difference between `let`, `const`, and `var` in terms of hoisting?

**Answer:**
- **`var`**: Hoisted and initialized with `undefined`. Can be accessed before declaration (returns `undefined`).
- **`let` and `const`**: Hoisted but not initialized. Accessing before declaration causes a `ReferenceError` (Temporal Dead Zone).

### Example:
```javascript
// var - hoisted and initialized
console.log(x); // undefined (not an error)
var x = 5;

// let/const - hoisted but not initialized
console.log(y); // ReferenceError: Cannot access 'y' before initialization
let y = 5;
```

## 28. What are template literals in JavaScript?

**Answer:**
Template literals are string literals that allow embedded expressions and multi-line strings. They use backticks (`` ` ``) instead of quotes.

### Example:
```javascript
const name = "John";
const age = 30;

// Template literal with expressions
const message = `Hello, my name is ${name} and I'm ${age} years old.`;

// Multi-line strings
const multiLine = `
    This is
    a multi-line
    string
`;
```

## 29. What is the difference between `==` and `===` in detail?

**Answer:**
- **`==` (loose equality)**: Performs type coercion before comparison. Converts operands to the same type before comparing.
- **`===` (strict equality)**: No type coercion. Returns `true` only if both operands are of the same type and have the same value.

### Example:
```javascript
5 == "5"; // true (type coercion)
5 === "5"; // false (different types)

null == undefined; // true
null === undefined; // false

0 == false; // true
0 === false; // false

"" == false; // true
"" === false; // false
```

## 30. What is the difference between `Object.assign()` and spread operator for object copying?

**Answer:**
Both can copy objects, but:
- **`Object.assign()`**: Copies properties from source objects to a target object. Modifies the target object.
- **Spread operator**: Creates a new object with copied properties. Doesn't modify existing objects.

### Example:
```javascript
const obj1 = { a: 1, b: 2 };
const obj2 = { c: 3 };

// Object.assign - modifies target
const copied1 = Object.assign({}, obj1, obj2); // { a: 1, b: 2, c: 3 }

// Spread operator - creates new object
const copied2 = { ...obj1, ...obj2 }; // { a: 1, b: 2, c: 3 }
```

## 31. What is `Array.from()` in JavaScript?

**Answer:**
`Array.from()` creates a new array from an array-like or iterable object.

### Example:
```javascript
// From string
Array.from("hello"); // ["h", "e", "l", "l", "o"]

// From array-like object
Array.from({ length: 5 }, (_, i) => i); // [0, 1, 2, 3, 4]

// From Set
Array.from(new Set([1, 2, 2, 3])); // [1, 2, 3]
```

## 32. What is the difference between `some()` and `every()` in JavaScript?

**Answer:**
- **`some()`**: Returns `true` if at least one element passes the test function.
- **`every()`**: Returns `true` only if all elements pass the test function.

### Example:
```javascript
const numbers = [1, 2, 3, 4, 5];

numbers.some(n => n > 3); // true (at least one is > 3)
numbers.every(n => n > 3); // false (not all are > 3)
```

## 33. What is `Object.freeze()` in JavaScript?

**Answer:**
`Object.freeze()` freezes an object, preventing new properties from being added, existing properties from being removed, and preventing changes to property values.

### Example:
```javascript
const obj = { name: "John", age: 30 };
Object.freeze(obj);

obj.name = "Jane"; // No effect (in strict mode, throws error)
obj.city = "NYC"; // No effect
delete obj.age; // No effect

console.log(obj); // { name: "John", age: 30 } (unchanged)
```

## 34. What is the difference between `Object.keys()`, `Object.values()`, and `Object.entries()`?

**Answer:**
- **`Object.keys()`**: Returns an array of a given object's own enumerable property names.
- **`Object.values()`**: Returns an array of a given object's own enumerable property values.
- **`Object.entries()`**: Returns an array of a given object's own enumerable string-keyed property [key, value] pairs.

### Example:
```javascript
const obj = { a: 1, b: 2, c: 3 };

Object.keys(obj); // ["a", "b", "c"]
Object.values(obj); // [1, 2, 3]
Object.entries(obj); // [["a", 1], ["b", 2], ["c", 3]]
```

## 35. What is `Array.isArray()` in JavaScript?

**Answer:**
`Array.isArray()` determines whether the passed value is an Array.

### Example:
```javascript
Array.isArray([1, 2, 3]); // true
Array.isArray("hello"); // false
Array.isArray({}); // false
Array.isArray(null); // false
```

## 36. What is the difference between `find()` and `findIndex()` in JavaScript?

**Answer:**
- **`find()`**: Returns the first element that satisfies the test function, or `undefined` if not found.
- **`findIndex()`**: Returns the index of the first element that satisfies the test function, or `-1` if not found.

### Example:
```javascript
const numbers = [1, 2, 3, 4, 5];

numbers.find(n => n > 3); // 4
numbers.findIndex(n => n > 3); // 3
```

## 37. What is `Array.includes()` in JavaScript?

**Answer:**
`Array.includes()` determines whether an array includes a certain value, returning `true` or `false`.

### Example:
```javascript
const arr = [1, 2, 3, 4, 5];

arr.includes(3); // true
arr.includes(6); // false
arr.includes(3, 3); // false (starts searching from index 3)
```

## 38. What is the difference between `shift()` and `unshift()` in JavaScript?

**Answer:**
- **`shift()`**: Removes the first element from an array and returns it. Modifies the original array.
- **`unshift()`**: Adds one or more elements to the beginning of an array. Modifies the original array.

### Example:
```javascript
const arr = [2, 3, 4];

arr.shift(); // returns 2, arr is now [3, 4]
arr.unshift(1); // arr is now [1, 3, 4]
```

## 39. What is the difference between `pop()` and `push()` in JavaScript?

**Answer:**
- **`pop()`**: Removes the last element from an array and returns it. Modifies the original array.
- **`push()`**: Adds one or more elements to the end of an array. Modifies the original array.

### Example:
```javascript
const arr = [1, 2, 3];

arr.pop(); // returns 3, arr is now [1, 2]
arr.push(4); // arr is now [1, 2, 4]
```

## 40. What is `Array.flat()` and `Array.flatMap()` in JavaScript?

**Answer:**
- **`flat()`**: Creates a new array with all sub-array elements concatenated into it recursively up to the specified depth.
- **`flatMap()`**: First maps each element using a mapping function, then flattens the result into a new array.

### Example:
```javascript
const arr = [1, [2, 3], [4, [5, 6]]];

arr.flat(); // [1, 2, 3, 4, [5, 6]]
arr.flat(2); // [1, 2, 3, 4, 5, 6]

const arr2 = [1, 2, 3];
arr2.flatMap(x => [x, x * 2]); // [1, 2, 2, 4, 3, 6]
```
