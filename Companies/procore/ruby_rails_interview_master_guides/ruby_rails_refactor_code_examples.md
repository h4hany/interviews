# Ruby on Rails Interview Preparation — Refactor Code Examples

**Prepared date:** 2026-06-02  
**Target:** Mid → Senior → Staff refactoring, runtime, production debugging, and code review interviews  
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

For each exercise: first explain behavior, then identify risks, then refactor in small safe steps. In a live interview, do not jump straight to rewriting. Say what tests you would add first, then show the refactor.

---
## Refactoring answer framework

Use this structure in interviews:

1. Clarify expected behavior.
2. Identify code smells.
3. Identify production/scaling/security risks.
4. Add characterization tests.
5. Refactor one boundary at a time.
6. Move side effects out of request/transaction when needed.
7. Add observability.
8. Discuss rollout and rollback.

---

    ### Exercise 1. Fat Controller with external API, PDF generation, and emails

    **Interview category / level:** Mid / Senior Refactoring

    **Original bad code:**
    ```ruby
    class InvoicesController < ApplicationController
  def create
    invoice = Invoice.create!(params.require(:invoice).permit!)
    tax = Net::HTTP.get(URI("https://tax.example.com?amount=#{invoice.amount}"))
    invoice.update!(tax_amount: JSON.parse(tax)["tax"])
    pdf = InvoicePdf.new(invoice).render
    InvoiceMailer.with(invoice: invoice, pdf: pdf).send_pdf.deliver_now
    SlackClient.notify("Invoice created #{invoice.id}")
    render json: invoice, status: :created
  end
end
    ```

    **Problems in the code:**
    - Controller owns business workflow
- `permit!` unsafe
- Synchronous external calls
- Email/PDF/Slack block request
- Poor error handling
- Hard to test

    **Production / scaling risks:**
    - Slow responses
- Thread exhaustion
- Partial failure
- Retry ambiguity
- Difficult observability

    **Refactoring strategy:**
    - Add tests around current behavior before changing code.
    - Separate HTTP/controller concerns from business workflow.
    - Keep database transactions short.
    - Move slow side effects to jobs or outbox events.
    - Make retries/idempotency explicit.
    - Add instrumentation around the meaningful business operation.

    **Improved implementation:**
    ```ruby
    module Invoices
  class Create
    def self.call(params:)
      new(params).call
    end

    def initialize(params)
      @params = params
    end

    def call
      Invoice.transaction do
        invoice = Invoice.create!(@params)
        OutboxEvent.create!(
          event_type: "invoice.created",
          aggregate_id: invoice.id,
          payload: { invoice_id: invoice.id }
        )
        invoice
      end
    end
  end
end

class InvoicesController < ApplicationController
  def create
    invoice = Invoices::Create.call(params: invoice_params)
    render json: invoice, status: :created
  end

  private

  def invoice_params
    params.require(:invoice).permit(:amount, :customer_id, :state)
  end
end
    ```

    **Testing strategy:**
    - Request spec for controller
- Unit test service success/failure
- Assert outbox event created
- Job tests for tax/PDF/email
- Contract tests for tax API

    **Staff-level things to mention:**
    - What invariant must be protected?
    - What should be synchronous vs asynchronous?
    - What can fail and how do we recover?
    - What metrics/traces prove the refactor helped?
    - What migration/rollout risk exists?

    **Follow-up interviewer questions:**
    - How would you roll this out safely in production?
    - What telemetry would you add?
    - What edge case could still fail?
    - Would this design still work at 10x traffic?

    ---

    ### Exercise 2. N+1 query in serializer

    **Interview category / level:** Mid / Senior Performance Refactoring

    **Original bad code:**
    ```ruby
    class ProjectSerializer
  def initialize(projects)
    @projects = projects
  end

  def as_json
    @projects.map do |project|
      {
        id: project.id,
        company: project.company.name,
        manager: project.manager.profile.full_name,
        open_tasks: project.tasks.where(status: "open").count
      }
    end
  end
end
    ```

    **Problems in the code:**
    - Company, manager/profile, and tasks count can trigger N+1
- Aggregation inside loop
- Serializer talks directly to database
- No pagination guarantee

    **Production / scaling risks:**
    - Latency grows with project count
- DB CPU spikes
- Memory overhead from eager loading too much if fixed blindly

    **Refactoring strategy:**
    - Add tests around current behavior before changing code.
    - Separate HTTP/controller concerns from business workflow.
    - Keep database transactions short.
    - Move slow side effects to jobs or outbox events.
    - Make retries/idempotency explicit.
    - Add instrumentation around the meaningful business operation.

    **Improved implementation:**
    ```ruby
    projects = Project
  .joins(:company)
  .joins(manager: :profile)
  .left_outer_joins(:tasks)
  .where(company_id: current_company.id)
  .select(
    "projects.id, projects.name, companies.name AS company_name, profiles.full_name AS manager_name, "     "COUNT(CASE WHEN tasks.status = 'open' THEN 1 END) AS open_tasks_count"
  )
  .group("projects.id, companies.id, profiles.id")
  .limit(50)

render json: projects.map { |p|
  {
    id: p.id,
    name: p.name,
    company: p.company_name,
    manager: p.manager_name,
    open_tasks: p.open_tasks_count.to_i
  }
}
    ```

    **Testing strategy:**
    - Add query count spec
- Verify JSON shape
- Run EXPLAIN ANALYZE
- Test with projects with/without tasks

    **Staff-level things to mention:**
    - What invariant must be protected?
    - What should be synchronous vs asynchronous?
    - What can fail and how do we recover?
    - What metrics/traces prove the refactor helped?
    - What migration/rollout risk exists?

    **Follow-up interviewer questions:**
    - How would you roll this out safely in production?
    - What telemetry would you add?
    - What edge case could still fail?
    - Would this design still work at 10x traffic?

    ---

    ### Exercise 3. External API inside transaction

    **Interview category / level:** Senior Reliability Refactoring

    **Original bad code:**
    ```ruby
    class SubscriptionActivator
  def self.call(user, plan)
    Subscription.transaction do
      sub = Subscription.create!(user: user, plan: plan, status: "pending")
      stripe_sub = Stripe::Subscription.create(customer: user.stripe_customer_id, plan: plan.external_id)
      sub.update!(stripe_id: stripe_sub.id, status: "active")
    end
  end
end
    ```

    **Problems in the code:**
    - Holds DB transaction during network call
- External call cannot roll back
- Potential DB/Stripe inconsistency
- No idempotency key

    **Production / scaling risks:**
    - Connection pool exhaustion
- Double billing on retry
- User charged but local DB failed

    **Refactoring strategy:**
    - Add tests around current behavior before changing code.
    - Separate HTTP/controller concerns from business workflow.
    - Keep database transactions short.
    - Move slow side effects to jobs or outbox events.
    - Make retries/idempotency explicit.
    - Add instrumentation around the meaningful business operation.

    **Improved implementation:**
    ```ruby
    class SubscriptionActivator
  def self.call(user:, plan:)
    sub = Subscription.create!(user: user, plan: plan, status: "pending")

    ActivateSubscriptionJob.perform_later(sub.id)

    sub
  end
end

class ActivateSubscriptionJob
  include Sidekiq::Worker

  def perform(subscription_id)
    sub = Subscription.find(subscription_id)
    return if sub.active?

    stripe_sub = Stripe::Subscription.create(
      { customer: sub.user.stripe_customer_id, plan: sub.plan.external_id },
      { idempotency_key: "subscription:#{sub.id}" }
    )

    sub.update!(stripe_id: stripe_sub.id, status: "active")
  rescue Stripe::StripeError => e
    sub.update!(status: "activation_failed", failure_reason: e.message)
    raise
  end
end
    ```

    **Testing strategy:**
    - Test no HTTP call inside transaction
- Test job idempotency
- Simulate Stripe failure
- Simulate DB failure after Stripe success and reconciliation

    **Staff-level things to mention:**
    - What invariant must be protected?
    - What should be synchronous vs asynchronous?
    - What can fail and how do we recover?
    - What metrics/traces prove the refactor helped?
    - What migration/rollout risk exists?

    **Follow-up interviewer questions:**
    - How would you roll this out safely in production?
    - What telemetry would you add?
    - What edge case could still fail?
    - Would this design still work at 10x traffic?

    ---

    ### Exercise 4. Race condition in inventory decrement

    **Interview category / level:** Senior Concurrency Refactoring

    **Original bad code:**
    ```ruby
    class InventoryManager
  def self.reserve(product_id, quantity)
    product = Product.find(product_id)
    return false if product.stock < quantity

    product.update!(stock: product.stock - quantity)
    true
  end
end
    ```

    **Problems in the code:**
    - Time-of-check-to-time-of-use race
- Two requests can oversell
- No database constraint
- No lock

    **Production / scaling risks:**
    - Negative inventory
- Customer-facing order failures
- Data correction needed

    **Refactoring strategy:**
    - Add tests around current behavior before changing code.
    - Separate HTTP/controller concerns from business workflow.
    - Keep database transactions short.
    - Move slow side effects to jobs or outbox events.
    - Make retries/idempotency explicit.
    - Add instrumentation around the meaningful business operation.

    **Improved implementation:**
    ```ruby
    class InventoryManager
  def self.reserve(product_id, quantity)
    Product.transaction do
      product = Product.lock.find(product_id)
      return false if product.stock < quantity

      product.update!(stock: product.stock - quantity)
      true
    end
  end
end

# Alternative atomic SQL:
Product.where(id: product_id)
       .where("stock >= ?", quantity)
       .update_all(["stock = stock - ?", quantity]) == 1
    ```

    **Testing strategy:**
    - Concurrency spec with threads
- Test insufficient stock
- Test no negative stock
- DB constraint check stock >= 0

    **Staff-level things to mention:**
    - What invariant must be protected?
    - What should be synchronous vs asynchronous?
    - What can fail and how do we recover?
    - What metrics/traces prove the refactor helped?
    - What migration/rollout risk exists?

    **Follow-up interviewer questions:**
    - How would you roll this out safely in production?
    - What telemetry would you add?
    - What edge case could still fail?
    - Would this design still work at 10x traffic?

    ---

    ### Exercise 5. Callback abuse in User model

    **Interview category / level:** Mid / Senior Architecture Refactoring

    **Original bad code:**
    ```ruby
    class User < ApplicationRecord
  after_create :create_profile
  after_save :sync_to_crm, if: :saved_change_to_email?
  after_commit :send_welcome_email, on: :create

  def create_profile
    Profile.create!(user: self)
  end

  def sync_to_crm
    CrmClient.update_user(id: id, email: email)
  end

  def send_welcome_email
    UserMailer.welcome(self).deliver_now
  end
end
    ```

    **Problems in the code:**
    - Hidden side effects
- External CRM call inside lifecycle
- Creating users in tests triggers unrelated work
- Model violates SRP

    **Production / scaling risks:**
    - Bulk updates call CRM many times
- Slow tests
- Data migrations accidentally send emails/CRM calls

    **Refactoring strategy:**
    - Add tests around current behavior before changing code.
    - Separate HTTP/controller concerns from business workflow.
    - Keep database transactions short.
    - Move slow side effects to jobs or outbox events.
    - Make retries/idempotency explicit.
    - Add instrumentation around the meaningful business operation.

    **Improved implementation:**
    ```ruby
    module Users
  class Register
    def self.call(params:)
      User.transaction do
        user = User.create!(params)
        user.create_profile!
        OutboxEvent.create!(
          event_type: "user.registered",
          aggregate_id: user.id,
          payload: { user_id: user.id }
        )
        user
      end
    end
  end
end
    ```

    **Testing strategy:**
    - Model tests only validations
- Service test creates profile/outbox
- Worker tests CRM/email
- Migration safety test/notes

    **Staff-level things to mention:**
    - What invariant must be protected?
    - What should be synchronous vs asynchronous?
    - What can fail and how do we recover?
    - What metrics/traces prove the refactor helped?
    - What migration/rollout risk exists?

    **Follow-up interviewer questions:**
    - How would you roll this out safely in production?
    - What telemetry would you add?
    - What edge case could still fail?
    - Would this design still work at 10x traffic?

    ---

    ### Exercise 6. Class variable shared state in service object

    **Interview category / level:** Senior Runtime Refactoring

    **Original bad code:**
    ```ruby
    class CurrencyConverter
  @@rates = {}

  def self.convert(amount, from, to)
    @@rates[[from, to]] ||= ExternalFxApi.rate(from, to)
    amount * @@rates[[from, to]]
  end
end
    ```

    **Problems in the code:**
    - Class variable shared across threads/subclasses
- No TTL
- Non-atomic cache fill
- Stale financial rates
- No BigDecimal

    **Production / scaling risks:**
    - Incorrect money conversion
- Race conditions
- Hard-to-debug state leaks

    **Refactoring strategy:**
    - Add tests around current behavior before changing code.
    - Separate HTTP/controller concerns from business workflow.
    - Keep database transactions short.
    - Move slow side effects to jobs or outbox events.
    - Make retries/idempotency explicit.
    - Add instrumentation around the meaningful business operation.

    **Improved implementation:**
    ```ruby
    class CurrencyConverter
  CACHE_TTL = 15.minutes

  def self.convert(amount, from, to)
    rate = Rails.cache.fetch(["fx_rate", from, to], expires_in: CACHE_TTL) do
      BigDecimal(ExternalFxApi.rate(from, to).to_s)
    end

    BigDecimal(amount.to_s) * rate
  end
end
    ```

    **Testing strategy:**
    - Threaded test with concurrent calls
- Cache expiration test
- BigDecimal precision test
- External API failure test

    **Staff-level things to mention:**
    - What invariant must be protected?
    - What should be synchronous vs asynchronous?
    - What can fail and how do we recover?
    - What metrics/traces prove the refactor helped?
    - What migration/rollout risk exists?

    **Follow-up interviewer questions:**
    - How would you roll this out safely in production?
    - What telemetry would you add?
    - What edge case could still fail?
    - Would this design still work at 10x traffic?

    ---

    ### Exercise 7. Unbounded CSV export in memory

    **Interview category / level:** Mid / Senior Memory Refactoring

    **Original bad code:**
    ```ruby
    class OrdersExport
  def self.call(merchant)
    CSV.generate do |csv|
      merchant.orders.includes(:customer, :line_items).each do |order|
        csv << [order.id, order.customer.email, order.line_items.count]
      end
    end
  end
end
    ```

    **Problems in the code:**
    - Loads many orders and associations
- CSV stored in one giant string
- `line_items.count` may query per order
- Runs synchronously

    **Production / scaling risks:**
    - OOM
- GC pressure
- Slow request
- DB overload

    **Refactoring strategy:**
    - Add tests around current behavior before changing code.
    - Separate HTTP/controller concerns from business workflow.
    - Keep database transactions short.
    - Move slow side effects to jobs or outbox events.
    - Make retries/idempotency explicit.
    - Add instrumentation around the meaningful business operation.

    **Improved implementation:**
    ```ruby
    class OrdersExportJob
  include Sidekiq::Worker

  def perform(merchant_id)
    file = Tempfile.new(["orders", ".csv"])

    CSV(file) do |csv|
      csv << ["Order ID", "Customer Email", "Items Count"]

      Order.where(merchant_id: merchant_id)
           .joins(:customer)
           .left_outer_joins(:line_items)
           .select("orders.id, customers.email AS customer_email, COUNT(line_items.id) AS items_count")
           .group("orders.id, customers.id")
           .find_each(batch_size: 1000) do |order|
             csv << [order.id, order.customer_email, order.items_count]
           end
    end

    # upload to S3 and notify user
  ensure
    file&.close
    file&.unlink
  end
end
    ```

    **Testing strategy:**
    - Test batching
- Test CSV headers/rows
- Query count spec
- Memory profile for large dataset

    **Staff-level things to mention:**
    - What invariant must be protected?
    - What should be synchronous vs asynchronous?
    - What can fail and how do we recover?
    - What metrics/traces prove the refactor helped?
    - What migration/rollout risk exists?

    **Follow-up interviewer questions:**
    - How would you roll this out safely in production?
    - What telemetry would you add?
    - What edge case could still fail?
    - Would this design still work at 10x traffic?

    ---

    ### Exercise 8. Unsafe command execution

    **Interview category / level:** Senior Security Refactoring

    **Original bad code:**
    ```ruby
    class PdfConverter
  def self.call(input_path, output_name)
    system("wkhtmltopdf #{input_path} public/#{output_name}.pdf")
  end
end
    ```

    **Problems in the code:**
    - Command injection
- No timeout
- Unsafe output path
- Blocks worker indefinitely

    **Production / scaling risks:**
    - Remote code execution
- Worker exhaustion
- File overwrite

    **Refactoring strategy:**
    - Add tests around current behavior before changing code.
    - Separate HTTP/controller concerns from business workflow.
    - Keep database transactions short.
    - Move slow side effects to jobs or outbox events.
    - Make retries/idempotency explicit.
    - Add instrumentation around the meaningful business operation.

    **Improved implementation:**
    ```ruby
    class PdfConverter
  def self.call(input_path, output_name)
    safe_output = Rails.root.join("tmp/exports", "#{SecureRandom.uuid}.pdf")

    Timeout.timeout(30) do
      system("wkhtmltopdf", input_path.to_s, safe_output.to_s, exception: true)
    end

    safe_output
  end
end
    ```

    **Testing strategy:**
    - Security test for malicious output name
- Timeout test
- Error handling test
- Path traversal test

    **Staff-level things to mention:**
    - What invariant must be protected?
    - What should be synchronous vs asynchronous?
    - What can fail and how do we recover?
    - What metrics/traces prove the refactor helped?
    - What migration/rollout risk exists?

    **Follow-up interviewer questions:**
    - How would you roll this out safely in production?
    - What telemetry would you add?
    - What edge case could still fail?
    - Would this design still work at 10x traffic?

    ---

    ### Exercise 9. Bad service object doing multiple domains

    **Interview category / level:** Senior / Staff Architecture Refactoring

    **Original bad code:**
    ```ruby
    class OrderProcessingService
  def process(order)
    order.update!(status: "processing")
    charge = Stripe::Charge.create(amount: order.total, source: order.token)
    order.update!(status: "paid", transaction_id: charge.id)

    order.line_items.each do |item|
      WarehouseStock.find_by!(sku: item.sku).decrement!(:quantity, item.quantity)
    end

    NotificationMailer.receipt(order).deliver_now
  end
end
    ```

    **Problems in the code:**
    - Payment, order, inventory, notification tightly coupled
- Partial failure leaves inconsistent state
- External call mixed with DB changes
- Not idempotent

    **Production / scaling risks:**
    - Double charges
- Inventory drift
- Hard retries
- Slow request/jobs

    **Refactoring strategy:**
    - Add tests around current behavior before changing code.
    - Separate HTTP/controller concerns from business workflow.
    - Keep database transactions short.
    - Move slow side effects to jobs or outbox events.
    - Make retries/idempotency explicit.
    - Add instrumentation around the meaningful business operation.

    **Improved implementation:**
    ```ruby
    module Orders
  class MarkPaid
    def self.call(order:, payment_id:)
      Order.transaction do
        order.update!(status: "paid", transaction_id: payment_id)
        OutboxEvent.create!(event_type: "order.paid", aggregate_id: order.id, payload: { order_id: order.id })
      end
    end
  end
end

# Consumers:
# InventoryReservationJob listens to order.paid
# ReceiptNotificationJob listens to order.paid
    ```

    **Testing strategy:**
    - Payment idempotency test
- Outbox creation test
- Inventory consumer idempotency
- Partial failure/retry tests

    **Staff-level things to mention:**
    - What invariant must be protected?
    - What should be synchronous vs asynchronous?
    - What can fail and how do we recover?
    - What metrics/traces prove the refactor helped?
    - What migration/rollout risk exists?

    **Follow-up interviewer questions:**
    - How would you roll this out safely in production?
    - What telemetry would you add?
    - What edge case could still fail?
    - Would this design still work at 10x traffic?

    ---

    ### Exercise 10. No tenant scoping in controller

    **Interview category / level:** Mid / Senior Security Refactoring

    **Original bad code:**
    ```ruby
    class TasksController < ApplicationController
  def show
    task = Task.find(params[:id])
    render json: task
  end
end
    ```

    **Problems in the code:**
    - IDOR vulnerability
- User can access another tenant's task by ID
- Authorization missing

    **Production / scaling risks:**
    - Data breach
- Compliance incident
- Customer trust loss

    **Refactoring strategy:**
    - Add tests around current behavior before changing code.
    - Separate HTTP/controller concerns from business workflow.
    - Keep database transactions short.
    - Move slow side effects to jobs or outbox events.
    - Make retries/idempotency explicit.
    - Add instrumentation around the meaningful business operation.

    **Improved implementation:**
    ```ruby
    class TasksController < ApplicationController
  def show
    task = current_company.tasks.find(params[:id])
    authorize task
    render json: task
  end
end
    ```

    **Testing strategy:**
    - Request spec denies other company task
- Policy tests
- Audit suspicious denied attempts

    **Staff-level things to mention:**
    - What invariant must be protected?
    - What should be synchronous vs asynchronous?
    - What can fail and how do we recover?
    - What metrics/traces prove the refactor helped?
    - What migration/rollout risk exists?

    **Follow-up interviewer questions:**
    - How would you roll this out safely in production?
    - What telemetry would you add?
    - What edge case could still fail?
    - Would this design still work at 10x traffic?

    ---

    ### Exercise 11. Slow dashboard aggregate on every request

    **Interview category / level:** Senior Performance Refactoring

    **Original bad code:**
    ```ruby
    class DashboardController < ApplicationController
  def show
    render json: {
      open_tasks: current_project.tasks.where(status: "open").count,
      overdue_tasks: current_project.tasks.where("due_date < ?", Date.current).count,
      open_rfis: current_project.rfis.where(status: "open").count
    }
  end
end
    ```

    **Problems in the code:**
    - Repeated aggregate queries
- Runs for every dashboard load
- Can overload DB at scale

    **Production / scaling risks:**
    - High DB CPU
- Slow dashboard
- Poor cache hit strategy

    **Refactoring strategy:**
    - Add tests around current behavior before changing code.
    - Separate HTTP/controller concerns from business workflow.
    - Keep database transactions short.
    - Move slow side effects to jobs or outbox events.
    - Make retries/idempotency explicit.
    - Add instrumentation around the meaningful business operation.

    **Improved implementation:**
    ```ruby
    class ProjectDashboardSummary < ApplicationRecord
  belongs_to :project
end

class DashboardController < ApplicationController
  def show
    summary = Rails.cache.fetch(["dashboard", current_project.id, current_project.updated_at], expires_in: 5.minutes) do
      ProjectDashboardBuilder.call(current_project)
    end

    render json: summary
  end
end
    ```

    **Testing strategy:**
    - Cache invalidation tests
- Builder unit tests
- Metrics for cache hit rate
- Reconciliation job tests

    **Staff-level things to mention:**
    - What invariant must be protected?
    - What should be synchronous vs asynchronous?
    - What can fail and how do we recover?
    - What metrics/traces prove the refactor helped?
    - What migration/rollout risk exists?

    **Follow-up interviewer questions:**
    - How would you roll this out safely in production?
    - What telemetry would you add?
    - What edge case could still fail?
    - Would this design still work at 10x traffic?

    ---

    ### Exercise 12. Synchronous file upload through Rails

    **Interview category / level:** Senior Architecture Refactoring

    **Original bad code:**
    ```ruby
    class DocumentsController < ApplicationController
  def create
    file = params[:file]
    Document.create!(project: current_project, content: file.read, filename: file.original_filename)
    render json: { ok: true }
  end
end
    ```

    **Problems in the code:**
    - Stores binary in DB
- Reads full file into memory
- Rails handles large upload
- No virus scan
- No object storage

    **Production / scaling risks:**
    - OOM
- DB bloat
- Slow uploads
- Security risk

    **Refactoring strategy:**
    - Add tests around current behavior before changing code.
    - Separate HTTP/controller concerns from business workflow.
    - Keep database transactions short.
    - Move slow side effects to jobs or outbox events.
    - Make retries/idempotency explicit.
    - Add instrumentation around the meaningful business operation.

    **Improved implementation:**
    ```ruby
    class DocumentsController < ApplicationController
  def presign
    document = current_project.documents.create!(status: "pending_upload", filename: params[:filename])
    url = S3Presigner.upload_url(key: document.storage_key, content_type: params[:content_type])
    render json: { document_id: document.id, upload_url: url }
  end

  def complete
    document = current_project.documents.find(params[:id])
    document.update!(status: "uploaded")
    ProcessDocumentJob.perform_later(document.id)
    render json: document
  end
end
    ```

    **Testing strategy:**
    - Presign authorization tests
- Complete upload test
- Processing job test
- File type/size validation tests

    **Staff-level things to mention:**
    - What invariant must be protected?
    - What should be synchronous vs asynchronous?
    - What can fail and how do we recover?
    - What metrics/traces prove the refactor helped?
    - What migration/rollout risk exists?

    **Follow-up interviewer questions:**
    - How would you roll this out safely in production?
    - What telemetry would you add?
    - What edge case could still fail?
    - Would this design still work at 10x traffic?

    ---

    ### Exercise 13. Dynamic SQL with interpolation

    **Interview category / level:** Mid / Senior Security Refactoring

    **Original bad code:**
    ```ruby
    class UserSearch
  def self.call(term)
    User.where("name ILIKE '%#{term}%'")
  end
end
    ```

    **Problems in the code:**
    - SQL injection risk
- Cannot reuse prepared statements
- Leading wildcard causes slow scan without trigram index

    **Production / scaling risks:**
    - Security incident
- Slow search
- DB CPU spike

    **Refactoring strategy:**
    - Add tests around current behavior before changing code.
    - Separate HTTP/controller concerns from business workflow.
    - Keep database transactions short.
    - Move slow side effects to jobs or outbox events.
    - Make retries/idempotency explicit.
    - Add instrumentation around the meaningful business operation.

    **Improved implementation:**
    ```ruby
    class UserSearch
  def self.call(term)
    sanitized = "%#{ActiveRecord::Base.sanitize_sql_like(term)}%"
    User.where("name ILIKE ?", sanitized)
  end
end

# For scale, consider pg_trgm GIN index or search engine.
    ```

    **Testing strategy:**
    - SQL injection test
- Escaped wildcard test
- Performance plan with trigram index

    **Staff-level things to mention:**
    - What invariant must be protected?
    - What should be synchronous vs asynchronous?
    - What can fail and how do we recover?
    - What metrics/traces prove the refactor helped?
    - What migration/rollout risk exists?

    **Follow-up interviewer questions:**
    - How would you roll this out safely in production?
    - What telemetry would you add?
    - What edge case could still fail?
    - Would this design still work at 10x traffic?

    ---

    ### Exercise 14. Unbounded Redis list read

    **Interview category / level:** Senior Scaling Refactoring

    **Original bad code:**
    ```ruby
    class EventProcessor
  def self.drain
    events = Redis.current.lrange("events", 0, -1)
    events.each { |event| process(event) }
    Redis.current.del("events")
  end
end
    ```

    **Problems in the code:**
    - Reads entire list into memory
- Race can delete newly added events
- Redis single-thread blocking risk
- No ack/retry

    **Production / scaling risks:**
    - Lost events
- Redis CPU spike
- Worker OOM

    **Refactoring strategy:**
    - Add tests around current behavior before changing code.
    - Separate HTTP/controller concerns from business workflow.
    - Keep database transactions short.
    - Move slow side effects to jobs or outbox events.
    - Make retries/idempotency explicit.
    - Add instrumentation around the meaningful business operation.

    **Improved implementation:**
    ```ruby
    class EventProcessor
  BATCH_SIZE = 100

  def self.drain
    loop do
      events = Redis.current.lpop("events", BATCH_SIZE)
      break if events.blank?

      events.each { |event| process(event) }
    end
  end
end

# For reliability, prefer Redis Streams, Sidekiq, or database outbox.
    ```

    **Testing strategy:**
    - Batch processing test
- No-delete-new-events test
- Failure/retry strategy test

    **Staff-level things to mention:**
    - What invariant must be protected?
    - What should be synchronous vs asynchronous?
    - What can fail and how do we recover?
    - What metrics/traces prove the refactor helped?
    - What migration/rollout risk exists?

    **Follow-up interviewer questions:**
    - How would you roll this out safely in production?
    - What telemetry would you add?
    - What edge case could still fail?
    - Would this design still work at 10x traffic?

    ---

    ### Exercise 15. Swallowing exceptions

    **Interview category / level:** Mid / Senior Reliability Refactoring

    **Original bad code:**
    ```ruby
    class PaymentJob
  include Sidekiq::Worker

  def perform(payment_id)
    PaymentProcessor.call(payment_id)
  rescue StandardError
    puts "payment failed"
  end
end
    ```

    **Problems in the code:**
    - Failures hidden
- Sidekiq thinks job succeeded
- No alerting
- No context
- No retry

    **Production / scaling risks:**
    - Silent data loss
- Financial inconsistency
- No incident visibility

    **Refactoring strategy:**
    - Add tests around current behavior before changing code.
    - Separate HTTP/controller concerns from business workflow.
    - Keep database transactions short.
    - Move slow side effects to jobs or outbox events.
    - Make retries/idempotency explicit.
    - Add instrumentation around the meaningful business operation.

    **Improved implementation:**
    ```ruby
    class PaymentJob
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform(payment_id)
    PaymentProcessor.call(payment_id)
  rescue PaymentProcessor::PermanentFailure => e
    Payment.find(payment_id).update!(status: "failed", failure_reason: e.message)
  rescue StandardError => e
    Rails.logger.error(payment_id: payment_id, error: e.class.name, message: e.message)
    raise
  end
end
    ```

    **Testing strategy:**
    - Retry behavior test
- Permanent failure test
- Logs include context
- No swallowed transient errors

    **Staff-level things to mention:**
    - What invariant must be protected?
    - What should be synchronous vs asynchronous?
    - What can fail and how do we recover?
    - What metrics/traces prove the refactor helped?
    - What migration/rollout risk exists?

    **Follow-up interviewer questions:**
    - How would you roll this out safely in production?
    - What telemetry would you add?
    - What edge case could still fail?
    - Would this design still work at 10x traffic?

    ---

    ### Exercise 16. Unsafe cache key with permissions

    **Interview category / level:** Senior Security/Performance Refactoring

    **Original bad code:**
    ```ruby
    class TasksController < ApplicationController
  def index
    tasks = Rails.cache.fetch("project_tasks_#{params[:project_id]}") do
      Task.where(project_id: params[:project_id]).to_a
    end
    render json: tasks
  end
end
    ```

    **Problems in the code:**
    - Cache key ignores user permissions
- Could serve unauthorized tasks
- Caches ActiveRecord objects
- No invalidation strategy

    **Production / scaling risks:**
    - Data leak
- Stale data
- Memory overhead

    **Refactoring strategy:**
    - Add tests around current behavior before changing code.
    - Separate HTTP/controller concerns from business workflow.
    - Keep database transactions short.
    - Move slow side effects to jobs or outbox events.
    - Make retries/idempotency explicit.
    - Add instrumentation around the meaningful business operation.

    **Improved implementation:**
    ```ruby
    class TasksController < ApplicationController
  def index
    project = current_company.projects.find(params[:project_id])
    authorize project, :show_tasks?

    tasks = TasksQuery.new(project: project, user: current_user, params: params).call
    render json: TaskSerializer.render(tasks)
  end
end

# Cache permission-safe summaries only when key includes role/scope/version.
    ```

    **Testing strategy:**
    - Cross-role cache test
- Tenant isolation test
- Cache invalidation test

    **Staff-level things to mention:**
    - What invariant must be protected?
    - What should be synchronous vs asynchronous?
    - What can fail and how do we recover?
    - What metrics/traces prove the refactor helped?
    - What migration/rollout risk exists?

    **Follow-up interviewer questions:**
    - How would you roll this out safely in production?
    - What telemetry would you add?
    - What edge case could still fail?
    - Would this design still work at 10x traffic?

    ---

    ### Exercise 17. Non-idempotent webhook consumer

    **Interview category / level:** Senior Distributed Systems Refactoring

    **Original bad code:**
    ```ruby
    class StripeWebhooksController < ApplicationController
  def create
    event = JSON.parse(request.body.read)
    user = User.find_by!(stripe_id: event["customer"])
    user.increment!(:credits, event["credits"])
    head :ok
  end
end
    ```

    **Problems in the code:**
    - Webhook retries duplicate credits
- No event ID dedupe
- No signature verification
- No transaction

    **Production / scaling risks:**
    - Financial/user credit corruption
- Security risk
- Hard reconciliation

    **Refactoring strategy:**
    - Add tests around current behavior before changing code.
    - Separate HTTP/controller concerns from business workflow.
    - Keep database transactions short.
    - Move slow side effects to jobs or outbox events.
    - Make retries/idempotency explicit.
    - Add instrumentation around the meaningful business operation.

    **Improved implementation:**
    ```ruby
    class StripeWebhooksController < ApplicationController
  def create
    event = Stripe::Webhook.construct_event(request.body.read, request.env["HTTP_STRIPE_SIGNATURE"], ENV["STRIPE_SECRET"])

    ProcessStripeEventJob.perform_later(event.id, event.to_json)

    head :ok
  end
end

class ProcessStripeEventJob
  include Sidekiq::Worker

  def perform(event_id, payload)
    ProcessedEvent.create!(event_id: event_id)
    StripeEventProcessor.call(JSON.parse(payload))
  rescue ActiveRecord::RecordNotUnique
    return
  end
end
    ```

    **Testing strategy:**
    - Duplicate event test
- Signature verification test
- Processor idempotency test
- Malformed payload test

    **Staff-level things to mention:**
    - What invariant must be protected?
    - What should be synchronous vs asynchronous?
    - What can fail and how do we recover?
    - What metrics/traces prove the refactor helped?
    - What migration/rollout risk exists?

    **Follow-up interviewer questions:**
    - How would you roll this out safely in production?
    - What telemetry would you add?
    - What edge case could still fail?
    - Would this design still work at 10x traffic?

    ---

    ### Exercise 18. Long transaction with many unrelated locks

    **Interview category / level:** Staff Database Refactoring

    **Original bad code:**
    ```ruby
    class ProjectCloser
  def self.call(project)
    Project.transaction do
      project.tasks.update_all(status: "closed")
      project.rfis.update_all(status: "closed")
      project.documents.update_all(archived: true)
      ExternalArchiveClient.archive(project.id)
      project.update!(status: "closed")
    end
  end
end
    ```

    **Problems in the code:**
    - Huge transaction
- Locks many rows/tables
- External API inside transaction
- No batching
- Hard rollback semantics

    **Production / scaling risks:**
    - Deadlocks
- Lock queues
- Connection starvation
- Partial external state

    **Refactoring strategy:**
    - Add tests around current behavior before changing code.
    - Separate HTTP/controller concerns from business workflow.
    - Keep database transactions short.
    - Move slow side effects to jobs or outbox events.
    - Make retries/idempotency explicit.
    - Add instrumentation around the meaningful business operation.

    **Improved implementation:**
    ```ruby
    class ProjectCloser
  def self.call(project)
    project.update!(status: "closing")
    CloseProjectJob.perform_later(project.id)
  end
end

class CloseProjectJob
  include Sidekiq::Worker

  def perform(project_id)
    project = Project.find(project_id)

    CloseTasksJob.perform_async(project.id)
    CloseRfisJob.perform_async(project.id)
    ArchiveDocumentsJob.perform_async(project.id)

    # orchestrate via state machine/checkpoints, not one giant transaction
  end
end
    ```

    **Testing strategy:**
    - State transition tests
- Batch job idempotency
- Failure checkpoint tests
- DB lock monitoring

    **Staff-level things to mention:**
    - What invariant must be protected?
    - What should be synchronous vs asynchronous?
    - What can fail and how do we recover?
    - What metrics/traces prove the refactor helped?
    - What migration/rollout risk exists?

    **Follow-up interviewer questions:**
    - How would you roll this out safely in production?
    - What telemetry would you add?
    - What edge case could still fail?
    - Would this design still work at 10x traffic?

    ---

    ### Exercise 19. Overloaded concern hiding business workflow

    **Interview category / level:** Senior Architecture Refactoring

    **Original bad code:**
    ```ruby
    module Billable
  extend ActiveSupport::Concern

  included do
    after_save :calculate_invoice
  end

  def calculate_invoice
    invoice = Invoice.find_or_create_by!(project: project)
    invoice.update!(amount: tasks.sum(:cost))
    AccountingClient.sync(invoice)
  end
end
    ```

    **Problems in the code:**
    - Concern hides workflow
- External side effect in callback
- Model including concern now coupled to accounting
- Hard tests

    **Production / scaling risks:**
    - Unexpected accounting calls
- Slow saves
- Production side effects from simple updates

    **Refactoring strategy:**
    - Add tests around current behavior before changing code.
    - Separate HTTP/controller concerns from business workflow.
    - Keep database transactions short.
    - Move slow side effects to jobs or outbox events.
    - Make retries/idempotency explicit.
    - Add instrumentation around the meaningful business operation.

    **Improved implementation:**
    ```ruby
    module Billing
  class RecalculateInvoice
    def self.call(project:)
      invoice = Invoice.find_or_create_by!(project: project)
      invoice.update!(amount_cents: project.tasks.sum(:cost_cents))
      OutboxEvent.create!(event_type: "invoice.recalculated", aggregate_id: invoice.id, payload: { invoice_id: invoice.id })
      invoice
    end
  end
end
    ```

    **Testing strategy:**
    - Service unit test
- No side effect on model save test
- Outbox event test
- Accounting sync job test

    **Staff-level things to mention:**
    - What invariant must be protected?
    - What should be synchronous vs asynchronous?
    - What can fail and how do we recover?
    - What metrics/traces prove the refactor helped?
    - What migration/rollout risk exists?

    **Follow-up interviewer questions:**
    - How would you roll this out safely in production?
    - What telemetry would you add?
    - What edge case could still fail?
    - Would this design still work at 10x traffic?

    ---

    ### Exercise 20. Poor error response handling in API

    **Interview category / level:** Mid / Senior API Refactoring

    **Original bad code:**
    ```ruby
    def create
  task = Task.create!(task_params)
  render json: task
rescue => e
  render json: { error: e.message }, status: 500
end
    ```

    **Problems in the code:**
    - Catches everything
- Returns 500 for validation errors
- Leaks internal error messages
- No structured error format

    **Production / scaling risks:**
    - Bad client UX
- Security leakage
- Hard monitoring

    **Refactoring strategy:**
    - Add tests around current behavior before changing code.
    - Separate HTTP/controller concerns from business workflow.
    - Keep database transactions short.
    - Move slow side effects to jobs or outbox events.
    - Make retries/idempotency explicit.
    - Add instrumentation around the meaningful business operation.

    **Improved implementation:**
    ```ruby
    def create
  task = Task.create!(task_params)
  render json: task, status: :created
rescue ActiveRecord::RecordInvalid => e
  render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
end

# Global handlers in ApplicationController for common errors are better.
    ```

    **Testing strategy:**
    - Validation error spec
- 404 spec
- Internal error not leaked
- Error schema contract test

    **Staff-level things to mention:**
    - What invariant must be protected?
    - What should be synchronous vs asynchronous?
    - What can fail and how do we recover?
    - What metrics/traces prove the refactor helped?
    - What migration/rollout risk exists?

    **Follow-up interviewer questions:**
    - How would you roll this out safely in production?
    - What telemetry would you add?
    - What edge case could still fail?
    - Would this design still work at 10x traffic?

    ---

    ### Exercise 21. Bad test over-mocking implementation details

    **Interview category / level:** Senior Testing Refactoring

    **Original bad code:**
    ```ruby
    it "calls every private step" do
  service = described_class.new(task)
  expect(service).to receive(:validate!)
  expect(service).to receive(:update_task!)
  expect(service).to receive(:notify!)
  service.call
end
    ```

    **Problems in the code:**
    - Tests implementation not behavior
- Brittle refactors
- Can pass while feature broken

    **Production / scaling risks:**
    - Slow refactoring
- False confidence
- Poor design feedback

    **Refactoring strategy:**
    - Add tests around current behavior before changing code.
    - Separate HTTP/controller concerns from business workflow.
    - Keep database transactions short.
    - Move slow side effects to jobs or outbox events.
    - Make retries/idempotency explicit.
    - Add instrumentation around the meaningful business operation.

    **Improved implementation:**
    ```ruby
    it "completes the task and enqueues notification" do
  expect {
    described_class.call(task: task, actor: user)
  }.to change { task.reload.status }.to("completed")
   .and have_enqueued_job(TaskCompletedNotificationJob).with(task.id)
end
    ```

    **Testing strategy:**
    - Behavior tests
- Failure path tests
- Rollback test
- Contract tests for external boundaries

    **Staff-level things to mention:**
    - What invariant must be protected?
    - What should be synchronous vs asynchronous?
    - What can fail and how do we recover?
    - What metrics/traces prove the refactor helped?
    - What migration/rollout risk exists?

    **Follow-up interviewer questions:**
    - How would you roll this out safely in production?
    - What telemetry would you add?
    - What edge case could still fail?
    - Would this design still work at 10x traffic?

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
