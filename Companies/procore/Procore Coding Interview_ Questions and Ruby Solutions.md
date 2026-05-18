# Procore Coding Interview: Questions and Ruby Solutions

This document provides detailed reconstructions of the common coding problems asked during Procore's General Coding Interview, along with complete Ruby solutions and explanations.

## 1. Worker Allocation Problem

### Problem Description
You are tasked with building a system to manage worker allocations on a construction site. The interviewer provides a basic `Worker` class skeleton and a set of predefined test cases in CoderPad. You need to implement the logic to assign workers to specific tasks or locations based on their skills and availability.

**Key Requirements:**
*   Implement a `Worker` class with attributes like `id`, `name`, `skills`, and `availability`.
*   Implement an `AllocationSystem` class to manage a collection of workers.
*   Write a method `assign_worker(task_requirement)` that returns the best-fit worker for a given task.
*   **Dynamic Constraint:** Mid-interview, the interviewer may add a requirement that workers cannot be assigned to more than one task at a time, or that they must have a specific combination of skills.

### Ruby Solution

```ruby
class Worker
  attr_accessor :id, :name, :skills, :is_available

  def initialize(id, name, skills)
    @id = id
    @name = name
    @skills = skills # Array of strings, e.g., ["Carpentry", "Electrical"]
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

  # Basic requirement: Find a worker with the required skill
  def find_worker_by_skill(required_skill)
    @workers.find { |w| w.is_available && w.skills.include?(required_skill) }
  end

  # Advanced requirement: Assign worker and mark as unavailable
  def assign_worker(required_skill)
    worker = find_worker_by_skill(required_skill)
    if worker
      worker.is_available = false
      return worker
    end
    nil
  end

  # Requirement added mid-interview: Find workers with multiple skills
  def find_workers_with_all_skills(required_skills)
    @workers.select do |w|
      w.is_available && (required_skills - w.skills).empty?
    end
  end
end

# Example Usage & Test Cases
system = AllocationSystem.new
system.add_worker(Worker.new(1, "Alice", ["Carpentry", "Plumbing"]))
system.add_worker(Worker.new(2, "Bob", ["Electrical"]))

# Test 1: Simple assignment
assigned = system.assign_worker("Carpentry")
puts "Assigned: #{assigned.name}" if assigned # Output: Alice

# Test 2: Availability check
assigned_again = system.assign_worker("Plumbing")
puts "Assigned again: #{assigned_again.name}" if assigned_again.nil? # Output: nil (Alice is busy)
```

### Explanation
*   **Data Structure:** Using an array to store `Worker` objects is simple and effective for the initial requirements.
*   **Skill Matching:** The `(required_skills - w.skills).empty?` trick is a clean way in Ruby to check if one array is a subset of another.
*   **State Management:** The `is_available` flag handles the dynamic constraint of preventing double-booking.

---

## 2. Punch List Management Problem

### Problem Description
A "Punch List" is a list of tasks that must be completed at the end of a construction project. You need to design a system to track these items, their status, and who is responsible for them.

**Key Requirements:**
*   Create a `PunchItem` class with `id`, `description`, `status` (e.g., `:open`, `:in_progress`, `:completed`), and `assignee_id`.
*   Implement a `PunchList` class to manage these items.
*   Write methods to:
    *   Add a new item.
    *   Update the status of an item.
    *   Filter items by status or assignee.
    *   Calculate the percentage of completed items.

### Ruby Solution

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

# Example Usage & Test Cases
my_list = PunchList.new
my_list.add_item("Fix leaky faucet", 101)
my_list.add_item("Paint front door")
my_list.add_item("Install light fixtures", 102)

my_list.update_status(1, :completed)

puts "Completed Items: #{my_list.filter_by_status(:completed).size}" # Output: 1
puts "Completion %: #{my_list.completion_percentage}%" # Output: 33.33%
```

### Explanation
*   **Storage:** Using a Hash (`@items = {}`) keyed by `id` allows for O(1) lookup when updating status, which is more efficient than an array for large lists.
*   **Symbols:** Using Ruby symbols (`:open`, `:completed`) for statuses is idiomatic and memory-efficient.
*   **Float Conversion:** In `completion_percentage`, `.to_f` is crucial to ensure floating-point division rather than integer division.

---

## Interview Tips for Procore
1.  **Ruby Idioms:** Use methods like `find`, `select`, and `count` instead of manual loops.
2.  **Edge Cases:** Always check if the list is empty before calculating percentages or finding items.
3.  **Refactoring:** If the requirements change (e.g., adding a "priority" field), show the interviewer how you would update your classes cleanly.
4.  **Communication:** Explain *why* you chose a Hash over an Array or vice versa. Procore values communication as much as coding skill.
