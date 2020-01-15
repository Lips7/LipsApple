#
# @lc app=leetcode.cn id=102 lang=python3
#
# [102] 二叉树的层次遍历
#

# @lc code=start
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, x):
#         self.val = x
#         self.left = None
#         self.right = None

class Solution:
    def levelOrder(self, root: TreeNode) -> List[List[int]]:
        res, level = [], [root]
        while root and level:
            res.append([node.val for node in level])
            LR = [(node.left, node.right) for node in level]
            level = [leaf for lr in LR for leaf in lr if leaf]
        return res
# @lc code=end

