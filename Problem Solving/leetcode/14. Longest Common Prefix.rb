#!/user/bin/ruby
# https://leetcode.com/problems/longest-common-prefix/
# @param {String[]} strs
# @return {String}
def longest_common_prefix(strs)
  return "" if strs.empty?
  base = strs[0]
  common = ''
  (0..base.length - 1).each do |index|
    if strs.all? { |x| x[index] == base[index] }
      common += base[index]
    else
      break
    end
  end
  common
end

strs = ["flower", "flow", "flight"]
strs = ["dog", "racecar", "car"]
puts longest_common_prefix(strs)
