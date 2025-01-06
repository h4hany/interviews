# https://leetcode.com/problems/missing-number/
# @param {Integer[]} nums
# @return {Integer}
#
# it can be solved by 2 ways normal one get sum of all
# get some of range
# range - all = result
# or by bitwise like below
def missing_number(nums)
  nums.reduce(:^) ^ (0..nums.length).reduce(:^)
end
