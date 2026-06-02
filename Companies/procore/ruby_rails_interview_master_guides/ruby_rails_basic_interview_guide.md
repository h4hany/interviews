# Ruby on Rails Interview Preparation — Basic Topics

**Prepared date:** 2026-06-02  
**Target:** Junior → Mid-level Rails interviews; useful foundation for Senior refresh  
**Format:** Question → Interview Category / Level → Answer → Ruby/Rails example → Interview tips/resources.

---

## Master deep-dive prompt

Copy this prompt to any AI when you want to go deeper on any question in this file:

```text
You are a Principal Ruby on Rails interviewer and Staff-level mentor.
I am preparing for Ruby on Rails interviews. I will give you one question from this guide.
Your task:
1. Explain the concept from first principles.
2. Give a real production Rails example.
3. Show Ruby/Rails code when useful.
4. Explain tradeoffs, edge cases, performance impact, security impact, and testing strategy.
5. Ask me 3 follow-up interview questions.
6. Give me a short answer version I can say in an interview.
7. Correct my answer if I respond.
Question: <PASTE QUESTION HERE>
```

---

## How to use this guide

Start here if you need to answer confidently without overcomplicating. For each question, practice a 60-second spoken answer, then read the code example aloud and explain why it works.

---

### Q1. What is Ruby and why is it popular with Rails?
**Interview category / level:** Junior / Ruby fundamentals

**Answer:**
Ruby is a dynamic, object-oriented language focused on developer happiness and readable code. Rails builds on Ruby by giving conventions for routing, controllers, models, views, database access, testing, and deployment. In interviews, emphasize readability, productivity, metaprogramming, blocks, and the rich ecosystem.

**Ruby/Rails example:**
```ruby
puts "Everything is an object"
puts 1.class
puts "hello".upcase
```

---


### Q2. What does “everything is an object” mean in Ruby?
**Interview category / level:** Junior / Ruby fundamentals

**Answer:**
It means values such as integers, strings, arrays, nil, true, false, classes, and modules are objects with methods. This makes Ruby consistent and expressive. Even `nil` has a class and methods, so Ruby code often relies on message passing rather than primitive operations.

**Ruby/Rails example:**
```ruby
puts 42.class       # Integer
puts nil.class      # NilClass
puts true.class     # TrueClass
puts "rails".methods.grep(/upcase/)
```

---


### Q3. What is the difference between a String and a Symbol?
**Interview category / level:** Junior / Ruby fundamentals

**Answer:**
A String is mutable text data. A Symbol is an immutable identifier. Use strings for user input/content and symbols for stable keys, enum-like values, method names, and options. Modern Ruby garbage-collects many dynamic symbols, but creating symbols from untrusted user input is still something to avoid unless needed.

**Ruby/Rails example:**
```ruby
name = "status"
status = :active
puts name.object_id == "status".object_id # usually false
puts status.object_id == :active.object_id # true
```

---


### Q4. What are arrays and hashes in Ruby?
**Interview category / level:** Junior / Ruby fundamentals

**Answer:**
Arrays store ordered lists. Hashes store key-value pairs. Rails uses hashes heavily for params, configuration, JSON-like data, and keyword arguments. Interviewers expect you to know common methods like `map`, `select`, `find`, `each_with_object`, `group_by`, and `tally`.

**Ruby/Rails example:**
```ruby
trades = ["plumbing", "electrical"]
worker = { email: "a@example.com", cost: 100 }
puts trades.first
puts worker[:email]
```

---


### Q5. What is the difference between `map`, `select`, `find`, and `each`?
**Interview category / level:** Junior / Ruby enumerable

**Answer:**
`each` iterates for side effects and returns the original collection. `map` transforms each item and returns a new array. `select` filters items that match a condition. `find` returns the first matching item. In interviews, use these instead of manual loops when they communicate intent clearly.

**Ruby/Rails example:**
```ruby
nums = [1, 2, 3, 4]
p nums.map { |n| n * 2 }
p nums.select(&:even?)
p nums.find { |n| n > 2 }
nums.each { |n| puts n }
```

---


### Q6. What is a block in Ruby?
**Interview category / level:** Junior / Ruby fundamentals

**Answer:**
A block is a chunk of code passed to a method. Blocks are central to Ruby because many methods yield control to caller-provided logic. Rails DSLs, iterators, transactions, routes, and callbacks all use blocks.

**Ruby/Rails example:**
```ruby
def around
  puts "before"
  yield if block_given?
  puts "after"
end

around { puts "inside" }
```

---


### Q7. What is the difference between `nil`, `false`, and truthy values in Ruby?
**Interview category / level:** Junior / Ruby fundamentals

**Answer:**
Only `nil` and `false` are falsey in Ruby. Everything else is truthy, including `0`, empty strings, and empty arrays. This is a common interview trick because it differs from JavaScript and some other languages.

**Ruby/Rails example:**
```ruby
puts "0 is truthy" if 0
puts "empty string is truthy" if ""
puts "empty array is truthy" if []
```

---


### Q8. What are classes and objects in Ruby?
**Interview category / level:** Junior / OOP

**Answer:**
A class defines behavior and data structure. An object is an instance of a class. Rails models, controllers, jobs, mailers, and services are classes. Good interview answers connect OOP to encapsulation, explicit responsibilities, and testability.

**Ruby/Rails example:**
```ruby
class Worker
  attr_reader :email
  def initialize(email)
    @email = email
  end
end

worker = Worker.new("a@example.com")
puts worker.email
```

---


### Q9. What is `attr_reader`, `attr_writer`, and `attr_accessor`?
**Interview category / level:** Junior / Ruby OOP

**Answer:**
`attr_reader` creates getter methods, `attr_writer` creates setter methods, and `attr_accessor` creates both. Prefer `attr_reader` by default to avoid allowing uncontrolled mutation.

**Ruby/Rails example:**
```ruby
class Worker
  attr_reader :email
  attr_accessor :cost
  def initialize(email, cost)
    @email = email
    @cost = cost
  end
end
```

---


### Q10. What is inheritance in Ruby?
**Interview category / level:** Junior / OOP

**Answer:**
Inheritance lets a class reuse behavior from a parent class. Use it when a subclass truly is a specialized form of the parent. In Rails, `ApplicationRecord < ActiveRecord::Base` and `ApplicationController < ActionController::Base` are common examples. Overusing inheritance can create rigid designs.

**Ruby/Rails example:**
```ruby
class Animal
  def speak
    "sound"
  end
end

class Dog < Animal
  def speak
    "woof"
  end
end
```

---


### Q11. What are modules and mixins?
**Interview category / level:** Junior / OOP

**Answer:**
A module groups reusable behavior. Including a module adds instance methods; extending a module adds class methods. Use modules for small shared behavior, not for hiding large business workflows.

**Ruby/Rails example:**
```ruby
module Archivable
  def archive!
    @archived = true
  end
end

class Document
  include Archivable
end

Document.new.archive!
```

---


### Q12. What is the difference between `include` and `extend`?
**Interview category / level:** Junior / Ruby modules

**Answer:**
`include` adds module methods as instance methods. `extend` adds module methods as methods on the class/object itself. In Rails concerns, `included` and `class_methods` help organize both.

**Ruby/Rails example:**
```ruby
module Searchable
  def search
    "instance search"
  end
end

class Project
  include Searchable
end

p Project.new.search
```

---


### Q13. What is MVC in Rails?
**Interview category / level:** Junior / Rails fundamentals

**Answer:**
MVC means Model, View, Controller. The controller receives the request, coordinates application behavior, asks models for data/domain logic, and returns a response or view. The model represents data and domain rules. The view renders output. For APIs, serializers often replace traditional HTML views.

**Ruby/Rails example:**
```ruby
class ProjectsController < ApplicationController
  def show
    @project = Project.find(params[:id])
    render json: @project
  end
end
```

---


### Q14. What is ActiveRecord?
**Interview category / level:** Junior / Rails fundamentals

**Answer:**
ActiveRecord is Rails’ ORM. It maps database tables to Ruby classes and rows to Ruby objects. It provides querying, validations, associations, callbacks, migrations, and transactions. In interviews, mention that it is powerful but you must understand SQL and performance.

**Ruby/Rails example:**
```ruby
class Project < ApplicationRecord
  has_many :tasks
  validates :name, presence: true
end

Project.where(status: "active").limit(10)
```

**Resources:**
- Rails Active Record Query Interface: https://guides.rubyonrails.org/active_record_querying.html

---


### Q15. What is a Rails migration?
**Interview category / level:** Junior / Rails database

**Answer:**
A migration changes the database schema over time using Ruby files. Common migrations create tables, add columns, add indexes, and add constraints. In production, migrations must be safe, especially on large tables.

**Ruby/Rails example:**
```ruby
class AddStatusToTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks, :status, :string, null: false, default: "open"
    add_index :tasks, [:project_id, :status]
  end
end
```

**Resources:**
- Rails Active Record Migrations: https://guides.rubyonrails.org/active_record_migrations.html

---


### Q16. What are Rails validations?
**Interview category / level:** Junior / Rails models

**Answer:**
Validations check model data before saving. They provide user-friendly errors. They are not a replacement for database constraints because validations can race under concurrency.

**Ruby/Rails example:**
```ruby
class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
end
```

---


### Q17. Why should uniqueness validation also have a unique database index?
**Interview category / level:** Junior-to-Mid / Rails database correctness

**Answer:**
Rails uniqueness validation is an application-level check. Two concurrent requests can both pass validation before either commits. A unique database index is the final protection against duplicates.

**Ruby/Rails example:**
```ruby
class AddUniqueIndexToUsersEmail < ActiveRecord::Migration[7.1]
  def change
    add_index :users, :email, unique: true
  end
end
```

---


### Q18. What are Rails associations?
**Interview category / level:** Junior / Rails models

**Answer:**
Associations define relationships between models, such as `belongs_to`, `has_many`, `has_one`, and `has_many :through`. They make navigation easier but can create N+1 queries if used carelessly.

**Ruby/Rails example:**
```ruby
class Project < ApplicationRecord
  has_many :tasks
end

class Task < ApplicationRecord
  belongs_to :project
end
```

**Resources:**
- Rails Association Basics: https://guides.rubyonrails.org/association_basics.html

---


### Q19. What is `has_many :through`?
**Interview category / level:** Junior / Rails associations

**Answer:**
It models a many-to-many relationship through a join model that can also hold extra data. Prefer it over HABTM when the relationship has attributes such as role, assigned_at, or status.

**Ruby/Rails example:**
```ruby
class Project < ApplicationRecord
  has_many :project_memberships
  has_many :users, through: :project_memberships
end
```

---


### Q20. What is routing in Rails?
**Interview category / level:** Junior / Rails fundamentals

**Answer:**
Routing maps HTTP requests to controller actions. RESTful routes use standard verbs: GET for read, POST for create, PATCH/PUT for update, DELETE for delete.

**Ruby/Rails example:**
```ruby
Rails.application.routes.draw do
  resources :projects do
    resources :tasks
  end
end
```

---


### Q21. What are strong parameters?
**Interview category / level:** Junior / Rails security

**Answer:**
Strong parameters whitelist which request parameters can be used for mass assignment. They protect against users submitting fields like `admin: true` unless explicitly permitted.

**Ruby/Rails example:**
```ruby
def task_params
  params.require(:task).permit(:title, :description, :due_date)
end
```

---


### Q22. What is a Rails controller responsible for?
**Interview category / level:** Junior / Rails fundamentals

**Answer:**
A controller should handle HTTP concerns: authorization, request parameters, calling domain logic, and rendering a response. It should not contain complex business logic, long database workflows, or external API orchestration.

**Ruby/Rails example:**
```ruby
class TasksController < ApplicationController
  def create
    task = Tasks::CreateService.call(project: current_project, params: task_params)
    render json: task, status: :created
  end
end
```

---


### Q23. What is the difference between `render` and `redirect_to`?
**Interview category / level:** Junior / Rails controllers

**Answer:**
`render` returns a response body for the current request. `redirect_to` sends a 3xx response telling the browser/client to make a new request to another URL.

**Ruby/Rails example:**
```ruby
def create
  if @task.save
    redirect_to @task
  else
    render :new, status: :unprocessable_entity
  end
end
```

---


### Q24. What is a partial in Rails views?
**Interview category / level:** Junior / Rails views

**Answer:**
A partial is a reusable view fragment. In API-only Rails apps you may not use them often, but in full-stack Rails they help reuse UI pieces. Overusing partials with database access can cause performance problems.

**Ruby/Rails example:**
```ruby
<%# app/views/tasks/_task.html.erb %>
<li><%= task.title %></li>
```

---


### Q25. What is ActiveJob?
**Interview category / level:** Junior / Rails background jobs

**Answer:**
ActiveJob is Rails’ abstraction for background jobs. It lets you enqueue work and run it through adapters such as Sidekiq, Solid Queue, Resque, or Delayed Job.

**Ruby/Rails example:**
```ruby
class SendWelcomeEmailJob < ApplicationJob
  queue_as :default
  def perform(user_id)
    UserMailer.welcome(User.find(user_id)).deliver_now
  end
end
```

---


### Q26. What is the difference between `deliver_now` and `deliver_later`?
**Interview category / level:** Junior / Rails mailers

**Answer:**
`deliver_now` sends synchronously in the current process. `deliver_later` enqueues a background job. In production request paths, prefer `deliver_later` so email latency does not slow the user response.

**Ruby/Rails example:**
```ruby
UserMailer.welcome(user).deliver_later
```

---


### Q27. What is a service object?
**Interview category / level:** Junior-to-Mid / Rails architecture

**Answer:**
A service object represents a use case or workflow that coordinates multiple models or external systems. It keeps controllers thin and makes complex behavior easier to test.

**Ruby/Rails example:**
```ruby
module Tasks
  class CloseService
    def self.call(task:, actor:)
      task.update!(status: "closed", closed_by: actor)
    end
  end
end
```

---


### Q28. What is the difference between authentication and authorization?
**Interview category / level:** Junior / Security

**Answer:**
Authentication answers: who are you? Authorization answers: what are you allowed to do? In Rails, authentication might use Devise/JWT/session cookies, while authorization might use Pundit/CanCanCan/custom policies.

**Ruby/Rails example:**
```ruby
class TaskPolicy
  def update?
    user.admin? || record.assignee_id == user.id
  end
end
```

---


### Q29. What is CSRF protection?
**Interview category / level:** Junior / Rails security

**Answer:**
CSRF protection prevents malicious websites from making authenticated browser requests on behalf of a user. Rails adds authenticity tokens to forms and verifies them on non-GET requests. API-only apps often use token-based authentication instead.

**Resources:**
- Rails Security Guide: https://guides.rubyonrails.org/security.html

---


### Q30. What is SQL injection and how does Rails help prevent it?
**Interview category / level:** Junior / Security

**Answer:**
SQL injection happens when untrusted input is inserted into SQL as executable code. ActiveRecord parameter binding protects you when you use placeholders or hash conditions. Avoid string interpolation in SQL fragments.

**Ruby/Rails example:**
```ruby
safe = User.where("email = ?", params[:email])
unsafe = User.where("email = '#{params[:email]}'")
```

---


### Q31. What is the Rails console used for?
**Interview category / level:** Junior / Rails tools

**Answer:**
Rails console lets you inspect and interact with your app in a Rails environment. In production, use it carefully because commands can trigger callbacks, external integrations, and data changes.

**Ruby/Rails example:**
```ruby
rails console
Project.find(1).tasks.count
```

---


### Q32. What is a model callback?
**Interview category / level:** Junior-to-Mid / Rails models

**Answer:**
A callback runs at a lifecycle event such as before validation, after save, or after commit. Use callbacks carefully. They are useful for local model invariants but dangerous for hidden external side effects.

**Ruby/Rails example:**
```ruby
class User < ApplicationRecord
  before_validation :normalize_email
  private
  def normalize_email
    self.email = email.to_s.downcase.strip
  end
end
```

---


### Q33. What is `after_commit` and why is it important?
**Interview category / level:** Junior-to-Mid / Rails transactions

**Answer:**
`after_commit` runs only after the database transaction has successfully committed. It is safer for enqueueing jobs or sending notifications than `after_save`, because jobs should not see uncommitted data.

**Ruby/Rails example:**
```ruby
class Task < ApplicationRecord
  after_commit :enqueue_notification, on: :create
  def enqueue_notification
    NotifyTaskCreatedJob.perform_later(id)
  end
end
```

---


### Q34. What is the difference between `destroy` and `delete`?
**Interview category / level:** Junior-to-Mid / Rails models

**Answer:**
`destroy` instantiates records and runs callbacks/dependent destroys. `delete` removes rows directly and skips callbacks. Use `destroy` when cleanup logic matters; use `delete` only when intentionally bypassing callbacks.

**Ruby/Rails example:**
```ruby
task.destroy
Task.where(project_id: project.id).delete_all
```

---


### Q35. What is `scope` in ActiveRecord?
**Interview category / level:** Junior / Rails querying

**Answer:**
A scope is a reusable query fragment that returns an ActiveRecord relation. Scopes should be composable and not execute queries immediately.

**Ruby/Rails example:**
```ruby
class Task < ApplicationRecord
  scope :open, -> { where(status: "open") }
  scope :overdue, -> { where("due_date < ?", Date.current) }
end
```

---


### Q36. What is the difference between `count`, `size`, and `length`?
**Interview category / level:** Junior-to-Mid / Rails querying

**Answer:**
`count` usually asks the database. `length` loads the records and counts in Ruby. `size` uses loaded records if present, otherwise asks the database. This matters for performance.

**Ruby/Rails example:**
```ruby
tasks = project.tasks
puts tasks.count
puts tasks.size
puts tasks.length
```

---


### Q37. What is `pluck` and why is it useful?
**Interview category / level:** Junior-to-Mid / Rails querying

**Answer:**
`pluck` selects specific columns and returns raw values without instantiating ActiveRecord objects. Use it for simple lists or IDs when you do not need model behavior.

**Ruby/Rails example:**
```ruby
emails = User.where(active: true).pluck(:email)
```

---


### Q38. What are fixtures and factories?
**Interview category / level:** Junior / Testing

**Answer:**
Fixtures are predefined test records loaded by Rails. Factories, commonly with FactoryBot, create flexible test objects. For interviews, know how to write tests that focus on behavior and avoid slow, overbuilt data setup.

**Ruby/Rails example:**
```ruby
RSpec.describe User do
  it "requires email" do
    user = User.new(email: nil)
    expect(user).not_to be_valid
  end
end
```

---


### Q39. What is RSpec request spec?
**Interview category / level:** Junior-to-Mid / Testing

**Answer:**
A request spec tests your API/controller behavior through HTTP-like requests. It is usually better than old controller specs because it exercises routing, middleware, params, and response behavior together.

**Ruby/Rails example:**
```ruby
RSpec.describe "Tasks API", type: :request do
  it "creates task" do
    post "/projects/1/tasks", params: { task: { title: "Fix door" } }
    expect(response).to have_http_status(:created)
  end
end
```

---


## Core resources used / recommended

- Rails Guides — Active Record Query Interface: https://guides.rubyonrails.org/active_record_querying.html
- Rails Guides — Active Record Associations: https://guides.rubyonrails.org/association_basics.html
- Rails Guides — Active Record Validations: https://guides.rubyonrails.org/active_record_validations.html
- Rails Guides — Active Record Callbacks: https://guides.rubyonrails.org/active_record_callbacks.html
- Rails Guides — Active Record Migrations: https://guides.rubyonrails.org/active_record_migrations.html
- Rails Guides — Securing Rails Applications: https://guides.rubyonrails.org/security.html
- Rails Guides — Testing Rails Applications: https://guides.rubyonrails.org/testing.html
- Rails Guides — Active Job Basics: https://guides.rubyonrails.org/active_job_basics.html
- Rails Guides — Active Support Instrumentation: https://guides.rubyonrails.org/active_support_instrumentation.html
- OpenTelemetry Ruby instrumentation: https://opentelemetry.io/docs/languages/ruby/instrumentation/
- OpenTelemetry Ruby getting started: https://opentelemetry.io/docs/languages/ruby/getting-started/
- Ruby Fiber scheduler docs: https://docs.ruby-lang.org/en/3.4/fiber_md.html
- PostgreSQL EXPLAIN docs: https://www.postgresql.org/docs/current/sql-explain.html
- PostgreSQL using EXPLAIN: https://www.postgresql.org/docs/current/using-explain.html
