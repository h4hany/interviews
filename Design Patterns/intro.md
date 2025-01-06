## Design Patterns:

- Singleton:
    - The **Singleton pattern** ensures that a class has only one instance and provides a global point of access to that
      instance.
- Observer:
    - The **Observer pattern** defines a one-to-many dependency between objects. When one object (the subject) changes
      state, all its dependents (observers) are notified and updated automatically.
- Dependency Injection:
    - **Dependency Injection (DI)** is a pattern where an object receives its dependencies (services, for instance) from
      an external source rather than creating them itself. This decouples the creation and use of the dependencies.
- Composite:
    - The **Composite pattern** allows individual objects to be composed into tree structures to represent part-whole
      hierarchies. Components in Angular follow this pattern, where they can be nested within other components.
- MVVM:
    - The **MVC pattern**

      separates an application into three components:

        - **Model**: The data or business logic.
        - **View**: The UI or presentation.
        - **Controller**: The mediator between the model and view, handling user input and updating the model or view
          accordingly.
- Factory:
    - The **Factory pattern** provides a way to create objects without specifying the exact class of object that will be
      created. Instead, a factory function decides which object to instantiate.
- Decorator:
    - The **Decorator pattern** allows behavior to be added to individual objects, either statically or dynamically,
      without affecting the behavior of other objects from the same class.
- Strategy:
    - The **Strategy pattern** defines a family of algorithms, encapsulates each one, and makes them interchangeable.
      The client can choose which strategy (algorithm) to use at runtime.
- Proxy:
    - The **Proxy pattern** provides a surrogate or placeholder for another object to control access to it. This is
      useful for intercepting requests and adding additional behavior before passing them to the actual target.
