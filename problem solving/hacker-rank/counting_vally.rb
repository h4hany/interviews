#!/user/bin/ruby

def counting_valleys(steps, path)
  # Write your code here
  sea_level = 0
  valleys = 0
  path.split('').each do |selected_path|
    if selected_path == 'U'
      sea_level += 1
    elsif selected_path == 'D'
      if sea_level.zero?
        valleys += 1
      end
      sea_level -= 1
    end
  end
  valleys
end

steps = 8
path = 'UDDDUDUU'
puts counting_valleys(steps, path)