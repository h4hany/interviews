# https://leetcode.com/problems/set-matrix-zeroes/
# @param {Integer[][]} matrix
# @return {Void} Do not return anything, modify matrix in-place instead.
def set_zeroes(matrix)
  m, n = [matrix.size, matrix.first.size]
  for i in (0...m)
    for j in (0...n)
      if matrix[i][j] == 0
        mark_for_zeroes(matrix, [:top, :bottom, :left, :right], i, j, m, n)
      end
    end
  end
  for i in (0...m)
    for j in (0...n)
      matrix[i][j] ||= 0
    end
  end
end

def mark_for_zeroes(matrix, directions, i, j, m, n)
  if i - 1 >= 0 && directions.include?(:top)
    matrix[i - 1][j] = matrix[i - 1][j] == 0 ? 0 : nil
    mark_for_zeroes(matrix, [:top], i - 1, j, m, n)
  end
  if i + 1 < m && directions.include?(:bottom)
    matrix[i + 1][j] = matrix[i + 1][j] == 0 ? 0 : nil
    mark_for_zeroes(matrix, [:bottom], i + 1, j, m, n)
  end
  if j - 1 >= 0 && directions.include?(:left)
    matrix[i][j - 1] = matrix[i][j - 1] == 0 ? 0 : nil
    mark_for_zeroes(matrix, [:left], i, j - 1, m, n)
  end
  if j + 1 < n && directions.include?(:right)
    matrix[i][j + 1] = matrix[i][j + 1] == 0 ? 0 : nil
    mark_for_zeroes(matrix, [:right], i, j + 1, m, n)
  end
end
