# https://leetcode.com/problems/longest-increasing-subsequence/
#!/user/bin/ruby
# @param {Integer[]} nums
# @return {Integer}
def length_of_lis(nums)
  tails = Array.new
  k = 0 # k is length of tails array
  nums.each do |num|
    start, finish = 0, k
    while start != finish
      mid = (start + finish)/2
      if tails[mid] < num
        start = mid + 1
      else
        finish = mid
      end
    end
    tails[start] = num
    k += 1 if start == k # new insertion in tails array, increase size of tails
  end
   k # longest increasing subsequence size
end
nums = [10,9,2,5,3,7,101,18]
puts length_of_lis(nums)
