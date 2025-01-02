module BinarySearchTree
  MAX = (2 ** (0.size * 8 - 2) - 1)
  MIN = - (2 ** (0.size * 8 - 2))

  def min_binary_search_tree
    return '-1' if @root.nil?
    current = @root
    last = current
    until current.nil?
      last = current
      current = current.left
    end
    last.val
  end

  def is_binary_search_tree?
    is_binary_search_tree_rec(@root, MIN, MAX)
  end

  private

  def is_binary_search_tree_rec(root, min, max)
    return true if root.nil?
    return false if root.val < min || root.val > max
    is_binary_search_tree_rec(root.left, min, root.val - 1) && is_binary_search_tree_rec(root.right, root.val + 1, max)
  end
end
