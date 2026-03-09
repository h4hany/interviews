# Flyweight Pattern - Complete Guide

## What is the Flyweight Pattern?

The **Flyweight Pattern** minimizes memory usage by sharing data among similar objects. It's useful when you have many objects with similar state.

## When to Use Flyweight Pattern

**Use Flyweight Pattern when:**
- ✅ You have many similar objects
- ✅ Memory usage is a concern
- ✅ Objects have intrinsic (shared) and extrinsic (unique) state
- ✅ You want to reduce object creation overhead
- ✅ Most object state can be made extrinsic

## How to Recognize the Problem

**Red Flags:**
- Creating many similar objects consumes too much memory
- Objects share a lot of common data
- You have thousands of objects with similar properties
- Memory usage is high due to object duplication
- "I have many objects that are mostly the same"

## Real-World Example: Text Editor

### Problem: Without Flyweight

```ruby
# Problem: Each character creates a new object with all properties
class Character
  def initialize(char, font, size, color)
    @char = char
    @font = font      # Same font used many times
    @size = size      # Same size used many times
    @color = color    # Same color used many times
  end
  
  def render
    puts "Rendering #{@char} with font=#{@font}, size=#{@size}, color=#{@color}"
  end
end

# Problem: 1000 characters = 1000 objects with duplicate font/size/color data
text = "Hello World" * 100
characters = text.chars.map { |char| Character.new(char, "Arial", 12, "black") }
# Wastes memory storing same font/size/color 1000 times!
```

### Solution: With Flyweight

```ruby
# Intrinsic state (shared) - stored in flyweight
class CharacterStyle
  attr_reader :font, :size, :color
  
  def initialize(font, size, color)
    @font = font
    @size = size
    @color = color
  end
  
  def render(char)
    puts "Rendering #{char} with font=#{@font}, size=#{@size}, color=#{@color}"
  end
end

# Flyweight factory - reuses shared styles
class StyleFactory
  def initialize
    @styles = {}
  end
  
  def get_style(font, size, color)
    key = "#{font}-#{size}-#{color}"
    @styles[key] ||= CharacterStyle.new(font, size, color)
    @styles[key]
  end
end

# Character with extrinsic state (unique per character)
class Character
  def initialize(char, style)
    @char = char      # Extrinsic: unique per character
    @style = style    # Intrinsic: shared among many characters
  end
  
  def render
    @style.render(@char)
  end
end

# Usage
factory = StyleFactory.new

# Many characters share the same style
style1 = factory.get_style("Arial", 12, "black")
style2 = factory.get_style("Arial", 12, "black")  # Reuses style1!

char1 = Character.new("H", style1)
char2 = Character.new("e", style2)  # Shares same style object

# Memory efficient: 1000 characters might share 10 style objects
```

## Real-World Example: Game Trees

```ruby
# Tree in a game - millions of trees, but only few types
class TreeType
  attr_reader :name, :color, :texture
  
  def initialize(name, color, texture)
    @name = name
    @color = color
    @texture = texture
  end
  
  def render(x, y)
    puts "Rendering #{@name} tree at (#{x}, #{y}) with color #{@color}"
  end
end

class TreeFactory
  def initialize
    @tree_types = {}
  end
  
  def get_tree_type(name, color, texture)
    key = "#{name}-#{color}-#{texture}"
    @tree_types[key] ||= TreeType.new(name, color, texture)
    @tree_types[key]
  end
end

class Tree
  def initialize(x, y, tree_type)
    @x = x           # Extrinsic: unique position
    @y = y           # Extrinsic: unique position
    @type = tree_type # Intrinsic: shared type
  end
  
  def render
    @type.render(@x, @y)
  end
end

# Usage
factory = TreeFactory.new

# Create tree types (shared)
oak = factory.get_tree_type("Oak", "green", "rough")
pine = factory.get_tree_type("Pine", "dark green", "smooth")

# Create many trees (share types)
trees = []
1000.times do |i|
  type = i % 2 == 0 ? oak : pine
  trees << Tree.new(rand(1000), rand(1000), type)
end

# Memory efficient: 1000 trees, but only 2 tree type objects!
```

## Benefits of Flyweight Pattern

1. **Memory Efficiency**: Shares common data
2. **Performance**: Reduces object creation
3. **Scalability**: Can handle many objects

## When NOT to Use Flyweight Pattern

- ❌ Objects don't share much common state
- ❌ Extrinsic state is complex
- ❌ Over-engineering for small number of objects

## Summary

**Flyweight Pattern:**
- Shares common data among many objects
- Separates intrinsic (shared) from extrinsic (unique) state
- Use when you have many similar objects
- Saves memory by reusing shared state

