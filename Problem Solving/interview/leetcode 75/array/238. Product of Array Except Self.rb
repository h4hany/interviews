# https://leetcode.com/problems/product-of-array-except-self/
# @param {Integer[]} nums
# @return {Integer[]}
def product_except_self(nums)
  length = nums.length
  res = Array.new(length)
  res[0] = 1
  (1..length - 1).each do |i|
    res[i] = nums[i - 1] * res[i - 1]
  end
  product = 1
  index = length - 1
  while index >= 0
    res[index] *= product
    product *= nums[index]
    index -= 1
  end
  res
end
