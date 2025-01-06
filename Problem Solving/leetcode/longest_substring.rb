#!/user/bin/ruby
#https://leetcode.com/problems/longest-substring-without-repeating-characters/
def length_of_longest_substring2(s)
  result = ''
  prev = 0
  arr = s.chars
  arr.each_with_index do |ch, index|
    if !result.include?(ch)
      result += ch
      prev = result.length
    else
      if prev <= result.length
        prev = result.length
      end
      result = arr[index] + ch
    end
  end
  prev
end

def length_of_longest_substring(s)
  window_start = 0
  max_length = 0
  char_hash = {}
  str = s.chars
  (0..s.length - 1).to_a.each do |window_end|
    end_char = str[window_end]
    if char_hash[end_char]
      window_start = [window_start, char_hash[end_char] + 1].max
    end
    char_hash[end_char] = window_end
    max_length = [max_length, window_end - window_start + 1].max
  end
  max_length
end

s = "abcabcbb"
s = "abcabcbb"
s = "pwwkew"
s = "dvdf"

puts length_of_longest_substring(s)
