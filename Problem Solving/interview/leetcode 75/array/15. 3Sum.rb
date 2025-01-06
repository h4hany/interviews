# https://leetcode.com/problems/3sum/
# @param {Integer[]} nums
# @return {Integer[][]}
def two_sum(nums, target)
  seen = Hash.new
  result = []
  nums.each_with_index do |e, i|
    if seen.has_key?(target - e)
      result << [seen[target - e], i]
    else
      seen[e] = i
    end
  end
  result
end

def three_sum(nums)
  nums.sort!
  seen = Hash.new
  results = []
  nums.each_with_index do |e, i|
    unless seen.has_key?(e)
      two_sum(nums[i + 1..-1], 0 - e).each do |pair|
        results << [e] + pair.map { |j| nums[j + i + 1] }
      end
      seen[e] = i
    end
  end
  results.uniq
end
