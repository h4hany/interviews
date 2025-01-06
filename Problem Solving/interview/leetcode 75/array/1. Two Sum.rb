# https://leetcode.com/problems/two-sum/
# @param {Integer[]} nums
# @param {Integer} target
# @return {Integer[]}
def two_sum(nums, target)
  seen = {}
  result = []
  nums.each_with_index do |num , i|
    if seen[target - num]
      result = [seen[target - num],i]
    else
      seen[num] = i
    end
  end
  result
end
