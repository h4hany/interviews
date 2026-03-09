# Memento Pattern - Complete Guide

## What is the Memento Pattern?

The **Memento Pattern** captures and externalizes an object's internal state so it can be restored later, without violating encapsulation.

## When to Use Memento Pattern

**Use Memento Pattern when:**
- ✅ You need to save and restore object state
- ✅ You want undo/redo functionality
- ✅ You need to implement checkpoints
- ✅ Direct access to object's state would break encapsulation
- ✅ You want to implement snapshots

## How to Recognize the Problem

**Red Flags:**
- You need to save object state for later restoration
- You want undo functionality
- You need to implement checkpoints or snapshots
- "I need to save the current state and restore it later"

## Real-World Example: Text Editor with Undo

### Problem: Without Memento

```ruby
class TextEditor
  def initialize
    @content = ""
  end
  
  def add_text(text)
    @content += text
  end
  
  # Problem: How to undo? Need to save state somehow
end
```

### Solution: With Memento

```ruby
# Memento - stores state
class TextMemento
  attr_reader :content
  
  def initialize(content)
    @content = content
  end
end

# Originator - creates and uses mementos
class TextEditor
  def initialize
    @content = ""
  end
  
  def add_text(text)
    @content += text
  end
  
  def content
    @content
  end
  
  # Create memento
  def save
    TextMemento.new(@content)
  end
  
  # Restore from memento
  def restore(memento)
    @content = memento.content
  end
end

# Caretaker - manages mementos
class History
  def initialize(editor)
    @editor = editor
    @history = []
  end
  
  def save_state
    @history << @editor.save
  end
  
  def undo
    return if @history.empty?
    @history.pop  # Remove current state
    return if @history.empty?
    @editor.restore(@history.last)  # Restore previous
  end
end

# Usage
editor = TextEditor.new
history = History.new(editor)

editor.add_text("Hello")
history.save_state

editor.add_text(" World")
history.save_state

editor.add_text("!")
puts editor.content  # "Hello World!"

history.undo
puts editor.content  # "Hello World"

history.undo
puts editor.content  # "Hello"
```

## Real-World Example: Game Checkpoints

```ruby
class GameMemento
  def initialize(level, score, lives)
    @level = level
    @score = score
    @lives = lives
  end
  
  attr_reader :level, :score, :lives
end

class Game
  def initialize
    @level = 1
    @score = 0
    @lives = 3
  end
  
  def play
    @score += 100
    @level += 1
  end
  
  def lose_life
    @lives -= 1
  end
  
  def save_checkpoint
    GameMemento.new(@level, @score, @lives)
  end
  
  def restore_checkpoint(memento)
    @level = memento.level
    @score = memento.score
    @lives = memento.lives
  end
  
  def status
    "Level: #{@level}, Score: #{@score}, Lives: #{@lives}"
  end
end

class CheckpointManager
  def initialize(game)
    @game = game
    @checkpoints = []
  end
  
  def save_checkpoint
    @checkpoints << @game.save_checkpoint
    puts "Checkpoint saved"
  end
  
  def restore_last_checkpoint
    return if @checkpoints.empty?
    @game.restore_checkpoint(@checkpoints.last)
    puts "Restored to last checkpoint"
  end
end

# Usage
game = Game.new
checkpoint_manager = CheckpointManager.new(game)

game.play
puts game.status  # Level: 2, Score: 100, Lives: 3

checkpoint_manager.save_checkpoint

game.play
game.lose_life
puts game.status  # Level: 3, Score: 200, Lives: 2

checkpoint_manager.restore_last_checkpoint
puts game.status  # Level: 2, Score: 100, Lives: 3 (restored!)
```

## Benefits of Memento Pattern

1. **Encapsulation**: Doesn't expose object's internal state
2. **Undo/Redo**: Easy to implement
3. **Checkpoints**: Save state at any point
4. **Separation**: State management separated from business logic

## When NOT to Use Memento Pattern

- ❌ Object state is simple (just save directly)
- ❌ Mementos consume too much memory
- ❌ Over-engineering for simple undo

## Summary

**Memento Pattern:**
- Saves and restores object state
- Maintains encapsulation
- Use for undo/redo or checkpoints
- Like a save game feature

