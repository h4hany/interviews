# - Breadth First Level Order
# - Depth First
# - Pre-order: root,left,right
# - In-order: left,root,right
# - Post-order: left,right,root
module TraversTree
  attr_accessor :depth_first, :result, :breadth_first

  def level_order
    @breadth_first = []
    height = self.height
    index = 0
    while index <= height
      @breadth_first.concat(get_node_at_level(index))
      index += 1
    end
    @breadth_first.to_s
  end

  # root,left,right
  def pre_order
    @depth_first = []
    pre_order_rec(@root)
    puts @depth_first.to_s
  end

  # left,right,root
  def post_order
    @depth_first = []
    post_order_rec(@root)
    puts @depth_first.to_s
  end

  # left,root,right
  def in_order
    @depth_first = []
    in_order_rec(@root)
    puts @depth_first.to_s
  end

  def get_node_at_level(level)
    @result = []
    get_node_at_level_rec(root, level)
    @result
  end

  private

  def get_node_at_level_rec(root, level)
    if root.nil?
      return
    end

    if level == 0
      @result.push(root.val)
      return
    end

    get_node_at_level_rec(root.left, level - 1)
    get_node_at_level_rec(root.right, level - 1)

  end

  def pre_order_rec(root)
    if root.nil?
      return;
    end
    @depth_first.push(root.val)
    # puts root.val
    pre_order_rec(root.left)
    pre_order_rec(root.right)
  end

  def post_order_rec(root)
    if root.nil?
      return;
    end
    # puts root.val
    pre_order_rec(root.left)
    pre_order_rec(root.right)
    @depth_first.push(root.val)

  end

  def in_order_rec(root)
    if root.nil?
      return;
    end
    # puts root.val
    pre_order_rec(root.left)
    @depth_first.push(root.val)
    pre_order_rec(root.right)
  end

end
