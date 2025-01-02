# https://leetcode.com/problems/house-robber-ii/
# @param {Integer[]} nums
# @return {Integer}
def rob(nums)
  return 0 if nums.empty?
  return nums.max if nums.length <= 3 # "If there are three or less it must only be the max number"

  first = nums.slice(0...nums.length - 1) # "First array which includes all elements except the last"
  second = nums.slice(1...nums.length) # "Second array which includes all elements except the first"

  first[1] = [first[0], first[1]].max
  second[1] = [second[0], second[1]].max # "We set index 1 to the max between index 0 and 1 for both arrays"
  i = 2 # "Start at index 2"
  while i < first.length # "Both arrays should be the same length so it doesn't matter which one"

    first[i] = [(first[i] + first[i - 2]), first[i - 1]].max
    second[i] = [second[i] + second[i - 2], second[i - 1]].max # "We compare the current element plus the before before element(index - 2) or the previous max we computed which is the first before element(index -1).

    i += 1
  end
  [first.last, second.last].max # "Explicit return for clarity, but due to DP are max is the last element for both arrays and we just return whichever is bigger"

end
