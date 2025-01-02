#!/user/bin/ruby
# https://leetcode.com/problems/robot-bounded-in-circle/
# @param {String} instructions
# @return {Boolean}
def is_robot_bounded(instructions)
  # direction N = 0, E = 1, S = 2, W = 3
  direction = 0
  x, y = 0, 0
  coordinates = [[0, 1], [1, 0], [0, -1], [-1, 0]]
  dx, dy = 0, 1

  instructions.each_char do |instruction|
    if instruction == 'G'
      dx, dy = coordinates[direction]
      x, y = x + dx, y + dy
    elsif instruction == 'L'
      direction = direction == 0 ? 3 : direction - 1
    elsif instruction == 'R'
      direction = direction == 3 ? 0 : direction + 1
    end
  end
  return true if x == 0 && y == 0
  direction != 0
end

instructions = "GGLLGG"
puts is_robot_bounded(instructions)
