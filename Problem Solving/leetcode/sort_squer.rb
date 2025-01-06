#!/user/bin/ruby
# https://leetcode.com/problems/squares-of-a-sorted-array/
def sorted_squares(nums)

  result = []
  nums.each do |num|
      result.push(num * num)


  end
  result = result_pos

  result_neg.each_with_index do |num,index|
    result_pos.each_with_index do |pos,i|
      if num >= pos && result_pos[i+1] && num <= result_pos[i+1]
        result_pos.insert(i,num)
      end
    end
  end
  result_pos
end
puts sorted_squares([-4,-1,0,3,10])
