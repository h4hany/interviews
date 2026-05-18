require 'set'

class Worker
  attr_reader :id, :name, :trade, :cost
  attr_accessor :is_available

  def initialize(id, name, trade, cost)
    @id = id
    @name = name
    @trade = trade
    @cost = cost
    @is_available = true
  end
end

class Ticket
  attr_accessor :id, :description, :trade, :status, :dependencies

  def initialize(id, description, trade)
    @id = id
    @description = description
    @trade = trade
    @status = :open
    @dependencies = [] # Array of Ticket IDs this ticket depends on
  end

  def blocked?(all_tickets)
    dependencies.any? do |dep_id|
      all_tickets[dep_id]&.status != :completed
    end
  end
end

class IssueBoard
  def initialize(workers)
    @workers = workers
    @tickets = {}
  end

  def add_ticket(ticket)
    @tickets[ticket.id] = ticket
  end

  def add_dependency(ticket_id, depends_on_id)
    # TODO: Add the dependency
    @tickets[ticket_id].dependencies << depends_on_id
  end

  # Advanced Requirement:
  # Return an array of all tickets that are currently unblocked
  # and have an available worker with the correct trade.
  def actionable_tickets
    # TODO: Implement the logic
    available_trades = @workers.select(&:is_available).map(&:trade).to_set
    @tickets.values.select do |ticket|
      ticket.status == :open &&
        available_trades.include?(ticket.trade) &&
        !ticket.blocked?(@tickets)
    end
  end

  # Assign the cheapest available worker to the ticket
  def assign_ticket(ticket_id)
    # TODO: Implement assignment, update worker availability and ticket status to :in_progress
    ticket = @tickets[ticket_id]

    # Guard clauses to fail fast
    return nil unless ticket
    return nil if ticket.status != :open || ticket.blocked?(@tickets)

    worker = find_cheapest_worker(ticket.trade)
    return nil unless worker

    # Update state
    worker.is_available = false
    ticket.status = :in_progress

    { ticket_id: ticket.id, assigned_to: worker.name }
  end

  private

  def find_cheapest_worker(trade)
    @workers
      .select { |w| w.is_available && w.trade == trade }
      .min_by(&:cost)
  end
end

# --- Test Case ---
workers = [
  Worker.new(1, "Alice", :electrical, 50),
  Worker.new(2, "Bob", :drywall, 30)
]
board = IssueBoard.new(workers)

t1 = Ticket.new(101, "Frame walls", :drywall)
t2 = Ticket.new(102, "Run wires", :electrical)
board.add_ticket(t1)
board.add_ticket(t2)

# Wires depend on framing
board.add_dependency(102, 101)

puts board.actionable_tickets.map(&:id) # Output: [101] (102 is blocked)

board.assign_ticket(101)
board.add_ticket(t1).status = :completed # Simulate work finishing

puts board.actionable_tickets.map(&:id) # Output: [102] (Unblocked now)
