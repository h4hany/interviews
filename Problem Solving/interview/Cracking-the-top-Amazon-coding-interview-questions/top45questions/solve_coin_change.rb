#!/user/bin/ruby
# Coin Changing Problem
# Problem Statement
# Suppose we have coin denominations of [1, 2, 5] and the total amount is 7. We can make changes in the following 6 ways:
def solve_coin_change(denominations, amount)
  solution = []
  (0..amount).each { |i|
    solution[i] = 0
  }
  solution[0] = 1
  (0..denominations.length - 1).each { |j|
    (denominations[j]..amount).each { |i|
      solution[i] += solution[i - denominations[j]]
    }
  }
   solution[solution.length - 1]
end

denominations = [1, 2, 5]
amount = 7
result = solve_coin_change(denominations, amount)
