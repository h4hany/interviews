#!/user/bin/ruby
#https://www.hackerrank.com/challenges/queens-attack-2/problem
#  1. INTEGER n
#  2. INTEGER k
#  3. INTEGER r_q
#  4. INTEGER c_q
#  5. 2D_INTEGER_ARRAY obstacles

def can_attack?(queen_position_in_board, boundary) end

def generate_board(board_size)
  board_array = Array.new(board_size * board_size)
  (board_size).times do |i|
    (board_size).times do |y|
      board_array[i] = [i + 1, y + 1]
    end
  end
  board_array
end

def queensAttack(n, k, r_q, c_q, obstacles)
  # Write your code here
  board_size = n #squrize
  number_obstacles = k
  row_queen_position = r_q
  column_queen_position = c_q
  queen_position_in_board = [row_queen_position, column_queen_position]
  obstacles_positions = obstacles
  board_boundary = [board_size, board_size]
  result = 0

  left_queen_attack = column_queen_position - 1
  down_queen_attack = row_queen_position - 1
  right_queen_attack = board_size - column_queen_position
  up_queen_attack = board_size - row_queen_position

  up_left_queen_attack = [up_queen_attack, left_queen_attack].min
  up_right_queen_attack = board_size - [column_queen_position, row_queen_position].max
  down_left_queen_attack = [column_queen_position, row_queen_position].min -1
  down_right_queen_attack = [row_queen_position - 1, board_size - column_queen_position].min

  # board_array = generate_board(board_size)

  (number_obstacles).times do |index|
    obstacle_row = obstacles[index][0]
    obstacle_column = obstacles[index][1]

    if (obstacle_row == row_queen_position) && (obstacle_column > column_queen_position)
      up_queen_attack = [up_queen_attack, obstacle_column - column_queen_position - 1].min
    else
      down_queen_attack = [down_queen_attack, column_queen_position - obstacle_column - 1].min
    end

    if (obstacle_column == column_queen_position) && (obstacle_row > row_queen_position)
      right_queen_attack = [right_queen_attack, obstacle_row - row_queen_position - 1].min
    else
      left_queen_attack = [left_queen_attack, row_queen_position - obstacle_row - 1].min
    end


    # Math.abs(c_o - c_q) == Math.abs(r_o - r_q) &&
    #   (c_o > c_q && r_o > r_q && (up_right = Math.min(up_right, c_o - c_q - 1)),
    #     c_o > c_q &&
    #       r_o < r_q &&
    #       (down_right = Math.min(down_right, c_o - c_q - 1)),
    #     c_o < c_q && r_o > r_q && (up_left = Math.min(up_left, c_q - c_o - 1)),
    #     c_o < c_q &&
    #       r_o < r_q &&
    #       (down_left = Math.min(down_left, c_q - c_o - 1)));

  end
  # # obstacles = [[5,5],[4,2],[2,3]]
  # # board_size
  # board_array_without_obstacles = []
  # board_array_that_queen_can_attack = []
  #
  # board_array.each do |boundary|
  #   obstacles.each do |obstacle|
  #     obstacle_row = obstacle[0] # 4
  #     obstacle_column = obstacle[1] # 2
  #
  #     row_queen_position = 4
  #     column_queen_position = 3
  #   end
  # end
  # # puts board_array
  # # while board_size > 0
  # #
  # # end

end

# 4 0
# 4 4
#
# 5 3
# 4 3
# 5 5
# 4 2
# 2 3
n = 5
k = 3
r_q = 4
c_q = 3
obstacles = [[5, 5], [4, 2], [2, 3]]
puts queensAttack(n, k, r_q, c_q, obstacles)
