# Definition for Node.
class Node
    attr_accessor :val, :left, :right, :next
    def initialize(val)
        @val = val
        @left, @right, @next = nil, nil, nil
    end
end

# @param {Node} root
# @return {Node}
def connect(root)
  return root if root == nil
  left_node = root.left
  right_node = root.right
  while left_node != nil
    left_node.next = right_node
    left_node = left_node.right
    right_node = right_node.left
  end
  connect(root.left)
  connect(root.right)
  root
end
