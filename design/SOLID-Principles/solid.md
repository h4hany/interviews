# Solid Principles Ruby Examples

## **Single Responsibility Principle (SRP)**

### **Definition:**

A class should have only one reason to change, meaning that a class should have

### **Problem**

Imagine a Report class responsible for both generating a report and sending it via email.

```ruby

class Report
  def generate
    # Logic to generate report
    "Report Content"
  end

  def send_email
    # Logic to send report via email
    puts "Email sent"
  end
end
```

This violates SRP because the class has two responsibilities: generating a report and sending an email.

### **Solution**

```ruby

class ReportGenerator
  def generate
    # Logic to generate report
    "Report Content"
  end
end

class EmailSender
  def send(content)
    # Logic to send report via email
    puts "Email sent with content: #{content}"
  end
end

report = ReportGenerator.new.generate
EmailSender.new.send(report)
```

## **Open/Closed Principle (OCP)**

### **Definition:**

Software entities (classes, modules, functions) should be open for extension but closed for modification.

### **Problem**

Consider a Discount class where adding a new discount type requires modifying existing code.

```ruby

class Discount
  def calculate(type, amount)
    case type
    when :seasonal
      amount * 0.9
    when :clearance
      amount * 0.5
    else
      amount
    end
  end
end
```

### **Solution**

```ruby

class Discount
  def calculate(amount)
    amount
  end
end

class SeasonalDiscount < Discount
  def calculate(amount)
    amount * 0.9
  end
end

class ClearanceDiscount < Discount
  def calculate(amount)
    amount * 0.5
  end
end

discount = SeasonalDiscount.new
puts discount.calculate(100) # Output: 90
```

## **Liskov Substitution Principle (LSP)**

### **Definition:**

Subtypes must be substitutable for their base types without altering the correctness of the program.

### **Problem**

A subclass violates LSP if it breaks the expected behavior of its superclass.

```ruby

class Bird
  def fly
    "Flying"
  end
end

class Penguin < Bird
  def fly
    raise "Penguins can't fly!"
  end
end
```

### **Solution**

```ruby

class Bird
end

class FlyingBird < Bird
  def fly
    "Flying"
  end
end

class Penguin < Bird
  def swim
    "Swimming"
  end
end

penguin = Penguin.new
puts penguin.swim # Output: Swimming
```

## **Interface Segregation Principle (ISP)**

### **Definition:**

Clients should not be forced to depend on interfaces they do not use.

### **Problem**

A Printer interface requires a Scan method, even if not all printers can scan.

```ruby

class MultiFunctionPrinter
  def print
    "Printing"
  end

  def scan
    "Scanning"
  end
end

class BasicPrinter
  def print
    "Printing"
  end

  def scan
    raise NotImplementedError, "Scan not supported"
  end
end
```

### **Solution**

```ruby

module Printable
  def print
    "Printing"
  end
end

module Scannable
  def scan
    "Scanning"
  end
end

class MultiFunctionPrinter
  include Printable
  include Scannable
end

class BasicPrinter
  include Printable
end
```

## **Dependency Inversion Principle (DIP)**

### **Definition:**

High-level modules should not depend on low-level modules. Both should depend on abstractions.

### **Problem**

A Notification class depends directly on an Email class.

```ruby

class Email
  def send_message
    "Sending Email"
  end
end

class Notification
  def notify
    Email.new.send_message
  end
end
```

### **Solution**

```ruby

class Notification
  def initialize(messenger)
    @messenger = messenger
  end

  def notify
    @messenger.send_message
  end
end

class Email
  def send_message
    "Sending Email"
  end
end

class SMS
  def send_message
    "Sending SMS"
  end
end

email_notification = Notification.new(Email.new)
puts email_notification.notify # Output: Sending Email

sms_notification = Notification.new(SMS.new)
puts sms_notification.notify # Output: Sending SMS
```

| Principle | Problem                                            | Solution                                              |
|-----------|----------------------------------------------------|-------------------------------------------------------|
| **SRP**   | One class handles multiple responsibilities.       | Split responsibilities into separate classes.         |
| **OCP**   | Existing code needs modification for new behavior. | Use polymorphism to extend behavior.                  |
| **LSP**   | Subclass behavior differs from expectations.       | Refactor hierarchy to reflect actual behavior.        |
| **ISP**   | Classes forced to implement unused methods.        | Split interfaces into smaller, specific ones.         |
| **DIP**   | High-level classes depend on low-level ones.       | Depend on abstractions, not concrete implementations. |

