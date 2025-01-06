# https://leetcode.com/problems/subtree-of-another-tree/
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
# @param {TreeNode} sub_root
# @return {Boolean}
def is_subtree(root, sub_root)
  return false if root.nil?
  return true if root.val == sub_root.val && subtree_matched?(root, sub_root)
  is_subtree(root.left, sub_root) || is_subtree(root.right, sub_root)
end

def subtree_matched?(root, sub_root)
  return true if root.nil? && sub_root.nil?
  return false if root.nil? || sub_root.nil?
  root.val == sub_root.val &&
    subtree_matched?(root.right, sub_root.right) &&
    subtree_matched?(root.left, sub_root.left)
end
