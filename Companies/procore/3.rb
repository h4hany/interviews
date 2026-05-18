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
