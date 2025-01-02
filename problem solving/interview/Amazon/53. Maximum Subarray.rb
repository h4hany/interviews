# https://leetcode.com/problems/maximum-subarray/
# @param {Integer[]} nums
# @return {Integer}
def max_sub_array(nums)
  n = nums.length
  sum = nums[0]
  max_sum = nums[0]

  1.upto(n-1) do |i|
    sum = [nums[i], sum + nums[i]].max
    max_sum = [max_sum, sum].max
  end
  max_sum
end
