#!/user/bin/ruby
# https://leetcode.com/problems/coin-change/
# @param {Integer[]} coins
# @param {Integer} amount
# @return {Integer}
def coin_change(coins, amount)
  dp = Array.new(amount + 1)
  dp[0] = 0
  1.upto(amount) do |a|
    min_combination = Float::INFINITY
    coins.each do |c|
      prev_amount = a - c
      next if prev_amount < 0
      min_combination = dp[prev_amount] if dp[prev_amount] < min_combination
    end
    dp[a] = min_combination + 1
  end
  dp[amount] == Float::INFINITY ? -1 : dp[amount]
end
coins = [1,2,5]
amount = 11
# Output: 3
# Explanation: 11 = 5 + 5 + 1
puts  coin_change(coins, amount)
