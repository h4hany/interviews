#!/user/bin/ruby
def test
  hash={x:1}
  x = 1
  increase(hash)
  hash
end
def increase(arg)
  arg[:x] += 1
end
puts test
