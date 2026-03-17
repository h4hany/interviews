# React Interview Questions

## 1. What is React?

**Answer:**
React is a JavaScript library for building user interfaces, particularly web applications. It was developed by Facebook and allows developers to create reusable UI components.

## 2. What are the main features of React?

**Answer:**
- **Component-based architecture**: Build encapsulated components that manage their own state
- **Virtual DOM**: Efficient rendering by updating only changed parts
- **JSX**: JavaScript syntax extension for writing HTML-like code
- **Unidirectional data flow**: Data flows down from parent to child components
- **React Hooks**: Functions that let you use state and lifecycle features in functional components

## 3. What is JSX?

**Answer:**
JSX (JavaScript XML) is a syntax extension that allows you to write HTML-like code in JavaScript. It gets transpiled to `React.createElement()` calls.

### Example:
```jsx
const element = <h1>Hello, World!</h1>;
```

## 4. What is the difference between functional and class components?

**Answer:**
- **Functional Components**: Simple JavaScript functions that return JSX. Use hooks for state and lifecycle.
- **Class Components**: ES6 classes that extend `React.Component`. Use `this.state` and lifecycle methods.

### Example:
```jsx
// Functional Component
function Welcome(props) {
  return <h1>Hello, {props.name}</h1>;
}

// Class Component
class Welcome extends React.Component {
  render() {
    return <h1>Hello, {this.props.name}</h1>;
  }
}
```

## 5. What are React Hooks?

**Answer:**
Hooks are functions that let you "hook into" React state and lifecycle features from functional components. They were introduced in React 16.8.

### Common Hooks:
- `useState`: Manages component state
- `useEffect`: Handles side effects and lifecycle
- `useContext`: Accesses React context
- `useReducer`: Alternative to useState for complex state
- `useMemo`: Memoizes computed values
- `useCallback`: Memoizes functions

## 6. What is `useState` hook?

**Answer:**
`useState` is a hook that allows you to add state to functional components. It returns an array with the current state value and a function to update it.

### Example:
```jsx
import { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0);
  
  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
    </div>
  );
}
```

## 7. What is `useEffect` hook?

**Answer:**
`useEffect` lets you perform side effects in functional components. It's similar to `componentDidMount`, `componentDidUpdate`, and `componentWillUnmount` combined.

### Example:
```jsx
import { useState, useEffect } from 'react';

function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  
  useEffect(() => {
    fetch(`/api/users/${userId}`)
      .then(res => res.json())
      .then(data => setUser(data));
  }, [userId]); // Runs when userId changes
  
  return <div>{user?.name}</div>;
}
```

## 8. What is the difference between `useEffect` with and without dependencies?

**Answer:**
- **Without dependencies `[]`**: Runs once after the first render (like `componentDidMount`).
- **With dependencies `[dep1, dep2]`**: Runs when dependencies change (like `componentDidUpdate`).
- **Without dependency array**: Runs on every render (can cause infinite loops).

### Example:
```jsx
// Runs once
useEffect(() => {
  console.log('Component mounted');
}, []);

// Runs when userId changes
useEffect(() => {
  fetchUser(userId);
}, [userId]);

// Runs on every render (avoid this)
useEffect(() => {
  console.log('Rendered');
});
```

## 9. What is the Virtual DOM?

**Answer:**
The Virtual DOM is a JavaScript representation of the real DOM. React uses it to efficiently update the UI by comparing the virtual DOM with the previous version and only updating the changed parts (reconciliation).

## 10. What is the difference between props and state?

**Answer:**
- **Props**: Data passed from parent to child components. Props are immutable and read-only.
- **State**: Data managed within a component. State is mutable and can be updated using `setState` or state setters.

### Example:
```jsx
// Props (passed from parent)
function Child({ name }) {
  return <h1>{name}</h1>;
}

// State (managed in component)
function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(count + 1)}>{count}</button>;
}
```

## 11. What is the difference between controlled and uncontrolled components?

**Answer:**
- **Controlled Components**: Form elements whose value is controlled by React state. The value is stored in state and updated via `onChange`.
- **Uncontrolled Components**: Form elements whose value is handled by the DOM itself, using `ref` to access values.

### Example:
```jsx
// Controlled
function ControlledInput() {
  const [value, setValue] = useState('');
  return <input value={value} onChange={(e) => setValue(e.target.value)} />;
}

// Uncontrolled
function UncontrolledInput() {
  const inputRef = useRef();
  return <input ref={inputRef} />;
}
```

## 12. What is `useRef` hook?

**Answer:**
`useRef` returns a mutable ref object that persists across renders. It's commonly used to access DOM elements or store mutable values that don't trigger re-renders.

### Example:
```jsx
function TextInput() {
  const inputRef = useRef(null);
  
  const focusInput = () => {
    inputRef.current.focus();
  };
  
  return (
    <>
      <input ref={inputRef} />
      <button onClick={focusInput}>Focus Input</button>
    </>
  );
}
```

## 13. What is `useContext` hook?

**Answer:**
`useContext` allows you to consume values from a React context without nesting components.

### Example:
```jsx
const ThemeContext = createContext('light');

function App() {
  return (
    <ThemeContext.Provider value="dark">
      <ThemedButton />
    </ThemeContext.Provider>
  );
}

function ThemedButton() {
  const theme = useContext(ThemeContext);
  return <button className={theme}>Themed Button</button>;
}
```

## 14. What is `useMemo` hook?

**Answer:**
`useMemo` memoizes expensive computations, only recalculating when dependencies change.

### Example:
```jsx
function ExpensiveComponent({ items }) {
  const expensiveValue = useMemo(() => {
    return items.reduce((sum, item) => sum + item.value, 0);
  }, [items]);
  
  return <div>Total: {expensiveValue}</div>;
}
```

## 15. What is `useCallback` hook?

**Answer:**
`useCallback` memoizes functions, preventing unnecessary re-creation on every render.

### Example:
```jsx
function Parent({ items }) {
  const handleClick = useCallback((id) => {
    console.log('Clicked:', id);
  }, []);
  
  return <Child onClick={handleClick} />;
}
```

## 16. What is the difference between `useMemo` and `useCallback`?

**Answer:**
- **`useMemo`**: Memoizes the result of a computation (returns a value).
- **`useCallback`**: Memoizes the function itself (returns a function).

### Example:
```jsx
// useMemo - memoizes value
const expensiveValue = useMemo(() => computeExpensiveValue(a, b), [a, b]);

// useCallback - memoizes function
const memoizedCallback = useCallback(() => {
  doSomething(a, b);
}, [a, b]);
```

## 17. What is `useReducer` hook?

**Answer:**
`useReducer` is an alternative to `useState` for managing complex state logic. It follows the reducer pattern.

### Example:
```jsx
function reducer(state, action) {
  switch (action.type) {
    case 'increment':
      return { count: state.count + 1 };
    case 'decrement':
      return { count: state.count - 1 };
    default:
      return state;
  }
}

function Counter() {
  const [state, dispatch] = useReducer(reducer, { count: 0 });
  return (
    <>
      Count: {state.count}
      <button onClick={() => dispatch({ type: 'increment' })}>+</button>
      <button onClick={() => dispatch({ type: 'decrement' })}>-</button>
    </>
  );
}
```

## 18. What is the difference between `useState` and `useReducer`?

**Answer:**
- **`useState`**: Simple state management, good for primitive values or simple objects.
- **`useReducer`**: Better for complex state logic, multiple sub-values, or when next state depends on previous state.

## 19. What are Higher-Order Components (HOCs)?

**Answer:**
HOCs are functions that take a component and return a new component with additional functionality.

### Example:
```jsx
function withLoading(Component) {
  return function WrappedComponent({ isLoading, ...props }) {
    if (isLoading) return <div>Loading...</div>;
    return <Component {...props} />;
  };
}

const UserListWithLoading = withLoading(UserList);
```

## 20. What are Render Props?

**Answer:**
Render props is a pattern where a component accepts a function as a prop that returns React elements.

### Example:
```jsx
function Mouse({ render }) {
  const [position, setPosition] = useState({ x: 0, y: 0 });
  
  return (
    <div onMouseMove={(e) => setPosition({ x: e.clientX, y: e.clientY })}>
      {render(position)}
    </div>
  );
}

<Mouse render={({ x, y }) => <p>Mouse at {x}, {y}</p>} />
```

## 21. What is React Context?

**Answer:**
React Context provides a way to pass data through the component tree without prop drilling.

### Example:
```jsx
const UserContext = createContext();

function App() {
  return (
    <UserContext.Provider value={{ name: 'John' }}>
      <Profile />
    </UserContext.Provider>
  );
}

function Profile() {
  const user = useContext(UserContext);
  return <div>{user.name}</div>;
}
```

## 22. What is the difference between `React.memo` and `useMemo`?

**Answer:**
- **`React.memo`**: Memoizes a component, preventing re-renders if props haven't changed.
- **`useMemo`**: Memoizes a computed value within a component.

### Example:
```jsx
// React.memo - memoizes component
const MemoizedComponent = React.memo(function Component({ name }) {
  return <div>{name}</div>;
});

// useMemo - memoizes value
function Component({ items }) {
  const total = useMemo(() => items.reduce((sum, item) => sum + item.price, 0), [items]);
  return <div>Total: {total}</div>;
}
```

## 23. What is the difference between `componentDidMount` and `useEffect`?

**Answer:**
- **`componentDidMount`**: Runs after the component is mounted (class components).
- **`useEffect` with `[]`**: Runs after the first render (functional components).

## 24. What is the difference between `componentDidUpdate` and `useEffect`?

**Answer:**
- **`componentDidUpdate`**: Runs after every update (class components).
- **`useEffect` with dependencies**: Runs when dependencies change (functional components).

## 25. What is the difference between `componentWillUnmount` and `useEffect` cleanup?

**Answer:**
- **`componentWillUnmount`**: Runs before component is unmounted (class components).
- **`useEffect` cleanup function**: Runs when component unmounts or before effect runs again.

### Example:
```jsx
useEffect(() => {
  const subscription = subscribe();
  return () => {
    subscription.unsubscribe(); // Cleanup
  };
}, []);
```

## 26. What is React Router?

**Answer:**
React Router is a library for routing in React applications, allowing navigation between different components based on the URL.

### Example:
```jsx
import { BrowserRouter, Route, Link } from 'react-router-dom';

function App() {
  return (
    <BrowserRouter>
      <Link to="/about">About</Link>
      <Route path="/about" component={About} />
    </BrowserRouter>
  );
}
```

## 27. What is the difference between `BrowserRouter` and `HashRouter`?

**Answer:**
- **`BrowserRouter`**: Uses HTML5 history API (clean URLs like `/about`).
- **`HashRouter`**: Uses hash in URL (URLs like `/#/about`).

## 28. What is React Portals?

**Answer:**
Portals provide a way to render children into a DOM node that exists outside the parent component's DOM hierarchy.

### Example:
```jsx
function Modal({ children }) {
  return createPortal(
    children,
    document.getElementById('modal-root')
  );
}
```

## 29. What is the difference between `React.Fragment` and `<>`?

**Answer:**
Both allow grouping multiple elements without adding extra DOM nodes. `<>` is shorthand for `React.Fragment`. `React.Fragment` can accept a `key` prop.

### Example:
```jsx
// Fragment with key
<React.Fragment key={item.id}>
  <Item />
</React.Fragment>

// Shorthand (no key)
<>
  <Item1 />
  <Item2 />
</>
```

## 30. What is the difference between `setState` and `useState`?

**Answer:**
- **`setState`**: Used in class components, can accept a function or object, batches updates.
- **`useState`**: Used in functional components, returns a state setter function, also batches updates.

### Example:
```jsx
// Class component
this.setState({ count: this.state.count + 1 });
this.setState(prevState => ({ count: prevState.count + 1 }));

// Functional component
const [count, setCount] = useState(0);
setCount(count + 1);
setCount(prevCount => prevCount + 1);
```

## 31. What is the difference between shallow and deep comparison in React?

**Answer:**
- **Shallow comparison**: Compares object references, not nested properties.
- **Deep comparison**: Compares all nested properties (React doesn't do this by default).

## 32. What is the purpose of `key` prop in React?

**Answer:**
The `key` prop helps React identify which items have changed, been added, or removed. It should be unique and stable.

### Example:
```jsx
{items.map(item => (
  <Item key={item.id} data={item} />
))}
```

## 33. What is the difference between `useLayoutEffect` and `useEffect`?

**Answer:**
- **`useEffect`**: Runs asynchronously after the DOM is updated and painted.
- **`useLayoutEffect`**: Runs synchronously after DOM mutations but before the browser paints.

## 34. What is React Suspense?

**Answer:**
React Suspense allows components to "wait" for something before rendering, typically used for code splitting and data fetching.

### Example:
```jsx
<Suspense fallback={<div>Loading...</div>}>
  <LazyComponent />
</Suspense>
```

## 35. What is code splitting in React?

**Answer:**
Code splitting is the practice of splitting your bundle into smaller chunks that can be loaded on demand, improving initial load time.

### Example:
```jsx
const LazyComponent = React.lazy(() => import('./LazyComponent'));
```

## 36. What is the difference between `React.lazy` and dynamic imports?

**Answer:**
- **`React.lazy`**: React-specific way to lazy load components, must be used with `Suspense`.
- **Dynamic imports**: JavaScript feature for lazy loading modules.

## 37. What is the difference between `forwardRef` and `useRef`?

**Answer:**
- **`forwardRef`**: Allows a component to receive a ref and pass it to a child element.
- **`useRef`**: Creates a ref object to access DOM elements or store mutable values.

### Example:
```jsx
const FancyButton = forwardRef((props, ref) => (
  <button ref={ref} className="fancy">
    {props.children}
  </button>
));
```

## 38. What is the difference between `useImperativeHandle` and `forwardRef`?

**Answer:**
- **`forwardRef`**: Passes ref to child component.
- **`useImperativeHandle`**: Customizes the instance value exposed to parent components via ref.

## 39. What is the difference between `React.PureComponent` and `React.Component`?

**Answer:**
- **`React.Component`**: Doesn't implement `shouldComponentUpdate`, always re-renders on state/prop changes.
- **`React.PureComponent`**: Implements shallow comparison in `shouldComponentUpdate`, prevents unnecessary re-renders.

## 40. What is the difference between `useState` and `useRef` for storing values?

**Answer:**
- **`useState`**: Triggers re-render when value changes, used for values that affect UI.
- **`useRef`**: Doesn't trigger re-render, used for values that don't affect UI (like previous values, timers).

## 41. What is the purpose of `useEffect` cleanup function?

**Answer:**
The cleanup function runs when the component unmounts or before the effect runs again, preventing memory leaks and cleaning up subscriptions.

### Example:
```jsx
useEffect(() => {
  const timer = setInterval(() => console.log('Tick'), 1000);
  return () => clearInterval(timer); // Cleanup
}, []);
```

## 42. What is the difference between `useState` and `useReducer` for complex state?

**Answer:**
- **`useState`**: Good for simple state, can become messy with complex state logic.
- **`useReducer`**: Better for complex state with multiple sub-values or when next state depends on previous state.

## 43. What is the difference between `React.memo`, `useMemo`, and `useCallback`?

**Answer:**
- **`React.memo`**: Memoizes entire component.
- **`useMemo`**: Memoizes computed values.
- **`useCallback`**: Memoizes functions.

## 44. What is the purpose of `StrictMode` in React?

**Answer:**
`StrictMode` is a tool for highlighting potential problems. It doesn't render any visible UI, but activates additional checks and warnings.

### Example:
```jsx
<React.StrictMode>
  <App />
</React.StrictMode>
```

## 45. What is the difference between `createElement` and JSX?

**Answer:**
JSX is syntactic sugar for `React.createElement()`. JSX gets transpiled to `createElement` calls.

### Example:
```jsx
// JSX
const element = <h1>Hello</h1>;

// Equivalent createElement
const element = React.createElement('h1', null, 'Hello');
```

## 46. What is the difference between `componentDidMount` and `constructor`?

**Answer:**
- **`constructor`**: Runs before component is mounted, used for initializing state and binding methods.
- **`componentDidMount`**: Runs after component is mounted, used for side effects like API calls.

## 47. What is the difference between `getDerivedStateFromProps` and `componentDidUpdate`?

**Answer:**
- **`getDerivedStateFromProps`**: Static method that runs before every render, used to update state based on props.
- **`componentDidUpdate`**: Runs after every update, used for side effects after updates.

## 48. What is the purpose of `Error Boundaries` in React?

**Answer:**
Error Boundaries catch JavaScript errors anywhere in the child component tree, log those errors, and display a fallback UI.

### Example:
```jsx
class ErrorBoundary extends React.Component {
  state = { hasError: false };
  
  static getDerivedStateFromError(error) {
    return { hasError: true };
  }
  
  render() {
    if (this.state.hasError) {
      return <h1>Something went wrong.</h1>;
    }
    return this.props.children;
  }
}
```

## 49. What is the difference between `React.createElement` and JSX factory?

**Answer:**
JSX factory is the function used to create elements. By default, it's `React.createElement`, but can be configured.

## 50. What is the purpose of `React.cloneElement`?

**Answer:**
`React.cloneElement` clones and returns a new React element, allowing you to add or modify props.

### Example:
```jsx
React.cloneElement(child, { className: 'new-class' });
```


