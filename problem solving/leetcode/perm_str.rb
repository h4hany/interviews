#!/user/bin/ruby
#https://leetcode.com/problems/permutation-in-string/
def check_inclusion(s1, s2)
  window_start = 0
  is_match = 0
  pattern = s1
  hash = {}
  pattern.chars.each do |char|
    unless hash.include? char
      hash[char] = 0
    end
    hash[char] += 1
  end
  str = s2.chars
  (0..s2.length - 1).to_a.each do |window_end|
    end_char = str[window_end]
    if hash[end_char]
      hash[end_char] -= 1
      if hash[end_char] == 0
        is_match += 1
      end
    end
    if is_match == hash.keys.length
      return true
    end

    if window_end >= pattern.length - 1
      start_char = str[window_start]
      window_start += 1
      if hash[start_char]
        if hash[start_char] == 0
          is_match -= 1
        end
        hash[start_char] += 1
      end
    end
  end
   false
end

puts check_inclusion("abc", "bbbca")
