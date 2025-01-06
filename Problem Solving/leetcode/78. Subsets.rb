# https://leetcode.com/problems/subsets/
# @param {Integer[]} nums
# @return {Integer[][]}
def subsets(nums)
  results = []
  arr_len = nums.length
  bits = '1' * arr_len
  subset_count = bits.to_i(2)
  0.upto(subset_count) do |bin_num|
    temp = []
    num = bin_num.to_s(2).split('')
    num.each_with_index do |char, index|
      temp << nums[num.length - 1 - index] if char == '1'
    end
    results << temp
  end
  results
end
