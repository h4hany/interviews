# Command Pattern - Complete Guide

## What is the Command Pattern?

The **Command Pattern** encapsulates a request as an object, allowing you to parameterize clients with different requests, queue operations, and support undo operations.

## When to Use Command Pattern

**Use Command Pattern when:**
- ✅ You need to parameterize objects with operations
- ✅ You want to queue operations
- ✅ You need undo/redo functionality
- ✅ You want to log operations
- ✅ You need to support transactions

## How to Recognize the Problem

**Red Flags:**
- You need to queue operations
- You want undo/redo functionality
- Operations need to be logged
- You need to delay operation execution
- "I need to store operations and execute them later"

## Real-World Example: Text Editor with Undo

### Problem: Without Command

```ruby
class TextEditor
  def initialize
    @text = ""
  end
  
  def add_text(text)
    @text += text
  end
  
  def delete_text(length)
    @text = @text[0...-length]
  end
  
  # Problem: No way to undo operations!
end
```

### Solution: With Command

```ruby
# Command interface
class Command
  def execute
    raise NotImplementedError
  end
  
  def undo
    raise NotImplementedError
  end
end

# Concrete commands
class AddTextCommand < Command
  def initialize(editor, text)
    @editor = editor
    @text = text
  end
  
  def execute
    @editor.add_text(@text)
  end
  
  def undo
    @editor.delete_text(@text.length)
  end
end

class DeleteTextCommand < Command
  def initialize(editor, length)
    @editor = editor
    @length = length
    @deleted_text = nil
  end
  
  def execute
    @deleted_text = @editor.get_last_n_chars(@length)
    @editor.delete_text(@length)
  end
  
  def undo
    @editor.add_text(@deleted_text) if @deleted_text
  end
end

class TextEditor
  def initialize
    @text = ""
  end
  
  def add_text(text)
    @text += text
  end
  
  def delete_text(length)
    @text = @text[0...-length]
  end
  
  def get_last_n_chars(n)
    @text[-n..-1]
  end
  
  def text
    @text
  end
end

# Invoker - executes commands
class CommandInvoker
  def initialize
    @history = []
    @current_index = -1
  end
  
  def execute_command(command)
    # Remove any commands after current index (for redo)
    @history = @history[0..@current_index] if @current_index >= 0
    @history << command
    @current_index = @history.length - 1
    command.execute
  end
  
  def undo
    return if @current_index < 0
    @history[@current_index].undo
    @current_index -= 1
  end
  
  def redo
    return if @current_index >= @history.length - 1
    @current_index += 1
    @history[@current_index].execute
  end
end

# Usage
editor = TextEditor.new
invoker = CommandInvoker.new

invoker.execute_command(AddTextCommand.new(editor, "Hello"))
puts editor.text  # "Hello"

invoker.execute_command(AddTextCommand.new(editor, " World"))
puts editor.text  # "Hello World"

invoker.undo
puts editor.text  # "Hello"

invoker.redo
puts editor.text  # "Hello World"
```

## Real-World Example: Remote Control

```ruby
class Command
  def execute
    raise NotImplementedError
  end
end

class Light
  def on
    puts "Light is ON"
  end
  
  def off
    puts "Light is OFF"
  end
end

class LightOnCommand < Command
  def initialize(light)
    @light = light
  end
  
  def execute
    @light.on
  end
end

class LightOffCommand < Command
  def initialize(light)
    @light = light
  end
  
  def execute
    @light.off
  end
end

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

# Usage
light = Light.new
remote = RemoteControl.new

remote.set_command(LightOnCommand.new(light))
remote.press_button  # Light is ON
```

## Benefits of Command Pattern

1. **Undo/Redo**: Easy to implement
2. **Queuing**: Can queue commands for later execution
3. **Logging**: Can log all commands
4. **Macro Commands**: Combine multiple commands
5. **Decoupling**: Separates invoker from receiver

## When NOT to Use Command Pattern

- ❌ Operations are too simple
- ❌ No need for undo/redo or queuing
- ❌ Over-engineering for simple cases

## Summary

**Command Pattern:**
- Encapsulates requests as objects
- Supports undo/redo
- Can queue and log operations
- Use when you need to parameterize with operations


