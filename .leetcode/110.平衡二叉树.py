#
# @lc app=leetcode.cn id=110 lang=python3
#
# [110] 平衡二叉树
#
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, x):
#         self.val = x
#         self.left = None
#         self.right = None


class Solution:
    def isBalanced(self, root: TreeNode) -> bool:
        def check(root):
            if not root:
                return 0
            return 1 + max(check(root.left), check(root.right))
        if not root:                                                 
            return True
        return abs(check(root.left)-check(root.right)) <= 1 and self.isBalanced(root.left) and self.isBalanced(root.right)
