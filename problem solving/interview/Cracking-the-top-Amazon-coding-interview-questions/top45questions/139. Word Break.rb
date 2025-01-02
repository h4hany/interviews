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

# String Segmentation
def can_segment_string(s, dictionary)
  (1..s.length).each { |i|
    first = s[0, i]
    if dictionary.include?(first)
      second = s[i..-1]
      if second.length == 0
        return true
      end
      if dictionary.include?(second)
        return true
      end
      if can_segment_string(second, dictionary)
        return true
      end
    end
  }
  false
end

s = "hellonow"
dictionary = Set.new(["hello", "hell", "on", "now"])
