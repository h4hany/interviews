# Proxy Pattern - Complete Guide

## What is the Proxy Pattern?

The **Proxy Pattern** provides a surrogate or placeholder for another object to control access to it. The proxy acts as an intermediary between client and real object.

## When to Use Proxy Pattern

**Use Proxy Pattern when:**
- ✅ You need to control access to an object
- ✅ You want lazy loading (create object only when needed)
- ✅ You need to add functionality (logging, caching) without modifying original
- ✅ You want to protect sensitive objects
- ✅ You need remote access (network proxy)

## How to Recognize the Problem

**Red Flags:**
- Object creation is expensive and might not be needed
- You need to add access control or logging
- You want to cache expensive operations
- You need to delay object creation
- "I need to control when/how an object is accessed"

## Real-World Example: Image Loading (Lazy Loading)

### Problem: Without Proxy

```ruby
# Problem: Loads all images immediately, even if not displayed
class Image
  def initialize(filename)
    @filename = filename
    load_from_disk  # Expensive operation!
  end
  
  def load_from_disk
    puts "Loading #{@filename} from disk (expensive!)"
    sleep(2)  # Simulate slow loading
  end
  
  def display
    puts "Displaying #{@filename}"
  end
end

# Problem: Creates all images even if user never views them
images = [
  Image.new("photo1.jpg"),  # Loaded immediately
  Image.new("photo2.jpg"),  # Loaded immediately
  Image.new("photo3.jpg")   # Loaded immediately
]
# All loaded, but user might only view one!
```

### Solution: With Proxy (Lazy Loading)

```ruby
# Subject interface
class Image
  def display
    raise NotImplementedError
  end
end

# Real subject - expensive to create
class RealImage < Image
  def initialize(filename)
    @filename = filename
    load_from_disk
  end
  
  def load_from_disk
    puts "Loading #{@filename} from disk (expensive!)"
    sleep(2)
  end
  
  def display
    puts "Displaying #{@filename}"
  end
end

# Proxy - controls access, lazy loads
class ImageProxy < Image
  def initialize(filename)
    @filename = filename
    @real_image = nil  # Not created yet!
  end
  
  def display
    # Lazy loading: create only when needed
    @real_image ||= RealImage.new(@filename)
    @real_image.display
  end
end

# Usage - images not loaded until displayed
images = [
  ImageProxy.new("photo1.jpg"),  # Not loaded yet!
  ImageProxy.new("photo2.jpg"),  # Not loaded yet!
  ImageProxy.new("photo3.jpg")   # Not loaded yet!
]

# Only loads when user actually views it
images[0].display  # Now it loads!
```

## Real-World Example: Access Control Proxy

```ruby
class Database
  def execute_query(query)
    puts "Executing: #{query}"
    "Results for #{query}"
  end
end

class DatabaseProxy
  def initialize(database, user)
    @database = database
    @user = user
  end
  
  def execute_query(query)
    # Access control
    unless @user.has_permission?(:read)
      raise "Access denied"
    end
    
    # Logging
    puts "User #{@user.name} executing: #{query}"
    
    # Execute
    @database.execute_query(query)
  end
end

# Usage
db = Database.new
user = User.new(name: "John", permissions: [:read])
proxy = DatabaseProxy.new(db, user)

proxy.execute_query("SELECT * FROM users")
```

## Real-World Example: Caching Proxy

```ruby
class ExpensiveService
  def fetch_data(key)
    puts "Fetching data for #{key} (expensive network call)"
    sleep(1)  # Simulate network delay
    "Data for #{key}"
  end
end

class CachingProxy
  def initialize(service)
    @service = service
    @cache = {}
  end
  
  def fetch_data(key)
    if @cache[key]
      puts "Returning cached data for #{key}"
      return @cache[key]
    end
    
    data = @service.fetch_data(key)
    @cache[key] = data
    data
  end
end

# Usage
service = ExpensiveService.new
proxy = CachingProxy.new(service)

proxy.fetch_data("user123")  # Fetches from service
proxy.fetch_data("user123")  # Returns from cache!
```

## Types of Proxies

1. **Virtual Proxy**: Lazy loading (create object when needed)
2. **Protection Proxy**: Access control
3. **Remote Proxy**: Network communication
4. **Caching Proxy**: Cache expensive operations
5. **Logging Proxy**: Add logging without modifying original

## Benefits of Proxy Pattern

1. **Lazy Loading**: Create objects only when needed
2. **Access Control**: Control who can access object
3. **Caching**: Cache expensive operations
4. **Separation**: Add functionality without modifying original

## When NOT to Use Proxy Pattern

- ❌ Object creation is cheap
- ❌ No need for access control or caching
- ❌ Over-engineering for simple cases

## Summary

**Proxy Pattern:**
- Controls access to another object
- Acts as intermediary
- Use for lazy loading, access control, caching
- Like a security guard controlling access to a building


