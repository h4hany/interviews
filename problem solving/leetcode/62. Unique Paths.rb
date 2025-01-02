# https://leetcode.com/problems/unique-paths/
#!/user/bin/ruby
# @param {Integer} m
# @param {Integer} n
# @return {Integer}
def unique_paths(m, n)
  matrix = Array.new(n) { Array.new(m) }
  (0...m).each do |col|
    matrix[0][col] = 1
  end
  (0...n).each do |row|
    matrix[row][0] = 1
  end

  (1...n).each do |row|
    (1...m).each do |col|
      matrix[row][col] = matrix[row][col - 1] + matrix[row - 1][col]
    end
  end
  puts matrix.to_s

  matrix[-1][-1]
end

m = 3
n = 2
puts unique_paths(m, n)
