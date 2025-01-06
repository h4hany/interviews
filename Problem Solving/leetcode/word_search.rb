#!/user/bin/ruby
#https://leetcode.com/problems/word-search/\
#
# @param {Character[][]} board
# @param {String} word
# @return {Boolean}
def exist(board, word)
  rows = board.length - 1
  columns = board[0].length - 1
  (0..rows).each do |i|
    (0..columns).each do |j|
      return search_word(i, j, board, word, 0)
    end
  end
  false
end

def search_word(i, j, board, word, index)
  columns = board[0].length
  rows = board.length
  return true if (index == (word.length - 1))
  return false if (i < 0 || i >= rows || j < 0 || j >= columns || board[i][j] != word[index]  || board[i][j] == '*')
  puts "aaa"

  visited_char = board[i][j]
  board[i][j] = '*'
  puts board
  is_exist = (search_word(i + 1, j, board, word, index + 1) ||
    search_word(i - 1, j, board, word, index + 1) ||
    search_word(i, j + 1, board, word, index + 1) ||
    search_word(i, j - 1, board, word, index + 1))

  board[i][j] = visited_char
  is_exist
end

board = [["A", "B", "C", "E"], ["S", "F", "C", "S"], ["A", "D", "E", "E"]]
word = "SEE"
# board = [["A", "B", "C", "E"], ["S", "F", "C", "S"], ["A", "D", "E", "E"]]
# word = "ABCCED"
puts exist(board, word)
