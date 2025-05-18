#/bin/ruby

# @param {Integer[]} nums
# @param {Integer} k
# @return {Integer}
def max_operations(nums, k)
  counts = Hash.new(0)
  operations = 0

  nums.each do |num|
    complement = k - num
    if counts[complement] > 0
      operations += 1
      counts[complement] -= 1
    else
      counts[num] += 1
    end
  end

  operations
end

# @param {Integer[]} height
# @return {Integer}
def max_area(height)
  left = 0
  right = height.length - 1
  max_area = 0
  while left < right
    max_area = [[height[left], height[right]].min * (right - left), max_area].max
    height[left] > height[right] ? right -= 1 : left += 1
  end
  max_area
end

# @param {String} s
# @param {String} t
# @return {Boolean}
def is_subsequence(s, t)
  i = 0 # Pointer for string s
  j = 0 # Pointer for string t
  while i < s.length && j < t.length
    if s[i] == t[j]
      i += 1
    end
    j += 1
  end
  i == s.length
end

# @param {Integer[]} nums
# @return {Void} Do not return anything, modify nums in-place instead.
def move_zeroes(nums)
  counter = 0
  nums.each_with_index do |n, i|
    if n == 0
      nums[i] = nil
      counter += 1
    end
  end
  nums.delete(nil)
  while counter > 0
    nums.push(0)
    counter -= 1
  end
end
