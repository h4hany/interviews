# https://leetcode.com/problems/search-a-2d-matrix/
# @param {Integer[][]} matrix
# @param {Integer} target
# @return {Boolean}
def search_matrix(matrix, target)
  result = []
  matrix.each do |mat|
    result.push( binary_search(mat, target))
  end
  result.include? true
end
def binary_search(nums, target)
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
      return true
    end
  end
  false
end
