class Equipment
  attr_reader :id, :type, :daily_rate

  def initialize(id, type, daily_rate)
    @id = id
    @type = type
    @daily_rate = daily_rate
  end
end

class RentalRequest
  attr_reader :request_id, :equipment_type, :start_day, :end_day

  def initialize(request_id, equipment_type, start_day, end_day)
    @request_id = request_id
    @equipment_type = equipment_type
    @start_day = start_day
    @end_day = end_day
  end

  def days
    (start_day..end_day).to_set
  end
end

class FleetManager
  def initialize(fleet)
    @fleet = fleet # Array of Equipment
    @schedule = {} # Suggestion: Map Equipment ID to an array of booked days
  end

  # Basic Requirement:
  # Can a specific piece of equipment be booked for the given days?
  def available?(equipment_id, start_day, end_day)
    # TODO: Return true if the equipment has no overlapping bookings
    requested_days = (start_day..end_day).to_set
    booked_days = @schedule[equipment_id]
    (requested_days & booked_days).empty?
  end

  # Mid-Interview Requirement:
  # Process an array of RentalRequests.
  # Fulfill as many as possible. If multiple pieces of equipment match the type,
  # pick the one with the lowest daily rate.
  # Return an array of fulfilled request IDs.
  def process_requests(requests)
    # TODO: Implement the booking logic
  end
end

# --- Test Case ---
fleet = [
  Equipment.new(1, :excavator, 500),
  Equipment.new(2, :excavator, 400), # Cheaper option
  Equipment.new(3, :crane, 1000)
]
manager = FleetManager.new(fleet)

requests = [
  RentalRequest.new("R1", :excavator, 1, 5),
  RentalRequest.new("R2", :excavator, 4, 8),
  RentalRequest.new("R3", :excavator, 2, 3)
]

# R1 books Equipment 2 (cheapest).
# R2 books Equipment 1 (Eq 2 is busy).
# R3 fails (both excavators are busy on days 2 and 3).
puts manager.process_requests(requests) # Output: ["R1", "R2"]
