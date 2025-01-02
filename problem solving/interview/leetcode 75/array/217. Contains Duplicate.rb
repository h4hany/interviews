# https://leetcode.com/problems/contains-duplicate/
# @param {Integer[]} nums
# @return {Boolean}
def contains_duplicate(nums)
  hash = Hash.new{|k,v| v = 0}
  nums.each do |n|
    hash[n]  += 1
    return true if  hash[n] > 1
  end
  false
end
