# rate_limiter.rb
# Concept: Distributed Rate Limiting for high scale (1M+ users)
# Pattern: Sliding Window Log (using Redis Sorted Sets)

require 'time'

# Simulating a Redis client for educational purposes
class MockRedis
  def initialize
    @storage = {} # Key: user_id, Value: Array of timestamps (sorted)
  end

  # Simulated ZADD: Adds a timestamp to the user's set
  def zadd(key, score, member)
    @storage[key] ||= []
    @storage[key] << score
    @storage[key].sort!
  end

  # Simulated ZREMRANGEBYSCORE: Removes timestamps older than the window
  def zremrangebyscore(key, min, max)
    return unless @storage[key]
    @storage[key].reject! { |ts| ts < max }
  end

  # Simulated ZCARD: Returns the number of requests in the current window
  def zcard(key)
    @storage[key]&.size || 0
  end

  # Simulated EXPIRE: Ensures data isn't stored forever
  def expire(key, seconds)
    # In real Redis, this would set a TTL
  end
end

class RateLimiter
  attr_reader :redis, :limit, :window_size

  def initialize(redis, limit: 100, window_size: 60)
    @redis = redis
    @limit = limit           # max requests
    @window_size = window_size # window in seconds
  end

  def allowed?(user_id)
    key = "rate_limit:#{user_id}"
    now = Time.now.to_f
    window_start = now - @window_size

    # Step 1: Remove old requests outside the current window
    # In Redis: ZREMRANGEBYSCORE key 0 window_start
    @redis.zremrangebyscore(key, 0, window_start)

    # Step 2: Check current count
    # In Redis: ZCARD key
    current_count = @redis.zcard(key)

    if current_count < @limit
      # Step 3: Add current request
      # In Redis: ZADD key now now
      @redis.zadd(key, now, now)
      @redis.expire(key, @window_size)
      true
    else
      false
    end
  end
end

# --- Interview Clarification ---
# 1. Why Sliding Window?
#    - Fixed window has a "burst" problem at the edges (double the limit in a short time).
#    - Sliding window is more accurate but uses more memory (stores every timestamp).
# 
# 2. How to handle 1M users?
#    - Redis Cluster: Distribute keys across multiple Redis nodes using hashing (CRC16).
#    - Memory: Each timestamp is ~8 bytes. 100 requests/user * 1M users = 100M timestamps = ~800MB - 1GB.
#      Very manageable for a Redis cluster.
#
# 3. Performance:
#    - Use Lua scripts to combine ZREMRANGEBYSCORE, ZCARD, and ZADD into a single atomic operation.
#    - This avoids race conditions and reduces network round-trips.

# Example Usage:
if __FILE__ == $0
  redis = MockRedis.new
  limiter = RateLimiter.new(redis, limit: 5, window_size: 10)

  user_id = "user_123"
  
  puts "Sending 7 requests for #{user_id}..."
  7.times do |i|
    if limiter.allowed?(user_id)
      puts "Request #{i+1}: Allowed"
    else
      puts "Request #{i+1}: Rate Limited (429 Too Many Requests)"
    end
  end
end
