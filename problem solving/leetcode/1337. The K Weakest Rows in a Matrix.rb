#!/user/bin/ruby
# https://leetcode.com/problems/the-k-weakest-rows-in-a-matrix/
# @param {Integer[][]} mat
# @param {Integer} k
# @return {Integer[]}
def k_weakest_rows(mat, k)
  hash = {}
  mat.each_with_index do |row,i|
    count = row.join('').count('1')
    hash[i] = count
  end
  hash.sort_by {|_, v| v}.first(3).map(&:first)
end
mat =
  [[1,1,0,0,0],
   [1,1,1,1,0],
   [1,0,0,0,0],
   [1,1,0,0,0],
   [1,1,1,1,1]]
    puts k_weakest_rows(mat, 3)
