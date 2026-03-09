# Template Method Pattern - Complete Guide

## What is the Template Method Pattern?

The **Template Method Pattern** defines the skeleton of an algorithm in a method, deferring some steps to subclasses. It lets subclasses redefine certain steps without changing the algorithm's structure.

## When to Use Template Method Pattern

**Use Template Method Pattern when:**
- ✅ You have an algorithm with steps that can vary
- ✅ You want to avoid code duplication
- ✅ Overall algorithm structure is fixed
- ✅ Subclasses should only customize specific steps
- ✅ You want to control the algorithm flow

## How to Recognize the Problem

**Red Flags:**
- Multiple classes have similar algorithms with slight variations
- Code duplication across classes
- Algorithm steps are mostly the same, only few differ
- "I have the same process but different implementations for some steps"

## Real-World Example: Data Processing Pipeline

### Problem: Without Template Method

```ruby
class CSVProcessor
  def process
    data = read_csv
    cleaned = clean_data(data)
    transformed = transform_data(cleaned)
    save_to_database(transformed)
  end
  
  def read_csv
    # CSV reading logic
  end
  
  def clean_data(data)
    # CSV cleaning logic
  end
  
  def transform_data(data)
    # CSV transformation logic
  end
  
  def save_to_database(data)
    # Database saving
  end
end

class JSONProcessor
  def process
    data = read_json  # Different!
    cleaned = clean_data(data)
    transformed = transform_data(cleaned)
    save_to_database(transformed)
  end
  
  def read_json  # Different!
    # JSON reading logic
  end
  
  def clean_data(data)
    # Similar cleaning logic (duplication!)
  end
  
  def transform_data(data)
    # Similar transformation (duplication!)
  end
  
  def save_to_database(data)
    # Same database saving (duplication!)
  end
end

# Problem: Code duplication, algorithm structure repeated
```

### Solution: With Template Method

```ruby
# Abstract class with template method
class DataProcessor
  # Template method - defines algorithm skeleton
  def process
    data = read_data        # Step 1: Varies by subclass
    cleaned = clean_data(data)      # Step 2: Same for all
    transformed = transform_data(cleaned)  # Step 3: Same for all
    save_to_database(transformed)    # Step 4: Same for all
  end
  
  # Primitive operations - must be implemented by subclasses
  def read_data
    raise NotImplementedError
  end
  
  # Hook methods - can be overridden
  def clean_data(data)
    # Default implementation
    data.reject { |item| item.nil? }
  end
  
  def transform_data(data)
    # Default implementation
    data.map { |item| item.transform }
  end
  
  def save_to_database(data)
    # Same for all
    Database.save(data)
  end
end

# Concrete implementations
class CSVProcessor < DataProcessor
  def read_data
    puts "Reading CSV file"
    # CSV reading logic
    [{ name: "John" }, { name: "Jane" }]
  end
end

class JSONProcessor < DataProcessor
  def read_data
    puts "Reading JSON file"
    # JSON reading logic
    [{ name: "John" }, { name: "Jane" }]
  end
end

class XMLProcessor < DataProcessor
  def read_data
    puts "Reading XML file"
    # XML reading logic
    [{ name: "John" }, { name: "Jane" }]
  end
  
  # Can override hook method if needed
  def clean_data(data)
    puts "XML-specific cleaning"
    super  # Call parent implementation
  end
end

# Usage
csv_processor = CSVProcessor.new
csv_processor.process  # Uses template method

json_processor = JSONProcessor.new
json_processor.process  # Same algorithm, different data source
```

## Real-World Example: Build Process

```ruby
class BuildProcess
  def build
    fetch_dependencies
    compile
    run_tests
    package
    deploy
  end
  
  def fetch_dependencies
    raise NotImplementedError
  end
  
  def compile
    puts "Compiling..."
  end
  
  def run_tests
    puts "Running tests..."
  end
  
  def package
    puts "Packaging..."
  end
  
  def deploy
    raise NotImplementedError
  end
end

class JavaBuild < BuildProcess
  def fetch_dependencies
    puts "Fetching Maven dependencies"
  end
  
  def deploy
    puts "Deploying JAR to server"
  end
end

class NodeBuild < BuildProcess
  def fetch_dependencies
    puts "Running npm install"
  end
  
  def deploy
    puts "Deploying to Node server"
  end
end
```

## Benefits of Template Method Pattern

1. **Code Reuse**: Common algorithm steps in base class
2. **Consistency**: Algorithm structure is fixed
3. **Flexibility**: Subclasses customize specific steps
4. **Control**: Base class controls algorithm flow

## When NOT to Use Template Method Pattern

- ❌ Algorithm steps vary too much
- ❌ You need more flexibility than template allows
- ❌ Over-engineering for simple cases

## Summary

**Template Method Pattern:**
- Defines algorithm skeleton
- Subclasses implement specific steps
- Use when algorithm structure is fixed but steps vary
- Like a recipe with some steps you can customize

