#!/user/bin/ruby
# https://leetcode.com/problems/find-all-anagrams-in-a-string/
# @param {String} s
# @param {String} p
# @return {Integer[]}
def find_anagrams(s, p)
  result = []
  index = 0
  last = p.length - 1
  sorted = p.chars.sort.join
  while index < s.length
    sorted_subs = s[index..last].chars.sort.join
    result.push(index) if sorted_subs == sorted
    index += 1
    last += 1
  end
  result
end
def find_anagrams_using_hash(s, p)
  p_hash = Hash.new(0)
  p.each_char { |c| p_hash[c] += 1 }
  i, j = 0, 0
  res = []
  while j < s.size
    if p_hash[s[j]] != 0
      p_hash[s[j]] -= 1
      res << i if j - i == p.size - 1
      j += 1
    elsif i == j
      i += 1
      j += 1
    else
      p_hash[s[i]] += 1
      i += 1
    end
  end
  res
end
s = "cbaebabacd"
p = "abc"
s = "abab"
p = "ab"
puts find_anagrams(s, p)
