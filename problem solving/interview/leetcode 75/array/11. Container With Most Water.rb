#!/user/bin/ruby
# https://leetcode.com/problems/container-with-most-water/
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
height = [1,8,6,2,5,4,8,3,7]
puts max_area(height)
