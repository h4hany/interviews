#!/user/bin/ruby
require 'rtesseract'

image = RTesseract.new("test.jpg")
puts image.to_s # Getting the value