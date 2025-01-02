# Definition for a binary tree node.
# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val = 0, left = nil, right = nil)
#         @val = val
#         @left = left
#         @right = right
#     end
# end
# @param {TreeNode} root
# @return {Boolean}
def is_valid_bst(root)
  max = (2 ** (0.size * 8 - 2) - 1)
  min = -(2 ** (0.size * 8 - 2))
  is_binary_search_tree_rec(root, min, max)

end

def is_binary_search_tree_rec(root, min, max)
  return true if root.nil?
  return false if root.val < min || root.val > max
  is_binary_search_tree_rec(root.left, min, root.val - 1) && is_binary_search_tree_rec(root.right, root.val + 1, max)
end
