class WorkScheduler
  def initialize(workers)
    @workers = workers
  end

  # Returns worker emails that can do the trade
  # sorted alphabetically
  def suitable_workers(trade)
    @workers
      .select { |worker| worker.trades.include?(trade) }
      .map(&:email)
      .sort
  end

  # Schedule trades for one day
  # - worker cannot work twice in same day
  # - choose cheapest available worker
  def schedule_one_day(trades)
    scheduled_workers = []
    used_workers = Set.new

    trades.each do |trade|
      worker = get_worker(trade, used_workers)

      next unless worker

      scheduled_workers << worker.email
      used_workers.add(worker.email)
    end

    scheduled_workers
  end

  # Schedule all trades across multiple days
  # using minimum number of days possible
  def schedule_all_tasks(trades)
    remaining_trades = trades.dup
    result = []

    until remaining_trades.empty?
      used_workers = Set.new
      day_schedule = []
      completed_indexes = []

      remaining_trades.each_with_index do |trade, index|
        worker = get_worker(trade, used_workers)

        next unless worker

        day_schedule << worker.email
        used_workers.add(worker.email)
        completed_indexes << index
      end

      completed_indexes.reverse_each do |index|
        remaining_trades.delete_at(index)
      end

      result << day_schedule
    end

    result
  end

  private

  def get_worker(trade, used_workers)
    @workers
      .select do |w| w.trades.include?(trade) && !used_workers.include?(w.email)
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

scheduler = WorkScheduler.new(workers)

p scheduler.suitable_workers(CEMENT)

p scheduler.schedule_one_day([
                               CEMENT,
                               BRICKWORK,
                               DRYWALL
                             ])

p scheduler.schedule_all_tasks([
                                 CEMENT,
                                 CEMENT,
                                 BRICKWORK,
                                 DRYWALL
                               ])
