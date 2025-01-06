#!/user/bin/ruby
# https://leetcode.com/problems/baseball-game/
# @param {String[]} ops
# @return {Integer}
def cal_points(ops)
  result = []
  ops.each do |op|
    if op == 'C'
      result.pop
    elsif op == 'D'
      result.push(result.last * 2)
    elsif op == '+'
      result.push(result.last(2).sum)
    else
      result.push(op.to_i)
    end
  end
  result.sum
end

ops = ["5", "2", "C", "D", "+"]
ops = ["5","-2","4","C","D","9","+","+"]
puts cal_points(ops)
[5, -2, -4, 9, 5, 14]
