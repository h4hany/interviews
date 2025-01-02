# https://leetcode.com/problems/symmetric-tree/
#!/user/bin/ruby
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
def is_symmetric(root)
  is_symmetric_rec(root, root)
end

def is_symmetric_rec(r1, r2)
  return true if r1.nil? && r2.nil?
  return false if r1.nil? || r2.nil?
  (r1.val == r2.val) && (is_symmetric_rec(r1.right, r2.left)) && (is_symmetric_rec(r1.left, r2.right))

end
