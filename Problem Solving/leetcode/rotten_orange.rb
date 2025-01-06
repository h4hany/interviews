#!/user/bin/ruby
# https://leetcode.com/problems/rotting-oranges/
# @param {Integer[][]} grid
# @return {Integer}
def oranges_rotting(grid)
  rows = grid.length - 1
  columns = grid[0].length - 1
  dirs = [[0, 1], [1, 0], [0, -1], [-1, 0]]
  oranges = 0
  time = 0
  queue = []
  (0..rows).each do |x|
    (0..columns).each do |y|
      if grid[x][y] == 1
        oranges += 1
      elsif grid[x][y] == 2
        queue.push([x, y, 0])
      end
    end
  end
  while queue.length > 0 && oranges
    cur_x, cur_y, mins = queue.shift
    if grid[cur_x][cur_y] == 1
      grid[cur_x][cur_y] = 2
      oranges -= 1
      time = mins
    end

    dirs.each do |select_dir|
      new_x = cur_x + select_dir[0]
      new_y = cur_y + select_dir[1]
      unless new_x < 0 || new_x > rows || new_y < 0 || new_y > columns
        if grid[new_x][new_y] == 1
          queue.push([new_x, new_y, mins + 1])
        end
      end
    end
  end
  oranges > 0 ? -1 : time
end


grid = [[2, 1, 1], [1, 1, 0], [0, 1, 1]]
# grid = [[2,1,1],[0,1,1],[1,0,1]]
puts oranges_rotting(grid)
