# Ruby & Ruby on Rails Interview Preparation Guide  
## Procore-Style Examples for Construction SaaS Backend Interviews

> Prepared for refreshing Ruby/Rails fundamentals through advanced backend topics, using Procore-style construction SaaS examples such as projects, companies, RFIs, submittals, tickets, documents, workflows, permissions, invoices, and project collaboration.

---

## How to Use This Guide

Use this guide as a practical interview refresher.

For each topic, try to answer in this structure:

1. **Definition** — explain the concept simply.
2. **Rails example** — show how it appears in real Rails code.
3. **Procore-style scenario** — connect it to construction SaaS.
4. **Tradeoff** — explain performance, security, or maintainability impact.
5. **Interview short answer** — say it clearly in 30–60 seconds.

---

## Procore-Style Domain Used in Examples

Throughout this file, examples use a construction SaaS domain similar to Procore:

- `Company`
- `Project`
- `User`
- `ProjectMembership`
- `Rfi`
- `Submittal`
- `Document`
- `Ticket`
- `Workflow`
- `Invoice`
- `PaymentApplication`
- `Permission`
- `AuditLog`

Example relationships:

```ruby
class Company < ApplicationRecord
  has_many :projects
  has_many :users
end

class Project < ApplicationRecord
  belongs_to :company
  has_many :rfis
  has_many :submittals
  has_many :documents
  has_many :project_memberships
end

class User < ApplicationRecord
  belongs_to :company
  has_many :project_memberships
  has_many :projects, through: :project_memberships
end

class Rfi < ApplicationRecord
  belongs_to :project
  belongs_to :created_by, class_name: "User"

  validates :subject, :question, :status, presence: true
end
```

---

# Part 1 — Basic Ruby Questions

## 1. What is Ruby?

Ruby is a dynamic, interpreted, object-oriented programming language.

Almost everything in Ruby is an object.

```ruby
"Procore".class
# => String

100.class
# => Integer

nil.class
# => NilClass
```

### Procore-style example

A project name, RFI status, and invoice amount can all be represented as Ruby objects:

```ruby
project_name = "Hospital Expansion"
rfi_status = :open
invoice_amount = 150_000
```

### Interview short answer

Ruby is a dynamic object-oriented language. In Ruby, almost everything is an object, and Rails is built on top of Ruby.

---

## 2. What is the difference between Ruby and Ruby on Rails?

Ruby is the programming language.

Ruby on Rails is a web framework written in Ruby.

Ruby example:

```ruby
project_name = "Airport Terminal Renovation"
puts "Project: #{project_name}"
```

Rails example:

```ruby
class ProjectsController < ApplicationController
  def show
    @project = Project.find(params[:id])
  end
end
```

### Interview short answer

Ruby is the language. Rails is the web framework that uses Ruby to build web applications using MVC, routing, ActiveRecord, controllers, views, jobs, and more.

---

## 3. What are symbols and why are they used?

A symbol is an immutable identifier.

```ruby
:open
:closed
:pending_review
```

Symbols are often used as keys or states.

```ruby
rfi = {
  subject: "Clarify beam size",
  status: :open
}
```

### Interview short answer

Symbols are immutable identifiers. They are commonly used as hash keys, enum-like values, method names, and internal states.

---

## 4. What is the difference between String and Symbol?

A string is mutable text.

A symbol is an immutable identifier.

```ruby
"open"  # String
:open   # Symbol
```

Use string for user-facing text:

```ruby
"RFI is waiting for architect response"
```

Use symbol for internal state:

```ruby
:waiting_for_response
```

### Interview short answer

Strings are for text data. Symbols are lightweight immutable identifiers, commonly used as keys or internal states.

---

## 5. What is an Array?

An array is an ordered list.

```ruby
trades = ["Electrical", "Plumbing", "Concrete"]
```

### Procore-style example

```ruby
project_tools = ["RFIs", "Submittals", "Documents", "Daily Logs"]

project_tools.each do |tool|
  puts tool
end
```

### Interview short answer

An array stores ordered values and is useful when order matters or when working with lists.

---

## 6. What is a Hash?

A hash stores key-value pairs.

```ruby
rfi = {
  subject: "Clarify door schedule",
  status: "open",
  priority: "high"
}
```

### Interview short answer

A hash stores values by keys. Rails uses hashes heavily in params, JSON responses, options, and configuration.

---

## 7. What is `nil`?

`nil` means no value.

```ruby
rfi.assignee
# => nil
```

Only `nil` and `false` are falsey in Ruby.

```ruby
if nil
  puts "yes"
else
  puts "no"
end
```

### Interview short answer

`nil` represents absence of value. In Ruby, only `nil` and `false` are falsey.

---

## 8. What is string interpolation?

String interpolation inserts Ruby expressions inside strings.

```ruby
project_name = "Tower A"
puts "Project name is #{project_name}"
```

### Procore-style example

```ruby
rfi_number = "RFI-102"
puts "New #{rfi_number} was created"
```

### Interview short answer

String interpolation lets us embed Ruby expressions inside double-quoted strings using `#{}`.

---

## 9. What is a method?

A method is reusable logic.

```ruby
def overdue?(due_date)
  due_date < Date.today
end
```

### Procore-style example

```ruby
def rfi_overdue?(rfi)
  rfi.due_date.present? && rfi.due_date < Date.current
end
```

### Interview short answer

A method groups reusable behavior. In Ruby, methods return the last evaluated expression automatically.

---

## 10. What is implicit return?

Ruby methods return the last evaluated expression by default.

```ruby
def display_name(first_name, last_name)
  "#{first_name} #{last_name}"
end
```

No explicit `return` is needed.

### Interview short answer

Ruby has implicit return, meaning the last expression in a method becomes the return value.

---

## 11. What are blocks?

A block is code passed to a method.

```ruby
projects.each do |project|
  puts project.name
end
```

Short form:

```ruby
projects.each { |project| puts project.name }
```

### Interview short answer

Blocks are anonymous pieces of code passed to methods. They are heavily used with collection methods like `each`, `map`, and `select`.

---

## 12. What is `map`?

`map` transforms a collection and returns a new array.

```ruby
rfi_subjects = rfis.map do |rfi|
  rfi.subject
end
```

Short form:

```ruby
rfi_subjects = rfis.map(&:subject)
```

### Interview short answer

`map` is used when we want to transform every item in a collection and return a new array.

---

## 13. What is `select`?

`select` filters a collection.

```ruby
open_rfis = rfis.select do |rfi|
  rfi.status == "open"
end
```

### Interview short answer

`select` returns items that match a condition.

---

## 14. What is `find`?

`find` returns the first matching item.

```ruby
high_priority_rfi = rfis.find do |rfi|
  rfi.priority == "high"
end
```

### Interview short answer

`find` returns the first item matching the condition, or `nil` if nothing matches.

---

## 15. What is a class?

A class is a blueprint for objects.

```ruby
class RfiNotification
  def initialize(rfi)
    @rfi = rfi
  end

  def message
    "RFI #{@rfi.id} needs your response"
  end
end
```

### Interview short answer

A class defines the structure and behavior of objects.

---

## 16. What is an object?

An object is an instance of a class.

```ruby
notification = RfiNotification.new(rfi)
```

### Interview short answer

An object is a real instance created from a class.

---

## 17. What is `initialize`?

`initialize` runs when an object is created.

```ruby
class RfiNotification
  def initialize(rfi)
    @rfi = rfi
  end
end
```

### Interview short answer

`initialize` is Ruby’s constructor method. It prepares a new object.

---

## 18. What are instance variables?

Instance variables start with `@` and belong to an object.

```ruby
@project
@rfi
@current_user
```

### Procore-style example

```ruby
class RfiPresenter
  def initialize(rfi)
    @rfi = rfi
  end
end
```

### Interview short answer

Instance variables store object-specific state.

---

## 19. What is `attr_reader`, `attr_writer`, and `attr_accessor`?

```ruby
class ProjectSummary
  attr_reader :project
  attr_accessor :status

  def initialize(project)
    @project = project
    @status = "active"
  end
end
```

- `attr_reader` creates getter.
- `attr_writer` creates setter.
- `attr_accessor` creates both.

### Interview short answer

These methods automatically create getter and setter methods for instance variables.

---

## 20. What is inheritance?

Inheritance lets one class reuse behavior from another.

```ruby
class ApplicationNotifier
  def deliver(message)
    puts message
  end
end

class RfiNotifier < ApplicationNotifier
end
```

### Interview short answer

Inheritance allows a child class to reuse or override behavior from a parent class.

---

## 21. What is a module?

A module groups reusable behavior.

```ruby
module Auditable
  def audit(action)
    AuditLog.create!(action: action, record: self)
  end
end

class Rfi < ApplicationRecord
  include Auditable
end
```

### Interview short answer

A module is used to share behavior between classes without inheritance.

---

## 22. What is the difference between `include` and `extend`?

`include` adds methods as instance methods.

```ruby
class Rfi
  include Auditable
end

rfi.audit("created")
```

`extend` adds methods as class methods.

```ruby
module Searchable
  def search(query)
    where("subject ILIKE ?", "%#{query}%")
  end
end

class Rfi < ApplicationRecord
  extend Searchable
end

Rfi.search("beam")
```

### Interview short answer

`include` adds module methods to instances. `extend` adds them to the class itself.

---

## 23. What is exception handling?

Exception handling lets us handle errors safely.

```ruby
begin
  Rfi.find(params[:id])
rescue ActiveRecord::RecordNotFound
  puts "RFI not found"
end
```

### Interview short answer

Exception handling lets us rescue and respond to errors instead of crashing unexpectedly.

---

## 24. What is `private`?

Private methods can only be called inside the object.

```ruby
class RfisController < ApplicationController
  def create
    @rfi = Rfi.new(rfi_params)
  end

  private

  def rfi_params
    params.require(:rfi).permit(:subject, :question, :project_id)
  end
end
```

### Interview short answer

Private methods hide internal implementation details and cannot be called directly from outside the object.

---

## 25. What is duck typing?

Duck typing means Ruby cares about what an object can do, not its class.

```ruby
def notify(record)
  puts "Notify about #{record.title}"
end
```

Any object with a `title` method can be used.

### Interview short answer

Duck typing means behavior matters more than class. If an object responds to the expected methods, it can be used.

---

# Part 2 — Basic Rails Questions

## 26. What is Rails?

Ruby on Rails is a web framework for building web applications.

Rails provides:

- MVC
- Routing
- ActiveRecord ORM
- Migrations
- Controllers
- Views
- Background jobs
- Mailers
- Security helpers
- Testing tools

### Interview short answer

Rails is a Ruby web framework based on convention over configuration and MVC.

---

## 27. What is MVC?

MVC means:

- **Model** — data and business logic
- **View** — presentation
- **Controller** — request handling

Procore-style flow:

```text
GET /projects/1/rfis
        ↓
Routes
        ↓
RfisController#index
        ↓
Project + Rfi models
        ↓
View or JSON response
```

### Interview short answer

MVC separates responsibilities. Models handle data, views display data, and controllers coordinate requests and responses.

---

## 28. What is a Rails model?

A model represents data and domain logic.

```ruby
class Rfi < ApplicationRecord
  belongs_to :project
  validates :subject, presence: true
end
```

### Interview short answer

A model maps to a database table and contains validations, associations, scopes, and domain behavior.

---

## 29. What is a controller?

A controller receives the request, calls models or services, and returns a response.

```ruby
class RfisController < ApplicationController
  def index
    @project = Project.find(params[:project_id])
    @rfis = @project.rfis
  end
end
```

### Interview short answer

A controller coordinates HTTP requests and responses.

---

## 30. What is a route?

A route maps a URL to a controller action.

```ruby
resources :projects do
  resources :rfis
end
```

This creates routes like:

```text
GET /projects/:project_id/rfis
POST /projects/:project_id/rfis
GET /projects/:project_id/rfis/:id
```

### Interview short answer

Routes define how URLs connect to controller actions.

---

## 31. What are RESTful actions?

Common RESTful actions:

- `index`
- `show`
- `new`
- `create`
- `edit`
- `update`
- `destroy`

Example:

```ruby
class RfisController < ApplicationController
  def index; end
  def show; end
  def create; end
  def update; end
  def destroy; end
end
```

### Interview short answer

RESTful actions provide a standard way to create, read, update, and delete resources.

---

## 32. What is ActiveRecord?

ActiveRecord is Rails’ ORM.

It lets us work with database records as Ruby objects.

```ruby
Rfi.where(status: "open")
Project.find(1)
Submittal.create!(title: "Steel Shop Drawings")
```

### Interview short answer

ActiveRecord maps database tables to Ruby classes and allows us to query and update data using Ruby methods.

---

## 33. What is a migration?

A migration changes the database schema.

```ruby
class CreateRfis < ActiveRecord::Migration[7.1]
  def change
    create_table :rfis do |t|
      t.references :project, null: false, foreign_key: true
      t.string :subject, null: false
      t.text :question, null: false
      t.string :status, null: false, default: "open"
      t.date :due_date

      t.timestamps
    end
  end
end
```

### Interview short answer

A migration is a version-controlled way to change the database schema.

---

## 34. What is `schema.rb`?

`schema.rb` represents the current database structure.

You normally do not edit it manually.

### Interview short answer

Migrations describe changes over time. `schema.rb` describes the current final structure.

---

## 35. What are validations?

Validations check data before saving.

```ruby
class Rfi < ApplicationRecord
  validates :subject, :question, :status, presence: true
end
```

### Interview short answer

Validations protect application-level data correctness and provide user-friendly error messages.

---

## 36. What are associations?

Associations define relationships between models.

```ruby
class Project < ApplicationRecord
  has_many :rfis
end

class Rfi < ApplicationRecord
  belongs_to :project
end
```

### Interview short answer

Associations define how models relate to each other, such as one project having many RFIs.

---

## 37. What is `dependent: :destroy`?

It destroys associated records when the parent is destroyed.

```ruby
class Project < ApplicationRecord
  has_many :rfis, dependent: :destroy
end
```

### Warning

In real construction SaaS systems, deleting project records may be dangerous because audit history matters. You may prefer soft deletes or archival.

### Interview short answer

`dependent: :destroy` removes associated records and runs callbacks. It should be used carefully for business-critical records.

---

## 38. What is the difference between `destroy` and `delete`?

`destroy` runs callbacks.

```ruby
rfi.destroy
```

`delete` skips callbacks.

```ruby
rfi.delete
```

### Interview short answer

`destroy` runs callbacks and dependent logic. `delete` removes the row directly and is faster but bypasses business logic.

---

## 39. What are callbacks?

Callbacks run at lifecycle points.

```ruby
class Rfi < ApplicationRecord
  before_save :normalize_status
  after_commit :notify_assignee, on: :create

  private

  def normalize_status
    self.status = status.downcase
  end

  def notify_assignee
    RfiNotificationJob.perform_later(id)
  end
end
```

### Interview short answer

Callbacks run automatically before or after lifecycle events. They are useful, but too many callbacks can hide business logic.

---

## 40. What are strong parameters?

Strong parameters whitelist allowed request fields.

```ruby
def rfi_params
  params.require(:rfi).permit(:subject, :question, :due_date, :assignee_id)
end
```

### Security note

Do not permit dangerous fields casually:

```ruby
# risky
params.require(:rfi).permit(:status, :company_id, :created_by_id)
```

### Interview short answer

Strong parameters protect against mass assignment by allowing only specific fields from request params.

---

# Part 3 — Intermediate Ruby Questions

## 41. What is `yield`?

`yield` calls a block passed to a method.

```ruby
def with_audit(action)
  puts "Starting #{action}"
  yield
  puts "Finished #{action}"
end

with_audit("create_rfi") do
  Rfi.create!(subject: "Clarification", question: "Need details")
end
```

### Interview short answer

`yield` executes a block passed to a method.

---

## 42. What is `Proc` vs `lambda`?

Both are callable objects.

```ruby
processor = Proc.new { |rfi| rfi.update!(status: "reviewed") }
processor.call(rfi)
```

```ruby
processor = ->(rfi) { rfi.update!(status: "reviewed") }
processor.call(rfi)
```

Main differences:

- Lambda checks argument count strictly.
- Proc is more flexible.
- `return` behaves differently.

### Interview short answer

Proc and lambda are object versions of blocks. Lambdas are stricter with arguments and return behavior.

---

## 43. What is memoization?

Memoization stores a computed result.

```ruby
def open_rfis_count
  @open_rfis_count ||= project.rfis.open.count
end
```

### Boolean warning

```ruby
def visible?
  return @visible if defined?(@visible)

  @visible = calculate_visibility
end
```

### Interview short answer

Memoization caches expensive method results, but be careful when the result can be `false` or `nil`.

---

## 44. What is `send` vs `public_send`?

`send` can call private methods.

```ruby
object.send(:private_method)
```

`public_send` only calls public methods.

```ruby
object.public_send(:name)
```

### Security warning

Avoid this:

```ruby
record.send(params[:method])
```

Better:

```ruby
allowed = %w[subject status due_date]

if allowed.include?(params[:field])
  record.public_send(params[:field])
end
```

### Interview short answer

`public_send` is safer because it only calls public methods. Avoid dynamic method calls from user input unless whitelisted.

---

## 45. What is metaprogramming?

Metaprogramming means writing code that defines or modifies code.

```ruby
class Workflow
  %i[pending approved rejected].each do |state|
    define_method("#{state}?") do
      status == state.to_s
    end
  end
end
```

### Interview short answer

Metaprogramming lets Ruby define behavior dynamically. Rails uses it heavily in associations, validations, scopes, and callbacks.

---

## 46. What is `method_missing`?

`method_missing` is called when a method does not exist.

```ruby
class DynamicStatusChecker
  def initialize(record)
    @record = record
  end

  def method_missing(method_name, *args)
    if method_name.to_s.end_with?("?")
      @record.status == method_name.to_s.delete_suffix("?")
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.end_with?("?") || super
  end
end
```

### Interview short answer

`method_missing` enables dynamic behavior, but it should be used carefully and paired with `respond_to_missing?`.

---

# Part 4 — Intermediate Rails Questions

## 47. Explain the Rails request lifecycle.

Example request:

```text
GET /projects/10/rfis/55
```

Lifecycle:

```text
Client
  ↓
Web server / Rack
  ↓
Rails middleware
  ↓
Router
  ↓
RfisController#show
  ↓
Project/Rfi model
  ↓
View or JSON serializer
  ↓
Response
```

### Interview short answer

A Rails request passes through Rack middleware, routing, controller action, models/services, rendering, and finally returns a response.

---

## 48. What is Rack?

Rack is the interface between Ruby web servers and Ruby web frameworks.

Simple Rack app:

```ruby
class App
  def call(env)
    [200, { "Content-Type" => "text/plain" }, ["Hello"]]
  end
end
```

### Interview short answer

Rack provides a standard interface between web servers like Puma and frameworks like Rails.

---

## 49. What is middleware?

Middleware runs before or after a request reaches the controller.

Examples:

- Sessions
- Cookies
- Request ID
- Logging
- CORS
- Authentication
- Exception handling

```bash
rails middleware
```

### Interview short answer

Middleware wraps request processing and handles cross-cutting concerns before or after controllers.

---

## 50. What are `before_action`, `after_action`, and `around_action`?

```ruby
class RfisController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  after_action :track_access

  private

  def set_project
    @project = current_company.projects.find(params[:project_id])
  end
end
```

`around_action` wraps the action:

```ruby
around_action :measure_time

def measure_time
  started_at = Time.current
  yield
ensure
  Rails.logger.info("request_time=#{Time.current - started_at}")
end
```

### Interview short answer

Controller actions can be wrapped with filters for authentication, setup, logging, authorization, and instrumentation.

---

## 51. What is an ActiveRecord Relation?

An `ActiveRecord::Relation` is a lazy query object.

```ruby
rfis = Rfi.where(status: "open")
```

The query is not executed until needed:

```ruby
rfis.each { |rfi| puts rfi.subject }
```

### Interview short answer

An ActiveRecord relation represents a lazy, chainable database query.

---

## 52. What is N+1 query problem?

Bad:

```ruby
rfis = Rfi.all

rfis.each do |rfi|
  puts rfi.project.name
end
```

This creates:

```text
1 query for RFIs
N queries for projects
```

Fix:

```ruby
rfis = Rfi.includes(:project)
```

### Interview short answer

N+1 happens when each record triggers an extra query for its association. Fix it with proper eager loading such as `includes`.

---

## 53. What is `includes`, `preload`, `eager_load`, and `joins`?

```ruby
Rfi.includes(:project)
```

Usually eager loads with separate queries.

```ruby
Rfi.preload(:project)
```

Always separate queries.

```ruby
Rfi.eager_load(:project)
```

Uses `LEFT OUTER JOIN`.

```ruby
Rfi.joins(:project)
```

Uses `INNER JOIN`, but does not preload the association.

### Procore-style example

Find open RFIs for active projects:

```ruby
Rfi
  .joins(:project)
  .where(status: "open", projects: { active: true })
```

Avoid N+1 while displaying project names:

```ruby
Rfi
  .joins(:project)
  .includes(:project)
  .where(status: "open", projects: { active: true })
```

### Interview short answer

`includes` is for eager loading, `preload` always uses separate queries, `eager_load` uses a left join, and `joins` is for SQL filtering but does not preload associations.

---

## 54. What is `has_many :through`?

Use it for many-to-many relationships with a join model.

```ruby
class User < ApplicationRecord
  has_many :project_memberships
  has_many :projects, through: :project_memberships
end

class ProjectMembership < ApplicationRecord
  belongs_to :user
  belongs_to :project

  enum :role, {
    project_admin: 0,
    architect: 1,
    subcontractor: 2,
    viewer: 3
  }
end

class Project < ApplicationRecord
  has_many :project_memberships
  has_many :users, through: :project_memberships
end
```

### Interview short answer

`has_many :through` is preferred for many-to-many relationships when the relationship has extra data like role, permissions, status, or timestamps.

---

## 55. What is a polymorphic association?

A polymorphic model can belong to different model types.

```ruby
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
end

class Rfi < ApplicationRecord
  has_many :comments, as: :commentable
end

class Submittal < ApplicationRecord
  has_many :comments, as: :commentable
end

class Document < ApplicationRecord
  has_many :comments, as: :commentable
end
```

Migration:

```ruby
create_table :comments do |t|
  t.text :body, null: false
  t.references :commentable, polymorphic: true, null: false
  t.timestamps
end
```

### Tradeoff

Polymorphic associations are flexible but make database foreign keys harder.

### Interview short answer

Polymorphic associations allow one model, like Comment or Attachment, to belong to multiple model types.

---

## 56. What is `counter_cache`?

Stores associated count in a column.

```ruby
class Rfi < ApplicationRecord
  belongs_to :project, counter_cache: true
end
```

Project table:

```ruby
t.integer :rfis_count, default: 0, null: false
```

Then:

```ruby
project.rfis_count
```

Instead of:

```ruby
project.rfis.count
```

### Interview short answer

`counter_cache` improves performance by storing association counts instead of counting every time.

---

## 57. What is `touch: true`?

Updates parent `updated_at` when child changes.

```ruby
class Comment < ApplicationRecord
  belongs_to :rfi, touch: true
end
```

Useful for cache invalidation.

### Interview short answer

`touch: true` updates the parent timestamp when the child changes, often to expire caches.

---

## 58. What are transactions?

Transactions group database changes so they succeed or fail together.

```ruby
ActiveRecord::Base.transaction do
  rfi = project.rfis.create!(rfi_params)
  AuditLog.create!(record: rfi, action: "created")
end
```

### Interview short answer

Transactions protect consistency by ensuring all operations succeed together or roll back together.

---

## 59. What is a race condition?

A race condition happens when two processes modify shared data at the same time incorrectly.

Bad:

```ruby
if event.available_seats > 0
  event.update!(available_seats: event.available_seats - 1)
end
```

Better:

```ruby
Event.transaction do
  event = Event.lock.find(event_id)

  raise "Sold out" if event.available_seats <= 0

  event.update!(available_seats: event.available_seats - 1)
end
```

### Procore-style example

For a conference ticketing system like GroundBreak, physical attendance capacity must be protected with locks or atomic updates.

### Interview short answer

A race condition occurs when concurrent requests produce incorrect data. Fix it with database constraints, transactions, locks, or atomic updates.

---

## 60. What is a background job?

A background job runs work outside the web request.

```ruby
class RfiNotificationJob < ApplicationJob
  queue_as :default

  def perform(rfi_id)
    rfi = Rfi.find(rfi_id)
    RfiMailer.assigned(rfi).deliver_now
  end
end
```

Call:

```ruby
RfiNotificationJob.perform_later(rfi.id)
```

### Interview short answer

Background jobs handle slow or asynchronous work like emails, reports, file processing, API syncs, and notifications.

---

## 61. Why pass IDs to jobs instead of objects?

Good:

```ruby
RfiNotificationJob.perform_later(rfi.id)
```

Less ideal:

```ruby
RfiNotificationJob.perform_later(rfi)
```

Reasons:

- Avoid stale serialized objects.
- Reduce payload size.
- Reload latest state.
- Easier retries.

### Interview short answer

Pass IDs to jobs so the job reloads fresh data and avoids serialization/staleness issues.

---

## 62. What is idempotency in jobs?

An idempotent job can run multiple times safely.

```ruby
class CloseOverdueRfiJob < ApplicationJob
  def perform(rfi_id)
    rfi = Rfi.find(rfi_id)

    return if rfi.closed?

    rfi.update!(status: "closed")
  end
end
```

### Interview short answer

Idempotency means retries or duplicate job execution do not create duplicate or incorrect side effects.

---

## 63. What is caching?

Caching stores expensive results.

```ruby
Rails.cache.fetch("project:#{project.id}:open_rfis_count", expires_in: 10.minutes) do
  project.rfis.where(status: "open").count
end
```

### Interview short answer

Caching improves performance by reusing expensive results, but invalidation must be designed carefully.

---

## 64. What is fragment caching?

Caches part of a view.

```erb
<% cache @rfi do %>
  <h2><%= @rfi.subject %></h2>
  <p><%= @rfi.status %></p>
<% end %>
```

### Interview short answer

Fragment caching caches reusable view sections and expires them when the cache key changes.

---

## 65. What is SQL injection?

SQL injection happens when user input is inserted into SQL unsafely.

Bad:

```ruby
Rfi.where("subject = '#{params[:subject]}'")
```

Good:

```ruby
Rfi.where(subject: params[:subject])
```

Or:

```ruby
Rfi.where("subject = ?", params[:subject])
```

### Interview short answer

SQL injection is prevented by using parameterized queries, hash conditions, and whitelisting dynamic SQL parts.

---

## 66. What is XSS?

XSS happens when unsafe user input is rendered as HTML/JS.

Dangerous:

```erb
<%= raw @rfi.question %>
```

Safe default:

```erb
<%= @rfi.question %>
```

### Interview short answer

Rails escapes output by default. Avoid `raw` and `html_safe` on user-generated content unless sanitized.

---

## 67. Authentication vs authorization

Authentication asks:

```text
Who are you?
```

Authorization asks:

```text
What are you allowed to do?
```

Procore-style example:

- Authentication: user logs in.
- Authorization: can this user view this project’s RFIs?

```ruby
current_company.projects.find(params[:project_id])
```

### Interview short answer

Authentication verifies identity. Authorization checks permissions for a specific action or resource.

---

# Part 5 — Advanced Ruby/Rails Topics

## 68. What is the Ruby GVL?

MRI Ruby has a Global VM Lock, meaning only one Ruby thread executes Ruby bytecode at a time per process.

Threads still help with I/O-bound work:

- PostgreSQL queries
- Redis calls
- HTTP API calls
- File uploads

Threads do not provide true parallel execution for CPU-heavy Ruby code.

### Procore-style example

A request listing RFIs may benefit from Puma threads because it waits on PostgreSQL.

A request generating a huge PDF report may be CPU-heavy and may not improve much with more threads.

### Interview short answer

The GVL allows only one Ruby thread to run Ruby code at a time per process. Threads help I/O-bound Rails requests, but CPU-heavy work needs more processes, background jobs, or external processing.

---

## 69. How do you choose Puma workers and threads?

Puma config:

```ruby
workers ENV.fetch("WEB_CONCURRENCY", 2)
threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
threads threads_count, threads_count
```

Total possible DB connections:

```text
WEB_CONCURRENCY * RAILS_MAX_THREADS * number_of_containers
```

Example:

```text
4 containers
2 workers each
5 threads each

4 * 2 * 5 = 40 possible web DB connections
```

ActiveRecord pool should match thread count per process:

```yaml
pool: <%= ENV.fetch("RAILS_MAX_THREADS", 5) %>
```

### Interview short answer

Workers give process-level parallelism. Threads increase concurrency for I/O-bound workloads. I size them based on CPU, memory, request profile, and total database connection limits.

---

## 70. Why can a fast SQL query still result in a slow endpoint?

Because endpoint time includes more than SQL.

Possible causes:

- Connection pool waiting
- N+1 queries
- JSON serialization
- Authorization checks
- Large payloads
- External APIs
- CPU-heavy Ruby
- View rendering
- Lock contention
- GC pauses

Bad serializer example:

```ruby
rfis.map do |rfi|
  {
    id: rfi.id,
    subject: rfi.subject,
    project_name: rfi.project.name,
    comments_count: rfi.comments.count
  }
end
```

Fix:

```ruby
rfis = Rfi.includes(:project).with_comments_count
```

### Interview short answer

A fast query does not guarantee a fast endpoint. I break down latency into queue time, DB time, rendering/serialization time, external calls, and Ruby CPU time.

---

## 71. How do you debug slow Rails endpoints?

Check:

1. Rails logs.
2. APM traces.
3. DB query time.
4. View/serialization time.
5. N+1 queries.
6. Connection pool waiting.
7. External API latency.
8. Memory allocations.
9. CPU profiling.
10. Recent deploys.

### Procore-style answer

For a slow `/projects/:id/rfis` endpoint:

- Check if RFIs are loaded with project, assignee, comments, and attachments.
- Look for N+1 in serializer.
- Check if project permissions are recalculated per record.
- Check if response returns too many RFIs without pagination.
- Check DB indexes on `project_id`, `status`, `due_date`.

### Interview short answer

I isolate where time is spent: DB, app CPU, rendering, queueing, or external calls. Then I fix the specific bottleneck and add monitoring or regression tests.

---

## 72. What is row-level locking?

Row-level locking locks selected rows inside a transaction.

```ruby
Project.transaction do
  project = Project.lock.find(project_id)

  project.update!(open_rfis_count: project.open_rfis_count + 1)
end
```

SQL equivalent:

```sql
SELECT * FROM projects WHERE id = 1 FOR UPDATE;
```

### Interview short answer

Row-level locking prevents concurrent transactions from modifying the same row at the same time. It is useful for counters, capacity, balances, and critical workflow state.

---

## 73. What is optimistic locking?

Optimistic locking uses a `lock_version` column.

```ruby
add_column :submittals, :lock_version, :integer, default: 0, null: false
```

If two users edit the same submittal at the same time, Rails raises:

```ruby
ActiveRecord::StaleObjectError
```

### Interview short answer

Optimistic locking detects concurrent updates without locking upfront. It is useful when conflicts are rare but should be detected.

---

## 74. What is a deadlock?

A deadlock happens when two transactions wait for each other.

Example:

```text
Transaction A locks RFI 1 then wants RFI 2
Transaction B locks RFI 2 then wants RFI 1
```

Reduce deadlocks by:

- Locking rows in consistent order.
- Keeping transactions short.
- Avoiding external calls inside transactions.
- Adding proper indexes.
- Retrying safely for idempotent operations.

### Interview short answer

Deadlocks happen when transactions wait on each other’s locks. I reduce them with consistent lock order, short transactions, proper indexes, and safe retries.

---

## 75. How do you design safe production migrations?

Unsafe for huge tables:

```ruby
add_column :rfis, :priority, :string, default: "normal", null: false
```

Safer approach:

```ruby
add_column :rfis, :priority, :string
```

Backfill in batches:

```ruby
Rfi.where(priority: nil).in_batches.update_all(priority: "normal")
```

Then:

```ruby
change_column_default :rfis, :priority, "normal"
change_column_null :rfis, :priority, false
```

Add indexes concurrently:

```ruby
class AddIndexToRfisStatus < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :rfis, [:project_id, :status], algorithm: :concurrently
  end
end
```

### Interview short answer

For production migrations, I avoid long locks, use expand-contract patterns, backfill in batches, add indexes concurrently, and ensure old and new code can run during deploy.

---

## 76. What is an index and how do you choose one?

Index example:

```ruby
add_index :rfis, [:project_id, :status, :due_date]
```

Good for:

```ruby
Rfi
  .where(project_id: project.id, status: "open")
  .order(:due_date)
```

### Tradeoff

Indexes improve reads but slow writes and use storage.

### Interview short answer

I choose indexes based on actual query patterns: filters, joins, ordering, uniqueness, and foreign keys. I verify with `EXPLAIN ANALYZE`.

---

## 77. What is a partial index?

Indexes only part of a table.

```ruby
add_index :rfis, [:project_id, :due_date],
  where: "status = 'open'",
  name: "index_open_rfis_on_project_and_due_date"
```

Useful for:

```ruby
Rfi.where(project_id: project.id, status: "open").order(:due_date)
```

### Interview short answer

Partial indexes are useful when queries target a specific subset of rows, like open RFIs or active projects.

---

## 78. What is an expression index?

Indexes an expression.

```ruby
add_index :users, "LOWER(email)", name: "index_users_on_lower_email"
```

Used for:

```ruby
User.where("LOWER(email) = ?", email.downcase)
```

### Interview short answer

Expression indexes optimize queries that filter by computed values like `LOWER(email)`.

---

## 79. What is `EXPLAIN ANALYZE`?

`EXPLAIN ANALYZE` shows how PostgreSQL actually executed a query.

Look for:

- Sequential scans on large tables.
- Missing indexes.
- Bad row estimates.
- Expensive joins.
- Sort operations.
- High actual time.

Rails:

```ruby
puts Rfi.where(project_id: 1, status: "open").explain
```

SQL:

```sql
EXPLAIN ANALYZE
SELECT *
FROM rfis
WHERE project_id = 1
AND status = 'open';
```

### Interview short answer

I use `EXPLAIN ANALYZE` to understand actual database execution and decide whether to add indexes or rewrite queries.

---

# Part 6 — Advanced Architecture

## 80. What is a service object?

A service object handles business workflows.

```ruby
module Rfis
  class Create
    Result = Struct.new(:success?, :rfi, :error, keyword_init: true)

    def initialize(project:, user:, params:)
      @project = project
      @user = user
      @params = params
    end

    def call
      rfi = nil

      ActiveRecord::Base.transaction do
        rfi = @project.rfis.create!(
          @params.merge(created_by: @user, status: "open")
        )

        AuditLog.create!(
          actor: @user,
          record: rfi,
          action: "rfi.created"
        )
      end

      RfiNotificationJob.perform_later(rfi.id)

      Result.new(success?: true, rfi: rfi)
    rescue ActiveRecord::RecordInvalid => e
      Result.new(success?: false, rfi: e.record, error: e.record.errors.full_messages)
    end
  end
end
```

Controller:

```ruby
def create
  result = Rfis::Create.new(
    project: current_project,
    user: current_user,
    params: rfi_params
  ).call

  if result.success?
    render json: result.rfi, status: :created
  else
    render json: { errors: result.error }, status: :unprocessable_entity
  end
end
```

### Interview short answer

Service objects make business workflows explicit and keep controllers/models smaller. They are useful when logic coordinates multiple models or external side effects.

---

## 81. What is a query object?

A query object encapsulates complex query logic.

```ruby
class RfisSearchQuery
  def initialize(scope = Rfi.all, filters = {})
    @scope = scope
    @filters = filters
  end

  def call
    scope = @scope
    scope = scope.where(status: @filters[:status]) if @filters[:status].present?
    scope = scope.where(priority: @filters[:priority]) if @filters[:priority].present?
    scope = scope.where("due_date <= ?", @filters[:due_before]) if @filters[:due_before].present?

    scope.includes(:project, :created_by).order(due_date: :asc)
  end
end
```

Usage:

```ruby
@rfis = RfisSearchQuery.new(current_project.rfis, params).call
```

### Interview short answer

Query objects keep complex filtering and search logic out of controllers and models.

---

## 82. What is a policy object?

A policy object handles authorization.

```ruby
class RfiPolicy
  def initialize(user, rfi)
    @user = user
    @rfi = rfi
  end

  def show?
    member_of_project?
  end

  def update?
    project_admin? || rfi_creator?
  end

  private

  def member_of_project?
    @user.projects.exists?(@rfi.project_id)
  end

  def project_admin?
    ProjectMembership.exists?(
      user: @user,
      project: @rfi.project,
      role: "project_admin"
    )
  end

  def rfi_creator?
    @rfi.created_by_id == @user.id
  end
end
```

### Interview short answer

Policy objects centralize authorization so permissions are explicit, testable, and not scattered across controllers.

---

## 83. What is a form object?

A form object handles multi-model form validation.

```ruby
class ProjectInviteForm
  include ActiveModel::Model

  attr_accessor :email, :role, :project, :invited_by

  validates :email, :role, presence: true

  def save
    return false unless valid?

    user = User.find_or_create_by!(email: email)

    ProjectMembership.create!(
      project: project,
      user: user,
      role: role,
      invited_by: invited_by
    )

    true
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
    false
  end
end
```

### Interview short answer

Form objects are useful when a form does not map cleanly to one ActiveRecord model.

---

## 84. What is a value object?

A value object represents a domain concept by value.

```ruby
class Money
  attr_reader :cents, :currency

  def initialize(cents:, currency:)
    @cents = cents
    @currency = currency
  end

  def +(other)
    raise "Currency mismatch" unless currency == other.currency

    Money.new(cents: cents + other.cents, currency: currency)
  end
end
```

### Procore-style use cases

- Contract value
- Invoice amount
- Budget variance
- Project date range
- Percentage complete

### Interview short answer

A value object models a concept like Money or DateRange with behavior, reducing primitive obsession.

---

## 85. What is the outbox pattern?

Problem:

```ruby
Rfi.transaction do
  rfi.update!(status: "answered")
end

EventBus.publish("rfi_answered", rfi.id)
```

If publishing fails, DB changed but no event was published.

Outbox solution:

```ruby
Rfi.transaction do
  rfi.update!(status: "answered")

  OutboxEvent.create!(
    event_type: "rfi_answered",
    payload: { rfi_id: rfi.id }
  )
end
```

Worker:

```ruby
OutboxEvent.pending.find_each do |event|
  EventBus.publish(event.event_type, event.payload)
  event.update!(published_at: Time.current)
end
```

### Interview short answer

The outbox pattern stores events in the same transaction as the business change, then publishes them asynchronously to avoid losing events.

---

## 86. What is API idempotency?

API idempotency prevents duplicate effects when clients retry.

Client sends:

```text
Idempotency-Key: abc-123
```

Server stores:

- Key
- Request fingerprint
- Response
- Resource ID
- Status

Example use case:

- Creating a ticket purchase.
- Creating payment application.
- Submitting invoice.
- Uploading document metadata.

### Interview short answer

API idempotency ensures retrying the same request does not create duplicate resources or side effects.

---

## 87. What is cursor pagination?

Offset pagination:

```ruby
Rfi.limit(20).offset(1000)
```

Can be slow at high offsets.

Cursor pagination:

```ruby
Rfi
  .where("id > ?", params[:cursor])
  .order(:id)
  .limit(20)
```

For created date:

```ruby
Rfi
  .where("created_at < ?", cursor_time)
  .order(created_at: :desc, id: :desc)
  .limit(20)
```

### Interview short answer

Cursor pagination is better for large datasets because it uses indexed stable ordering instead of expensive offsets.

---

# Part 7 — Multi-Tenancy and Security

## 88. What is multi-tenancy?

Multi-tenancy means one app serves many companies/accounts while isolating data.

Common Rails approach:

```ruby
class Project < ApplicationRecord
  belongs_to :company
end
```

Always scope:

```ruby
current_company.projects.find(params[:id])
```

Avoid:

```ruby
Project.find(params[:id])
```

### Interview short answer

Multi-tenancy requires strict tenant scoping so one company cannot access another company’s data.

---

## 89. How do you prevent cross-tenant data leaks?

Use scoped queries:

```ruby
@project = current_company.projects.find(params[:project_id])
@rfi = @project.rfis.find(params[:id])
```

Validate same tenant:

```ruby
validate :project_belongs_to_company

def project_belongs_to_company
  return if project.company_id == company_id

  errors.add(:project, "must belong to the same company")
end
```

Add indexes:

```ruby
add_index :projects, [:company_id, :id]
add_index :rfis, [:project_id, :status]
```

### Interview short answer

Prevent leaks by scoping all queries through the current company/project, enforcing authorization, validating tenant consistency, and adding tenant-aware indexes.

---

## 90. What is authorization leakage?

Bad:

```ruby
@rfi = Rfi.find(params[:id])
```

This may find another company’s RFI.

Better:

```ruby
@rfi = current_company
  .projects
  .find(params[:project_id])
  .rfis
  .find(params[:id])
```

### Interview short answer

Authorization leakage happens when records are fetched globally instead of through the authorized tenant or parent resource.

---

## 91. How do you secure dynamic sorting?

Bad:

```ruby
Rfi.order(params[:sort])
```

Good:

```ruby
allowed_sort_columns = {
  "created_at" => :created_at,
  "due_date" => :due_date,
  "status" => :status
}

column = allowed_sort_columns.fetch(params[:sort], :created_at)
direction = params[:direction] == "asc" ? :asc : :desc

Rfi.order(column => direction)
```

### Interview short answer

Dynamic SQL parts like `order` must be whitelisted because parameter binding does not protect column names or directions.

---

# Part 8 — Observability and Production Debugging

## 92. What is observability?

Observability means understanding system behavior from outputs.

Core signals:

- Logs
- Metrics
- Traces

Rails signals:

- Request latency
- DB time
- Queue time
- Error rate
- Job failures
- External API latency
- Cache hit rate
- Memory usage
- GC time

### Interview short answer

Observability lets us answer what happened, where it happened, and why, using logs, metrics, and traces.

---

## 93. What is structured logging?

Instead of:

```text
RFI created
```

Use:

```json
{
  "event": "rfi_created",
  "rfi_id": 123,
  "project_id": 55,
  "company_id": 8,
  "request_id": "abc-123"
}
```

### Interview short answer

Structured logs make production debugging easier because logs can be searched by fields like request ID, project ID, company ID, and job ID.

---

## 94. What is distributed tracing?

Tracing follows a request across components.

Example:

```text
Rails API
  → PostgreSQL
  → Redis
  → External integration
  → Background job
```

### Interview short answer

Distributed tracing shows where time is spent across services, DB queries, queues, and external API calls.

---

## 95. What is OpenTelemetry?

OpenTelemetry is a vendor-neutral standard for collecting telemetry.

In Rails it can instrument:

- Rack
- Rails controllers
- ActiveRecord
- Redis
- HTTP clients
- Background jobs

### Interview short answer

OpenTelemetry provides standard instrumentation for traces, metrics, and logs across Rails, databases, jobs, and external calls.

---

## 96. What should you include in traces/logs?

Include:

- Request ID
- Trace ID
- Controller/action
- Route
- HTTP status
- Project ID
- Company ID
- Job class
- Queue
- External service
- Error class

Avoid:

- Passwords
- Tokens
- Credit card data
- Sensitive PII
- Large payloads

### Interview short answer

Add enough metadata to debug issues, but avoid sensitive or excessive data.

---

# Part 9 — Advanced Testing

## 97. How do you test models?

```ruby
RSpec.describe Rfi, type: :model do
  it "requires subject" do
    rfi = build(:rfi, subject: nil)

    expect(rfi).not_to be_valid
  end

  it "belongs to project" do
    rfi = create(:rfi)

    expect(rfi.project).to be_present
  end
end
```

### Interview short answer

Model specs should test validations, associations, scopes, and domain methods.

---

## 98. How do you test request specs?

```ruby
RSpec.describe "RFIs API", type: :request do
  it "creates an RFI" do
    project = create(:project)
    user = create(:user, company: project.company)

    sign_in user

    expect {
      post "/projects/#{project.id}/rfis", params: {
        rfi: {
          subject: "Clarify slab thickness",
          question: "What is the required slab thickness?"
        }
      }
    }.to change(Rfi, :count).by(1)

    expect(response).to have_http_status(:created)
  end
end
```

### Interview short answer

Request specs test endpoint behavior: status code, response body, DB changes, authentication, authorization, and error cases.

---

## 99. How do you test service objects?

```ruby
RSpec.describe Rfis::Create do
  it "creates an rfi and audit log" do
    project = create(:project)
    user = create(:user, company: project.company)

    result = described_class.new(
      project: project,
      user: user,
      params: {
        subject: "Clarify ceiling height",
        question: "What is the ceiling height in lobby?"
      }
    ).call

    expect(result).to be_success
    expect(result.rfi).to be_persisted
    expect(AuditLog.where(record: result.rfi, action: "rfi.created")).to exist
  end
end
```

### Interview short answer

Service object tests should focus on business outcomes, DB changes, rollback behavior, and side effects.

---

## 100. How do you test background jobs?

```ruby
RSpec.describe RfiNotificationJob, type: :job do
  it "sends notification for assigned RFI" do
    rfi = create(:rfi)

    expect(RfiMailer).to receive(:assigned).with(rfi).and_call_original

    described_class.perform_now(rfi.id)
  end
end
```

### Interview short answer

Job tests should verify idempotency, state transitions, retries, missing records, and external side effects.

---

# Part 10 — Production Scenarios and Interview Answers

## 101. Scenario: RFI list endpoint is slow

### Possible causes

- Missing index on `project_id` and `status`.
- N+1 loading project, assignee, comments, attachments.
- Returning thousands of RFIs without pagination.
- Expensive permission checks per RFI.
- Slow serializer.
- Large JSON response.

### Fix

```ruby
rfis = current_project
  .rfis
  .includes(:created_by, :assignee)
  .where(status: params[:status])
  .order(created_at: :desc)
  .limit(50)
```

Add index:

```ruby
add_index :rfis, [:project_id, :status, :created_at]
```

### Interview answer

I would inspect traces and logs to split DB time from serialization time. I would check for N+1 queries, missing indexes, large payloads, and repeated authorization checks. Then I would add eager loading, pagination, proper indexes, and maybe cache counts if needed.

---

## 102. Scenario: Users can see RFIs from another company

### Root cause

The code probably does global lookup:

```ruby
Rfi.find(params[:id])
```

### Fix

Scope through company and project:

```ruby
project = current_company.projects.find(params[:project_id])
rfi = project.rfis.find(params[:id])
```

### Interview answer

This is a multi-tenant authorization bug. I would immediately patch the query to scope through the current tenant, add request specs proving cross-company access is forbidden, audit logs for suspicious access, and review similar endpoints for global `find` usage.

---

## 103. Scenario: Duplicate ticket purchases happen under load

### Root cause

Race condition.

Bad:

```ruby
if event.available_seats > 0
  event.update!(available_seats: event.available_seats - 1)
end
```

### Fix with lock

```ruby
Event.transaction do
  event = Event.lock.find(event_id)

  raise SoldOutError if event.available_seats <= 0

  event.update!(available_seats: event.available_seats - 1)
  Ticket.create!(event: event, user: user)
end
```

### Interview answer

I would enforce capacity at the database level using transactions and row-level locks or atomic conditional updates. I would also add idempotency keys so client retries do not create duplicate purchases.

---

## 104. Scenario: Background job sends duplicate emails

### Root cause

Job retries without idempotency.

Bad:

```ruby
RfiMailer.assigned(rfi).deliver_now
```

Better:

```ruby
return if NotificationLog.exists?(
  record: rfi,
  event: "rfi_assigned",
  recipient: rfi.assignee
)

RfiMailer.assigned(rfi).deliver_now

NotificationLog.create!(
  record: rfi,
  event: "rfi_assigned",
  recipient: rfi.assignee
)
```

Add unique index:

```ruby
add_index :notification_logs,
  [:record_type, :record_id, :event, :recipient_id],
  unique: true,
  name: "index_notification_logs_uniqueness"
```

### Interview answer

I would make the job idempotent using a notification log or unique constraint. Queue retries are normal, so the job must be safe to run more than once.

---

## 105. Scenario: A migration locked a large production table

### Safer approach

Use expand-contract:

1. Add nullable column.
2. Deploy code that writes it.
3. Backfill in batches.
4. Add default.
5. Add `NOT NULL`.
6. Remove old column later if needed.

### Interview answer

For large tables, I avoid blocking migrations. I add columns safely, backfill asynchronously or in batches, add indexes concurrently, and deploy changes in backward-compatible steps.

---

# Part 11 — Short Answers to Memorize

## MVC

MVC separates the app into models for data and business logic, views for presentation, and controllers for request/response coordination.

## ActiveRecord

ActiveRecord is Rails’ ORM. It maps database tables to Ruby classes and lets us query and update data using Ruby methods.

## Strong Parameters

Strong parameters protect against mass assignment by allowing only specific fields from request params.

## N+1

N+1 happens when loading a list of records causes one extra query per record for associations. I fix it with eager loading, usually `includes`.

## Transactions

A transaction groups database operations so they either all succeed or all roll back.

## Race Condition

A race condition happens when concurrent requests modify shared data incorrectly. I fix it using locks, constraints, atomic updates, or idempotency.

## Background Job

A background job moves slow work outside the request path, such as emails, file processing, reports, or external API sync.

## Idempotency

Idempotency means repeating the same operation does not duplicate side effects. It is critical for retries, payments, ticket purchases, and notifications.

## Multi-Tenancy

Multi-tenancy means one app serves multiple companies while isolating data. Always scope queries through the current tenant.

## GVL

MRI Ruby’s GVL allows only one Ruby thread to execute Ruby bytecode at a time per process. Threads still help I/O-bound Rails apps but not CPU-heavy Ruby code.

## Safe Migration

Safe migrations avoid long locks and are backward-compatible. Use expand-contract, batch backfills, and concurrent indexes.

## Observability

Observability means using logs, metrics, and traces to understand production behavior and debug issues quickly.

---

# Part 12 — Final Interview Checklist

## Basic

- Ruby objects
- Strings vs symbols
- Arrays and hashes
- Methods and implicit return
- Blocks
- Classes and objects
- Modules
- Exceptions
- MVC
- Routes
- Controllers
- Models
- Migrations
- Validations
- Associations
- Strong params

## Intermediate

- Rack and middleware
- Request lifecycle
- ActiveRecord relations
- Lazy loading
- N+1
- `includes`, `preload`, `eager_load`, `joins`
- `has_many :through`
- Polymorphic associations
- Transactions
- Callbacks
- `after_commit`
- Background jobs
- Caching
- SQL injection
- XSS
- Authentication vs authorization
- Request specs
- Service objects

## Advanced

- GVL
- Puma workers and threads
- Connection pool sizing
- Slow endpoint debugging
- Row locking
- Optimistic locking
- Deadlocks
- Index strategy
- Partial indexes
- Expression indexes
- `EXPLAIN ANALYZE`
- Safe migrations
- Query objects
- Policy objects
- Outbox pattern
- API idempotency
- Cursor pagination
- Multi-tenancy
- Structured logging
- Distributed tracing
- OpenTelemetry
- Production debugging

---

# Part 13 — Staff-Level Answer Template

When answering any advanced Rails question, use this format:

```text
1. First, explain the concept simply.
2. Then explain where it appears in Rails.
3. Then give a production example.
4. Then mention tradeoffs and failure modes.
5. Then explain how you would test or monitor it.
```

Example:

> For N+1 queries, the core issue is that we load parent records and then issue one query per child association. In Rails this often happens inside views or serializers. For a Procore-style RFI list, if we load RFIs and then call `rfi.project.name`, `rfi.assignee.name`, and `rfi.comments.count`, we can create many extra queries. I would fix it with `includes`, counter caches, or aggregate queries depending on the response. I would verify using Rails logs, Bullet, query count tests, and production APM traces.

---

# Part 14 — Procore-Style Practice Questions

Use these to practice aloud.

## Basic

1. Explain MVC using Projects and RFIs.
2. Explain Rails routes for nested project RFIs.
3. Explain ActiveRecord associations between Company, Project, User, and RFI.
4. Explain strong params for creating an RFI.
5. Explain validation vs database constraint.

## Intermediate

1. How would you fix N+1 queries in an RFI list?
2. Explain `includes` vs `joins` using RFIs and Projects.
3. How would you design `ProjectMembership` roles?
4. When would you use `has_many :through`?
5. When would you use a polymorphic attachment or comment?
6. Why should notification jobs be idempotent?
7. Why should emails be sent after commit?
8. How would you secure project-level data access?

## Advanced

1. How does GVL affect Rails performance?
2. How would you tune Puma for a Rails/Postgres app?
3. How do you debug a slow `/projects/:id/rfis` endpoint?
4. How do you prevent duplicate ticket purchases under load?
5. How do you design safe production migrations?
6. How do you prevent cross-tenant data leaks?
7. How would you implement API idempotency?
8. When would you use the outbox pattern?
9. How would you instrument Rails with OpenTelemetry?
10. How would you debug high DB CPU after a deploy?

---

# Sources and Context Used

This guide is based on our chat discussion plus public Procore-style domain context:

- Procore describes its platform as construction management software connecting field and office with real-time visibility.
- Procore project management materials mention tools such as RFIs, submittals, schedules, and document management.
- Procore developer documentation exposes project-level API concepts such as `project_id`, `Procore-Company-Id`, submittals, filtering, and pagination.
- Public job descriptions and job mirrors for Procore-related roles mention backend work with Ruby/Rails, React/TypeScript, PostgreSQL, AWS, Kubernetes, CI/CD, and service-oriented architecture.
- OpenTelemetry Ruby documentation and contrib libraries describe Ruby/Rails instrumentation for traces and observability.

Use these examples as realistic interview practice, not as a claim about Procore’s exact internal implementation.
