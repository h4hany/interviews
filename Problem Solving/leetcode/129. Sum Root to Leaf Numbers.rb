#!/user/bin/ruby
# https://leetcode.com/problems/sum-root-to-leaf-numbers/
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
def sum_numbers(root)
  return 0 if root.nil?

  @sum = 0
  build_number("", root)
  @sum
end

def build_number(current, root)
  current_number = "#{current}#{root.val}"

  if root.left.nil? && root.right.nil?
    @sum += current_number.to_i
    return
  end

  build_number(current_number, root.left) if root.left
  build_number(current_number, root.right) if root.right
end
