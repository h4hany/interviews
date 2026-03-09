# Bridge Pattern - Complete Guide

## What is the Bridge Pattern?

The **Bridge Pattern** separates an object's abstraction from its implementation, allowing them to vary independently. It decouples "what" from "how".

## When to Use Bridge Pattern

**Use Bridge Pattern when:**
- ✅ You want to avoid permanent binding between abstraction and implementation
- ✅ Abstractions and implementations should be extensible independently
- ✅ Changes in implementation should not affect clients
- ✅ You want to hide implementation details from clients
- ✅ You have a class hierarchy that grows in two dimensions

## How to Recognize the Problem

**Red Flags:**
- Class hierarchy has many combinations (e.g., CircleRed, CircleBlue, SquareRed, SquareBlue)
- Adding new types requires creating many new classes
- Implementation details are mixed with abstraction
- "I need to support multiple implementations of the same abstraction"

## Real-World Example: Remote Control and Devices

### Problem: Without Bridge Pattern

```ruby
# Problem: Explosion of classes for each combination
class BasicTVRemote
  def turn_on
    puts "Basic TV: Turning on"
  end
end

class AdvancedTVRemote
  def turn_on
    puts "Advanced TV: Turning on"
  end
end

class BasicRadioRemote
  def turn_on
    puts "Basic Radio: Turning on"
  end
end

class AdvancedRadioRemote
  def turn_on
    puts "Advanced Radio: Turning on"
  end
end

# Problem: If we add new device (AC), we need:
# - BasicACRemote
# - AdvancedACRemote
# This creates a combinatorial explosion!
```

### Solution: With Bridge Pattern

```ruby
# Implementation interface (how)
class Device
  def turn_on
    raise NotImplementedError
  end
  
  def turn_off
    raise NotImplementedError
  end
  
  def set_volume(level)
    raise NotImplementedError
  end
end

# Concrete implementations
class TV < Device
  def turn_on
    puts "TV: Turning on"
  end
  
  def turn_off
    puts "TV: Turning off"
  end
  
  def set_volume(level)
    puts "TV: Volume set to #{level}"
  end
end

class Radio < Device
  def turn_on
    puts "Radio: Turning on"
  end
  
  def turn_off
    puts "Radio: Turning off"
  end
  
  def set_volume(level)
    puts "Radio: Volume set to #{level}"
  end
end

# Abstraction (what)
class RemoteControl
  def initialize(device)
    @device = device  # Bridge: connects abstraction to implementation
  end
  
  def turn_on
    @device.turn_on
  end
  
  def turn_off
    @device.turn_off
  end
end

# Refined abstraction
class AdvancedRemoteControl < RemoteControl
  def mute
    @device.set_volume(0)
  end
  
  def volume_up
    current = 5  # Would get from device
    @device.set_volume(current + 1)
  end
  
  def volume_down
    current = 5
    @device.set_volume(current - 1)
  end
end

# Usage
tv = TV.new
radio = Radio.new

basic_remote = RemoteControl.new(tv)
basic_remote.turn_on

advanced_remote = AdvancedRemoteControl.new(radio)
advanced_remote.turn_on
advanced_remote.volume_up

# Easy to add new device without modifying remote classes!
class AC < Device
  def turn_on
    puts "AC: Turning on"
  end
  
  def turn_off
    puts "AC: Turning off"
  end
  
  def set_volume(level)
    puts "AC: Temperature set to #{level}"
  end
end

ac = AC.new
remote = AdvancedRemoteControl.new(ac)  # Works immediately!
```

## Real-World Example: Shape and Rendering

```ruby
# Implementation: How shapes are rendered
class Renderer
  def render_circle(radius)
    raise NotImplementedError
  end
  
  def render_square(side)
    raise NotImplementedError
  end
end

class VectorRenderer < Renderer
  def render_circle(radius)
    puts "Drawing a circle of radius #{radius} as vector"
  end
  
  def render_square(side)
    puts "Drawing a square of side #{side} as vector"
  end
end

class RasterRenderer < Renderer
  def render_circle(radius)
    puts "Drawing a circle of radius #{radius} as pixels"
  end
  
  def render_square(side)
    puts "Drawing a square of side #{side} as pixels"
  end
end

# Abstraction: What shapes are
class Shape
  def initialize(renderer)
    @renderer = renderer  # Bridge
  end
  
  def draw
    raise NotImplementedError
  end
end

class Circle < Shape
  def initialize(renderer, radius)
    super(renderer)
    @radius = radius
  end
  
  def draw
    @renderer.render_circle(@radius)
  end
end

class Square < Shape
  def initialize(renderer, side)
    super(renderer)
    @side = side
  end
  
  def draw
    @renderer.render_square(@side)
  end
end

# Usage
vector = VectorRenderer.new
raster = RasterRenderer.new

circle1 = Circle.new(vector, 5)
circle1.draw  # Vector rendering

circle2 = Circle.new(raster, 5)
circle2.draw  # Raster rendering

# Can mix and match independently!
```

## Benefits of Bridge Pattern

1. **Separation**: Separates abstraction from implementation
2. **Flexibility**: Can change implementations independently
3. **Extensibility**: Easy to add new abstractions or implementations
4. **No Explosion**: Avoids combinatorial class explosion

## When NOT to Use Bridge Pattern

- ❌ Abstraction and implementation are tightly coupled
- ❌ You only have one implementation
- ❌ Over-engineering for simple cases

## Summary

**Bridge Pattern:**
- Separates "what" (abstraction) from "how" (implementation)
- Allows them to vary independently
- Prevents combinatorial class explosion
- Use when you have multiple dimensions of variation

