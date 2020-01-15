#
# @lc app=leetcode.cn id=61 lang=python3
#
# [61] 旋转链表
#

# @lc code=start
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, x):
#         self.val = x
#         self.next = None

class Solution:
    def rotateRight(self, head: ListNode, k: int) -> ListNode:
        if not head:
            return None
        if not head.next:
            return head
        p, length = head, 1
        while p.next:
            p = p.next
            length += 1
        t = k % length
        if k == 0 or t == 0:
            return head
        fast, slow = head, head
        for a in range(t):
            fast = fast.next
        while fast.next:
            slow = slow.next
            fast = fast.next
        temp = slow.next
        slow.next, fast.next = None, head
        return temp
# @lc code=end

