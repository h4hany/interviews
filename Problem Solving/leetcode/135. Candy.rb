#!/user/bin/ruby
# https://leetcode.com/problems/candy/
# @param {Integer[]} ratings
# @return {Integer}
def candy(ratings)
  return 0 if ratings.empty?
  return ratings.length if ratings.length == 1
  count = ratings.length
  count_arr = Array.new(ratings.length).fill(1)
  # [1,2,87,87,87,2,1]
  # prev = 0
  # current = 1
  current = 1
  while current < ratings.length
    prev = current - 1
    next_index = current + 1
    if ratings[current] > ratings[prev] && (count_arr[current] <= count_arr[prev])
      count_arr[current] += 1
    end
    if ratings[next_index] && ratings[current] > ratings[next_index] && (count_arr[current] <= count_arr[next_index])
      count_arr[current] += 1
    end
    if prev == 0 && (ratings[prev] > ratings[current] && count_arr[prev] <= count_arr[current])
      count_arr[prev] += 1
    end
    current += 1
  end
  count_arr.to_s
  # while current < ratings.length
  #   if prev == 0 && (ratings[prev] > ratings[current])
  #     count += 1
  #   elsif ratings[current] > ratings[prev] || (ratings[current + 1] && ratings[current] > ratings[current + 1])
  #     count += 1
  #   end
  #   current += 1
  #   prev += 1
  # end
  # count
end

def candy2(ratings)
  ans = 0
  cur = 0
  dp = Array.new(ratings.length).fill(0)
  dp[ratings.length - 1] = 0
  i = ratings.length - 2
  while i >= 0
    if ratings[i] > ratings[i + 1]
      dp[i] = dp[i + 1] + 1
    else
      dp[i] = 0
    end
    i -= 1
  end
  ans = dp[0] + 1
  i = 1
  while i < ratings.length
    cur = ratings[i] > ratings[i - 1] ? cur + 1 : 0
    ans += [cur, dp[i]].max + 1
    i += 1
  end

  ans
end

ratings = [1, 0, 2]
ratings = [1, 2, 87, 87, 87, 2, 1]
puts candy2(ratings)
