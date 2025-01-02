#!/user/bin/ruby
# https://www.hackerrank.com/challenges/sherlock-and-anagrams/problem?h_l=interview&playlist_slugs%5B%5D=interview-preparation-kit&playlist_slugs%5B%5D=dictionaries-hashmaps&h_r=next-challenge&h_v=zen&h_r=next-challenge&h_v=zen
def sherlockAndAnagrams(s)
  # Write your code here
  counter = Hash.new(0)
  (1..s.size).each do |length|
    s.chars.each_cons(length) do |sub_str|
      puts sub_str.to_s
      puts '---------------------------'
      counter[sub_str.sort.join] += 1
    end
  end
  puts counter
  counter.values.map { |n| n * (n - 1) / 2 }.sum
end

s = 'abba'
puts sherlockAndAnagrams(s)
