#!/user/bin/ruby
# https://leetcode.com/problems/recover-binary-search-tree/
# Definition for a binary tree node.
class TreeNode
  attr_accessor :val, :left, :right

  def initialize(val = 0, left = nil, right = nil)
    @val = val
    @left = left
    @right = right
  end
end

# @param {TreeNode} root
# @return {Void} Do not return anything, modify root in-place instead.
def recover_tree(root)
  as_is = build_tree(root)
  should_be = as_is.sort
  target_nodes = []
  (0...as_is.length).each { |i|
    target_nodes << as_is[i] if as_is[i] != should_be[i]
  }

  swap_1 = find_node(root, target_nodes[0])
  swap_2 = find_node(root, target_nodes[1])
  swap = swap_1.val
  swap_1.val = swap_2.val
  swap_2.val = swap
  root
end

def build_tree(root)
  return [] if root == nil
  build_tree(root.left) + [root.val] + build_tree(root.right)
end

def find_node(root, val)
  return nil if root == nil
  return root if root.val == val
  left = find_node(root.left, val)
  return left if left != nil
  find_node(root.right, val)
end
