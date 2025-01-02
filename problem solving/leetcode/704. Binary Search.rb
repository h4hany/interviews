# https://leetcode.com/problems/binary-search/
# @param {Integer[]} nums
# @param {Integer} target
# @return {Integer}
def search(nums, target)
  length = nums.length

  start = 0
  last = length - 1

  while start <= last
    mid = start + ((last - start) / 2)
    if target > nums[mid]
      start = mid + 1
    elsif target < nums[mid]
      last = mid - 1
    elsif target == nums[mid]
      return mid
    end
  end
  -1
end
