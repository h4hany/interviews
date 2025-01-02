module TrieTraverse
  attr_accessor :result
  def pre_order
    @result = []
    pre_order_rec(@root)
    @result.to_s
  end

  def post_order
    @result = []
    post_order_rec(@root)
    @result.to_s
  end

  private

  def pre_order_rec(root)
    @result.push(root.val)
    root.get_children.each do |child|
      pre_order_rec(child)
    end
  end

  def post_order_rec(root)
    root.get_children.each do |child|
      post_order_rec(child)
    end
    @result.push(root.val)
  end
end
