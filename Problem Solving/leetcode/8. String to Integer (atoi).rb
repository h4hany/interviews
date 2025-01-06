#!/user/bin/ruby
# https://leetcode.com/problems/string-to-integer-atoi/
# @param {String} s
# @return {Integer}
def my_atoi(s)
  n = s.split(" ").first.to_i
  return 2147483647 if n > 2147483647
  return -2147483648 if n < -2147483648
  n
end
