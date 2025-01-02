# https://leetcode.com/problems/number-of-islands/
# @param {Character[][]} grid
# @return {Integer}
def num_islands(grid)

  islands = 0
  return islands if grid.empty?

  grid.each_with_index do |row, i|
    row.each_with_index do |col, j|
      if grid[i][j] == '1'
        dfs(grid, i, j)
        islands += 1
      end
    end
  end

  islands
end

def dfs(grid, i, j)
  return if i < 0 || i >= grid.length || j < 0 || j >= grid[0].length || grid[i][j] == '0'
  grid[i][j] = '0'
  dfs(grid, i + 1, j)
  dfs(grid, i - 1, j)
  dfs(grid, i, j + 1)
  dfs(grid, i, j - 1)
end
