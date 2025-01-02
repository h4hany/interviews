# https://leetcode.com/problems/path-sum/
#!/user/bin/ruby
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
# @param {Integer} target_sum
# @return {Boolean}
def has_path_sum(root, target_sum)
  return false if root.nil?
  return root.val == target_sum if root.left.nil? and root.right.nil?
  values = []
  if root.left
    values << has_path_sum(root.left, target_sum - root.val)
  end
  if root.right
    values << has_path_sum(root.right, target_sum - root.val)
  end
  values.any?
end
root = [5,4,8,11,nil,13,4,7,2,nil,nil,nil,1]

target_sum = 22
has_path_sum(root, target_sum)
