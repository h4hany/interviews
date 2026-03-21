def dbl_linear(n)
  result = [1]
  arr_length = result.length
  index = 0
  while arr_length < n
    result << (2 *  result[index] ) + 1
    result << (3 *  result[index] ) + 1
    index += 1
    arr_length = result.length
  end
  result[n]
end
puts dbl_linear(10)
# Ex: u = [1, 3, 4, 7, 9, 10, 13, 15, 19, 21, 22, 27, ...]

