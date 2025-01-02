# https://leetcode.com/problems/maximum-product-subarray/
# @param {Integer[]} nums
# @return {Integer}
def max_product(nums)
  return 0 if nums.length == 0
  min_so_far, max_so_far, result = nums.first, nums.first, nums.first
  (1..(nums.length - 1)).each { |i|
    res = [nums[i], max_so_far * nums[i], min_so_far * nums[i]]
    max_so_far = res.max
    min_so_far = res.min
    result = [result, max_so_far].max
  }
  result
end
def max_product2(nums)
  min = 1
  max = 1
  result = -1.0/0.0
  nums.each do |num|
    prev_min = min
    min = [min*num, max*num, num].min
    max = [prev_min*num, max*num, num].max
    result = [max, result].max
  end
  result
end
nums = [2,3,-2,4]
puts max_product(nums)
