#!/user/bin/ruby
# https://www.hackerrank.com/challenges/new-year-chaos/problem?isFullScreen=true&h_l=interview&playlist_slugs%5B%5D=interview-preparation-kit&playlist_slugs%5B%5D=arrays&h_r=next-challenge&h_v=zen
def minimum_bribes(q)
  # Write your code here
  index = 0
  dp = Array.new(q.length).fill(0)
  while index < q.length
      if q[index] > index + 1
        dp[index] = q[index] - (index + 1)
      end

    index += 1
  end
  puts dp.to_s
  puts dp.max > 2 ? 'Too chaotic.' : dp.sum
end

# puts minimum_bribes([2, 1, 5, 3, 4])
puts minimum_bribes([1 ,2 ,5, 3 ,7, 8, 6, 4])
