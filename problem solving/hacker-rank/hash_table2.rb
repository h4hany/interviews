#!/user/bin/ruby
#https://www.hackerrank.com/challenges/ctci-ransom-note/problem?h_l=interview&playlist_slugs%5B%5D=interview-preparation-kit&playlist_slugs%5B%5D=dictionaries-hashmaps
def checkMagazine(magazine, ransom)
  # Write your code here

  ransom_table = Hash.new
  ransom.each do |word|
    ransom_table.has_key?(word) ? ransom_table[word] += 1 : ransom_table[word] = 1
  end
  puts ransom_table
  magazine.each do |word|
    ransom_table[word] -= 1 if ransom_table.has_key?(word)
  end

  flag = true
  ransom_table.each_key do |key|
    flag = false if ransom_table[key] > 0
  end

  print flag ? 'Yes' : 'No'
end

magazine = %w[give me one grand today night]
note = %w[give one grand today]
magazine = %w[attack at dawn]
note = %w[Attack at dawn]
magazine = %w[two times three is not four]
note = %w[two times two is four]
# magazine = %w[h ghq g xxy wdnr anjst xxy wdnr h h anjst wdnr]
# note = %w[h ghq]
#  magazine = %w[]
#  note = %w[]
# magazine = %w[]
# note = %w[]
puts checkMagazine(magazine, note)
