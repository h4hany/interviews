# https://leetcode.com/problems/word-break-ii/
# @param {String} s
# @param {String[]} word_dict
# @return {String[]}
def word_break(s, word_dict)
  word_break_helper(s, word_dict, {})
end

def word_break_helper(s, word_dict, memo)
  return memo[s] if memo.has_key?(s)
  return [""] if s.length == 0

  results = []

  word_dict.each do |word|
    if s.start_with?(word)
      substrings = word_break_helper(s[word.length ..-1], word_dict, memo)

      substrings.each do |substring|
        optional_space = substring.empty? ? "" : " "
        results << word + optional_space + substring
      end
    end
  end

  memo[s] = results
end
