#!/user/bin/ruby
# You are given a linked list where the node has two pointers.
# The first is the regular next pointer.
# The second pointer is called arbitrary_pointer and it can point to any node in the linked list.
# Your job is to write code to make a deep copy of the given linked list. Here,
# deep copy means that any operations on the original list should not affect the copied list.
class LinkedListNode
  attr_accessor :data, :next, :arbitrary

  def initialize(val = 0, _next = nil, _arbitrary = nil)
    @data = val
    @next = _next
    @arbitrary = _arbitrary
  end
end

def deep_copy_arbitrary_pointer(head)
    return nil if head.nil?


  current = head
  new_head = nil
  new_prev = nil
  ht = {}

  # create copy of the linked list, recording the corresponding
  # nodes in hashmap without updating arbitrary pointer
    until current.nil?
    new_node = LinkedListNode.new(current.data)

    # copy the old arbitrary pointer in the new node
    new_node.arbitrary = current.arbitrary

    if new_prev
      new_prev.next = new_node
    else
      new_head = new_node
    end

    ht[current] = new_node
    ht[new_node] = current

    new_prev = new_node
    current = current.next
  end

  new_current = new_head
  # updating arbitrary pointer
    until new_current.nil?
    if new_current.arbitrary
      node = ht[new_current.arbitrary]
      new_current.arbitrary = node
    end

    new_current = new_current.next
  end

   new_head
end

def create_linked_list_with_arb_pointers(length)
  head = create_random_linked_list(length)
  v = []
  temp = head
  until temp.nil?
    v.push(temp)
    temp = temp.next
  end

  (0..v.length - 1).each { |i|
    j = (rand * (v.length - 1)).floor
    p = (rand * 100).floor
    if p < 75
      v[i].arbitrary = v[j]
    end
  }
   head
end
