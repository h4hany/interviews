#!/user/bin/ruby
# https://leetcode.com/problems/decode-string/
# @param {String} s
# @return {String}
def decode_string(s)
  stack = []
  numbers = [0..9].to_a.map(&:to_s)
  stack_num = []
  res = ''
  chars = []
  s.each_char do |c|
    if c == "["
      stack.push(c)
    elsif numbers.include? c
      stack_num.push(c)
    elsif stack.pop == "]"

    else
          chars.push(c)
          stack_num.pop.to_i
    end
  end
  char_arr = s.scan(/\[(.*?)\]/).flatten
  num_arr = s.scan(/\d/)
end
s = "3[a]2[bc]"
puts decode_string(s)
