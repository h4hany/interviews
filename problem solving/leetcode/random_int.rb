#!/user/bin/ruby
# https://leetcode.com/discuss/interview-question/451431/facebook-onsite-generate-random-max-index
# Given an array of integers arr, randomly return an index of the maximum value seen by far.
#
#   Example:
#   Input: [11, 30, 2, 30, 30, 30, 6, 2, 62, 62]
#
# Having iterated up to the at element index 5 (where the last 30 is), randomly give an index among [1, 3, 4, 5]
# which are indices of 30 - the max value by far. Each index should have a ¼ chance to get picked.
#
#Having iterated through the entire array, randomly give an index between 8 and 9 which are indices of the max value 62.
def find_random_index_of_max(arr)
  hash = {}
  arr.each_with_index do |num, i|
    if hash[num]
      hash[num][:count] += 1
      hash[num][:indeces].push(i)
    else
      hash[num] = {
        indeces: [i],
        count: 1
      }
    end
  end
  max_key = -1
  selected_target = 0
  hash.each_pair do |key, value|
    if value[:count] > max_key
      max_key = value[:count]
      selected_target = key
    end
  end

  array = hash[selected_target][:indeces]
  random =  array.sample(1 + rand(array.count)).first
  "element #{arr[random]} at index #{random}"
end

arr = [-1, 4, 9, 7, 7, 2, 7, 3, 0, 9, 6, 5, 7, 8, 9]
puts find_random_index_of_max(arr)
