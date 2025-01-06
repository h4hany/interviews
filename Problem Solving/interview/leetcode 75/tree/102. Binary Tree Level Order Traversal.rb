# https://leetcode.com/problems/binary-tree-level-order-traversal/
def level_order(root)
  return [] if root.nil?
  result = []
  q = [root]
  until q.empty?
    level = []
    (0..q.size - 1).each { |i|
      node = q.shift
      level << node.val
      q << node.left unless node.left.nil?
      q << node.right unless node.right.nil?
    }
    result << level
  end
  result
end
