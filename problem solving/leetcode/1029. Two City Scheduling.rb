#!/user/bin/ruby
# https://leetcode.com/problems/two-city-scheduling/
# @param {Integer[][]} costs
# @return {Integer}
def two_city_sched_cost(costs)
  sum = 0
  max_limit = costs.length / 2
  costs =   costs.sort {|a,b| (a[0] - a[1]) - (b[0] - b[1])}
  index = 0
  while index < max_limit
    sum+= costs[index][0] + costs[max_limit + index][1]
    index+=1
  end
  sum
end

#         a , b
# costs = [[10, 20], [30, 200], [400, 50], [30, 20]]
costs = [[259, 770], [448, 54], [926, 667], [184, 139], [840, 118], [577, 469]]
puts two_city_sched_cost(costs)
