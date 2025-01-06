#!/user/bin/ruby

def equalizeArray(arr)
  hash_repeated_no = {}
  result = 0
  arr.each_with_index do |element, index|
    if hash_repeated_no[element]
      hash_repeated_no[element][:count] += 1
    else
      hash_repeated_no[element] = { count: 1 }
    end
  end
  max_repeated = 0
  min_repeated = 0
  all_arr_has_one = []
  hash_repeated_no.each_pair do |key, value|
    all_arr_has_one.push(hash_repeated_no[key][:count] == 1)
    if hash_repeated_no[key][:count] > 1 && max_repeated < hash_repeated_no[key][:count]
      max_repeated = hash_repeated_no[key][:count]
    else
      min_repeated += 1
    end
  end
  unless all_arr_has_one.include?(false)
    max_repeated = 1
  end
  arr.length - max_repeated
end

arr1 = [3, 3, 2, 1, 3]

arr = [1, 2, 3, 1, 2, 3, 3, 3]
puts equalizeArray(arr)
