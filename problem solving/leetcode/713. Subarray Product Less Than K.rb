#!/user/bin/ruby
# https://leetcode.com/problems/subarray-product-less-than-k/
# @param {Integer[]} nums
# @param {Integer} k
# @return {Integer}
def num_subarray_product_less_than_k(nums, k)
  return 0 if k == 0
  start = 0
  product = 1
  count = 0
  nums.each_with_index do |num, i|
    while start <= i && product * num >= k
      product = product.to_f / nums[start]
      start += 1
    end
    product = start > i ? 1 : product * num
    count = start > i ? count : count + (i - start + 1)
  end

  count
end

nums = [10, 5, 2, 6]
k = 100
puts num_subarray_product_less_than_k(nums, k)
