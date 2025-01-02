#!/user/bin/ruby
# https://leetcode.com/problems/find-first-and-last-position-of-element-in-sorted-array/
# @param {Integer[]} nums
# @param {Integer} target
# @return {Integer[]}
def search_range(nums, target)
  result = [-1, -1]
  return result if nums.length == 0

  result[0] = binary_search(nums,target ,false)
  if result[0] != -1
    result[1] = binary_search(nums,target)
  end
  result
end

def binary_search(nums, target, first = true)
  length = nums.length
  start = 0
  last = length - 1
  res = -1
  while start <= last
    mid = start + ((last - start) / 2)
    if target > nums[mid]
      start = mid + 1
    elsif target < nums[mid]
      last = mid - 1
    else
      res = mid
      if first
        start = mid + 1
      else
        last = mid - 1
      end
    end
  end
  res
end
def binary_search2(nums, target)
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

nums = [5, 7, 7, 8, 8, 10]
target = 8
# nums = [2, 2]
# target = 2
puts search_range(nums, target)
