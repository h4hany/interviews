#!/user/bin/ruby
#https://leetcode.com/problems/custom-sort-string/
def custom_sort_string(order, s)
  order_res = ''
  result = ''
  hash = {}
  order.split('').each do |char|
    if s.include? char
      order_res += char
    end
  end
  s.split('').each do |char|
    if hash[char]
      hash[char] += 1
    else
      hash[char] = 1
    end
  end

  order_res.split('').each do |char|
    result += char * hash[char]
    hash.delete(char)
  end
  hash.each do |key, value|
    result += key * value
  end
  result
end

order = "cbazs"
s = "abcd"
puts custom_sort_string(order, s)

