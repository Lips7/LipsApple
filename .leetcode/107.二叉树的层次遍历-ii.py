#
# @lc app=leetcode.cn id=107 lang=python3
#
# [107] 二叉树的层次遍历 II
#
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, x):
#         self.val = x
#         self.left = None
#         self.right = None


class Solution:
    def levelOrderBottom(self, root: TreeNode) -> List[List[int]]:
        def dfs(root, level, res):
            if root:
                if len(res) < level + 1:
                    res.insert(0, [])
                res[-(level + 1)].append(root.val)
                dfs(root.left, level + 1, res)
                dfs(root.right, level + 1, res)

        res = []
        dfs(root, 0, res)
        return res
