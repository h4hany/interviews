# https://leetcode.com/problems/binary-tree-zigzag-level-order-traversal/
# Definition for a binary tree node.
# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val)
#         @val = val
#         @left, @right = nil, nil
#     end
# end

# @param {TreeNode} root
# @return {Integer[][]}
def zigzag_level_order(root)
  if root.nil?
    return []
  end
  levels = []
  reverse = false
  queue = [root]
  until queue.empty?
    next_queue = []
    level = []
    queue.each do |node|
      reverse ? level.unshift(node.val) : level.push(node.val)
      next_queue << node.left if node.left
      next_queue << node.right if node.right
    end
    queue = next_queue
    levels << level
    reverse = !reverse
  end

  levels
end

def zigzag_level_order2(root)
  result = []
  return result if root.nil?
  inner_zigzag_level_order(root, 0, result)
  result.each_with_index do |row, index|
    if index % 2 == 1
      result[index] = result[index].reverse
    end
  end
  result
end

def inner_zigzag_level_order(root, level, result)
  result[level] ||= []
  result[level] << root.val
  level += 1
  inner_zigzag_level_order(root.left, level, result) unless root.left.nil?
  inner_zigzag_level_order(root.right, level, result) unless root.right.nil?
end
