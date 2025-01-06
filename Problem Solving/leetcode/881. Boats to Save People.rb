# https://leetcode.com/problems/boats-to-save-people/
#!/user/bin/ruby
# @param {Integer[]} people
# @param {Integer} limit
# @return {Integer}
def num_rescue_boats(people, limit)
  result = []
  sum_arr = []
  people_arr = []
  hash = {}
  people.each do |p|
    if p  == limit
      result.push(p)
    elsif p < limit
      people_arr.push(p)
    end
  end


  people_arr.each do |p|
    if hash[p]
      sum_arr.push([p,limit - p])
      if hash[p] > 1
        sum_arr.push(limit - p)
        hash[p] -= 1
      end
      hash[p]+=1
    else
      hash[limit - p] = 1
    end
  end
  if sum_arr.length  ==  0
    sum_arr = people_arr
  end
  puts sum_arr.to_s
  puts result.to_s
  result.concat(sum_arr)
  result.length
end

def num_rescue_boats2(people, limit)
  people.sort!
  start = 0
  last = people.length - 1
  boats = 0
  while start <= last

    if people[start] + people[last] <= limit

      start += 1
      last -= 1
      boats += 1
    else
      last -= 1
      boats += 1
    end
  end
  boats
end
people = [1,2]
limit = 3
people = [3,2,2,1]
limit = 3
# people = [3,5,3,4]
# limit = 5
puts  num_rescue_boats(people, limit)
