# React Interview Questions - Answers

## Section 1: Introduction

### Pros and Cons of React

#### Q1: What are the pros and cons of React?

**Pros of React:**

1.  **Component-Based Architecture:** React promotes a component-based structure, which encourages reusability, maintainability, and modularity. Each component encapsulates its own logic and UI, making it easier to develop and manage complex applications.
2.  **Virtual DOM:** React uses a Virtual DOM, an in-memory representation of the actual DOM. This allows React to perform updates efficiently by first calculating the minimal changes needed and then updating only those specific parts of the real DOM. This significantly improves performance compared to direct DOM manipulation.
3.  **Unidirectional Data Flow:** React follows a unidirectional data flow (parent-to-child), which makes the application's data flow predictable and easier to debug. This contrasts with two-way data binding, which can lead to complex data mutations and harder-to-track changes.
4.  **Rich Ecosystem and Community Support:** React has a vast and active community, leading to a rich ecosystem of libraries, tools, and resources (e.g., React Router, Redux, Next.js, Material-UI). This extensive support makes development faster and problem-solving more efficient.
5.  **Declarative UI:** React's declarative paradigm makes it easier to reason about the application's UI. Developers describe *what* the UI should look like for a given state, and React takes care of *how* to achieve that state, simplifying UI development and debugging.
6.  **JSX:** JSX (JavaScript XML) is a syntax extension that allows developers to write HTML-like code directly within JavaScript. This combines UI logic with rendering logic, improving readability and making components self-contained.
7.  **Strong Backing by Facebook (Meta):** Being maintained by Meta ensures continuous development, updates, and long-term support, making it a reliable choice for enterprise-level applications.

**Cons of React:**

1.  **Steep Learning Curve (for beginners):** While conceptually simple, React's ecosystem, JSX, and component-based approach can be challenging for developers new to frontend frameworks, especially those coming from traditional JavaScript or jQuery backgrounds.
2.  **Rapid Development Pace:** React's frequent updates and new features can sometimes be overwhelming. Keeping up with the latest best practices, libraries, and tools requires continuous learning.
3.  **JSX Complexity:** While a pro for many, JSX can be a hurdle for developers unfamiliar with mixing HTML-like syntax within JavaScript. It might initially seem less intuitive than pure HTML templates.
4.  **
    Flexibility and Opinionatedness:** React is a library, not a full-fledged framework, offering more flexibility but requiring developers to make more decisions about tooling (e.g., routing, state management). This can be a pro for experienced teams but a con for those seeking a more opinionated, all-in-one solution.
5.  **SEO Challenges (for Client-Side Rendering):** While server-side rendering (SSR) and static site generation (SSG) solutions like Next.js mitigate this, pure client-side rendered (CSR) React applications can face SEO challenges as search engine crawlers might struggle to index dynamically loaded content.

#### Q2: How you can compare it to Angular?

| Feature             | React                                        | Angular                                      |
| :------------------ | :------------------------------------------- | :------------------------------------------- |
| **Type**            | Library (UI-focused)                         | Framework (full-fledged)                     |
| **Learning Curve**  | Moderate to Steep (due to ecosystem choices) | Steep (due to comprehensive nature)          |
| **Data Binding**    | Unidirectional (one-way)                     | Bidirectional (two-way)                      |
| **DOM**             | Virtual DOM                                  | Real DOM (with change detection)             |
| **Templating**      | JSX (JavaScript XML)                         | HTML with directives (TypeScript)            |
| **State Management**| External libraries (e.g., Redux, Zustand)    | Built-in (e.g., RxJS, NgRx)                  |
| **Architecture**    | Component-based                              | Component-based (with modules, services)     |
| **Performance**     | Highly optimized with Virtual DOM            | Optimized with change detection strategies   |
| **Mobile**          | React Native                                 | Ionic, NativeScript                          |
| **Backed By**       | Meta (Facebook)                              | Google                                       |
| **Use Cases**       | SPAs, complex UIs, interactive dashboards    | Enterprise-level apps, large-scale projects  |

### How to create React application?

#### Q1: How do you prefer to generate your React application?

As a staff frontend engineer, I prefer to generate React applications using **Next.js** for most projects. Next.js is a React framework that enables server-side rendering (SSR), static site generation (SSG), and API routes out of the box. This provides significant advantages in terms of performance, SEO, and developer experience compared to a purely client-side rendered application.

For simpler projects or when the requirements strictly dictate a client-side rendered application without the need for SSR/SSG, I would opt for **Vite** with the React template. Vite offers an incredibly fast development server and build process, making it a highly efficient choice for modern React development.

#### Q2: What are the ways?

There are several popular ways to create a React application, each with its own advantages:

1.  **Create React App (CRA):** This was historically the most common way to set up a new React project. It provides a comfortable environment for learning React and is a good solution for building single-page applications (SPAs). It handles the build setup, Babel, Webpack, and other configurations, allowing developers to focus on writing code. However, it's becoming less favored due to its slower development server and build times compared to newer tools.
2.  **Next.js:** A full-stack React framework that enables server-side rendering (SSR), static site generation (SSG), and incremental static regeneration (ISR). It's excellent for building performant, SEO-friendly, and scalable React applications, including complex web applications and marketing sites. It abstracts away much of the configuration for routing, data fetching, and build processes.
3.  **Vite:** A next-generation frontend tooling that provides an extremely fast development experience. It uses native ES modules for development and Rollup for bundling, resulting in significantly faster cold start times and hot module replacement (HMR) compared to Webpack-based tools like CRA. It's a great choice for modern SPAs and can be used with various frameworks, including React.
4.  **Gatsby:** A React-based open-source framework for creating websites and apps. It specializes in static site generation (SSG) and is particularly well-suited for content-heavy websites, blogs, and e-commerce sites that benefit from pre-built HTML and optimized assets.
5.  **Manual Setup (Webpack/Babel):** For highly customized or advanced scenarios, one can manually configure tools like Webpack and Babel to build a React application from scratch. This offers maximum control but requires a deep understanding of build tools and can be time-consuming to set up and maintain.

### Section 2: Basic knowledge

### What is virtual DOM?

#### Q1: What makes React so powerful?

React's power stems from several core concepts and design principles:

1.  **Declarative Programming:** Developers describe the desired UI state, and React efficiently updates the DOM to match that state. This makes code more predictable and easier to debug.
2.  **Component-Based Architecture:** Encourages building encapsulated components that manage their own state and render their own UI. This promotes reusability, modularity, and easier maintenance of complex UIs.
3.  **Virtual DOM for Performance:** Instead of directly manipulating the browser's DOM, React uses a lightweight, in-memory representation called the Virtual DOM. This allows React to perform efficient updates by minimizing direct DOM manipulations, which are typically slow.
4.  **Unidirectional Data Flow:** Data flows in a single direction, from parent to child components. This predictability simplifies debugging and understanding how data changes affect the application.
5.  **JSX:** A syntax extension that allows writing HTML-like code directly within JavaScript. It makes component creation intuitive and combines UI logic with rendering logic, enhancing readability.
6.  **Rich Ecosystem and Community:** A vast array of libraries, tools, and an active community provide solutions for almost any development challenge, from state management (Redux, Zustand) to routing (React Router) and UI components (Material-UI, Ant Design).
7.  **Strong Abstraction:** React abstracts away the complexities of direct DOM manipulation, allowing developers to focus on the application's logic and UI state.

#### Q2: What is virtual DOM?

The **Virtual DOM (VDOM)** is a programming concept where a virtual representation of the UI is kept in memory and synchronized with the
real DOM by a library like ReactDOM. It's a lightweight copy of the actual DOM.

When a component's state changes, React first updates this Virtual DOM. Then, it compares the updated Virtual DOM with a snapshot of the Virtual DOM before the update (a process called "diffing"). This comparison identifies the minimal set of changes that need to be applied to the real DOM. Finally, React batches these changes and updates only the necessary parts of the real DOM, rather than re-rendering the entire DOM tree. This process is significantly faster than directly manipulating the browser's DOM, which is a costly operation.

#### Q3: What is the difference between virtual DOM and shadow DOM?

| Feature           | Virtual DOM (VDOM)                               | Shadow DOM                                     |
| :---------------- | :----------------------------------------------- | :--------------------------------------------- |
| **Purpose**       | Performance optimization for UI rendering        | Encapsulation of component styles and markup   |
| **Managed By**    | JavaScript libraries (e.g., React, Vue)          | Web browser (Web Components standard)          |
| **Concept**       | In-memory representation of the UI               | Encapsulated subtree of the DOM                |
| **Interaction**   | React compares VDOMs and updates real DOM        | Browser isolates styles and markup from main DOM |
| **Scope**         | Entire application UI                            | Individual Web Components                      |
| **Primary Benefit**| Efficient UI updates, improved rendering performance | Style and markup isolation, preventing conflicts |

### What is JSX?

#### Q1: What is JSX?

**JSX (JavaScript XML)** is a syntax extension for JavaScript that allows you to write HTML-like code directly within your JavaScript files. It's not a new language or a templating engine; rather, it's a syntactic sugar for `React.createElement()` calls. JSX makes it easier to describe the structure of your UI components in a way that is familiar to web developers who are used to writing HTML.

For example, instead of writing:

```jsx
React.createElement(
  'h1',
  { className: 'greeting' },
  'Hello, world!'
);
```

You can write with JSX:

```jsx
<h1 className="greeting">Hello, world!</h1>
```

This makes the code more readable, intuitive, and closer to the final rendered output, allowing developers to visualize the UI structure more easily.

#### Q2: Is JSX a part of React?

No, **JSX is not technically a part of React itself**, but it is commonly used with React. React can be used without JSX, but it's not recommended due to the verbosity of `React.createElement()` calls. JSX is a preprocessor step; it gets transformed into regular JavaScript function calls (specifically `React.createElement()`) by a transpiler like Babel before the browser executes the code. React's core library doesn't inherently require JSX, but it's the most widely adopted and recommended way to write React components.

### Why do we use className and not class?

#### Q1: Why can't we write class inside our JSX markup?

We cannot use `class` directly inside JSX markup because `class` is a **reserved keyword in JavaScript**. In JavaScript, `class` is used to define classes (e.g., `class MyComponent { ... }`). Since JSX is ultimately transformed into JavaScript, using `class` as an attribute name would cause a syntax conflict and lead to errors.

To avoid this conflict, React uses the `className` attribute for specifying CSS classes in JSX. When React renders the component to the DOM, it automatically converts `className` to the standard `class` attribute on the HTML element.

### What are functional components and props?

#### Q1: How to create functional components?

**Functional components** are JavaScript functions that accept a single `props` object argument and return React elements (JSX) to describe what should appear on the screen. With the introduction of React Hooks, functional components have become the preferred way to write React components, as they can now manage state, handle side effects, and access other React features that were previously only available in class components.

Here's how to create a functional component:

```jsx
import React from 'react';

// Using a function declaration
function WelcomeMessage(props) {
  return <h1>Hello, {props.name}!</h1>;
}

// Using an arrow function (most common)
const Greeting = (props) => {
  return <p>Greetings from {props.city}.</p>;
};

// With destructuring props for cleaner code
const UserProfile = ({ username, age }) => {
  return (
    <div>
      <h2>{username}</h2>
      <p>Age: {age}</p>
    </div>
  );
};

export default WelcomeMessage;
```

#### Q2: How to pass props to the components?

**Props (short for properties)** are a mechanism for passing data from a parent component to a child component. They are read-only, meaning a child component should never modify the props it receives. This ensures a unidirectional data flow, making applications more predictable.

You pass props to components in JSX just like you pass attributes to HTML elements:

```jsx
// Parent Component
import React from 'react';
import WelcomeMessage from './WelcomeMessage';
import Greeting from './Greeting';
import UserProfile from './UserProfile';

function App() {
  return (
    <div>
      <WelcomeMessage name="Alice" />
      <Greeting city="New York" />
      <UserProfile username="Bob" age={30} />
    </div>
  );
}

export default App;
```

In the example above:

*   `name="Alice"` passes a string prop named `name` with the value "Alice" to `WelcomeMessage`.
*   `city="New York"` passes a string prop named `city` with the value "New York" to `Greeting`.
*   `username="Bob"` and `age={30}` pass string and number props respectively to `UserProfile`. Note that for non-string values (like numbers, booleans, objects, arrays, or functions), you enclose them in curly braces `{}`.

### What are class components, props and state?

#### Q1: How to create class components?

**Class components** are ES6 classes that extend `React.Component` and have a `render()` method that returns React elements (JSX). Before the introduction of Hooks, class components were the only way to manage state and lifecycle methods in React. While still supported, functional components with Hooks are now generally preferred for new development.

Here's how to create a class component:

```jsx
import React, { Component } from 'react';

class MyClassComponent extends Component {
  render() {
    return (
      <div>
        <h1>Hello from a Class Component!</h1>
      </div>
    );
  }
}

export default MyClassComponent;
```

#### Q2: How to pass props to class components?

Passing props to class components is similar to functional components. You pass them as attributes in JSX, and inside the class component, you access them via `this.props`.

```jsx
// Parent Component
import React from 'react';
import MyClassComponent from './MyClassComponent';

function App() {
  return (
    <div>
      <MyClassComponent title="My Awesome App" subtitle="Built with React" />
    </div>
  );
}

export default App;

// MyClassComponent.jsx
import React, { Component } from 'react';

class MyClassComponent extends Component {
  render() {
    return (
      <div>
        <h1>{this.props.title}</h1>
        <p>{this.props.subtitle}</p>
      </div>
    );
  }
}

export default MyClassComponent;
```

#### Q3: How state is working in class components?

In class components, **state** is an object that holds data that might change over the lifetime of the component and influence its rendering. State is private to the component and can only be modified within the component itself. When the state changes, the component re-renders.

Here's how state works in class components:

1.  **Initialization:** State is initialized in the constructor of the class component using `this.state`.
2.  **Reading State:** You access state values using `this.state.propertyName`.
3.  **Updating State:** You update state using the `this.setState()` method. This method merges the new state with the current state and triggers a re-render of the component and its children.

```jsx
import React, { Component } from 'react';

class Counter extends Component {
  constructor(props) {
    super(props);
    this.state = {
      count: 0,
    };
    // Bind the event handler to the component instance
    this.handleClick = this.handleClick.bind(this);
  }

  handleClick() {
    // Correct way to update state based on previous state
    this.setState((prevState) => ({
      count: prevState.count + 1,
    }));
  }

  render() {
    return (
      <div>
        <p>Count: {this.state.count}</p>
        <button onClick={this.handleClick}>Increment</button>
      </div>
    );
  }
}

export default Counter;
```

**Key points about `this.setState()`:**

*   `this.setState()` is asynchronous. React may batch multiple `setState()` calls for performance. If you need to update state based on the previous state, always pass a function to `setState()` as shown in the `handleClick` example above.
*   `this.setState()` performs a shallow merge. This means that if your state object has multiple properties, `setState()` will only update the properties you specify, leaving others untouched.

### What are dumb vs smart components?

#### Q1: What are dumb and smart components?

The terms "dumb" and "smart" components (also known as "presentational" and "container" components, respectively) refer to a pattern for separating concerns in React applications. This pattern aims to improve reusability, maintainability, and testability by dividing components based on their responsibilities.

**Dumb Components (Presentational Components):**

*   **Concerned with *how things look*.** They receive data and callbacks exclusively via props and render UI based on that data.
*   They typically have no internal state (unless it's UI-related, like a toggle's open/closed state).
*   They are usually functional components (before Hooks, they were often stateless functional components).
*   They are highly reusable because they are decoupled from application-specific logic.
*   Examples: `Button`, `ListItem`, `Card`, `Modal`.

**Smart Components (Container Components):**

*   **Concerned with *how things work*.** They manage state, fetch data, and contain application logic.
*   They pass data and callbacks as props to their dumb (presentational) children.
*   They often don't have much markup of their own; their primary role is to orchestrate data and behavior.
*   They are typically class components (before Hooks) or functional components using Hooks (e.g., `useState`, `useEffect`, `useContext`) to manage state and side effects.
*   Examples: `UserListContainer`, `ProductPageContainer`, `AuthFormContainer`.

#### Q2: What are presentational vs container components?

This is essentially the same concept as "dumb vs. smart components," just with different terminology popularized by Dan Abramov. The distinction is as follows:

*   **Presentational Components:** Focus on the UI and how data is displayed. They receive data via props and render it. They are typically stateless and have no dependencies on the rest of the application's state management logic. They are concerned with *presentation*.
*   **Container Components:** Focus on data fetching, state management, and application logic. They provide data and behavior to presentational components. They are concerned with *logic* and *data management*.

**Benefits of this separation:**

*   **Improved Reusability:** Presentational components can be reused across different parts of the application or even in different projects.
*   **Easier Testing:** Presentational components are easier to test because they are pure functions of their props. Container components can be tested separately for their logic.
*   **Better Separation of Concerns:** Clearly defines responsibilities, making the codebase easier to understand and maintain.

### What is a key index map?

#### Q1: How to render a list inside React?

To render a list of items in React, you typically use the JavaScript `map()` array method to iterate over an array of data and return a React element for each item. Each item in the list should have a unique `key` prop.

Here's an example:

```jsx
import React from 'react';

function ItemList() {
  const items = [
    { id: 1, name: 'Apple' },
    { id: 2, name: 'Banana' },
    { id: 3, name: 'Cherry' },
  ];

  return (
    <ul>
      {items.map((item) => (
        <li key={item.id}>{item.name}</li>
      ))}
    </ul>
  );
}

export default ItemList;
```

In this example:

1.  We have an array `items` where each object represents a list item.
2.  We use `items.map()` to iterate over the array.
3.  For each `item`, we return a `<li>` element.
4.  Crucially, each `<li>` element has a `key` prop set to `item.id`. This `key` prop is essential for React's reconciliation process.

#### Q2: What is key and why it is bad to use index for it?

The `key` prop is a special string attribute you need to include when creating lists of elements in React. Keys help React identify which items have changed, are added, or are removed. They provide a stable identity to components in a list.

**Why `key` is important:**

When a list changes (items are reordered, added, or removed), React uses the `key` prop to efficiently update the UI. Without stable keys, React might re-render entire list items or update them incorrectly, leading to performance issues and potential bugs (e.g., incorrect state being associated with the wrong item).

**Why it is bad to use `index` for `key`:**

Using the array `index` as a `key` is generally discouraged and can lead to problems, especially when:

1.  **The list items can be reordered:** If you reorder the list, the indices of the items change. React will see the same keys (indices) but different content, leading it to believe that the *same* components have just changed their content, rather than recognizing that the components themselves have moved. This can cause unexpected behavior, performance degradation, and issues with component state.
2.  **The list items can be added/removed in the middle:** If you add or remove an item in the middle of the list, the indices of all subsequent items will shift. Again, React will incorrectly associate the old state with new items or misidentify which items were actually removed/added.

**Example of why `index` is bad:**

Consider a list of input fields where each input has its own internal state. If you use `index` as a key and then reorder the list, the input fields might retain the values they had before reordering, but they will be associated with the *wrong* data item because React matched them by their unchanging index, not their actual identity.

**When `index` as `key` might be acceptable (but still generally avoided):**

*   The list is static and will never change (no reordering, adding, or removing items).
*   The list has no IDs for its items.
*   The items in the list have no state of their own.

In most real-world scenarios, it's best to use a stable, unique identifier from your data (like a database ID) as the `key`.

### What is React.Fragment?

#### Q1: What is React fragment?

**React.Fragment** (often shortened to `<>...</>`) is a built-in component in React that lets you group a list of children without adding extra nodes to the DOM. In React, components must return a single parent element. This means you can't return multiple top-level elements directly from a component's `render()` method or functional component's return statement without wrapping them in a common parent like a `<div>`.

However, sometimes adding an extra `<div>` to the DOM can break styling, semantic HTML, or introduce unnecessary nodes. `React.Fragment` solves this problem by allowing you to group elements without rendering an actual DOM element.

Example without Fragment (will cause an error):

```jsx
function MyComponent() {
  return (
    <p>First paragraph</p>
    <p>Second paragraph</p>
  ); // Error: Adjacent JSX elements must be wrapped in an enclosing tag
}
```

Example with `React.Fragment`:

```jsx
import React from 'react';

function MyComponent() {
  return (
    <React.Fragment>
      <p>First paragraph</p>
      <p>Second paragraph</p>
    </React.Fragment>
  );
}
```

#### Q2: Do you know the short version?

Yes, the short syntax for `React.Fragment` is an empty tag: `<>...</>`. This is a more concise and commonly used way to achieve the same result.

Example with short syntax:

```jsx
function MyComponent() {
  return (
    <>
      <p>First paragraph</p>
      <p>Second paragraph</p>
    </>
  );
}
```

**Note:** The short syntax `<>` does not support `key` props or other attributes. If you need to pass a `key` (e.g., when rendering a list of fragments), you must use the explicit `<React.Fragment key={item.id}>` syntax.

### What is conditional rendering in React?

#### Q1: What do you know about conditional rendering in React?

**Conditional rendering** in React refers to the ability to render different elements or components based on certain conditions. It allows you to control what gets displayed on the screen depending on the application's state, props, or other factors. This is a fundamental concept for building dynamic and interactive user interfaces.

React provides several ways to implement conditional rendering:

1.  **`if` statements (outside JSX):** You can use standard JavaScript `if` statements to conditionally return different JSX.

    ```jsx
    function Greeting({ isLoggedIn }) {
      if (isLoggedIn) {
        return <h1>Welcome back!</h1>;
      }
      return <h1>Please log in.</h1>;
    }
    ```

2.  **Ternary Operator (`condition ? true : false`):** This is a concise way to render one of two elements based on a condition, often used inline within JSX.

    ```jsx
    function Greeting({ isLoggedIn }) {
      return (
        <div>
          {isLoggedIn ? (
            <h1>Welcome back!</h1>
          ) : (
            <h1>Please log in.</h1>
          )}
        </div>
      );
    }
    ```

3.  **Logical `&&` Operator (`condition && expression`):** If you want to render something only when a condition is true, and render nothing otherwise, you can use the logical `&&` operator. If the condition is `true`, the element after `&&` will be rendered; otherwise, React ignores and skips it.

    ```jsx
    function Mailbox({ unreadMessages }) {
      return (
        <div>
          <h1>Hello!</h1>
          {unreadMessages.length > 0 &&
            <h2>You have {unreadMessages.length} unread messages.</h2>
          }
        </div>
      );
    }
    ```

4.  **`switch` statements (outside JSX):** For multiple conditions, a `switch` statement can be used, similar to `if` statements.

    ```jsx
    function UserStatus({ status }) {
      switch (status) {
        case 'online':
          return <p>User is online.</p>;
        case 'offline':
          return <p>User is offline.</p>;
        default:
          return <p>Status unknown.</p>;
      }
    }
    ```

5.  **Element Variables:** You can declare a variable that will hold the element to be rendered conditionally and then include that variable in your JSX.

    ```jsx
    function LoginControl({ isLoggedIn }) {
      let button;
      if (isLoggedIn) {
        button = <LogoutButton />;
      } else {
        button = <LoginButton />;
      }
      return (
        <div>
          {button}
        </div>
      );
    }
    ```

Conditional rendering is crucial for creating dynamic UIs, such as showing/hiding loading indicators, displaying different content based on user roles, or toggling visibility of elements.

### How to apply styles in React?

#### Q1: How to apply styles in React?

There are several ways to apply styles to React components, ranging from traditional CSS to more modern JavaScript-in-CSS solutions. As a staff frontend engineer, I typically choose the method based on project requirements, team preferences, and scalability needs.

1.  **Inline Styles:**
    You can apply styles directly to elements using the `style` prop. The value of the `style` prop is a JavaScript object where keys are camelCased CSS property names and values are strings.

    ```jsx
    function MyComponent() {
      const myStyle = {
        color: 'blue',
        fontSize: '16px',
        backgroundColor: '#f0f0f0',
        padding: '10px'
      };

      return (
        <h1 style={myStyle}>Hello, Inline Styles!</h1>
      );
    }
    ```
    **Pros:** Component-scoped, easy for dynamic styles.
    **Cons:** No pseudo-classes/elements, no media queries, verbose for many styles, not performant for complex styles.

2.  **CSS Stylesheets (External CSS):**
    This is the traditional way. You write CSS in separate `.css` files and import them into your React components. This applies global styles.

    ```css
    /* MyComponent.css */
    .my-heading {
      color: green;
      font-size: 24px;
    }
    ```

    ```jsx
    import React from 'react';
    import './MyComponent.css'; // Import the CSS file

    function MyComponent() {
      return (
        <h1 className="my-heading">Hello, External CSS!</h1>
      );
    }
    ```
    **Pros:** Familiar, full CSS features, good for global styles.
    **Cons:** Global scope can lead to naming conflicts, requires careful management to avoid unintended side effects.

3.  **CSS Modules:**
    CSS Modules solve the global scope issue of traditional CSS. When you import a CSS Module file (e.g., `MyComponent.module.css`), the class names are automatically scoped locally to that component by generating unique class names.

    ```css
    /* MyComponent.module.css */
    .myHeading {
      color: purple;
      font-size: 20px;
    }
    .myParagraph {
      margin-top: 10px;
    }
    ```

    ```jsx
    import React from 'react';
    import styles from './MyComponent.module.css'; // Import as an object

    function MyComponent() {
      return (
        <div className={styles.myHeading}>
          <h1>Hello, CSS Modules!</h1>
          <p className={styles.myParagraph}>This paragraph is also styled.</p>
        </div>
      );
    }
    ```
    **Pros:** Local scope (no naming conflicts), familiar CSS syntax, good for component-level styling.
    **Cons:** Requires build tool configuration (often handled by bundlers like Webpack/Vite).

4.  **Styled Components (CSS-in-JS):**
    Libraries like Styled Components allow you to write actual CSS code inside your JavaScript files, creating components with styles attached. This provides true component encapsulation for styles.

    ```jsx
    import React from 'react';
    import styled from 'styled-components';

    const StyledHeading = styled.h1`
      color: orange;
      font-size: 28px;
      &:hover {
        color: red;
      }
    `;

    function MyComponent() {
      return (
        <StyledHeading>Hello, Styled Components!</StyledHeading>
      );
    }
    ```
    **Pros:** Component-scoped styles, dynamic styling based on props, co-location of styles and components, supports advanced CSS features.
    **Cons:** Runtime overhead, can be a learning curve, potentially larger bundle size.

5.  **Utility-First CSS (e.g., Tailwind CSS):**
    Tailwind CSS provides a set of utility classes that you can apply directly in your JSX to style elements. It's highly configurable and promotes rapid UI development.

    ```jsx
    function MyComponent() {
      return (
        <h1 className="text-blue-500 text-3xl font-bold p-4 bg-gray-100 rounded-lg">
          Hello, Tailwind CSS!
        </h1>
      );
    }
    ```
    **Pros:** Rapid development, consistent design system, small production CSS bundle (with purging).
    **Cons:** Can lead to verbose JSX, initial setup/configuration.

#### Q2: How to add several classes conditionally?

Adding several classes conditionally in React is a common task. Here are a few popular approaches:

1.  **Template Literals (ES6):**
    This is a straightforward way to combine static and dynamic class names.

    ```jsx
    function Button({ isActive, type }) {
      const baseClasses = "py-2 px-4 rounded";
      const activeClass = isActive ? "bg-blue-500 text-white" : "bg-gray-200 text-gray-800";
      const buttonTypeClass = type === 'primary' ? 'font-bold' : 'font-normal';

      return (
        <button className={`${baseClasses} ${activeClass} ${buttonTypeClass}`}>
          Click Me
        </button>
      );
    }
    ```

2.  **`clsx` or `classnames` Libraries:**
    For more complex conditional class logic, libraries like `clsx` (or `classnames`) are highly recommended. They provide a clean API for conditionally joining class names.

    First, install it:
    `npm install clsx` or `yarn add clsx`

    Then use it:

    ```jsx
    import clsx from 'clsx';

    function Alert({ type, hasIcon, isDismissible }) {
      return (
        <div
          className={clsx(
            'p-4 rounded-md',
            {
              'bg-red-100 text-red-700': type === 'error',
              'bg-green-100 text-green-700': type === 'success',
              'flex items-center': hasIcon,
              'pr-10': isDismissible,
            }
          )}
        >
          {/* Alert content */}
        </div>
      );
    }
    ```
    `clsx` can take multiple arguments: strings, objects (where keys are class names and values are booleans), and arrays.

3.  **Array `join` Method:**
    You can build an array of class names and then `join` them with a space.

    ```jsx
    function Card({ isLoading, isDisabled }) {
      const classes = ['card'];
      if (isLoading) {
        classes.push('card--loading');
      }
      if (isDisabled) {
        classes.push('card--disabled');
      }

      return (
        <div className={classes.join(' ')}>
          {/* Card content */}
        </div>
      );
    }
    ```

Using `clsx` or `classnames` is generally the most robust and readable solution for complex conditional class assignments.

### How parent child communication is working in React?

#### Q1: How parent and child components can communicate in React?

Communication between parent and child components in React primarily follows a **unidirectional data flow**, meaning data flows down from parent to child via props. However, there are established patterns for child components to communicate back up to their parents.

**1. Parent to Child Communication (Props Down):**

This is the most common and straightforward way. Parent components pass data to child components using `props`.

*   **Mechanism:** The parent component renders the child component and passes data as attributes (props) to it.
*   **Example:**

    ```jsx
    // ChildComponent.jsx
    function ChildComponent({ message }) {
      return <p>{message}</p>;
    }

    // ParentComponent.jsx
    function ParentComponent() {
      const data = "Hello from Parent!";
      return <ChildComponent message={data} />;
    }
    ```

**2. Child to Parent Communication (Callbacks Up):**

Since props flow down, a child component cannot directly modify the parent's state or data. To communicate back up, the parent component passes a function (a callback prop) to the child. The child then calls this function, passing data as arguments, which allows the parent to update its state or perform an action.

*   **Mechanism:** Parent passes a function as a prop to the child. Child invokes the function, potentially with data.
*   **Example:**

    ```jsx
    // ChildComponent.jsx
    function ChildComponent({ onButtonClick }) {
      return (
        <button onClick={() => onButtonClick("Data from child")}>
          Click Me
        </button>
      );
    }

    // ParentComponent.jsx
    import React, { useState } from 'react';

    function ParentComponent() {
      const [childData, setChildData] = useState('');

      const handleChildButtonClick = (data) => {
        setChildData(data);
        console.log("Received from child:", data);
      };

      return (
        <div>
          <p>Data from child: {childData}</p>
          <ChildComponent onButtonClick={handleChildButtonClick} />
        </div>
      );
    }
    ```

**3. Sibling Communication:**

Siblings don't communicate directly. They communicate via their common parent. One sibling passes data up to the parent using a callback, and the parent then passes that data down to the other sibling via props.

*   **Mechanism:** Child A -> Parent (callback) -> Child B (props).

**4. Context API (for deeply nested components):**

For passing data through many levels of nested components without explicitly passing props at each level (prop drilling), React's Context API can be used. Context provides a way to share values like themes, user authentication status, or locale across the component tree.

*   **Mechanism:** Create a Context, provide a value higher up in the tree, and consume it in any descendant component.

    ```jsx
    // ThemeContext.js
    import React from 'react';
    export const ThemeContext = React.createContext('light');

    // App.js (Provider)
    import React, { useState } from 'react';
    import { ThemeContext } from './ThemeContext';
    import Toolbar from './Toolbar';

    function App() {
      const [theme, setTheme] = useState('light');
      return (
        <ThemeContext.Provider value={theme}>
          <Toolbar />
          <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
            Toggle Theme
          </button>
        </ThemeContext.Provider>
      );
    }

    // Toolbar.js (Intermediate component, doesn't care about theme)
    import React from 'react';
    import ThemedButton from './ThemedButton';

    function Toolbar() {
      return (
        <div>
          <ThemedButton />
        </div>
      );
    }

    // ThemedButton.js (Consumer)
    import React, { useContext } from 'react';
    import { ThemeContext } from './ThemeContext';

    function ThemedButton() {
      const theme = useContext(ThemeContext);
      return (
        <button style={{ background: theme === 'dark' ? '#333' : '#eee', color: theme === 'dark' ? 'white' : 'black' }}>
          I am a {theme} button
        </button>
      );
    }
    ```

**5. State Management Libraries (e.g., Redux, Zustand, Recoil):**

For complex applications with global state or state that needs to be shared across many components that are not directly related, dedicated state management libraries are often used. These libraries provide a centralized store for application state, allowing any component to access and update it.

#### Q2: Can we mutate props?

No, **you should never mutate props directly in React**. Props are read-only. React enforces a strict unidirectional data flow, and mutating props would violate this principle, leading to unpredictable behavior, difficult-to-debug issues, and breaking React's reconciliation process.

If a child component needs to modify data that originated from a parent, the correct approach is for the parent to pass a callback function as a prop to the child. The child then calls this function, passing the new data, and the parent updates its own state, which then re-renders the child with the updated props.

Attempting to mutate props will often result in a warning in development mode (e.g., "Do not mutate props directly"), and in strict mode, it can lead to unexpected behavior or errors.


## Section 3: Advanced knowledge

### What is useState hook?

#### Q1: What do you know about useState hook?

The `useState` Hook is a fundamental React Hook that allows functional components to manage state. Before Hooks, state management was primarily confined to class components. `useState` provides a way to add state variables to functional components, making them capable of holding and updating data that triggers re-renders.

**How it works:**

`useState` is a function that takes one argument: the initial state value. It returns an array containing two elements:

1.  The current state value.
2.  A function to update that state value.

**Syntax:**

```jsx
import React, { useState } from 'react';

function Counter() {
  // Declare a state variable 'count' and its setter 'setCount'
  const [count, setCount] = useState(0); // Initial state is 0

  return (
    <div>
      <p>You clicked {count} times</p>
      <button onClick={() => setCount(count + 1)}>
        Click me
      </button>
      <button onClick={() => setCount(0)}>
        Reset
      </button>
    </div>
  );
}

export default Counter;
```

**Key characteristics and best practices:**

*   **State Initialization:** The argument passed to `useState` is the initial state. It is only used during the initial render. For subsequent renders, the state value is the latest one.
*   **Setter Function:** The `setCount` (or `setState` generally) function is used to update the state. When called, it schedules a re-render of the component. It does not immediately mutate the state variable.
*   **Functional Updates:** If the new state depends on the previous state, it's recommended to pass a function to the setter. This function receives the previous state as an argument and returns the new state. This prevents issues with stale closures when state updates are batched.

    ```jsx
    // Correct way to update state based on previous state
    setCount(prevCount => prevCount + 1);
    ```
*   **Multiple State Variables:** You can use `useState` multiple times in a single component to declare independent state variables.

    ```jsx
    const [firstName, setFirstName] = useState('John');
    const [lastName, setLastName] = useState('Doe');
    ```
*   **Immutability:** State in React should be treated as immutable. When updating objects or arrays in state, you should create a new object/array with the desired changes rather than directly modifying the existing one.

    ```jsx
    const [user, setUser] = useState({ name: 'Alice', age: 30 });

    // Bad: Mutates state directly
    // user.age = 31;
    // setUser(user);

    // Good: Creates a new object
    setUser(prevUser => ({ ...prevUser, age: prevUser.age + 1 }));
    ```

`useState` is the most basic and frequently used Hook, enabling functional components to be just as powerful and capable as class components in managing internal state.

### What is useEffect hook?

#### Q1: What do you know about useEffect hook?

The `useEffect` Hook is a powerful React Hook that allows functional components to perform side effects. Side effects are operations that interact with the outside world or affect things outside the component's render cycle, such as data fetching, subscriptions, manually changing the DOM, timers, and logging.

**How it works:**

`useEffect` takes two arguments:

1.  A function (the "effect" function) that contains the side effect logic.
2.  An optional dependency array.

React runs the effect function after every render where the dependencies have changed. It also provides a mechanism for cleanup.

**Syntax:**

```jsx
import React, { useState, useEffect } from 'react';

function Timer() {
  const [count, setCount] = useState(0);

  // Effect runs after every render if no dependency array is provided
  // or if dependencies change.
  useEffect(() => {
    // This is the side effect
    const intervalId = setInterval(() => {
      setCount(prevCount => prevCount + 1);
    }, 1000);

    // Cleanup function: runs before the component unmounts
    // or before the effect re-runs due to dependency changes.
    return () => {
      clearInterval(intervalId);
    };
  }, []); // Empty dependency array: effect runs once after initial render and cleans up on unmount

  return (
    <div>
      <p>Timer: {count} seconds</p>
    </div>
  );
}

export default Timer;
```

**Key characteristics and use cases:**

1.  **Runs After Render:** The effect function runs *after* the component has rendered and the DOM has been updated. This prevents blocking the browser's paint process.
2.  **Cleanup Function:** The `useEffect` hook can return a cleanup function. This function is executed before the component unmounts and before the effect re-runs (if dependencies change). It's crucial for preventing memory leaks (e.g., clearing timers, unsubscribing from events).
3.  **Dependency Array:**
    *   **No dependency array:** The effect runs after *every* render. (Rarely used, can lead to performance issues).
    *   **Empty dependency array (`[]`):** The effect runs only once after the initial render and the cleanup runs only when the component unmounts. This mimics `componentDidMount` and `componentWillUnmount`.
    *   **With dependencies (`[propA, stateB]`):** The effect runs after the initial render and whenever any of the values in the dependency array change. The cleanup runs before the effect re-runs and on unmount. This mimics `componentDidMount`, `componentDidUpdate`, and `componentWillUnmount` combined.

**Common use cases for `useEffect`:**

*   **Data Fetching:** Making API calls when a component mounts or when certain props/state change.
*   **DOM Manipulation:** Directly interacting with the DOM (e.g., setting document title, adding event listeners).
*   **Subscriptions:** Setting up and tearing down subscriptions to external data sources.
*   **Timers:** Starting and clearing `setInterval` or `setTimeout`.
*   **Logging:** Sending analytics events.

It's important to correctly manage the dependency array to avoid unnecessary re-runs of effects and to ensure proper cleanup, which is a common source of bugs and performance issues if not handled carefully.

### What is useReducer hook?

#### Q1: What do you know about useReducer hook?

The `useReducer` Hook is an alternative to `useState` for managing more complex state logic in functional components. It is particularly useful when state transitions are complex, involve multiple sub-values, or when the next state depends on the previous one. It's often preferred over `useState` when you have state logic that involves multiple actions or when the state shape is an object or array that needs careful updates.

`useReducer` is conceptually similar to Redux, providing a predictable state container.

**How it works:**

`useReducer` takes two (or optionally three) arguments:

1.  A `reducer` function: This function takes the current `state` and an `action` as arguments and returns the `new state`.
2.  An `initialState`: The initial value of the state.
3.  (Optional) An `init` function: A function to lazily initialize the state.

It returns an array containing two elements:

1.  The current `state`.
2.  A `dispatch` function: Used to dispatch actions to the reducer.

**Syntax:**

```jsx
import React, { useReducer } from 'react';

// 1. Define the reducer function
const counterReducer = (state, action) => {
  switch (action.type) {
    case 'increment':
      return { count: state.count + 1 };
    case 'decrement':
      return { count: state.count - 1 };
    case 'reset':
      return { count: action.payload };
    default:
      throw new Error();
  }
};

function CounterWithReducer() {
  // 2. Initialize state with useReducer
  const [state, dispatch] = useReducer(counterReducer, { count: 0 });

  return (
    <div>
      <p>Count: {state.count}</p>
      <button onClick={() => dispatch({ type: 'increment' })}>
        Increment
      </button>
      <button onClick={() => dispatch({ type: 'decrement' })}>
        Decrement
      </button>
      <button onClick={() => dispatch({ type: 'reset', payload: 0 })}>
        Reset
      </button>
    </div>
  );
}

export default CounterWithReducer;
```

**Key benefits of `useReducer`:**

*   **Predictable State Changes:** All state changes go through the `reducer` function, making state transitions explicit and easier to understand and debug.
*   **Centralized Logic:** State update logic is centralized in the reducer, separating it from the component's rendering logic.
*   **Complex State Management:** Better suited for managing complex state objects or arrays where `useState` might become cumbersome with multiple `set` functions.
*   **Performance Optimization (with `useCallback`):** The `dispatch` function itself is stable across re-renders, meaning it won't cause child components that depend on it to re-render unnecessarily if wrapped with `React.memo`.
*   **Lazy Initialization:** The optional `init` function allows for lazy initialization of the state, which can be useful for expensive initial state calculations.

`useReducer` is an excellent choice when you have state that involves multiple related values, and the updates to these values are interdependent or follow a specific pattern. It also pairs well with `useContext` for global state management without external libraries.

### What is useContext hook?

#### Q1: What do you know about useContext hook?

The `useContext` Hook is a React Hook that allows functional components to subscribe to React Context. Context provides a way to pass data through the component tree without having to pass props down manually at every level (a problem known as "prop drilling"). It's designed to share data that can be considered "global" for a tree of React components, such as the current authenticated user, theme settings, or preferred language.

**How it works:**

1.  **Create Context:** First, you create a Context object using `React.createContext()`. This object comes with a `Provider` and a `Consumer` component (or you use `useContext` for consumption).
2.  **Provide Value:** The `Provider` component is placed higher up in the component tree and accepts a `value` prop. All components within the `Provider`'s subtree can access this value.
3.  **Consume Value:** The `useContext` Hook is used in a functional component to read the current context value. It takes the Context object itself as an argument and returns the current context value.

**Syntax:**

```jsx
import React, { createContext, useContext, useState } from 'react';

// 1. Create a Context
const ThemeContext = createContext('light'); // Default value is 'light'

function App() {
  const [theme, setTheme] = useState('light');

  return (
    // 2. Provide the context value to its children
    <ThemeContext.Provider value={theme}>
      <Toolbar />
      <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
        Toggle Theme
      </button>
    </ThemeContext.Provider>
  );
}

function Toolbar() {
  return (
    <div>
      <ThemedButton />
    </div>
  );
}

function ThemedButton() {
  // 3. Consume the context value using useContext
  const theme = useContext(ThemeContext);

  const buttonStyle = {
    background: theme === 'dark' ? '#333' : '#eee',
    color: theme === 'dark' ? 'white' : 'black',
    padding: '10px',
    borderRadius: '5px',
    border: 'none',
    cursor: 'pointer',
  };

  return (
    <button style={buttonStyle}>
      I am a {theme} button
    </button>
  );
}

export default App;
```

**Key benefits and considerations:**

*   **Avoids Prop Drilling:** Eliminates the need to pass props down through many intermediate components that don't directly use the data.
*   **Global State (within a subtree):** Provides a way to manage state that is global to a specific part of the application.
*   **Re-renders:** When the `value` prop of a `Provider` changes, all consumers that use that Context will re-render, even if they are memoized. This is an important performance consideration.
*   **Not a Replacement for Redux:** While `useContext` can be combined with `useReducer` to create a lightweight global state management solution, it's not a full-fledged replacement for libraries like Redux for very complex, large-scale applications with highly optimized state updates.
*   **Multiple Contexts:** An application can have multiple contexts for different types of global data.

`useContext` is an excellent tool for sharing data that doesn't change frequently or doesn't require highly optimized updates across many components.

### What is useRef hook?

#### Q1: What do you know about useRef hook?

The `useRef` Hook is a React Hook that provides a way to create a mutable `ref` object whose `.current` property can hold any mutable value. This `ref` object will persist for the full lifetime of the component. Its primary use cases are to access DOM elements directly or to store mutable values that don't trigger a re-render when they change.

**How it works:**

`useRef` returns a plain JavaScript object with a single property called `current`. This property can be initialized with an argument passed to `useRef`.

**Syntax:**

```jsx
import React, { useRef, useEffect } from 'react';

function TextInputWithFocusButton() {
  // Create a ref object
  const inputEl = useRef(null);

  const onButtonClick = () => {
    // `current` points to the mounted text input element
    inputEl.current.focus();
  };

  useEffect(() => {
    // You can also use it for direct DOM manipulation on mount
    if (inputEl.current) {
      inputEl.current.style.border = '2px solid blue';
    }
  }, []);

  return (
    <>
      <input ref={inputEl} type="text" />
      <button onClick={onButtonClick}>Focus the input</button>
    </>
  );
}

export default TextInputWithFocusButton;
```

**Key use cases and characteristics:**

1.  **Accessing DOM Elements:** The most common use case is to get a direct reference to a DOM element. You pass the `ref` object to the `ref` attribute of a JSX element, and React will set the `current` property to the actual DOM node after the component mounts.
2.  **Storing Mutable Values (that don't trigger re-renders):** `useRef` can also be used to store any mutable value that you want to persist across renders without causing the component to re-render when that value changes. This is useful for:
    *   Storing a previous value of a prop or state.
    *   Holding a mutable object that isn't part of the component's visual output (e.g., a timer ID, a WebSocket instance).
    *   Avoiding re-creating expensive objects on every render.

    ```jsx
    import React, { useRef, useEffect, useState } from 'react';

    function CounterWithRef() {
      const [count, setCount] = useState(0);
      const prevCountRef = useRef();

      useEffect(() => {
        prevCountRef.current = count; // Store current count after render
      });

      const previousCount = prevCountRef.current;

      return (
        <div>
          <p>Current Count: {count}</p>
          <p>Previous Count: {previousCount}</p>
          <button onClick={() => setCount(count + 1)}>Increment</button>
        </div>
      );
    }
    ```

3.  **Persists Across Renders:** Unlike regular variables that are re-initialized on every render, the `ref.current` value persists across renders without being reset.
4.  **Does Not Trigger Re-renders:** Changing `ref.current` does *not* cause a component to re-render. This is a key difference from `useState` and makes `useRef` suitable for values that are internal to the component's logic but don't directly affect its visual output.

**When to use `useRef`:**

*   Managing focus, text selection, or media playback.
*   Triggering imperative animations.
*   Integrating with third-party DOM libraries.
*   Storing any mutable value that doesn't need to trigger a re-render.

It's important to remember that `useRef` is for imperative interactions and should be used sparingly, as direct DOM manipulation can sometimes go against React's declarative paradigm.

### What is useMemo hook?

#### Q1: What do you know about useMemo hook?

The `useMemo` Hook is a React Hook that allows you to memoize (cache) the result of a computation. It's used for performance optimization by preventing expensive calculations from being re-executed on every render when their dependencies haven't changed. `useMemo` returns a memoized value.

**How it works:**

`useMemo` takes two arguments:

1.  A "create" function: This function performs the expensive computation and returns its result.
2.  A dependency array: An array of values that the computation depends on.

React will only re-run the "create" function and re-calculate the value if one of the dependencies in the array has changed since the last render. Otherwise, it returns the previously memoized value.

**Syntax:**

```jsx
import React, { useState, useMemo } from 'react';

function ExpensiveCalculationComponent({ num }) {
  const [count, setCount] = useState(0);

  // This function is expensive and we only want to re-run it when 'num' changes
  const calculateExpensiveValue = (number) => {
    console.log('Calculating expensive value...');
    // Simulate a slow calculation
    let result = 0;
    for (let i = 0; i < 100000000; i++) {
      result += number;
    }
    return result;
  };

  // Memoize the result of calculateExpensiveValue
  // It will only re-run if 'num' changes
  const memoizedValue = useMemo(() => calculateExpensiveValue(num), [num]);

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Increment Count</button>
      <p>Expensive Value (depends on num): {memoizedValue}</p>
      <p>Prop num: {num}</p>
    </div>
  );
}

export default ExpensiveCalculationComponent;
```

In this example, `calculateExpensiveValue` is called only when the `num` prop changes. If `count` changes, the `ExpensiveCalculationComponent` re-renders, but `memoizedValue` is returned from the cache without re-executing the expensive calculation.

**Key considerations and best practices:**

*   **Performance Optimization:** Use `useMemo` for computations that are genuinely expensive and whose results are needed for rendering. Don't overuse it, as memoization itself has a cost.
*   **Dependency Array:** The dependency array is crucial. If it's omitted, the function will re-run on every render. If it's empty (`[]`), the function will run only once on the initial render.
*   **Referential Equality:** `useMemo` relies on referential equality for its dependencies. If you pass objects or arrays as dependencies, ensure they are stable references, or `useMemo` might re-run unexpectedly.
*   **When to use:**
    *   Filtering large lists.
    *   Complex data transformations.
    *   Creating objects or arrays that are passed as props to memoized child components (e.g., `React.memo`), to prevent unnecessary re-renders of those children.

**Caution:** React may choose to "forget" some memoized values and re-calculate them during future renders, for example, to free up memory. Therefore, `useMemo` should be used as a performance hint, not as a guarantee that the "create" function will never re-run.

### What is useCallback hook?

#### Q1: What do you know about useCallback hook?

The `useCallback` Hook is a React Hook that returns a memoized callback function. It's used for performance optimization, specifically to prevent unnecessary re-renders of child components that rely on callback functions passed as props. `useCallback` is particularly useful when dealing with `React.memo`.

**How it works:**

`useCallback` takes two arguments:

1.  A callback function: The function you want to memoize.
2.  A dependency array: An array of values that the callback function depends on.

React will return the *same function instance* between renders as long as the dependencies in the array haven't changed. If any dependency changes, `useCallback` will return a new function instance.

**Syntax:**

```jsx
import React, { useState, useCallback } from 'react';

// Child component that is memoized
const Button = React.memo(({ onClick, children }) => {
  console.log('Button rendered', children);
  return <button onClick={onClick}>{children}</button>;
});

function ParentComponent() {
  const [count, setCount] = useState(0);
  const [text, setText] = useState('');

  // Without useCallback, handleIncrement would be a new function on every render
  // const handleIncrement = () => {
  //   setCount(count + 1);
  // };

  // Memoized callback: handleIncrement will only change if 'count' changes
  const handleIncrement = useCallback(() => {
    setCount(prevCount => prevCount + 1);
  }, []); // Empty dependency array: function is created once on initial render

  // Memoized callback: handleReset will only change if 'text' changes
  const handleReset = useCallback(() => {
    setCount(0);
    setText('');
  }, [text]); // Dependency array: function changes if 'text' changes

  return (
    <div>
      <p>Count: {count}</p>
      <input type="text" value={text} onChange={(e) => setText(e.target.value)} />
      <Button onClick={handleIncrement}>Increment</Button>
      <Button onClick={handleReset}>Reset</Button>
      <Button onClick={() => console.log('Inline click')}>Inline Button</Button>
    </div>
  );
}

export default ParentComponent;
```

In this example:

*   `Button` is a memoized child component using `React.memo`. It will only re-render if its props change.
*   `handleIncrement` is memoized with an empty dependency array. It will be the *same function instance* across all renders of `ParentComponent`. Thus, `Button` (Increment) will not re-render when `text` changes.
*   `handleReset` is memoized with `[text]` as a dependency. It will be a *new function instance* if `text` changes. Thus, `Button` (Reset) will re-render when `text` changes.
*   The inline `onClick` for "Inline Button" creates a new function on every render, causing that `Button` to re-render every time `ParentComponent` re-renders.

**Key benefits and considerations:**

*   **Prevents Unnecessary Re-renders:** The main purpose is to maintain referential equality of functions passed as props to `React.memo` (or `PureComponent`) wrapped child components. If the function reference doesn't change, the child component can skip its re-render.
*   **Optimizing `useEffect` Dependencies:** It can also be used to memoize functions that are dependencies of `useEffect` or `useMemo` to prevent those hooks from re-running unnecessarily.
*   **Cost of Memoization:** Like `useMemo`, `useCallback` has a cost. Don't overuse it. Only apply it when you observe performance issues related to function re-creation or when passing callbacks to memoized children.
*   **Correct Dependencies:** Ensure the dependency array is correct. If a memoized callback uses a variable that is not in its dependency array, it might use a stale value (closure over an old value).

`useCallback` is a specialized optimization tool. It's most effective when used in conjunction with `React.memo` to prevent expensive re-renders of child components.

### Write React custom hook useFetch

#### Q1: Write a custom hook useFetch which works like this
`const [{response, error, isLoading}, doFetch] = useFetch('http://localhost:3004/posts')`

Here's an implementation of a `useFetch` custom hook that matches the specified signature and functionality:

```jsx
import { useState, useEffect, useCallback } from 'react';

const useFetch = (initialUrl) => {
  const [url, setUrl] = useState(initialUrl);
  const [response, setResponse] = useState(null);
  const [error, setError] = useState(null);
  const [isLoading, setIsLoading] = useState(false);

  // Memoize the fetch function to prevent unnecessary re-creations
  // and to allow it to be used as a stable dependency in useEffect
  const doFetch = useCallback((options = {}) => {
    // If a new URL is provided in options, update the state
    if (options.url && options.url !== url) {
      setUrl(options.url);
    }
    // This function will trigger the useEffect to run
    // We can also pass options like method, body, headers here
    // For simplicity, we'll just use a flag to trigger the fetch
    // A more robust implementation might use a ref to store options
    // or return a function that takes options directly.
    // For this example, we'll just use the url state.
    setIsLoading(true);
    setError(null); // Clear previous errors on new fetch attempt
  }, [url]); // doFetch changes if the url changes

  useEffect(() => {
    if (!isLoading) return; // Only run effect if a fetch is triggered

    const fetchData = async () => {
      try {
        const res = await fetch(url);
        if (!res.ok) {
          throw new Error(`HTTP error! status: ${res.status}`);
        }
        const json = await res.json();
        setResponse(json);
      } catch (err) {
        setError(err);
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, [isLoading, url]); // Re-run effect when isLoading or url changes

  return [{ response, error, isLoading }, doFetch];
};

export default useFetch;
```

**Explanation:**

1.  **State Variables:**
    *   `url`: Stores the URL to fetch. It's initialized with `initialUrl` and can be updated by `doFetch`.
    *   `response`: Stores the successful data returned from the API.
    *   `error`: Stores any error that occurs during the fetch.
    *   `isLoading`: A boolean flag indicating whether a fetch operation is currently in progress.

2.  **`doFetch` Function (Memoized with `useCallback`):**
    *   This function is returned by the hook and is intended to be called by the component to initiate a fetch. It's memoized using `useCallback` to ensure its reference remains stable unless `url` changes. This is important if `doFetch` is passed to a memoized child component.
    *   When `doFetch` is called, it sets `isLoading` to `true` and clears any previous `error`. This `isLoading` change triggers the `useEffect`.
    *   The `options` parameter allows for dynamic URL changes or passing other fetch options (though for simplicity, this example primarily uses the `url` state for triggering).

3.  **`useEffect` for Data Fetching:**
    *   This `useEffect` hook is responsible for actually performing the `fetch` operation.
    *   It runs whenever `isLoading` becomes `true` (triggered by `doFetch`) or when the `url` changes.
    *   It contains an `async` function `fetchData` to handle the asynchronous API call.
    *   It sets `response` on success, `error` on failure, and `isLoading` back to `false` in the `finally` block.

**How to use it:**

```jsx
import React from 'react';
import useFetch from './useFetch'; // Assuming useFetch.js

function PostList() {
  const [{ response, error, isLoading }, doFetch] = useFetch('http://localhost:3004/posts');

  // Example of triggering a fetch manually (e.g., on button click)
  const handleFetchUsers = () => {
    doFetch({ url: 'http://localhost:3004/users' });
  };

  if (isLoading) {
    return <p>Loading posts...</p>;
  }

  if (error) {
    return <p>Error: {error.message}</p>;
  }

  return (
    <div>
      <h1>Posts</h1>
      <button onClick={() => doFetch()}>Refresh Posts</button>
      <button onClick={handleFetchUsers}>Fetch Users</button>
      {response && response.map(item => (
        <div key={item.id}>
          <h2>{item.title}</h2>
          <p>{item.body}</p>
        </div>
      ))}
    </div>
  );
}

export default PostList;
```

This custom hook encapsulates the logic for data fetching, loading states, and error handling, making components cleaner and more focused on rendering.

### Write React custom hook useLocalStorage

#### Q1: Write a custom hook useLocalStorage which works like this. It must be fully synchronized between local storage and local values.
`const [name, setName] = useLocalStorage('name', 'Jack')`

Here's an implementation of a `useLocalStorage` custom hook that provides synchronized state with `localStorage`:

```jsx
import { useState, useEffect } from 'react';

function useLocalStorage(key, initialValue) {
  // State to store our value
  // Pass initial state function to useState so logic is only executed once
  const [storedValue, setStoredValue] = useState(() => {
    try {
      const item = window.localStorage.getItem(key);
      // Parse stored json or if none return initialValue
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      // If error, return initialValue
      console.warn(`Error reading localStorage key “${key}”:`, error);
      return initialValue;
    }
  });

  // useEffect to update localStorage when the state changes
  useEffect(() => {
    try {
      // Allow value to be a function so we have same API as useState
      const valueToStore = typeof storedValue === 'function'
        ? storedValue(storedValue)
        : storedValue;
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.warn(`Error setting localStorage key “${key}”:`, error);
    }
  }, [key, storedValue]); // Only re-run if key or storedValue changes

  // Function to update state and localStorage
  const setValue = (value) => {
    try {
      // Allow value to be a function so we have same API as useState
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      // Update state
      setStoredValue(valueToStore);
    } catch (error) {
      console.warn(`Error setting localStorage key “${key}”:`, error);
    }
  };

  // Optional: Add event listener for changes from other tabs/windows
  useEffect(() => {
    const handleStorageChange = (event) => {
      if (event.key === key && event.newValue !== null) {
        try {
          setStoredValue(JSON.parse(event.newValue));
        } catch (error) {
          console.warn(`Error parsing localStorage change for key “${key}”:`, error);
        }
      } else if (event.key === key && event.newValue === null) {
        // Handle item removal from localStorage
        setStoredValue(initialValue);
      }
    };

    window.addEventListener('storage', handleStorageChange);

    return () => {
      window.removeEventListener('storage', handleStorageChange);
    };
  }, [key, initialValue]); // Re-run if key or initialValue changes

  return [storedValue, setValue];
}

export default useLocalStorage;
```

**Explanation:**

1.  **`useState` for Local Value:**
    *   The `useState` hook is used to manage the component's local state (`storedValue`).
    *   The initial state is determined by a function passed to `useState`. This function attempts to read the value from `localStorage` using the provided `key`. If found, it parses the JSON; otherwise, it uses the `initialValue`. This ensures the value is loaded from `localStorage` only once on the initial render.
    *   Error handling is included for `localStorage` access.

2.  **`useEffect` for Synchronizing State to `localStorage`:**
    *   This `useEffect` hook runs whenever `key` or `storedValue` changes.
    *   It stringifies the `storedValue` (handling functional updates similar to `useState`) and saves it to `localStorage` under the given `key`.
    *   This keeps `localStorage` in sync with the component's state.

3.  **`setValue` Function:**
    *   This is the setter function returned by the hook, similar to `useState`'s setter.
    *   It updates the component's `storedValue` state. The `useEffect` above then handles writing this new value to `localStorage`.
    *   It also supports functional updates (e.g., `setName(prevName => prevName + ' Jr.')`).

4.  **`useEffect` for Cross-Tab/Window Synchronization (Optional but important for "fully synchronized"):**
    *   This `useEffect` adds an event listener for the `storage` event. This event fires when a `localStorage` item is changed in *another* tab or window of the same origin.
    *   When the `storage` event occurs for the specific `key` this hook is watching, it updates the component's `storedValue` to reflect the change, ensuring synchronization across multiple open tabs/windows.
    *   It includes a cleanup function to remove the event listener when the component unmounts.

**How to use it:**

```jsx
import React from 'react';
import useLocalStorage from './useLocalStorage'; // Assuming useLocalStorage.js

function UserSettings() {
  const [name, setName] = useLocalStorage('userName', 'Guest');
  const [age, setAge] = useLocalStorage('userAge', 25);
  const [isDarkMode, setIsDarkMode] = useLocalStorage('darkMode', false);

  return (
    <div>
      <h1>User Settings</h1>
      <div>
        <label>Name:</label>
        <input
          type="text"
          value={name}
          onChange={(e) => setName(e.target.value)}
        />
        <p>Hello, {name}!</p>
      </div>
      <div>
        <label>Age:</label>
        <input
          type="number"
          value={age}
          onChange={(e) => setAge(Number(e.target.value))}
        />
        <p>You are {age} years old.</p>
      </div>
      <div>
        <label>
          <input
            type="checkbox"
            checked={isDarkMode}
            onChange={(e) => setIsDarkMode(e.target.checked)}
          />
          Dark Mode
        </label>
        <p>Dark Mode is {isDarkMode ? 'enabled' : 'disabled'}.</p>
      </div>
    </div>
  );
}

export default UserSettings;
```

This hook provides a robust and convenient way to manage state that needs to be persisted in `localStorage` and synchronized across browser tabs.

### React.memo - rendering optimisation in React

#### Q1: Do you know how React.memo works?

`React.memo` is a higher-order component (HOC) in React that provides a way to optimize functional components by preventing unnecessary re-renders. It's similar to `PureComponent` for class components.

**How it works:**

When a component is wrapped with `React.memo`, React will "memoize" the rendered output of that component. This means that React will skip rendering the component if its props have not changed since the last render. It does this by performing a shallow comparison of the component's props.

**Mechanism:**

1.  When the parent component re-renders, React checks if the props passed to the `React.memo` wrapped child component are the same as the props from the previous render.
2.  If the props are shallowly equal (meaning primitive values are the same, and object/array references are the same), React reuses the last rendered result and skips executing the component's function body, thus avoiding re-rendering the component and its subtree.
3.  If the props are different, the component re-renders as usual.

**Example:**

```jsx
import React, { useState } from 'react';

// Child component wrapped with React.memo
const MyMemoizedComponent = React.memo(({ name, age }) => {
  console.log('MyMemoizedComponent rendered');
  return (
    <div>
      <p>Name: {name}</p>
      <p>Age: {age}</p>
    </div>
  );
});

function ParentComponent() {
  const [count, setCount] = useState(0);
  const [userName, setUserName] = useState('Alice');

  return (
    <div>
      <h1>Parent Count: {count}</h1>
      <button onClick={() => setCount(count + 1)}>Increment Parent Count</button>
      <button onClick={() => setUserName('Bob')}>Change User Name</button>

      {/* MyMemoizedComponent will only re-render if 'userName' or 'age' props change */}
      <MyMemoizedComponent name={userName} age={30} />

      {/* This component will re-render every time ParentComponent re-renders */}
      <div>
        <p>This part always re-renders with parent.</p>
      </div>
    </div>
  );
}

export default ParentComponent;
```

In this example, if you click "Increment Parent Count", `ParentComponent` re-renders, but `MyMemoizedComponent` will *not* re-render because its `name` and `age` props haven't changed. If you click "Change User Name", `userName` changes, causing `MyMemoizedComponent` to re-render.

**When to use `React.memo`:**

*   When your component renders the same output given the same props.
*   When your component is expensive to render.
*   When its parent component re-renders frequently, but the child's props often remain the same.

**Important considerations:**

*   **Shallow Comparison:** `React.memo` performs a shallow comparison of props. If props are objects or arrays, a new reference (even with the same content) will cause a re-render. This is where `useMemo` and `useCallback` become useful to stabilize object/array/function references.
*   **Cost of Memoization:** Memoization itself has a cost (the cost of the shallow comparison). Don't overuse `React.memo` on every component, as it can sometimes lead to *more* overhead than simply re-rendering a small component.
*   **Context Changes:** If a component wrapped with `React.memo` uses `useContext`, it will still re-render when the context value changes, regardless of prop changes.

#### Q2: How to add a comparator to it?

By default, `React.memo` performs a shallow comparison of props. However, you can provide a custom comparison function as the second argument to `React.memo` if you need more control over when the component should re-render. This function receives the `prevProps` and `nextProps` as arguments and should return `true` if the props are equal (i.e., the component should *not* re-render) and `false` if the props are different (i.e., the component *should* re-render).

**Syntax:**

```jsx
import React from 'react';

const MyCustomMemoizedComponent = React.memo(
  ({ list }) => {
    console.log('MyCustomMemoizedComponent rendered');
    return (
      <ul>
        {list.map((item) => (
          <li key={item.id}>{item.name}</li>
        ))}
      </ul>
    );
  },
  (prevProps, nextProps) => {
    // Custom comparison function
    // Return true if props are equal (don't re-render)
    // Return false if props are different (re-render)

    // Example: Deep compare a 'list' prop (array of objects)
    if (prevProps.list.length !== nextProps.list.length) {
      return false; // Length changed, so re-render
    }
    for (let i = 0; i < prevProps.list.length; i++) {
      if (prevProps.list[i].id !== nextProps.list[i].id ||
          prevProps.list[i].name !== nextProps.list[i].name) {
        return false; // Item content changed, so re-render
      }
    }
    return true; // All items are the same, don't re-render
  }
);

function ParentWithCustomMemo() {
  const [count, setCount] = React.useState(0);
  const [items, setItems] = React.useState([
    { id: 1, name: 'Item A' },
    { id: 2, name: 'Item B' },
  ]);

  const addItem = () => {
    setItems(prevItems => [...prevItems, { id: prevItems.length + 1, name: `Item ${String.fromCharCode(65 + prevItems.length)}` }]);
  };

  const changeItemName = () => {
    setItems(prevItems => prevItems.map(item =>
      item.id === 1 ? { ...item, name: 'Changed Item A' } : item
    ));
  };

  return (
    <div>
      <h1>Parent Count: {count}</h1>
      <button onClick={() => setCount(count + 1)}>Increment Parent Count</button>
      <button onClick={addItem}>Add Item</button>
      <button onClick={changeItemName}>Change Item A Name</button>
      <MyCustomMemoizedComponent list={items} />
    </div>
  );
}

export default ParentWithCustomMemo;
```

In this example, `MyCustomMemoizedComponent` will only re-render if the `list` prop actually changes in content (deep comparison), not just if its reference changes. If you click "Increment Parent Count", `MyCustomMemoizedComponent` will not re-render. If you click "Add Item" or "Change Item A Name", it will re-render because the `list` content changes.

**When to use a custom comparator:**

*   When the default shallow comparison is not sufficient for your props (e.g., deeply nested objects or arrays).
*   When you need to optimize for specific prop changes that a shallow comparison would miss or incorrectly trigger a re-render.

**Caution:** Writing a custom comparison function can be more complex and error-prone than relying on the default shallow comparison. Ensure your comparison logic is correct and efficient, as an inefficient comparison function can negate the performance benefits of `React.memo`.

### What is the best React file structure?

#### Q1: What ways of structuring files in React applications do you know?

There isn't a single "best" React file structure, as the optimal choice often depends on the project's size, complexity, team size, and specific requirements. However, several common patterns have emerged, each with its own advantages. As a staff frontend engineer, I've worked with and advocate for structures that prioritize maintainability, scalability, and developer experience.

Here are some popular and effective ways of structuring files in React applications:

1.  **Feature-First (or Domain-Driven) Structure:**
    This is often considered the most scalable and maintainable approach for larger applications. Files are grouped by feature or domain, meaning all components, styles, tests, and logic related to a specific feature reside in the same directory.

    ```
    src/
    ├── components/         # Reusable, generic UI components (e.g., Button, Modal)
    │   ├── Button/
    │   │   ├── Button.jsx
    │   │   ├── Button.module.css
    │   │   └── Button.test.js
    │   └── Modal/
    │       ├── Modal.jsx
    │       └── Modal.test.js
    ├── features/           # Application-specific features/domains
    │   ├── Auth/
    │   │   ├── components/ # Auth-specific components
    │   │   │   ├── LoginForm.jsx
    │   │   │   └── RegisterForm.jsx
    │   │   ├── hooks/      # Auth-specific hooks
    │   │   │   └── useAuth.js
    │   │   ├── pages/      # Auth-related pages/routes
    │   │   │   ├── LoginPage.jsx
    │   │   │   └── SignupPage.jsx
    │   │   ├── services/   # Auth API calls
    │   │   │   └── authService.js
    │   │   └── AuthProvider.jsx # Context provider
    │   ├── Products/
    │   │   ├── components/
    │   │   ├── hooks/
    │   │   ├── pages/
    │   │   └── services/
    │   └── Users/
    │       ├── components/
    │       └── pages/
    ├── app/
    │   ├── App.jsx
    │   ├── index.js
    │   └── App.css
    ├── hooks/              # Global/reusable hooks (e.g., useDebounce)
    ├── utils/              # Utility functions (e.g., formatters, validators)
    ├── services/           # Global API services (if not feature-specific)
    ├── assets/             # Images, fonts, icons
    └── styles/             # Global styles, variables
    ```

    **Pros:** Excellent for large teams and large applications, easy to find related code, promotes encapsulation, simplifies code splitting.
    **Cons:** Can feel redundant for very small projects, might require more initial setup.

2.  **Type-First (or Folder-by-Type) Structure:**
    This is a common structure for smaller to medium-sized applications, where files are grouped by their technical type (e.g., all components in one folder, all hooks in another).

    ```
    src/
    ├── components/
    │   ├── Button.jsx
    │   ├── Header.jsx
    │   └── UserCard.jsx
    ├── pages/
    │   ├── HomePage.jsx
    │   ├── AboutPage.jsx
    │   └── ProductPage.jsx
    ├── hooks/
    │   ├── useAuth.js
    │   └── useCounter.js
    ├── services/
    │   ├── authService.js
    │   └── productService.js
    ├── utils/
    │   ├── helpers.js
    │   └── validators.js
    ├── assets/
    ├── styles/
    ├── App.jsx
    └── index.js
    ```

    **Pros:** Simple to understand for beginners, easy to locate a specific type of file.
    **Cons:** Can lead to large, unwieldy directories as the application grows, harder to understand feature context at a glance, less scalable for large applications.

3.  **Atomic Design Principles:**
    This approach structures files based on the principles of Atomic Design (Atoms, Molecules, Organisms, Templates, Pages). It's more of a conceptual model for UI components but can influence file structure.

    ```
    src/
    ├── atoms/      # Smallest UI elements (e.g., Button, Input, Text)
    ├── molecules/  # Groups of atoms (e.g., SearchBar, LoginForm)
    ├── organisms/  # Groups of molecules and/or atoms (e.g., Header, Footer, ProductGrid)
    ├── templates/  # Page-level layouts (e.g., TwoColumnLayout)
    ├── pages/      # Instances of templates with real content (e.g., HomePage, ProductPage)
    ├── hooks/
    ├── services/
    └── App.jsx
    ```

    **Pros:** Promotes highly reusable components, clear hierarchy of UI elements, good for design systems.
    **Cons:** Can be overly rigid for some projects, learning curve for the terminology.

**General Recommendations:**

*   **Start Simple, Evolve:** For small projects, a type-first structure might be sufficient. As the project grows, refactor towards a feature-first approach.
*   **Consistency is Key:** Whatever structure you choose, ensure the entire team adheres to it consistently.
*   **Flat is Better Than Deep:** Avoid excessively deep nesting of folders.
*   **Colocation:** Keep related files (component, styles, tests, stories) together.
*   **Absolute Imports:** Configure your build system (Webpack, Vite) to allow absolute imports (e.g., `import Button from 'components/Button'`) to avoid long relative paths (`../../../components/Button`).

For most modern, medium to large-scale React applications, the **Feature-First** structure combined with a separate `components` folder for truly generic UI elements is often the most effective and scalable approach.

### How does React router work?

#### Q1: What do you know about routing?

**Routing** in web applications refers to the mechanism that maps URLs to specific views or components within the application. In traditional multi-page applications (MPAs), routing is handled by the server, which serves a new HTML page for each URL request. In Single-Page Applications (SPAs), like those built with React, routing is primarily handled on the client-side (browser) to provide a seamless, app-like experience without full page reloads.

Key concepts in client-side routing:

*   **URL Management:** The router manages the browser's URL, allowing users to navigate between different
    views without a full page refresh.
*   **History API:** Modern client-side routers leverage the browser's History API (`pushState`, `replaceState`, `popstate` event) to manipulate the URL without triggering a server request.
*   **Component Mapping:** The router maps specific URL paths to corresponding React components that should be rendered.
*   **Navigation:** Provides programmatic navigation (e.g., redirecting users after login) and declarative navigation (e.g., `<Link>` components).
*   **Nested Routes:** Allows for hierarchical routing, where parts of the UI are rendered based on nested URL segments.
*   **Route Parameters:** Enables dynamic segments in URLs (e.g., `/users/:id`) to pass data to components.
*   **Query Parameters:** Handles query strings (e.g., `/search?q=react`) for filtering or searching.

#### Q2: How react-router is working?

**React Router** is the most popular declarative routing library for React. It enables you to build single-page applications with multiple views that can be navigated using the browser's URL. It works by keeping your UI in sync with the URL.

Here's a breakdown of how React Router typically works:

1.  **Installation:** You install it via npm or yarn (`react-router-dom`).
2.  **`BrowserRouter` (or `HashRouter`):** You wrap your entire application (or the part that needs routing) with a router component, usually `<BrowserRouter>`. This component uses the HTML5 History API to keep your UI in sync with the URL.
    ```jsx
    import { BrowserRouter as Router } from 'react-router-dom';
    // ...
    <Router>
      <App />
    </Router>
    ```
3.  **`Routes` and `Route`:**
    *   The `<Routes>` component is used to group `<Route>` components. It looks through all its children `<Route>` elements and renders the first one that matches the current URL.
    *   The `<Route>` component is responsible for rendering a specific UI component when its `path` prop matches the current URL.

    ```jsx
    import { Routes, Route } from 'react-router-dom';
    import HomePage from './HomePage';
    import AboutPage from './AboutPage';
    import UserProfile from './UserProfile';

    function AppRoutes() {
      return (
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/about" element={<AboutPage />} />
          <Route path="/users/:id" element={<UserProfile />} />
          {/* Catch-all route for 404 */} 
          <Route path="*" element={<div>404 Not Found</div>} />
        </Routes>
      );
    }
    ```
4.  **`Link` for Navigation:**
    Instead of using standard `<a>` tags (which would trigger a full page reload), React Router provides the `<Link>` component. When a `<Link>` is clicked, React Router intercepts the event, updates the URL using the History API, and then re-renders the appropriate component without a full page refresh.

    ```jsx
    import { Link } from 'react-router-dom';

    function Navigation() {
      return (
        <nav>
          <Link to="/">Home</Link>
          <Link to="/about">About</Link>
          <Link to="/users/123">User 123</Link>
        </nav>
      );
    }
    ```
5.  **`useParams`, `useNavigate`, `useLocation` Hooks:**
    React Router provides hooks for functional components to access routing information:
    *   `useParams()`: Extracts dynamic parameters from the URL (e.g., `id` from `/users/:id`).
    *   `useNavigate()`: Returns a function to programmatically navigate (e.g., `navigate('/dashboard')`).
    *   `useLocation()`: Returns the current `location` object, which contains information about the current URL.

**Key principles:**

*   **Declarative:** You declare *what* routes exist and *what* components they render, rather than imperatively manipulating the URL.
*   **Component-based:** Routes are components, making them easy to integrate into your React application structure.
*   **Dynamic Routing:** Routes can be rendered conditionally or nested, allowing for complex UI layouts.

### What is React portals?

#### Q1: What do you know about react-portals?

**React Portals** provide a way to render children into a DOM node that exists outside the DOM hierarchy of the parent component. Normally, a component's `render` method returns JSX that React renders as a child of the component's own DOM node. However, with Portals, you can
"teleport" that JSX to a different part of the DOM tree.

**Why use Portals?**

The primary use case for Portals is when a child component needs to visually break out of its parent container. This is common for UI elements like:

*   **Modals / Dialogs:** You want a modal to overlay the entire screen, regardless of where the modal component is deeply nested in the component tree. If it's not a portal, CSS properties like `overflow: hidden` or `z-index` on parent elements can clip or hide the modal.
*   **Tooltips / Popovers:** Similar to modals, tooltips need to appear above other content and shouldn't be constrained by parent containers.
*   **Dropdown Menus:** Ensuring dropdowns don't get cut off by parent boundaries.

**How it works:**

You use `ReactDOM.createPortal(child, container)`.

*   `child`: Any renderable React child (an element, string, or fragment).
*   `container`: A DOM element where you want the `child` to be rendered.

Even though a portal can be anywhere in the DOM tree, it behaves like a normal React child in every other way. Features like context work exactly the same regardless of whether the child is a portal, as the portal still exists in the *React tree* regardless of its position in the *DOM tree*. This includes event bubbling; an event fired from inside a portal will propagate to ancestors in the containing React tree, even if those elements are not ancestors in the DOM tree.

#### Q2: Create an example

Here is an example of creating a simple Modal component using a React Portal.

First, you need a target container in your `index.html` (outside the main `root` div):

```html
<!-- public/index.html -->
<body>
  <noscript>You need to enable JavaScript to run this app.</noscript>
  <div id="root"></div>
  <!-- Add a container for portals -->
  <div id="modal-root"></div>
</body>
```

Then, create the Modal component:

```jsx
// Modal.jsx
import React from 'react';
import ReactDOM from 'react-dom';

const Modal = ({ isOpen, onClose, children }) => {
  if (!isOpen) return null;

  // Find the portal container in the DOM
  const modalRoot = document.getElementById('modal-root');

  // The UI for the modal
  const modalContent = (
    <div style={styles.overlay}>
      <div style={styles.modal}>
        <button onClick={onClose} style={styles.closeButton}>
          Close
        </button>
        {children}
      </div>
    </div>
  );

  // Render the modalContent into the modalRoot DOM node
  return ReactDOM.createPortal(modalContent, modalRoot);
};

// Simple inline styles for demonstration
const styles = {
  overlay: {
    position: 'fixed',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 1000, // Ensure it's on top
  },
  modal: {
    backgroundColor: 'white',
    padding: '20px',
    borderRadius: '8px',
    minWidth: '300px',
    position: 'relative',
  },
  closeButton: {
    position: 'absolute',
    top: '10px',
    right: '10px',
  },
};

export default Modal;
```

Finally, use the Modal in a parent component:

```jsx
// App.jsx
import React, { useState } from 'react';
import Modal from './Modal';

function App() {
  const [isModalOpen, setIsModalOpen] = useState(false);

  return (
    <div style={{ padding: '50px', border: '2px solid red', overflow: 'hidden' }}>
      <h1>React Portals Example</h1>
      <p>This container has overflow: hidden, but the modal will still escape it.</p>
      
      <button onClick={() => setIsModalOpen(true)}>Open Modal</button>

      <Modal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)}>
        <h2>Hello from the Portal!</h2>
        <p>I am rendered outside the main React root DOM node.</p>
      </Modal>
    </div>
  );
}

export default App;
```

In this example, even though the `<Modal>` is rendered inside a `<div>` with `overflow: hidden` in the React tree, the actual DOM nodes for the modal are appended to the `#modal-root` element, allowing it to display correctly over the entire screen.

### What is React lazy and React suspense?

#### Q1: What do you know about React lazy and suspense?

`React.lazy` and `React.Suspense` are features introduced in React 16.6 that enable **code-splitting** and **lazy loading** of components. They are crucial for optimizing the performance of large React applications by reducing the initial bundle size.

**Code-Splitting:**

In a typical React app, tools like Webpack bundle all your JavaScript files into one large file. If the app is large, this bundle can take a long time to download, delaying the initial render (Time to Interactive). Code-splitting allows you to split this large bundle into smaller chunks that can be loaded on demand.

**`React.lazy`:**

`React.lazy` is a function that lets you render a dynamic import as a regular component. It makes it easy to create components that are loaded only when they are first rendered.

*   It takes a function that must call a dynamic `import()`.
*   This `import()` must return a Promise which resolves to a module with a `default` export containing a React component.

**`React.Suspense`:**

When a component is loaded lazily using `React.lazy`, there is a delay while the code is being fetched over the network. `React.Suspense` is a component that lets you specify a fallback UI (like a loading spinner) to display while the lazy component is loading.

*   You wrap the lazy component (or a tree containing lazy components) with `<Suspense>`.
*   You provide a `fallback` prop to `<Suspense>`, which is the React element to render while waiting.

**Example:**

```jsx
import React, { Suspense } from 'react';

// 1. Dynamically import the component using React.lazy
// This component will not be included in the main bundle.
// It will be fetched in a separate chunk when it's needed.
const HeavyComponent = React.lazy(() => import('./HeavyComponent'));

function App() {
  return (
    <div>
      <h1>My App</h1>
      
      {/* 2. Wrap the lazy component in Suspense */}
      {/* The fallback UI is shown while HeavyComponent is downloading */}
      <Suspense fallback={<div>Loading heavy component...</div>}>
        <HeavyComponent />
      </Suspense>
    </div>
  );
}

export default App;
```

**Common Use Cases:**

*   **Route-based code splitting:** This is the most common use case. You lazy load the components for different routes so that users only download the code for the page they are currently visiting.
*   **Loading heavy components conditionally:** If you have a complex component (like a large chart, a rich text editor, or a complex modal) that isn't always visible, you can lazy load it only when the user interacts with the feature that requires it.

**Important Notes:**

*   `React.lazy` currently only supports default exports. If the module you want to import uses named exports, you need to create an intermediate module that re-exports it as the default.
*   `Suspense` can wrap multiple lazy components. It will show the fallback until *all* lazy components within its tree have loaded.
*   In modern React (React 18+), `Suspense` is also being integrated with data fetching (Suspense for Data Fetching), allowing you to use the same declarative loading state mechanism for both code and data.

### How does Typescript work in React?

#### Q1: Do you know how to use Typescript together with React?

Yes, using TypeScript with React is highly recommended for building robust and maintainable applications, especially at scale. TypeScript adds static typing to JavaScript, which helps catch errors during development rather than at runtime, improves code editor autocompletion (IntelliSense), and serves as excellent documentation.

Here's how TypeScript works and is used in React:

**1. Setup:**

Modern build tools make it easy to start a React project with TypeScript.
*   **Create React App:** `npx create-react-app my-app --template typescript`
*   **Vite:** `npm create vite@latest my-app -- --template react-ts`
*   **Next.js:** `npx create-next-app@latest --ts`

These tools configure the necessary `tsconfig.json` and set up the build pipeline to compile TypeScript (`.ts` and `.tsx` files) into JavaScript.

**2. Typing Props:**

The most common use of TypeScript in React is defining the shape of the `props` a component expects. You typically use an `interface` or a `type` alias for this.

```tsx
import React from 'react';

// Define the shape of the props
interface UserCardProps {
  name: string;
  age: number;
  isOnline?: boolean; // Optional prop
  onMessageClick: (userId: string) => void; // Function prop
}

// Apply the type to the functional component
const UserCard: React.FC<UserCardProps> = ({ name, age, isOnline = false, onMessageClick }) => {
  return (
    <div>
      <h2>{name}</h2>
      <p>Age: {age}</p>
      <p>Status: {isOnline ? 'Online' : 'Offline'}</p>
      <button onClick={() => onMessageClick('user-123')}>Send Message</button>
    </div>
  );
};

export default UserCard;
```
*Note: While `React.FC` (or `React.FunctionComponent`) was common, it's often preferred now to just type the props directly in the function signature: `const UserCard = ({ name, age }: UserCardProps) => { ... }` as it's simpler and avoids implicit `children` typing issues.*

**3. Typing State (`useState`):**

TypeScript can often infer the type of state based on the initial value. However, if the state can be null initially or is a complex object, you should explicitly provide the type parameter to `useState`.

```tsx
import React, { useState } from 'react';

interface User {
  id: number;
  username: string;
}

function UserProfile() {
  // TypeScript infers 'count' is a number
  const [count, setCount] = useState(0); 

  // Explicitly type state that might be null initially
  const [user, setUser] = useState<User | null>(null);

  // Explicitly type an array of objects
  const [items, setItems] = useState<string[]>([]);

  return (
    // ...
  );
}
```

**4. Typing Events:**

When handling DOM events (like clicks, input changes), you need to type the event object. React provides specific types for these events.

```tsx
import React, { useState, ChangeEvent, MouseEvent } from 'react';

function Form() {
  const [inputValue, setInputValue] = useState('');

  // Type for an input change event
  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    setInputValue(e.target.value);
  };

  // Type for a button click event
  const handleSubmit = (e: MouseEvent<HTMLButtonElement>) => {
    e.preventDefault();
    console.log('Submitted:', inputValue);
  };

  return (
    <form>
      <input type="text" value={inputValue} onChange={handleChange} />
      <button onClick={handleSubmit}>Submit</button>
    </form>
  );
}
```

**5. Typing Hooks (`useRef`, `useReducer`, `useContext`):**

*   **`useRef`:** You provide the type of the DOM element or the mutable value it will hold.
    ```tsx
    const inputRef = useRef<HTMLInputElement>(null);
    ```
*   **`useReducer`:** You define types for the State and the Action.
    ```tsx
    type State = { count: number };
    type Action = { type: 'increment' } | { type: 'decrement' } | { type: 'reset', payload: number };
    // ... const [state, dispatch] = useReducer(reducer, initialState);
    ```
*   **`useContext`:** You define the type of the context value when creating it.
    ```tsx
    interface ThemeContextType { theme: string; toggleTheme: () => void; }
    const ThemeContext = createContext<ThemeContextType | undefined>(undefined);
    ```

**Benefits of TypeScript in React:**

*   **Early Error Detection:** Catches typos, missing props, and incorrect data types before you even run the code.
*   **Better Refactoring:** When you change a component's props or state shape, TypeScript immediately highlights all the places in your codebase that need to be updated.
*   **Enhanced Developer Experience:** Provides excellent autocomplete and inline documentation in editors like VS Code.
*   **Self-Documenting Code:** The types serve as a clear contract for how components and functions should be used.

### What are high order components? (HOC)

#### Q1: Do you know what are high order components?

A **Higher-Order Component (HOC)** is an advanced technique in React for reusing component logic. It is not a part of the React API per se, but rather a pattern that emerges from React's compositional nature.

**Definition:**

A Higher-Order Component is a function that takes a component and returns a new component.

```javascript
const EnhancedComponent = higherOrderComponent(WrappedComponent);
```

While a normal component transforms props into UI, a higher-order component transforms a component into another component.

**Why use HOCs?**

Before React Hooks were introduced, HOCs (along with Render Props) were the primary way to share stateful logic or side effects between multiple components. Common use cases included:

*   **Cross-cutting concerns:** Applying the same logic to many components (e.g., logging, analytics tracking).
*   **State abstraction and manipulation:** Managing state that needs to be shared (e.g., connecting a component to a Redux store, managing form state).
*   **Prop manipulation:** Adding, modifying, or removing props before passing them to the wrapped component.
*   **Conditional rendering:** Rendering the wrapped component only if certain conditions are met (e.g., requiring authentication).

**Example: An Authentication HOC**

Imagine you have several components that should only be visible to logged-in users. Instead of duplicating the authentication check in every component, you can create an HOC.

```jsx
import React from 'react';

// The HOC function
const withAuth = (WrappedComponent) => {
  // It returns a new component
  return function WithAuthComponent(props) {
    // Logic: Check if user is authenticated (e.g., from local storage or context)
    const isAuthenticated = localStorage.getItem('token') !== null;

    if (!isAuthenticated) {
      // If not authenticated, redirect or show a message
      return <div>Please log in to view this content.</div>;
    }

    // If authenticated, render the wrapped component and pass through all props
    return <WrappedComponent {...props} />;
  };
};

// A regular component
const Dashboard = ({ user }) => {
  return <h1>Welcome to the Dashboard, {user}!</h1>;
};

// Enhance the component using the HOC
const ProtectedDashboard = withAuth(Dashboard);

export default ProtectedDashboard;
```

**HOCs vs. Hooks:**

With the introduction of React Hooks (like `useState`, `useEffect`, `useContext`, and custom hooks), the need for HOCs has significantly diminished. Custom hooks provide a much cleaner, more composable, and less deeply-nested way to share logic.

*   **Hooks are generally preferred** for sharing stateful logic because they don't introduce extra nodes into the component tree (avoiding "wrapper hell") and are easier to type with TypeScript.
*   **HOCs are still useful** in specific scenarios, particularly when you need to wrap a component to inject props based on external data sources (like `connect` in older Redux codebases) or when integrating with third-party libraries that rely on the HOC pattern. However, even Redux now strongly recommends using its Hooks API (`useSelector`, `useDispatch`).

### Write an example of form inside React

#### Q1: How would you create a register form in React?

Creating a form in React typically involves managing the form's state using controlled components. In a controlled component, the form data is handled by the React component's state, making React the "single source of truth."

Here is an example of a robust registration form using functional components and the `useState` hook.

```jsx
import React, { useState } from 'react';

function RegisterForm() {
  // 1. Define state for form fields
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    password: '',
    confirmPassword: '',
  });

  // 2. Define state for errors and submission status
  const [errors, setErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitSuccess, setSubmitSuccess] = useState(false);

  // 3. Handle input changes
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prevData) => ({
      ...prevData,
      [name]: value,
    }));
    // Clear error for the field being edited
    if (errors[name]) {
      setErrors((prevErrors) => ({ ...prevErrors, [name]: '' }));
    }
  };

  // 4. Validate the form
  const validate = () => {
    const newErrors = {};
    if (!formData.username.trim()) newErrors.username = 'Username is required';
    if (!formData.email.trim()) {
      newErrors.email = 'Email is required';
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = 'Email is invalid';
    }
    if (!formData.password) {
      newErrors.password = 'Password is required';
    } else if (formData.password.length < 6) {
      newErrors.password = 'Password must be at least 6 characters';
    }
    if (formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = 'Passwords do not match';
    }
    return newErrors;
  };

  // 5. Handle form submission
  const handleSubmit = async (e) => {
    e.preventDefault(); // Prevent default browser form submission
    
    const validationErrors = validate();
    if (Object.keys(validationErrors).length > 0) {
      setErrors(validationErrors);
      return;
    }

    setIsSubmitting(true);
    setErrors({});

    try {
      // Simulate an API call
      await new Promise((resolve) => setTimeout(resolve, 1500));
      
      console.log('Form submitted successfully:', formData);
      setSubmitSuccess(true);
      // Reset form (optional)
      // setFormData({ username: '', email: '', password: '', confirmPassword: '' });
    } catch (error) {
      setErrors({ submit: 'Failed to register. Please try again.' });
    } finally {
      setIsSubmitting(false);
    }
  };

  if (submitSuccess) {
    return (
      <div className="success-message">
        <h2>Registration Successful!</h2>
        <p>Welcome, {formData.username}.</p>
      </div>
    );
  }

  return (
    <div className="register-form-container">
      <h2>Register</h2>
      <form onSubmit={handleSubmit}>
        
        <div className="form-group">
          <label htmlFor="username">Username:</label>
          <input
            type="text"
            id="username"
            name="username"
            value={formData.username}
            onChange={handleChange}
            disabled={isSubmitting}
          />
          {errors.username && <span className="error">{errors.username}</span>}
        </div>

        <div className="form-group">
          <label htmlFor="email">Email:</label>
          <input
            type="email"
            id="email"
            name="email"
            value={formData.email}
            onChange={handleChange}
            disabled={isSubmitting}
          />
          {errors.email && <span className="error">{errors.email}</span>}
        </div>

        <div className="form-group">
          <label htmlFor="password">Password:</label>
          <input
            type="password"
            id="password"
            name="password"
            value={formData.password}
            onChange={handleChange}
            disabled={isSubmitting}
          />
          {errors.password && <span className="error">{errors.password}</span>}
        </div>

        <div className="form-group">
          <label htmlFor="confirmPassword">Confirm Password:</label>
          <input
            type="password"
            id="confirmPassword"
            name="confirmPassword"
            value={formData.confirmPassword}
            onChange={handleChange}
            disabled={isSubmitting}
          />
          {errors.confirmPassword && <span className="error">{errors.confirmPassword}</span>}
        </div>

        {errors.submit && <div className="error global-error">{errors.submit}</div>}

        <button type="submit" disabled={isSubmitting}>
          {isSubmitting ? 'Registering...' : 'Register'}
        </button>
      </form>
    </div>
  );
}

export default RegisterForm;
```

**Key aspects of this implementation:**

*   **Controlled Components:** The `value` of each input is tied to the `formData` state, and the `onChange` handler updates that state.
*   **Single State Object:** Using a single object for `formData` is often cleaner than having separate `useState` hooks for every field, especially for larger forms.
*   **Validation:** A `validate` function checks the data before submission and populates an `errors` state object.
*   **Error Handling:** Inline error messages are displayed below the relevant fields if validation fails.
*   **Loading State:** The `isSubmitting` state disables the inputs and the submit button while the simulated API call is in progress, preventing double submissions.

For very complex forms with deep validation requirements, using a library like **React Hook Form** or **Formik** combined with a validation schema library like **Yup** or **Zod** is highly recommended in professional environments.

### Why does strict mode renders twice in React?

#### Q1: What is strict mode?

`React.StrictMode` is a tool for highlighting potential problems in an application. Like `Fragment`, `StrictMode` does not render any visible UI. It activates additional checks and warnings for its descendants.

You typically wrap your entire application (or a part of it) in `StrictMode` during development:

```jsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
```

**What Strict Mode checks for:**

*   Identifying components with unsafe lifecycles (in older class components).
*   Warning about legacy string ref API usage.
*   Warning about deprecated `findDOMNode` usage.
*   Detecting unexpected side effects (this is the reason for the double render).
*   Detecting legacy context API.
*   Ensuring reusable state (React 18 feature).

**Important:** Strict Mode checks are run in **development mode only**; they do not impact the production build.

#### Q2: Why does strict mode renders twice in React?

In development mode, when a component is wrapped in `<React.StrictMode>`, React intentionally **double-invokes** certain functions, including:

*   Class component `constructor`, `render`, and `shouldComponentUpdate` methods.
*   Class component static `getDerivedStateFromProps` method.
*   Function component bodies (the render phase).
*   State updater functions (the first argument to `setState`).
*   Functions passed to `useState`, `useMemo`, or `useReducer`.

**Why does React do this?**

The primary reason is to **detect unexpected side effects** in the render phase.

React assumes that the render phase (the part where your component function runs and returns JSX) should be **pure**. A pure function is one that, given the same inputs, always returns the same output and does not produce any observable side effects (like mutating external variables, making API calls, or directly manipulating the DOM).

Side effects should only happen in the "commit phase" (e.g., inside `useEffect` or event handlers).

By rendering components twice in development, React makes it much more obvious if your render function is impure. If a component has a side effect in its render body (e.g., pushing an item to an external array), that side effect will happen twice, making the bug immediately apparent to the developer.

**Example of catching a bug:**

```jsx
let externalArray = [];

function BadComponent() {
  // BAD: Side effect in the render phase!
  externalArray.push('rendered'); 

  return <div>Check the console</div>;
}
```

Without Strict Mode, `externalArray` would have one item after the first render. With Strict Mode, it will have two items, immediately alerting the developer that the render function is not pure.

React suppresses the `console.log` output for the second render to avoid cluttering the console, but the code itself is executed twice.

### Do I need to rewrite all my class components with hooks?

#### Q1: Do you want to rewrite all our classes components with hooks?

As a staff engineer, my answer is generally **No, you do not need to rewrite all existing, working class components with Hooks.**

React strongly guarantees backwards compatibility. Class components are not deprecated, and there are no plans to remove them from React. If a class component is working perfectly fine, is well-tested, and doesn't require new features, rewriting it just for the sake of using Hooks is often a poor use of engineering time and introduces unnecessary risk (potential regressions).

**When *should* you rewrite a class component to a functional component with Hooks?**

1.  **When you need to add significant new features or modify complex logic:** If you are already going to touch the component heavily, refactoring it to use Hooks can make the new logic easier to implement and test.
2.  **When the class component is overly complex ("Wrapper Hell" or "Huge Components"):** If a class component has become a massive, unmaintainable mess of lifecycle methods (`componentDidMount`, `componentDidUpdate`, `componentWillUnmount`) handling multiple unrelated concerns, Hooks can help separate those concerns into smaller, reusable custom hooks.
3.  **When you want to share stateful logic:** If you find yourself needing to use HOCs or Render Props to share logic that the class component currently holds, extracting that logic into a custom hook and converting the component is a good architectural move.

For **new components**, however, the standard practice is to use functional components and Hooks exclusively.

#### Q2: Will it make our application faster?

**No, rewriting class components to functional components with Hooks will not inherently make your application faster.**

In fact, the performance difference between a well-written class component and a well-written functional component with Hooks is negligible in most real-world scenarios. React's reconciliation algorithm handles both efficiently.

Sometimes, a naive rewrite might even introduce performance issues if dependencies in `useEffect`, `useMemo`, or `useCallback` are not managed correctly, leading to unnecessary re-renders or infinite loops.

The primary benefits of Hooks are related to developer experience, code organization, and logic reuse, not raw rendering speed.

#### Q3: What are the benefits?

While it won't necessarily make the app faster, using Hooks (and thus functional components) offers significant architectural and developer experience benefits:

1.  **Better Logic Reuse:** Custom hooks allow you to extract stateful logic from a component so it can be tested independently and reused across multiple components. This replaces complex patterns like Higher-Order Components (HOCs) and Render Props, reducing "wrapper hell" in the component tree.
2.  **Separation of Concerns:** In class components, related logic is often split across different lifecycle methods (e.g., setting up a subscription in `componentDidMount` and tearing it down in `componentWillUnmount`). Hooks like `useEffect` allow you to group related logic together in one place.
3.  **Simpler Mental Model:** Functional components are conceptually simpler. You don't have to worry about the complexities of `this` binding in JavaScript, which is a common source of bugs for beginners and experienced developers alike.
4.  **Less Boilerplate:** Functional components with Hooks generally require less code than equivalent class components (no constructor, no `render` method, no `this.state` or `this.props` everywhere).
5.  **Better Minification:** Functions minify slightly better than classes, and they don't suffer from issues where methods can't be minified effectively.
6.  **Alignment with React's Future:** The React team's focus for new features (like Concurrent Mode, Suspense for Data Fetching) is heavily centered around functional components and Hooks.

### Can you force a component to re-render without calling setState?

#### Q1: How to do re-render in class components and functional components?

While React's declarative nature means you should generally rely on state or prop changes to trigger re-renders, there are ways to force a re-render if absolutely necessary (though it's usually a sign of an anti-pattern or integration with non-React code).

**In Class Components:**

You can use the built-in `forceUpdate()` method.

```jsx
import React, { Component } from 'react';

class MyComponent extends Component {
  handleForceUpdate = () => {
    // This bypasses shouldComponentUpdate
    this.forceUpdate();
  };

  render() {
    return (
      <div>
        <p>Random Number: {Math.random()}</p>
        <button onClick={this.handleForceUpdate}>Force Re-render</button>
      </div>
    );
  }
}
```
*Note: Calling `forceUpdate()` skips `shouldComponentUpdate()`. It should be avoided if possible, as it goes against React's typical data flow.*

**In Functional Components:**

Functional components don't have a `forceUpdate` method. To force a re-render, you typically use a state variable that you update solely for the purpose of triggering a render.

A common pattern is to use `useState` or `useReducer` to create a "dummy" state.

```jsx
import React, { useState, useCallback } from 'react';

function MyFunctionalComponent() {
  // Using useState
  const [, updateState] = useState();
  const forceUpdate = useCallback(() => updateState({}), []);

  // Alternatively, using useReducer (often considered slightly cleaner for this specific hack)
  // const [, forceUpdate] = useReducer(x => x + 1, 0);

  return (
    <div>
      <p>Random Number: {Math.random()}</p>
      <button onClick={forceUpdate}>Force Re-render</button>
    </div>
  );
}
```

**When might you need this?**

You almost never need this in a pure React application. You might need it if your component relies on data that is mutated *outside* of React's state management system (e.g., a mutable object from a third-party library, or reading directly from the DOM) and you need React to reflect those external changes. However, the better approach is usually to bring that external data into React's state.

### What is React fiber?

#### Q1: What is the main gold of React Fiber?

**React Fiber** is the reconciliation engine (the core algorithm) in React, introduced in React 16. It was a complete rewrite of React's core algorithm.

The **main goal** of React Fiber is to improve the suitability of React for areas like animation, layout, and gestures. Its headline feature is **incremental rendering**: the ability to split rendering work into chunks and spread it out over multiple frames.

Before Fiber (in the "Stack Reconciler"), once React started rendering an update, it couldn't be interrupted. If the component tree was deep and complex, this synchronous rendering could block the main thread, causing the browser to drop frames and resulting in a janky, unresponsive user interface.

**Key capabilities introduced by Fiber:**

1.  **Pause, Resume, and Abort Work:** Fiber allows React to pause rendering work, yield control back to the browser (so it can handle user input or animations), and then resume the work later. It can also abort work if it's no longer needed (e.g., if a new update supersedes an older one).
2.  **Prioritization of Updates:** Fiber allows React to assign different priorities to different types of updates. For example, an update caused by user input (like typing in a text field) needs to be handled immediately (high priority) to feel responsive, while an update from a network request fetching data in the background can be delayed (low priority).
3.  **Concurrency:** Fiber is the foundation that enables React's Concurrent Mode (fully realized in React 18). Concurrent React can prepare multiple versions of the UI at the same time in the background without blocking the main thread.
4.  **Better Error Handling:** Fiber introduced Error Boundaries, allowing components to catch JavaScript errors anywhere in their child component tree, log those errors, and display a fallback UI instead of crashing the whole app.

In essence, Fiber changed React from a synchronous, blocking rendering engine to an asynchronous, interruptible, and prioritized rendering engine, vastly improving perceived performance and responsiveness in complex applications.

### What is server side rendering in React?

#### Q1: What is server side rendering? (SSR)

**Server-Side Rendering (SSR)** is a technique where a React application is rendered to HTML on the server, rather than in the browser.

In a traditional Client-Side Rendered (CSR) React app, the server sends a nearly empty HTML document with a `<div id="root"></div>` and a link to a large JavaScript bundle. The browser downloads the JS, executes it, and *then* React builds the UI and populates the DOM. During this time, the user sees a blank screen or a loading spinner.

With SSR, when a user requests a page, the server executes the React code, generates the fully populated HTML string for that specific page, and sends it to the browser. The browser can immediately display this HTML, resulting in a much faster First Contentful Paint (FCP).

#### Q2: How does it work?

The SSR process in React generally follows these steps:

1.  **Request:** The user's browser requests a URL from the server.
2.  **Server Rendering:** The server (usually running Node.js) receives the request. It uses a function like `ReactDOMServer.renderToString(<App />)` to render the React component tree into an HTML string.
3.  **Data Fetching (Crucial Step):** If the components need data from an API, the server must fetch this data *before* rendering the HTML. Frameworks like Next.js handle this seamlessly (e.g., using `getServerSideProps`).
4.  **Send HTML:** The server sends the fully formed HTML document (including the fetched data embedded as a script tag, often called the "initial state") to the browser.
5.  **Browser Display:** The browser receives the HTML and immediately displays the UI. The page is visible but not yet interactive.
6.  **Hydration:** The browser downloads the React JavaScript bundle. React boots up, examines the existing HTML sent by the server, and attaches event listeners to it. This process of making the static HTML interactive is called **hydration**. Once hydrated, the app functions as a normal SPA.

#### Q3: What is the difference between client rendering, server rendering and server side rendering?

*(Note: "Server rendering" and "Server side rendering" are generally used interchangeably. I will compare CSR, SSR, and SSG as they are the distinct rendering strategies in the React ecosystem).*

| Feature | Client-Side Rendering (CSR) | Server-Side Rendering (SSR) | Static Site Generation (SSG) |
| :--- | :--- | :--- | :--- |
| **Where HTML is generated** | In the browser (Client) | On the server, per request | On the server, at build time |
| **Initial HTML sent** | Mostly empty (`<div id="root">`) | Fully populated with content | Fully populated with content |
| **Time to First Byte (TTFB)** | Fast (server just sends static files) | Slower (server has to compute HTML) | Very Fast (HTML is pre-built and served from CDN) |
| **First Contentful Paint (FCP)** | Slower (waits for JS to download/execute) | Fast (HTML is immediately visible) | Very Fast (HTML is immediately visible) |
| **SEO** | Can be challenging (crawlers must execute JS) | Excellent (crawlers see full HTML) | Excellent (crawlers see full HTML) |
| **Server Load** | Low (server just hosts static files) | High (server computes HTML for every request) | Low (server just hosts static files) |
| **Data Freshness** | Always up-to-date (fetched on client) | Always up-to-date (fetched on server per request) | Stale until next build (unless using ISR) |
| **Best Use Case** | Highly interactive dashboards, authenticated apps | Dynamic content requiring SEO, personalized pages | Blogs, marketing sites, documentation |

**Summary:**

*   **CSR (e.g., Create React App):** Good for complex apps where SEO isn't the primary concern and initial load time is acceptable.
*   **SSR (e.g., Next.js `getServerSideProps`):** Good when you need SEO and the data changes frequently per user or per request.
*   **SSG (e.g., Next.js `getStaticProps`, Gatsby):** The best for performance and SEO, ideal for content that doesn't change on every request.


## Section 4: State management

### React Query

#### Q1: Do you know something about React Query?

**React Query** (now officially TanStack Query) is a powerful and highly optimized library for managing, caching, synchronizing, and updating server state in React applications. It's not a general-purpose state management library like Redux; instead, it focuses specifically on **server state**, which is asynchronous, often shared, and needs to be kept in sync with a remote source.

**Why React Query?**

Traditional React state management (like `useState` and `useEffect`) is excellent for UI state (e.g., whether a modal is open, input values). However, managing server state manually with `useEffect` can quickly become complex, leading to issues like:

*   **Loading states:** Manually tracking `isLoading`.
*   **Error handling:** Manually tracking `isError` and `error`.
*   **Caching:** Preventing unnecessary re-fetches.
*   **Stale data:** Ensuring data is fresh.
*   **Background re-fetching:** Updating data in the background.
*   **Optimistic updates:** Improving perceived performance.
*   **Pagination/Infinite scrolling:** Complex data fetching patterns.

React Query abstracts away these complexities, providing hooks that make working with server state feel like working with local state.

**Key Concepts and Features:**

1.  **`useQuery` Hook:** The primary hook for fetching data. It takes a unique `queryKey` (an array) and a `queryFn` (an asynchronous function that fetches data). It returns an object containing `data`, `isLoading`, `isError`, `error`, `isFetching`, etc.

    ```jsx
    import { useQuery } from '@tanstack/react-query';

    function Todos() {
      const { data, isLoading, isError, error } = useQuery({
        queryKey: ['todos'],
        queryFn: async () => {
          const res = await fetch('/api/todos');
          if (!res.ok) throw new Error('Failed to fetch todos');
          return res.json();
        },
      });

      if (isLoading) return <div>Loading todos...</div>;
      if (isError) return <div>Error: {error.message}</div>;

      return (
        <ul>
          {data.map((todo) => (
            <li key={todo.id}>{todo.title}</li>
          ))}
        </ul>
      );
    }
    ```

2.  **`useMutation` Hook:** Used for creating, updating, or deleting data on the server. It provides `mutate` function, `isLoading`, `isError`, `error`, and `data` (for the mutation result).

    ```jsx
    import { useMutation, useQueryClient } from '@tanstack/react-query';

    function AddTodo() {
      const queryClient = useQueryClient();
      const mutation = useMutation({
        mutationFn: async (newTodo) => {
          const res = await fetch('/api/todos', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(newTodo),
          });
          if (!res.ok) throw new Error('Failed to add todo');
          return res.json();
        },
        onSuccess: () => {
          // Invalidate and refetch the 'todos' query to show the new todo
          queryClient.invalidateQueries({ queryKey: ['todos'] });
        },
      });

      const handleSubmit = (e) => {
        e.preventDefault();
        mutation.mutate({ title: 'New Todo', completed: false });
      };

      return (
        <form onSubmit={handleSubmit}>
          <button type="submit" disabled={mutation.isPending}>
            {mutation.isPending ? 'Adding...' : 'Add Todo'}
          </button>
          {mutation.isError && <div>Error adding todo: {mutation.error.message}</div>}
        </form>
      );
    }
    ```

3.  **Caching and Stale-While-Revalidate:** React Query automatically caches data and uses a "stale-while-revalidate" strategy. This means it immediately shows cached data (stale) while silently re-fetching it in the background (revalidate) to ensure the UI is always up-to-date without blocking the user.

4.  **Automatic Re-fetching:** It automatically re-fetches data in various scenarios:
    *   When the component mounts.
    *   When the window is re-focused.
    *   When the network reconnects.
    *   Optionally, at a specified interval.

5.  **Devtools:** Provides excellent devtools for inspecting cache, queries, and mutations.

6.  **Optimistic Updates:** Easily implement optimistic UI updates, where the UI is updated immediately after a mutation, assuming success, and then rolled back if the actual API call fails.

React Query significantly simplifies data fetching and synchronization, leading to cleaner code, better performance, and an improved developer experience for applications heavily reliant on server data.

### How Redux works in plain Javascript?

#### Q1: Can you show how Redux is working with vanilla Javascript?

Redux is a predictable state container for JavaScript apps. While most commonly associated with React, its core principles and implementation are framework-agnostic. It follows a strict unidirectional data flow and is built around three core principles:

1.  **Single source of truth:** The state of your whole application is stored in an object tree within a single *store*.
2.  **State is read-only:** The only way to change the state is to emit an *action*, an object describing what happened.
3.  **Changes are made with pure functions:** To specify how the state tree is transformed by actions, you write pure *reducers*.

Here's a simplified example of how Redux concepts work in plain JavaScript:

```javascript
// 1. Define Actions
// Actions are plain JavaScript objects that describe what happened.
// They must have a `type` property.
const INCREMENT = 'INCREMENT';
const DECREMENT = 'DECREMENT';
const ADD_TODO = 'ADD_TODO';
const REMOVE_TODO = 'REMOVE_TODO';

// Action Creators (functions that create actions)
function increment() {
  return { type: INCREMENT };
}

function decrement() {
  return { type: DECREMENT };
}

function addTodo(text) {
  return { type: ADD_TODO, payload: { id: Date.now(), text, completed: false } };
}

function removeTodo(id) {
  return { type: REMOVE_TODO, payload: { id } };
}

// 2. Define Reducers
// Reducers are pure functions that take the current state and an action,
// and return the new state. They must NOT mutate the original state.

const initialCounterState = { count: 0 };

function counterReducer(state = initialCounterState, action) {
  switch (action.type) {
    case INCREMENT:
      return { ...state, count: state.count + 1 };
    case DECREMENT:
      return { ...state, count: state.count - 1 };
    default:
      return state;
  }
}

const initialTodoState = { todos: [] };

function todoReducer(state = initialTodoState, action) {
  switch (action.type) {
    case ADD_TODO:
      return { ...state, todos: [...state.todos, action.payload] };
    case REMOVE_TODO:
      return { ...state, todos: state.todos.filter(todo => todo.id !== action.payload.id) };
    default:
      return state;
  }
}

// 3. Combine Reducers (for multiple state slices)
// In a real app, you'd have multiple reducers for different parts of your state.
// combineReducers helps combine them into a single root reducer.
function combineReducers(reducers) {
  return function (state = {}, action) {
    return Object.keys(reducers).reduce((nextState, key) => {
      nextState[key] = reducers[key](state[key], action);
      return nextState;
    }, {});
  };
}

const rootReducer = combineReducers({
  counter: counterReducer,
  todos: todoReducer,
});

// 4. Create the Store
// The store holds the application state and allows access to it,
// dispatches actions, and registers listeners.
function createStore(reducer) {
  let state;
  let listeners = [];

  function getState() {
    return state;
  }

  function dispatch(action) {
    state = reducer(state, action);
    listeners.forEach(listener => listener());
  }

  function subscribe(listener) {
    listeners.push(listener);
    return function unsubscribe() {
      listeners = listeners.filter(l => l !== listener);
    };
  }

  // Initialize state by dispatching a dummy action
  dispatch({ type: '@@INIT' });

  return { getState, dispatch, subscribe };
}

const store = createStore(rootReducer);

// 5. Interact with the Store (Vanilla JS Example)

// Subscribe to state changes
const unsubscribe = store.subscribe(() => {
  console.log('Current State:', store.getState());
  document.getElementById('counter-display').textContent = store.getState().counter.count;
  document.getElementById('todo-list').innerHTML = store.getState().todos.map(todo => `<li>${todo.text}</li>`).join('');
});

// Dispatch actions to change state
store.dispatch(increment()); // count: 1
store.dispatch(increment()); // count: 2
store.dispatch(addTodo('Learn Redux'));
store.dispatch(decrement()); // count: 1
store.dispatch(addTodo('Build a Redux App'));
store.dispatch(removeTodo(store.getState().todos[0].id)); // Remove 'Learn Redux'

// Unsubscribe later if needed
// unsubscribe();

// Example HTML for demonstration
/*
<div id="app">
  <h1>Counter: <span id="counter-display"></span></h1>
  <h2>Todos:</h2>
  <ul id="todo-list"></ul>
</div>
*/
```

This vanilla JavaScript example demonstrates the core Redux flow: actions describe events, reducers update state immutably based on actions, and the store manages the state and notifies subscribers of changes.

### How does Redux work together with React?

#### Q1: Can you show me on example how Redux works with React without Redux toolkit?

Integrating Redux with React typically involves the `react-redux` library, which provides bindings to connect React components to a Redux store. Without Redux Toolkit, you'd manually set up the store, actions, and reducers, and then use `connect` (or hooks like `useSelector` and `useDispatch`) from `react-redux`.

Here's an example demonstrating Redux with React using `react-redux` without Redux Toolkit:

**1. Redux Store Setup (store.js):**

```javascript
// store.js
import { createStore, combineReducers } from 'redux';

// Actions
const INCREMENT = 'INCREMENT';
const DECREMENT = 'DECREMENT';
const ADD_TASK = 'ADD_TASK';
const TOGGLE_TASK = 'TOGGLE_TASK';

export const increment = () => ({ type: INCREMENT });
export const decrement = () => ({ type: DECREMENT });
export const addTask = (text) => ({ type: ADD_TASK, payload: { id: Date.now(), text, completed: false } });
export const toggleTask = (id) => ({ type: TOGGLE_TASK, payload: { id } });

// Reducers
const initialCounterState = { count: 0 };
function counterReducer(state = initialCounterState, action) {
  switch (action.type) {
    case INCREMENT:
      return { ...state, count: state.count + 1 };
    case DECREMENT:
      return { ...state, count: state.count - 1 };
    default:
      return state;
  }
}

const initialTasksState = { tasks: [] };
function tasksReducer(state = initialTasksState, action) {
  switch (action.type) {
    case ADD_TASK:
      return { ...state, tasks: [...state.tasks, action.payload] };
    case TOGGLE_TASK:
      return {
        ...state,
        tasks: state.tasks.map(task =>
          task.id === action.payload.id ? { ...task, completed: !task.completed } : task
        ),
      };
    default:
      return state;
  }
}

// Combine Reducers
const rootReducer = combineReducers({
  counter: counterReducer,
  tasks: tasksReducer,
});

// Create Store
const store = createStore(rootReducer);

export default store;
```

**2. React Components (App.js, Counter.js, TaskList.js):**

```jsx
// App.js
import React from 'react';
import { Provider } from 'react-redux';
import store from './store';
import Counter from './Counter';
import TaskList from './TaskList';

function App() {
  return (
    <Provider store={store}>
      <div style={{ padding: '20px' }}>
        <h1>Redux with React (without Toolkit)</h1>
        <Counter />
        <hr />
        <TaskList />
      </div>
    </Provider>
  );
}

export default App;
```

```jsx
// Counter.js
import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { increment, decrement } from './store';

function Counter() {
  // Access state from the Redux store
  const count = useSelector((state) => state.counter.count);
  // Get the dispatch function
  const dispatch = useDispatch();

  return (
    <div>
      <h2>Counter: {count}</h2>
      <button onClick={() => dispatch(increment())}>Increment</button>
      <button onClick={() => dispatch(decrement())}>Decrement</button>
    </div>
  );
}

export default Counter;
```

```jsx
// TaskList.js
import React, { useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { addTask, toggleTask } from './store';

function TaskList() {
  const tasks = useSelector((state) => state.tasks.tasks);
  const dispatch = useDispatch();
  const [newTaskText, setNewTaskText] = useState('');

  const handleAddTask = (e) => {
    e.preventDefault();
    if (newTaskText.trim()) {
      dispatch(addTask(newTaskText));
      setNewTaskText('');
    }
  };

  return (
    <div>
      <h2>Tasks</h2>
      <form onSubmit={handleAddTask}>
        <input
          type="text"
          value={newTaskText}
          onChange={(e) => setNewTaskText(e.target.value)}
          placeholder="Add a new task"
        />
        <button type="submit">Add Task</button>
      </form>
      <ul>
        {tasks.map((task) => (
          <li key={task.id} style={{ textDecoration: task.completed ? 'line-through' : 'none' }}>
            <input
              type="checkbox"
              checked={task.completed}
              onChange={() => dispatch(toggleTask(task.id))}
            />
            {task.text}
          </li>
        ))}
      </ul>
    </div>
  );
}

export default TaskList;
```

**Explanation:**

1.  **`Provider` Component:** The `<Provider store={store}>` component from `react-redux` makes the Redux store available to all nested components. It uses React's Context API internally.
2.  **`useSelector` Hook:** This hook allows functional components to extract data from the Redux store state. It takes a selector function as an argument, which receives the entire Redux state and returns the piece of state the component needs. `useSelector` automatically subscribes the component to the store, and it will re-render if the selected state changes.
3.  **`useDispatch` Hook:** This hook returns a reference to the `dispatch` function from the Redux store. Components use `dispatch` to send actions to the store, triggering state changes via reducers.

This setup provides a clear separation of concerns: Redux manages the application state, and React components are responsible for rendering the UI based on that state and dispatching actions to update it.

### How does Redux toolkit work?

#### Q1: Can you show me on example how Redux works with React with Redux toolit?

**Redux Toolkit (RTK)** is the official, opinionated, batteries-included toolset for efficient Redux development. It was created to simplify common Redux use cases, reduce boilerplate, and address common pain points like complex configuration and excessive code. RTK is now the recommended way to write Redux logic.

It includes several utilities:

*   **`configureStore`:** Simplifies store setup with good defaults (e.g., Redux DevTools Extension, `redux-thunk` middleware).
*   **`createSlice`:** Generates action creators and reducers automatically based on a slice of state.
*   **`createAsyncThunk`:** Simplifies handling asynchronous logic (e.g., API calls).
*   **`createEntityAdapter`:** Helps manage normalized state in the store.

Here's an example demonstrating Redux with React using Redux Toolkit:

**1. Redux Store Setup (store.js):**

```javascript
// store.js
import { configureStore, createSlice } from '@reduxjs/toolkit';

// Counter Slice
const counterSlice = createSlice({
  name: 'counter',
  initialState: { count: 0 },
  reducers: {
    increment: (state) => {
      state.count += 1; // Immer allows direct mutation, but it's still immutable under the hood
    },
    decrement: (state) => {
      state.count -= 1;
    },
    incrementByAmount: (state, action) => {
      state.count += action.payload;
    },
  },
});

export const { increment, decrement, incrementByAmount } = counterSlice.actions;
export const counterReducer = counterSlice.reducer;

// Tasks Slice
const tasksSlice = createSlice({
  name: 'tasks',
  initialState: { tasks: [] },
  reducers: {
    addTask: (state, action) => {
      state.tasks.push({ id: Date.now(), text: action.payload, completed: false });
    },
    toggleTask: (state, action) => {
      const task = state.tasks.find(task => task.id === action.payload);
      if (task) {
        task.completed = !task.completed;
      }
    },
  },
});

export const { addTask, toggleTask } = tasksSlice.actions;
export const tasksReducer = tasksSlice.reducer;

// Configure Store
const store = configureStore({
  reducer: {
    counter: counterReducer,
    tasks: tasksReducer,
  },
});

export default store;
```

**2. React Components (App.js, Counter.js, TaskList.js):**

```jsx
// App.js
import React from 'react';
import { Provider } from 'react-redux';
import store from './store';
import Counter from './Counter';
import TaskList from './TaskList';

function App() {
  return (
    <Provider store={store}>
      <div style={{ padding: '20px' }}>
        <h1>Redux with React (with Redux Toolkit)</h1>
        <Counter />
        <hr />
        <TaskList />
      </div>
    </Provider>
  );
}

export default App;
```

```jsx
// Counter.js
import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { increment, decrement, incrementByAmount } from './store';

function Counter() {
  const count = useSelector((state) => state.counter.count);
  const dispatch = useDispatch();

  return (
    <div>
      <h2>Counter: {count}</h2>
      <button onClick={() => dispatch(increment())}>Increment</button>
      <button onClick={() => dispatch(decrement())}>Decrement</button>
      <button onClick={() => dispatch(incrementByAmount(5))}>Increment by 5</button>
    </div>
  );
}

export default Counter;
```

```jsx
// TaskList.js
import React, { useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { addTask, toggleTask } from './store';

function TaskList() {
  const tasks = useSelector((state) => state.tasks.tasks);
  const dispatch = useDispatch();
  const [newTaskText, setNewTaskText] = useState('');

  const handleAddTask = (e) => {
    e.preventDefault();
    if (newTaskText.trim()) {
      dispatch(addTask(newTaskText));
      setNewTaskText('');
    }
  };

  return (
    <div>
      <h2>Tasks</h2>
      <form onSubmit={handleAddTask}>
        <input
          type="text"
          value={newTaskText}
          onChange={(e) => setNewTaskText(e.target.value)}
          placeholder="Add a new task"
        />
        <button type="submit">Add Task</button>
      </form>
      <ul>
        {tasks.map((task) => (
          <li key={task.id} style={{ textDecoration: task.completed ? 'line-through' : 'none' }}>
            <input
              type="checkbox"
              checked={task.completed}
              onChange={() => dispatch(toggleTask(task.id))}
            />
            {task.text}
          </li>
        ))}
      </ul>
    </div>
  );
}

export default TaskList;
```

**Key Differences and Benefits with Redux Toolkit:**

1.  **`createSlice`:** This is the most significant improvement. It automatically generates action creators and a reducer for a given "slice" of state. It uses the Immer library internally, which allows you to write "mutating" logic inside reducers, but it produces new immutable state behind the scenes. This drastically reduces boilerplate.
2.  **`configureStore`:** Simplifies store setup. It automatically sets up the Redux DevTools Extension, adds `redux-thunk` middleware (for async actions), and combines your slice reducers.
3.  **Less Boilerplate:** You write significantly less code for actions, action types, and reducers compared to traditional Redux.
4.  **Improved Developer Experience:** The opinionated nature and built-in tools guide developers towards best practices, making Redux easier to learn and use.
5.  **`useSelector` and `useDispatch`:** These hooks from `react-redux` are still used in the same way to connect React components to the RTK store.

Redux Toolkit makes Redux development much more approachable and efficient, making it the standard choice for new Redux projects and highly recommended for existing ones looking to modernize their codebase.

