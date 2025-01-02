#!/user/bin/ruby
# https://leetcode.com/problems/longest-palindromic-substring/
# @param {String} s
# @return {String}
def longest_palindrome(s)
  # cause time limit exceed but it is right
  return s if s.length == 1
  return s if s.length == 2 && s == s.reverse
  result = ''
  max_plain = ''
  start = 0
  str_arr = s.chars
  while start < s.length
    result += str_arr[start]
    if result == result.reverse
      max_plain = result.length > max_plain.length ? result : max_plain
    end
    index = 1
    while index < result.length
      y = result[index..result.length]
      if y == y.reverse
        max_plain = y.length > max_plain.length ? y : max_plain
      end
      index += 1
    end
    start += 1
  end
  max_plain
end

def longest_palindrome2(s)
  return "" if s.length < 1
  max_sub_start = 0
  max_sub_length = 0
  (0..s.length - 1).each do |index|
    max = [expand_around_center(s, index, index), expand_around_center(s, index, index + 1)].max
    if max > max_sub_length
      max_sub_length = max
      temp = ((max_sub_length - 1) / 2).floor
      max_sub_start = index - temp
    end
  end
  s[max_sub_start..max_sub_length ].chars.take(max_sub_length).join
end

def expand_around_center(s, left, right)
  while left >= 0 && right < s.length && s[left] == s[right]
    left -= 1
    right += 1
  end
  right - left - 1
end

# s = "babad"
s = "cbbd"
# s = "ac"
# s = "ccc"
# s = "eabcb"

puts longest_palindrome2(s)
