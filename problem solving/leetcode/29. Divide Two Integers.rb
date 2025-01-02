#!/user/bin/ruby
# https://leetcode.com/problems/divide-two-integers/
# @param {Integer} dividend
# @param {Integer} divisor
# @return {Integer}
def divide(dividend, divisor)
  flag = [dividend, divisor].one?(&:positive?)
  dividend, divisor = dividend.abs, divisor.abs
  res = 0
  while dividend >= divisor
    tmp, mul = divisor, 1
    while dividend >= tmp
      dividend -= tmp
      res += mul
      mul = mul << 1
      tmp = tmp << 1
    end
  end
  flag ? [res * -1, -2147483648].max : [res, 2147483647].min
end

dividend = 10
divisor = 3
puts divide(dividend, divisor)
