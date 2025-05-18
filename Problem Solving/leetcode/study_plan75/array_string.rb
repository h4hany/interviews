#/bin/ruby

# @param {String} word1
# @param {String} word2
# @return {String}
def merge_alternately(word1, word2)
  merged = []
  max_length = [word1.length, word2.length].max

  (0...max_length).each do |i|
    merged << word1[i] if i < word1.length
    merged << word2[i] if i < word2.length
  end

  merged.join
end

# @param {String} str1
# @param {String} str2
# @return {String}
def gcd_of_strings(str1, str2)
  return '' if (str1 + str2 != str2 + str1)
  len1 = str1.length
  len2 = str2.length

  while len2 != 0
    temp = len2
    len2 = len1 % len2
    len1 = temp
  end
  str1[0..len1 - 1]
end

# @param {Integer[]} candies
# @param {Integer} extra_candies
# @return {Boolean[]}
def kids_with_candies(candies, extra_candies)
  result = []
  candies.each do |c|
    candies_with_extra = c + extra_candies
    candies_with_extra >= candies.max ? result.push(true) : result.push(false)
  end
  result
end

# @param {Integer[]} flowerbed
# @param {Integer} n
# @return {Boolean}
def can_place_flowers(flowerbed, n)
  len = flowerbed.length
  remain_flower = n
  (0..len - 1).each do |i|
    # puts i
    if flowerbed[i] == 0 && remain_flower > 0
      if i == 0 && flowerbed[i + 1] != 1 && flowerbed[i] == 0
        flowerbed[i] = 1
        remain_flower -= 1
        puts 'start'
      end

      if i == len - 1 && flowerbed[i - 1] != 1 && flowerbed[i] == 0
        flowerbed[i] = 1
        remain_flower -= 1
        puts 'end'

      end

      if flowerbed[i - 1] != 1 && flowerbed[i + 1] != 1 && flowerbed[i] == 0
        flowerbed[i] = 1
        remain_flower -= 1
        puts 'middle'
      end
    end

  end
  puts flowerbed
  puts remain_flower
  remain_flower == 0 ? true : false

end

# @param {String} s
# @return {String}
def reverse_vowels(s)
  vowels = %w[a e i o u]
  vowels_indexs = []
  vowels_char = []
  s.chars.each_with_index do |c, index|
    if vowels.include?(c.downcase)
      vowels_indexs.push(index)
      vowels_char.push(c)
    end
  end
  vowels_char.reverse!
  vowels_indexs.each_with_index { |i,index| s[i] = vowels_char[index] }

  s
end

# @param {String} s
# @return {String}
def reverse_words(s)
  s.split(' ').reverse.join(' ')
end

# @param {Integer[]} nums
# @return {Integer[]}
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

# @param {Integer[]} nums
# @return {Boolean}
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

# @param {Character[]} chars
# @return {Integer}
def compress(chars)
  write_index = 0
  read_index = 0

  while read_index < chars.length
    char = chars[read_index]
    count = 0

    while read_index < chars.length && chars[read_index] == char
      count += 1
      read_index += 1
    end

    chars[write_index] = char
    write_index += 1

    if count > 1
      count.to_s.each_char do |c|
        chars[write_index] = c
        write_index += 1
      end
    end
  end
  return write_index
end
