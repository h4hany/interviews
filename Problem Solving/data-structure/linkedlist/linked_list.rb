#!/user/bin/ruby

require_relative 'linked_list_node'

class LinkedList
  # include LinkedListNode
  attr_accessor :first, :last

  # @param {Integer} val
  def add_last(val)
    node = LinkedListNode.new(val)
    if @first.nil?
      @first = @last = node
    else
      @last.next = node
      @last = node
    end
  end

  # @param {Integer} val
  def add_first(val)
    node = LinkedListNode.new(val)
    if @first.nil?
      @first = @last = node
    else
      node.next = @first
      @first = node
    end
  end

  # @param {Integer} val
  # @return {Integer} index
  def index_of(val)
    return -1 if @first.nil?
    current = @first
    index = 0
    until current.nil?
      return index if current.val == val
      current = current.next
      index += 1
    end
    -1
  end

  # @param {Integer} val
  # @return {Boolean} res
  def contain(val)
    index_of(val) == -1 ? false : true
  end

  def remove_first
    if @first.nil?
      return
    end
    if @first == @last
      @first = @last = nil
      return
    end
    # @first = @first.next
    second = @first.next
    @first.next = nil
    @first = second
  end

  def remove_last
    if @last.nil?
      return
    end
    if @first == @last
      @first = @last = nil
      return
    end
    current = @first
    until current.nil?
      if current.next == @last
        @last = current
        @last.next = nil
        break
      end
      current = current.next
    end
  end

  # @return {Integer} size
  def size
    if @last.nil?
      return
    end
    if @first == @last
      @first = @last = nil
      return
    end

    current = @first
    index = 0
    until current.nil?
      index += 1
      current = current.next
    end
    index
  end

  def reverse
    if @first.nil?
      return
    end
    prev = @first
    current = @first.next
    until current.nil?
      next_var = current.next
      current.next = prev
      prev = current
      current = next_var
    end
    @last = @first
    @last.next = nil
    @first = prev
  end

  def delete_from_last(kth)
    first = @first
    second = @first
    index = 0
    while index < kth
      if second.next == nil
        @first = @first.next  if index == kth - 1
        break
      end
      second = second&.next
    end

    until second.nil?
      first = first.next
      second = second.next
    end
    first.next = first&.next&.next
  end

  def print
    temp = @first
    result = []
    until temp.nil?
      result.push(temp.val)
      temp = temp.next
    end
    result.to_s
  end

end

list = LinkedList.new
list.add_last(10)
list.add_last(20)
list.add_first(5)
list.add_last(30)
list.add_first(-1)
puts list.print

# puts list.index_of(20)
puts list.delete_from_last(3)
puts list.print

# puts list.reverse
# puts list.print
