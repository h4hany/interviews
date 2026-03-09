# Factory Pattern - Complete Guide

## What is the Factory Pattern?

The **Factory Pattern** provides a way to create objects without specifying the exact class of object that will be created. Instead, a factory method decides which object to instantiate based on certain conditions.

## When to Use Factory Pattern

**Use Factory Pattern when:**
- ✅ You don't know the exact type of object until runtime
- ✅ Object creation logic is complex
- ✅ You want to decouple object creation from object usage
- ✅ You need to create objects based on configuration or input
- ✅ You want to centralize object creation logic

## How to Recognize the Problem

**Red Flags:**
- Code has many `if/else` or `switch/case` statements for object creation
- Object creation logic is scattered throughout the code
- Adding new types requires modifying existing code
- You see `new` keyword with conditional logic
- "I need to create different types of objects based on some condition"

## Real-World Example: Payment Gateway Factory

### Problem: Without Factory Pattern

```ruby
class PaymentProcessor
  def process_payment(payment_type, amount, customer)
    # Problem: Object creation logic mixed with business logic
    case payment_type
    when :credit_card
      payment = CreditCardPayment.new(customer.card_number, customer.cvv)
      payment.process(amount)
    when :paypal
      payment = PayPalPayment.new(customer.paypal_email)
      payment.process(amount)
    when :stripe
      payment = StripePayment.new(customer.stripe_token)
      payment.process(amount)
    when :apple_pay
      payment = ApplePayPayment.new(customer.apple_pay_id)
      payment.process(amount)
    else
      raise "Unknown payment type"
    end
  end
end

# Problems:
# - Object creation logic scattered
# - Hard to test
# - Adding new payment type requires modifying this method
# - Violates Open/Closed Principle
```

### Solution: With Factory Pattern

```ruby
# Payment interface
class Payment
  def process(amount)
    raise NotImplementedError
  end
end

# Concrete payment classes
class CreditCardPayment < Payment
  def initialize(card_number, cvv)
    @card_number = card_number
    @cvv = cvv
  end
  
  def process(amount)
    puts "Processing credit card payment of $#{amount}"
    # Credit card processing logic
  end
end

class PayPalPayment < Payment
  def initialize(email)
    @email = email
  end
  
  def process(amount)
    puts "Processing PayPal payment of $#{amount}"
    # PayPal processing logic
  end
end

class StripePayment < Payment
  def initialize(token)
    @token = token
  end
  
  def process(amount)
    puts "Processing Stripe payment of $#{amount}"
    # Stripe processing logic
  end
end

# Factory class - centralizes object creation
class PaymentFactory
  def self.create_payment(payment_type, customer)
    case payment_type
    when :credit_card
      CreditCardPayment.new(customer.card_number, customer.cvv)
    when :paypal
      PayPalPayment.new(customer.paypal_email)
    when :stripe
      StripePayment.new(customer.stripe_token)
    when :apple_pay
      ApplePayPayment.new(customer.apple_pay_id)
    else
      raise "Unknown payment type: #{payment_type}"
    end
  end
end

# Usage - clean and simple
class PaymentProcessor
  def process_payment(payment_type, amount, customer)
    payment = PaymentFactory.create_payment(payment_type, customer)
    payment.process(amount)
  end
end

# Adding new payment type - just extend factory, no modification needed!
class ApplePayPayment < Payment
  def initialize(apple_pay_id)
    @apple_pay_id = apple_pay_id
  end
  
  def process(amount)
    puts "Processing Apple Pay payment of $#{amount}"
  end
end

# Update factory (or use configuration)
class PaymentFactory
  def self.create_payment(payment_type, customer)
    case payment_type
    when :credit_card
      CreditCardPayment.new(customer.card_number, customer.cvv)
    when :paypal
      PayPalPayment.new(customer.paypal_email)
    when :stripe
      StripePayment.new(customer.stripe_token)
    when :apple_pay
      ApplePayPayment.new(customer.apple_pay_id) # NEW - easy to add
    else
      raise "Unknown payment type: #{payment_type}"
    end
  end
end
```

## Real-World Example: Database Connection Factory

```ruby
# Database connection interface
class DatabaseConnection
  def connect
    raise NotImplementedError
  end
  
  def query(sql)
    raise NotImplementedError
  end
end

# Concrete implementations
class MySQLConnection < DatabaseConnection
  def initialize(host, port, database, username, password)
    @host = host
    @port = port
    @database = database
    @username = username
    @password = password
  end
  
  def connect
    puts "Connecting to MySQL at #{@host}:#{@port}/#{@database}"
    # MySQL connection logic
  end
  
  def query(sql)
    puts "Executing MySQL query: #{sql}"
    # MySQL query execution
  end
end

class PostgreSQLConnection < DatabaseConnection
  def initialize(host, port, database, username, password)
    @host = host
    @port = port
    @database = database
    @username = username
    @password = password
  end
  
  def connect
    puts "Connecting to PostgreSQL at #{@host}:#{@port}/#{@database}"
    # PostgreSQL connection logic
  end
  
  def query(sql)
    puts "Executing PostgreSQL query: #{sql}"
    # PostgreSQL query execution
  end
end

class MongoDBConnection < DatabaseConnection
  def initialize(connection_string)
    @connection_string = connection_string
  end
  
  def connect
    puts "Connecting to MongoDB: #{@connection_string}"
    # MongoDB connection logic
  end
  
  def query(sql)
    puts "Executing MongoDB query: #{sql}"
    # MongoDB query execution
  end
end

# Factory - creates appropriate database connection
class DatabaseConnectionFactory
  def self.create_connection(db_type, config)
    case db_type
    when :mysql
      MySQLConnection.new(
        config[:host],
        config[:port],
        config[:database],
        config[:username],
        config[:password]
      )
    when :postgresql
      PostgreSQLConnection.new(
        config[:host],
        config[:port],
        config[:database],
        config[:username],
        config[:password]
      )
    when :mongodb
      MongoDBConnection.new(config[:connection_string])
    else
      raise "Unsupported database type: #{db_type}"
    end
  end
end

# Usage
config = {
  host: "localhost",
  port: 5432,
  database: "mydb",
  username: "user",
  password: "pass"
}

db = DatabaseConnectionFactory.create_connection(:postgresql, config)
db.connect
db.query("SELECT * FROM users")
```

## Benefits of Factory Pattern

1. **Decoupling**: Separates object creation from object usage
2. **Flexibility**: Easy to add new types without modifying existing code
3. **Centralization**: All creation logic in one place
4. **Testability**: Easy to mock factory for testing
5. **Maintainability**: Changes to creation logic happen in one place

## When NOT to Use Factory Pattern

- ❌ Object creation is simple (just use `new`)
- ❌ You always know the exact type at compile time
- ❌ Only one type of object needs to be created
- ❌ Over-engineering for simple cases

## Summary

**Factory Pattern:**
- Creates objects without specifying exact class
- Centralizes object creation logic
- Makes code more flexible and maintainable
- Use when object creation depends on runtime conditions

