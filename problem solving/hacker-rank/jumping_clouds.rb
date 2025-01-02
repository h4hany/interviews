#!/user/bin/ruby

def jumpingOnClouds(clouds)
  # Write your code here
  len_c = clouds.length
  counter = 0
  result = 0
  while counter < len_c
    # jump ahead as long as it's safe 2 steps ahead or unsafe 1 spot next
    if counter + 2 < len_c && clouds[counter + 2].zero?
      counter += 2
      result += 1
      next
    elsif counter + 1 < len_c && clouds[counter + 1].zero?
      counter += 1
      result += 1
      next
    elsif counter + 1 < len_c && clouds[counter + 1] == 1
      counter += 2
      result += 1
      next
    end
    counter += 1
  end
  result
end

c = [0, 1, 0, 0, 0, 1, 0]
puts jumpingOnClouds(c)