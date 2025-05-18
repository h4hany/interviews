class TreeNode
  attr_accessor :value, :left, :right

  def initialize(value)
    @value = value
    @left = nil
    @right = nil
  end
end

class BinarySearchTree
  attr_accessor :root

  def initialize
    @root = nil
  end

  def insert(value)
    @root = insert_recursive(@root, value)
  end

  def search(value)
    search_recursive(@root, value)
  end

  def height
    height_recursive(@root)
  end

  def is_leaf?(root)
    root.left.nil? && root.right.nil?
  end

  private

  def insert_recursive(node, value)
    return TreeNode.new(value) if node.nil?

    if value < node.value
      node.left = insert_recursive(node.left, value)
    elsif value > node.value
      node.right = insert_recursive(node.right, value)
    else
      # Value already exists; do nothing or handle duplicates as needed
    end
    node
  end

  def search_recursive(node, value)
    return false if node.nil?

    if value == node.value
      true
    elsif value < node.value
      search_recursive(node.left, value)
    else
      search_recursive(node.right, value)
    end
  end

  def height_recursive(node)
    return -1 if node.nil?

    left_height = height_recursive(node.left)
    right_height = height_recursive(node.right)
    [left_height, right_height].max + 1
  end
end
