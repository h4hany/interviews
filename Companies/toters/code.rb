def active_deliveries(orders)
  events = Hash.new(0)

  orders.each do |order|
    start_time = order[:timestamp]
    end_time = start_time + order[:delivery_duration]

    events[start_time] += 1
    events[end_time] -= 1
  end
  current_active = 0
  max_active = 0

  events.keys.sort.each do |time|
    current_active += events[time]
    max_active = [max_active, current_active].max
  end

  max_active
end

orders = [
  { order_id: 1, timestamp: 0, delivery_duration: 5 },
  { order_id: 2, timestamp: 1, delivery_duration: 2 },
  { order_id: 3, timestamp: 3, delivery_duration: 3 }
]
# orders = [
#   { order_id: 1, timestamp: 2, delivery_duration: 4 },
#   { order_id: 2, timestamp: 3, delivery_duration: 3 },
#   { order_id: 3, timestamp: 5, delivery_duration: 2 },
#   { order_id: 4, timestamp: 6, delivery_duration: 1 }
# ]
# puts active_deliveries(orders)
# 0   1   2   3   4   5   6   7   8   9
# order_______________1
#     order___2
#             order_______3

def allow_request(user_id, timestamp, users_data)
  window_size = 10
  max_requests = 3

  users_data[user_id] ||= []
  #[1,2,3] 11
  # 11 - 10
  users_data[user_id].reject! do |t|
    t <= timestamp - window_size
  end
  if users_data[user_id].length >= max_requests
    return false
  end
  users_data[user_id] << timestamp

  true
end

users_data = {}

# puts allow_request("u1", 1, users_data) # true
# puts allow_request("u1", 2, users_data) # true
# puts allow_request("u1", 3, users_data) # true
# puts allow_request("u1", 11, users_data) # true (old requests expired)
# puts allow_request("u1", 12, users_data) # true (old requests expired)

# Problem 2 — Top K Active Restaurants
# 👨‍💻 Interviewer 1
# 📌 Problem
#
# You are given a stream of orders:
#
#                             { restaurant_id: "r1", timestamp: 123 }
#
# Return the top K restaurants with most orders in the last 60 minutes.
#
#   🎯 Requirements
# Efficient updates (real-time stream)
# Handle large scale (millions of orders)
# Optimize for fast queries
# 🎯 What we test
# Heap / priority queue
# Sliding window + counting
# Trade-offs between accuracy vs performance
def top_k(orders, k, current_time)
  window_start = current_time - 3600

  counts = Hash.new(0)

  # Step 1: filter + count
  orders.each do |order|
    if order[:timestamp] >= window_start
      counts[order[:restaurant_id]] += 1
    end
  end

  # Step 2: sort and take top K
  counts.sort_by { |_, count| -count }
        .first(k)
        .map { |restaurant_id, _| restaurant_id }
end

orders = [
  { restaurant_id: "r1", timestamp: 100 },
  { restaurant_id: "r2", timestamp: 200 },
  { restaurant_id: "r1", timestamp: 250 },
  { restaurant_id: "r3", timestamp: 300 },
  { restaurant_id: "r2", timestamp: 1200 },
  { restaurant_id: "r1", timestamp: 1800 },
  { restaurant_id: "r4", timestamp: 2000 },
  { restaurant_id: "r2", timestamp: 2200 },
  { restaurant_id: "r3", timestamp: 2500 },
  { restaurant_id: "r3", timestamp: 2600 },
  { restaurant_id: "r1", timestamp: 3000 },
  { restaurant_id: "r5", timestamp: 3200 },
  { restaurant_id: "r2", timestamp: 3500 },
  { restaurant_id: "r1", timestamp: 3700 },
  { restaurant_id: "r3", timestamp: 3800 },
  { restaurant_id: "r4", timestamp: 3900 }
]
# puts top_k(orders, 2, 4000)

driver_delivery = {}

def add_delivery(driver_id, eta, driver_delivery)
  if driver_delivery[driver_id]
    driver_delivery[driver_id][:sum_eta] += eta
    driver_delivery[driver_id][:count] += 1
  else
    driver_delivery[driver_id] = {
      sum_eta: eta,
      count: 1
    }
  end
end

def get_average(driver_id, driver_delivery)

  driver_delivery[driver_id][:sum_eta].to_f / driver_delivery[driver_id][:count]
end

deliveries = [
  { driver_id: "d1", eta: 5 },
  { driver_id: "d1", eta: 7 },
  { driver_id: "d2", eta: 3 }
]
