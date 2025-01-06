#!/user/bin/ruby
# https://leetcode.com/problems/house-robber/
# @param {Integer[]} nums
# @return {Integer}
def rob(nums)
  index = 0
  sum_even = 0
  sum_odd = 0
  while index  <= nums.length - 1

    if index % 2 == 0
      sum_even+= nums[index]
      sum_even = sum_even > sum_odd ? sum_even : sum_odd
    else
      sum_odd+= nums[index]
      sum_odd = sum_even > sum_odd ? sum_even : sum_odd
    end
    index += 1
  end
  sum_even > sum_odd ? sum_even : sum_odd

end

nums = [1, 2, 3, 1]
nums = [2,7,9,3,1]
nums = [1,2]
nums = [2,1,1,2]

puts rob(nums)
