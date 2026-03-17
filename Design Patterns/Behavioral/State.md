# State Pattern - Complete Guide

## What is the State Pattern?

The **State Pattern** allows an object to alter its behavior when its internal state changes. The object appears to change its class.

## When to Use State Pattern

**Use State Pattern when:**
- ✅ Object behavior depends on its state
- ✅ You have many conditional statements based on state
- ✅ State transitions are complex
- ✅ You want to avoid large if/else or switch statements
- ✅ State-specific behavior should be encapsulated

## How to Recognize the Problem

**Red Flags:**
- Many if/else statements checking object state
- State transitions are scattered throughout code
- Adding new state requires modifying existing code
- State-specific behavior is mixed with general behavior
- "Object behaves differently based on its current state"

## Real-World Example: Order State Machine

### Problem: Without State Pattern

```ruby
class Order
  def initialize
    @state = "pending"
  end
  
  def process
    case @state
    when "pending"
      @state = "confirmed"
      puts "Order confirmed"
    when "confirmed"
      @state = "processing"
      puts "Order processing"
    when "processing"
      @state = "shipped"
      puts "Order shipped"
    when "shipped"
      puts "Order already shipped"
    when "cancelled"
      puts "Cannot process cancelled order"
    end
  end
  
  def cancel
    case @state
    when "pending"
      @state = "cancelled"
      puts "Order cancelled"
    when "confirmed"
      @state = "cancelled"
      puts "Order cancelled"
    when "processing"
      puts "Cannot cancel order in processing"
    when "shipped"
      puts "Cannot cancel shipped order"
    when "cancelled"
      puts "Order already cancelled"
    end
  end
  
  # Problem: Complex conditionals, hard to maintain, violates OCP
end
```

### Solution: With State Pattern

```ruby
# State interface
class OrderState
  def process(order)
    raise NotImplementedError
  end
  
  def cancel(order)
    raise NotImplementedError
  end
end

# Concrete states
class PendingState < OrderState
  def process(order)
    puts "Order confirmed"
    order.state = ConfirmedState.new
  end
  
  def cancel(order)
    puts "Order cancelled"
    order.state = CancelledState.new
  end
end

class ConfirmedState < OrderState
  def process(order)
    puts "Order processing"
    order.state = ProcessingState.new
  end
  
  def cancel(order)
    puts "Order cancelled"
    order.state = CancelledState.new
  end
end

class ProcessingState < OrderState
  def process(order)
    puts "Order shipped"
    order.state = ShippedState.new
  end
  
  def cancel(order)
    puts "Cannot cancel order in processing"
  end
end

class ShippedState < OrderState
  def process(order)
    puts "Order already shipped"
  end
  
  def cancel(order)
    puts "Cannot cancel shipped order"
  end
end

class CancelledState < OrderState
  def process(order)
    puts "Cannot process cancelled order"
  end
  
  def cancel(order)
    puts "Order already cancelled"
  end
end

# Context
class Order
  attr_accessor :state
  
  def initialize
    @state = PendingState.new
  end
  
  def process
    @state.process(self)
  end
  
  def cancel
    @state.cancel(self)
  end
end

# Usage
order = Order.new
order.process  # Order confirmed
order.process  # Order processing
order.cancel   # Cannot cancel order in processing
order.process  # Order shipped
order.cancel   # Cannot cancel shipped order
```

## Real-World Example: Vending Machine

```ruby
class VendingMachineState
  def insert_coin(machine)
    raise NotImplementedError
  end
  
  def select_item(machine)
    raise NotImplementedError
  end
  
  def dispense(machine)
    raise NotImplementedError
  end
end

class NoCoinState < VendingMachineState
  def insert_coin(machine)
    puts "Coin inserted"
    machine.state = HasCoinState.new
  end
  
  def select_item(machine)
    puts "Please insert coin first"
  end
end

class HasCoinState < VendingMachineState
  def insert_coin(machine)
    puts "Coin already inserted"
  end
  
  def select_item(machine)
    puts "Item selected"
    machine.state = DispensingState.new
  end
end

class DispensingState < VendingMachineState
  def dispense(machine)
    puts "Dispensing item"
    machine.state = NoCoinState.new
  end
end

class VendingMachine
  attr_accessor :state
  
  def initialize
    @state = NoCoinState.new
  end
  
  def insert_coin
    @state.insert_coin(self)
  end
  
  def select_item
    @state.select_item(self)
  end
  
  def dispense
    @state.dispense(self)
  end
end
```

## Benefits of State Pattern

1. **Clear State Logic**: Each state encapsulated in its own class
2. **Easy to Extend**: Add new states without modifying existing
3. **No Conditionals**: Eliminates large if/else statements
4. **Maintainability**: State transitions are clear

## When NOT to Use State Pattern

- ❌ Simple state changes (just use enum/flag)
- ❌ States don't have different behaviors
- ❌ Over-engineering for simple state machines

## Summary

**State Pattern:**
- Object behavior changes with state
- Each state is a separate class
- Use for complex state machines
- Eliminates conditional state logic


