# Ruby on Rails Interview Master Guide

Prepared for interview revision. This guide merges the uploaded Rails Q&A, improves unclear answers, fixes duplicates/wording, adds interview grade levels, and expands the list with deeper Senior, Staff, and Principal-level questions.

## How to use this guide

- **Junior**: fundamentals, Rails conventions, basic CRUD, validations, associations.
- **Mid-level**: query behavior, callbacks, background jobs, testing, API patterns, performance basics.
- **Senior**: architecture, scalability, transactions, security, observability, production debugging.
- **Staff**: cross-service design, reliability, migration strategy, ownership of system-wide tradeoffs.
- **Principal**: organization-level architecture, platform strategy, long-term maintainability, risk management.

Use each answer as a base. In interviews, add examples from your own projects: receipts, cashback, scraping pipelines, IoT truck loading, semantic search, background reporting, and Rails refactoring.

---

# Section 1: Rails Fundamentals

## 1. What is the difference between `render` and `redirect_to`?

**Grade:** Junior  
**Weight:** 10

**Answer:**

`render` tells Rails to build a response using a template, JSON, plain text, or another response body without making a new HTTP request. The browser URL usually stays the same because the same request is being completed.

`redirect_to` sends an HTTP redirect response, usually `302`, telling the browser or client to make a new request to another URL or action. This changes the request cycle and usually changes the browser URL.

In a traditional Rails HTML app, `redirect_to` is common after successful create/update/delete actions to avoid duplicate form submissions. In APIs, `render json:` is usually preferred because API clients expect a structured response, not a browser navigation.

**Example:**

```ruby
class PostsController < ApplicationController
  def create
    @post = Post.new(post_params)

    if @post.save
      redirect_to @post, notice: "Post created"
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

**Interview tip:**

Say: "`render` completes the current request. `redirect_to` starts a new request. For failed validations I usually render the form again with `422`; after success I redirect to avoid resubmission."

---

## 2. Explain the Rails MVC structure.

**Grade:** Junior  
**Weight:** 9

**Answer:**

Rails follows the Model-View-Controller pattern.

- **Model:** Represents domain data and business rules. In Rails this is usually an `ApplicationRecord` model backed by a database table.
- **View:** Represents the user interface or response format, such as ERB, JSON, or Turbo Stream.
- **Controller:** Receives the request, calls application/domain logic, prepares data, and returns a response.

A good Rails application keeps controllers thin, avoids putting database-heavy logic in views, and keeps business decisions close to the domain layer.

**Example:**

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
end

class ArticlesController < ApplicationController
  def show
    @article = Article.find(params[:id])
  end
end
```

**Interview tip:**

For senior roles, don't stop at definitions. Add that MVC is a starting point, but complex apps usually need service objects, form objects, query objects, policies, domain models, jobs, and events.

---

## 3. What is the purpose of `before_action` in Rails?

**Grade:** Junior  
**Weight:** 9

**Answer:**

`before_action` runs a method before one or more controller actions. It is commonly used for authentication, authorization setup, loading shared resources, or enforcing request requirements.

**Example:**

```ruby
class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: %i[show edit update destroy]

  def show
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end
end
```

**Best practices:**

Use `before_action` for request-level concerns, not hidden business workflows. Too many callbacks in controllers can make execution flow hard to follow.

---

## 4. How do you use concerns in Rails?

**Grade:** Junior to Mid-level  
**Weight:** 10

**Answer:**

Concerns are modules used to share behavior between models or controllers. Rails commonly places them in `app/models/concerns` or `app/controllers/concerns`. They usually use `ActiveSupport::Concern` to make included blocks and class methods cleaner.

**Example:**

```ruby
# app/models/concerns/publishable.rb
module Publishable
  extend ActiveSupport::Concern

  included do
    scope :published, -> { where(published: true) }
  end

  def publish!
    update!(published: true, published_at: Time.current)
  end
end

class Article < ApplicationRecord
  include Publishable
end
```

**Best practices:**

Concerns should be small and focused. If a concern becomes a large bucket of business logic, extract a domain object, service object, or explicit module with a clear name.

**Interview tip:**

Say: "I use concerns for reusable horizontal behavior, not as a dumping ground for unrelated model logic."

---

## 5. What is the purpose of `has_secure_password`?

**Grade:** Junior to Mid-level  
**Weight:** 8

**Answer:**

`has_secure_password` adds password handling to a model. It stores a password digest, uses BCrypt, adds password/password_confirmation behavior, and provides `authenticate` to verify a password.

The database table needs a `password_digest` column.

**Example:**

```ruby
class User < ApplicationRecord
  has_secure_password
end

user = User.create!(email: "user@example.com", password: "secret123")
user.authenticate("secret123") # returns user
user.authenticate("wrong")     # returns false
```

**Security note:**

Never store plain text passwords. Also combine password security with rate limiting, secure sessions, CSRF protection, password reset flows, and proper secrets management.

---

## 6. How do you use scopes in Rails models?

**Grade:** Junior  
**Weight:** 7

**Answer:**

Scopes define reusable query fragments on models. They return `ActiveRecord::Relation`, so they can be chained.

**Example:**

```ruby
class Post < ApplicationRecord
  scope :published, -> { where(published: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_author, ->(author_id) { where(author_id: author_id) }
end

Post.published.recent.by_author(5)
```

**Best practices:**

Keep scopes composable. Avoid scopes that return arrays because that breaks chaining. Use class methods when the logic is complex or may return something other than a relation.

---

## 7. What is the difference between a scope and a class method?

**Grade:** Mid-level  
**Weight:** 4

**Answer:**

A `scope` is syntax for defining reusable Active Record queries, usually returning a relation. A class method is more flexible and can return a relation, object, array, hash, or any result.

**Example:**

```ruby
class Order < ApplicationRecord
  scope :paid, -> { where(status: "paid") }

  def self.revenue_for_month(month)
    paid.where(created_at: month.all_month).sum(:total_cents)
  end
end
```

Use scopes for simple chainable query fragments. Use class methods or query objects for more complex logic.

---

## 8. What is a Rails migration?

**Grade:** Junior  
**Weight:** 3

**Answer:**

A migration is Ruby code used to evolve the database schema over time. It can create tables, add columns, add indexes, rename columns, and remove database objects.

**Example:**

```ruby
class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :body
      t.timestamps
    end

    add_index :posts, :title
  end
end
```

**Senior note:**

For production systems, migrations must be safe, reversible where possible, and designed to avoid long locks. Large data backfills should often be separated from schema changes.

---

## 9. What is the purpose of validations in Rails?

**Grade:** Junior  
**Weight:** 1

**Answer:**

Validations ensure model data is valid before it is saved. Common validations include presence, length, format, numericality, inclusion, and uniqueness.

**Example:**

```ruby
class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :age, numericality: { greater_than_or_equal_to: 18 }
end
```

**Important:**

Application-level uniqueness validation is not enough under concurrency. Add a unique database index for true protection.

---

## 10. What is the difference between `validates` and `validates!`?

**Grade:** Mid-level  
**Weight:** 5

**Answer:**

`validates` adds normal validations. If validation fails, methods like `save` return `false` and methods like `save!` raise an exception.

`validates!` creates a strict validation. When it fails, Rails raises an exception instead of adding a normal validation error.

**Example:**

```ruby
class User < ApplicationRecord
  validates :email, presence: true
  validates! :role, inclusion: { in: %w[admin member] }
end
```

Use strict validations carefully. They are useful for invariants that should never be silently handled as user input errors.

---

# Section 2: Associations

## 11. What is the purpose of `has_many` and `belongs_to`?

**Grade:** Junior  
**Weight:** 7

**Answer:**

`has_many` defines a one-to-many relationship from the parent side. `belongs_to` defines the child side, usually where the foreign key exists.

**Example:**

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :destroy
end

class Book < ApplicationRecord
  belongs_to :author
end
```

Here, `books` table usually has `author_id`.

---

## 12. What is the difference between `belongs_to` and `has_one`?

**Grade:** Junior to Mid-level  
**Weight:** 4

**Answer:**

Both can describe one-to-one relationships, but the foreign key location is different.

- `belongs_to` is used on the model that owns the foreign key.
- `has_one` is used on the model that is referenced by the foreign key.

**Example:**

```ruby
class User < ApplicationRecord
  has_one :profile
end

class Profile < ApplicationRecord
  belongs_to :user
end
```

The `profiles` table has `user_id`.

---

## 13. What is `has_and_belongs_to_many`?

**Grade:** Junior to Mid-level  
**Weight:** 6

**Answer:**

`has_and_belongs_to_many`, or HABTM, defines a many-to-many relationship using a join table without a join model.

**Example:**

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :roles
end

class Role < ApplicationRecord
  has_and_belongs_to_many :users
end
```

**When to avoid it:**

If the relationship needs extra fields, validations, callbacks, timestamps, ownership, or business behavior, prefer `has_many :through`.

---

## 14. What is the difference between `has_many` and `has_many :through`?

**Grade:** Junior to Mid-level  
**Weight:** 4

**Answer:**

`has_many` defines a direct one-to-many relationship. `has_many :through` defines an indirect relationship through another model, often for many-to-many relationships.

**Example:**

```ruby
class Doctor < ApplicationRecord
  has_many :appointments
  has_many :patients, through: :appointments
end

class Appointment < ApplicationRecord
  belongs_to :doctor
  belongs_to :patient
end

class Patient < ApplicationRecord
  has_many :appointments
  has_many :doctors, through: :appointments
end
```

Use `has_many :through` when the join itself has meaning, such as `appointment_date`, `status`, or `notes`.

---

## 15. What is `accepts_nested_attributes_for`?

**Grade:** Mid-level  
**Weight:** 4

**Answer:**

`accepts_nested_attributes_for` allows a parent model to create or update associated records through nested parameters.

**Example:**

```ruby
class Author < ApplicationRecord
  has_many :books
  accepts_nested_attributes_for :books, allow_destroy: true
end
```

**Controller params example:**

```ruby
def author_params
  params.require(:author).permit(
    :name,
    books_attributes: %i[id title _destroy]
  )
end
```

**Best practices:**

Use it for simple nested forms. For complex workflows, use form objects or service objects to avoid making models responsible for too much UI-specific behavior.

---

## 16. What is the difference between `dependent: :destroy` and `dependent: :delete_all`?

**Grade:** Mid-level  
**Weight:** 5

**Answer:**

`dependent: :destroy` loads and destroys each associated record, running callbacks and dependent logic. It is safer when child records have cleanup logic.

`dependent: :delete_all` deletes matching rows directly in SQL without instantiating records or running callbacks. It is faster but skips model-level cleanup.

**Example:**

```ruby
class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :page_views, dependent: :delete_all
end
```

**Interview tip:**

Say: "I use `destroy` when callbacks matter and `delete_all` for simple dependent data where database-level deletion is enough."

---

## 17. What are `inverse_of` and `foreign_key` in associations?

**Grade:** Senior  
**Weight:** 1

**Answer:**

`foreign_key` tells Rails which database column connects the association. `inverse_of` tells Rails the inverse association so it can keep objects consistent in memory and sometimes avoid extra queries.

**Example:**

```ruby
class User < ApplicationRecord
  has_many :posts, inverse_of: :author
end

class Post < ApplicationRecord
  belongs_to :author, class_name: "User", foreign_key: "user_id", inverse_of: :posts
end
```

This is useful when association names do not follow Rails conventions.

---

# Section 3: Active Record Queries and Performance

## 18. What is an N+1 query and how do you avoid it?

**Grade:** Mid-level  
**Weight:** 10

**Answer:**

An N+1 query happens when the app loads a list of records, then runs an extra query for each record's association.

**Bad example:**

```ruby
posts = Post.all
posts.each do |post|
  puts post.author.name
end
```

This runs one query for posts, then one query per post for authors.

**Fixed example:**

```ruby
posts = Post.includes(:author)
posts.each do |post|
  puts post.author.name
end
```

**How to detect:**

Use logs, Bullet gem in development, APM traces, slow query dashboards, and database query counts in tests.

---

## 19. What is the difference between `includes`, `joins`, `preload`, and `eager_load`?

**Grade:** Senior  
**Weight:** 8

**Answer:**

- `joins`: Adds an SQL `INNER JOIN`. Useful for filtering/sorting by associated tables. It does not preload associated records.
- `left_outer_joins`: Adds a `LEFT OUTER JOIN` for filtering while preserving records without matches.
- `includes`: Lets Rails decide whether to use separate queries or a join. Commonly used to avoid N+1 queries.
- `preload`: Always loads associations using separate queries.
- `eager_load`: Always uses a `LEFT OUTER JOIN` and loads associations in one joined query.

**Examples:**

```ruby
Post.joins(:comments).where(comments: { approved: true })
Post.includes(:author)
Post.preload(:comments)
Post.eager_load(:comments)
```

**Interview tip:**

Say: "I use `joins` to filter, `includes` to avoid N+1, `preload` when I want separate queries, and `eager_load` when I intentionally want a join-based eager load."

---

## 20. What is the difference between `find`, `find_by`, and `where`?

**Grade:** Junior to Mid-level  
**Weight:** 7

**Answer:**

- `find(id)` searches by primary key and raises `ActiveRecord::RecordNotFound` if missing.
- `find_by(...)` returns the first matching record or `nil`.
- `where(...)` returns an `ActiveRecord::Relation`, which can be chained and lazily executed.

**Example:**

```ruby
User.find(1)
User.find_by(email: "test@example.com")
User.where(active: true).order(created_at: :desc)
```

---

## 21. What is the difference between `pluck` and `select`?

**Grade:** Mid-level  
**Weight:** 6

**Answer:**

`pluck` directly returns values from the database as arrays without building Active Record objects.

`select` returns Active Record objects with only selected columns loaded.

**Example:**

```ruby
User.pluck(:email)
# => ["a@example.com", "b@example.com"]

User.select(:id, :email)
# => [#<User id: 1, email: "a@example.com">]
```

Use `pluck` when you only need raw values. Use `select` when you still need model objects.

---

## 22. What is the difference between `count`, `length`, and `size`?

**Grade:** Mid-level  
**Weight:** 6

**Answer:**

- `count`: Runs a SQL `COUNT` query.
- `length`: Loads records into memory and counts them.
- `size`: Uses loaded records if available; otherwise may run `COUNT`.

**Example:**

```ruby
users = User.where(active: true)
users.count  # SQL count
users.length # loads records then counts
users.size   # smart behavior depending on loaded state
```

**Interview tip:**

In performance-sensitive code, be intentional. Accidentally using `length` on a large relation can load too much data.

---

## 23. What is the difference between `first`, `last`, and `take`?

**Grade:** Junior to Mid-level  
**Weight:** 6

**Answer:**

- `first`: Returns the first record according to order or primary key.
- `last`: Returns the last record according to order or primary key.
- `take`: Returns a record without guaranteed order, often faster when order does not matter.

**Example:**

```ruby
User.first
User.last
User.take
```

Use explicit `order` when result order matters.

---

## 24. What is the difference between `present?` and `exists?`?

**Grade:** Mid-level  
**Weight:** 2

**Answer:**

`present?` checks whether an object is not blank. On an Active Record relation, it may load records.

`exists?` checks existence using a database query and is usually more efficient.

**Example:**

```ruby
User.where(email: email).present? # may load records
User.exists?(email: email)        # efficient existence check
```

Use `exists?` when you only need to know if a record exists.

---

## 25. What is the difference between `merge` and `joins`?

**Grade:** Senior  
**Weight:** 2

**Answer:**

`joins` adds a SQL join. `merge` applies conditions from another Active Record relation.

**Example:**

```ruby
class Comment < ApplicationRecord
  scope :approved, -> { where(approved: true) }
end

Post.joins(:comments).merge(Comment.approved)
```

This keeps query logic reusable and avoids duplicating conditions across models.

---

## 26. What is the difference between `reload` and association `reset`?

**Grade:** Mid-level  
**Weight:** 2

**Answer:**

`reload` reloads a record from the database and discards unsaved changes.

Association `reset` clears the association cache so the next access reloads the association.

**Example:**

```ruby
user.reload
user.posts.reset
```

Use these when cached model state may be stale.

---

## 27. How would you optimize a slow Rails endpoint?

**Grade:** Senior  
**Weight:** 10

**Answer:**

Start with measurement, not guessing.

A strong process:

1. Reproduce the slow request.
2. Check logs/APM traces for total time, database time, view time, external service time, and job enqueue time.
3. Look for N+1 queries, missing indexes, large payloads, expensive serialization, slow third-party calls, and memory allocation problems.
4. Add or adjust indexes after checking query plans.
5. Use pagination, caching, background jobs, batching, or precomputed tables where appropriate.
6. Add tests or monitoring to prevent regression.

**Example fixes:**

```ruby
# Before
orders = Order.where(user_id: params[:user_id])

# After adding index and eager loading
orders = Order.includes(:line_items, :payment)
              .where(user_id: params[:user_id])
              .order(created_at: :desc)
              .limit(50)
```

**Interview tip:**

Mention tradeoffs. Caching can hide slow code but adds invalidation complexity. Indexes speed reads but slow writes and consume storage.

---

# Section 4: Persistence Methods and Callbacks

## 28. What is the difference between `save`, `save!`, `create`, and `create!`?

**Grade:** Junior to Mid-level  
**Weight:** 8

**Answer:**

- `save`: Saves an existing/new object and returns `true` or `false`.
- `save!`: Saves and raises an exception if validation or persistence fails.
- `create`: Initializes and saves a new record, returning the object even if invalid.
- `create!`: Initializes and saves, raising an exception on failure.

**Example:**

```ruby
user = User.new(email: "a@example.com")
user.save
user.save!

User.create(email: "a@example.com")
User.create!(email: "a@example.com")
```

**Interview tip:**

Use bang methods when failure is exceptional and should rollback a transaction. Use non-bang methods when you need to show validation errors to users.

---

## 29. What is the difference between `update` and `update_attributes`?

**Grade:** Junior  
**Weight:** 7

**Answer:**

`update` updates attributes and saves the record, returning `true` or `false`.

`update_attributes` was an older alias and has been deprecated/removed in modern Rails versions. Use `update`.

**Example:**

```ruby
user.update(name: "Jane")
```

---

## 30. What is the difference between `update_column` and `update_columns`?

**Grade:** Mid-level  
**Weight:** 3

**Answer:**

Both update the database directly and skip validations and callbacks.

- `update_column`: Updates one column.
- `update_columns`: Updates multiple columns.

**Example:**

```ruby
user.update_column(:last_seen_at, Time.current)
user.update_columns(name: "John", updated_at: Time.current)
```

Use carefully because validations, callbacks, and normal lifecycle logic are skipped.

---

## 31. What is the difference between `touch` and `update_attribute`?

**Grade:** Mid-level  
**Weight:** 3

**Answer:**

`touch` updates timestamp columns like `updated_at` and optionally another time column.

`update_attribute` updates a single attribute, skips validations, but runs callbacks.

**Example:**

```ruby
user.touch
user.touch(:last_seen_at)
user.update_attribute(:active, false)
```

Prefer `update` unless you intentionally need the special behavior.

---

## 32. What is the difference between `delete` and `destroy`?

**Grade:** Junior to Mid-level  
**Weight:** 3

**Answer:**

`delete` removes a row directly from the database without callbacks.

`destroy` instantiates the record and runs callbacks before deleting.

**Example:**

```ruby
user.delete
user.destroy
```

Use `destroy` when cleanup logic matters. Use `delete` only when you are sure callbacks and dependent cleanup are not needed.

---

## 33. What is the difference between `find_or_create_by` and `find_or_initialize_by`?

**Grade:** Mid-level  
**Weight:** 2

**Answer:**

`find_or_create_by` finds a record or creates and saves it.

`find_or_initialize_by` finds a record or builds a new unsaved instance.

**Example:**

```ruby
User.find_or_create_by(email: "test@example.com")
user = User.find_or_initialize_by(email: "test@example.com")
user.name = "Test"
user.save!
```

**Concurrency note:**

`find_or_create_by` can still race under concurrent requests. Use unique database constraints and handle uniqueness violations.

---

## 34. What is the difference between `before_save` and `before_create`?

**Grade:** Junior to Mid-level  
**Weight:** 5

**Answer:**

`before_save` runs before both create and update.

`before_create` runs only before a new record is inserted.

**Example:**

```ruby
class User < ApplicationRecord
  before_save :normalize_email
  before_create :set_default_role
end
```

Use the most specific callback possible.

---

## 35. What is the difference between `after_save` and `after_commit`?

**Grade:** Senior  
**Weight:** 6

**Answer:**

`after_save` runs after the record is saved but before the database transaction is committed.

`after_commit` runs only after the transaction is successfully committed.

**Example:**

```ruby
class Order < ApplicationRecord
  after_commit :enqueue_confirmation_email, on: :create

  private

  def enqueue_confirmation_email
    OrderConfirmationJob.perform_later(id)
  end
end
```

**Why it matters:**

If you send emails, publish events, or enqueue jobs in `after_save`, the external side effect may happen even if the transaction later rolls back. `after_commit` is safer for external side effects.

---

## 36. What is the difference between callbacks and observers?

**Grade:** Senior  
**Weight:** 5

**Answer:**

Callbacks are lifecycle hooks inside a model, such as `before_validation`, `after_create`, and `after_commit`.

Observers move reaction logic outside the model. They watch model events and respond to them. Rails no longer emphasizes built-in observers in default applications, but similar patterns are often implemented with domain events, pub/sub, service layers, or gems.

**Callback example:**

```ruby
class Post < ApplicationRecord
  after_commit :notify_subscribers, on: :create
end
```

**Event-style alternative:**

```ruby
class PublishPost
  def call(post)
    post.update!(published: true)
    PostPublishedJob.perform_later(post.id)
  end
end
```

**Interview tip:**

Say: "Callbacks are convenient but can hide control flow. For important side effects, I prefer explicit services, jobs, or domain events."

---

# Section 5: Controllers, APIs, and Security

## 37. What are strong parameters?

**Grade:** Junior to Mid-level  
**Weight:** 8

**Answer:**

Strong parameters protect against mass assignment vulnerabilities by explicitly allowing only expected request parameters.

**Example:**

```ruby
class UsersController < ApplicationController
  def create
    @user = User.create!(user_params)
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end
end
```

Never permit sensitive fields like `admin`, `role`, or `account_id` directly from untrusted users unless authorized.

---

## 38. What is CSRF protection in Rails?

**Grade:** Mid-level  
**Weight:** 7

**Answer:**

CSRF means Cross-Site Request Forgery. It tricks a logged-in user's browser into submitting unwanted requests to your app.

Rails protects HTML apps using authenticity tokens. For APIs, CSRF strategy depends on authentication style. Cookie-based APIs need CSRF protection. Token-based APIs usually rely on Authorization headers and different protections.

**Example:**

```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end
```

**Interview tip:**

Mention SameSite cookies, secure cookies, HTTPS, and avoiding unsafe state-changing GET requests.

---

## 39. How do you handle authentication and authorization in Rails?

**Grade:** Mid-level to Senior  
**Weight:** 8

**Answer:**

Authentication answers: "Who is the user?" Authorization answers: "What is this user allowed to do?"

Common authentication options:

- Rails built-in authentication generator in modern Rails.
- `has_secure_password` for custom username/password flows.
- Devise for full-featured authentication.
- OAuth/OIDC providers for enterprise login.

Common authorization options:

- Pundit policies.
- CanCanCan abilities.
- Custom policy/service objects.

**Policy example:**

```ruby
class PostPolicy
  def initialize(user, post)
    @user = user
    @post = post
  end

  def update?
    @user.admin? || @post.author_id == @user.id
  end
end
```

**Senior note:**

Authorization should be enforced server-side, tested, and designed around multi-tenancy boundaries.

---

## 40. How do you design a Rails JSON API?

**Grade:** Senior  
**Weight:** 8

**Answer:**

A good Rails API should have clear resources, consistent status codes, structured errors, authentication, authorization, pagination, filtering, versioning strategy, and observability.

**Example:**

```ruby
class Api::V1::OrdersController < Api::BaseController
  def index
    orders = current_user.orders.order(created_at: :desc).limit(50)
    render json: orders, status: :ok
  end

  def create
    order = CreateOrder.call(user: current_user, params: order_params)
    render json: order, status: :created
  rescue CreateOrder::Invalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
```

**Best practices:**

Avoid leaking internal model structure. Use serializers or presenters when response shape differs from database shape.

---

## 41. What status codes should a Rails API return?

**Grade:** Mid-level  
**Weight:** 6

**Answer:**

Common API status codes:

- `200 OK`: Successful read/update.
- `201 Created`: Resource created.
- `204 No Content`: Successful delete or empty success response.
- `400 Bad Request`: Invalid request structure.
- `401 Unauthorized`: Not authenticated.
- `403 Forbidden`: Authenticated but not allowed.
- `404 Not Found`: Resource not found.
- `409 Conflict`: State conflict, duplicate operation, optimistic lock issue.
- `422 Unprocessable Entity`: Validation errors.
- `429 Too Many Requests`: Rate limit.
- `500 Internal Server Error`: Unexpected server failure.

**Interview tip:**

Use `422` for validation failures in Rails APIs, and include machine-readable error details when possible.

---

## 42. How do you prevent mass assignment/security bugs in Rails?

**Grade:** Senior  
**Weight:** 7

**Answer:**

Use strong parameters, policy checks, database constraints, tenant scoping, and never trust client-provided ownership fields.

**Bad:**

```ruby
Project.create!(params[:project])
```

**Better:**

```ruby
current_account.projects.create!(project_params)
```

This prevents a user from assigning records to another account by passing `account_id`.

---

# Section 6: Background Jobs, Action Cable, and Async Work

## 43. How do you use Active Job in Rails?

**Grade:** Mid-level  
**Weight:** 7

**Answer:**

Active Job provides a common interface for background jobs. It can use different queue backends, including Solid Queue, Sidekiq, Resque, or others.

**Example:**

```ruby
class ReportGenerationJob < ApplicationJob
  queue_as :reports

  def perform(report_id)
    report = Report.find(report_id)
    ReportGenerator.new(report).call
  end
end

ReportGenerationJob.perform_later(report.id)
```

Use jobs for slow work like emails, reports, imports, external API calls, file processing, and webhooks.

---

## 44. What should you consider when designing background jobs?

**Grade:** Senior  
**Weight:** 9

**Answer:**

Important job design principles:

- Make jobs idempotent when possible.
- Pass IDs, not full objects.
- Use retries carefully.
- Handle dead jobs and poison messages.
- Add timeouts for external calls.
- Avoid enqueueing jobs before database commit.
- Use separate queues for critical and heavy workloads.
- Add metrics, logs, and alerts.

**Example:**

```ruby
class SendReceiptJob < ApplicationJob
  retry_on Net::OpenTimeout, wait: :exponentially_longer, attempts: 5
  discard_on ActiveRecord::RecordNotFound

  def perform(receipt_id)
    receipt = Receipt.find(receipt_id)
    return if receipt.email_sent?

    ReceiptMailer.created(receipt).deliver_now
    receipt.update!(email_sent: true)
  end
end
```

---

## 45. How do you use Action Cable for real-time updates?

**Grade:** Mid-level  
**Weight:** 5

**Answer:**

Action Cable integrates WebSockets with Rails. It uses channels for real-time communication and allows the server to broadcast messages to subscribed clients.

**Example:**

```ruby
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_room_#{params[:room_id]}"
  end
end

ActionCable.server.broadcast(
  "chat_room_#{room.id}",
  { message: "Hello" }
)
```

**Production concerns:**

Authentication, authorization, Redis/pubsub adapter, connection limits, horizontal scaling, and avoiding broadcasting sensitive data.

---

# Section 7: Testing

## 46. How do you test Rails models and controllers with RSpec?

**Grade:** Junior to Mid-level  
**Weight:** 6

**Answer:**

RSpec is a popular testing framework in Rails. Model specs test validations, associations, scopes, and domain methods. Request specs test HTTP endpoints. In modern Rails/RSpec, request specs are usually preferred over old controller specs.

**Model example:**

```ruby
RSpec.describe Post, type: :model do
  it "requires a title" do
    post = Post.new(title: nil)
    expect(post).not_to be_valid
  end
end
```

**Request example:**

```ruby
RSpec.describe "Posts", type: :request do
  describe "GET /posts" do
    it "returns success" do
      get posts_path
      expect(response).to have_http_status(:ok)
    end
  end
end
```

---

## 47. What is the difference between unit, request, integration, and system tests?

**Grade:** Mid-level  
**Weight:** 6

**Answer:**

- **Unit tests:** Test a small object or method in isolation.
- **Model tests:** Test validations, scopes, associations, and model behavior.
- **Request tests:** Test API or HTTP behavior across routing, controllers, middleware, and response.
- **Integration tests:** Test multiple parts working together.
- **System tests:** Drive a browser and test end-to-end user flows.

**Interview tip:**

Say: "I prefer a test pyramid: many fast unit/model tests, solid request tests for endpoints, and fewer high-value system tests for critical flows."

---

## 48. How do you test background jobs?

**Grade:** Senior  
**Weight:** 7

**Answer:**

Test that jobs are enqueued when expected and test job behavior separately.

**Example:**

```ruby
RSpec.describe OrdersController, type: :request do
  include ActiveJob::TestHelper

  it "enqueues confirmation job" do
    expect {
      post orders_path, params: { order: valid_params }
    }.to have_enqueued_job(OrderConfirmationJob)
  end
end
```

**Job spec:**

```ruby
RSpec.describe OrderConfirmationJob, type: :job do
  it "sends the email" do
    order = create(:order)
    expect {
      described_class.perform_now(order.id)
    }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
```

---

## 49. What makes a good Rails test suite?

**Grade:** Senior  
**Weight:** 8

**Answer:**

A good test suite is fast, reliable, meaningful, and easy to maintain.

Important practices:

- Test behavior, not implementation details.
- Keep factories minimal.
- Avoid excessive mocking around core business flows.
- Use request specs for APIs.
- Add regression tests for bugs.
- Make tests deterministic.
- Run tests in CI.
- Track flaky tests and fix them quickly.

**Staff-level note:**

At larger scale, test suite health becomes a platform concern. Slow/flaky CI reduces engineering velocity.

---

# Section 8: Design Patterns and Architecture

## 50. What is the difference between Fat Model/Thin Controller and Domain-Driven Design in Rails?

**Grade:** Senior  
**Weight:** 8

**Answer:**

Fat Model/Thin Controller means controllers should only handle HTTP concerns, while business logic moves into models. This is better than fat controllers, but large Rails apps can end up with huge models.

Domain-Driven Design focuses on modeling business concepts explicitly. Instead of putting everything inside Active Record models, you may create domain services, value objects, policies, commands, aggregates, and events.

**Example:**

```ruby
class CreateReceipt
  def initialize(user:, params:)
    @user = user
    @params = params
  end

  def call
    Receipt.transaction do
      receipt = @user.receipts.create!(@params)
      CashbackCalculator.new(receipt).call
      receipt
    end
  end
end
```

**Interview tip:**

Say: "I start with Rails conventions, then extract explicit domain objects when models become too large or workflows need orchestration."

---

## 51. What design patterns are commonly used in Rails?

**Grade:** Senior  
**Weight:** 8

**Answer:**

Common Rails patterns:

- **Service Object:** Encapsulates a business workflow.
- **Query Object:** Encapsulates complex query logic.
- **Policy Object:** Encapsulates authorization.
- **Form Object:** Handles complex form validation and submission.
- **Presenter/Decorator:** Keeps view formatting logic out of models.
- **Value Object:** Represents immutable domain values like Money, DateRange, or Address.
- **Command Object:** Represents an operation with clear input/output.
- **Event Publisher/Subscriber:** Decouples side effects.

**Example service object:**

```ruby
class CreateOrder
  def self.call(...) = new(...).call

  def initialize(user:, params:)
    @user = user
    @params = params
  end

  def call
    Order.transaction do
      order = @user.orders.create!(@params)
      ReserveInventory.call(order: order)
      order
    end
  end
end
```

---

## 52. When should you use a service object in Rails?

**Grade:** Senior  
**Weight:** 7

**Answer:**

Use a service object when a workflow does not naturally belong to one model or when it coordinates multiple models/external services.

Good candidates:

- Checkout flow.
- Receipt creation with image upload and cashback calculation.
- User onboarding.
- Payment capture.
- Report generation.
- Import pipelines.

Avoid creating tiny service objects for every one-line method. That can make the app harder to navigate.

---

## 53. What is a query object and when would you use it?

**Grade:** Senior  
**Weight:** 6

**Answer:**

A query object encapsulates complex database queries in a reusable, testable object.

**Example:**

```ruby
class OrdersSearchQuery
  def initialize(scope = Order.all, params = {})
    @scope = scope
    @params = params
  end

  def call
    relation = @scope
    relation = relation.where(status: @params[:status]) if @params[:status].present?
    relation = relation.where("created_at >= ?", @params[:from]) if @params[:from].present?
    relation.order(created_at: :desc)
  end
end
```

Use it when scopes become too many, too conditional, or hard to test.

---

## 54. How do you avoid fat controllers in Rails?

**Grade:** Mid-level to Senior  
**Weight:** 7

**Answer:**

Move responsibilities to the right layer:

- Request parsing stays in controller.
- Authorization goes to policies.
- Complex workflows go to services.
- Query logic goes to scopes/query objects.
- Presentation logic goes to serializers/presenters.
- Slow work goes to jobs.

**Example:**

```ruby
class ReceiptsController < ApplicationController
  def create
    receipt = CreateReceipt.call(user: current_user, params: receipt_params)
    render json: ReceiptSerializer.new(receipt), status: :created
  end
end
```

---

## 55. How do you structure a large Rails application?

**Grade:** Staff  
**Weight:** 10

**Answer:**

Start with Rails conventions, then organize around business domains as the app grows.

Possible structure:

```text
app/
  models/
  controllers/
  jobs/
  services/
    receipts/
      create_receipt.rb
      calculate_cashback.rb
  queries/
  policies/
  serializers/
  value_objects/
```

For very large systems, use domain boundaries such as Billing, Onboarding, Notifications, Search, and Identity. Keep dependencies clear and avoid letting every part of the app call every other part.

**Staff-level answer:**

"I optimize for clear ownership, low coupling, testability, and safe change. I don't split into microservices just because the app is large. I first create modular boundaries inside the monolith."

---

# Section 9: Transactions, Concurrency, and Data Integrity

## 56. How do transactions work in Rails?

**Grade:** Senior  
**Weight:** 9

**Answer:**

Transactions group database operations so they either all succeed or all roll back.

**Example:**

```ruby
Order.transaction do
  order = Order.create!(user: user)
  Payment.create!(order: order, amount_cents: 1000)
  Inventory.reserve!(order)
end
```

If an exception is raised, the transaction rolls back.

**Important:**

External side effects like emails, HTTP calls, and message publishing cannot be rolled back by the database. Trigger them after commit or through an outbox pattern.

---

## 57. What is optimistic locking in Rails?

**Grade:** Senior  
**Weight:** 7

**Answer:**

Optimistic locking prevents lost updates when multiple processes edit the same record. Rails uses a `lock_version` column. If two users load the same record and both update it, the second stale update raises `ActiveRecord::StaleObjectError`.

**Migration:**

```ruby
add_column :products, :lock_version, :integer, default: 0, null: false
```

**Use case:**

Good for records edited by users or processes where conflicts are possible but not constant.

---

## 58. What is pessimistic locking in Rails?

**Grade:** Senior  
**Weight:** 7

**Answer:**

Pessimistic locking locks a database row so other transactions cannot modify it until the lock is released.

**Example:**

```ruby
Product.transaction do
  product = Product.lock.find(product_id)
  product.update!(stock: product.stock - 1)
end
```

Use it when concurrent updates would be dangerous, such as inventory, wallet balances, or limited slots.

**Tradeoff:**

It improves consistency but can reduce throughput and cause lock waits if overused.

---

## 59. How would you prevent duplicate records under high concurrency?

**Grade:** Senior  
**Weight:** 8

**Answer:**

Do not rely only on Rails validations. Use database constraints.

**Example:**

```ruby
add_index :users, :email, unique: true
```

Then handle the race:

```ruby
begin
  User.create!(email: email)
rescue ActiveRecord::RecordNotUnique
  User.find_by!(email: email)
end
```

For business operations, use idempotency keys, unique indexes, locks, or upserts.

---

## 60. What is an idempotency key and why is it important?

**Grade:** Staff  
**Weight:** 8

**Answer:**

An idempotency key lets clients safely retry requests without creating duplicate side effects.

Example: if a payment request times out, the client may retry. Without idempotency, the user may be charged twice.

**Design:**

Create a table storing `key`, `user_id`, request fingerprint, response status, and result reference. Add a unique index on `[user_id, key]`.

**Use cases:**

- Payments.
- Order creation.
- Webhooks.
- Receipt submission.
- External API retries.

---

## 61. How would you design safe database migrations for production?

**Grade:** Staff  
**Weight:** 10

**Answer:**

For production systems, migrations must avoid long locks and downtime.

Safe approach:

1. Add nullable columns first.
2. Backfill data in batches outside the migration or using a controlled job.
3. Deploy code that writes both old and new columns if needed.
4. Validate data.
5. Add constraints/indexes safely.
6. Remove old columns in a later deploy.

**Example danger:**

Adding a column with a default and `NOT NULL` to a huge table can lock the table depending on database/version and operation.

**Staff-level answer:**

Mention expand-and-contract migrations, backwards-compatible deploys, feature flags, and rollback strategy.

---

# Section 10: Caching, Scaling, and Reliability

## 62. What caching options exist in Rails?

**Grade:** Mid-level to Senior  
**Weight:** 7

**Answer:**

Rails supports multiple caching strategies:

- Page/action caching patterns through infrastructure or reverse proxies.
- Fragment caching in views.
- Low-level caching with `Rails.cache`.
- Russian doll caching.
- HTTP caching with ETags and cache-control.
- Query/result caching.

**Example:**

```ruby
Rails.cache.fetch("user:#{user.id}:stats", expires_in: 10.minutes) do
  UserStatsCalculator.new(user).call
end
```

**Senior note:**

Caching introduces invalidation problems. Always define ownership, expiration, and correctness requirements.

---

## 63. How do you scale a Rails application?

**Grade:** Senior to Staff  
**Weight:** 10

**Answer:**

Scaling Rails involves application, database, background jobs, caching, and infrastructure.

Common approaches:

- Add app instances behind a load balancer.
- Use database indexes and query optimization.
- Use read replicas for read-heavy workloads.
- Use background jobs for slow work.
- Add caching for expensive repeatable work.
- Paginate large lists.
- Use CDN/object storage for assets and uploads.
- Separate queues by workload.
- Monitor performance and errors.

**Staff-level answer:**

"I first identify the bottleneck. Scaling web dynos won't fix a slow database query. Scaling workers won't fix lock contention."

---

## 64. How do you handle multi-tenancy in Rails?

**Grade:** Staff  
**Weight:** 9

**Answer:**

Common multi-tenancy models:

1. **Shared database, shared schema:** every tenant-scoped table has `account_id` or `tenant_id`.
2. **Shared database, separate schemas:** tenant data separated by schema.
3. **Separate databases:** strongest isolation but more operational complexity.

For most SaaS Rails apps, shared schema with strong tenant scoping is common.

**Example:**

```ruby
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end

class Project < ApplicationRecord
  belongs_to :account
end

current_account.projects.find(params[:id])
```

**Security note:**

Never use `Project.find(params[:id])` in tenant-scoped apps unless authorization separately guarantees tenant ownership.

---

## 65. How do you design observability for Rails?

**Grade:** Staff  
**Weight:** 9

**Answer:**

Observability should help answer: what happened, where, why, and who was affected.

Important signals:

- Structured logs with request IDs and user/account IDs where safe.
- Metrics for latency, throughput, errors, queue depth, retries, and database time.
- Distributed traces for request/job/external service flow.
- Error tracking with context.
- Dashboards and alerts tied to user impact.

**Rails examples:**

- Use `ActiveSupport::Notifications` for custom instrumentation.
- Use OpenTelemetry for traces.
- Add custom metrics around business-critical paths.

**Interview tip:**

Mention RED metrics: rate, errors, duration. For jobs, add queue latency and retry/dead count.

---

## 66. How would you debug a production Rails incident?

**Grade:** Senior to Staff  
**Weight:** 10

**Answer:**

A good incident response process:

1. Confirm user impact.
2. Check recent deploys, config changes, traffic spikes, and dependency issues.
3. Look at dashboards: error rate, latency, database, queues, memory, CPU.
4. Use logs/traces to identify failing path.
5. Mitigate quickly: rollback, feature flag off, scale workers, pause bad jobs, disable integration.
6. Communicate status.
7. After resolution, write a postmortem and add prevention.

**Interview tip:**

Avoid sounding like you jump directly to code. Senior engineers stabilize the system first, then diagnose deeply.

---

# Section 11: Rails with PostgreSQL

## 67. What database constraints should you use with Rails validations?

**Grade:** Senior  
**Weight:** 8

**Answer:**

Rails validations improve user experience, but database constraints protect data integrity.

Common constraints:

- `null: false`
- unique indexes
- foreign keys
- check constraints
- default values

**Example:**

```ruby
add_reference :orders, :user, null: false, foreign_key: true
add_index :users, :email, unique: true
add_check_constraint :orders, "total_cents >= 0", name: "orders_total_non_negative"
```

**Interview tip:**

Say: "I treat Rails validations as application feedback and database constraints as the final protection."

---

## 68. How do you use indexes effectively?

**Grade:** Senior  
**Weight:** 9

**Answer:**

Indexes speed up reads but add write overhead and storage cost.

Good index candidates:

- Foreign keys.
- Columns used in frequent `WHERE` filters.
- Columns used in joins.
- Columns used in ordering with filters.
- Unique business keys.

**Example:**

```ruby
add_index :orders, [:account_id, :created_at]
add_index :users, :email, unique: true
```

Use `EXPLAIN ANALYZE` to confirm query behavior. Don't add indexes blindly.

---

## 69. What are database read replicas and when would you use them?

**Grade:** Staff  
**Weight:** 7

**Answer:**

Read replicas are database copies used for read traffic. They reduce load on the primary database.

Use cases:

- Reporting queries.
- Heavy read endpoints.
- Admin dashboards.
- Search/filter pages.

Tradeoffs:

- Replication lag.
- Read-after-write consistency issues.
- Operational complexity.

Rails supports multiple database connections and roles, but the app must understand which reads can tolerate lag.

---

# Section 12: Advanced Rails and System Design

## 70. How would you design a Rails service for file uploads?

**Grade:** Senior  
**Weight:** 7

**Answer:**

Use Active Storage or direct cloud uploads depending on requirements.

Design considerations:

- File size limits.
- Content type validation.
- Virus scanning if needed.
- Direct upload to S3/GCS to avoid app server bottlenecks.
- Background processing for thumbnails/OCR/parsing.
- Authorization around file access.
- Signed URLs for private downloads.

**Example flow:**

Client uploads directly to S3, Rails stores metadata, a background job processes the file, and the UI polls or receives real-time status.

---

## 71. How would you design a notification system in Rails?

**Grade:** Staff  
**Weight:** 9

**Answer:**

A notification system should separate the event from delivery.

Possible design:

- Domain event: `OrderCreated`, `ReceiptApproved`, `CashbackAvailable`.
- Notification record in DB.
- Delivery channels: email, push, SMS, in-app.
- Background jobs for delivery.
- User preferences.
- Deduplication/idempotency.
- Retry and failure tracking.

**Architecture:**

```text
Business Action -> Domain Event -> Notification Builder -> Delivery Jobs -> Providers
```

**Staff-level tradeoff:**

For small systems, keep it in Rails. For high volume, consider event streaming and dedicated notification workers/services.

---

## 72. How would you design a webhook system in Rails?

**Grade:** Staff  
**Weight:** 9

**Answer:**

Webhook systems need reliability, security, and retry handling.

Key parts:

- Store webhook endpoints per customer.
- Sign payloads with HMAC.
- Send asynchronously through jobs.
- Retry with backoff.
- Record delivery attempts and responses.
- Provide replay support.
- Disable endpoints after repeated failures.
- Avoid sending uncommitted data.

**Example:**

```ruby
WebhookDeliveryJob.perform_later(event.id, endpoint.id)
```

**Security:**

Use signatures, timestamps, HTTPS, and avoid including sensitive data unless required.

---

## 73. How would you split a Rails monolith into services?

**Grade:** Staff to Principal  
**Weight:** 10

**Answer:**

Do not split randomly. First identify boundaries, ownership, data dependencies, and business capabilities.

Process:

1. Define domain boundaries inside the monolith.
2. Reduce coupling through interfaces/events.
3. Move background-heavy or independently scaling capability first if needed.
4. Decide data ownership.
5. Create migration and rollback strategy.
6. Add observability and contract testing.
7. Avoid distributed transactions where possible.

**Good candidates:**

- Search/indexing.
- Notifications.
- Billing.
- File processing.
- Reporting.

**Principal-level answer:**

"Microservices solve team and scaling problems but introduce distributed systems problems. I would only split when the organizational and technical benefits outweigh the operational cost."

---

## 74. How would you design a reporting system in Rails?

**Grade:** Senior to Staff  
**Weight:** 8

**Answer:**

Reports can be expensive, so avoid running heavy aggregation in web requests.

Design options:

- Generate reports asynchronously with background jobs.
- Store report status and output file.
- Use materialized views or precomputed summary tables.
- Use read replicas or warehouse for heavy analytics.
- Cache common reports.
- Notify users when complete.

**Example:**

```ruby
class Report < ApplicationRecord
  enum :status, { pending: 0, processing: 1, completed: 2, failed: 3 }
end

GenerateReportJob.perform_later(report.id)
```

**Interview connection:**

You can mention your experience generating reports in Rails and moving long-running tasks to background jobs.

---

## 75. How would you design semantic search in a Rails app?

**Grade:** Staff  
**Weight:** 8

**Answer:**

Semantic search usually stores embeddings for documents or records, then compares query embeddings to find similar content.

Possible design:

- Normalize source data.
- Generate embeddings asynchronously.
- Store vectors in pgvector, Elasticsearch/OpenSearch plugin, or a vector database.
- Keep metadata in PostgreSQL.
- Re-embed when content changes.
- Combine vector similarity with filters like tenant, permissions, status, and date.
- Add evaluation to measure search quality.

**Rails flow:**

```text
Record Created -> Embedding Job -> Store Vector -> Search Query -> Filter + Rank -> Return Results
```

**Staff-level note:**

Permissions must be applied before or during retrieval, not only after, to avoid leaking private records.

---

## 76. How would you design a cashback calculation system in Rails?

**Grade:** Senior to Staff  
**Weight:** 9

**Answer:**

A cashback system should be deterministic, auditable, and safe under concurrency.

Design considerations:

- Store rules with versioning.
- Calculate cashback inside a transaction.
- Store calculation breakdowns instead of recalculating every time.
- Use idempotency to avoid duplicate rewards.
- Separate pending and available balances.
- Add ledger entries for auditability.
- Use background jobs for expensive receipt processing.

**Possible tables:**

```text
receipts
cashback_rules
cashback_calculations
wallets
wallet_ledger_entries
```

**Interview tip:**

Mention that precomputing cashback improves read performance and gives an audit trail.

---

## 77. How would you design an onboarding task assignment system in Rails?

**Grade:** Senior to Staff  
**Weight:** 9

**Answer:**

Model the domain explicitly:

- `Customer`
- `Onboarding`
- `Task`
- `CSR`
- `Skill` or `TaskType`
- `Assignment`
- `CapacitySlot`

Assignment logic should consider skills, capacity, priority, due date, fairness, and cost.

**Simple approach:**

Use a service object that selects eligible CSRs, sorts by availability/cost/workload, and creates assignments in a transaction.

**Concurrency concern:**

Use locks or database constraints to prevent over-assigning the same CSR slots when multiple onboarding requests arrive at the same time.

---

# Section 13: Code Quality and Refactoring

## 78. How do you refactor a large Rails model?

**Grade:** Senior  
**Weight:** 8

**Answer:**

Steps:

1. Add characterization tests around current behavior.
2. Identify responsibilities: validations, callbacks, queries, formatting, workflows.
3. Move query logic to scopes/query objects.
4. Move workflows to services.
5. Move presentation logic to presenters/serializers.
6. Replace risky callbacks with explicit orchestration where needed.
7. Keep commits small and reversible.

**Interview tip:**

Say: "I don't refactor blindly. I protect behavior with tests first, then extract responsibilities one by one."

---

## 79. How do you review a Rails pull request?

**Grade:** Senior to Staff  
**Weight:** 7

**Answer:**

Review for correctness, maintainability, performance, security, and operational risk.

Checklist:

- Does it solve the actual problem?
- Are authorization and tenant scoping correct?
- Are queries efficient?
- Are transactions used correctly?
- Are external side effects safe?
- Are tests meaningful?
- Is the code readable and idiomatic Rails?
- Does it need migration/rollback planning?
- Are logs/metrics needed?

**Staff-level note:**

Good reviews teach, reduce future risk, and maintain team standards without blocking unnecessarily.

---

## 80. What makes code “Rails idiomatic”?

**Grade:** Mid-level to Senior  
**Weight:** 6

**Answer:**

Idiomatic Rails code follows conventions, uses framework features appropriately, and stays simple.

Examples:

- RESTful controllers where appropriate.
- Active Record associations instead of manual foreign key handling.
- Strong parameters.
- Validations plus DB constraints.
- Background jobs for slow work.
- `after_commit` for external side effects.
- Clear model names and table conventions.
- Simple service objects when workflows become complex.

**Caution:**

Idiomatic does not mean forcing everything into Active Record. Good Rails code balances convention with explicit architecture.

---

# Section 14: Staff and Principal-Level Questions

## 81. How do you decide between a modular monolith and microservices?

**Grade:** Staff to Principal  
**Weight:** 10

**Answer:**

A modular monolith keeps deployment and data simpler while allowing internal boundaries. Microservices allow independent scaling and team ownership but add network, deployment, observability, consistency, and operational complexity.

Choose a modular monolith when:

- The team is small or medium.
- Domain boundaries are still changing.
- Strong consistency is important.
- Operational maturity is limited.

Choose microservices when:

- Teams need independent ownership/deployment.
- A domain has clearly separate scaling needs.
- Data ownership is clear.
- The organization can operate distributed systems well.

**Principal-level answer:**

"I do not treat microservices as an upgrade path by default. I treat them as an organizational and operational tradeoff."

---

## 82. How do you make architectural decisions in a Rails organization?

**Grade:** Staff to Principal  
**Weight:** 10

**Answer:**

Use an Architecture Decision Record or similar lightweight process.

A good decision includes:

- Problem statement.
- Context and constraints.
- Options considered.
- Tradeoffs.
- Decision.
- Consequences.
- Rollout plan.
- Revisit criteria.

**Example:**

Choosing Sidekiq vs Solid Queue vs another backend should consider workload, database pressure, team experience, operational tooling, retries, scheduling, and failure modes.

---

## 83. How do you improve developer productivity in a large Rails codebase?

**Grade:** Staff to Principal  
**Weight:** 9

**Answer:**

Focus on reducing feedback-loop time and cognitive load.

Areas:

- Faster CI.
- Reliable test suite.
- Clear domain boundaries.
- Good local development setup.
- Code generators/templates.
- Observability in development.
- Documentation and onboarding guides.
- Dependency upgrades.
- Better review standards.

**Principal-level note:**

Developer productivity is not only tooling. It is architecture, ownership, process, and culture.

---

## 84. How do you approach Rails upgrades?

**Grade:** Senior to Staff  
**Weight:** 8

**Answer:**

Rails upgrades should be incremental and low-risk.

Process:

1. Read release notes.
2. Update dependencies and fix deprecations.
3. Run test suite and CI.
4. Upgrade in small version steps when needed.
5. Deploy behind monitoring.
6. Watch errors, performance, and background jobs.
7. Remove compatibility code after stabilization.

**Staff-level answer:**

For large organizations, create an upgrade playbook, ownership plan, and dependency policy so upgrades do not become multi-year projects.

---

## 85. How do you balance speed and quality as a senior Rails engineer?

**Grade:** Senior to Staff  
**Weight:** 8

**Answer:**

Speed and quality are not opposites. Low-quality code slows future delivery.

Good balance:

- Deliver small vertical slices.
- Use tests around risky behavior.
- Avoid over-engineering early.
- Make tradeoffs explicit.
- Add observability for production confidence.
- Pay down high-interest technical debt.
- Use feature flags for safer rollout.

**Interview tip:**

Say: "I optimize for sustainable delivery, not just the first release."

---

# Section 15: Quick Drill Questions

Use these for fast revision.

1. Why is `after_commit` safer than `after_save` for jobs?
2. Why should uniqueness validation have a unique database index?
3. When would you use `preload` instead of `includes`?
4. When would you use `delete_all` instead of `destroy_all`?
5. Why is `Project.find(params[:id])` dangerous in a multi-tenant app?
6. What makes a background job idempotent?
7. How do you detect N+1 queries?
8. How do you choose between service objects and model methods?
9. What should be included in a production incident postmortem?
10. What are the risks of callbacks?
11. How do you safely add a non-null column to a large table?
12. How do you design retries for external API calls?
13. How do you prevent duplicate webhook delivery?
14. How do you test authorization in Rails?
15. How do you debug high database CPU in a Rails app?
16. What is the difference between authentication and authorization?
17. How do you handle stale reads from read replicas?
18. How do you design pagination for large datasets?
19. What should be logged in a Rails API request?
20. What should not be logged?

---

# Section 16: Interview Answer Frameworks

## Framework 1: For “difference between X and Y” questions

Use this format:

1. Define X.
2. Define Y.
3. Explain when to use each.
4. Mention tradeoffs.
5. Give a small example.

Example:

"`destroy` runs callbacks and dependent cleanup, while `delete` removes the row directly. I use `destroy` when business cleanup matters and `delete` only when I intentionally want a direct database delete for simple data."

---

## Framework 2: For production debugging questions

Use this format:

1. Confirm impact.
2. Check metrics/logs/traces.
3. Identify recent changes.
4. Mitigate first.
5. Debug root cause.
6. Add prevention.

---

## Framework 3: For architecture questions

Use this format:

1. Clarify requirements.
2. Define constraints.
3. Propose simple design first.
4. Discuss data model.
5. Discuss APIs/workflows.
6. Discuss scaling and failure modes.
7. Discuss tradeoffs.
8. Discuss rollout/monitoring.

---

# Section 17: Recommended Source Topics for Deeper Study

These are the official Rails areas to review regularly:

- Rails Active Record Query Interface: joins, includes, preload, eager_load, scopes, relations.
- Rails Active Record Associations: belongs_to, has_one, has_many, has_many through, HABTM.
- Rails Active Record Validations: validation lifecycle, strict validations, uniqueness limitations.
- Rails Active Record Callbacks: callback order, transaction callbacks, after_commit.
- Rails Active Record Migrations: reversible migrations, indexes, foreign keys, constraints.
- Rails Security Guide: CSRF, sessions, cookies, injection, mass assignment protection.
- Rails Testing Guide: unit, integration, system tests, fixtures, test database behavior.
- Rails Active Job Guide: queues, retries, async processing.
- Rails Action Cable Guide: channels, broadcasting, WebSocket scaling.

---

# Final Preparation Advice

For a Rails interview, do not only memorize method differences. Interviewers care about judgment.

For every answer, try to include:

- What the feature does.
- When you use it.
- When you avoid it.
- Performance impact.
- Security impact.
- Production risk.
- A real example from your experience.

Strong senior/staff Rails answers usually sound like this:

"Rails gives me a good convention for the simple case. When the workflow grows, I make the boundary explicit, add tests, protect data with database constraints, move slow work to jobs, instrument the path, and choose the simplest architecture that can safely handle the current and near-future scale."

---

# Source References Used While Expanding This Guide

- Rails Guides — Active Record Query Interface: https://guides.rubyonrails.org/active_record_querying.html
- Rails Guides — Active Record Associations: https://guides.rubyonrails.org/association_basics.html
- Rails Guides — Active Record Validations: https://guides.rubyonrails.org/active_record_validations.html
- Rails Guides — Active Record Callbacks: https://guides.rubyonrails.org/active_record_callbacks.html
- Rails Guides — Active Record Migrations: https://guides.rubyonrails.org/active_record_migrations.html
- Rails Guides — Securing Rails Applications: https://guides.rubyonrails.org/security.html
- Rails Guides — Testing Rails Applications: https://guides.rubyonrails.org/testing.html
- Rails Guides — Active Job Basics: https://guides.rubyonrails.org/active_job_basics.html
- Rails Guides — Action Cable Overview: https://guides.rubyonrails.org/action_cable_overview.html
