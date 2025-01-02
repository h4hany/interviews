#!/user/bin/ruby
# https://www.hackerrank.com/challenges/two-strings/problem?h_l=interview&playlist_slugs%5B%5D=interview-preparation-kit&playlist_slugs%5B%5D=dictionaries-hashmaps&h_r=next-challenge&h_v=zen
def twoStrings(s1, s2)
  # Write your code here
  is_substring = 'No'
  hash = {}
  s1.split('').each do |each_char|
    hash.has_key?(each_char) ? hash[each_char] += 1 : hash[each_char] = 1
  end
  s2.split('').each do |each_char|
    if  hash.has_key?(each_char)
      is_substring = 'Yes'
      break
    end
  end
  is_substring
end

s1 = 'hello'
s2 = 'world'
puts twoStrings(s1, s2)
