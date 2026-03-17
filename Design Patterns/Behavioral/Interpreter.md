# Interpreter Pattern - Complete Guide

## What is the Interpreter Pattern?

The **Interpreter Pattern** defines a representation for a language's grammar and an interpreter to interpret sentences in that language.

## When to Use Interpreter Pattern

**Use Interpreter Pattern when:**
- ✅ You need to interpret a language or expressions
- ✅ Grammar is simple
- ✅ Performance is not critical
- ✅ You want to represent grammar as classes
- ✅ You need to evaluate expressions

## How to Recognize the Problem

**Red Flags:**
- You need to parse and evaluate expressions
- You have a simple grammar to interpret
- You need to build an expression evaluator
- "I need to interpret a language or expression"

## Real-World Example: Expression Evaluator

### Problem: Without Interpreter

```ruby
# Problem: Hard to extend, complex parsing
def evaluate(expression)
  # Complex string parsing and evaluation
  # Hard to add new operations
end
```

### Solution: With Interpreter

```ruby
# Abstract expression
class Expression
  def interpret(context)
    raise NotImplementedError
  end
end

# Terminal expressions
class Number < Expression
  def initialize(value)
    @value = value
  end
  
  def interpret(context)
    @value
  end
end

# Non-terminal expressions
class AddExpression < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end
  
  def interpret(context)
    @left.interpret(context) + @right.interpret(context)
  end
end

class SubtractExpression < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end
  
  def interpret(context)
    @left.interpret(context) - @right.interpret(context)
  end
end

class MultiplyExpression < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end
  
  def interpret(context)
    @left.interpret(context) * @right.interpret(context)
  end
end

# Usage: Build expression tree
# Expression: (5 + 3) * 2
expression = MultiplyExpression.new(
  AddExpression.new(
    Number.new(5),
    Number.new(3)
  ),
  Number.new(2)
)

result = expression.interpret({})
puts result  # 16
```

## Real-World Example: SQL-like Query

```ruby
class QueryExpression < Expression
  def initialize(table, conditions)
    @table = table
    @conditions = conditions
  end
  
  def interpret(context)
    results = context[@table]
    @conditions.each do |condition|
      results = condition.interpret(results)
    end
    results
  end
end

class WhereExpression < Expression
  def initialize(column, operator, value)
    @column = column
    @operator = operator
    @value = value
  end
  
  def interpret(data)
    data.select do |row|
      case @operator
      when "="
        row[@column] == @value
      when ">"
        row[@column] > @value
      end
    end
  end
end

# Usage
data = {
  users: [
    { name: "John", age: 30 },
    { name: "Jane", age: 25 }
  ]
}

query = QueryExpression.new(
  :users,
  [WhereExpression.new(:age, ">", 26)]
)

results = query.interpret(data)
```

## Benefits of Interpreter Pattern

1. **Extensibility**: Easy to add new expressions
2. **Representation**: Grammar represented as classes
3. **Flexibility**: Can change interpretation easily

## When NOT to Use Interpreter Pattern

- ❌ Grammar is complex (use parser generator)
- ❌ Performance is critical
- ❌ Grammar changes frequently

## Summary

**Interpreter Pattern:**
- Represents grammar as classes
- Interprets expressions
- Use for simple grammars
- Like a calculator that evaluates expressions


