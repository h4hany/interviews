# https://leetcode.com/problems/counting-bits/
# @param {Integer} n
# @return {Integer[]}
def count_bits(n)
  ret_array=[0]
  (1..n).each { |i|
    ret_array << i.to_s(2).count('1')
  }
   ret_array
end
