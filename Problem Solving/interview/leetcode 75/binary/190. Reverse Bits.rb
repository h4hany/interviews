# https://leetcode.com/problems/reverse-bits/
# @param {Integer} n, a positive integer
# @return {Integer}
def reverse_bits(n)
  num = 0
  32.times do
    num *= 2
    num += n & 1
    n /= 2
  end

  num
end
