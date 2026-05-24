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

  # Returns worker emails that can do the trade
  # sorted alphabetically
  def suitable_workers(trade)
    # @workers.select{|worker| worker.trades.include?(trade)}.map(&:email).sort
    @workers_by_trades[trade].map(&:email).sort
  end

  # Schedule trades for one day
  # - worker cannot work twice in same day
  # - choose cheapest available worker
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

  # Schedule all trades across multiple days
  # using minimum number of days possible
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

  private

  def get_worker(trade, used_workers)
    @workers
      .select do |w|
      w.trades.include?(trade) && !used_workers.include?(w.email)
    end
      .min_by(&:cost)
  end
end

class Worker
  attr_reader :email, :trades, :cost

  def initialize(email, trades, cost)
    @email = email
    @trades = trades
    @cost = cost
  end
end

Trade = Struct.new(:name)

BRICKWORK = :brickwork
CEMENT = :cement
DRYWALL = :drywall

require 'set'

workers = [
  Worker.new("alice@example.com", [BRICKWORK, DRYWALL], 30),
  Worker.new("bob@brickwork.com", [BRICKWORK], 20),
  Worker.new("charlie@cement.com", [CEMENT], 10),
  Worker.new("wally@walls.com", [CEMENT, DRYWALL], 15)
]

# scheduler = WorkScheduler.new(workers)
#
# p scheduler.suitable_workers(CEMENT)
#
# p scheduler.schedule_one_day([
#                                CEMENT,
#                                BRICKWORK,
#                                DRYWALL
#                              ])
#
# p scheduler.schedule_all_tasks([
#                                  CEMENT,
#                                  CEMENT,
#                                  BRICKWORK,
#                                  DRYWALL
#                                ])
def min_meeting_rooms(intervals)
  # [[0,30],[5,10],[15,20]]
  return 0 if intervals.empty?

  starts = intervals.map { |i| i[0] }.sort
  ends = intervals.map { |i| i[1] }.sort
  puts starts.inspect
  puts ends.inspect
  rooms = 0
  end_ptr = 0

  starts.each do |start_time|
    if start_time >= ends[end_ptr]
      # A room freed up, move the end pointer
      end_ptr += 1
    else
      # We need a new room
      rooms += 1
    end
  end

  puts rooms
end
min_meeting_rooms([[0,30],[5,10],[15,20]])
