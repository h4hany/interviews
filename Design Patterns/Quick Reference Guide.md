# Design Patterns - Quick Reference Guide

## Problem → Pattern Decision Tree

Use this guide to quickly identify which pattern to use based on the problem you're facing.

---

## "I need to create objects..."

### "I need exactly one instance"
**→ Use Singleton Pattern**
- Database connections
- Logger instances
- Configuration objects
- Cache managers

**File:** `Creational/Singleton.md`

### "I need to create objects but don't know the exact type until runtime"
**→ Use Factory Pattern**
- Payment methods (CreditCard, PayPal, etc.)
- Database connections (MySQL, PostgreSQL)
- UI components based on platform

**File:** `Creational/Factory.md`

### "I need to create families of related objects that must work together"
**→ Use Abstract Factory Pattern**
- UI components (Windows vs Mac theme)
- Database components (MySQL connection + query builder + transaction)
- Cross-platform toolkits

**File:** `Creational/Abstract Factory.md`

### "I need to build complex objects with many optional parameters"
**→ Use Builder Pattern**
- SQL query builder
- HTTP request builder
- Configuration objects with many options

**File:** `Creational/Builder.md`

### "Creating objects is expensive, I want to clone existing ones"
**→ Use Prototype Pattern**
- Game objects (clone enemies, bullets)
- Document templates
- Configuration templates

**File:** `Creational/Prototype.md`

---

## "I need to structure objects..."

### "I have incompatible interfaces that need to work together"
**→ Use Adapter Pattern**
- Third-party library integration
- Legacy system integration
- API version compatibility

**File:** `Structural/Adapter.md`

### "I want to separate what something is from how it's implemented"
**→ Use Bridge Pattern**
- Remote controls for different devices
- Shapes with different rendering methods
- Platform-independent code

**File:** `Structural/Bridge.md`

### "I need to treat individual objects and groups the same way"
**→ Use Composite Pattern**
- File system (files and folders)
- Menu systems (items and submenus)
- Organization hierarchies

**File:** `Structural/Composite.md`

### "I need to add features to objects dynamically"
**→ Use Decorator Pattern**
- Text formatting (bold, italic, underline)
- Coffee orders (milk, sugar, cream)
- HTTP request middleware

**File:** `Structural/Decorator.md`

### "I want to provide a simple interface to a complex system"
**→ Use Facade Pattern**
- Home theater system (one button to start everything)
- Database operations (hide complexity)
- API wrappers

**File:** `Structural/Facade.md`

### "I have many similar objects consuming too much memory"
**→ Use Flyweight Pattern**
- Game trees/particles
- Text editor characters
- UI components with shared styles

**File:** `Structural/Flyweight.md`

### "I need to control when/how an object is accessed"
**→ Use Proxy Pattern**
- Lazy loading (load images on demand)
- Access control (permissions)
- Caching (cache expensive operations)
- Remote access (network proxy)

**File:** `Structural/Proxy.md`

---

## "I need to handle behavior..."

### "Multiple objects can handle a request, try them in order"
**→ Use Chain of Responsibility Pattern**
- Request approval (Manager → Director → CEO)
- Authentication (API key → Token → Session)
- Error handling pipeline

**File:** `Behavioral/Chain of Responsibility.md`

### "I need to queue operations or support undo/redo"
**→ Use Command Pattern**
- Text editor undo/redo
- Remote control buttons
- Transaction logging
- Macro commands

**File:** `Behavioral/Command.md`

### "I need to interpret a language or expression"
**→ Use Interpreter Pattern**
- Expression evaluators
- Query languages
- Rule engines
- Simple DSLs

**File:** `Behavioral/Interpreter.md`

### "I need to traverse collections uniformly"
**→ Use Iterator Pattern**
- Custom collections
- Tree traversal
- Different iteration orders

**File:** `Behavioral/Iterator.md`

### "Objects communicate in complex ways, I want to reduce coupling"
**→ Use Mediator Pattern**
- Chat rooms (users don't know about each other)
- Air traffic control
- Form validation (components communicate through mediator)

**File:** `Behavioral/Mediator.md`

### "I need to save and restore object state"
**→ Use Memento Pattern**
- Undo/redo functionality
- Game checkpoints
- Snapshot/restore features

**File:** `Behavioral/Memento.md`

### "I need to notify multiple objects when something changes"
**→ Use Observer Pattern**
- Event systems
- Model-View updates
- Stock market notifications
- Publish-Subscribe systems

**File:** `Behavioral/Observer.md`

### "Object behavior changes based on its state"
**→ Use State Pattern**
- Order state machine (pending → confirmed → shipped)
- Vending machine states
- Game character states
- Workflow states

**File:** `Behavioral/State.md`

### "I have multiple ways to do something, want to choose at runtime"
**→ Use Strategy Pattern**
- Payment processing (different payment methods)
- Sorting algorithms (QuickSort, MergeSort)
- Compression algorithms
- Validation strategies

**File:** `Behavioral/Strategy.md`

### "I have an algorithm where structure is fixed but steps vary"
**→ Use Template Method Pattern**
- Build processes (fetch → compile → test → deploy)
- Data processing pipelines
- Report generation
- Algorithm with customizable steps

**File:** `Behavioral/Template Method.md`

### "I need to add operations to object structure without modifying classes"
**→ Use Visitor Pattern**
- Document export (PDF, HTML, XML)
- Compiler operations (type checking, code generation)
- Tree operations (calculate total, print structure)

**File:** `Behavioral/Visitor.md`

---

## Pattern Selection by Category

### If you're dealing with **Object Creation**:
1. Need one instance? → **Singleton**
2. Don't know type until runtime? → **Factory**
3. Need families of objects? → **Abstract Factory**
4. Complex construction? → **Builder**
5. Expensive creation? → **Prototype**

### If you're dealing with **Object Structure**:
1. Incompatible interfaces? → **Adapter**
2. Separate abstraction/implementation? → **Bridge**
3. Part-whole hierarchies? → **Composite**
4. Add features dynamically? → **Decorator**
5. Simplify complex system? → **Facade**
6. Too many similar objects? → **Flyweight**
7. Control access? → **Proxy**

### If you're dealing with **Object Behavior**:
1. Multiple handlers? → **Chain of Responsibility**
2. Need undo/redo? → **Command**
3. Interpret language? → **Interpreter**
4. Traverse collections? → **Iterator**
5. Complex communication? → **Mediator**
6. Save/restore state? → **Memento**
7. Notify multiple objects? → **Observer**
8. Behavior depends on state? → **State**
9. Multiple algorithms? → **Strategy**
10. Algorithm with variable steps? → **Template Method**
11. Add operations to structure? → **Visitor**

---

## Common Combinations

### Frequently Used Together:
- **Factory + Strategy**: Create objects and choose algorithms
- **Observer + Command**: Notify observers with commands
- **Composite + Visitor**: Traverse tree structures
- **Decorator + Factory**: Create decorated objects
- **State + Strategy**: State-specific strategies

---

## Anti-Patterns to Avoid

### Don't use patterns when:
- ❌ Problem is too simple (over-engineering)
- ❌ Pattern adds more complexity than it solves
- ❌ You're forcing a pattern where it doesn't fit
- ❌ Pattern violates YAGNI (You Aren't Gonna Need It)

### Remember:
- Patterns are tools, not goals
- Start simple, add patterns when needed
- Patterns should solve real problems
- Don't pattern for pattern's sake

---

## Learning Path

1. **Start with**: Singleton, Factory, Observer, Strategy
2. **Then learn**: Adapter, Decorator, Command, State
3. **Advanced**: Visitor, Interpreter, Mediator, Chain of Responsibility

---

## Quick Decision Matrix

| Problem Type | Pattern |
|--------------|---------|
| One instance needed | Singleton |
| Create based on condition | Factory |
| Families of objects | Abstract Factory |
| Complex construction | Builder |
| Clone objects | Prototype |
| Incompatible interfaces | Adapter |
| Separate what/how | Bridge |
| Individual + groups | Composite |
| Add features dynamically | Decorator |
| Simplify interface | Facade |
| Share common data | Flyweight |
| Control access | Proxy |
| Multiple handlers | Chain of Responsibility |
| Undo/redo | Command |
| Interpret language | Interpreter |
| Traverse collections | Iterator |
| Centralize communication | Mediator |
| Save/restore state | Memento |
| Notify multiple | Observer |
| State-dependent behavior | State |
| Choose algorithm | Strategy |
| Algorithm skeleton | Template Method |
| Add operations | Visitor |

---

For detailed explanations with real-world examples, see the individual pattern files in their respective directories.

