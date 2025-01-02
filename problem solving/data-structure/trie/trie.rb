#!/user/bin/ruby
require_relative 'trie_node'
require_relative 'trie_traverse'

class Trie
  include TrieTraverse
  attr_accessor :root

  def initialize
    @root = TrieNode.new(' ')
  end

  def insert(word)
    current = @root
    word.chars.each do |ch|
      current.add_child(ch) unless current.has_child?(ch)
      current = current.get_child(ch)
    end
    current.is_end_of_word = true
  end

  # @param {String} word
  # @return {Boolean}
  def has?(word)
    return false if word.nil?
    current = @root
    word.chars.each do |ch|
      return false unless current.has_child?(ch)
      current = current.get_child(ch)
    end
    current.is_end_of_word
  end

  def remove(word)
    remove_rec(@root, word, 0)

  end

  def find_words(prefix)
    res = []
    last_node = find_last_node_of(prefix)
    find_words_rec(last_node, prefix, res)
    res.to_s
  end

  private

  def remove_rec(root, word, index)
    if index == word.length
      root.is_end_of_word = false
      return
    end
    ch = word[index]
    child = root.get_child(ch)
    if child.nil?
      return
    end
    remove_rec(child, word, index + 1)
    root.remove_child(ch) unless child.has_children? && child.is_end_of_word
  end

  def find_last_node_of(prefix)
    current = @root
    prefix.chars.each do |ch|
      child = current.get_child(ch)
      if child.nil?
        return nil
      end
      current = child
    end
    current
  end

  def find_words_rec(root, prefix, res)
    if root.nil?
      return
    end
    res.push(prefix) if root.is_end_of_word
    root.get_children.each do |child|
      find_words_rec(child, prefix + child.val, res)
    end
  end
end

trie = Trie.new
trie.insert('car')
trie.insert('card')
trie.insert('care')
trie.insert('careful')
trie.insert('egg')

# puts trie.has?(nil)
# puts trie.pre_order
# trie.remove('cat')
# puts trie.pre_order
puts trie.find_words('car')

# puts trie.post_order
