#!/user/bin/ruby
# https://www.hackerrank.com/challenges/ctci-array-left-rotation/problem?isFullScreen=true&h_l=interview&playlist_slugs%5B%5D=interview-preparation-kit&playlist_slugs%5B%5D=arrays
def rot_left(a, d)
  # Write your code here
  arr = (1..a).to_a
  index = d - 1
  arr[index + 1..arr.length] + arr[0..index]
end

# 1 2 3 4 5
puts rot_left(5, 4)
