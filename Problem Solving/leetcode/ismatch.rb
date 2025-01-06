#!/user/bin/ruby
# @param {String} p
# @return {Boolean}
def is_match(s, p)
  wild = %w[* ?]
  return true if p == s || p == wild[0]
  return false if !p.include?(wild[0]) && !p.include?(wild[1])
  res = []
  start = 1

  p.chars.each_with_index do |pattern, index|
    if pattern == "*"
      while start < s.length
        if index + 1 < p.length && p[index + 1] != s[start]
          res.push(true)
          start += 1
        end
      end
    elsif s[start] == pattern
      res.push(true)
      start += 1
    elsif pattern == '?'
      start += 1
      res.push(true)
    else
      return false
    end

  end

  !res.include?(false)
end

def is_match2(s, p)
  string_start = 0
  pattern_start = 0
  match = 0
  start = -1

  while string_start < s.length
    if pattern_start < p.length && (p[pattern_start] == '?' || p[pattern_start] == s[string_start])
      string_start += 1
      pattern_start += 1
    elsif pattern_start < p.length && p[pattern_start] == '*'
      start = pattern_start
      match = string_start
      pattern_start += 1
    elsif  start != -1
      pattern_start = start + 1
      match += 1
      string_start =match
    else
      return false
    end
  end


  while pattern_start < p.length && p[pattern_start] == '*'
    pattern_start+=1
  end

   pattern_start == p.length

end

s = "abcabczzzde"
p = "*abc???de*"
s = "aa"
p = "a"
s = "aa"
p = "*"
# s = "cb"
# p = "?a"
s = "adceb"
p = "*a*b"
puts is_match2(s, p)
