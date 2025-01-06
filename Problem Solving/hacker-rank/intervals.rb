#!/user/bin/ruby
# https://www.codewars.com/kata/52b7ed099cdc285c300001cd/train/ruby
def sum_of_intervals(intervals)
  intervals.map{ |a| (a[0]...a[1]).to_a }.flatten.uniq.size

end

intervals = [
  [1, 4],
  [7, 10],
  [3, 5]
]
sum_of_intervals(intervals)

