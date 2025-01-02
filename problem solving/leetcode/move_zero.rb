#!/user/bin/ruby
# https://leetcode.com/problems/move-zeroes/
def move_zeroes(nums)

  length = nums.length
  count = 0
  (0..length - 1).each do |i|
    if nums[i] != 0
      nums[count] = nums[i]
      count+=1
    end
  end
  while count < length
    nums[count] = 0
    count+=1
  end
end
puts move_zeroes([0,1,0,3,12])
