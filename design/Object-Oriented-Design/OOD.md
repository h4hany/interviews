# Object Oriented design  interview questions

1. **What is object-oriented design (OOD)?**

#### Answer:

**Object-Oriented Design (OOD)** is a programming paradigm that focuses on modeling real-world entities as objects that
have
---

2. **What is the difference between composition and inheritance in object-oriented design? Can you provide examples of
   when
   you might use one over the other?**

#### Answer:

**Inheritance** and **Composition** are both mechanisms in object-oriented design that allow for code reuse and defining
relationships between classes, but they do so in different ways.

1. **Inheritance**:
    - **Definition**: Inheritance is when one class (subclass) derives from another (superclass), inheriting its
      attributes and methods. This is typically used when there is a "is-a" relationship between the classes.
    - **Example**: Suppose you have a class `Vehicle`, and you have subclasses like `Car`, `Truck`, and `Motorcycle`.
      All these subclasses inherit from `Vehicle` because they are types of vehicles.

```ruby

class Vehicle
  def start
    puts "Starting the vehicle"
  end
end

class Car < Vehicle
  def open_trunk
    puts "Opening car trunk"
  end
end
```

- **Composition:**:
    - **Definition**: Composition is a design principle where one object is composed of other objects, allowing it to
      delegate responsibilities. This is used when there is a "has-a" relationship between the objects.
    - **Example**: Consider a `Car` class that has an `Engine` and `Wheels`. Instead of inheriting from a
      generic `Vehicle`
      class, you would use composition to include specific objects like `Engine` and `Wheel` in the `Car` class.
    - **When to Use Which:**
        - **Inheritance** is useful when you have a clear hierarchy of classes and there is a strong "is-a" relationship
          between them. It provides a way to model the relationship between classes and allows for code reuse.
        - **Composition** is more flexible and can be used to model relationships where one object "has-a" another
          object. It

```ruby

class Engine
  def start
    puts "Engine starting"
  end
end

class Wheel
  def rotate
    puts "Wheel rotating"
  end
end

class Car
  def initialize
    @engine = Engine.new
    @wheels = [Wheel.new, Wheel.new, Wheel.new, Wheel.new]
  end

  def start
    @engine.start
  end

  def rotate_wheels
    @wheels.each(&:rotate)
  end
end

```

- **Key Points to Remember:**
    - **Inheritance** creates a tight coupling between the parent and child classes, whereas composition allows more
      flexibility and promotes loose coupling.
    - **Composition** can help avoid the "fragile base class" problem (where changes to the parent class can break the
      subclasses).

---

3. Can you explain the concept of polymorphism in object-oriented design? How would you implement polymorphism in Ruby,
   and can you give an example?

#### Answer:

Polymorphism in object-oriented design allows different classes to be treated as instances of the same class through a
common interface. It enables you to reuse the same method name across different classes, while the method's behavior can
vary based on the object's actual class type.

- **There are two types of polymorphism:**
    - **Method Overloading (Compile-Time Polymorphism):**
      This happens when you define multiple methods with the same name but different argument types or numbers. However,
      Ruby does not support true method overloading in the traditional sense. In Ruby, you would handle this by using
      default arguments or variable-length arguments instead.
    - **Method Overriding (Run-Time Polymorphism):**
      This is when a subclass provides a specific implementation of a method that is already defined in its superclass.
      At runtime, the method that is invoked is the one corresponding to the actual object's class, not the type of the
      reference variable.

```ruby
# In this example, the speak method is overridden in both Dog and Cat, demonstrating runtime polymorphism. 
# Even though we're calling the same method (speak) on different objects, 
# each object behaves differently based on its class.
class Animal
  def speak
    "Some generic sound"
  end
end

class Dog < Animal
  def speak
    "Woof"
  end
end

class Cat < Animal
  def speak
    "Meow"
  end
end

# Polymorphism in action
animals = [Dog.new, Cat.new]

animals.each do |animal|
  puts animal.speak # Outputs "Woof" and "Meow"
end

```

---

4. What is the difference between an abstract class and an interface in object-oriented design? How would you implement
   both in Ruby, and when would you use one over the other?

#### Answer:

In object-oriented design, both abstract classes and interfaces are used to define a contract or blueprint for other
classes to follow, but they serve different purposes and have different rules regarding implementation.

- **Abstract Class:**
    - **Definition**:  An abstract class is a class that cannot be instantiated directly and may contain abstract
      methods (methods without a body) that must be implemented by subclasses. An abstract class can also contain
      concrete methods (methods with implementations).
    - **When to Use**: You would use an abstract class when you want to provide a common base with shared implementation
      that can be inherited by other classes. It allows you to define some default behavior while enforcing that certain
      methods must be overridden.
    - **Example in Ruby**: Ruby doesn't have a formal abstract class or interface keyword, but you can use `raise
      NotImplementedError` to simulate abstract methods.

```ruby 

class Animal
  def speak
    raise NotImplementedError, 'This method should be overridden by subclass'
  end
end

class Dog < Animal
  def speak
    "Woof"
  end
end

dog = Dog.new
puts dog.speak # Outputs "Woof"


```

- **Interface:**
    - **Definition**: An interface is a contract that defines a set of methods that a class must implement. Unlike an
      abstract class, an interface cannot contain any method implementations.
    - **When to Use**: You would use an interface when you want to define a contract that specifies what methods a class
      must implement without providing any implementation details. This allows for a high level of abstraction and
      flexibility.
    - **Example in Ruby**: Ruby doesn't have a formal interface keyword, but you can use modules to define interfaces.

```ruby

module Speakable
  def speak
    raise NotImplementedError, 'This method should be implemented by a class including the module'
  end
end

class Dog
  include Speakable

  def speak
    "Woof"
  end
end

dog = Dog.new
puts dog.speak # Outputs "Woof"

```

- **Key Differences:**
    - **Abstract Class**:
        - Can contain both abstract (unimplemented) and concrete (implemented) methods.
        - Used when you want to share common behavior across related classes.
        - A class can inherit from only one abstract class (single inheritance).
    - **Interface**:
        - Only defines the method signatures (no implementation).
        - A class can implement multiple interfaces (multiple inheritance is possible in Ruby via modules).
        - Used when you want to enforce a contract across unrelated classes.
- **When to Use Which**:
    - Use an abstract class when you have a common base class with shared functionality, but you want to enforce that
      subclasses must implement specific methods.
    - Use an interface (or module in Ruby) when you want to enforce a contract on multiple classes that may not share a
      common parent but should implement a set of methods.

---

5. **What is the SOLID design principle, and how does it apply to object-oriented design? Can you explain each of the
   SOLID
   principles?**

#### Answer

The **SOLID** design principles are a set of five principles that help developers design maintainable and scalable
object-oriented systems. Each principle focuses on a specific aspect of software design and aims to make the system more
flexible, robust, and easier to maintain.

- **SOLID** stands for:
    - **S** - **Single Responsibility Principle (SRP)**
    - **O** - **Open/Closed Principle (OCP)**
    - **L** - **Liskov Substitution Principle (LSP)**
    - **I** - **Interface Segregation Principle (ISP)**
    - **D** - **Dependency Inversion Principle (DIP)**

---

6. What is the Singleton Design Pattern, and how would you implement it in Ruby? Can you provide a real-world scenario
   where the Singleton pattern would be useful?

#### Answer

The Singleton Design Pattern ensures that a class has only one instance and provides a global point of access to that
instance. It is often used for resources that should be shared, such as a configuration object or a database connection.

- The Singleton pattern restricts the instantiation of a class to one object.
- It provides a global point of access to that object, ensuring that it is used throughout the application.

```ruby
require 'singleton'

class DatabaseConnection
  include Singleton

  def initialize
    @connection = "Database connection established"
  end

  def connection
    @connection
  end
end

# Both calls will return the same instance of DatabaseConnection
db1 = DatabaseConnection.instance
db2 = DatabaseConnection.instance

puts db1.connection # Outputs "Database connection established"
puts db1 == db2 # Outputs true, both variables point to the same object

```

**Real-World Scenario:**
Database Connection: In a web application, we only need a single database connection object throughout the lifetime of
the application. Using the Singleton pattern ensures that we don’t create multiple instances of the database connection,
thus saving resources and improving performance.

---

7. Can you explain the concept of the Factory Design Pattern and how it is implemented in Ruby? Can you provide an
   example of when this pattern might be useful?

#### Answer

The Factory Design Pattern provides a way to create objects without specifying the exact class of object that will be
created. Instead, a factory function decides which object to instantiate based on certain conditions or parameters.

- **Key Components of the Factory Pattern:**
    - **Factory Interface**: An interface or abstract class that defines a method for creating objects.
    - **Concrete Factories**: Classes that implement the factory interface and are responsible for creating specific
      types of objects.
    - **Product Interface**: An interface or abstract class that defines the common methods that all products must
      implement.
    - **Concrete Products**: Classes that implement the product interface and represent the objects created by the
      factory.
- **When to Use the Factory Pattern**:
    - When you want to delegate the responsibility of object creation to a separate class or method.
    - When you want to decouple the client code from the actual object creation logic.
    - When you want to provide a way to create different types of objects without exposing the instantiation logic.
- **benefits of the Factory Pattern**:
    - Centralizes the object creation logic.
    - Promotes loose coupling by abstracting object creation.
    - Allows easy substitution of object types.
- **Real-World Scenario:**
  **Database Connection:** A factory can be used to return different types of database connection objects (e.g., MySQL,
  PostgreSQL, SQLite) based on the configuration or user input. Instead of directly instantiating each type of
  connection,
  the Factory method abstracts the creation process.

```ruby
# In this example, we have a ShapeFactory that creates different types of shapes (Circle and Square).
# The ShapeFactory decides which type of shape to create based on the input parameter.
class Shape
  def draw
    raise NotImplementedError, 'This method should be overridden by subclasses'
  end
end

class Circle < Shape
  def draw
    "Drawing a circle"
  end
end

class Square < Shape
  def draw
    "Drawing a square"
  end
end

class ShapeFactory
  def self.create_shape(type)
    case type
    when :circle
      Circle.new
    when :square
      Square.new
    else
      raise ArgumentError, "Invalid shape type"
    end
  end
end

# Factory pattern in action
circle = ShapeFactory.create_shape(:circle)
square = ShapeFactory.create_shape(:square)

puts circle.draw # Outputs "Drawing a circle"
puts square.draw # Outputs "Drawing a square"

```

--- 

8. What is the Observer Design Pattern, and how would you implement it in Ruby? Can you provide an example of a scenario
   where this pattern is useful?

#### Answer

The Observer Design Pattern is a **behavioral pattern** that allows an object (called the subject) to maintain a list of
dependents (called observers) that need to be notified of changes to the state of the subject. This pattern is
particularly useful in scenarios where an object’s state changes frequently, and other objects need to react to those
changes.

- **Key Components of the Observer Pattern:**
    - **Subject**: The object that holds the state and sends notifications.
    - **Observer**: he objects that need to be updated whenever the subject’s state changes.
    - **Loose Coupling**: Observers don’t need to know about the specific details of the subject’s implementation.

- **benefits of the Observer Pattern**:
    - Promotes loose coupling between objects.
    - Makes it easy to add new observers without changing the subject.
    - Useful for scenarios where multiple objects need to react to the same event.
- **Real-World Scenario:**
    - **Event Handling in UI Systems:**
      In a user interface, many components might need to update themselves based on a
      single event, such as a button click or a form submission. **The Observer pattern** can be used to decouple the
      components that need to listen for events from those that generate the events. For instance, multiple UI
      elements (labels, charts, etc.) can listen for changes in data, and when the data is updated, they automatically
      refresh.

```ruby
# We can implement the Observer pattern in Ruby using observer modules or by manually managing the list of observers.
# Here's an example that uses Ruby's Observer module:
require 'observer'

class Stock
  include Observable

  attr_reader :price, :symbol

  def initialize(symbol, price)
    @symbol = symbol
    @price = price
  end

  def update_price(new_price)
    @price = new_price
    changed
    notify_observers(self)
  end
end

class Investor
  def initialize(name)
    @name = name
  end

  def update(stock)
    puts "#{@name} has been notified. The price of #{stock.symbol} is now $#{stock.price}."
  end
end

# Creating the subject and observers
stock = Stock.new('AAPL', 150)
investor1 = Investor.new('Alice')
investor2 = Investor.new('Bob')

# Adding observers to the stock
stock.add_observer(investor1)
stock.add_observer(investor2)

# Changing stock price, which will notify observers
stock.update_price(155)

```

---

9. What is the Strategy Design Pattern, and how would you implement it in Ruby? Can you provide an example of a scenario
   where this pattern is useful?

#### Answer

The Strategy Design Pattern is a **behavioral pattern** that allows you to define a family of algorithms, encapsulate
each one, and make them interchangeable. This pattern enables the client to choose the algorithm to use at runtime
without changing the client code.

- **Key Components of the Strategy Pattern:**
    - **Context**: The class that contains a reference to the strategy interface.
    - **Strategy Interface**: The interface that defines the common methods for all strategies.
    - **Concrete Strategies**: The classes that implement the strategy interface and provide specific algorithm
      implementations.
- **benefits of the Strategy Pattern**:
    - **Flexibility:** You can change the algorithm at runtime.
    - **Extensibility:** New strategies can be added without modifying existing code.
    - **Separation of concerns:** Each strategy encapsulates a specific behavior, making the code cleaner and easier to
      maintain.
    - **Real-World Scenario:**
        - **Sorting Algorithms:**
          In a sorting application, you might have different sorting algorithms (e.g., bubble sort, quicksort,
          mergesort)
          that
          can be used based on the size of the input data or other factors. **The Strategy pattern** allows you to
          encapsulate each sorting algorithm in a separate class and switch between them dynamically.
        - **Payment Methods:**
          In an e-commerce application, you might have different payment methods (e.g., credit card, PayPal, Apple Pay)
          that can be used for checkout. **The Strategy pattern** allows you to define a common payment interface and
          have different payment methods as concrete strategies

 ```ruby
        # Define the strategy interface
class SortingStrategy
  def sort(list)
    raise NotImplementedError, 'This method should be overridden by subclasses'
  end
end

# Concrete strategy 1: BubbleSort
class BubbleSort < SortingStrategy
  def sort(list)
    list.sort # Simplified for example
  end
end

# Concrete strategy 2: MergeSort
class MergeSort < SortingStrategy
  def sort(list)
    list.sort # Simplified for example
  end
end

# Context class that uses the strategy
class SortedList
  def initialize(strategy)
    @strategy = strategy
  end

  def set_strategy(strategy)
    @strategy = strategy
  end

  def sort_list(list)
    @strategy.sort(list)
  end
end

# Usage
list = [5, 3, 8, 1]
context = SortedList.new(BubbleSort.new)
puts "Bubble Sort: #{context.sort_list(list)}"

context.set_strategy(MergeSort.new)
puts "Merge Sort: #{context.sort_list(list)}"

```

```ruby

class PaymentStrategy
  def pay(amount)
    raise NotImplementedError, 'This method should be overridden by subclasses'
  end
end

class PayPal < PaymentStrategy
  def pay(amount)
    puts "Paying #{amount} through PayPal."
  end
end

class Stripe < PaymentStrategy
  def pay(amount)
    puts "Paying #{amount} through Stripe."
  end
end

class Checkout
  def initialize(payment_strategy)
    @payment_strategy = payment_strategy
  end

  def process_payment(amount)
    @payment_strategy.pay(amount)
  end
end

# Usage

checkout = Checkout.new(PayPal.new)
checkout.process_payment(100)

checkout = Checkout.new(Stripe.new)
checkout.process_payment(150)

``` 

---

10. What is the Command Design Pattern, and how would you implement it in Ruby? Can you provide an example of a scenario
    where this pattern is useful?

#### Answer

The Command Design Pattern is a **behavioral pattern** that turns a request or simple operation into an object. This
pattern
allows the parameterization of objects with operations, delays the execution of a request, and supports undoable
operations. The command object encapsulates all the details of a request, including the method to call, the parameters
to pass, and the object that will perform the request.

- **Key Characteristics:**
    - **Command**: The command object encapsulates a request as an object, allowing for parameterization and queuing of
      requests.
    - **Receiver**: The receiver is the object that performs the action when the command is executed.
    - **Invoker**: The invoker is responsible for executing the command and managing the lifecycle of the command
      object.
    - **Client**: The client creates the command object and sets the receiver.
- **Benefits:**
    - Decouples the sender and receiver, allowing the client to be unaware of how the request is executed.
    - Supports undo/redo functionality.
    - Allows queuing of requests or logging of operations.
    - Easy to extend by adding new commands without modifying existing code.
- **Real-World Scenario:**
    - **Remote Control:**
      In a remote control application, you might have different buttons that trigger different actions (e.g., turning
      on/off the TV, changing the channel). **The Command pattern** allows you to encapsulate each action as a command
      object, which can be executed by the remote control.

```ruby
# Command Interface
class Command
  def execute
    raise NotImplementedError, 'This method should be overridden by subclasses'
  end
end

# Receiver
class Light
  def on
    puts "Light is ON"
  end

  def off
    puts "Light is OFF"
  end
end

# Concrete Command 1
class TurnOnLightCommand < Command
  def initialize(light)
    @light = light
  end

  def execute
    @light.on
  end
end

# Concrete Command 2
class TurnOffLightCommand < Command
  def initialize(light)
    @light = light
  end

  def execute
    @light.off
  end
end

# Invoker
class RemoteControl
  def initialize
    @commands = []
  end

  def set_command(command)
    @commands << command
  end

  def press_button
    @commands.each(&:execute)
  end
end

# Client
light = Light.new
turn_on = TurnOnLightCommand.new(light)
turn_off = TurnOffLightCommand.new(light)

remote = RemoteControl.new
remote.set_command(turn_on)
remote.set_command(turn_off)

remote.press_button


```

---

11. Design a system for managing a library. The system should handle books, authors, and patrons. A book should have a
    title, an author, and a status (whether it is available or checked out). A patron can check out and return books,
    and an author can write multiple books. Design the classes and relationships between them in a way that reflects
    good object-oriented design principles. Please provide the classes, attributes, and methods you'd implement.

#### Answer

```ruby

class Library

  def initialize(books = [])
    @books = books
  end

  def add_book(book)
    @books << book
  end

  def remove_book(book)
    @books.delete(book)
  end

  def find_book_by_title(title)
    @books.find { |book| book.title == title }
  end
end

class Book
  attr_accessor :title, :author, :status

  def initialize(title:, author:)
    title = title
    author = author
    status = 'available'
  end
end

class Author
  attr_accessor :name

  def initialize(name)
    @name = name
    @books = []
  end

  def write_book(title)
    book = Book.new(title: title, author: self)
    @books << book
  end

  def books
    @books
  end
end

class Patron
  def initialize
    @books = []
  end

  def checkout(book)
    if book.status == 'checked out'
      return 'Book is not available'
    end
    @books << book
    book.status = 'checked out'
  end

  def return(book)
    @books.delete(book)
    book.status = 'available'
  end

  def books
    @books
  end
end
```

---

12. Design a simple order management system for an e-commerce platform. The system should handle orders, products, and
    customers. Each order contains multiple products, and each product has a price and a name. A customer can place
    multiple orders, and the system should be able to calculate the total cost of an order, including any discounts or
    promotions. How would you design the classes and their relationships? Please include the necessary attributes,
    methods, and any relevant design decisions.

#### Answer

````ruby

class Product
  attr_accessor :name, :price

  def initialize(name, price = 0.0)
    raise 'Price must be a positive number' if price <= 0
    @name = name
    @price = price
  end
end

class Order
  attr_accessor :products, :customer

  def initialize(products, customer)
    @products = products
    @customer = customer
  end

  def add_product(product, quantity = 1)
    @products << product
  end

  def delete_product(product)
    @products.delete(product)
  end

  def total_price
    @products.sum(&:price)
  end

  def apply_discount(discount_percentage)
    total_price * (1 - discount_percentage / 100.0)
  end
end

class Customer
  def initialize(name)
    @name = name
    @orders = []
  end

  def place_order(products)
    order = Order.new(products, self)
    @orders << order
    order
  end

  def orders
    @orders
  end
end
````

---

13. Design a system for a simple banking application. The system should handle multiple accounts, allow users to deposit
    and withdraw money, and check their balance. There should be different types of accounts (e.g., checking, savings),
    and each account should have the ability to calculate interest (for savings). The system should ensure that users
    can't withdraw more money than they have in their account. Please design the classes, attributes, methods, and
    relationships for this system.

#### Answer

```ruby

class Account
  attr_accessor :balance, :account_type

  def initialize(balance, account_type)
    @balance = balance
    @account_type = account_type
  end

  def deposit(amount)
    @balance += amount
  end

  def withdraw(amount)
    if amount > @balance
      raise 'Insufficient balance'
    else
      @balance -= amount
    end
  end
end

class SavingsAccount < Account
  attr_accessor :interest_rate

  def initialize(balance, account_type, interest_rate)
    super(balance, account_type)
    @interest_rate = interest_rate
  end

  def calculate_interest
    @balance += @balance * @interest_rate
  end
end

class CheckingAccount < Account
  def initialize(balance, account_type)
    super(balance, account_type)
  end
end

class Bank
  attr_accessor :accounts

  def initialize
    @accounts = []
  end

  def add_account(account)
    @accounts << account
  end

  def remove_account(account)
    @accounts.delete(account)
  end
end
```
