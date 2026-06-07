# Coding Problems & Ruby Solutions

> Includes known Procore coding problems AND the WorkScheduler refactoring exercise.

---

# 1. Worker Allocation Problem (Known Coding Round)

## Problem Description
Build a system to manage worker allocations on a construction site. Given a basic `Worker` class skeleton and predefined test cases:
- Implement worker assignment based on skills and availability
- Handle dynamic constraints added mid-interview (e.g., no double-booking)

## Solution
```ruby
class Worker
  attr_accessor :id, :name, :skills, :is_available

  def initialize(id, name, skills)
    @id = id
    @name = name
    @skills = skills   # Array: ["Carpentry", "Electrical"]
    @is_available = true
  end
end

class AllocationSystem
  def initialize
    @workers = []
  end

  def add_worker(worker)
    @workers << worker
  end

  def find_worker_by_skill(required_skill)
    @workers.find { |w| w.is_available && w.skills.include?(required_skill) }
  end

  def assign_worker(required_skill)
    worker = find_worker_by_skill(required_skill)
    if worker
      worker.is_available = false
      return worker
    end
    nil
  end

  # Mid-interview addition: find workers with ALL required skills
  def find_workers_with_all_skills(required_skills)
    @workers.select do |w|
      w.is_available && (required_skills - w.skills).empty?
    end
  end
end
```

### Key Techniques
- `(required_skills - w.skills).empty?` — clean Ruby array subset check
- `is_available` flag for state management
- Hash storage for O(1) lookup (if requirements grow)

---

# 2. Punch List Management Problem (Known Coding Round)

## Problem Description
Design a punch list tracking system with status management and completion tracking.

## Solution
```ruby
class PunchItem
  attr_accessor :id, :description, :status, :assignee_id

  def initialize(id, description, assignee_id = nil)
    @id = id
    @description = description
    @status = :open
    @assignee_id = assignee_id
  end
end

class PunchList
  def initialize
    @items = {}
  end

  def add_item(description, assignee_id = nil)
    id = @items.size + 1
    new_item = PunchItem.new(id, description, assignee_id)
    @items[id] = new_item
    new_item
  end

  def update_status(id, new_status)
    item = @items[id]
    item.status = new_status if item
  end

  def filter_by_status(status)
    @items.values.select { |item| item.status == status }
  end

  def completion_percentage
    return 0.0 if @items.empty?
    completed_count = @items.values.count { |item| item.status == :completed }
    (completed_count.to_f / @items.size * 100).round(2)
  end
end
```

### Key Techniques
- Hash keyed by `id` for O(1) lookup
- Ruby symbols for status (`:open`, `:completed`) — idiomatic and memory-efficient
- `.to_f` for floating-point division

---

# 3. WorkScheduler — Refactoring Exercise

## Context
You passed the coding round with this. In the specialized technical interview, they may ask you to:
- Identify risks in the original code
- Refactor it
- Add tests
- Instrument it with OpenTelemetry
- Discuss production readiness

## Original Code (What You Submitted)
```ruby
class WorkScheduler
  def initialize(workers)
    @workers = workers
    @workers_by_trades = Hash.new { |h, k| h[k] = [] }
    @workers.each do |worker|
      worker.trades.each do |trade|
        @workers_by_trades[trade] << worker
      end
    end
    @workers_by_trades.values.each { |list| list.sort_by!(&:cost) }
  end

  def suitable_workers(trade)
    @workers_by_trades[trade].map(&:email).sort
  end

  def schedule_one_day(trades)
    used_workers = Set.new
    schedule_workers = []
    trades.each do |trade|
      worker = @workers_by_trades[trade].find { |w| !used_workers.include?(w.email) }
      if worker
        used_workers.add(worker.email)
        schedule_workers << worker.email
      end
    end
    schedule_workers
  end

  def schedule_all_tasks(trades)
    result = []
    remaining_trades = trades.dup
    until remaining_trades.empty?
      schedule_day = []
      used_workers = Set.new
      unfulfilled_trades = []
      remaining_trades.each do |trade|
        worker = @workers_by_trades[trade].find { |w| !used_workers.include?(w.email) }
        if worker
          used_workers.add(worker.email)
          schedule_day << worker.email
        else
          unfulfilled_trades << trade
        end
      end
      result << schedule_day
      remaining_trades = unfulfilled_trades
    end
    result
  end
end
```

## Identified Risks

### Risk 1: Infinite Loop ⚠️
If `remaining_trades` contains a trade with no workers, `schedule_day` stays empty and `unfulfilled_trades` never changes. Loop runs forever.

### Risk 2: Greedy Strategy May Not Minimize Days
The algorithm chooses cheapest available worker in input order. Not guaranteed to be globally optimal. For "minimum days," need bipartite matching.

### Risk 3: Returns Only Emails, Not Trade-Worker Pairs
Result is ambiguous — can't tell which worker was assigned to which trade.

### Risk 4: Non-Deterministic Tie-Breaking
Workers sorted by cost only. Same cost → input-order dependent. Should sort by `[cost, email]`.

### Risk 5: Dead Code
`get_worker` private method exists but is never used.

### Risk 6: Missing `require "set"`
`Set` must be explicitly required in standalone Ruby.

## Refactored Version

```ruby
require "set"

class WorkScheduler
  class UnschedulableTradeError < StandardError; end
  Assignment = Struct.new(:trade, :worker_email, keyword_init: true)

  def initialize(workers)
    @workers = workers
    @workers_by_trade = build_worker_index(workers)
  end

  def suitable_workers(trade)
    @workers_by_trade.fetch(trade, []).map(&:email).sort
  end

  def schedule_one_day(trades)
    used_worker_emails = Set.new
    trades.each_with_object([]) do |trade, assignments|
      worker = cheapest_available_worker_for(trade, used_worker_emails)
      next unless worker
      used_worker_emails.add(worker.email)
      assignments << Assignment.new(trade: trade, worker_email: worker.email)
    end
  end

  def schedule_all_tasks(trades)
    validate_schedulable!(trades)
    days = []
    remaining_trades = trades.dup

    until remaining_trades.empty?
      assignments = schedule_one_day(remaining_trades)
      raise UnschedulableTradeError, "No progress" if assignments.empty?

      scheduled_trades = assignments.map(&:trade)
      days << assignments
      remaining_trades = remove_scheduled_trades(remaining_trades, scheduled_trades)
    end
    days
  end

  private

  def build_worker_index(workers)
    workers.each_with_object(Hash.new { |h, k| h[k] = [] }) do |worker, index|
      worker.trades.each { |trade| index[trade] << worker }
    end.tap do |index|
      index.values.each { |list| list.sort_by! { |w| [w.cost, w.email] } }
    end
  end

  def cheapest_available_worker_for(trade, used_emails)
    @workers_by_trade.fetch(trade, []).find { |w| !used_emails.include?(w.email) }
  end

  def validate_schedulable!(trades)
    missing = trades.uniq.select { |t| @workers_by_trade.fetch(t, []).empty? }
    raise UnschedulableTradeError, "No workers for: #{missing.join(', ')}" unless missing.empty?
  end

  def remove_scheduled_trades(remaining, scheduled)
    counts = scheduled.tally
    remaining.reject do |trade|
      if counts[trade].to_i.positive?
        counts[trade] -= 1
        true
      end
    end
  end
end
```

### Improvements
- ✅ Prevents infinite loops
- ✅ Returns rich Assignment objects (trade + worker_email)
- ✅ Deterministic tie-breaking (cost, email)
- ✅ Explicit domain error class
- ✅ No dead code
- ✅ Single-responsibility methods
- ✅ Explicit `require "set"`

## RSpec Tests
```ruby
RSpec.describe WorkScheduler do
  let(:alice) { Worker.new("alice@example.com", ["plumbing", "electrical"], 100) }
  let(:bob)   { Worker.new("bob@example.com", ["plumbing"], 80) }
  let(:cara)  { Worker.new("cara@example.com", ["electrical"], 90) }
  subject(:scheduler) { described_class.new([alice, bob, cara]) }

  describe "#suitable_workers" do
    it "returns emails sorted alphabetically" do
      expect(scheduler.suitable_workers("plumbing")).to eq(["alice@example.com", "bob@example.com"])
    end
  end

  describe "#schedule_one_day" do
    it "assigns each worker at most once" do
      assignments = scheduler.schedule_one_day(["plumbing", "electrical"])
      emails = assignments.map(&:worker_email)
      expect(emails).to eq(emails.uniq)
    end

    it "chooses the cheapest available worker" do
      assignments = scheduler.schedule_one_day(["plumbing"])
      expect(assignments.first.worker_email).to eq("bob@example.com")
    end
  end

  describe "#schedule_all_tasks" do
    it "schedules all tasks across multiple days" do
      days = scheduler.schedule_all_tasks(["plumbing", "plumbing", "electrical"])
      expect(days.flatten.map(&:trade)).to contain_exactly("plumbing", "plumbing", "electrical")
    end

    it "raises error for impossible trades" do
      expect { scheduler.schedule_all_tasks(["roofing"]) }
        .to raise_error(WorkScheduler::UnschedulableTradeError)
    end
  end
end
```

## Complexity Analysis

| Method | Complexity |
|--------|-----------|
| `initialize` | O(W × K) + O(M log M) per trade group |
| `suitable_workers` | O(M log M) for email sorting |
| `schedule_one_day` | O(T × M) worst case |
| `schedule_all_tasks` | O(D × T × M) where D = number of days |

Where: W = workers, K = trades per worker, T = requested trades, M = workers per trade, D = days

---

# 4. Additional Coding Problems

## Equipment Rental Tracker
Track equipment allocation, daily rates, and usage history across construction projects.

## Minimum Cost Employee Schedule
Schedule employees for weekly job shifts, minimizing total cost while ensuring all shifts are covered.

---

# 5. Coding Interview Tips for Procore

1. **Ruby Idioms** — Use `find`, `select`, `map`, `count` instead of manual loops
2. **Edge Cases** — Always check empty collections before calculations
3. **Explain Data Structures** — Tell interviewer WHY you chose Hash over Array
4. **Adaptability** — Requirements change mid-interview; keep initial solution flexible
5. **Communication** — Think out loud, summarize problem back before coding
6. **State Management** — Show awareness of concurrent access and state mutations
