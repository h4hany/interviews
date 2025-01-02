#!/user/bin/ruby
# https://leetcode.com/problems/broken-calculator/
# @param {Integer} start_value
# @param {Integer} target
# @return {Integer}
def broken_calc(start_value, target)
  return 0 if start_value == target
  # return start_value - target if start_value > target
  if start_value < target && target % 2 == 0
    return 1 + broken_calc(start_value, target / 2)
  end
  1 + broken_calc(start_value, target + 1)
end

start_value = 5
target = 8
puts broken_calc(start_value, target)

