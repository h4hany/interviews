#!/user/bin/ruby
#https://www.hackerrank.com/challenges/queens-attack-2/problem
#  1. INTEGER n
#  2. INTEGER k
#  3. INTEGER r_q
#  4. INTEGER c_q
#  5. 2D_INTEGER_ARRAY obstacles

def queensAttack(n, k, r_q, c_q, obstacles)

  up = n - r_q
  right = n - c_q
  down = r_q - 1
  left = c_q - 1

  up_left =[up, left].min
  up_right = n - [c_q, r_q].max
  down_left =[c_q, r_q].min- 1
  down_right =[r_q - 1, n - c_q].min

  k.times do |i|
    r_o= obstacles[i][0]
    c_o= obstacles[i][1]

    r_o == r_q && (c_o > c_q ? (up = [up, c_o - c_q - 1].min) : (down = [down, c_q - c_o - 1].min))

    c_o == c_q && (r_o > r_q ? (right = [right, r_o - r_q - 1].min) : (left = [left, r_q - r_o - 1].min))

   (c_o - c_q).abs == (r_o - r_q).abs &&
      (c_o > c_q && r_o > r_q && (up_right =[up_right, c_o - c_q - 1].min)
        c_o > c_q &&
          r_o < r_q &&
          (down_right =[down_right, c_o - c_q - 1].min)
        c_o < c_q && r_o > r_q && (up_left =[up_left, c_q - c_o - 1].min)
        c_o < c_q &&
          r_o < r_q &&
          (down_left =[down_left, c_q - c_o - 1].min))
  end

  right + left + up + down + down_left + up_left + down_right + up_right

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
