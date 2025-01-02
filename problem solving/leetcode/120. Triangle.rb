#!/user/bin/ruby
# https://leetcode.com/problems/triangle/
# @param {Integer[][]} triangle
# @return {Integer}
def minimum_total(triangle)
  sum = 0
  sum_next = 0
  result = []
  triangle.each_with_index do |tr, index|
    if index == 0
      sum += tr[index]
      result.push(tr[index])
    elsif index == triangle.length - 1
      sum += tr.min
      result.push(tr.min)
    elsif index - 1 >= 0
      selected = tr[index] > tr[index - 1] ? tr[index - 1] : tr[index]
      sum += selected
      result.push(selected)
    end
    # if index - 1 >= 0 && index != triangle.length - 1
    #   selected = tr[index] > tr[index - 1] ? tr[index - 1] : tr[index]
    #   sum += selected
    #   result.push(selected)
    # else
    #   sum += tr.min
    #   result.push(tr.min)
    # end
    # if index - 1 >= 0
    #   selected = tr[index] > tr[index - 1] ? tr[index - 1] : tr[index]
    #   sum += selected
    #   result.push(selected)
    # else
    #   puts triangle.length
    #   puts index
    #   if index == triangle.length - 1
    #     puts 'aaaaa'
    #     sum += tr.min
    #     result.push(tr.min)
    #   else
    #     sum += tr[index]
    #     result.push(tr[index])
    #   end
    # end

    # if tr[index]
    #   sum += tr[index]
    # elsif index - 1 >= 0
    #   unless tr[index] > tr[index - 1]
    #     sum-= tr[index]
    #     sum+= tr[index - 1]
    #   end
    # end
  end
  puts result.to_s
  sum

end

triangle = [[2], [3, 4], [6, 5, 7], [4, 1, 8, 3]]
triangle = [[-1], [2, 3], [1, -1, -3]]
# -1

puts minimum_total(triangle)

#    -1
#   2   3
# 1   -1   -3
