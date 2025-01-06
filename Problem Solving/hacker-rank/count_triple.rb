#!/user/bin/ruby
# https://www.hackerrank.com/challenges/count-triplets-1/problem?h_l=interview&playlist_slugs%5B%5D=interview-preparation-kit&playlist_slugs%5B%5D=dictionaries-hashmaps&h_r=next-challenge&h_v=zen&h_r=next-challenge&h_v=zen&h_r=next-challenge&h_v=zen
def countTriplets(arr, common_ration)
  counter = 0

  arr.combination(3).each do |selected_comp|
    first_element = selected_comp[0]
    flag_seq = true
    selected_comp[1..3].each do |element_num|
      if first_element * common_ration == element_num
        first_element = element_num
      else
        flag_seq = false
        break
      end
    end
    puts selected_comp.to_s
    puts flag_seq

    if flag_seq
      counter += 1
      puts "counter : #{counter}"
    end
    puts '-----------------------------------'

  end
  counter
end

arr = [1, 5, 5, 25, 125]
r = 5
arr = [1, 2, 2, 4]
    # [0, 1, 2, 3]
# 0,1,3  0,2,3
# [1,2,4]
# [1,2,4]

r = 2
puts countTriplets(arr, r)
