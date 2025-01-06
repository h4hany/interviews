#!/user/bin/ruby
# https://leetcode.com/problems/find-minimum-in-rotated-sorted-array/
# @param {Integer[]} nums
# @return {Integer}
def find_min(nums)
  nums.bsearch { |num| num <= nums.last }
end
def find_min_elem(nums)
  return nums[0] if nums.length == 1
  left = 0
  right = nums.length - 1
  return nums[0] if nums[right] > nums[0]
  while right >= left
    mid = left + (right-left) / 2
    return nums[mid+1] if nums[mid] > nums[mid+1]
    return nums[mid] if nums[mid - 1] > nums[mid]
    if nums[mid] > nums[0]
      left = mid + 1
    else
      right = mid - 1
    end
  end
   -1
end
