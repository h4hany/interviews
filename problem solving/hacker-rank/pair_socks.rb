#!/usr/bin/ruby
# https://www.hackerrank.com/challenges/sock-merchant?h_l=interview&playlist_slugs%5B%5D=interview-preparation-kit&playlist_slugs%5B%5D=warmup
def sockMerchant(n, ar)
  # Write your code here
  hash_result = {}
  count_pairs = 0
  ar.each  do |sock|
    if hash_result[sock]
      sock_hash = {count: hash_result[sock][:count] + 1 , pairs: 0}
      if sock_hash[:count] % 2 == 0
        sock_hash[:pairs] += 1
        count_pairs +=  sock_hash[:pairs]
      end
      hash_result[sock] =   sock_hash
    else
      hash_result[sock] = {count: 1, pairs: 0}
    end
  end

  count_pairs
end

ar = [10, 20, 20, 10, 10, 30, 50, 10, 20]
n = 9
puts sockMerchant(n, ar)
