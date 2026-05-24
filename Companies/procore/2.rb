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
system.add_worker(Worker.new(1, "Alice", %w[Carpentry Plumbing]))
system.add_worker(Worker.new(2, "Bob", ["Electrical"]))

# Test 1: Simple assignment
assigned = system.assign_worker("Carpentry")
puts "Assigned: #{assigned.name}" if assigned # Output: Alice

# Test 2: Availability check
assigned_again = system.assign_worker("Plumbing")
puts "Assigned again: #{assigned_again.name}" if assigned_again.nil? # Output: nil (Alice is busy)
