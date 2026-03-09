# Mediator Pattern - Complete Guide

## What is the Mediator Pattern?

The **Mediator Pattern** defines an object that encapsulates how a set of objects interact. It promotes loose coupling by keeping objects from referring to each other directly.

## When to Use Mediator Pattern

**Use Mediator Pattern when:**
- ✅ Objects communicate in complex ways
- ✅ You want to reduce coupling between objects
- ✅ Communication logic is scattered
- ✅ You want to centralize complex interactions
- ✅ Objects have many direct dependencies

## How to Recognize the Problem

**Red Flags:**
- Objects have many direct references to each other
- Communication logic is scattered
- Adding new components requires changing many existing ones
- Objects are tightly coupled
- "Objects need to communicate but I want to reduce coupling"

## Real-World Example: Chat Room

### Problem: Without Mediator

```ruby
class User
  def initialize(name)
    @name = name
    @users = []  # Direct references to all users!
  end
  
  def send_message(message, recipient)
    # Problem: User needs to know about all other users
    recipient.receive_message(@name, message)
  end
  
  def receive_message(sender, message)
    puts "#{@name} received from #{sender}: #{message}"
  end
end

# Problem: Tight coupling, hard to add/remove users
```

### Solution: With Mediator

```ruby
# Mediator interface
class ChatMediator
  def send_message(message, sender, recipient)
    raise NotImplementedError
  end
  
  def broadcast(message, sender)
    raise NotImplementedError
  end
end

# Concrete mediator
class ChatRoom < ChatMediator
  def initialize
    @users = []
  end
  
  def add_user(user)
    @users << user
    user.mediator = self
  end
  
  def send_message(message, sender, recipient)
    recipient.receive_message(sender.name, message)
  end
  
  def broadcast(message, sender)
    @users.each do |user|
      user.receive_message(sender.name, message) unless user == sender
    end
  end
end

# Colleague - doesn't know about other colleagues
class User
  attr_accessor :mediator
  attr_reader :name
  
  def initialize(name)
    @name = name
  end
  
  def send_message(message, recipient)
    @mediator.send_message(message, self, recipient)
  end
  
  def broadcast(message)
    @mediator.broadcast(message, self)
  end
  
  def receive_message(sender, message)
    puts "#{@name} received from #{sender}: #{message}"
  end
end

# Usage
chat_room = ChatRoom.new

alice = User.new("Alice")
bob = User.new("Bob")
charlie = User.new("Charlie")

chat_room.add_user(alice)
chat_room.add_user(bob)
chat_room.add_user(charlie)

# Users communicate through mediator
alice.send_message("Hello Bob", bob)
alice.broadcast("Hello everyone!")
```

## Real-World Example: Air Traffic Control

```ruby
class AirTrafficControl
  def initialize
    @aircrafts = []
  end
  
  def register(aircraft)
    @aircrafts << aircraft
    aircraft.mediator = self
  end
  
  def request_landing(aircraft)
    if runway_available?
      puts "#{aircraft.name} cleared for landing"
      aircraft.land
    else
      puts "#{aircraft.name} please wait, runway busy"
      queue_landing(aircraft)
    end
  end
  
  def runway_available?
    @aircrafts.none? { |a| a.landing? }
  end
  
  def queue_landing(aircraft)
    # Queue logic
  end
end

class Aircraft
  attr_accessor :mediator
  attr_reader :name
  
  def initialize(name)
    @name = name
    @landing = false
  end
  
  def request_landing
    @mediator.request_landing(self)
  end
  
  def landing?
    @landing
  end
  
  def land
    @landing = true
    puts "#{@name} landing"
  end
end
```

## Benefits of Mediator Pattern

1. **Loose Coupling**: Objects don't reference each other directly
2. **Centralized Control**: All communication through mediator
3. **Easier Maintenance**: Change communication logic in one place
4. **Reusability**: Objects can be reused independently

## When NOT to Use Mediator Pattern

- ❌ Simple communication between few objects
- ❌ Mediator becomes too complex (god object)
- ❌ Over-engineering for simple interactions

## Summary

**Mediator Pattern:**
- Centralizes communication between objects
- Reduces coupling
- Use when objects have complex interactions
- Like a traffic controller directing communication

