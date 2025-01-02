# https://leetcode.com/problems/arithmetic-slices/
#!/user/bin/ruby
# @param {Integer[]} nums
# @return {Integer}
def number_of_arithmetic_slices(nums)
  res, prev = 0, 0
  (2...nums.size).each { |i|
    (nums[i] - nums[i - 1] == nums[i - 1] - nums[i - 2]) ? prev += 1 : (prev = 0)
    res += prev
  }
  res
end

nums = [1, 2, 3, 4]
puts number_of_arithmetic_slices(nums)
