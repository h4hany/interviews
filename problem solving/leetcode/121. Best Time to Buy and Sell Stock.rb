#!/user/bin/ruby
# https://leetcode.com/problems/best-time-to-buy-and-sell-stock/
# @param {Integer[]} prices
# @return {Integer}
def max_profit(prices)
  return 0 if prices.empty?
  max_profit = 0
  min_price = prices[0]
  (1..prices.length - 1).each { |i|
    min_price = [min_price, prices[i - 1]].min
    max_profit = [max_profit, prices[i] - min_price].max
  }
  max_profit
end

prices = [7, 1, 5, 3, 6, 4]
puts max_profit(prices)
