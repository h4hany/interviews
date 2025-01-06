# https://leetcode.com/problems/remove-duplicates-from-sorted-array-ii/submissions/
# @param {Integer[]} nums
# @return {Integer}
def remove_duplicates(nums)
  k = nums.length
  hash = {}

  (0..nums.length - 1).each do |i|
    num = nums[i]
    if hash[num]
      hash[num] += 1
      if hash[num] > 2
        nums[i]="-"
        k -= 1
      end
    else
      hash[num] = 1
    end
  end
  nums.delete("-")
  k
end
puts remove_duplicates([0,0,1,1,1,1,2,3,3])
