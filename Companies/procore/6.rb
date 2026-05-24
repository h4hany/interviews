# Problem 1: Minimum Cost Employee Schedule
# Difficulty: Medium
# Companies: Procore (Custom)
#
# Problem Statement:
#           You are a manager tasked with scheduling employees for a series of jobs over the week. You are given two 2D string arrays: employees and jobs.
#
#   employees[i] = [name, hourly_rate] represents an available employee and their required hourly pay.
#
#   jobs[j] = [day, start_time, end_time] represents a required job shift in a 24-hour format.
#
#   You must assign exactly one employee to each job shift. To optimize the company's budget, you must always assign the available employee with the lowest hourly rate to every job. You may assume the cheapest employee is always available for any shift (no overlapping shift conflicts for the same employee need to be resolved).
#
# Return the total minimum cost to complete all jobs, rounded to two decimal places.
#
# Example 1:
#
# Plaintext
# Input:
# employees = [["Alice", "20"], ["Bob", "15"], ["Charlie", "25"]]
# jobs = [["Monday", "9.0", "17.0"], ["Tuesday", "10.5", "14.5"]]
#
# Output: 180.00
#
# Explanation:
# Bob is the cheapest employee at $15/hr.
# Monday job duration: 17.0 - 9.0 = 8.0 hours. Cost = 8.0 * 15 = $120.00
# Tuesday job duration: 14.5 - 10.5 = 4.0 hours. Cost = 4.0 * 15 = $60.00
# Total Cost = 120.00 + 60.00 = 180.00
# Constraints:
#
# 1 <= employees.length <= 100
#
# 1 <= jobs.length <= 10^4
#
# 0.0 <= start_time < end_time <= 24.0
#
# Hourly rates and times are provided as strings representing valid floating-point numbers.

def optimize_schedule(employees, jobs)

  sorted_employees = employees.map { |name, rate| { name: name, rate: rate.to_f } }
                              .sort_by { |emp| emp[:rate] }

  schedule = []
  total_cost = 0

  jobs.each do |day, start_time, end_time|
    hours = end_time.to_f - start_time.to_f
    next if hours <= 0
    cheapest = sorted_employees.first
    job_cost = hours * cheapest[:rate]
    total_cost += job_cost

    schedule << {
      day: day,
      hours: hours,
      assigned_to: cheapest[:name],
      cost: job_cost
    }
  end

  { schedule: schedule, total_cost: total_cost }
end

# Example Usage:
employees = [["Alice", 20], ["Bob", 15], ["Charlie", 25]]
jobs = [["Monday", 9, 17], ["Tuesday", 10, 15]]

puts optimize_schedule(employees, jobs)


# Problem 2: Toeplitz Matrix
# Difficulty: Easy
# Companies: Procore, Meta, Google
#
# Problem Statement:
#           Given an m x n integer matrix matrix, return true if the matrix is Toeplitz. Otherwise, return false.
#
#   A matrix is Toeplitz if every diagonal from top-left to bottom-right has the same elements.
#
#   Example 1:
#
#   Plaintext
# Input: matrix = [[1,2,3,4],[5,1,2,3],[9,5,1,2]]
# Output: true
#
# Explanation:
#   In the above grid, the diagonals are:
#                                      "[9]", "[5, 5]", "[1, 1, 1]", "[2, 2, 2]", "[3, 3]", "[4]".
#   In each diagonal all elements are the same, so the answer is True.
#   Example 2:
#
#   Plaintext
# Input: matrix = [[1,2],[2,2]]
# Output: false
#
# Explanation:
#   The diagonal "[1, 2]" has different elements.
#   Constraints:
#
#   m == matrix.length
#
# n == matrix[i].length
#
# 1 <= m, n <= 20
#
# 0 <= matrix[i][j] <= 99
#
# Follow up:
#
#          What if the matrix is stored on disk, and the memory is limited such that you can only load at most one row of the matrix into the memory at once?
def is_toeplitz_matrix(matrix)
  (0...matrix.length - 1).each do |r|
    (0...matrix[0].length - 1).each do |c|
      return false if matrix[r][c] != matrix[r + 1][c + 1]
    end
  end
  true
end

# https://leetcode.com/problems/sort-colors/description/
def sort_colors(nums)
  low = 0
  mid = 0
  high = nums.length - 1

  while mid <= high
    if nums[mid] == 0
      nums[low], nums[mid] = nums[mid], nums[low]
      low += 1
      mid += 1
    elsif nums[mid] == 1
      mid += 1
    else # nums[mid] == 2
      nums[mid], nums[high] = nums[high], nums[mid]
      high -= 1
    end
  end
  nums
end

#
# Problem 3: Meeting Rooms II
# Difficulty: Medium
# Companies: Procore, Amazon, Bloomberg
#
# Problem Statement:
#           Given an array of meeting time intervals intervals where intervals[i] = [start_i, end_i], return the minimum number of conference rooms required to hold all the meetings.
#
#   Example 1:
#
#   Plaintext
# Input: intervals = [[0,30],[5,10],[15,20]]
# Output: 2
#
# Explanation:
#   Room 1: [0, 30]
# Room 2: [5, 10], [15, 20]
# Example 2:
#
#   Plaintext
# Input: intervals = [[7,10],[2,4]]
# Output: 1
#
# Explanation:
#   The meetings do not overlap, so only one room is needed.
#     Constraints:
#
#     1 <= intervals.length <= 10^4
#
#   0 <= start_i < end_i <= 10^6


def min_meeting_rooms(intervals)
  return 0 if intervals.empty?
  starts = intervals.map { |i| i[0] }.sort
  ends = intervals.map { |i| i[1] }.sort
  rooms = 0
  end_ptr = 0
  starts.each do |start_time|
    if start_time >= ends[end_ptr]
      end_ptr += 1
    else
      rooms += 1
    end
  end
  rooms
end


  # Problem 4: LRU Cache
  # Difficulty: Medium
  # Companies: Procore, Microsoft, Apple
  #
  #   Problem Statement:
  #             Design a data structure that follows the constraints of a Least Recently Used (LRU) cache.
  #
  #   Implement the LRUCache class:
  #
  #                            LRUCache(int capacity) Initialize the LRU cache with positive size capacity.
  #
  #   int get(int key) Return the value of the key if the key exists, otherwise return -1.
  #
  #   void put(int key, int value) Update the value of the key if the key exists. Otherwise, add the key-value pair to the cache. If the number of keys exceeds the capacity from this operation, evict the least recently used key.
  #
  #   The functions get and put must each run in O(1) average time complexity.
  #
  #   Example 1:
  #
  #   Plaintext
  # Input
  # ["LRUCache", "put", "put", "get", "put", "get", "put", "get", "get", "get"]
  # [[2], [1, 1], [2, 2], [1], [3, 3], [2], [4, 4], [1], [3], [4]]
  #
  # Output
  # [null, null, null, 1, null, -1, null, -1, 3, 4]
  #
  # Explanation
  # LRUCache lRUCache = new LRUCache(2);
  # lRUCache.put(1, 1); // cache is {1=1}
  # lRUCache.put(2, 2); // cache is {1=1, 2=2}
  # lRUCache.get(1);    // return 1
  # lRUCache.put(3, 3); // LRU key was 2, evicts key 2, cache is {1=1, 3=3}
  # lRUCache.get(2);    // returns -1 (not found)
  # lRUCache.put(4, 4); // LRU key was 1, evicts key 1, cache is {4=4, 3=3}
  # lRUCache.get(1);    // return -1 (not found)
  # lRUCache.get(3);    // return 3
  # lRUCache.get(4);    // return 4
  # Constraints:
  #
  #   1 <= capacity <= 3000
  #
  # 0 <= key <= 10^4
  #
  # 0 <= value <= 10^5
  #
  # At most 2 * 10^5 calls will be made to get and put.
class LRUCache
  def initialize(capacity)
    @capacity = capacity
    @cache = {} # Keeps track of key-value and insertion order
  end

  def get(key)
    return -1 unless @cache.key?(key)
    val = @cache.delete(key)
    @cache[key] = val
    val
  end

  def put(key, value)
    if @cache.key?(key)
      @cache.delete(key)
    elsif @cache.size >= @capacity
      first_key = @cache.keys.first
      @cache.delete(first_key)
    end

    @cache[key] = value
  end
end
