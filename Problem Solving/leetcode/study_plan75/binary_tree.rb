# Count Good Nodes in Binary Tree
def good_nodes(root)
  good_nodes_rec(root, root.val)
end

def good_nodes_rec(node, max_val)
  return 0 if node.nil?

  count = node.val >= max_val ? 1 : 0
  new_max = [max_val, node.val].max
  count += good_nodes_rec(node.left, new_max)
  count += good_nodes_rec(node.right, new_max)
  count

end
