# Observer Pattern - Complete Guide

## What is the Observer Pattern?

The **Observer Pattern** defines a one-to-many dependency between objects. When one object (subject) changes state, all its dependents (observers) are notified and updated automatically.

## When to Use Observer Pattern

**Use Observer Pattern when:**
- ✅ Change to one object requires changing others
- ✅ You don't know how many objects need to be notified
- ✅ Objects should be loosely coupled
- ✅ You need event-driven architecture
- ✅ You want to notify multiple objects about state changes

## How to Recognize the Problem

**Red Flags:**
- Object needs to notify multiple other objects
- Tight coupling between subject and observers
- Manual notification code scattered everywhere
- "When X changes, I need to update Y, Z, and W"

## Real-World Example: Stock Market

### Problem: Without Observer

```ruby
# Problem: Tight coupling, manual updates
class Stock
  def initialize(symbol, price)
    @symbol = symbol
    @price = price
    @investors = []  # Hard-coded list
  end
  
  def update_price(new_price)
    @price = new_price
    # Problem: Must manually notify each investor
    @investors.each { |investor| investor.notify(self) }
  end
end

class Investor
  def notify(stock)
    puts "#{self.name}: #{stock.symbol} is now $#{stock.price}"
  end
end
```

### Solution: With Observer

```ruby
# Subject interface
module Observable
  def add_observer(observer)
    @observers ||= []
    @observers << observer
  end
  
  def remove_observer(observer)
    @observers.delete(observer)
  end
  
  def notify_observers
    @observers.each { |observer| observer.update(self) }
  end
end

# Subject
class Stock
  include Observable
  
  attr_reader :symbol, :price
  
  def initialize(symbol, price)
    @symbol = symbol
    @price = price
  end
  
  def update_price(new_price)
    @price = new_price
    notify_observers  # Notify all observers automatically
  end
end

# Observer interface
class Observer
  def update(subject)
    raise NotImplementedError
  end
end

# Concrete observers
class Investor < Observer
  def initialize(name)
    @name = name
  end
  
  def update(stock)
    puts "#{@name}: #{stock.symbol} is now $#{stock.price}"
  end
end

class StockDisplay < Observer
  def update(stock)
    puts "Stock Display: #{stock.symbol} = $#{stock.price}"
  end
end

class AlertSystem < Observer
  def initialize(threshold)
    @threshold = threshold
  end
  
  def update(stock)
    if stock.price > @threshold
      puts "ALERT: #{stock.symbol} exceeded $#{@threshold}!"
    end
  end
end

# Usage
stock = Stock.new("AAPL", 150)

investor1 = Investor.new("Alice")
investor2 = Investor.new("Bob")
display = StockDisplay.new
alert = AlertSystem.new(200)

# Subscribe observers
stock.add_observer(investor1)
stock.add_observer(investor2)
stock.add_observer(display)
stock.add_observer(alert)

# Change price - all observers notified automatically!
stock.update_price(155)
# Output:
# Alice: AAPL is now $155
# Bob: AAPL is now $155
# Stock Display: AAPL = $155
```

## Real-World Example: Event System

```ruby
class EventEmitter
  def initialize
    @listeners = {}
  end
  
  def on(event, &block)
    @listeners[event] ||= []
    @listeners[event] << block
  end
  
  def emit(event, data)
    return unless @listeners[event]
    @listeners[event].each { |listener| listener.call(data) }
  end
end

class Order
  def initialize
    @events = EventEmitter.new
    @status = "pending"
  end
  
  def add_listener(event, &block)
    @events.on(event, &block)
  end
  
  def update_status(new_status)
    @status = new_status
    @events.emit(:status_changed, { status: @status, order: self })
  end
end

# Usage
order = Order.new

order.add_listener(:status_changed) do |data|
  puts "Email: Order status changed to #{data[:status]}"
end

order.add_listener(:status_changed) do |data|
  puts "SMS: Order status changed to #{data[:status]}"
end

order.add_listener(:status_changed) do |data|
  puts "Log: Order #{data[:order].id} status = #{data[:status]}"
end

order.update_status("shipped")  # All listeners notified!
```

## Benefits of Observer Pattern

1. **Loose Coupling**: Subject doesn't know about concrete observers
2. **Dynamic**: Add/remove observers at runtime
3. **Broadcast**: One change notifies many observers
4. **Flexibility**: Easy to add new observers

## When NOT to Use Observer Pattern

- ❌ Too many observers cause performance issues
- ❌ Update order matters and is complex
- ❌ Circular dependencies between observers

## Summary

**Observer Pattern:**
- One-to-many dependency
- Subject notifies observers of changes
- Use for event-driven systems
- Like a newsletter subscription system


