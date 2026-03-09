# Strategy Pattern - Complete Guide

## What is the Strategy Pattern?

The **Strategy Pattern** defines a family of algorithms, encapsulates each one, and makes them interchangeable. The client can choose which algorithm to use at runtime.

## When to Use Strategy Pattern

**Use Strategy Pattern when:**
- ✅ You have multiple ways to perform a task
- ✅ You want to choose algorithm at runtime
- ✅ You want to avoid conditional statements for algorithm selection
- ✅ Algorithms should be interchangeable
- ✅ You want to isolate algorithm implementation

## How to Recognize the Problem

**Red Flags:**
- Many if/else or switch statements for algorithm selection
- Similar classes differ only in their behavior
- You want to add new algorithms without modifying existing code
- "I need different ways to do the same thing"

## Real-World Example: Payment Processing

### Problem: Without Strategy

```ruby
class PaymentProcessor
  def process_payment(amount, payment_type)
    case payment_type
    when :credit_card
      # Credit card processing logic
      fee = amount * 0.03
      process_credit_card(amount, fee)
    when :paypal
      # PayPal processing logic
      fee = amount * 0.02
      process_paypal(amount, fee)
    when :bank_transfer
      # Bank transfer logic
      fee = amount * 0.01
      process_bank_transfer(amount, fee)
    end
  end
end

# Problem: Adding new payment method requires modifying this class
```

### Solution: With Strategy

```ruby
# Strategy interface
class PaymentStrategy
  def process(amount)
    raise NotImplementedError
  end
  
  def calculate_fee(amount)
    raise NotImplementedError
  end
end

# Concrete strategies
class CreditCardStrategy < PaymentStrategy
  def process(amount)
    fee = calculate_fee(amount)
    puts "Processing credit card: $#{amount} (fee: $#{fee})"
    # Credit card processing
  end
  
  def calculate_fee(amount)
    amount * 0.03
  end
end

class PayPalStrategy < PaymentStrategy
  def process(amount)
    fee = calculate_fee(amount)
    puts "Processing PayPal: $#{amount} (fee: $#{fee})"
    # PayPal processing
  end
  
  def calculate_fee(amount)
    amount * 0.02
  end
end

class BankTransferStrategy < PaymentStrategy
  def process(amount)
    fee = calculate_fee(amount)
    puts "Processing bank transfer: $#{amount} (fee: $#{fee})"
    # Bank transfer processing
  end
  
  def calculate_fee(amount)
    amount * 0.01
  end
end

# Context - uses strategy
class PaymentProcessor
  def initialize(strategy)
    @strategy = strategy
  end
  
  def set_strategy(strategy)
    @strategy = strategy
  end
  
  def process_payment(amount)
    @strategy.process(amount)
  end
end

# Usage - choose strategy at runtime
processor = PaymentProcessor.new(CreditCardStrategy.new)
processor.process_payment(100)

processor.set_strategy(PayPalStrategy.new)
processor.process_payment(100)

# Easy to add new strategy without modifying existing code!
class CryptoStrategy < PaymentStrategy
  def process(amount)
    fee = calculate_fee(amount)
    puts "Processing crypto: $#{amount} (fee: $#{fee})"
  end
  
  def calculate_fee(amount)
    amount * 0.005
  end
end

processor.set_strategy(CryptoStrategy.new)
processor.process_payment(100)
```

## Real-World Example: Sorting Algorithms

```ruby
class SortStrategy
  def sort(array)
    raise NotImplementedError
  end
end

class QuickSortStrategy < SortStrategy
  def sort(array)
    puts "Using QuickSort"
    array.sort  # Simplified
  end
end

class MergeSortStrategy < SortStrategy
  def sort(array)
    puts "Using MergeSort"
    array.sort  # Simplified
  end
end

class BubbleSortStrategy < SortStrategy
  def sort(array)
    puts "Using BubbleSort"
    array.sort  # Simplified
  end
end

class Sorter
  def initialize(strategy)
    @strategy = strategy
  end
  
  def sort(array)
    @strategy.sort(array)
  end
end

# Usage - choose algorithm based on data size
data = [3, 1, 4, 1, 5, 9, 2, 6]

if data.length < 10
  sorter = Sorter.new(BubbleSortStrategy.new)
elsif data.length < 1000
  sorter = Sorter.new(QuickSortStrategy.new)
else
  sorter = Sorter.new(MergeSortStrategy.new)
end

sorter.sort(data)
```

## Benefits of Strategy Pattern

1. **Flexibility**: Switch algorithms at runtime
2. **Extensibility**: Add new strategies without modifying code
3. **Isolation**: Each strategy is independent
4. **Eliminates Conditionals**: No if/else for algorithm selection

## When NOT to Use Strategy Pattern

- ❌ Only one way to do something
- ❌ Algorithms are too simple
- ❌ Over-engineering for simple cases

## Summary

**Strategy Pattern:**
- Encapsulates algorithms
- Makes them interchangeable
- Choose algorithm at runtime
- Use when you have multiple ways to do the same thing

