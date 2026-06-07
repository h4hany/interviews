# Ruby Fundamentals — Interview Refresher

> Procore-style construction SaaS examples used throughout.

---

## 1. Ruby Basics

### Everything is an Object
```ruby
"Procore".class    # => String
100.class          # => Integer
nil.class          # => NilClass
:open.class        # => Symbol
```

### Symbols vs Strings
- **Symbol** — immutable identifier, used for keys, states, internal labels
- **String** — mutable text, used for user-facing content

```ruby
# Symbol for internal state
rfi_status = :open

# String for display
rfi_message = "RFI is waiting for architect response"
```

### Nil and Truthiness
Only `nil` and `false` are falsey in Ruby. Everything else (including `0`, `""`, `[]`) is truthy.

```ruby
if nil   # falsey
if false # falsey
if 0     # truthy!
if ""    # truthy!
```

### String Interpolation
```ruby
project_name = "Hospital Expansion"
puts "Project: #{project_name}"

rfi_number = "RFI-102"
puts "New #{rfi_number} was created"
```

### Implicit Return
Ruby methods return the last evaluated expression — no explicit `return` needed.
```ruby
def display_name(first, last)
  "#{first} #{last}"
end
```

---

## 2. Collections

### Arrays
```ruby
trades = ["Electrical", "Plumbing", "Concrete"]
project_tools = ["RFIs", "Submittals", "Documents", "Daily Logs"]
```

### Hashes
```ruby
rfi = {
  subject: "Clarify door schedule",
  status: "open",
  priority: "high"
}
```

### Key Enumerable Methods

| Method | Purpose | Example |
|--------|---------|---------|
| `each` | Iterate (no return value) | `rfis.each { \|r\| puts r.subject }` |
| `map` | Transform → new array | `rfis.map(&:subject)` |
| `select` | Filter → matching items | `rfis.select { \|r\| r.status == "open" }` |
| `reject` | Filter → non-matching items | `rfis.reject { \|r\| r.closed? }` |
| `find` | First matching item | `rfis.find { \|r\| r.priority == "high" }` |
| `reduce` | Accumulate single value | `amounts.reduce(0, :+)` |
| `flat_map` | Map + flatten | `projects.flat_map(&:rfis)` |
| `group_by` | Group into hash | `rfis.group_by(&:status)` |
| `sort_by` | Sort by attribute | `rfis.sort_by(&:due_date)` |
| `count` | Count matching | `rfis.count { \|r\| r.overdue? }` |
| `any?` / `all?` / `none?` | Boolean checks | `rfis.any?(&:overdue?)` |
| `tally` | Count occurrences | `statuses.tally # {"open"=>3, "closed"=>2}` |
| `each_with_object` | Iterate with accumulator | See below |

```ruby
# each_with_object example
workers.each_with_object(Hash.new { |h, k| h[k] = [] }) do |worker, index|
  worker.trades.each { |trade| index[trade] << worker }
end
```

---

## 3. Blocks, Procs, and Lambdas

### Blocks
Anonymous code passed to a method:
```ruby
projects.each do |project|
  puts project.name
end

# Short form
projects.each { |project| puts project.name }
```

### Procs
Stored blocks:
```ruby
overdue_check = Proc.new { |rfi| rfi.due_date < Date.current }
overdue_rfis = rfis.select(&overdue_check)
```

### Lambdas
Like procs but with strict argument checking and different return behavior:
```ruby
cost_filter = ->(min) { Proc.new { |worker| worker.cost >= min } }
expensive = workers.select(&cost_filter.call(100))
```

### Key Differences
| Feature | Block | Proc | Lambda |
|---------|-------|------|--------|
| Object? | No | Yes | Yes |
| Arity check | N/A | Lenient | Strict |
| `return` behavior | Exits enclosing method | Exits enclosing method | Returns to caller |

---

## 4. Object-Oriented Programming

### Classes and Initialize
```ruby
class RfiNotification
  def initialize(rfi)
    @rfi = rfi
  end

  def message
    "RFI #{@rfi.id} needs your response"
  end
end

notification = RfiNotification.new(rfi)
```

### attr_reader / attr_writer / attr_accessor
```ruby
class ProjectSummary
  attr_reader :project     # getter only
  attr_accessor :status    # getter + setter

  def initialize(project)
    @project = project
    @status = "active"
  end
end
```

### Inheritance
```ruby
class ApplicationNotifier
  def deliver(message)
    puts message
  end
end

class RfiNotifier < ApplicationNotifier
  # inherits deliver method
end
```

### Modules (Mixins)
```ruby
module Auditable
  def audit(action)
    AuditLog.create!(action: action, record: self)
  end
end

class Rfi < ApplicationRecord
  include Auditable  # instance methods
end

module Searchable
  def search(query)
    where("subject ILIKE ?", "%#{query}%")
  end
end

class Rfi < ApplicationRecord
  extend Searchable  # class methods
end
```

### `include` vs `extend`
- `include` → adds module methods as **instance methods**
- `extend` → adds module methods as **class methods**

---

## 5. Error Handling

```ruby
begin
  Rfi.find(params[:id])
rescue ActiveRecord::RecordNotFound => e
  puts "RFI not found: #{e.message}"
rescue StandardError => e
  puts "Unexpected error: #{e.message}"
ensure
  # always runs
end
```

### Custom Exceptions
```ruby
class WorkScheduler
  class UnschedulableTradeError < StandardError; end

  def schedule(trades)
    raise UnschedulableTradeError, "No workers for: #{trade}" if workers_empty?
  end
end
```

---

## 6. Duck Typing

Ruby cares about **what an object can do**, not its class:
```ruby
def notify(record)
  puts "Notify about #{record.title}"
end

# Works with any object that has a `title` method:
notify(rfi)       # Rfi has #title
notify(submittal) # Submittal has #title
notify(task)      # Task has #title
```

---

## 7. Struct and Data Classes

```ruby
# Struct — value object with named fields
Assignment = Struct.new(:trade, :worker_email, keyword_init: true)
assignment = Assignment.new(trade: "plumbing", worker_email: "alice@example.com")

# Frozen struct for immutability
Result = Struct.new(:success?, :value, :error, keyword_init: true)
```

---

## 8. Private / Protected / Public

```ruby
class RfisController < ApplicationController
  def create
    @rfi = Rfi.new(rfi_params)
  end

  private  # only callable inside this class

  def rfi_params
    params.require(:rfi).permit(:subject, :question, :project_id)
  end
end
```

- `private` — only callable within the object (no explicit receiver)
- `protected` — callable within the object and by instances of the same class
- `public` — callable by anyone (default)

---

## Interview Short Answers

| Question | Quick Answer |
|----------|-------------|
| What is Ruby? | Dynamic, interpreted, object-oriented language. Everything is an object. |
| Symbol vs String? | Symbols are immutable identifiers for internal use. Strings are mutable text for user-facing content. |
| What is `nil`? | Represents absence of value. Only `nil` and `false` are falsey. |
| What are blocks? | Anonymous code passed to methods, heavily used with collections. |
| Proc vs Lambda? | Both are stored blocks. Lambda has strict arity and returns to caller; Proc exits enclosing method. |
| What is duck typing? | Ruby cares about behavior (methods), not class. If it quacks like a duck... |
| include vs extend? | `include` adds instance methods. `extend` adds class methods. |
