#!/user/bin/ruby
def sub_array_ranges(nums)
  result = []
  length = nums.length
  nums.sort!
  sum = 0
  # puts nums.to_s
  # puts nums.to_s
  repeated_apirs = {}
  nums.each_with_index do |num, index|
    nums.each_with_index do |num2, index2|
      pairs = "(#{num2},#{num})"
      reverse_pair = "(#{num},#{num2})"
      if repeated_apirs[pairs] || repeated_apirs[reverse_pair]
        next
      else
        # unless index2 == length - 1
        sum += num2 - num
        result.push(num2 - num)
        puts "------------------------------"
        puts num2
        puts num
        puts num2 - num
        puts pairs + reverse_pair
        puts "------------------------------"

        repeated_apirs[pairs] = 1
        repeated_apirs[reverse_pair] = 1
        # end
      end

    end

    # puts repeated_apirs
    # result.push(0)
    # sum+=0
    # puts "next_index = #{(index + 1)}"
    # if index + 1 < length
    #   next_num = nums[index + 1]
    #   puts next_num
    #   diff = next_num - num
    #   sum+=diff
    #   result.push(diff)
    # end
  end
  # pairs = "(#{nums[length - 1]},#{nums[0]})"
  # reverse_pair = "(#{nums[0]},#{nums[length - 1]})"
  # if repeated_apirs[pairs]
  #  sum -= nums[length - 1] - nums[0]
  # end
  # result.push(nums[length - 1] - nums[0])
  puts sum
  puts result.to_s
end

# nums = [1, 2, 3]
nums = [1, 3, 3]
# nums = [4, -2, -3, 4, 1]
# sub_array_ranges(nums)
# Given an array of integers and an integer total target, return whether a contiguous subarray of integers sums up to target.

# [1, 3, 2, 4, 23], 9 : True (because 3 + 2 + 4 = 9)
# [1, 3, 2, 4, 23], 7 : False;

# // 2

# // 6 +4 = 10
# // current_sum -= nums[0]

def has_sum_of_target(nums, target)
  current_sum = 0
  last_index = -1
  nums.each_with_index do |n, i|
    current_sum += n
    if current_sum == target
      return true
    elsif current_sum > target
      current_sum -= n
      last_index = i
      break
    end
  end
  first_index = 0
  (last_index..nums.length - 1).each do |index|
    current_sum += nums[index]
    if current_sum > target
      current_sum -= nums[first_index]
      first_index += 1
    end
    if current_sum == target
      return true
    end

  end
  false
end

nums = [1, 3, 2, 4, 23]
target = 7
puts has_sum_of_target(nums, target)
