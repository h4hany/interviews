#!/user/bin/ruby
# https://leetcode.com/problems/reverse-string/
# https://leetcode.com/problems/reverse-words-in-a-string-iii/
def reverse_string(s)
  start = 0
  last = s.length - 1

  while start < last
    temp = s[start]
    s[start] = s[last]
    s[last] = temp
    start += 1
    last -= 1
  end
   s.to_s
end
def reverse_words2(s)
  arr_s = s.split(" ")
  result = []
  arr_s.each do |curr|
    selected_arr = curr.chars
    start = 0
    last = selected_arr.length - 1

    while start < last
      temp = selected_arr[start]
      selected_arr[start] = selected_arr[last]
      selected_arr[last] = temp
      start += 1
      last -= 1
    end
    result.push(selected_arr.join(""))
  end
  result.join(" ")
end
# puts reverse_string(["h","e","l","l","o"])
s = "God Ding"
puts reverse_words2(s)
