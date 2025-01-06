# https://leetcode.com/problems/construct-binary-tree-from-preorder-and-inorder-traversal/
# Definition for a binary tree node.
# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val = 0, left = nil, right = nil)
#         @val = val
#         @left = left
#         @right = right
#     end
# end
# @param {Integer[]} preorder
# @param {Integer[]} inorder
# @return {TreeNode}
def build_tree(preorder, inorder)
  return if inorder.empty? || preorder.empty?

  root = TreeNode.new(preorder.first)
  split_idx = inorder.index(preorder.first)
  root.left = build_tree(preorder[1 .. split_idx], inorder[0 ... split_idx])
  root.right = build_tree(preorder[split_idx + 1.. -1], inorder[split_idx + 1.. -1])

  root
end
