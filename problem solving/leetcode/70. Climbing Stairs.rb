#!/user/bin/ruby
# https://leetcode.com/problems/climbing-stairs/
# @param {Integer} n
# @return {Integer}
def climb_stairs(n)
  return n if n == 1 || n == 2 || n == 0
  step1 = 2
  step2 = 1
  sum = 0
  (3..n).each do |index|
    sum = step1 + step2
    temp = step1
    step1 = sum
    step2 = temp
  end
  sum
end

def factorial(n)
  return 1 if n == 0
  n * factorial(n - 1)
end

n = 2
puts climb_stairs(n)

