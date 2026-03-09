# Composite Pattern - Complete Guide

## What is the Composite Pattern?

The **Composite Pattern** allows you to compose objects into tree structures to represent part-whole hierarchies. It lets clients treat individual objects and compositions uniformly.

## When to Use Composite Pattern

**Use Composite Pattern when:**
- ✅ You need to represent part-whole hierarchies
- ✅ You want clients to treat individual objects and groups uniformly
- ✅ You have tree-like structures
- ✅ You want to apply operations to entire tree structures
- ✅ You need recursive composition

## How to Recognize the Problem

**Red Flags:**
- You have objects that contain other objects of the same type
- You need to treat individual items and groups the same way
- You have tree-like structures (folders/files, menus/submenus)
- Code has special cases for "leaf" vs "composite" objects
- "I need to treat a single item and a group of items the same way"

## Real-World Example: File System

### Problem: Without Composite Pattern

```ruby
# Problem: Different handling for files and folders
class File
  def size
    100  # File size
  end
end

class Folder
  def initialize
    @files = []
  end
  
  def add_file(file)
    @files << file
  end
  
  def size
    # Special handling for folders
    @files.sum { |file| file.size }
  end
end

# Problem: Can't have folders inside folders easily
# Problem: Different interfaces for files and folders
```

### Solution: With Composite Pattern

```ruby
# Component interface - common interface for leaf and composite
class FileSystemComponent
  def name
    raise NotImplementedError
  end
  
  def size
    raise NotImplementedError
  end
  
  def add(component)
    raise NotImplementedError
  end
  
  def remove(component)
    raise NotImplementedError
  end
  
  def children
    raise NotImplementedError
  end
end

# Leaf - represents individual file
class File < FileSystemComponent
  def initialize(name, size)
    @name = name
    @size = size
  end
  
  def name
    @name
  end
  
  def size
    @size
  end
  
  def add(component)
    raise "Cannot add to a file"
  end
  
  def remove(component)
    raise "Cannot remove from a file"
  end
  
  def children
    []
  end
end

# Composite - represents folder (can contain files and folders)
class Folder < FileSystemComponent
  def initialize(name)
    @name = name
    @children = []
  end
  
  def name
    @name
  end
  
  def size
    # Recursively calculate size
    @children.sum { |child| child.size }
  end
  
  def add(component)
    @children << component
  end
  
  def remove(component)
    @children.delete(component)
  end
  
  def children
    @children
  end
end

# Usage - treat files and folders the same way!
root = Folder.new("Root")

documents = Folder.new("Documents")
documents.add(File.new("resume.pdf", 200))
documents.add(File.new("letter.txt", 50))

pictures = Folder.new("Pictures")
pictures.add(File.new("photo1.jpg", 500))
pictures.add(File.new("photo2.jpg", 600))

root.add(documents)
root.add(pictures)

# Same interface for both!
puts root.size  # Works for folder
puts documents.size  # Works for folder
puts File.new("test.txt", 100).size  # Works for file

# Can nest folders inside folders!
subfolder = Folder.new("Subfolder")
subfolder.add(File.new("nested.txt", 75))
documents.add(subfolder)

puts root.size  # Recursively calculates all!
```

## Real-World Example: Organization Hierarchy

```ruby
class Employee
  def initialize(name, salary)
    @name = name
    @salary = salary
    @subordinates = []
  end
  
  def add(employee)
    @subordinates << employee
  end
  
  def remove(employee)
    @subordinates.delete(employee)
  end
  
  def get_salary
    @salary + @subordinates.sum { |e| e.get_salary }
  end
  
  def show_details(indent = 0)
    puts "#{'  ' * indent}#{@name} - Salary: $#{@salary}"
    @subordinates.each { |e| e.show_details(indent + 1) }
  end
end

# Usage
ceo = Employee.new("John CEO", 100000)
cto = Employee.new("Jane CTO", 80000)
cfo = Employee.new("Bob CFO", 75000)

developer1 = Employee.new("Alice Dev", 60000)
developer2 = Employee.new("Charlie Dev", 55000)

ceo.add(cto)
ceo.add(cfo)
cto.add(developer1)
cto.add(developer2)

puts "Total salary: $#{ceo.get_salary}"
ceo.show_details
```

## Real-World Example: Menu System

```ruby
class MenuComponent
  def name
    raise NotImplementedError
  end
  
  def price
    raise NotImplementedError
  end
  
  def add(component)
    raise "Not supported"
  end
  
  def remove(component)
    raise "Not supported"
  end
  
  def children
    []
  end
  
  def print
    raise NotImplementedError
  end
end

class MenuItem < MenuComponent
  def initialize(name, price)
    @name = name
    @price = price
  end
  
  def name
    @name
  end
  
  def price
    @price
  end
  
  def print
    puts "  #{@name} - $#{@price}"
  end
end

class Menu < MenuComponent
  def initialize(name)
    @name = name
    @children = []
  end
  
  def name
    @name
  end
  
  def price
    @children.sum { |child| child.price }
  end
  
  def add(component)
    @children << component
  end
  
  def remove(component)
    @children.delete(component)
  end
  
  def children
    @children
  end
  
  def print
    puts "#{@name} - Total: $#{price}"
    @children.each { |child| child.print }
  end
end

# Usage
breakfast = Menu.new("Breakfast")
breakfast.add(MenuItem.new("Pancakes", 8))
breakfast.add(MenuItem.new("Waffles", 7))

lunch = Menu.new("Lunch")
lunch.add(MenuItem.new("Burger", 12))
lunch.add(MenuItem.new("Salad", 10))

dinner = Menu.new("Dinner")
dinner.add(MenuItem.new("Steak", 25))
dinner.add(MenuItem.new("Pasta", 18))

main_menu = Menu.new("Restaurant Menu")
main_menu.add(breakfast)
main_menu.add(lunch)
main_menu.add(dinner)

main_menu.print  # Prints entire menu tree!
```

## Benefits of Composite Pattern

1. **Uniformity**: Treat individual and composite objects the same
2. **Flexibility**: Easy to add new component types
3. **Simplicity**: Client code is simpler (no special cases)
4. **Recursion**: Natural for tree structures

## When NOT to Use Composite Pattern

- ❌ Structure is not tree-like
- ❌ Components are fundamentally different
- ❌ Over-engineering for simple hierarchies

## Summary

**Composite Pattern:**
- Treats individual objects and groups uniformly
- Perfect for tree-like structures
- Use when you have part-whole hierarchies
- Allows recursive operations on entire structures

