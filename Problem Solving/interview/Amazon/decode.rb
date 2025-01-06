#!/user/bin/ruby
# https://www.youtube.com/watch?v=mjZpZ_wcYFg
def run_length(str)
  count = 1
  result = ''
  prev_char = '0'
  str.each_char do |char|
    if char == prev_char
      count += 1
    else
      result += count.to_s + prev_char if prev_char != '0'
      prev_char = char
      count = 1
    end
  end
  result += count.to_s + prev_char
end

str = 'aaabbccca'
output = '3a2b3c1a'
puts run_length(str)
