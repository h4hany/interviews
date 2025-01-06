#!/user/bin/ruby
# <<-DOC
# [Maximum Swap]
# You are given an integer num. You can swap two digits at most once to get the maximum valued number.
# Return the maximum valued number you can get.
#
# Example 1:
# Input: num = 2736
# Output: 7236
# Explanation: Swap the number 2 and the number 7.
#
# All these number conform with "at most once to get" constrain
# 2763 (2736 -> 2763) Swap the number 6 and the number 3.
# 2637 (2736 -> 2637) Swap the number 6 and the number 7.
# 2376 (2736 -> 2376) Swap the number 3 and the number 7.
# 7236 (2736 -> 7236) Swap the number 2 and the number 7.
#
# BUT this one not, this is 2 swap
# 7632 (2736 -> 7236) Swap the number 7 and the number 2.
# 	 (7236 -> 7632) Swap the number 2 and the number 6.
#
# Example 2:
# Input: num = 9973
# Output: 9973
# Explanation: No swap.
#
# Constraints:
# 0 <= num <= 10^8
#
# other input
# 99088, 99901, 3997, 9973, 98368, 115, 120
#
# 99088 -> 99880
# 99901 -> 99910
# 98368 -> 98863
#
def debug_info(var_name, value)
  puts "#{var_name}: #{value}"
end
def max_swap(num)
  string_num = num.to_s
  num_arr = string_num.split('').map(&:to_i)
  sorted_num_arr = num_arr.map(&:to_i).sort.reverse
  string_num_length = string_num.length
  debug_info('num_arr',num_arr)
  debug_info('sorted_num_arr',sorted_num_arr)

  first_mismatch_index = 0
  (0..string_num_length - 1).each do |index|
    if num_arr[index] != sorted_num_arr[index]
      debug_info('index',index)

      first_mismatch_index = index
      break
    end
  end
  debug_info('first_mismatch_index',first_mismatch_index)
  if first_mismatch_index == string_num_length
    return num
  end
  pattern = /#{sorted_num_arr[first_mismatch_index]}/
  last_position_of_mismatching_index = string_num.rindex(pattern)
  debug_info('sorted_num_arr[first_mismatch_index]',sorted_num_arr[first_mismatch_index])

  debug_info('last_position_of_mismatching_index',last_position_of_mismatching_index)

  temp_change = num_arr[first_mismatch_index]
  debug_info('temp_change',temp_change)
  debug_info(' num_arr[first_mismatch_index] ', num_arr[first_mismatch_index] )

  num_arr[first_mismatch_index] = num_arr[last_position_of_mismatching_index]

  debug_info('  num_arr[last_position_of_mismatching_index]',  num_arr[last_position_of_mismatching_index] )

  num_arr[last_position_of_mismatching_index] = temp_change
  debug_info('temp_change',temp_change)

  num_arr.join.to_i
end

num = 99088
puts max_swap(num)
