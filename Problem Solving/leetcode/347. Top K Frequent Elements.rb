#!/user/bin/ruby
# https://leetcode.com/problems/top-k-frequent-elements/
# @param {Integer[]} nums
# @param {Integer} k
# @return {Integer[]}
def top_k_frequent(nums, k)
  hash = Hash.new { |_, v| v = 0 }
  nums.each { |n| hash[n] += 1 }
   Hash[hash.sort_by {|_key, value| value}].keys.last(k)
end

nums = [1, 1, 1, 2, 2, 3]
k = 2
puts top_k_frequent(nums, k)
