# SOLID Principles - Complete Guide with Real-World Examples

## Introduction

SOLID principles are five design principles that make software designs more understandable, flexible, and maintainable. This guide helps you **recognize problems** in code and know **which principle to apply**.

---

## How to Use This Guide

For each principle, you'll learn:
1. **What it means** (simple explanation)
2. **How to recognize the problem** (symptoms to look for)
3. **Real-world examples** (before and after)
4. **When to use it** (decision guide)

---

## S - Single Responsibility Principle (SRP)

### What It Means
**A class should have only one reason to change.** Each class should do one thing and do it well.

### How to Recognize the Problem

**Red Flags:**
- Class has multiple unrelated methods
- Class name contains "And" or "Or" (e.g., `UserAndEmail`, `OrderAndPayment`)
- Class is doing too many things (generating reports AND sending emails AND saving to database)
- When you need to change one feature, you have to modify multiple unrelated parts
- Class is hard to test because it does too many things

**Symptoms:**
```ruby
# BAD: This class does too many things
class User
  def create_account
    # Creates user account
  end
  
  def send_welcome_email
    # Sends email
  end
  
  def save_to_database
    # Database operations
  end
  
  def generate_user_report
    # Report generation
  end
  
  def validate_password
    # Password validation
  end
end
```

**Problem**: If email service changes, you modify User class. If database changes, you modify User class. Too many reasons to change!

### Real-World Example: E-Commerce Order System

**Before (Violates SRP):**
```ruby
class Order
  def initialize(customer, items)
    @customer = customer
    @items = items
    @total = calculate_total
  end
  
  def calculate_total
    # Business logic: Calculate order total
    @items.sum { |item| item.price * item.quantity }
  end
  
  def save_to_database
    # Database operation: Save order
    Database.save(self)
  end
  
  def send_confirmation_email
    # Email operation: Send email
    EmailService.send(@customer.email, "Order confirmed")
  end
  
  def generate_invoice_pdf
    # File generation: Create PDF
    PDFGenerator.create(self)
  end
  
  def process_payment
    # Payment processing: Charge customer
    PaymentGateway.charge(@customer, @total)
  end
end
```

**Why This Is Bad:**
- If email service changes → modify Order class
- If database schema changes → modify Order class
- If PDF format changes → modify Order class
- If payment gateway changes → modify Order class
- **4 different reasons to change one class!**

**After (Follows SRP):**
```ruby
# Each class has ONE responsibility

class Order
  def initialize(customer, items)
    @customer = customer
    @items = items
  end
  
  def calculate_total
    # ONLY business logic for order
    @items.sum { |item| item.price * item.quantity }
  end
end

class OrderRepository
  def save(order)
    # ONLY database operations
    Database.save(order)
  end
  
  def find(id)
    Database.find(id)
  end
end

class EmailService
  def send_confirmation(order)
    # ONLY email operations
    EmailService.send(order.customer.email, "Order confirmed")
  end
end

class InvoiceGenerator
  def generate(order)
    # ONLY PDF generation
    PDFGenerator.create(order)
  end
end

class PaymentProcessor
  def process(order)
    # ONLY payment processing
    PaymentGateway.charge(order.customer, order.total)
  end
end

# Usage: Compose these services
order = Order.new(customer, items)
OrderRepository.new.save(order)
EmailService.new.send_confirmation(order)
InvoiceGenerator.new.generate(order)
PaymentProcessor.new.process(order)
```

**Benefits:**
- Each class has ONE reason to change
- Easy to test each part independently
- Easy to swap implementations (e.g., change email service)
- Clear separation of concerns

### When to Use SRP

**Use SRP when:**
- ✅ Class is doing multiple unrelated things
- ✅ You find yourself saying "this class handles X AND Y AND Z"
- ✅ Testing is difficult because class does too much
- ✅ Changes in one area affect unrelated code

**Decision Guide:**
```
Is your class doing more than ONE thing?
├─ YES → Split into multiple classes (SRP)
└─ NO → You're good!
```

---

## O - Open/Closed Principle (OCP)

### What It Means
**Software should be open for extension but closed for modification.** You should be able to add new features without changing existing code.

### How to Recognize the Problem

**Red Flags:**
- Adding new features requires modifying existing code
- Large if/else or switch/case statements for different types
- Every new feature breaks existing tests
- Code has many conditional branches based on types
- "I need to add a new type, so I'll modify this existing class"

**Symptoms:**
```ruby
# BAD: Adding new discount type requires modifying this method
class DiscountCalculator
  def calculate_discount(type, amount)
    case type
    when :seasonal
      amount * 0.9
    when :clearance
      amount * 0.5
    when :student
      amount * 0.8
    when :senior
      amount * 0.85
    # Adding new discount? Modify this method!
    else
      amount
    end
  end
end
```

**Problem**: Every time you add a new discount type, you modify existing code. This can break existing functionality!

### Real-World Example: Payment Processing System

**Before (Violates OCP):**
```ruby
class PaymentProcessor
  def process_payment(payment_type, amount, customer)
    case payment_type
    when :credit_card
      # Credit card processing logic
      CreditCardGateway.charge(customer.card, amount)
    when :paypal
      # PayPal processing logic
      PayPalAPI.charge(customer.paypal_account, amount)
    when :bank_transfer
      # Bank transfer logic
      BankAPI.transfer(customer.account, amount)
    when :crypto
      # Cryptocurrency logic
      CryptoGateway.transfer(customer.wallet, amount)
    # Adding new payment method? Modify this class!
    end
  end
end
```

**Why This Is Bad:**
- Adding Apple Pay requires modifying PaymentProcessor
- Risk of breaking existing payment methods
- Hard to test each payment method independently
- Violates OCP: closed for extension, open for modification

**After (Follows OCP):**
```ruby
# Base class/interface - CLOSED for modification
class PaymentMethod
  def process(amount, customer)
    raise NotImplementedError, "Subclass must implement"
  end
end

# Extensions - OPEN for extension (new classes)
class CreditCardPayment < PaymentMethod
  def process(amount, customer)
    CreditCardGateway.charge(customer.card, amount)
  end
end

class PayPalPayment < PaymentMethod
  def process(amount, customer)
    PayPalAPI.charge(customer.paypal_account, amount)
  end
end

class BankTransferPayment < PaymentMethod
  def process(amount, customer)
    BankAPI.transfer(customer.account, amount)
  end
end

class CryptoPayment < PaymentMethod
  def process(amount, customer)
    CryptoGateway.transfer(customer.wallet, amount)
  end
end

# NEW payment method - NO modification needed!
class ApplePayPayment < PaymentMethod
  def process(amount, customer)
    ApplePayAPI.charge(customer.apple_pay, amount)
  end
end

# Payment processor - CLOSED for modification
class PaymentProcessor
  def process_payment(payment_method, amount, customer)
    payment_method.process(amount, customer)
  end
end

# Usage
processor = PaymentProcessor.new
processor.process_payment(CreditCardPayment.new, 100, customer)
processor.process_payment(ApplePayPayment.new, 100, customer) # NEW - no modification!
```

**Benefits:**
- Add new payment methods WITHOUT modifying existing code
- Existing code remains unchanged and safe
- Each payment method is independently testable
- Follows OCP: open for extension, closed for modification

### When to Use OCP

**Use OCP when:**
- ✅ You need to add new types/variants frequently
- ✅ You see many if/else or switch statements based on types
- ✅ Adding features requires modifying existing code
- ✅ You want to prevent breaking existing functionality

**Decision Guide:**
```
Do you need to modify existing code to add new features?
├─ YES → Use inheritance/polymorphism (OCP)
└─ NO → You're good!
```

---

## L - Liskov Substitution Principle (LSP)

### What It Means
**Subtypes must be substitutable for their base types.** Objects of a superclass should be replaceable with objects of its subclasses without breaking the application.

### How to Recognize the Problem

**Red Flags:**
- Subclass throws exceptions for methods it "inherits"
- Subclass returns different types than parent
- Subclass has preconditions that parent doesn't have
- Code checks "if instance_of? Subclass" before using it
- Subclass violates the contract of the parent class

**Symptoms:**
```ruby
# BAD: Penguin can't fly, but Bird says it can
class Bird
  def fly
    "Flying"
  end
end

class Penguin < Bird
  def fly
    raise "Penguins can't fly!" # Breaks LSP!
  end
end

# This breaks because you can't substitute Penguin for Bird
def make_bird_fly(bird)
  bird.fly # Crashes if bird is a Penguin!
end
```

**Problem**: Code expecting a Bird will break if given a Penguin. They're not substitutable!

### Real-World Example: Payment System

**Before (Violates LSP):**
```ruby
class Payment
  def process(amount)
    # Base implementation
    raise NotImplementedError
  end
  
  def refund(transaction_id)
    # All payments should support refund
    raise NotImplementedError
  end
end

class CreditCardPayment < Payment
  def process(amount)
    CreditCardGateway.charge(amount)
  end
  
  def refund(transaction_id)
    CreditCardGateway.refund(transaction_id)
  end
end

class CashPayment < Payment
  def process(amount)
    # Cash payment - just record it
    CashRegister.record(amount)
  end
  
  def refund(transaction_id)
    raise "Cash payments cannot be refunded!" # VIOLATES LSP!
  end
end

# This code expects ALL payments to support refund
def process_refund(payment, transaction_id)
  payment.refund(transaction_id) # Crashes for CashPayment!
end
```

**Why This Is Bad:**
- CashPayment can't be used wherever Payment is expected
- Breaks the contract: "All payments support refund"
- Code using Payment will crash with CashPayment
- Violates LSP: not substitutable

**After (Follows LSP):**
```ruby
# Base class - all payments can process
class Payment
  def process(amount)
    raise NotImplementedError
  end
end

# Refundable payments
class RefundablePayment < Payment
  def process(amount)
    raise NotImplementedError
  end
  
  def refund(transaction_id)
    raise NotImplementedError
  end
end

# Non-refundable payments
class NonRefundablePayment < Payment
  def process(amount)
    raise NotImplementedError
  end
end

# Implementations
class CreditCardPayment < RefundablePayment
  def process(amount)
    CreditCardGateway.charge(amount)
  end
  
  def refund(transaction_id)
    CreditCardGateway.refund(transaction_id)
  end
end

class CashPayment < NonRefundablePayment
  def process(amount)
    CashRegister.record(amount)
  end
  # No refund method - correct!
end

# Now they're substitutable within their categories
def process_payment(payment, amount)
  payment.process(amount) # Works for both!
end

def process_refund(refundable_payment, transaction_id)
  refundable_payment.refund(transaction_id) # Only refundable ones
end
```

**Benefits:**
- Subclasses can be used wherever parent is expected
- No surprises or exceptions
- Clear contracts
- Follows LSP: fully substitutable

### When to Use LSP

**Use LSP when:**
- ✅ Creating class hierarchies
- ✅ Subclasses should behave like parent
- ✅ You find yourself checking "if type X" before using
- ✅ Subclasses throw exceptions for inherited methods

**Decision Guide:**
```
Can you substitute subclass for parent without breaking code?
├─ NO → Fix the hierarchy (LSP)
└─ YES → You're good!
```

---

## I - Interface Segregation Principle (ISP)

### What It Means
**Clients should not be forced to depend on interfaces they don't use.** Create specific interfaces instead of one general-purpose interface.

### How to Recognize the Problem

**Red Flags:**
- Class implements methods it doesn't need
- Methods throw "NotImplementedError" or return empty
- Interface has many unrelated methods
- Class is forced to implement unused methods
- "I only need method X, but I have to implement Y and Z too"

**Symptoms:**
```ruby
# BAD: Printer must implement scan even if it can't scan
class Printer
  def print
    raise NotImplementedError
  end
  
  def scan
    raise NotImplementedError # Basic printer doesn't need this!
  end
  
  def fax
    raise NotImplementedError # Most printers don't need this!
  end
end

class BasicPrinter < Printer
  def print
    "Printing..."
  end
  
  def scan
    raise "Not supported" # Forced to implement unused method!
  end
  
  def fax
    raise "Not supported" # Forced to implement unused method!
  end
end
```

**Problem**: BasicPrinter is forced to implement methods it doesn't need!

### Real-World Example: Worker Management System

**Before (Violates ISP):**
```ruby
class Worker
  def work
    raise NotImplementedError
  end
  
  def eat
    raise NotImplementedError
  end
  
  def sleep
    raise NotImplementedError
  end
end

class HumanWorker < Worker
  def work
    "Human working"
  end
  
  def eat
    "Human eating"
  end
  
  def sleep
    "Human sleeping"
  end
end

class RobotWorker < Worker
  def work
    "Robot working"
  end
  
  def eat
    raise "Robots don't eat!" # Forced to implement unused method!
  end
  
  def sleep
    raise "Robots don't sleep!" # Forced to implement unused method!
  end
end
```

**Why This Is Bad:**
- RobotWorker forced to implement eat() and sleep()
- Violates ISP: clients depend on methods they don't use
- Unnecessary code and complexity

**After (Follows ISP):**
```ruby
# Segregated interfaces - clients only depend on what they need

module Workable
  def work
    raise NotImplementedError
  end
end

module Eatable
  def eat
    raise NotImplementedError
  end
end

module Sleepable
  def sleep
    raise NotImplementedError
  end
end

# Human implements all interfaces it needs
class HumanWorker
  include Workable
  include Eatable
  include Sleepable
  
  def work
    "Human working"
  end
  
  def eat
    "Human eating"
  end
  
  def sleep
    "Human sleeping"
  end
end

# Robot only implements what it needs
class RobotWorker
  include Workable
  
  def work
    "Robot working"
  end
  # No eat() or sleep() - not needed!
end

# Usage
def make_worker_work(workable)
  workable.work # Only needs Workable interface
end

def make_worker_eat(eatable)
  eatable.eat # Only needs Eatable interface
end
```

**Benefits:**
- Classes only implement what they need
- No unused methods
- Clear, focused interfaces
- Follows ISP: clients depend only on what they use

### When to Use ISP

**Use ISP when:**
- ✅ Class implements methods it doesn't use
- ✅ Interface has many unrelated methods
- ✅ You see "NotImplementedError" or empty method implementations
- ✅ Clients are forced to depend on unused methods

**Decision Guide:**
```
Are classes implementing methods they don't need?
├─ YES → Split interfaces (ISP)
└─ NO → You're good!
```

---

## D - Dependency Inversion Principle (DIP)

### What It Means
**High-level modules should not depend on low-level modules. Both should depend on abstractions.** Depend on interfaces, not concrete implementations.

### How to Recognize the Problem

**Red Flags:**
- High-level code directly creates low-level objects
- Hard to test because of concrete dependencies
- Changing implementation requires changing high-level code
- Code uses "new" keyword for dependencies
- "I want to change the database, but I have to modify the service class"

**Symptoms:**
```ruby
# BAD: High-level class depends on low-level class
class OrderService
  def initialize
    @database = MySQLDatabase.new # Direct dependency!
  end
  
  def save_order(order)
    @database.save(order) # Tightly coupled to MySQL
  end
end

# Problem: Want to use PostgreSQL? Modify OrderService!
```

**Problem**: OrderService is tightly coupled to MySQLDatabase. Can't easily swap implementations!

### Real-World Example: Notification System

**Before (Violates DIP):**
```ruby
# Low-level modules (concrete implementations)
class EmailService
  def send(to, message)
    puts "Sending email to #{to}: #{message}"
  end
end

class SMSService
  def send(to, message)
    puts "Sending SMS to #{to}: #{message}"
  end
end

# High-level module depends on low-level modules
class NotificationService
  def initialize
    @email_service = EmailService.new # Direct dependency!
    @sms_service = SMSService.new # Direct dependency!
  end
  
  def notify_user(user, message)
    @email_service.send(user.email, message)
    @sms_service.send(user.phone, message)
  end
end

# Problem: Want to add PushNotification? Modify NotificationService!
# Problem: Hard to test - can't mock dependencies!
```

**Why This Is Bad:**
- NotificationService depends on concrete classes
- Hard to test (can't easily mock)
- Hard to extend (adding new notification type requires modification)
- Violates DIP: high-level depends on low-level

**After (Follows DIP):**
```ruby
# Abstraction (interface) - both depend on this
module NotificationChannel
  def send(to, message)
    raise NotImplementedError
  end
end

# Low-level modules depend on abstraction
class EmailService
  include NotificationChannel
  
  def send(to, message)
    puts "Sending email to #{to}: #{message}"
  end
end

class SMSService
  include NotificationChannel
  
  def send(to, message)
    puts "Sending SMS to #{to}: #{message}"
  end
end

class PushNotificationService
  include NotificationChannel
  
  def send(to, message)
    puts "Sending push to #{to}: #{message}"
  end
end

# High-level module depends on abstraction (not concrete classes)
class NotificationService
  def initialize(notification_channels)
    @channels = notification_channels # Depends on abstraction!
  end
  
  def notify_user(user, message)
    @channels.each do |channel|
      channel.send(user.contact, message)
    end
  end
end

# Usage: Inject dependencies (Dependency Injection)
email = EmailService.new
sms = SMSService.new
push = PushNotificationService.new

notification_service = NotificationService.new([email, sms, push])
notification_service.notify_user(user, "Your order is ready!")

# Easy to test - inject mock objects
mock_channel = double("NotificationChannel")
notification_service = NotificationService.new([mock_channel])
```

**Benefits:**
- High-level code doesn't depend on low-level code
- Easy to swap implementations
- Easy to test (inject mocks)
- Easy to extend (add new notification types)
- Follows DIP: both depend on abstractions

### When to Use DIP

**Use DIP when:**
- ✅ High-level code directly creates low-level objects
- ✅ Hard to test because of concrete dependencies
- ✅ Want to swap implementations easily
- ✅ Code is tightly coupled to specific implementations

**Decision Guide:**
```
Does high-level code depend on concrete low-level classes?
├─ YES → Use abstractions/interfaces (DIP)
└─ NO → You're good!
```

---

## Quick Reference: Problem Recognition Guide

### When You See This Problem → Use This Principle

| Problem | Principle | Solution |
|---------|-----------|----------|
| Class does multiple unrelated things | **SRP** | Split into separate classes |
| Adding features requires modifying existing code | **OCP** | Use inheritance/polymorphism |
| Subclass breaks parent's contract | **LSP** | Fix the hierarchy |
| Class implements unused methods | **ISP** | Split interfaces |
| High-level depends on low-level directly | **DIP** | Depend on abstractions |

### Decision Tree

```
Is your class doing multiple things?
├─ YES → Apply SRP (split classes)
└─ NO → Continue

Do you modify existing code to add features?
├─ YES → Apply OCP (use polymorphism)
└─ NO → Continue

Can you substitute subclass for parent?
├─ NO → Apply LSP (fix hierarchy)
└─ YES → Continue

Are classes implementing unused methods?
├─ YES → Apply ISP (split interfaces)
└─ NO → Continue

Does high-level depend on low-level directly?
├─ YES → Apply DIP (use abstractions)
└─ NO → You're following SOLID! ✅
```

---

## Real-World Combined Example: E-Commerce System

### Problem: Order Processing System

**Initial Bad Design (Violates All SOLID Principles):**
```ruby
class OrderProcessor
  def initialize
    @database = MySQLDatabase.new # Violates DIP
  end
  
  def process_order(order, payment_type)
    # Violates SRP: Does calculation, validation, payment, email, database
    
    # Calculate total
    total = order.items.sum { |item| item.price * item.quantity }
    
    # Validate
    raise "Invalid order" if total <= 0
    
    # Process payment - violates OCP
    case payment_type
    when :credit_card
      CreditCardGateway.charge(total)
    when :paypal
      PayPalAPI.charge(total)
    end
    
    # Save to database
    @database.save(order)
    
    # Send email
    EmailService.send(order.customer.email, "Order confirmed")
  end
end
```

**Problems:**
- ❌ **SRP**: Does calculation, validation, payment, database, email
- ❌ **OCP**: Adding payment type requires modification
- ❌ **DIP**: Depends on MySQLDatabase directly
- ❌ **ISP**: Not applicable here
- ❌ **LSP**: Not applicable here

**Refactored Design (Follows SOLID):**
```ruby
# SRP: Each class has one responsibility

class OrderCalculator
  def calculate_total(order)
    order.items.sum { |item| item.price * item.quantity }
  end
end

class OrderValidator
  def validate(order)
    raise "Invalid order" if order.total <= 0
    raise "No items" if order.items.empty?
  end
end

# OCP: Open for extension (new payment methods), closed for modification
class PaymentMethod
  def process(amount)
    raise NotImplementedError
  end
end

class CreditCardPayment < PaymentMethod
  def process(amount)
    CreditCardGateway.charge(amount)
  end
end

class PayPalPayment < PaymentMethod
  def process(amount)
    PayPalAPI.charge(amount)
  end
end

# DIP: Depend on abstraction
module OrderRepository
  def save(order)
    raise NotImplementedError
  end
end

class MySQLOrderRepository
  include OrderRepository
  
  def save(order)
    MySQLDatabase.save(order)
  end
end

class PostgreSQLOrderRepository
  include OrderRepository
  
  def save(order)
    PostgreSQLDatabase.save(order)
  end
end

# ISP: Segregated interfaces
module Notifiable
  def notify(user, message)
    raise NotImplementedError
  end
end

class EmailNotifier
  include Notifiable
  
  def notify(user, message)
    EmailService.send(user.email, message)
  end
end

class SMSNotifier
  include Notifiable
  
  def notify(user, message)
    SMSService.send(user.phone, message)
  end
end

# High-level class - depends on abstractions (DIP)
class OrderProcessor
  def initialize(calculator, validator, repository, notifier)
    @calculator = calculator
    @validator = validator
    @repository = repository
    @notifier = notifier
  end
  
  def process_order(order, payment_method)
    # SRP: Each step uses a dedicated class
    order.total = @calculator.calculate_total(order)
    @validator.validate(order)
    payment_method.process(order.total) # OCP: Polymorphism
    @repository.save(order) # DIP: Abstraction
    @notifier.notify(order.customer, "Order confirmed") # DIP: Abstraction
  end
end

# Usage
calculator = OrderCalculator.new
validator = OrderValidator.new
repository = MySQLOrderRepository.new # Easy to swap!
notifier = EmailNotifier.new

processor = OrderProcessor.new(calculator, validator, repository, notifier)
processor.process_order(order, CreditCardPayment.new) # OCP: Easy to add new payment types
```

**Benefits:**
- ✅ **SRP**: Each class has one responsibility
- ✅ **OCP**: Add new payment methods without modification
- ✅ **LSP**: All payment methods are substitutable
- ✅ **ISP**: Interfaces are focused
- ✅ **DIP**: High-level depends on abstractions

---

## Summary

**SOLID Principles help you:**
1. Write maintainable code
2. Make changes safely
3. Test easily
4. Extend functionality without breaking existing code
5. Create flexible, reusable designs

**Remember:**
- **SRP**: One class, one job
- **OCP**: Extend, don't modify
- **LSP**: Subclasses must be substitutable
- **ISP**: Don't force unused methods
- **DIP**: Depend on abstractions

**Practice recognizing problems, and you'll naturally know which principle to apply!**

