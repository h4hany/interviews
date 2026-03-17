# Abstract Factory Pattern - Complete Guide

## What is the Abstract Factory Pattern?

The **Abstract Factory Pattern** provides an interface for creating families of related or dependent objects without specifying their concrete classes. It's like a factory of factories.

## When to Use Abstract Factory Pattern

**Use Abstract Factory Pattern when:**
- ✅ You need to create families of related objects
- ✅ You want to ensure objects from the same family are used together
- ✅ You need to support multiple product families
- ✅ You want to hide platform-specific implementations
- ✅ Objects must be compatible with each other

## How to Recognize the Problem

**Red Flags:**
- You need to create groups of related objects
- Objects must work together (e.g., UI components from same theme)
- You have multiple variants of the same product family
- Mixing objects from different families causes issues
- "I need to create a set of objects that must be compatible"

## Real-World Example: UI Component Factory

### Problem: Without Abstract Factory

```ruby
# Problem: Can accidentally mix Windows and Mac UI components
class WindowsButton
  def render
    puts "Windows-style button"
  end
end

class MacButton
  def render
    puts "Mac-style button"
  end
end

class WindowsDialog
  def render
    puts "Windows-style dialog"
  end
end

class MacDialog
  def render
    puts "Mac-style dialog"
  end
end

# Problem: Can mix Windows and Mac components (incompatible!)
button = WindowsButton.new
dialog = MacDialog.new  # Wrong! Different families!
button.render
dialog.render
```

### Solution: With Abstract Factory

```ruby
# Abstract Factory - defines interface for creating UI components
class UIFactory
  def create_button
    raise NotImplementedError
  end
  
  def create_dialog
    raise NotImplementedError
  end
  
  def create_menu
    raise NotImplementedError
  end
end

# Concrete Factory 1: Windows UI Factory
class WindowsUIFactory < UIFactory
  def create_button
    WindowsButton.new
  end
  
  def create_dialog
    WindowsDialog.new
  end
  
  def create_menu
    WindowsMenu.new
  end
end

# Concrete Factory 2: Mac UI Factory
class MacUIFactory < UIFactory
  def create_button
    MacButton.new
  end
  
  def create_dialog
    MacDialog.new
  end
  
  def create_menu
    MacMenu.new
  end
end

# Product interfaces
class Button
  def render
    raise NotImplementedError
  end
end

class Dialog
  def render
    raise NotImplementedError
  end
end

# Windows products
class WindowsButton < Button
  def render
    puts "Windows-style button"
  end
end

class WindowsDialog < Dialog
  def render
    puts "Windows-style dialog"
  end
end

class WindowsMenu
  def render
    puts "Windows-style menu"
  end
end

# Mac products
class MacButton < Button
  def render
    puts "Mac-style button"
  end
end

class MacDialog < Dialog
  def render
    puts "Mac-style dialog"
  end
end

class MacMenu
  def render
    puts "Mac-style menu"
  end
end

# Client code - uses abstract factory
class Application
  def initialize(ui_factory)
    @ui_factory = ui_factory
  end
  
  def create_ui
    # All components from same family (guaranteed compatibility)
    button = @ui_factory.create_button
    dialog = @ui_factory.create_dialog
    menu = @ui_factory.create_menu
    
    button.render
    dialog.render
    menu.render
  end
end

# Usage
if platform == :windows
  factory = WindowsUIFactory.new
elsif platform == :mac
  factory = MacUIFactory.new
end

app = Application.new(factory)
app.create_ui  # All components from same family!
```

## Real-World Example: Database Factory (Multiple Product Families)

```ruby
# Abstract Factory
class DatabaseFactory
  def create_connection
    raise NotImplementedError
  end
  
  def create_query_builder
    raise NotImplementedError
  end
  
  def create_transaction_manager
    raise NotImplementedError
  end
end

# Concrete Factory 1: MySQL Family
class MySQLFactory < DatabaseFactory
  def create_connection
    MySQLConnection.new
  end
  
  def create_query_builder
    MySQLQueryBuilder.new
  end
  
  def create_transaction_manager
    MySQLTransactionManager.new
  end
end

# Concrete Factory 2: PostgreSQL Family
class PostgreSQLFactory < DatabaseFactory
  def create_connection
    PostgreSQLConnection.new
  end
  
  def create_query_builder
    PostgreSQLQueryBuilder.new
  end
  
  def create_transaction_manager
    PostgreSQLTransactionManager.new
  end
end

# Products
class MySQLConnection
  def connect
    puts "MySQL connection"
  end
end

class MySQLQueryBuilder
  def build_query(table)
    puts "MySQL query for #{table}"
  end
end

class MySQLTransactionManager
  def begin_transaction
    puts "MySQL transaction started"
  end
end

class PostgreSQLConnection
  def connect
    puts "PostgreSQL connection"
  end
end

class PostgreSQLQueryBuilder
  def build_query(table)
    puts "PostgreSQL query for #{table}"
  end
end

class PostgreSQLTransactionManager
  def begin_transaction
    puts "PostgreSQL transaction started"
  end
end

# Client
class DatabaseClient
  def initialize(factory)
    @factory = factory
  end
  
  def execute_operation
    # All components from same database family (compatible!)
    connection = @factory.create_connection
    query_builder = @factory.create_query_builder
    transaction = @factory.create_transaction_manager
    
    connection.connect
    query_builder.build_query("users")
    transaction.begin_transaction
  end
end

# Usage
factory = MySQLFactory.new  # Or PostgreSQLFactory.new
client = DatabaseClient.new(factory)
client.execute_operation  # All components work together!
```

## Difference: Factory vs Abstract Factory

| Factory Pattern | Abstract Factory Pattern |
|----------------|-------------------------|
| Creates one type of object | Creates families of related objects |
| Single factory method | Multiple factory methods |
| Returns one product | Returns multiple related products |
| Simpler | More complex |

## Benefits of Abstract Factory Pattern

1. **Consistency**: Ensures objects from same family are used together
2. **Flexibility**: Easy to switch between product families
3. **Isolation**: Hides concrete classes from client
4. **Compatibility**: Prevents mixing incompatible objects

## When NOT to Use Abstract Factory Pattern

- ❌ You only need to create one type of object (use Factory)
- ❌ Product families don't need to be kept together
- ❌ Adding new product types requires changing abstract factory (violates OCP)

## Summary

**Abstract Factory Pattern:**
- Creates families of related objects
- Ensures objects are compatible
- Use when you need groups of objects that work together
- More complex than Factory, but ensures consistency


