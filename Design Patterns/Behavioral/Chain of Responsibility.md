# Chain of Responsibility Pattern - Complete Guide

## What is the Chain of Responsibility Pattern?

The **Chain of Responsibility Pattern** passes requests along a chain of handlers. Each handler decides either to process the request or pass it to the next handler.

## When to Use Chain of Responsibility Pattern

**Use Chain of Responsibility Pattern when:**
- ✅ More than one object may handle a request
- ✅ You don't know which handler should process the request
- ✅ You want to decouple sender and receiver
- ✅ You want to add/remove handlers dynamically
- ✅ You need to process requests in a specific order

## How to Recognize the Problem

**Red Flags:**
- Multiple objects can handle a request
- You don't know which object should handle it
- You want to process requests through multiple handlers
- "I need to try multiple handlers until one can process the request"

## Real-World Example: Request Processing

### Problem: Without Chain

```ruby
class RequestProcessor
  def process(request)
    if request.amount < 100
      # Handle by manager
    elsif request.amount < 1000
      # Handle by director
    else
      # Handle by CEO
    end
  end
end

# Problem: All logic in one place, hard to extend
```

### Solution: With Chain of Responsibility

```ruby
# Handler interface
class Handler
  def initialize
    @next_handler = nil
  end
  
  def set_next(handler)
    @next_handler = handler
    handler
  end
  
  def handle(request)
    if can_handle?(request)
      process_request(request)
    elsif @next_handler
      @next_handler.handle(request)
    else
      puts "No handler can process this request"
    end
  end
  
  def can_handle?(request)
    raise NotImplementedError
  end
  
  def process_request(request)
    raise NotImplementedError
  end
end

# Concrete handlers
class ManagerHandler < Handler
  def can_handle?(request)
    request.amount <= 100
  end
  
  def process_request(request)
    puts "Manager approved request of $#{request.amount}"
  end
end

class DirectorHandler < Handler
  def can_handle?(request)
    request.amount <= 1000
  end
  
  def process_request(request)
    puts "Director approved request of $#{request.amount}"
  end
end

class CEOHandler < Handler
  def can_handle?(request)
    true  # CEO can handle any request
  end
  
  def process_request(request)
    puts "CEO approved request of $#{request.amount}"
  end
end

# Usage - build chain
manager = ManagerHandler.new
director = DirectorHandler.new
ceo = CEOHandler.new

manager.set_next(director).set_next(ceo)

# Process requests
manager.handle(Request.new(50))    # Manager handles
manager.handle(Request.new(500))   # Director handles
manager.handle(Request.new(5000))  # CEO handles
```

## Real-World Example: Authentication Chain

```ruby
class AuthHandler
  def initialize
    @next = nil
  end
  
  def set_next(handler)
    @next = handler
  end
  
  def authenticate(request)
    if can_authenticate?(request)
      return authenticate_request(request)
    end
    
    return @next.authenticate(request) if @next
    false
  end
  
  def can_authenticate?(request)
    raise NotImplementedError
  end
  
  def authenticate_request(request)
    raise NotImplementedError
  end
end

class APIKeyHandler < AuthHandler
  def can_authenticate?(request)
    request.has_api_key?
  end
  
  def authenticate_request(request)
    puts "Authenticating with API key"
    request.api_key == "valid_key"
  end
end

class TokenHandler < AuthHandler
  def can_authenticate?(request)
    request.has_token?
  end
  
  def authenticate_request(request)
    puts "Authenticating with token"
    validate_token(request.token)
  end
end

class SessionHandler < AuthHandler
  def can_authenticate?(request)
    request.has_session?
  end
  
  def authenticate_request(request)
    puts "Authenticating with session"
    validate_session(request.session)
  end
end

# Build chain
api_key = APIKeyHandler.new
token = TokenHandler.new
session = SessionHandler.new

api_key.set_next(token).set_next(session)

# Try authentication methods in order
api_key.authenticate(request)
```

## Benefits of Chain of Responsibility Pattern

1. **Decoupling**: Sender doesn't know which handler processes request
2. **Flexibility**: Add/remove handlers dynamically
3. **Ordering**: Process in specific order
4. **Single Responsibility**: Each handler has one responsibility

## When NOT to Use Chain of Responsibility Pattern

- ❌ Only one handler can process requests
- ❌ Request must be handled by specific handler
- ❌ Chain becomes too long and complex

## Summary

**Chain of Responsibility Pattern:**
- Passes request through chain of handlers
- Each handler can process or pass to next
- Use when multiple handlers can process request
- Like customer service escalation


