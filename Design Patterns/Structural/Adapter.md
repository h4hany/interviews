# Adapter Pattern - Complete Guide

## What is the Adapter Pattern?

The **Adapter Pattern** allows incompatible interfaces to work together by wrapping an object with an adapter that translates between interfaces. It's like a power adapter that lets you use a foreign plug in your country's socket.

## When to Use Adapter Pattern

**Use Adapter Pattern when:**
- ✅ You need to use a class with an incompatible interface
- ✅ You want to integrate third-party libraries
- ✅ You need to make old code work with new code
- ✅ You want to create a reusable class that cooperates with unrelated classes
- ✅ You can't modify the source code of the incompatible class

## How to Recognize the Problem

**Red Flags:**
- You have classes that do similar things but with different interfaces
- You need to use a third-party library with different method names
- You're trying to integrate old code with new code
- You see code trying to manually convert between different formats
- "I have this class that does what I need, but its interface doesn't match"

## Real-World Example: Payment Gateway Adapter

### Problem: Incompatible Interfaces

```ruby
# Third-party payment library (can't modify this)
class StripePayment
  def charge_customer(amount, customer_id)
    puts "Stripe: Charging $#{amount} to customer #{customer_id}"
  end
end

# Your application's payment interface
class PaymentProcessor
  def process_payment(amount, customer)
    # Problem: StripePayment has different method signature!
    # It expects customer_id, but we have customer object
    # Method name is different: charge_customer vs process_payment
  end
end
```

### Solution: With Adapter Pattern

```ruby
# Your application's payment interface (target interface)
class Payment
  def process(amount, customer)
    raise NotImplementedError
  end
end

# Third-party Stripe library (adaptee - incompatible interface)
class StripePayment
  def charge_customer(amount, customer_id)
    puts "Stripe: Charging $#{amount} to customer #{customer_id}"
    # Returns Stripe-specific response
    { success: true, transaction_id: "stripe_123" }
  end
end

# Adapter - makes StripePayment compatible with Payment interface
class StripePaymentAdapter < Payment
  def initialize
    @stripe = StripePayment.new
  end
  
  def process(amount, customer)
    # Adapts the interface:
    # - Converts customer object to customer_id
    # - Calls charge_customer instead of process
    # - Converts response format
    result = @stripe.charge_customer(amount, customer.id)
    
    # Adapt response to match expected format
    {
      status: result[:success] ? "success" : "failed",
      transaction_id: result[:transaction_id]
    }
  end
end

# Another third-party library
class PayPalAPI
  def make_payment(amount, email)
    puts "PayPal: Processing $#{amount} for #{email}"
    { paid: true, payment_id: "paypal_456" }
  end
end

# Adapter for PayPal
class PayPalAdapter < Payment
  def initialize
    @paypal = PayPalAPI.new
  end
  
  def process(amount, customer)
    # Adapts PayPal interface to Payment interface
    result = @paypal.make_payment(amount, customer.email)
    
    {
      status: result[:paid] ? "success" : "failed",
      transaction_id: result[:payment_id]
    }
  end
end

# Your application code - works with any payment adapter
class PaymentProcessor
  def initialize(payment_adapter)
    @payment = payment_adapter
  end
  
  def process_payment(amount, customer)
    @payment.process(amount, customer)  # Same interface for all!
  end
end

# Usage
customer = { id: "123", email: "user@example.com" }

# Use Stripe through adapter
stripe_adapter = StripePaymentAdapter.new
processor = PaymentProcessor.new(stripe_adapter)
processor.process_payment(100, customer)

# Use PayPal through adapter
paypal_adapter = PayPalAdapter.new
processor = PaymentProcessor.new(paypal_adapter)
processor.process_payment(100, customer)
```

## Real-World Example: Data Format Adapter

```ruby
# Your application expects JSON
class JSONDataProcessor
  def process(data)
    json = JSON.parse(data)
    puts "Processing JSON: #{json}"
  end
end

# Third-party service returns XML (incompatible)
class XMLService
  def get_data
    "<user><name>John</name><age>30</age></user>"
  end
end

# Adapter converts XML to JSON format
class XMLToJSONAdapter
  def initialize(xml_service)
    @xml_service = xml_service
  end
  
  def get_json_data
    xml_data = @xml_service.get_data
    
    # Convert XML to JSON
    require 'rexml/document'
    doc = REXML::Document.new(xml_data)
    name = doc.elements['user/name'].text
    age = doc.elements['user/age'].text
    
    JSON.generate({ name: name, age: age.to_i })
  end
end

# Usage
xml_service = XMLService.new
adapter = XMLToJSONAdapter.new(xml_service)
json_data = adapter.get_json_data

processor = JSONDataProcessor.new
processor.process(json_data)  # Works with JSON!
```

## Real-World Example: Legacy System Adapter

```ruby
# Old legacy system (can't modify)
class LegacyUserService
  def get_user_info(user_id)
    # Returns hash with different key names
    {
      user_id: user_id,
      full_name: "John Doe",
      email_addr: "john@example.com",  # Different key name!
      phone_num: "123-456-7890"        # Different key name!
    }
  end
end

# New system expects different format
class ModernUserService
  def get_user(user_id)
    # Expects different structure
    {
      id: user_id,
      name: "John Doe",
      email: "john@example.com",
      phone: "123-456-7890"
    }
  end
end

# Adapter makes legacy system compatible
class LegacyUserAdapter
  def initialize(legacy_service)
    @legacy = legacy_service
  end
  
  def get_user(user_id)
    legacy_data = @legacy.get_user_info(user_id)
    
    # Convert legacy format to modern format
    {
      id: legacy_data[:user_id],
      name: legacy_data[:full_name],
      email: legacy_data[:email_addr],  # Map to new key
      phone: legacy_data[:phone_num]   # Map to new key
    }
  end
end

# Usage
legacy_service = LegacyUserService.new
adapter = LegacyUserAdapter.new(legacy_service)

# Now legacy service works with modern code!
user = adapter.get_user("123")
puts user[:email]  # Works with modern interface!
```

## Types of Adapters

### 1. Object Adapter (Composition)
```ruby
class Adapter
  def initialize(adaptee)
    @adaptee = adaptee  # Composition
  end
  
  def target_method
    @adaptee.incompatible_method  # Adapts the call
  end
end
```

### 2. Class Adapter (Inheritance)
```ruby
class Adapter < Adaptee  # Inheritance
  def target_method
    incompatible_method  # Adapts the call
  end
end
```

**Prefer Object Adapter** (composition) as it's more flexible.

## Benefits of Adapter Pattern

1. **Integration**: Makes incompatible interfaces work together
2. **Reusability**: Reuse existing classes with different interfaces
3. **Flexibility**: Easy to swap adapters
4. **Separation**: Keeps adaptation logic separate

## When NOT to Use Adapter Pattern

- ❌ You can modify the source code (just change the interface)
- ❌ The interfaces are already compatible
- ❌ Over-engineering for simple conversions

## Summary

**Adapter Pattern:**
- Makes incompatible interfaces work together
- Like a translator between two languages
- Use when integrating third-party code or legacy systems
- Wraps incompatible object to match expected interface


