# flash_sale.rb
# Concept: High Concurrency Flash Sale (1000 items, 200k+ requests in a burst)
# Pattern: Atomic Counter (Redis DECR) + Pre-heat Cache + Early Termination

# Simulating Redis for educational purposes
class MockRedis
  attr_reader :stock

  def initialize(stock_count)
    @stock = stock_count # Key: product_id:stock
  end

  # Simulated Lua script execution (Atomic operation)
  # In Redis, Lua scripts are atomic.
  def eval_buy_script(product_id)
    if @stock > 0
      @stock -= 1
      return true # Success
    else
      return false # Sold Out
    end
  end

  # Get current stock
  def get(key)
    @stock
  end
end

class FlashSaleService
  attr_reader :redis, :product_id

  def initialize(redis, product_id: "phone_001")
    @redis = redis
    @product_id = product_id
  end

  def process_request(user_id)
    # Step 1: Atomic check and decrement (The Lua script approach)
    # This prevents race conditions where 1000.times { thread } leads to -50 stock.
    success = @redis.eval_buy_script(@product_id)

    if success
      # Step 2: Push to an asynchronous queue for actual order creation
      # NEVER create a database record synchronously in a flash sale burst.
      # Database write throughput is the bottleneck (e.g., 500-2k TPS).
      # Redis throughput is 100k+ TPS.
      enqueue_order(user_id, @product_id)
      { status: 200, message: "Order placed! Processing..." }
    else
      # Step 3: Return early. 200k-1000 users get this quickly.
      { status: 429, message: "Sold Out" }
    end
  end

  private

  def enqueue_order(user_id, product_id)
    # Simulating a push to Sidekiq or SQS
    # puts "[Queue] Processing order for #{user_id}..."
  end
end

# --- Interview Clarification ---
# 1. Handling 40k RPS (200k in 5s):
#    - Redis can easily handle 40k RPS on a single instance.
#    - To scale even further, use Redis Sentinel/Cluster.
# 
# 2. Database Protection:
#    - Use "Return Early" (Step 3). Only the 1000 lucky requests hit the next step.
#    - The actual DB write happens in the background via a queue. This is "Load Leveling".
#
# 3. Consistency vs Availability:
#    - In a flash sale, we prioritize "Strong Consistency" for stock count to avoid overselling.
#    - Redis provides atomicity for this. 
#
# 4. Global Scale:
#    - Use CDN to cache static assets (HTML/JS/Images) of the flash sale page.
#    - Only the "Buy" button POST request goes to the FlashSaleService.

# Example Usage:
if __FILE__ == $0
  puts "Pre-heating cache with 10 items..."
  redis = MockRedis.new(10)
  service = FlashSaleService.new(redis)

  puts "Simulating 15 rapid requests..."
  15.times do |i|
    user_id = "user_#{i}"
    result = service.process_request(user_id)
    puts "Request #{i+1}: #{result[:message]} (Status: #{result[:status]})"
  end

  puts "\nFinal Stock: #{redis.get("phone_001")}"
end
