class TrieNode
  attr_accessor :val, :children, :is_end_of_word
  ALPHABET_SIZE = 26
  def initialize(val)
    @val = val
    @children = {}
    @is_end_of_word = false
  end

  def has_child?(ch)
    @children.key? ch
  end

  def has_children?
    !@children.empty?
  end

  def add_child(ch)
    @children[ch] = TrieNode.new(ch)
  end

  def remove_child(ch)
    @children.delete(ch)
  end

  # @param {String} ch
  # @return {TrieNode}
  def get_child(ch)
    @children[ch]
  end

  # @return {TrieNode[]}
  def get_children
    @children.values
  end

end
