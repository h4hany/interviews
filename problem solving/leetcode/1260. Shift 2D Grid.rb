#!/user/bin/ruby
# https://leetcode.com/problems/shift-2d-grid/
# @param {Integer[][]} grid
# @param {Integer} k
# @return {Integer[][]}
def shift_grid(grid, k)
  arr = grid.flatten
  k.times {|i| arr.unshift(arr.pop)}
  arr.each_slice(grid.first.length).to_a
end

grid = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
k = 1
puts shift_grid(grid, k)
