def valid_tree(n, edges)
  return false if edges.length != n - 1

  graph = Hash.new { |h, k| h[k] = [] }
  puts graph
  edges.each do |u, v|

    graph[u] << v
    graph[v] << u
  end
  puts graph

  visited = Set.new

  dfs = lambda do |node, parent|
    return false if visited.include?(node)

    visited.add(node)

    graph[node].each do |neighbor|
      next if neighbor == parent

      return false unless dfs.call(neighbor, node)
    end

    true
  end

  return false unless dfs.call(0, -1)

  visited.size == n
end

require 'set'

# puts valid_tree(5, [[0,1],[0,2],[0,3],[1,4]])
class ListNode
  attr_accessor :val, :next

  def initialize(val = 0, nxt = nil)
    @val = val
    @next = nxt
  end
end
# Input: 1 -> 2 -> 3 -> 4
# Output: 2 -> 1 -> 4 -> 3

def swap_pairs(head)
  # Input: 1 -> 2 -> 3 -> 4

  dummy = ListNode.new(0)
  # 0 -> 1
  dummy.next = head
  prev = dummy

  while prev.next && prev.next.next
    first = prev.next # 1
    second = first.next # 2
    first.next  = second.next
    second.next = first
    prev =
  end
end
