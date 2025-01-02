#!/user/bin/ruby
# https://leetcode.com/problems/letter-case-permutation/
# @param {String} s
# @return {String[]}
def letter_case_permutation(s)
  return [""] if s.length == 0
  return [s] if s.to_i > 0
  result = []
  first = s[0]
  prem = letter_case_permutation(s.slice(1))
  puts prem.to_s
  prem.each do |p|
    result.push(first + p)
    if first.to_i == 0
      temp = first == first.upcase ? first.downcase : first.upcase
      result.push(temp + p)
    end
  end
  result
end



  s = "a1b2"
  puts letter_case_permutation(s).to_s
