#!/user/bin/ruby
# https://leetcode.com/problems/combinations/
# @param {Integer} n
# @param {Integer} k
# @return {Integer[][]}
def combine(n, k)
  result = []
  combine_helper([], 1, n, k,result)
  result
end

def combine_helper(partial_result, current_num, n, k,result)
  index = current_num
  if partial_result.length == k
    result.push([*partial_result])
    return
  end
  while index <= n
    partial_result.push(index)
    combine_helper(partial_result, index + 1, n, k,result)
    partial_result.pop
    index += 1
  end
end

n = 1
k = 1
puts combine(n, k).to_s
