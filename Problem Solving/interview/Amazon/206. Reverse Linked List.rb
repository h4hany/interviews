# https://leetcode.com/problems/reverse-linked-list/
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
def reverse_list(head)
  current = head
  prev_node = nil
  next_node = nil
  until current.nil?
    next_node = current.next
    current.next = prev_node
    prev_node = current
    current = next_node
  end
  head = prev_node
end
