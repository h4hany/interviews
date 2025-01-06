#!/user/bin/ruby

def repeatedString(s, n)
  # Write your code here
  input_arr = s.split('')
  string_length = s.length
  selected_char = 'a'
  counted_first_char = s.count(selected_char)
  repeated_string_part = (n / string_length).ceil
  result = counted_first_char * repeated_string_part
  boundary = (n % string_length) == 0 ?  (n % string_length) : (n % string_length) - 1
  if string_length > 1
    result += input_arr[0..boundary].join('').count(selected_char)
  else
    result
  end
  result
end
s = 'kmretasscityylpdhuwjirnqimlkcgxubxmsxpypgzxtenweirknjtasxtvxemtwxuarabssvqdnktqadhyktagjxoanknhgilnm'
n = 736778906400
puts repeatedString(s, n)
51574523448
