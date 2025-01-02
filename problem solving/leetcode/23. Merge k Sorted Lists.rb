# Definition for singly-linked list.
# class ListNode
#     attr_accessor :val, :next
#     def initialize(val = 0, _next = nil)
#         @val = val
#         @next = _next
#     end
# end
# @param {ListNode[]} lists
# @return {ListNode}
def merge_k_lists(lists)
  return nil if lists.length == 0
  merge_lists(lists, 0, lists.length - 1)
end
def merge_lists(lists, i, j)
  return lists[i]  if i == j

  mid = (i + j)/2
  left_list = merge_lists(lists, i, mid)
  right_list = merge_lists(lists, mid + 1, j)
  merge_two_lists(left_list, right_list)
end

def merge_two_lists(list1, list2)
  return list1 if list1.nil? && list2.nil?
  return list2 if list1.nil?
  return list1 if list2.nil?
  result = ListNode.new

  if list1.val > list2.val
    result = list2
    list2 = list2.next
  else
    result = list1
    list1 = list1.next
  end
  result.next = merge_two_lists(list1, list2)
  result

end
