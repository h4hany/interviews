### AI Mocked Interview

### **prompt**

> Act as interviewer for tech company
> Here is my experience. I have more than 10 years of experience as a software engineer.
> i am applying for Senior Backend Software Engineer
> the main stack is rails
> Now I want you to ask me 20 questions for Problem Solving, Algorithms, and Data Structures
> and i want the questions to be one by one so you ask, then i answer the question
> then you give feedback about my answer
> your feedback should have
> rate my answer from 1 to 10. ,
> my strength point in my answer and my weak point ,
> the correct answer for this question ,
> what i need to do so that i can improve my answer

### **Questions**

---

1. Given an unsorted array of integers, find the two numbers such that their sum is closest to zero.

You can assume that the array has at least two elements. How would you approach solving this problem?

### **Answer**

```ruby
arr = [5, 6, 0, 2, 3]

def closets_zero(arr)
  arr.sort!

  left = 0
  right = arr.size - 1
  min_sum = arr[left] + arr[right]

  while left < right
    current_sum = arr[left] + arr[right]
    min_sum = current_sum if current_sum.abs < min_sum.abs

    if current_sum > 0
      right -= 1
    elsif current_sum < 0
      left += 1
    else
      return [arr[left], arr[right]]
    end
  end

  return [arr[left], arr[right]]
end
```

---

2. How would you implement a function to determine if a string has all unique characters?

```ruby

def has_unique_characters_optimized?(str)
  seen = Set.new
  str.each_char do |char|
    return false if seen.include?(char)
    seen.add(char)
  end
  true
end
```

---

3. Given a binary tree, write a function to find the height of the tree. The height of a tree is the length of the
   longest path from the root to a leaf node.

```ruby

def height(root)
  return 0 if root.nil? # An empty tree has height 0
  return 1 if root.left.nil? && root.right.nil? # A leaf node has height 1
  1 + [height(root.left), height(root.right)].max
end
```

---

4. Write a function to find the first non-repeating character in a string. If it doesn't exist, return nil. How would
   you solve this?

```ruby

def first_non_repeating_char(str)
  return nil if str.nil? || str.empty? # Explicitly handle edge cases
  char_count = Hash.new(0)
  str.each_char { |char| char_count[char] += 1 }
  str.each_char { |char| return char if char_count[char] == 1 }
  nil
end
```

---

5. Write a function to reverse the words in a sentence while maintaining the word order. For example: Input: "Hello
   World" Output: "olleH dlroW"

```ruby 

def reverse(str)
  return "" if str.nil? || str.empty?
  str.split(' ').map(&:reverse).join(' ')
end
```

---

6. Write a function to check if two strings are anagrams of each other. For example:

Input: "listen", "silent"
Output: true

```ruby

def angram(str1, str2)
  return false if str1.length != str2.length
  str1.chars.sort == str2.chars.sort
end
```

---

7. Write a function to find the longest substring without repeating characters in a given string. For example:

Input: "abcabcbb"
Output: "abc"

```ruby

def longest_substrings(str)
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

# Sliding Window Technique
def longest_substring(str)
  char_map = {}
  start_idx = 0
  max_length = 0
  result = ""

  str.chars.each_with_index do |char, index|
    # If the character is repeated within the current window, move the start index
    if char_map.key?(char) && char_map[char] >= start_idx
      start_idx = char_map[char] + 1
    end

    # Update the character's index
    char_map[char] = index

    # Check if the current substring is the longest
    if index - start_idx + 1 > max_length
      max_length = index - start_idx + 1
      result = str[start_idx..index]
    end
  end

  result
end

```

---

8. Write a function in Ruby to merge two sorted arrays into one sorted array. For example:

Input: [1, 3, 5] and [2, 4, 6,9]
Output: [1, 2, 3, 4, 5, 6,9]

```ruby 

def merge_sorted_arrays(arr1, arr2)
  arr1.concat(arr2).sort
end

def merge_sorted_arrays2(arr1, arr2)
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
```  

---

9. Write a function in Ruby to find the majority element in an array. The majority element is the element that appears
   more than n/2 times, where n is the size of the array. If no such element exists, return nil.

For example:

Input: [3, 3, 4, 2, 3, 3, 5]
Output: 3
Input: [1, 2, 3, 4]
Output: nil

```ruby

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
```

--- 

10. Write a function in Ruby to detect if a string is a palindrome. A palindrome is a word, phrase, or sequence that
    reads the same backward as forward (ignoring spaces, punctuation, and capitalization).

For example:

Input: "A man, a plan, a canal, Panama"
Output: true
Input: "race a car"
Output: false

```ruby

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
```
