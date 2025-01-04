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
- Less efficient than pluck when dealing with large datasets because it retrieves full objects with only certain attributes loaded.
- **When to Use:** Use select when you want to retrieve multiple columns and still want the results as ActiveRecord
  objects (with all the model's behavior, like callbacks and methods).


```ruby
# Get a collection of post objects with only the id and title attributes loaded
posts = Post.select(:id, :title)


```
