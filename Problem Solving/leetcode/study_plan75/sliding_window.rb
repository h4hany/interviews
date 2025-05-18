#/bin/ruby

=begin
Step-by-Step Explanation of the Sliding Window Technique and Solving the Problem
Sliding Window Technique Overview
Purpose: Efficiently find subarrays/substrings that meet certain criteria (e.g., max length, min sum) without redundant checks.

When to Use:

Problems involving contiguous sequences (arrays/strings).

When the solution can be tracked by expanding/shrinking a window (e.g., longest substring with at most K distinct characters).

Key Indicators:

The problem requires maximizing/minimizing a window size.

Constraints allow maintaining a valid window by adjusting pointers.

Steps to Apply Sliding Window
Initialize Pointers: left and right to define the window.

Expand the Window: Move right to include new elements.

Shrink the Window: Adjust left when the window becomes invalid.

Track State: Use variables (e.g., counts, sums) to monitor the window's validity.

Update Result: Keep track of the best solution found.

=end

def find_max_average(nums, k)
  max_sum = -Float::INFINITY
  sum = 0.0
  len = nums.length
  start = 0

  (0..len - 1).each do |i|
    sum += nums[i]
    if i >= k - 1
      max_sum = [sum, max_sum].max
      sum -= nums[start]
      start += 1
    end
  end

  max_sum / k
end

def max_vowels(s, k)
  vowels = Set.new(['a', 'e', 'i', 'o', 'u'])
  max_count = 0
  current_count = 0

  s.chars.each_with_index do |char, i|
    current_count += 1 if vowels.include?(char)
    if i >= k
      current_count -= 1 if vowels.include?(s[i - k])
    end
    max_count = [max_count, current_count].max
  end

  max_count
end

def longest_ones(nums, k)
  left = 0
  zero_count = 0
  max_length = 0
  nums.each_with_index do |num, right|
    # Increment zero_count if the current element is 0
    zero_count += 1 if num == 0

    # If there are more zeros than allowed (k), move left pointer to the right
    while zero_count > k
      # Decrement zero_count if the element at left is 0 (since it's being excluded from the window)
      zero_count -= 1 if nums[left] == 0
      left += 1
    end

    # Calculate the current window length and update max_length if needed
    current_length = right - left + 1
    max_length = [max_length, current_length].max
  end
  max_length
end

def longest_subarray(nums)
  left = 0
  max_length = 0
  zero_count = 0
  # [0,1,1,1,0,1,1,0,1]
  nums.each_with_index do |num, right|
    zero_count += 1 if num == 0
    while zero_count > 1
      zero_count -= 1 if nums[left] == 0
      left += 1
    end
    current_length = right - left + 1
    max_length = [max_length, current_length].max
  end

  return max_length - 1 if max_length != 0
  0
end
