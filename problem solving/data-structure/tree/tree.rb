#!/user/bin/ruby
# implementing tree using ruby
require_relative 'travers_tree'
require_relative 'binary_search_tree'

class Tree
  include TraversTree
  include BinarySearchTree

  attr_accessor :root
  # @return {Node}
  def initialize
    @root = nil
  end

  # @param {Integer} value
  def insert(value)
    node = Node.new(value)
    if @root.nil?
      @root = node
      return
    end
    # puts value
    # @root = node && return if @root.nil?
    current = @root
    while true
      if value < current.val
        if current.left.nil?
          current.left = node
          break
        end
        current = current.left
      else
        if current.right.nil?
          current.right = node
          break
        end
        current = current.right
      end
    end
  end

  # @param {Integer} value
  # @return {Node}
  def find(value)
    current = @root
    until current.nil?
      if value < current.val
        current = current.left
      elsif value > current.val
        current = current.right
      else
        return current
      end
    end
    nil
  end

  # @param {Integer} value
  # @return {Boolean}
  def exist?(value)
    return true if find(value)
    false
  end

  # @return {Integer}
  def height
    height_rec(@root)
  end

  # @return {Integer}
  def min
    return min_binary_search_tree if is_binary_search_tree?
    min_rec(@root)
  end

  # @param {Tree} other

  def equal(other)
    return false if other.nil?
    equals_rec(@root, other.root)
  end

  def swap_root
    if @root.nil? || @root.left.nil? || @root.right.nil?
      return;
    end
    temp = @root.left
    @root.left = @root.right
    @root.right = temp
  end

  def invert
    @root = invert_rec(right)
  end

  def lowest_common_ancestor(root, p, q)
    return root if root==p or root==q or (root.val > p.val and root.val < q.val) or (root.val < p.val and root.val > q.val)
    if root.val > p.val
       lowest_common_ancestor(root.left,p,q)
    else
       lowest_common_ancestor(root.right,p,q)
    end
  end
  private

  class Node
    attr_accessor :val, :left, :right
    # @param {Node} root
    # @return {Node}
    def initialize(val)
      @val = val
      @left, @right = nil, nil
    end
  end

  def invert_rec(root)
    return root if root.nil?
    left = invert_rec(root.left)
    right = invert_rec(root.right)
    root.left = right
    root.right = left
    root
  end

  # @param {Node} root
  # @return {Integer}
  def height_rec(root)
    return -1 if root.nil?
    return 0 if is_leaf?(root)
    1 + [height_rec(root.left), height_rec(root.right)].max
  end

  def is_leaf?(root)
    root.left.nil? && root.right.nil?
  end

  # @param {Node} root
  # @return {Integer}
  def min_rec(root)
    return root.val if is_leaf?(root)
    left = min_rec(root.left)
    right = min_rec(root.right)
    [[left, right].min, root.val].min
  end

  # @param {Node} first
  # @param {Node} second
  def equals_rec(first, second)
    return true if first.nil? && second.nil?
    unless first.nil? && second.nil?
      return first.val == second.val &&
        equals_rec(first.left, second.left) &&
        equals_rec(first.right, second.right)
    end
    false
  end
end
def tree_creator(nodes_val)
  tree = Tree.new
  nodes_val.each { |n| tree.insert(n) }
  tree
end

nodes_val = [7, 4, 9, 1, 6, 8, 10]
tree = tree_creator(nodes_val)
nodes_val = [7, 4, 9, 1, 6, 8, 10]

tree2 = tree_creator(nodes_val)

# tree.pre_order
# tree.post_order
# tree.in_order
# puts tree.equal(tree2)
# puts tree.is_binary_search_tree?
puts tree.invert
# n = tree.find(5)
# puts n.left
