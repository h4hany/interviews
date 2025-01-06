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
