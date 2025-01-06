#!/user/bin/ruby
#https://www.hackerrank.com/challenges/common-child/problem?utm_campaign=challenge-recommendation&utm_medium=email&utm_source=7-day-campaign
#
def debug_info(var_name, value)
  puts "#{var_name}: #{value}"
end
def commonChild(s1, s2)
  # Write your code here
  hash_s2 = {}

  s = ''
  s2.split('').each_with_index  do |char,index|
    hash_s2[index] = char
  end

  s1.split('').each_with_index do |char,index1|
    puts "------------------(#{char} ,#{index1})------------------------"
    index_of_s2 = 0
    if s2.include?(char)
      index_of_s2 = hash_s2.key(char) # 2
      s += char
    end
    # s=HN
    # s1 = 'SHINCHAN'
    # s2 = 'NOHARAAA'
    debug_info('positon of chars',index_of_s2)
    debug_info('hash_s2',hash_s2)

    debug_info('s',s)
    #['h','n']
    s.split('').each_with_index do |char2,index|
      debug_info('char2',char2)

      debug_info('hash_s2[char2]',hash_s2.key(char2))

      puts '--------------   inside loop ---------------------'
      if hash_s2.key(char2) < index_of_s2
        # arr = s[index..-1] || ''
        # s = s[index..-1] || ''
        # s.delete(char2)
        s = char2

      end
      debug_info('s inside ',s)

    end
    debug_info('s after delete',s)

    puts '--------------   outside  ---------------------'

  end
  puts s
  s.length
end

# s1 = 'SHINCHAN'
# s2 = 'NOHARAAA'
# s1 ='ABCDEF'
# s2='FBDAMN'
# s1 = 'HARRY'
# s2 = 'SALLY'
s1 ='ELGGYJWKTDHLXJRBJLRYEJWVSUFZKYHOIKBGTVUTTOCGMLEXWDSXEBKRZTQUVCJNGKKRMUUBACVOEQKBFFYBUQEMYNENKYYGUZSP'
s2 ='FRVIFOVJYQLVZMFBNRUTIYFBMFFFRZVBYINXLDDSVMPWSQGJZYTKMZIPEGMVOUQBKYEWEYVOLSHCMHPAZYTENRNONTJWDANAMFRX'
puts commonChild(s1, s2)
