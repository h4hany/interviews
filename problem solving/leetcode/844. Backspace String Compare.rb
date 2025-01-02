# https://leetcode.com/problems/backspace-string-compare/
#!/user/bin/ruby
# @param {String} s
# @param {String} t
# @return {Boolean}
def backspace_compare(s, t)
  s =remove_helper(s)
  t= remove_helper(t)
  return true if s == t
  false
end

def remove_helper(str)
  start = 0
  while start < str.length
    if str[start] == "#"
      prev = str[start - 1]
      removed = prev + '#'
      str.slice! removed
      start = 0
    end
    start += 1
  end
  str.slice! '#'
  str
end
s = "ab##"
t = "c#d#"
t = "ad#c"
s = "y#fo##f"
t="y#f#o##f"

remove_helper(t)
