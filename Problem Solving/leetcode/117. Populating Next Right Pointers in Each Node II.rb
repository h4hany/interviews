# https://leetcode.com/problems/populating-next-right-pointers-in-each-node-ii/
# Definition for a Node.
# class Node
#     attr_accessor :val, :left, :right, :next
#     def initialize(val)
#         @val = val
#         @left, @right, @next = nil, nil, nil
#     end
# end

# @param {Node} root
# @return {Node}
def connect(root)
  queue = [root].compact

  while !queue.empty? do
    children = []
    queue.each_with_index do |node, i|
      node.next = queue[i+1]

      children.push(node.left) if node.left
      children.push(node.right) if node.right
    end
    queue = children
  end

  return root
end
