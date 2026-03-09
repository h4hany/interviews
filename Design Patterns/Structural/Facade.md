# Facade Pattern - Complete Guide

## What is the Facade Pattern?

The **Facade Pattern** provides a simplified interface to a complex subsystem, hiding its complexity and making it easier to use.

## When to Use Facade Pattern

**Use Facade Pattern when:**
- ✅ You want to provide a simple interface to a complex subsystem
- ✅ You want to decouple clients from subsystem components
- ✅ You want to create a layered architecture
- ✅ Subsystem is complex with many interdependent classes
- ✅ You want to hide implementation details

## How to Recognize the Problem

**Red Flags:**
- Client code needs to interact with many classes
- Complex initialization sequences
- Client code is tightly coupled to subsystem
- "I need to simplify how clients use this complex system"

## Real-World Example: Home Theater System

### Problem: Without Facade

```ruby
# Complex subsystem with many components
class Amplifier
  def on
    puts "Amplifier on"
  end
  
  def set_volume(level)
    puts "Volume set to #{level}"
  end
end

class DVDPlayer
  def on
    puts "DVD Player on"
  end
  
  def play(movie)
    puts "Playing #{movie}"
  end
end

class Projector
  def on
    puts "Projector on"
  end
  
  def wide_screen_mode
    puts "Wide screen mode"
  end
end

class Lights
  def dim(level)
    puts "Lights dimmed to #{level}%"
  end
end

# Problem: Client needs to know about all components and their order
class Client
  def watch_movie(movie)
    amp = Amplifier.new
    dvd = DVDPlayer.new
    projector = Projector.new
    lights = Lights.new
    
    # Complex sequence - client must know all steps!
    lights.dim(10)
    amp.on
    amp.set_volume(5)
    dvd.on
    dvd.play(movie)
    projector.on
    projector.wide_screen_mode
  end
end
```

### Solution: With Facade

```ruby
# Same complex subsystem
class Amplifier
  def on
    puts "Amplifier on"
  end
  
  def set_volume(level)
    puts "Volume set to #{level}"
  end
end

class DVDPlayer
  def on
    puts "DVD Player on"
  end
  
  def play(movie)
    puts "Playing #{movie}"
  end
end

class Projector
  def on
    puts "Projector on"
  end
  
  def wide_screen_mode
    puts "Wide screen mode"
  end
end

class Lights
  def dim(level)
    puts "Lights dimmed to #{level}%"
  end
end

# Facade - simplified interface
class HomeTheaterFacade
  def initialize
    @amp = Amplifier.new
    @dvd = DVDPlayer.new
    @projector = Projector.new
    @lights = Lights.new
  end
  
  def watch_movie(movie)
    puts "Get ready to watch a movie..."
    @lights.dim(10)
    @amp.on
    @amp.set_volume(5)
    @dvd.on
    @dvd.play(movie)
    @projector.on
    @projector.wide_screen_mode
    puts "Enjoy your movie!"
  end
  
  def end_movie
    puts "Shutting movie theater down..."
    @lights.dim(100)
    @projector.off if @projector.respond_to?(:off)
    @dvd.off if @dvd.respond_to?(:off)
    @amp.off if @amp.respond_to?(:off)
  end
end

# Client - simple interface!
class Client
  def initialize
    @theater = HomeTheaterFacade.new
  end
  
  def watch_movie(movie)
    @theater.watch_movie(movie)  # One simple method!
  end
end
```

## Real-World Example: Database Facade

```ruby
# Complex database subsystem
class ConnectionPool
  def get_connection
    puts "Getting connection from pool"
  end
end

class QueryBuilder
  def build(query)
    puts "Building query: #{query}"
  end
end

class ResultSet
  def process(results)
    puts "Processing results"
  end
end

class TransactionManager
  def begin
    puts "Beginning transaction"
  end
  
  def commit
    puts "Committing transaction"
  end
end

# Facade - simple database interface
class DatabaseFacade
  def initialize
    @pool = ConnectionPool.new
    @query_builder = QueryBuilder.new
    @result_set = ResultSet.new
    @transaction = TransactionManager.new
  end
  
  def execute_query(query)
    @transaction.begin
    connection = @pool.get_connection
    built_query = @query_builder.build(query)
    results = connection.execute(built_query)  # Simplified
    processed = @result_set.process(results)
    @transaction.commit
    processed
  end
end

# Client - doesn't need to know about all components
db = DatabaseFacade.new
results = db.execute_query("SELECT * FROM users")  # Simple!
```

## Benefits of Facade Pattern

1. **Simplicity**: Hides complexity behind simple interface
2. **Decoupling**: Clients don't depend on subsystem details
3. **Flexibility**: Can change subsystem without affecting clients
4. **Easier to Use**: Reduces learning curve

## When NOT to Use Facade Pattern

- ❌ You need direct access to subsystem components
- ❌ Facade becomes too complex (creates another layer of complexity)
- ❌ Over-simplification hides necessary flexibility

## Summary

**Facade Pattern:**
- Provides simple interface to complex subsystem
- Hides complexity from clients
- Use when subsystem is too complex for clients
- Like a receptionist directing you to the right department

