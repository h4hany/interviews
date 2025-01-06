#!/user/bin/ruby
# https://leetcode.com/problems/valid-sudoku/
# @param {Character[][]} board
# @return {Boolean}
def is_valid_sudoku(board)
  res = []
  [0, 3, 6].each do |col|
    [0, 3, 6].each do |row|
      return false unless partially_valid?(board, row, col)
      res << board[row..row + 2].map { |cc| cc[col..col + 2] }.flatten.reject { |b| b == '.' }
    end
  end
  puts res.to_s
  true
end

def partially_valid?(board, row, col)
  partial_square = board[row..row + 2].map { |cc| cc[col..col + 2] }.flatten.reject { |b| b == '.' }
  partial_square.uniq.size == partial_square.size
end

board =
  [["5", "3", ".", ".", "7", ".", ".", ".", "."],
   ["6", ".", ".", "1", "9", "5", ".", ".", "."],
   [".", "9", "8", ".", ".", ".", ".", "6", "."],
   ["8", ".", ".", ".", "6", ".", ".", ".", "3"],
   ["4", ".", ".", "8", ".", "3", ".", ".", "1"],
   ["7", ".", ".", ".", "2", ".", ".", ".", "6"],
   [".", "6", ".", ".", ".", ".", "2", "8", "."],
   [".", ".", ".", "4", "1", "9", ".", ".", "5"],
   [".", ".", ".", ".", "8", ".", ".", "7", "9"]]

b = [[".", ".", "4", ".", ".", ".", "6", "3", "."],
     [".", ".", ".", ".", ".", ".", ".", ".", "."],
     ["5", ".", ".", ".", ".", ".", ".", "9", "."],
     [".", ".", ".", "5", "6", ".", ".", ".", "."],
     ["4", ".", "3", ".", ".", ".", ".", ".", "1"],
     [".", ".", ".", "7", ".", ".", ".", ".", "."],
     [".", ".", ".", "5", ".", ".", ".", ".", "."],
     [".", ".", ".", ".", ".", ".", ".", ".", "."],
     [".", ".", ".", ".", ".", ".", ".", ".", "."]]
is_valid_sudoku(b)
