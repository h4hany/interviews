#!/user/bin/ruby
# https://leetcode.com/problems/flood-fill/
def flood_fill(image, sr, sc, new_color)
  start_point_val = image[sr][sc]
  unless start_point_val == new_color
    flood_fill_util(image, sr, sc, start_point_val, new_color)
  end
  image.to_s

end

def flood_fill_util(image, sr, sc, prev_color, new_color)
  rows = image.length
  columns = image[0].length
  unless sr < 0 || sr > rows - 1 || sc < 0 || sc > columns - 1 || image[sr][sc] != prev_color
    image[sr][sc] = new_color
    flood_fill_util(image, sr + 1, sc, prev_color, new_color)
    flood_fill_util(image, sr - 1, sc, prev_color, new_color)
    flood_fill_util(image, sr, sc + 1, prev_color, new_color)
    flood_fill_util(image, sr, sc - 1, prev_color, new_color)
    image.to_s

  end
  image.to_s
end

image = [[1, 1, 1], [1, 1, 0], [1, 0, 1]]
sr = 1
sc = 1
new_color = 2
image = [[0,0,0],[0,1,0]]
sr = 1
sc = 1
new_color = 1
# image = [[2, 1, 1], [1, 1, 0], [0, 1, 1]]
# sr = 0
# sc = 0
# new_color = 2
puts flood_fill(image, sr, sc, new_color)
