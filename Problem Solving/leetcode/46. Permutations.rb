#!/user/bin/ruby
# https://leetcode.com/problems/permutations/

# @param {Integer[]} nums
# @return {Integer[][]}
def permute(nums)
  result = []
  permute_helper(nums, [], result)
  result
end

def permute_helper(nums, path, result)
  if nums.length == 0
    result.push([*path])
    return
  end
  nums.each do |num|
    path.push(num)
    permute_helper(nums.filter {|a| a != num},path,result)
    path.pop
  end
end
nums = [1,2,3]
puts permute(nums).to_s
