#!/user/bin/ruby
# https://www.hackerrank.com/challenges/2d-array/problem?h_l=interview&isFullScreen=true&playlist_slugs%5B%5D%5B%5D=interview-preparation-kit&playlist_slugs%5B%5D%5B%5D=arrays
def hourglass_um(arr)
  # Write your code here
  sum = -64
  (0..3).each do |row|
    (0..3).each do |col|
      top = arr[row][col] + arr[row][col + 1] + arr[row][col + 2]
      middle = arr[row + 1][col + 1]
      bottom = arr[row + 2][col] + arr[row + 2][col + 1] + arr[row + 2][col + 2]
      sum = top + middle + bottom if ((top + middle + bottom) > sum)
    end
  end
  sum
end
# 1 1 1 0 0 0
# 0 1 0 0 0 0
# 1 1 1 0 0 0
# 0 0 0 0 0 0
# 0 0 0 0 0 0
# 0 0 0 0 0 0
