# https://leetcode.com/problems/combination-sum-ii/
# @param {Integer[]} candidates
# @param {Integer} target
# @return {Integer[][]}
def combination_sum2(candidates, target)
  candidates.sort!

  results = []
  generate_combination_sum(results, [], candidates, target, 0)
  results
end

def generate_combination_sum(res, tmp, nums, remain, index)
  if remain == 0
    res << tmp.clone
    return
  end

  return if nums[index].nil? || remain < nums[index]

  (index...nums.length).each do |i|
    next if (nums[i] == nums[i-1]) && (i > index)
    break if nums[i] > remain

    tmp << nums[i]
    generate_combination_sum(res, tmp, nums, remain - nums[i], i+1)

    tmp.pop
  end
end
