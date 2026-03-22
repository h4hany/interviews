# throttling.rb
# Concept: API Throttling (Protecting backend with steady flow)
# Pattern: Leaky Bucket Algorithm

require 'time'

# Simulating a Redis client for distributed state
class MockRedis
  def initialize
    @buckets = {} # Key: service_id, Value: { count: current_fill, last_update: timestamp }
  end

  def get_bucket(key)
    @buckets[key] || { count: 0, last_update: Time.now.to_f }
  end

  def set_bucket(key, data)
    @buckets[key] = data
  end
end

class LeakyBucketThrottler
  attr_reader :redis, :capacity, :leak_rate

  def initialize(redis, capacity: 10, leak_rate: 2.0)
    @redis = redis
    @capacity = capacity  # Max size of the bucket (burst capacity)
    @leak_rate = leak_rate # Requests per second (steady output flow)
  end

  def allowed?(service_id)
    key = "throttle:#{service_id}"
    now = Time.now.to_f
    
    bucket = @redis.get_bucket(key)
    
    # Step 1: Calculate "leaked" amount since last update
    time_passed = now - bucket[:last_update]
    leaked_amount = time_passed * @leak_rate
    
    # Step 2: Update bucket count (cannot go below 0)
    new_count = [0, bucket[:count] - leaked_amount].max
    
    # Step 3: Check if request can fit in the bucket
    if new_count + 1 <= @capacity
      new_count += 1
      @redis.set_bucket(key, { count: new_count, last_update: now })
      true
    else
      # Update the bucket even on failure to ensure last_update is fresh
      @redis.set_bucket(key, { count: new_count, last_update: now })
      false
    end
  end
end

# --- Interview Clarification ---
# 1. Leaky Bucket vs Token Bucket:
#    - Token Bucket: Allows bursts but limits the average rate. Good for user-level API limits.
#    - Leaky Bucket: Forces a steady output rate regardless of bursts. Good for protecting 
#      databases or legacy services that can only handle exactly X requests per second.
#
# 2. Distributed Implementation:
#    - In Redis, we store `last_update` and `count`.
#    - We use a Lua script to ensure the "get-calculate-set" logic is atomic.
#    - This prevents race conditions where multiple requests leak the bucket simultaneously.
#
# 3. Use Case: Shaping Traffic
#    - If you have a background job system that can only process 10 jobs/sec, you wrap 
#      it in a Leaky Bucket. Bursts are queued or rejected, ensuring the downstream
#      system never sees more than 10 req/s.

# Example Usage:
if __FILE__ == $0
  redis = MockRedis.new
  # Capacity 5, processes 1 request every 0.5 seconds (2 req/s)
  throttler = LeakyBucketThrottler.new(redis, capacity: 5, leak_rate: 2.0)

  service_name = "payment_gateway"
  
  puts "Simulating a burst of 10 requests for #{service_name}..."
  10.times do |i|
    if throttler.allowed?(service_name)
      puts "Request #{i+1}: Allowed (Bucket Count: #{redis.get_bucket("throttle:#{service_name}")[:count].round(2)})"
    else
      puts "Request #{i+1}: Throttled (Bucket is Full)"
    end
  end

  puts "\nWaiting 2 seconds for bucket to leak..."
  sleep 2

  puts "Sending 3 more requests..."
  3.times do |i|
    if throttler.allowed?(service_name)
      puts "Request #{i+11}: Allowed"
    else
      puts "Request #{i+11}: Throttled"
    end
  end
end
