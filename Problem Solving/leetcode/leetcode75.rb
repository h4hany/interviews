#/bin/ruby
# https://leetcode.com/studyplan/leetcode-75/
def product_except_self(nums)
  n = nums.length
  result = Array.new(n, 1)

  left_product = 1
  (1...n).each do |i|
    left_product *= nums[i - 1]
    result[i] = left_product
  end

  right_product = 1
  (n - 2).downto(0).each do |i|
    right_product *= nums[i + 1]
    result[i] *= right_product
  end

  result

end

def increasing_triplet(nums)
  min1 = Float::INFINITY
  min2 = Float::INFINITY
  nums.each do |n|
    if n <= min1
      min1 = n
    elsif n <= min2
      min2 = n
    else
      return true
    end
  end
  false
end

def compress(chars)
  result = ''
  seq_chars = []
  len = chars.length

  seq_chars << chars[0]
  last_char = chars[0]
  return chars if len == 1
  (1..len - 1).each do |index|
    ch = chars[index]

    seq_chars.push(ch) if last_char == ch

    if last_char != ch || index == len - 1
      result += seq_chars[0] if seq_chars.length == 1
      result += "#{seq_chars[0]}#{seq_chars.length}" if seq_chars.length > 1
      seq_chars = [ch]
      last_char = ch
    end
  end
  result.split('').to_s
end

def move_zeroes(nums)
  counter = 0
  nums.each_with_index do |n, i|
    if n == 0
      nums[i] = nil
      counter += 1
    end
  end
  nums.delete(nil)
  while counter > 0
    nums.push(0)
    counter -= 1
  end

end

def is_subsequence(s, t)
  i = 0 # Pointer for string s
  j = 0 # Pointer for string t
  while i < s.length && j < t.length
    if s[i] == t[j]
      i += 1
    end
    j += 1
  end
  i == s.length
end

def max_operations(nums, k)
  counts = Hash.new(0)
  operations = 0

  nums.each do |num|
    complement = k - num
    if counts[complement] > 0
      operations += 1
      counts[complement] -= 1
    else
      counts[num] += 1
    end
  end

  operations

end

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
  # nums = [1,1,0,1]
  # [1,1,0]
  left = 0
  max_length = 0
  current_ones = 0
  last_zero_index = nil
  count_one = 0
  nums.each_with_index do |num, index|

    current_ones += 1 if num == 1

    if num == 0
      count_one = 0
      last_zero_index = index
    else
      count_one += 1
    end

  end
end
nums = [1,1,0,1]
