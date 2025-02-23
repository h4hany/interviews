# Angular Interview Questions

## 1- Change Detection:

- the process of checking to see if something in your Angular application has changed, and then rendering the changes to
  the DOM so the user can see the updated application.
- **Change Detection**
    - Change detection in Angular is implemented using Zone.js. Zone.js is a library that essentially patches many lower
      level browser APIs (like event handlers) so that the default functionality of the event occurs, as well as some
      custom Angular functionality. Zone.js patches all of the browser events (like click events, mouse events, etc),
      setTimeout and setInterval, and Ajax HTTP requests. If any of these events occur in your Angular app, Zone.js will
      cause change detection to run.
    - Angular starts at the bottom of the application’s component tree to check for changes, and then moves up through
      the app. When the app finds a component that has changed and needs to be updated, Angular performs a top-down
      review of the app to see if any of the parent components need to be updated as well. The marking of components as
      changed happens from bottom-up in the application; the re-rendering happens top-down.
    - **Default Implementation**
        - Each component has a change detector that determines if anything has changed in the component since the last
          time change detection ran. It looks at the information in the component (variables, template, etc) and
          compares the current value with the previous value. If the two values are different, they are marked as
          changed. Angular is also smart enough to only check for changes on values used in a specific component. This
          means that if you have an attribute on an object that is not used in a component, that component will not
          check to see if the value of that attribute has changed.
        - In this change detection method, Angular will check each component on every change detection cycle to see if
          something has changed and needs updating. This is also referred to as dirty checking. The downside to this is
          that when you have a large application where performance matters, many components will be checked for changes
          even though ultimately nothing changed in that component.
    - **`OnPush`**
    - The other change detection method you can use in Angular applications is called the`OnPush`method. With this
      change detection method, the component will only be checked for changes in certain situations. Those situations
      are:
        1. An input reference changes
        2. An event is emitted from the component or one of its children
        3. The developer explicitly marks the component as needing to be checked
        4. The async pipe is used in the view, or an`Observable`emits an event

        - If none of the above conditions are met, then Angular will skip that component on its change detection cycle.

2- Guards and Resolvers:

### 1. **Guards**

- **Purpose**: Guards control whether a route can be accessed or not.
- **Use cases**: They are often used for authentication and authorization checks, ensuring that only certain users can
  access specific routes.
- **Types of Guards**:
    - `CanActivate`: Decides if a route can be activated.
    - `CanDeactivate`: Decides if you can leave the route.
    - `CanActivateChild`: Decides if child routes can be activated.
    - `CanLoad`: Prevents routes from being loaded until a condition is met.

2. **Resolvers**

- **Purpose**: Resolvers retrieve data before a route is activated and make that data available to the component.
- **Use cases**: They are ideal for ensuring that all required data is fetched before navigating to a route. This can
  prevent components from loading without necessary data, avoiding flickering screens or errors due to missing data.
- **Example**: A resolver might fetch a user’s profile data from the server before allowing navigation to the user
  profile page.

3- Webpack:

Webpack plays a crucial role in optimizing Angular projects, especially for production builds, where it bundles,
minifies, and optimizes the application code and assets for improved performance. Here are some of the key ways webpack
optimizes Angular projects:

### 1. **Tree Shaking**

- Webpack uses "tree shaking" to eliminate unused code from the final bundle. It analyzes module imports and removes any
  unused modules, functions, or variables. In Angular, this means it removes parts of libraries or Angular modules not
  used in your app, reducing the final bundle size.

### 2. **Code Splitting**

- Webpack splits the application into smaller "chunks" that can be loaded on demand. Angular leverages lazy loading
  and `loadChildren` in the router, where feature modules are loaded only when needed. This approach improves the
  initial load time by keeping the initial bundle small and deferring the loading of additional code until it's
  required.

### 3. **Ahead-of-Time (AOT) Compilation**

- With Angular’s AOT compilation, templates and components are compiled at build time rather than runtime. Webpack
  includes these precompiled templates in the bundle, reducing the amount of code required to bootstrap and run the
  Angular application, thus improving startup performance and reducing bundle size.

### 4. **Minification and Uglification**

- Webpack’s minification process removes whitespace, comments, and unnecessary characters in JavaScript code, while "
  uglification" renames variables and shortens function names. This process significantly reduces the bundle size,
  making the code harder to read but much faster to download and parse.

### 5. **File Compression (Gzip/Brotli)**

- For production builds, Webpack can generate compressed versions of assets (Gzip or Brotli). These compressed files are
  significantly smaller and are downloaded faster by the browser, improving load times. The server serves these
  compressed files directly to users if configured accordingly.

### 6. **Asset Optimization**

- Webpack optimizes assets, such as images, fonts, and CSS, through loaders and plugins. For example:
    - Images are often compressed or converted to WebP format, reducing their size.
    - CSS files are minimized, and unused styles are eliminated, reducing the CSS payload.

### 7. **Scope Hoisting**

- Scope hoisting is a Webpack optimization that wraps modules into fewer functions instead of separate ones. This
  reduces the overhead associated with function wrappers, resulting in a faster runtime and slightly smaller bundle
  size.

### 8. **Source Map Control**

- In production builds, source maps are typically minimized or excluded to avoid exposing source code, but Webpack can
  still generate source maps for debugging if needed. This feature helps keep the bundle size small in production while
  retaining useful debug information for development.

### 9. **Service Worker Generation with Workbox**

- When Angular is configured as a Progressive Web App (PWA), Webpack can use Workbox to generate a service worker
  script, which handles caching and offline support, speeding up loading times and allowing parts of the app to be
  cached locally on users' devices.

### 10. **Environment-Specific Configuration**

- Webpack can inject environment-specific configurations, such as setting production-specific flags (`production: true`)
  to enable optimizations and disable certain debugging features or logs, resulting in leaner production code.

These optimizations help ensure that Angular applications are as small and fast as possible in production environments,
enhancing user experience with faster load times and smoother interactions.

4- Optimize Angular App:

### **Optimize Change Detection with `OnPush` Strategy**

- By default, Angular’s change detection checks all components in the component tree, which can be resource-intensive.
  Use the `ChangeDetectionStrategy.OnPush` for components that primarily rely on `@Input` properties and immutability,
  so Angular only checks for changes when inputs change or events occur.
- **Lazy Load Modules**
    - Use lazy loading for feature modules to split code into smaller bundles, which loads only when needed. This
      reduces the initial load time of the application.
- **Use AOT Compilation**
    - Ahead-of-Time (AOT) compilation precompiles Angular templates at build time, which reduces runtime overhead and
      makes the app load faster. This is enabled by default in production builds.
- **Enable `Ivy` and `optimization` Flags**
    - Angular’s Ivy renderer offers faster compilation and runtime performance. Enabling `optimization` further reduces
      bundle size and enables AOT, dead code elimination, and minification.
- **Use `trackBy` in `ngFor` Directives**
    - For lists rendered with `ngFor`, using `trackBy` helps Angular identify list items by a unique property, reducing
      DOM re-renders when items change.
- **Minimize the Bundle Size**
    - Use tools like `webpack-bundle-analyzer` to identify large dependencies. Reduce unused libraries or replace them
      with lighter alternatives.
    - Angular CLI removes unused code in production with tree-shaking, but you can further optimize by analyzing imports
      and keeping dependencies minimal.
- **Use `async` Pipe for Observable Data**
    - The `async` pipe automatically manages subscriptions and unsubscriptions for Observables, preventing memory leaks
      and ensuring components are updated only when data changes.
- **Preload Lazy-Loaded Modules with `PreloadAllModules`**
    - If your app has multiple lazy-loaded routes, you can preload them after the initial load
      using `PreloadAllModules`, so they’re available when the user navigates.
- **Optimize HTTP Requests with Caching and Debouncing**
    - Use caching for repetitive requests and debounce input-related requests (like search fields) to reduce the number
      of calls.
    - Implement caching using `HttpInterceptor` or a service with `ReplaySubject` or `BehaviorSubject`.
- **Use Web Workers for Heavy Computation**
    - Offload heavy computations to web workers to prevent blocking the main thread. Angular CLI supports web workers
      for operations outside of the main app’s execution thread.
- **Optimize Image and Asset Loading**
    - Use Angular’s built-in lazy loading for images to reduce load time by loading images as they come into view.
    - Serve images in modern formats like WebP and compress assets to reduce their size.
- **Optimize Third-Party Libraries**
    - Some third-party libraries can significantly increase bundle size. Import only the necessary modules or functions
      rather than the entire library, and prefer lightweight libraries when possible.
- **Implement Route Guards for Heavy Components**
    - Use route guards to control access to resource-intensive routes, making sure they load only when necessary. This
      prevents premature loading of components and services.
