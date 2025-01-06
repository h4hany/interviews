#!/user/bin/ruby
# https://leetcode.com/problems/interval-list-intersections/
# @param {Integer[][]} first_list
# @param {Integer[][]} second_list
# @return {Integer[][]}
def interval_intersection(first_list, second_list)
  # time limit exceed but right
  result = []
  first_list.each do |first|
    second_list.each do |second|
      inter = intersection_btn_arrays(first, second)
      if inter.empty?
        next
      else
        result.push([inter.min,inter.max])
      end
    end
  end
  result
end

def interval_intersection2(first_list, second_list)
  i = j = 0
  intersection = []
  while i < first_list.count && j < second_list.count
    lo = [first_list[i][0], second_list[j][0]].max
    hi = [first_list[i][1], second_list[j][1]].min
    if lo <= hi
      intersection << [lo, hi]
    end
    if first_list[i][1] < second_list[j][1]
      i += 1
    else
      j += 1
    end
  end
  intersection
end



def intersection_btn_arrays(l1, l2)
  (l1[0]..l1[1]).to_a & (l2[0]..l2[1]).to_a
end

first_list = [[0, 2], [5, 10], [13, 23], [24, 25]]
second_list = [[1, 5], [8, 12], [15, 24], [25, 26]]
puts interval_intersection(first_list, second_list)
