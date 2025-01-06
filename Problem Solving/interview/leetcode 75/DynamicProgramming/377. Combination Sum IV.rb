#!/user/bin/ruby
# https://leetcode.com/problems/combination-sum-iv/
# @param {Integer[]} nums
# @param {Integer} target
# @return {Integer}
def combination_sum4(nums, target)
  arr = nums.product(nums).select { |arr| arr.sum <= target }
  count = arr.select { |a| a.sum == target }.length
  arr = arr.select { |a| a.sum < target }
  puts arr.to_s
  hash = {}
  arr.each do |a|
    if nums.include?(target - a.sum)
      unless hash[a.join(',')]
        a.push(target - a.sum)
        count += 1
        hash[a.join(',')] = 1
      end
    end
  end
  count += 1 if nums.include?(1)
  count
end

def combination_sum42(nums, target)
  dp = [1] + Array.new(target, 0)
  (1..target).each do |s|
    nums.each do |n|
      dp[s] += dp[s - n] if s >= n
    end
  end
  dp[target]
end

nums = [1, 2, 3]
target = 4
puts combination_sum4(nums, target)
