# https://leetcode.com/problems/word-break/
# @param {String} s
# @param {String[]} word_dict
# @return {Boolean}
def word_break(s, word_dict)
  len = s.length
  dp = Array.new(len + 1).fill(false)
  dp[0] = true
  (1..len).each do |i|
    word_dict.each do |word|
      l = word.length
      dp[i] |= dp[i - l] if i >= l && s[i - l..i].includes(word)
    end
  end
  dp[len]
end
