#!/user/bin/ruby
# https://leetcode.com/problems/max-area-of-island/
def max_area_of_island(grid)
  rows = grid.length - 1
  columns = grid[0].length - 1
  res = 0
  (0..rows).each do |x|
    (0..columns).each do |y|
      if grid[x][y] == 1
        res = [res, max_area_of_island_util(grid, x, y)].max
      end
    end
  end
  res
end

def max_area_of_island_util(grid, x, y)
  rows = grid.length
  columns = grid[0].length
  return 0 if x < 0 || x >= rows || y < 0 || y >= columns  || grid[x][y] == 0
  grid[x][y] = 0
  1 + max_area_of_island_util(grid, x + 1, y) +
    max_area_of_island_util(grid, x - 1, y) +
    max_area_of_island_util(grid, x, y + 1) +
    max_area_of_island_util(grid, x, y - 1)
end

grid = [[0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0],
        [0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0],
        [0, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0]]
puts max_area_of_island(grid)
