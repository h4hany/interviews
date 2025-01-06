# Ruby interview questions

### **1. What is the difference between `proc` and `lambda` in Ruby?**

**Weight:** 10

- **Answer:**
    - `lambda` checks the number of arguments, `proc` does not.
    - `lambda` returns control to the caller, while `proc` exits the method where it was called.
    - `proc` can be reused  `lambda` can't
    - `lambda` is a closure, `proc` is not.
- **Code Example:**
  ```ruby
  def test_lambda
    l = ->(x, y) { x + y }
    puts l.call(1, 2) # Works fine
    # puts l.call(1) # Raises ArgumentError
  end

  def test_proc
    p = Proc.new { |x, y| x.to_i + y.to_i }
    puts p.call(1) # Works, y is nil
  end

  test_lambda
  test_proc
  ```

### **2. Explain the differences between `module` and `class`.**

**Weight:** 9

- **Answer:**
    - Classes can be instantiated; modules cannot.
    - Modules are used for namespacing and mixins.
    - A class can be subclassed; a module cannot.
    - Modules do not have instances.

- **Code Example:**
  ```ruby
  module Greetings
    def greet
      "Hello, World!"
    end
  end

  class Person
    include Greetings
  end

  person = Person.new
  puts person.greet # Outputs "Hello, World!"
  ```

### **3. How does Ruby handle garbage collection?**

**Weight:** 8

- **Answer:**
    - Ruby uses a mark-and-sweep garbage collection algorithm to reclaim unused memory.
    - It keeps track of all objects and references to those objects.
    - When an object is no longer referenced, it is marked for garbage collection.
    - The garbage collector runs periodically to free up memory.
    - Ruby also has a reference counting garbage collector.

### **4. What is the significance of the `self` keyword?**

**Weight:** 8

- **Answer:**
    - `self` refers to the object that is currently executing the method.
- **Code Example:**
  ```ruby
  class Example
    def instance_method
      self
    end

    def self.class_method
      self
    end
  end

  e = Example.new
  puts e.instance_method # Returns the instance
  puts Example.class_method # Returns the class
  ```

### **5. What are Ruby blocks, and how are they different from methods?**

**Weight:** 7

- **Answer:**
    - Blocks are anonymous chunks of code, executed in the context of a method.
    - Methods are reusable and can be called directly by their name.
- **Code Example:**
  ```ruby
  def example_method
    yield if block_given?
  end

  example_method { puts "Hello from a block!" } # Outputs "Hello from a block!"
  ```

### **6. How do you handle exceptions in Ruby?**

**Weight:** 7

- **Answer:**
    - Use `begin-rescue-end` blocks to handle exceptions.
- **Code Example:**
  ```ruby
  begin
    1 / 0
  rescue ZeroDivisionError => e
    puts "Error: #{e.message}"
  end
  ```

### **7. Explain the differences between symbols and strings in Ruby.**

**Weight:** 6

- **Answer:**
    - Symbols are immutable and memory-efficient there will be only one reference in the memory and cannot be changes (
      it is read only);
    - Strings are mutable.
- **Code Example:**
  ```ruby
  symbol1 = :hello
  symbol2 = :hello
  string1 = "hello"
  string2 = "hello"
  string1.object_id == string2.object_id # false
  symbol1.object_id == symbol2.object_id # true
  ```

### **8. What is a singleton method in Ruby?**

**Weight:** 6

- **Answer:**
    - A method defined for a single object rather than a class. (static method)
- **Code Example:**
  ```ruby
  obj = "Hello"
  def obj.shout
    self.upcase
  end

  puts obj.shout # Outputs "HELLO"
  ```

### **9. How does Ruby handle method missing?**

**Weight:** 5

- **Answer:**
    - The `method_missing` hook is invoked when a method is called that doesn't exist.
- **Code Example:**
  ```ruby
  class Dynamic
    def method_missing(method_name, *args, &block)
      "You called #{method_name} with #{args}"
    end
  end

  d = Dynamic.new
  puts d.some_method(1, 2) # Outputs "You called some_method with [1, 2]"
  ```

### **10. Explain the purpose of Ruby's Enumerable module.**

**Weight:** 5

- **Answer:**
    - Provides methods for traversal, searching, sorting, and more for collections.
- **Code Example:**
  ```ruby
  arr = [1, 2, 3, 4]
  arr.each { |n| puts n * 2 }
  ```

### **11. What are the differences between `==` and `eql?` in Ruby?**

**Weight:** 4

- **Answer:**
    - `==` checks for value equality; `eql?` checks for both value and type equality.
- **Code Example:**
  ```ruby
  puts 1 == 1.0    # true
  puts 1.eql?(1.0) # false
  ```

### **12. How does Ruby implement mixins?**

**Weight:** 4

- **Answer:**
    - Mixins are implemented by including or extending modules.
- **Code Example:**
  ```ruby
  module Printable
    def print
      "Printing..."
    end
  end

  class Document
    include Printable
  end

  doc = Document.new
  puts doc.print
  ```

### **13. What is metaprogramming in Ruby?**

**Weight:** 3

- **Answer:**
    - Writing code that writes code at runtime.
- **Code Example:**
  ```ruby
  class Dynamic
    define_method(:greet) { "Hello, World!" }
  end

  d = Dynamic.new
  puts d.greet
  ```

### **14. How do you define a constant in Ruby?**

**Weight:** 3

- **Answer:**
    - Constants are defined using uppercase letters.
- **Code Example:**
  ```ruby
  MAX_VALUE = 100
  ```

### **15. What are Ruby's built-in testing libraries?**

**Weight:** 2

- **Answer:**
    - `Test::Unit`, `RSpec`, and `Minitest` are commonly used.
- **Code Example:**
  ```ruby
  require 'minitest/autorun'

  class TestExample < Minitest::Test
    def test_addition
      assert_equal 4, 2 + 2
    end
  end
  ```

### **16. Differentiate between '==' and 'equal?' comparison operators.**

**Weight:** 2

- **Answer:**
    - `==` checks for value equality; `equal?` checks for object identity.
    - `==` is defined in the `Object` class, while `equal?` is defined in the `BasicObject` class.
    - `==` can be overridden by classes, but `equal?` cannot.

- **Code Example:**
  ```ruby
  symbol1 = :hello
  symbol2 = :hello
  string1 = "hello"
  string2 = "hello"
  string1 == string2 # true
  string1.equal?(string2) # false
  symbol1 == symbol2 # true
  symbol1.equal?(symbol2) # true
  ```

### **17. Explain multiple inheritance and mixins in Ruby.**

**Weight:** 2

- **Answer:**
    - Ruby does not support multiple inheritance for classes.
    - Mixins are used to simulate multiple inheritance by including modules in classes.

## **18. How do you identify and resolve memory leaks in a Ruby application?**

**Weight:** 1

- **Answer:**
    - Use memory profiling tools like `ruby-prof` or `Valgrind`.
    - Check for circular references and unused objects.
    - Optimize code to reduce memory usage.
    - Ensure proper garbage collection, and release resources explicitly.
    - Monitoring memory usage and using good programming practices will aid in preventing memory leaks.

## **19. Discuss the global interpreter lock (GIL) and its impact on Ruby's performance.**

**Weight:** 1

- **Answer:**
    - The GIL is a mutex that prevents multiple threads from executing Ruby code simultaneously.
    - It is used to ensure thread safety in C extensions.
    - The GIL can impact performance in multi-threaded applications by limiting parallelism.
    - Ruby's GIL can be a bottleneck for CPU-bound tasks but is less of an issue for I/O-bound tasks.
    - The global interpreter lock (GIL) is a mutex in the CPython interpreter (Ruby's primary implementation) that
      prevents multiple native threads from executing Python (or Ruby) bytecode simultaneously in a single process. This
      means that even on multi-core systems, only one thread can execute Ruby code at a time. GIL can limit the
      potential performance gains from using multiple CPU cores for certain types of workloads that involve CPU-bound
      tasks.

## **20. Explain the concept of fibers and their use in managing lightweight concurrent tasks..**

**Weight:** 1

- **Answer:**
    - Fibers are a lightweight alternative to threads that allow for cooperative multitasking.
    - Fibers can be paused and resumed, allowing for non-preemptive multitasking.
    - Fibers are useful for managing I/O-bound tasks and asynchronous programming.
    - Fibers can be used to implement coroutines and generators in Ruby.
    - Fibers are a lightweight concurrency mechanism in Ruby that allow you to pause and resume the execution of a block
      of code. They provide a way to achieve cooperative multitasking where a single thread can manage multiple
      independent execution contexts.
    - Fibers are useful for scenarios where you want to perform I/O-bound operations without blocking the entire thread.
      They provide a level of concurrency without the constraints of the global interpreter lock (GIL).

## **21. What are Ruby refinements and how do they affect method behavior?**

**Weight:** 1

- **Answer:**
    - Refinements are a way to modify the behavior of classes and modules within a limited scope.
    - Refinements allow you to change the behavior of methods without affecting other parts of the code.
    - Refinements are activated using the `refine` keyword and are limited to the current lexical scope.
    - Refinements are a way to modify the behavior of classes and modules within a limited scope without affecting the
      global behavior of the code. They allow you to change the behavior of methods without affecting other parts of the
      codebase. Refinements are activated using the `refine` keyword and are limited to the current lexical scope.
    - **Code Example:**
    - ```ruby
      module StringExtensions
        refine String do
          def reverse
            "Reversed: #{self}"
          end
        end
      end

      using StringExtensions
      puts "Hello".reverse # Outputs "Reversed: Hello"
      puts "World".reverse # Outputs "Reversed: World"
      ```

## **22. How does Ruby handle concurrency and parallelism?**

**Weight:** 1

- **Answer:**
    - Ruby uses threads for concurrency and processes for parallelism.
    - Ruby's global interpreter lock (GIL) limits parallelism but allows for concurrent I/O-bound tasks.
    - Ruby supports multi-threading and multi-processing for handling concurrent tasks.
    - Ruby's concurrency model is based on threads, which are lightweight processes that share the same memory space.
    - Ruby's parallelism model is based on processes, which are independent instances of the Ruby interpreter that run
      in separate memory spaces.

## **23. Explain the concept of ‘JIT’ (just-in-time) compilation in Ruby.**

**Weight:** 1

- **Answer:**
    - JIT compilation is a technique used to improve the performance of interpreted languages like Ruby.
    - JIT compilers translate code into machine code at runtime for faster execution.
    - Ruby 2.6 introduced a JIT compiler that can improve performance for certain workloads.
    - JIT compilation can optimize hot code paths and reduce the overhead of interpretation.
    - Ruby 3 introduced MJIT (method-based just-in-time compilation) to enhance performance, making Ruby closer in speed
      to lower-level languages.
