#!/user/bin/ruby
# https://www.codewars.com/kata/53db96041f1a7d32dc0004d2/train/ruby
def done_or_not(board)
  #your code here
  reverse_board = board.transpose.map(&:reverse)
  board.each do |row|
    return "Try again!" if row.include?(0)
    return "Try again!" if row.uniq.size < 9
  end
  reverse_board.each do |row|
    return "Try again!" if row.include?(0)
    return "Try again!" if row.uniq.size < 9
    return "Try again!" if is_squares?(board)

  end
  "Finished!"
end
def is_squares?(board)
  res = []
  [0,3,6].each do |col|
    [0,3,6].each do |row|
      res << board[row .. row+2].map{ |cc| cc[col .. col+2] }.flatten
    end
  end
  res.each  do |row|
    row.sum == 45
  end
end
board = [[5, 3, 4, 6, 7, 8, 9, 1, 2],
         [6, 7, 2, 1, 9, 5, 3, 4, 8],
         [1, 9, 8, 3, 4, 2, 5, 6, 7],
         [8, 5, 9, 7, 6, 1, 4, 2, 3],
         [4, 2, 6, 8, 5, 3, 7, 9, 1],
         [7, 1, 3, 9, 2, 4, 8, 5, 6],
         [9, 6, 1, 5, 3, 7, 2, 8, 4],
         [2, 8, 7, 4, 1, 9, 6, 3, 5],
         [3, 4, 5, 2, 8, 6, 1, 7, 9]]

board1 =[[5, 3, 4, 6, 7, 8, 9, 1, 2],
 [6, 7, 2, 1, 9, 0, 3, 4, 9],
 [1, 0, 0, 3, 4, 2, 5, 6, 0],
 [8, 5, 9, 7, 6, 1, 0, 2, 0],
 [4, 2, 6, 8, 5, 3, 7, 9, 1],
 [7, 1, 3, 9, 2, 4, 8, 5, 6],
 [9, 0, 1, 5, 3, 7, 2, 1, 4],
 [2, 8, 7, 4, 1, 9, 6, 3, 5],
 [3, 0, 0, 4, 8, 1, 1, 7, 9]]

board3=[[1, 2, 3, 4, 5, 6, 7, 8, 9], [2, 3, 4, 5, 6, 7, 8, 9, 1], [3, 4, 5, 6, 7, 8, 9, 1, 2], [4, 5, 6, 7, 8, 9, 1, 2, 3], [5, 6, 7, 8, 9, 1, 2, 3, 4], [6, 7, 8, 9, 1, 2, 3, 4, 5], [7, 8, 9, 1, 2, 3, 4, 5, 6], [8, 9, 1, 2, 3, 4, 5, 6, 7], [9, 1, 2, 3, 4, 5, 6, 7, 8]]
# puts done_or_not(board3)
puts squares(board3).to_s
