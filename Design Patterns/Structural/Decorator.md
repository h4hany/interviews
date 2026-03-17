# Decorator Pattern - Complete Guide

## What is the Decorator Pattern?

The **Decorator Pattern** allows you to add new behavior to objects dynamically by wrapping them with decorator objects. It provides a flexible alternative to subclassing.

## When to Use Decorator Pattern

**Use Decorator Pattern when:**
- ✅ You need to add responsibilities to objects dynamically
- ✅ You want to add features without modifying existing code
- ✅ Subclassing would lead to too many classes
- ✅ You need to combine features in different ways
- ✅ You want to add/remove features at runtime

## How to Recognize the Problem

**Red Flags:**
- You need many subclasses for different feature combinations
- Adding features requires creating new classes
- You want to add features at runtime
- Class hierarchy explodes with combinations
- "I need to add features to an object without changing its class"

## Real-World Example: Coffee Ordering System

### Problem: Without Decorator Pattern

```ruby
# Problem: Class explosion for each combination
class Coffee
  def cost
    5.0
  end
end

class CoffeeWithMilk < Coffee
  def cost
    super + 1.0
  end
end

class CoffeeWithSugar < Coffee
  def cost
    super + 0.5
  end
end

class CoffeeWithMilkAndSugar < Coffee
  def cost
    super + 1.0 + 0.5
  end
end

# Problem: What about CoffeeWithMilkAndSugarAndCream?
# This creates too many classes!
```

### Solution: With Decorator Pattern

```ruby
# Component interface
class Beverage
  def description
    raise NotImplementedError
  end
  
  def cost
    raise NotImplementedError
  end
end

# Concrete component
class Coffee < Beverage
  def description
    "Coffee"
  end
  
  def cost
    5.0
  end
end

# Base decorator
class BeverageDecorator < Beverage
  def initialize(beverage)
    @beverage = beverage  # Wraps the component
  end
  
  def description
    @beverage.description
  end
  
  def cost
    @beverage.cost
  end
end

# Concrete decorators
class MilkDecorator < BeverageDecorator
  def description
    "#{@beverage.description}, Milk"
  end
  
  def cost
    @beverage.cost + 1.0
  end
end

class SugarDecorator < BeverageDecorator
  def description
    "#{@beverage.description}, Sugar"
  end
  
  def cost
    @beverage.cost + 0.5
  end
end

class CreamDecorator < BeverageDecorator
  def description
    "#{@beverage.description}, Cream"
  end
  
  def cost
    @beverage.cost + 1.5
  end
end

# Usage - combine features dynamically!
coffee = Coffee.new
puts "#{coffee.description}: $#{coffee.cost}"

coffee_with_milk = MilkDecorator.new(coffee)
puts "#{coffee_with_milk.description}: $#{coffee_with_milk.cost}"

coffee_with_milk_and_sugar = SugarDecorator.new(coffee_with_milk)
puts "#{coffee_with_milk_and_sugar.description}: $#{coffee_with_milk_and_sugar.cost}"

# Can combine in any order!
coffee_with_everything = CreamDecorator.new(
  SugarDecorator.new(
    MilkDecorator.new(Coffee.new)
  )
)
puts "#{coffee_with_everything.description}: $#{coffee_with_everything.cost}"
```

## Real-World Example: Text Formatting

```ruby
class Text
  def initialize(content)
    @content = content
  end
  
  def render
    @content
  end
end

class TextDecorator
  def initialize(text)
    @text = text
  end
  
  def render
    @text.render
  end
end

class BoldDecorator < TextDecorator
  def render
    "<b>#{@text.render}</b>"
  end
end

class ItalicDecorator < TextDecorator
  def render
    "<i>#{@text.render}</i>"
  end
end

class UnderlineDecorator < TextDecorator
  def render
    "<u>#{@text.render}</u>"
  end
end

# Usage
text = Text.new("Hello World")

bold_text = BoldDecorator.new(text)
puts bold_text.render  # <b>Hello World</b>

bold_italic = ItalicDecorator.new(bold_text)
puts bold_italic.render  # <i><b>Hello World</b></i>

all_formats = UnderlineDecorator.new(
  ItalicDecorator.new(
    BoldDecorator.new(text)
  )
)
puts all_formats.render  # <u><i><b>Hello World</b></i></u>
```

## Real-World Example: HTTP Request Decorators

```ruby
class HTTPRequest
  def initialize(url)
    @url = url
    @headers = {}
  end
  
  def execute
    puts "Executing request to #{@url}"
    "Response from #{@url}"
  end
end

class RequestDecorator
  def initialize(request)
    @request = request
  end
  
  def execute
    @request.execute
  end
end

class AuthenticationDecorator < RequestDecorator
  def execute
    puts "Adding authentication header"
    result = @request.execute
    puts "Request authenticated"
    result
  end
end

class LoggingDecorator < RequestDecorator
  def execute
    puts "Logging request start"
    result = @request.execute
    puts "Logging request end"
    result
  end
end

class CachingDecorator < RequestDecorator
  def initialize(request)
    super(request)
    @cache = {}
  end
  
  def execute
    if @cache[@request.instance_variable_get(:@url)]
      puts "Returning cached response"
      return @cache[@request.instance_variable_get(:@url)]
    end
    
    result = @request.execute
    @cache[@request.instance_variable_get(:@url)] = result
    result
  end
end

# Usage - add features dynamically
request = HTTPRequest.new("https://api.example.com")

# Add logging
logged_request = LoggingDecorator.new(request)
logged_request.execute

# Add authentication and logging
auth_request = AuthenticationDecorator.new(
  LoggingDecorator.new(request)
)
auth_request.execute

# Add all features
full_request = CachingDecorator.new(
  AuthenticationDecorator.new(
    LoggingDecorator.new(request)
  )
)
full_request.execute
```

## Benefits of Decorator Pattern

1. **Flexibility**: Add features dynamically at runtime
2. **No Explosion**: Avoids class explosion from combinations
3. **Composition**: Can combine decorators in any order
4. **Single Responsibility**: Each decorator adds one feature

## When NOT to Use Decorator Pattern

- ❌ You need to add many unrelated features
- ❌ Decorators need to know about each other
- ❌ Simple cases where inheritance is sufficient

## Summary

**Decorator Pattern:**
- Adds behavior to objects dynamically
- Wraps objects with decorators
- Use when you need flexible feature combinations
- Alternative to subclassing for adding features


