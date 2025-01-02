#!/user/bin/ruby
def product_except_self(nums)
  length = nums.length
  res = Array.new(length)
  res[0] = 1
  (1..length - 1).each do |i|
    res[i] = nums[i - 1] * res[i - 1]
  end
  product = 1
  index = length - 1
  result = Array.new(length)
  res_i = 0
  while index >= 0
    res[index] *= product
    result[res_i] = res[index]
    product *= nums[index]
    index -= 1
    res_i += 1
  end
   result
end

nums = [1, 2, 3, 4]
puts product_except_self(nums)
