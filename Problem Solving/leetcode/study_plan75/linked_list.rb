#/bin/ruby

# Definition for singly-linked list.
# class ListNode
#     attr_accessor :val, :next
#     def initialize(val = 0, _next = nil)
#         @val = val
#         @next = _next
#     end
# end
# @param {ListNode} head
# @return {ListNode}
def delete_middle(head)
  size = list_size(head)
  if size == 1
    head = nil
    return head
  end
  selected_index = size / 2
  current = head
  index = 0
  until current.nil?
    if index == selected_index - 1
      temp = current.next.next
      current.next = temp
      break
    end
    index += 1
    current = current.next
  end
  head
end

def list_size(head)
  current = head
  size = 0
  until current.nil?
    size += 1
    current = current.next
  end
  size
end

def odd_even_list(head)
  return head if head.nil? || head.next.nil?

  odd = head
  even = head.next
  even_head = even

  while even&.next
    odd.next = even.next
    odd = odd.next
    even.next = odd.next
    even = even.next
  end

  odd.next = even_head
  head

end

def reverse_list(head)
  prev = nil
  current = head
  while current != nil
    temp = current.next
    current.next = prev
    prev = current
    current = temp
  end
  prev
end
