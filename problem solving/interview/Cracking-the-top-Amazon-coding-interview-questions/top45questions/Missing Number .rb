#!/user/bin/ruby
# You are given an array of positive numbers from 1 to n,
# such that all numbers from 1 to n are present except one number x.
# You have to find x. The input array is not sorted.
# Look at the below array and give it a try before checking the solution.

def find_missing(nums)
  # normal solun
  n = nums.size + 1
  real_sum = (n * (n + 1)) / 2
  sum = 0
  nums.each { |x| sum += x }
  real_sum - sum
end

arr = [3, 7, 1, 2, 8, 4, 5]
puts find_missing(arr)
