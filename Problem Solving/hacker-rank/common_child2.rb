#!/user/bin/ruby
#https://www.hackerrank.com/challenges/common-child/problem?utm_campaign=challenge-recommendation&utm_medium=email&utm_source=7-day-campaign
#
def debug_info(var_name, value)
  puts "#{var_name}: #{value}"
end
def commonChild(s1, s2)
  # Write your code here
  hash_s2 = {}
  hash_s1 = {}

  s = ''
  s1.split('').each_with_index  do |char,index|
    hash_s1[char] = index
  end

  s2.split('').each_with_index  do |char,index|
    hash_s2[char] = index
  end

  puts hash_s1
  puts hash_s2

end

s1 = 'SHINCHAN'
s2 = 'NOHARAAA'
# s1 ='ABCDEF'
# s2='FBDAMN'
puts commonChild(s1, s2)
