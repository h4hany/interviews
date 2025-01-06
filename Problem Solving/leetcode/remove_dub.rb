#!/user/bin/ruby
# https://leetcode.com/problems/remove-all-adjacent-duplicates-in-string/
def remove_duplicates(s)
  s.split('').each_with_index  do |char,index|
    if  hash[char]
      hash.delete(char)
    else
      hash[char] = 1
    end
  end
end
 s = "aababaab"
# "ba"
# "ca"
# s = "azxxzy"
# Output: "ay"
puts remove_duplicates(s)
