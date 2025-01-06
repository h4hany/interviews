#!/user/bin/ruby
def generate_anagrams(word)
  words = File.readlines("/usr/share/dict/words")
  dict = Hash.new { |h, k| h[k] = [] }
  words.each do |searched|
    searched = searched.chomp.downcase
    if dict[searched.chars.sort.join('')]
      dict[searched.chars.sort.join('')].push(searched)
    else
      dict[searched.chars.sort.join('')] = [searched]
    end
  end
  puts dict[word.downcase.chars.sort.join('')]
end

def generate_anagrams2(word)
  dictionary = File.open("/usr/share/dict/words").read.split(/\b/)
  result = []
  return result if word.length == 0
  word_characters = word.downcase.chars.sort.join
  if word.length > 2
    dictionary.each do |x|
      if x.downcase.chars.sort.join == word_characters && !result.include?(x)
        result.push(x)
      end
    end
  else
    result.push(word.reverse)
  end
  result
end

# puts generate_anagrams2("LiSTen")
# puts generate_anagrams("LiSTen")
puts generate_anagrams2("LiSTen")

# puts generate_anagrams("suacal")
# puts generate_anagrams("listen")
