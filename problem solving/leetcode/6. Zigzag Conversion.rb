#!/user/bin/ruby
# https://leetcode.com/problems/zigzag-conversion/
# @param {String} s
# @param {Integer} num_rows
# @return {String}
def convert(s, num_rows)
  arr = s.chars
  matrix_arr = Array.new(num_rows, Array.new(s.length))

end
s = "PAYPALISHIRING"
num_rows = 3

puts convert(s, num_rows)
