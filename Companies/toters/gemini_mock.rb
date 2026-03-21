class FlashPromotion

  def initialize(payload, current_user)
    @idempotency_key = payload["idempotency_key"]
    @user_id = current_user.id
    @promotion_id = payload["promotion_id"]
  end

  def call
    already_claimed = redis.setnx("claim:#{user_id}", 1)
    return "claimed" unless already_claimed
    result = redis.eval(lua_script, keys: [key])

    if allowed == 1
      enqueue_to_queue(user_id)
      return "SUCCESS 🎉"
    else
      return "FAILED ❌"
    end
  end

  def enqueue_to_queue
    here the kafa process sucess
  end
  def lua_script
    <<~LUA
      local current = redis.call("GET", KEYS[1])
      if not current then current = 0 else current = tonumber(current) end

      if current < 1000 then
        redis.call("INCR", KEYS[1])
        return 1
      else
        return 0
      end
    LUA
  end
end
