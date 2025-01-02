# https://leetcode.com/problems/binary-tree-maximum-path-sum/
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
def max_path_sum(root)
  @max_sum = -Float::INFINITY
  helper(root)
  @max_sum
end

def helper(node)
  return 0 if node.nil?
  left_sum = helper(node.left)
  right_sum = helper(node.right)
  left_sum = [left_sum,0].max
  right_sum = [right_sum, 0].max
  total = left_sum + right_sum + node.val
  @max_sum = [@max_sum, total].max
  node.val + [left_sum, right_sum].max
end
