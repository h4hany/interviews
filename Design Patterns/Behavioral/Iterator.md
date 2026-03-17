# Iterator Pattern - Complete Guide

## What is the Iterator Pattern?

The **Iterator Pattern** provides a way to access elements of an aggregate object sequentially without exposing its underlying representation.

## When to Use Iterator Pattern

**Use Iterator Pattern when:**
- ✅ You need to traverse different data structures uniformly
- ✅ You want to hide the internal structure of a collection
- ✅ You need multiple ways to traverse the same collection
- ✅ You want to provide a standard way to iterate
- ✅ Collection structure might change

## How to Recognize the Problem

**Red Flags:**
- Code directly accesses collection internals
- Different traversal logic scattered throughout code
- Hard to change collection structure
- "I need to iterate through collections in different ways"

## Real-World Example: Custom Collection

### Problem: Without Iterator

```ruby
class BookCollection
  def initialize
    @books = []
  end
  
  def add(book)
    @books << book
  end
  
  # Problem: Exposes internal structure
  def books
    @books
  end
end

# Client must know about array structure
collection = BookCollection.new
collection.books.each { |book| puts book.title }  # Exposes @books!
```

### Solution: With Iterator

```ruby
# Iterator interface
class Iterator
  def has_next?
    raise NotImplementedError
  end
  
  def next
    raise NotImplementedError
  end
end

# Aggregate interface
class Aggregate
  def create_iterator
    raise NotImplementedError
  end
end

# Concrete aggregate
class BookCollection < Aggregate
  def initialize
    @books = []
  end
  
  def add(book)
    @books << book
  end
  
  def create_iterator
    BookIterator.new(@books)
  end
end

# Concrete iterator
class BookIterator < Iterator
  def initialize(books)
    @books = books
    @index = 0
  end
  
  def has_next?
    @index < @books.length
  end
  
  def next
    book = @books[@index]
    @index += 1
    book
  end
end

# Usage - doesn't expose internal structure
collection = BookCollection.new
collection.add(Book.new("Book 1"))
collection.add(Book.new("Book 2"))

iterator = collection.create_iterator
while iterator.has_next?
  puts iterator.next.title
end
```

## Real-World Example: Tree Traversal

```ruby
class TreeNode
  attr_accessor :value, :left, :right
  
  def initialize(value)
    @value = value
    @left = nil
    @right = nil
  end
end

class TreeIterator
  def initialize(root)
    @root = root
    @stack = [root] if root
  end
  
  def has_next?
    !@stack.empty?
  end
  
  def next
    node = @stack.pop
    @stack << node.right if node.right
    @stack << node.left if node.left
    node.value
  end
end

class BinaryTree
  def initialize(root)
    @root = root
  end
  
  def create_iterator
    TreeIterator.new(@root)
  end
end
```

## Benefits of Iterator Pattern

1. **Encapsulation**: Hides collection structure
2. **Uniform Interface**: Same interface for different collections
3. **Multiple Iterators**: Can have different traversal methods
4. **Separation**: Traversal logic separated from collection

## When NOT to Use Iterator Pattern

- ❌ Simple collections (use built-in iterators)
- ❌ Collections don't need traversal abstraction
- ❌ Over-engineering for simple iteration

## Summary

**Iterator Pattern:**
- Provides way to traverse collections
- Hides collection structure
- Use when you need flexible traversal
- Most languages have built-in iterators


