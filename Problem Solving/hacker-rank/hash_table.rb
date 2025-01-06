#!/user/bin/ruby
#https://www.hackerrank.com/challenges/ctci-ransom-note/problem?h_l=interview&playlist_slugs%5B%5D=interview-preparation-kit&playlist_slugs%5B%5D=dictionaries-hashmaps
def checkMagazine(magazine, note)
  # Write your code here

  result_arr = []
  result = 'Yes'
  note.each do |selected_word|
    if note.count(selected_word) > magazine.count(selected_word)
      result = 'No'
      break
    end
    if magazine.include?(selected_word)
      result_arr.push(selected_word)
    else
      result = 'No'
      break
    end
  end
  puts result
end

magazine = %w[give me one grand today night]
note = %w[give one grand today]
magazine = %w[attack at dawn]
note = %w[Attack at dawn]
magazine = %w[two times three is not four]
note = %w[two times two is four]
# magazine = %w[h ghq g xxy wdnr anjst xxy wdnr h h anjst wdnr]
# note = %w[h ghq]
 magazine = %w[]
 note = %w[]
magazine = %w[]
note = %w[]
puts checkMagazine(magazine, note)
