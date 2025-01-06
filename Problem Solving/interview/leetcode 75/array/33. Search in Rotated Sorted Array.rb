# https://leetcode.com/problems/search-in-rotated-sorted-array/
# @param {Integer[]} nums
# @param {Integer} target
# @return {Integer}
def search(nums, target)
  nums.index(target) || -1
end
