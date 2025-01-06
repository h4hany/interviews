# https://leetcode.com/problems/decode-ways/
# @param {String} s
# @return {Integer}
def num_decodings(s,memo={})
  return memo[s] if memo.key?(s)

  num      = s[0]
  num_next = s[1]

  return 0 if num == '0'
  return 1 if num.nil?
  return 1 if num_next.nil?

  result = num_decodings(s[1..-1], memo)

  if (num + num_next).to_i.between?(1,26)
    result += num_decodings(s[2..-1], memo)
  end

  memo[s] = result
  result
end
