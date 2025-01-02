def split_array(nums, m)
  (nums.max .. nums.inject(:+)).bsearch { |cap|
    subarrays = 0
    sum = cap
    nums.each { |num|
      if (sum += num) > cap
        sum = num
        subarrays += 1
      end
    }
    subarrays <= m
  }
end
