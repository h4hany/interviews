#!/user/bin/ruby
# https://leetcode.com/problems/rotate-array/
def rotate(nums, k)
  return nums.reverse! if nums.length == 2 && nums.length < k
  split = nums.length % 2 == 0 ? k : k + 1
  ne = nums.slice!(0, split)
  nums.concat(ne)
  nums.to_s
end

puts rotate([1, 2], 3)
puts rotate([-1, -100, 3, 99], 2)
puts rotate([1, 2, 3, 4, 5, 6, 7], 3)
