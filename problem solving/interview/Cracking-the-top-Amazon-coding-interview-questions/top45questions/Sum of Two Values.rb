#!/user/bin/ruby
# Problem Statement
# Given an array of integers and a value,
# determine if there are any two integers in the array whose sum is equal to the given value.
# Return true if the sum exists and return false if it does not.
# Consider this array and the target sums:
def find_sum_of_two(arr, val)
  found_values = {}
  arr.each do |elt|
    if found_values[val - elt]
      return true
    end
    found_values[elt] = 1
  end
  false
end
arr = [5, 7, 1, 2, 8, 4, 3]
val = 10
puts find_sum_of_two(arr, val)
