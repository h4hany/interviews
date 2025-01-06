# https://leetcode.com/problems/minimum-size-subarray-sum/
#!/user/bin/ruby
# @param {Integer} target
# @param {Integer[]} nums
# @return {Integer}
def min_sub_array_len(target, nums)
  result = []
  sum = 0
  last_index = -1
  window_start = 0
  window_end = 0
  min_length = 1000
  # [2, 3, 1, 2, 4, 3]
  while window_end < nums.length
    sum += nums[window_start]

    if sum >= target
      sum -= nums[window_start]
      last_index = window_end - 1
      min_length = [min_length, window_end - window_start ].min
      puts min_length
      result.push(nums[window_start..min_length])
      window_start += 1
      puts '---------------------'
    end

    window_end += 1
  end
  puts min_length
  result.to_s

end

def min_sub_array_len2(target, nums)
  return 0 if nums.empty?
  min = nil
  window_start, window_end = 0, 0
  sum = nums[window_start]
  while window_end < nums.size
    if sum < target
      window_end += 1
      sum += nums[window_end] if window_end < nums.size
      next
    end
    return 1 if (window_end == window_start)
    length = window_end - window_start + 1
    min = length if min.nil? || min > length
    window_start += 1
    sum -= nums[window_start - 1]
  end
  min ? min : 0
end

target = 7
nums = [2, 3, 1, 2, 4, 3]
puts min_sub_array_len(target, nums)
