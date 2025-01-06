_### AI Mocked Interview

### **prompt**

> Act as interviewer for tech company
> Here is my experience. I have more than 10 years of experience as a software engineer.
> i am applying for Senior Backend Software Engineer
> the main stack is rails
> Now I want you to ask me 30 questions for ruby and ruby on rails to cover most of the topics related to it (like oop,
> problem solving , best practice , testing, and any other topics may be asked for interview )
> and i want the questions to be one by one so you ask, then i answer the question
> then you give feedback about my answer
> your feedback should have
> rate my answer from 1 to 10. ,
> my strength point in my answer and my weak point ,
> the correct answer for this question ,
> what i need to do so that i can improve my answer

### **Questions**

---

1. What are the main differences between proc and lambda in Ruby? Can you provide an example demonstrating these
   differences?

### **Answer**

The main differences between proc and lambda in Ruby are:

- Argument Checking:
    - lambda enforces the exact number of arguments and raises an error if mismatched.
    - proc is more lenient and assigns nil to missing arguments.
- Behavior of return:
    - In a lambda, return exits the lambda itself and resumes execution outside of it.
    - In a proc, return exits the enclosing method or block entirely.
- Reusability:
    - Both lambda and proc can be reused by assigning them to a variable.

```ruby
# Example showing argument validation and return behavior
my_lambda = lambda { |x, y| x + y }
puts my_lambda.call(2, 3) # Outputs 5
# my_lambda.call(2) # Raises an error due to missing argument

my_proc = Proc.new { |x, y| x + y }
puts my_proc.call(2, 3) # Outputs 5
puts my_proc.call(2) # Outputs 2 (missing argument treated as nil)

def test_return
  my_proc = Proc.new { return "From Proc" }
  my_lambda = -> { return "From Lambda" }

  puts my_lambda.call # Executes and continues
  my_proc.call # Exits the method entirely
  "Method End"
end

puts test_return
# Output:
# From Lambda
# From Proc
```

---

2. Explain how the Rails Active Record pattern simplifies database interactions. What are the benefits of using Active
   Record over raw SQL queries?

### **Answer**

Active Record is an ORM (Object-Relational Mapping) framework in Rails that abstracts database interactions by
representing database tables as classes and rows as objects.
This allows developers to interact with the database using Ruby methods instead of writing raw SQL queries.

- Key Benefits:

    - Abstraction: Simplifies complex queries and reduces boilerplate code.
    - Object-Oriented Design: Developers work with Ruby objects instead of database rows, making the code more intuitive
      and maintainable.
    - Database-Agnostic: Active Record adapts to multiple database systems (e.g., PostgreSQL, MySQL) without requiring
      SQL syntax changes.
    - Built-in Validations and Callbacks: Automates common tasks like data validation and lifecycle event handling (
      e.g., before saving a record).
    - Eager Loading and Associations: Manages relationships between tables (e.g., belongs_to, has_many) and optimizes
      queries using eager loading (includes, joins).

```ruby
# Querying records
user = User.find(1) # SELECT * FROM users WHERE id = 1

# Creating a new record
user = User.create(name: "John Doe", email: "john@example.com")

# Updating a record
user.update(email: "new_email@example.com")

# Associations
posts = user.posts # Fetches posts associated with the user

# Eager Loading
users_with_posts = User.includes(:posts).where(active: true)
```

---

3. What are Rails callbacks, and how can they be used effectively? Are there any potential drawbacks to using callbacks?

### **Answer**

Rails Callbacks are methods that are triggered at specific points in the lifecycle of an Active Record object.
They help automate common tasks, such as validations, notifications, or logging, by hooking into events like creating,
updating, or deleting records.

```ruby

class Order < ApplicationRecord
  # Callback runs after the record is saved
  after_save :send_email

  private

  def send_email
    # Code to send an email notification
    puts "Email sent to the user"
  end
end
```

**Common Callbacks in Rails:**

- before_validation, after_validation
- before_save, after_save
- before_create, after_create
- before_update, after_update
- before_destroy, after_destroy

**Drawbacks of Callbacks:**

- **Tight Coupling:** Callbacks mix business logic with model code, making it harder to isolate and test logic.
- **Hidden Side Effects:** It’s not always obvious when callbacks are being triggered, leading to unexpected behavior.
- **Performance Issues:** Overuse of callbacks can slow down database operations, especially if they include external
  requests (e.g., sending emails or API calls).

**Best Practices for Using Callbacks:**

- Use callbacks sparingly to avoid hidden logic.
- Keep callback methods simple and delegate complex logic to service objects or background jobs.
- Avoid callbacks for actions that should happen outside the model, like email notifications or logging. Use tools like
  Active Job for such tasks.

---

4. Can you explain how Rails manages database migrations? Why are migrations important, and what best practices should
   be followed when writing them?

### **Answer**

**How Rails Manages Migrations:**
Rails uses migration files to manage and track database schema changes over time.
Each migration file is timestamped and includes Ruby DSL methods to define schema changes like creating, modifying, or
deleting tables and columns.
Migrations are applied in sequence, ensuring consistent database structure across environments.
The schema file (e.g., schema.rb) reflects the current state of the database and is used to sync new environments.

**Why Migrations Are Important:**

- **Version Control:** Migrations track each change to the database, making it easier to understand and audit schema
  evolution.
- **Rollback Capability:** Migrations provide a mechanism to reverse changes (rails db:rollback), ensuring safe
  experimentation.
- **Declarative Syntax:** Rails' DSL simplifies writing database modifications without writing raw SQL.
- **Collaboration:** Ensures all team members work with the same schema by syncing changes with migrations.

```ruby

class AddStatusToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :status, :string, default: "pending", null: false
  end
end

#Rollback Example:

class AddStatusToOrders < ActiveRecord::Migration[7.0]
  def up
    add_column :orders, :status, :string, default: "pending", null: false
  end

  def down
    remove_column :orders, :status
  end
end
```

---

5. What is the difference between has_many :through and has_and_belongs_to_many in Rails associations? When would you
   use one over the other?

### **Answer**

Both has_many :through and has_and_belongs_to_many are used for modeling many-to-many relationships in Rails. The main
difference lies in how the relationship is set up and whether the join table needs additional fields.

- **has_and_belongs_to_many (HABTM):**
    - This is a simpler association that connects two models directly via a join table.
    - The join table does not have its own model and cannot store additional fields.
    - Use this when the relationship is straightforward and does not require extra attributes or logic.
    - **Limitations of HABTM:**
        - Cannot add validations or callbacks to the join table.
        - Less flexible for future changes

```ruby 

class Book < ApplicationRecord
  has_and_belongs_to_many :authors
end

class Author < ApplicationRecord
  has_and_belongs_to_many :books
end

class CreateAuthorsBooksJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :authors, :books
  end
end
```

- **has_many :through:**
    - This uses a separate join table that has its own model, allowing for additional fields, validations, and logic.
    - Use this when you need to store attributes on the join table or have complex business logic.

```ruby

class Book < ApplicationRecord
  has_many :book_authors
  has_many :authors, through: :book_authors
end

class Author < ApplicationRecord
  has_many :book_authors
  has_many :books, through: :book_authors
end

class BookAuthor < ApplicationRecord
  belongs_to :book
  belongs_to :author
end

class CreateBookAuthors < ActiveRecord::Migration[7.0]
  def change
    create_table :book_authors do |t|
      t.references :book, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: true
      t.date :collaboration_date # Example of an additional field
      t.timestamps
    end
  end
end
```

**When to Use One Over the Other:**

- Use **HABTM:** When the relationship is simple and does not require additional fields or logic on the join table.
- Use **has_many :through:** When the join table needs its own model for additional attributes, validations, or custom
  logic.

---

6. What are Rails validations, and why are they important? Can you provide examples of custom validations?

### **Answer**

Validations are a way to ensure data integrity by enforcing rules on model attributes before saving them to the
database. They prevent invalid data from being persisted and provide error messages to the user or developer.

**Built-In Validations Examples:**

```ruby

class User < ApplicationRecord
  validates :name, presence: true
  validates :age, numericality: { greater_than: 18 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, uniqueness: true
  validates :password, length: { minimum: 8 }

end

# Custom Validations Example:

class Product < ApplicationRecord
  validate :expiration_date_cannot_be_in_the_past

  private

  def expiration_date_cannot_be_in_the_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "can't be in the past")
    end
  end
end
```

**Why Are Validations Important?**

- **Data Integrity:** Prevent invalid or incomplete data from being saved.
- **User Feedback:** Provide clear error messages to guide user input.
- **Consistency:** Enforce rules at the application level regardless of how data is entered.

---

7. What are Rails validations, and why are they important? Can you provide examples of custom validations?

### **Answer**

Scopes are methods in Rails models that encapsulate reusable and chainable query logic. They simplify queries by making
them more readable and reusable across the application.

```ruby

class News < ApplicationRecord
  scope :most_recent, -> { where('date > ?', Date.today - 7) }
end

# Usage:
News.most_recent

```

**Default Scope:**
A default scope is a query applied automatically to all queries on a model unless explicitly overridden.

```ruby

class News < ApplicationRecord
  default_scope { order(created_at: :desc) }
end

# Usage:
News.all # Always returns records in descending order of creation date.
```

**Potential Drawbacks of Default Scope:**

- **Overriding Complexity:** Default scopes need to be manually overridden in queries, which can lead to unexpected
  behavior
- **Testing and Maintenance:** Debugging can be harder if the default scope is not well-documented.

**Best Practices for Scopes:**

- **Use Named Scopes for Reusability:** Encapsulate logic that might be reused in multiple places.
- **Avoid Overusing Default Scope:** Use it sparingly and only for universally applicable rules.
- **Keep Scopes Chainable:** Write scopes in a way that they can be combined with others.

```ruby
scope :published, -> { where(status: 'published') }
scope :most_recent, -> { order(created_at: :desc) }

# Chaining scopes:
News.published.most_recent
```

8. What are polymorphic associations in Rails, and when would you use them? Provide an example.

### **Answer**

Polymorphic associations allow a model to belong to multiple other models through a single association.
This avoids creating separate tables for each relationship and simplifies the database structure.

```ruby

class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
end

class Post < ApplicationRecord
  has_many :comments, as: :commentable
end

class Image < ApplicationRecord
  has_many :comments, as: :commentable
end

class CreateComments < ActiveRecord::Migration[7.1]
  def change
    create_table :comments do |t|
      t.text :body
      t.references :commentable, polymorphic: true, null: false

      t.timestamps
    end
  end
end

# Create a post
post = Post.create(title: "A Blog Post", content: "This is the content.")

# Add a comment to the post
post.comments.create(body: "Great post!")

# Create an image
image = Image.create(url: "example.com/image.png")

# Add a comment to the image
image.comments.create(body: "Nice picture!")

# Query comments for a specific post
post.comments
```

**When to Use Polymorphic Associations:**
Polymorphic associations are ideal when multiple models share similar behavior or functionality, like comments, likes,
or tags. Instead of creating separate tables for each model, you can manage all related data in one table.

- **Advantages:**

    - Simplifies the database structure.
    - Reduces redundancy by avoiding multiple association tables.
- **Disadvantages:**

    - Queries may become more complex due to the need to handle different commentable_type.
    - Indexing and performance may be harder to optimize with large datasets.

---

9. What is the difference between includes and joins in Rails? When would you use each?

### **Answer**

**Difference Between includes and joins:**

- **includes:**
    - Used for eager loading associated records.
    - Executes separate queries to fetch the main and associated records or performs a LEFT OUTER JOIN if needed.
    - Avoids the N+1 query problem by preloading associated data.
    - Generates fewer queries when accessing associations but can load unnecessary data into memory.
    - **When to Use:** Use includes when you need to access associated records after fetching the main records,
      especially if there's a risk of N+1 queries.

```ruby
# Fetch posts with associated comments (eager loading)
posts = Post.includes(:comments)

posts.each do |post|
  puts post.comments.size # No additional query
end

```

- **joins:**
    - Performs a SQL JOIN (typically INNER JOIN) to combine records from multiple tables in a single query.
    - Doesn’t fetch the associated records into memory but allows filtering based on associated records.
    - Efficient for filtering but may lead to additional queries if associated data is accessed without eager loading.
    - **When to Use:** Use joins when you need to filter records based on associated data or perform aggregate queries.

```ruby
posts = Post.joins(:comments).where(comments: { approved: true })

```

---

10. What is the difference between pluck and select in Rails? Provide examples.

### **Answer**

**Difference Between pluck and select:**

- **pluck:**

    - **Purpose:** Returns an array of values for a single attribute (or multiple attributes) directly from the
      database.
    - More efficient than select because it only returns raw values and doesn't instantiate ActiveRecord objects.
    - **When to Use:** Use pluck when you only need specific attributes from the database and don't need full
      ActiveRecord objects. It avoids the overhead of instantiating models.

```ruby
# Get an array of all post titles
titles = Post.pluck(:title)

# Get an array of post titles and their ids
post_info = Post.pluck(:id, :title)

```

- **select:**

- **Purpose:** Returns an ActiveRecord relation, where you can chain further query methods. It allows you to specify
  multiple columns to be selected in a query.
- Less efficient than pluck when dealing with large datasets because it retrieves full objects with only certain
  attributes loaded.
- **When to Use:** Use select when you want to retrieve multiple columns and still want the results as ActiveRecord
  objects (with all the model's behavior, like callbacks and methods).

```ruby
# Get a collection of post objects with only the id and title attributes loaded
posts = Post.select(:id, :title)


```

11. What is the purpose of the unscoped method in Rails, and when would you use it?

### **Answer**

- **Purpose of unscoped:**
  unscoped is used to remove any default scope that might be applied to a query, allowing you to query the database
  without the constraints of the default scope.

- **When to Use It:**
  When you need to bypass the default_scope for a specific query.
  For example, fetching all records (including those that a default_scope would typically exclude).
  Be cautious with unscoped as it may lead to fetching sensitive or unexpected data, especially if used inappropriately.
- **Difference Between unscoped and unscope:**
    - **unscoped:** Removes all default scopes applied to a model.
    - **unscope:** Removes specific conditions (e.g., :where, :order) from a query.

```ruby

class Post < ActiveRecord::Base
  default_scope { where(published: true) }
end

# By default, only published posts are returned
Post.all
# SELECT * FROM posts WHERE published = true

# Using unscoped to bypass the default scope
Post.unscoped.where("created_at > ?", 1.week.ago)
# SELECT * FROM posts WHERE created_at > '2025-01-01'
Post.where(published: true).order(:created_at).unscope(:order)

```

---

12. What is the difference between before_create and before_save callbacks in Rails? When would you use one over the
    other?

### **Answer**

**Difference Between before_create and before_save:**

- **before_create:**
  Runs only once, before the record is inserted into the database (after validation and before the INSERT SQL query).
  It only runs for create operations (e.g., Model.create or save on a new object).
  Use Case: Ideal for actions that should only happen when a new record is created, such as generating a unique token.

```ruby

class User < ActiveRecord::Base
  before_create :generate_token

  def generate_token
    self.token = SecureRandom.hex(10)
  end
end

```

- **before_save:**
  Runs before the record is saved to the database, whether it is a new record or an existing record being updated.
  It runs for both create and update operations.
  Use Case: Useful for actions that should happen every time the record is saved, like normalizing or modifying an
  attribute.

```ruby

class Post < ActiveRecord::Base
  before_save :normalize_title

  def normalize_title
    self.title = title.downcase
  end
end

```

---

13. What is the touch method in Rails? What are some use cases for it?

### **Answer**

The touch method in Rails updates the updated_at timestamp of a record to the current time (or a custom timestamp
column, if specified) without making changes to any other attributes. It triggers a database update but avoids running
validations.

**Use Cases for touch:**

- **Updating the Timestamp Without Changing Attributes:**
  Useful for signaling that a record has been modified or refreshed without altering its data.

````ruby
product.touch
# Updates `updated_at` to the current time.
````

- **Cascading Updates to Associated Records:**
  When an association is configured with touch: true, saving or updating the associated record will also update the
  parent
  record's updated_at.

```ruby

class Order < ActiveRecord::Base
  belongs_to :user, touch: true
end

order.save

# This will also update the `updated_at` timestamp of the associated user.
```

- **Custom Timestamps:**
  You can specify a custom timestamp column to update.

```ruby
product.touch(:published_at)

# Updates the `published_at` column to the current time.
```

- **Maintaining Cache Expiry:**
  Commonly used to invalidate or refresh caches by signaling that related data has changed.

---

14. What are ActiveRecord transactions in Rails? Why are they important, and how do you use them?

### **Answer**

ActiveRecord transactions are a way to group multiple database queries into a single atomic operation. If any query in
the block fails, all changes made within the transaction are rolled back, ensuring data integrity.

- **Why Are Transactions Important?**
    - **Data Integrity:** Prevent partial updates when an error occurs.
    - **Atomicity:** Ensures that all queries within a block succeed together or none at all.
    - **Error Handling:** Makes it easier to manage failure scenarios in database operations.
- **How to Use Transactions:**
  Transactions are implemented using the ActiveRecord::Base.transaction method:
- **Use Case Example:**
  Imagine a scenario where a user places an order and pays for it. You want to ensure both the Order and Payment records
  are created successfully, or neither is created.
- **Common Pitfalls:**
    - **Nesting Transactions:** Avoid unnecessary nesting, as Rails might not fully support rollback behavior in nested
      blocks.
    - **Long Transactions:** Keep transactions short to avoid locking tables for extended periods.
    - **Database-Specific Behavior:** Ensure your database supports transactions for the operations you're performing (
      e.g., some DDL commands may not support transactions).

```ruby
# how to use
ActiveRecord::Base.transaction do
  user = User.create!(name: "John")
  order = Order.create!(user_id: user.id, total: 100)

  # If any of these fails (e.g., validation error), the transaction rolls back.
end

# use case example
ActiveRecord::Base.transaction do
  order = Order.create!(user_id: user.id, total: 100)
  Payment.create!(order_id: order.id, amount: 100)
end


```

---

15. What is the difference between save, save!, and update_attributes in Rails?

### **Answer**

Difference Between save, save!, and update_attributes:

- **save:**
    - Saves the object to the database if validations pass.
    - Returns true on success and false on failure.
    - Does not raise exceptions if validation fails.

- **save!:**
    - Saves the object to the database if validations pass.
    - Raises an exception (ActiveRecord::RecordInvalid) if validations fail.
- **update_attributes (Deprecated in Rails 6):**

    - Used to update specific attributes of a model and save the changes.
    - Returns true if the update succeeds and false otherwise.
    - Deprecated in favor of update starting from Rails 6.

```ruby
user = User.new(name: nil) # Assuming name is required
if user.save
  puts "Saved successfully"
else
  puts "Failed to save"
end

user = User.new(name: nil)
user.save! # This will raise an error if the validation fails

user = User.find(1)
user.update_attributes(name: "Updated Name") # Deprecated
user.update(name: "Updated Name") # Preferred in Rails 6+

```

---

16. What is the difference between find, find_by, and where in Rails?

### **Answer**

Differences Between find, find_by, and where:

- **find:**
    - Finds a record by its primary key (id).
    - Raises an exception (ActiveRecord::RecordNotFound) if the record is not found.

- **find_by:**
    - Retrieves the first record that matches a specific condition.
    - Returns nil if no record is found (no exception is raised).

- **where:**
    - Retrieves all records that match one or more conditions.
    - Returns an ActiveRecord::Relation object, which can be chained for further queries or converted to an array using
      .to_a.

---

17. What is the difference between optimistic and pessimistic locking in Rails?

### **Answer**

- **Optimistic Locking:**
    - Used to prevent conflicting updates by multiple users.
    - Relies on a version number (or timestamp) column in the database (commonly lock_version).
    - Each time a record is updated, Rails checks the version to ensure no other updates have been made since it was
      loaded.
    - If the version number has changed, Rails raises an ActiveRecord::StaleObjectError.

```ruby

class Product < ApplicationRecord
end

product = Product.find(1)
product.name = "Updated Name"
product.save # Fails if another update changed the version

```

- **Pessimistic Locking:**
    - Locks the record in the database to prevent other users from modifying it until the lock is released.
    - Accomplished using SQL locking mechanisms (e.g., SELECT ... FOR UPDATE).
    - Useful when updates are frequent or the operation is critical.

```ruby

product = Product.lock.find(1) # Applies a database lock
product.name = "Updated Name"
product.save


```

---

18. What are Rails helpers, and how do they differ from concerns?

### **Answer**

- **Rails Helpers:**
    - **Purpose:** Helpers are modules used to encapsulate reusable methods for views.
    - **Scope:** Typically associated with the presentation layer. They make views cleaner by offloading logic or
      formatting-related tasks.
    - **Usage:** Automatically available in their respective views and can also be made available globally.

```ruby

module ApplicationHelper
  def format_date(date)
    date.strftime("%B %d, %Y")
  end
end

```

- **Rails Concerns:**
    - **Purpose:** Concerns are modules designed to encapsulate shared logic across models or controllers.
    - **Scope:** Focused on business logic or shared functionality that spans multiple models or controllers.
    - **Usage:** Included in models or controllers using include or extend.

```ruby

module Archivable
  extend ActiveSupport::Concern

  included do
    scope :archived, -> { where(archived: true) }
  end

  def archive
    update(archived: true)
  end
end

class Post < ApplicationRecord
  include Archivable
end

```

---

19. What are Rails engines, and when would you use them?

### **Answer**

- **Definition:** Rails engines are self-contained Rails applications that can be mounted within a parent Rails
  application. They enable modular development by allowing features or functionality to be packaged and reused across
  different projects.
- **Types:**
    - **Full Engines:** Operate as standalone Rails apps.
    - **Mountable Engines:** Share their functionality with a parent app but don’t operate independently.
- **When to Use Rails Engines:**
    - To encapsulate complex features like authentication (e.g., Devise) or content management (e.g., Spree).
    - To share reusable functionality across multiple Rails applications.
    - To separate distinct business logic into isolated modules for better code organization.
- **Example:**
    - **Creating an Engine:**
      ```bash
      rails plugin new discount_engine --mountable
      ```
    - **Folder Structure:** The engine will have its own app, config, db, and other directories like a Rails app.
    - **Mounting the Engine:** In the parent app's routes.rb: `mount DiscountEngine::Engine, at: '/discounts'`
    - **Using the Engine's Functionality:** The parent app can access routes and functionality provided by the engine.

---

20. What is the difference between dependent: :destroy and dependent: :delete_all in Rails?

### **Answer**

- **dependent: :destroy:**
    - **Description:** Ensures that when the parent object is destroyed, the associated child records are also destroyed
      by calling their destroy method.
    - **Behavior:** This triggers callbacks (such as before_destroy, after_destroy) for each associated record.
    - **Use Case:** Use this when you want to run the model’s callbacks and validations before deleting associated
      records.

- **dependent: :delete_all:**
    - **Description:** This deletes all associated records directly from the database without triggering callbacks or
      validations.
    - **Behavior:** It is faster than :destroy because it performs a raw SQL DELETE operation. However, it bypasses
      Active Record callbacks and validations.
    - **Use Case:** Use this when you need better performance and don't need to run callbacks or validations for the
      child records.

```ruby

class Post < ApplicationRecord
  has_many :comments, dependent: :destroy
end

post = Post.find(1)
post.destroy # Comments will be destroyed, triggering their callbacks

class Post < ApplicationRecord
  has_many :comments, dependent: :delete_all
end

post = Post.find(1)
post.destroy # Comments will be deleted directly from the database without callbacks

```

---

21. What are service objects in Rails, and why would you use them?

### **Answer**

Service objects are plain Ruby classes used to encapsulate complex business logic that doesn’t belong to models,
controllers, or views. They follow the principle of "Single Responsibility," ensuring each class has a single,
well-defined purpose.

- **Why Use Service Objects?**
    - **Keep Models and Controllers Clean:** They move complex logic out of models and controllers, making them easier
      to maintain.
    - **Enhance Testability:** Isolated logic in service objects is easier to test independently.
    - **Apply SOLID Principles:** Promotes separation of concerns and reduces coupling.
    - **Reusability:** Code in service objects can be reused in multiple places (e.g., background jobs or API calls).

```ruby
#Without Service Object (Fat Controller):

class OrdersController < ApplicationController
  def create
    @order = Order.new(order_params)
    if @order.save
      send_confirmation_email(@order)
      charge_credit_card(@order)
      render json: @order, status: :created
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  private

  def send_confirmation_email(order)
    # Email logic here
  end

  def charge_credit_card(order)
    # Payment logic here
  end
end

#With Service Object:

class OrderService
  def initialize(order_params)
    @order_params = order_params
  end

  def create_order
    order = Order.new(@order_params)
    if order.save
      send_confirmation_email(order)
      charge_credit_card(order)
      return order
    else
      raise ActiveRecord::RecordInvalid, order
    end
  end

  private

  def send_confirmation_email(order)
    # Email logic here
  end

  def charge_credit_card(order)
    # Payment logic here
  end
end

class OrdersController < ApplicationController
  def create
    service = OrderService.new(order_params)
    order = service.create_order
    render json: order, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: e.record.errors, status: :unprocessable_entity
  end
end

```

---

22. What is Rails Active Job, and why would you use it?

### **Answer**

Active Job is a framework for declaring jobs and making them run on various queueing backends. It provides a consistent
interface for job processing, enabling developers to write jobs once and use them with any backend, such as Sidekiq,
Resque, or Delayed Job.

- **Why Use Active Job?**
    - **Offload Long-Running Tasks:** For example, sending bulk emails or generating reports.
    - **Improve User Experience:** Users don’t have to wait for time-consuming tasks to complete.
    - **Queue Flexibility:** Supports multiple backends without changing job definitions.
    - **Retry Logic:** Automatically retries jobs on failure.
    - **Asynchronous Execution:** Allows jobs to run independently of the main application process.

```ruby

class UserMailerJob < ApplicationJob
  queue_as :default

  def perform(user)
    UserMailer.welcome_email(user).deliver_now
  end
end

user = User.find(1)
UserMailerJob.perform_later(user)

```
