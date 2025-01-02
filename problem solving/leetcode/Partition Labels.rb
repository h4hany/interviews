#!/user/bin/ruby
# https://leetcode.com/problems/partition-labels/
# @param {String} s
# @return {Integer[]}
def partition_labels(s)
  result = []
  start = 0
  last = 0
  s.chars.each_with_index do |selected_char, i|
    last = [last, s.rindex(selected_char)].max
    if i == last
      result.push(last - start + 1)
      start = last + 1
    end

  end
   result
end

s = "ababcbacadefegdehijhklij"
#   "ababcbaca"
puts partition_labels(s)
