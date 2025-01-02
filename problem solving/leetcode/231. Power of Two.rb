#!/user/bin/ruby
# https://leetcode.com/problems/power-of-two/
# @param {Integer} n
# @return {Boolean}
def is_power_of_two(n)
   n > 0 && n.to_s(2).count("1") == 1
end
