#!/user/bin/ruby
# https://leetcode.com/problems/jump-game/
def can_jump(nums)
  max_jump = 0
  nums.size.times do |i|
    return false if max_jump < i
    puts max_jump
    puts i + nums[i]
    max_jump = [max_jump, i + nums[i]].max
    puts ' ---------------------------'
  end
  true
end

def can_jump2(nums)
  start = 0
  length = nums.length
  return true if nums.length == 1
  while start < length
    next_jump = (start == 0) ? 1 : nums[start]
    start += next_jump
    if start == length - 1
      return true
    elsif  nums[start] == 0
      return false
    elsif start >= length
      return false
    end
  end
  false
end

nums = [2, 3, 1, 1, 4]
nums = [0,1]

puts can_jump2(nums)
