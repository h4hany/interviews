def unique_occurrences(arr)
  hash = {}
  arr.each do |n|
    hash[n] = (hash[n] || 0) + 1
  end
  hash.values.length == hash.values.uniq().length

end

def find_difference(nums1, nums2)

  nums1_diff = Set.new
  nums2_diff = Set.new

  nums1.each do |num|
    nums1_diff.add num unless nums2.include? num
  end
  nums2.each do |num|
    nums2_diff.add num unless nums1.include? num
  end
  [nums1_diff.to_a, nums2_diff.to_a]

end
