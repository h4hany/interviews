#!/user/bin/ruby
def longest_substring(str)
  longest_str = ''
  result = ''
  char_map = {}
  str.chars.each_with_index do |char, index|
    char_map[char] = char_map[char].nil? ? 1 : char_map[char] + 1
    if char_map[char] && char_map[char] > 1
      longest_str.length > result.length ? result = longest_str : result
      longest_str = ''
    end
    longest_str += char
  end
  result
end

str = 'abcabcbb'
# puts longest_substring(str)
def merge_sorted_arrays(arr1, arr2)
  merged = []
  i, j = 0, 0

  while i < arr1.length && j < arr2.length
    if arr1[i] < arr2[j]
      merged << arr1[i]
      i += 1
    else
      merged << arr2[j]
      j += 1
    end
  end

  # Add any remaining elements from arr1 or arr2
  merged.concat(arr1[i..]) if i < arr1.length
  merged.concat(arr2[j..]) if j < arr2.length

  merged
end

# puts merge_sorted_arrays([1, 3, 5], [2, 4, 6, 9])

# Input: [3, 3, 4, 2, 3, 3, 5]
# Output: 3
def majority_element(arr)
  arr_length = arr.length
  majority = arr_length / 2
  hash = {}
  arr.each do |el|
    hash[el] = hash[el].nil? ? 1 : hash[el] + 1
    return el if hash[el] > majority
  end
  nil
end

# puts majority_element([3, 3, 4, 2, 3, 3, 5])
# puts majority_element([1, 2, 3, 4])

def plaindrom(str)
  str = str.downcase.gsub(/[^a-z0-9]/, '')
  i, j = 0, str.length - 1
  while i < j
    return false if str[i] != str[j]
    i += 1
    j -= 1
  end
  true
end

str = "A man, a plan, a canal, Panama"
puts plaindrom(str)
