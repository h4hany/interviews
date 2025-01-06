#!/user/bin/ruby
# https://leetcode.com/problems/powx-n/
# @param {Float} x
# @param {Integer} n
# @return {Float}
def my_pow(x, n)
  return 1 if n == 0
  return x if n == 1
  return x * x if n == 2

  if n < 0
    return 1 / x * my_pow(1 / x, - (n + 1))
  end

  if n % 2 == 0
    return   my_pow(my_pow(x,n/2),2)
  else
    return  x * my_pow(my_pow(x,n/2),2)
  end

end
