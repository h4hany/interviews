#!/user/bin/ruby
# https://leetcode.com/problems/minimum-depth-of-binary-tree/
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
# @return {Integer}
def min_depth(root)
  return 0 unless root
  left = min_depth(root.left)
  right = min_depth(root.right)
  if left.zero? || right.zero?
    [left, right].max + 1
  else
    [left, right].min + 1
  end
end

