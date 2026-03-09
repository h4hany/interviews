# Rails Interview Questions

## **1. What is the difference between `render` and `redirect_to`?**

**Weight:** 10

- **Answer:**
    - `render` displays a specific view without making a new request.
    - `redirect_to` sends a new HTTP request to a different action or URL.
- **Code Example:**
  ```ruby
  # In a controller action
  def example_action
    if some_condition
      render :some_view
    else
      redirect_to root_path
    end
  end
  ```

## **2. How do you use a concern in Rails?**

**Weight:** 10

- **Answer:**
    - Concerns allow reusable code for controllers or models.
    - To use a concern in a (controller / model), include the module in the (controller / model).
    - To create a concern, create a module in the `app/controllers/concerns` or `app/models/concerns` directory.
    - To include a concern in a controller, use the `include` keyword.
    - **Code Example:**
      ```ruby
      # app/controllers/concerns/authentication.rb
      module Authentication
       extend ActiveSupport::Concern
    
       included do
         before_action :authenticate_user
       end
    
        def authenticate_user
          redirect_to login_path unless current_user
        end
      end
    
      # app/controllers/application_controller.rb
      class ApplicationController < ActionController::Base
        include Authentication
      end
      ```

## **3. Explain the Rails MVC structure.**

**Weight:** 9

- **Answer:**
    - **Model:** Represents the data and business logic of the application.
    - **View:** Represents the user interface of the application.
    - **Controller:** Handles user requests, interacts with the model, and renders the view.

## **4. What is the purpose of the `before_action` method in Rails?**

**Weight:** 9

- **Answer:**
    - The `before_action` method is used to execute a method before a controller action.
    - It is commonly used for authentication, authorization, and other shared logic.
    - **Code Example:**
      ```ruby
      class PostsController < ApplicationController
        before_action :authenticate_user, only: [:new, :create]
    
        def new
          @post = Post.new
        end
    
        def create
          @post = Post.new(post_params)
          if @post.save
            redirect_to @post
          else
            render :new
          end
        end
    
        private
    
        def post_params
          params.require(:post).permit(:title, :content)
        end
    
        def authenticate_user
          redirect_to login_path unless current_user
        end
      end
      ```

## **5. What is the purpose of the `has_secure_password` method in Rails?**

**Weight:** 8

- **Answer:**
    - The `has_secure_password` method is used to add password hashing and authentication functionality to a model.
    - It provides methods to set and authenticate against a BCrypt password.
    - **Code Example:**
      ```ruby
      class User < ApplicationRecord
        has_secure_password
      end
      ```

## **6.How do you use scopes in Rails models?**

**Weight:** 7

- **Answer:**
- Scopes are used to define common queries that can be reused throughout the application.
- Scopes are defined using the `scope` method in a model.
- Scopes can take arguments to customize the query.
- Scopes can be chained together to create complex queries.
- **Code Example:**
  ```ruby
  class Post < ApplicationRecord
    scope :published, -> { where(published: true) }
    scope :recent, -> { order(created_at: :desc).limit(5) }
  end
  ```

## **7. What is the purpose of the `has_many` and `belongs_to` associations in Rails?**

**Weight:** 7

- **Answer:**
    - The `has_many` association is used to define a one-to-many relationship between two models.
    - The `belongs_to` association is used to define the inverse side of a one-to-many relationship.
    - These associations allow ActiveRecord to automatically generate SQL queries to retrieve associated records.
    - **Code Example:**
      ```ruby
      class Author < ApplicationRecord
        has_many :books
      end
      
      class Book < ApplicationRecord
        belongs_to :author
      end
      ```

## **8. What is the purpose of the `has_and_belongs_to_many` association in Rails?**

**Weight:** 6

- **Answer:**
    - The `has_and_belongs_to_many` association is used to define a many-to-many relationship between two models.
    - It creates a join table to store the relationships between the two models.
    - **Code Example:**
      ```ruby
      class User < ApplicationRecord
        has_and_belongs_to_many :roles
      end
      
      class Role < ApplicationRecord
        has_and_belongs_to_many :users
      end
      ```

## **9. How do you use ActionCable for real-time updates in Rails?**

**Weight:** 5

- **Answer:**
    - ActionCable is a framework for real-time communication over WebSockets in Rails.
    - To use ActionCable, you need to create a channel, a consumer, and a connection.
    - You can broadcast messages to the channel to update clients in real-time.
    - **Code Example:**
      ```ruby
      # app/channels/chat_channel.rb
      class ChatChannel < ApplicationCable::Channel
        def subscribed
          stream_from "chat_channel"
        end
    
        def receive(data)
          ActionCable.server.broadcast("chat_channel", data)
        end
      end
      ```

## **10. Explain the difference between has_many and has_many**

**Weight:** 4

- **Answer:**
    - `has_many` is used to define a one-to-many relationship between two models.
    - `has_many :through` is used to define a many-to-many relationship through a join model.
    - **Code Example:**
      ```ruby
      class Doctor < ApplicationRecord
        has_many :appointments
        has_many :patients, through: :appointments
      end
      ```

## **11. What is the purpose of the `accepts_nested_attributes_for` method in Rails?**

**Weight:** 4

- **Answer:**
    - The `accepts_nested_attributes_for` method is used to allow nested attributes to be passed to a model.
    - It is commonly used to create or update associated records through a parent model.
    - **Code Example:**
      ```ruby
      class Author < ApplicationRecord
        has_many :books
        accepts_nested_attributes_for :books
      end
      ```

## **12. What is a migration in Ruby on Rails?**

**Weight:** 3

- **Answer:**
    - A migration is a way to alter the database schema using Ruby code.
    - Migrations are used to create, modify, or delete database tables and columns.
    - Migrations are version-controlled and can be rolled back if needed.
    - **Code Example:**
      ```ruby
      class CreatePosts < ActiveRecord::Migration[6.0]
        def change
          create_table :posts do |t|
            t.string :title
            t.text :content
            t.timestamps
          end
        end
      end
      ```

## **13. How to make testing in rails app? using Rspec for model , controller**

**Weight:** 3

- **Answer:**
    - RSpec is a popular testing framework for Ruby on Rails applications.
    - To test models, you can use RSpec's `describe` and `it` blocks to define test cases.
    - To test controllers, you can use RSpec's `describe` and `it` blocks with `get`, `post`, `put`, or `delete` methods
      to simulate HTTP requests.
    - **Code Example:**
      ```ruby
      # spec/models/post_spec.rb
      require 'rails_helper'
      
      RSpec.describe Post, type: :model do
        it "is valid with a title and content" do
          post = Post.new(title: "Test Title", content: "Test Content")
          expect(post).to be_valid
        end
      end
      
      # spec/controllers/posts_controller_spec.rb
      require 'rails_helper'
      
      RSpec.describe PostsController, type: :controller do
        describe "GET #index" do
          it "returns a successful response" do
            get :index
            expect(response).to be_successful
          end
        end
      end
      ```

## **14. What is the different Fat model thin controller and domain driven in rails?**

**Weight:** 2

- **Answer:**
    - **Fat Model, Thin Controller:** This design pattern advocates for moving business logic and data manipulation
      into the model layer, keeping controllers lightweight and focused on handling HTTP requests.
    - **Domain-Driven Design (DDD):** DDD is an approach to software development that focuses on modeling the domain
      and business logic of an application. It emphasizes collaboration between domain experts and developers to
      create a shared understanding of the problem domain.
    - **Code Example:**
      ```ruby
      # Fat Model, Thin Controller
      class PostsController < ApplicationController
        def create
          @post = Post.new(post_params)
          if @post.save
            redirect_to @post
          else
            render :new
          end
        end
      
        private
      
        def post_params
          params.require(:post).permit(:title, :content)
        end
      end
      
      class Post < ApplicationRecord
        validates :title, presence: true
        validates :content, presence: true
      end
      
      # Domain-Driven Design
      class Post < ApplicationRecord
        def publish
          update(published: true)
        end
      end
      ```

## **15. What are other design pattern used in rails and the best practice?**

**Weight:** 2

- **Answer:**
    - **Service Objects:** Service objects are used to encapsulate complex business logic that doesn't fit neatly
      into models or controllers. They help keep controllers thin and focused on handling HTTP requests.
    - **Policy Objects:** Policy objects are used to encapsulate authorization logic, such as determining if a user
      has permission to perform a certain action. They help keep authorization logic separate from models and
      controllers.
    - **Query Objects:** Query objects are used to encapsulate complex database queries, making them reusable and
      testable. They help keep models focused on business logic and data manipulation.
    - **Decorator/Presenter Patterns:** Decorators or presenters are used to add presentation logic to models or
      objects. They help keep views clean and focused on rendering HTML.
    - **Singleton Pattern:** The Singleton pattern is used to ensure that a class has only one instance and provides a
      global point of access to that instance.
    - **Code Example:**
      ```ruby
      # Service Object
      class PostCreator
        def initialize(params)
          @params = params
        end
      
        def create_post
          Post.create(@params)
        end
      end
      
      # Policy Object
      class PostPolicy
        def initialize(user, post)
          @user = user
          @post = post
        end
      
        def can_edit?
          @user.admin? || @user == @post.author
        end
      end
      
      # Query Object
      class RecentPostsQuery
        def initialize(limit)
          @limit = limit
        end
      
        def find_recent_posts
          Post.order(created_at: :desc).limit(@limit)
        end
      end
      
        # Decorator/Presenter
        class PostDecorator
          def initialize(post)
            @post = post
          end
        
          def formatted_title
            @post.title.upcase
          end
        end
      
        # Singleton Pattern
        class SingletonClass
          private_class_method :new
        
          def self.instance
            @instance ||= new
          end
        end
      ```

## **16. Different between call_back and observers in rails ?**

**Weight:** 1

- **Answer:**
    - **Callbacks:** Callbacks are methods that are called at certain points in an object's lifecycle, such as
      before_validation, after_create, or around_save. They allow you to trigger custom logic in response to
      specific events.
    - **Observers:** Observers are classes that observe changes in an object and trigger custom logic in response
      to those changes. They are separate from the observed class and can be used to encapsulate complex
      event-driven behavior.
    - **Code Example:**
      ```ruby
      # Callback
      class Post < ApplicationRecord
        before_save :set_published_at
      
        private
      
        def set_published_at
          self.published_at = Time.now if published?
        end
      end
      
      # Observer
      class PostObserver < ActiveRecord::Observer
        def after_create(post)
          NotificationService.send_new_post_notification(post)
        end
      end
      ```

## **17. What is the purpose of the `validates` method in Rails models?**

**Weight:** 1

- **Answer:**
    - The `validates` method is used to define validations for model attributes.
    - It allows you to specify conditions that must be met for an object to be considered valid.
    - Common validations include presence, length, format, and uniqueness.
    - **Code Example:**
      ```ruby
      class Post < ApplicationRecord
        validates :title, presence: true
        validates :content, length: { minimum: 10 }
      end
      ```

## **18. What is N+1 query? and how to avoid it**

**Weight:** 1

- **Answer:**
    - An N+1 query occurs when a database query is made for a collection of objects, and then an additional query
      is made for each object in the collection. This results in N+1 queries being executed, where N is the number
      of objects in the collection.
    - N+1 queries can lead to performance issues, as each additional query incurs overhead in terms of database
      round-trips and processing time.
    - To avoid N+1 queries, you can use eager loading with the `includes` method to load associated records in a
      single query. This reduces the number of queries executed and improves performance.
    - **Code Example:**
      ```ruby
      # N+1 query example
      @posts = Post.all
      @posts.each do |post|
        puts post.comments.count
      end
      
        # Avoiding N+1 query
      
        @posts = Post.includes(:comments)
      ```

## **19. What is the difference between `includes`, `joins`, `preload`, and `eager_load` in Rails?**

**Weight:** 8

- **Answer:**
    - **`includes`**: Uses LEFT OUTER JOIN or separate queries depending on conditions. Can prevent N+1 queries.
    - **`joins`**: Uses INNER JOIN. Doesn't load associated data, only joins tables for filtering.
    - **`preload`**: Always uses separate queries. Loads associations in a second query.
    - **`eager_load`**: Always uses LEFT OUTER JOIN. Loads all associations in a single query.
- **Code Example:**
  ```ruby
  # includes - smart loading
  Post.includes(:comments)  # May use JOIN or separate queries

  # joins - for filtering only
  Post.joins(:comments).where(comments: { approved: true })

  # preload - separate queries
  Post.preload(:comments)

  # eager_load - single query with JOIN
  Post.eager_load(:comments)
  ```

## **20. What is the difference between `save`, `save!`, `create`, and `create!` in Rails?**

**Weight:** 8

- **Answer:**
    - **`save`**: Saves the record, returns `true` or `false` (doesn't raise on validation failure).
    - **`save!`**: Saves the record, raises exception on validation failure.
    - **`create`**: Creates and saves a new record, returns the object (even if invalid).
    - **`create!`**: Creates and saves a new record, raises exception on validation failure.
- **Code Example:**
  ```ruby
  user = User.new(name: "John")
  user.save        # Returns true/false
  user.save!       # Raises exception if invalid

  User.create(name: "John")   # Returns user object (may be invalid)
  User.create!(name: "John") # Raises exception if invalid
  ```

## **21. What is the difference between `update` and `update_attributes` in Rails?**

**Weight:** 7

- **Answer:**
    - **`update`**: Updates attributes and saves the record. Returns `true` or `false`.
    - **`update_attributes`**: Alias for `update` (deprecated in Rails 6.0+).
- **Code Example:**
  ```ruby
  user.update(name: "Jane")           # Recommended
  user.update_attributes(name: "Jane") # Deprecated
  ```

## **22. What is the difference between `find`, `find_by`, and `where` in Rails?**

**Weight:** 7

- **Answer:**
    - **`find`**: Finds by primary key, raises `ActiveRecord::RecordNotFound` if not found.
    - **`find_by`**: Finds the first record matching conditions, returns `nil` if not found.
    - **`where`**: Returns a relation (lazy loading), returns empty relation if not found.
- **Code Example:**
  ```ruby
  User.find(1)                    # Raises error if not found
  User.find_by(email: "test@example.com")  # Returns nil if not found
  User.where(email: "test@example.com")    # Returns relation (may be empty)
  ```

## **23. What is the difference between `pluck` and `select` in Rails?**

**Weight:** 6

- **Answer:**
    - **`pluck`**: Extracts specific column values directly from the database, returns an array.
    - **`select`**: Returns ActiveRecord objects with only specified attributes loaded.
- **Code Example:**
  ```ruby
  User.pluck(:name)           # ["John", "Jane"] (array of values)
  User.select(:name)          # [<User name: "John">, <User name: "Jane">] (objects)
  ```

## **24. What is the difference between `first`, `last`, and `take` in Rails?**

**Weight:** 6

- **Answer:**
    - **`first`**: Returns the first record, ordered by primary key (or specified order).
    - **`last`**: Returns the last record, ordered by primary key (or specified order).
    - **`take`**: Returns a record without any ordering (faster, but order is not guaranteed).
- **Code Example:**
  ```ruby
  User.first    # First user by id
  User.last     # Last user by id
  User.take     # Any user (no ordering)
  ```

## **25. What is the difference between `count`, `length`, and `size` in Rails?**

**Weight:** 6

- **Answer:**
    - **`count`**: Always executes a SQL COUNT query.
    - **`length`**: Loads all records into memory and counts them.
    - **`size`**: Smart - uses `count` if collection not loaded, `length` if already loaded.
- **Code Example:**
  ```ruby
  User.count    # SQL: SELECT COUNT(*) FROM users
  User.length   # Loads all users, then counts in memory
  User.size     # Uses count if not loaded, length if loaded
  ```

## **26. What is the difference between `before_save` and `before_create` callbacks in Rails?**

**Weight:** 5

- **Answer:**
    - **`before_save`**: Runs before both create and update operations.
    - **`before_create`**: Runs only before create operations.
- **Code Example:**
  ```ruby
  class User < ApplicationRecord
    before_save :normalize_email      # Runs on create and update
    before_create :set_default_role   # Runs only on create
  end
  ```

## **27. What is the difference between `validates` and `validates!` in Rails?**

**Weight:** 5

- **Answer:**
    - **`validates`**: Adds validation that runs on `save` (can be skipped with `save(validate: false)`).
    - **`validates!`**: Adds validation that always runs, even with `save(validate: false)`.
- **Code Example:**
  ```ruby
  class User < ApplicationRecord
    validates :email, presence: true      # Can be skipped
    validates! :email, format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i }  # Cannot be skipped
  end
  ```

## **28. What is the difference between `dependent: :destroy` and `dependent: :delete_all` in Rails?**

**Weight:** 5

- **Answer:**
    - **`dependent: :destroy`**: Calls `destroy` on each associated record (runs callbacks).
    - **`dependent: :delete_all`**: Deletes records directly from database (no callbacks, faster).
- **Code Example:**
  ```ruby
  class User < ApplicationRecord
    has_many :posts, dependent: :destroy      # Runs callbacks
    has_many :comments, dependent: :delete_all # No callbacks, faster
  end
  ```

## **29. What is the difference between `belongs_to` and `has_one` in Rails?**

**Weight:** 4

- **Answer:**
    - **`belongs_to`**: Used on the model that has the foreign key (many-to-one relationship).
    - **`has_one`**: Used on the model without the foreign key (one-to-one relationship).
- **Code Example:**
  ```ruby
  class User < ApplicationRecord
    has_one :profile
  end

  class Profile < ApplicationRecord
    belongs_to :user  # Has user_id foreign key
  end
  ```

## **30. What is the difference between `has_many` and `has_many :through` in Rails?**

**Weight:** 4

- **Answer:**
    - **`has_many`**: Direct one-to-many relationship.
    - **`has_many :through`**: Many-to-many relationship through a join model.
- **Code Example:**
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

## **31. What is the difference between `scope` and class methods in Rails?**

**Weight:** 4

- **Answer:**
    - **`scope`**: Syntactic sugar for class methods that return ActiveRecord::Relation.
    - **Class methods**: More flexible, can return anything.
- **Code Example:**
  ```ruby
  class Post < ApplicationRecord
    scope :published, -> { where(published: true) }
    
    def self.recent
      order(created_at: :desc).limit(10)
    end
  end
  ```

## **32. What is the difference between `after_commit` and `after_save` callbacks in Rails?**

**Weight:** 3

- **Answer:**
    - **`after_save`**: Runs after the record is saved, but within the same transaction.
    - **`after_commit`**: Runs after the database transaction is committed (safer for external operations).
- **Code Example:**
  ```ruby
  class Order < ApplicationRecord
    after_save :send_notification      # Runs in transaction
    after_commit :send_email           # Runs after commit (safer)
  end
  ```

## **33. What is the difference between `update_column` and `update_columns` in Rails?**

**Weight:** 3

- **Answer:**
    - **`update_column`**: Updates a single column, skips validations and callbacks.
    - **`update_columns`**: Updates multiple columns, skips validations and callbacks.
- **Code Example:**
  ```ruby
  user.update_column(:name, "John")                    # Single column
  user.update_columns(name: "John", email: "john@example.com")  # Multiple columns
  ```

## **34. What is the difference between `touch` and `update_attribute` in Rails?**

**Weight:** 3

- **Answer:**
    - **`touch`**: Updates the `updated_at` timestamp (and optionally other timestamps).
    - **`update_attribute`**: Updates a single attribute, bypasses validations but runs callbacks.
- **Code Example:**
  ```ruby
  user.touch                    # Updates updated_at
  user.touch(:last_seen_at)     # Updates specific timestamp
  user.update_attribute(:name, "John")  # Updates name, bypasses validations
  ```

## **35. What is the difference between `delete` and `destroy` in Rails?**

**Weight:** 3

- **Answer:**
    - **`delete`**: Removes record directly from database, no callbacks, no validations.
    - **`destroy`**: Runs callbacks and validations before removing the record.
- **Code Example:**
  ```ruby
  user.delete    # Direct SQL DELETE, no callbacks
  user.destroy   # Runs callbacks, then deletes
  ```

## **36. What is the difference between `find_or_create_by` and `find_or_initialize_by` in Rails?**

**Weight:** 2

- **Answer:**
    - **`find_or_create_by`**: Finds a record or creates it if not found (saves to database).
    - **`find_or_initialize_by`**: Finds a record or initializes it if not found (doesn't save).
- **Code Example:**
  ```ruby
  User.find_or_create_by(email: "test@example.com")      # Saves to DB
  User.find_or_initialize_by(email: "test@example.com")  # Doesn't save
  ```

## **37. What is the difference between `present?` and `exists?` in Rails?**

**Weight:** 2

- **Answer:**
    - **`present?`**: Rails method that checks if object is not blank (works on any object).
    - **`exists?`**: ActiveRecord method that checks if record exists in database (efficient query).
- **Code Example:**
  ```ruby
  User.where(email: "test@example.com").present?  # Loads records
  User.exists?(email: "test@example.com")         # Efficient query
  ```

## **38. What is the difference between `reload` and `reset` in Rails?**

**Weight:** 2

- **Answer:**
    - **`reload`**: Reloads the record from the database, discarding unsaved changes.
    - **`reset`**: Resets the association cache, forcing it to reload on next access.
- **Code Example:**
  ```ruby
  user.reload              # Reloads user from database
  user.posts.reset         # Resets posts association cache
  ```

## **39. What is the difference between `merge` and `joins` in Rails?**

**Weight:** 2

- **Answer:**
    - **`merge`**: Merges conditions from another relation.
    - **`joins`**: Joins tables for filtering, doesn't load associated data.
- **Code Example:**
  ```ruby
  Post.joins(:comments).merge(Comment.where(approved: true))
  ```

## **40. What is the difference between `inverse_of` and `foreign_key` in Rails associations?**

**Weight:** 1

- **Answer:**
    - **`inverse_of`**: Explicitly sets the inverse association to avoid multiple queries.
    - **`foreign_key`**: Specifies the foreign key column name.
- **Code Example:**
  ```ruby
  class User < ApplicationRecord
    has_many :posts, inverse_of: :author
  end

  class Post < ApplicationRecord
    belongs_to :author, class_name: "User", foreign_key: "user_id"
  end
  ```
