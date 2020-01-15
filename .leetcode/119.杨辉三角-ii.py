#
# @lc app=leetcode.cn id=119 lang=python3
#
# [119] 杨辉三角 II
#
# https://leetcode-cn.com/problems/pascals-triangle-ii/description/
#
# algorithms
# Easy (57.42%)
# Likes:    86
# Dislikes: 0
# Total Accepted:    24.2K
# Total Submissions: 41.8K
# Testcase Example:  '3'
#
# 给定一个非负索引 k，其中 k ≤ 33，返回杨辉三角的第 k 行。
# 
# 
# 
# 在杨辉三角中，每个数是它左上方和右上方的数的和。
# 
# 示例:
# 
# 输入: 3
# 输出: [1,3,3,1]
# 
# 
# 进阶：
# 
# 你可以优化你的算法到 O(k) 空间复杂度吗？
# 
#
class Solution:
    def getRow(self, rowIndex: int) -> List[int]:
        pascal = [1]
        for i in range(1, rowIndex + 1):
            pascal.insert(0, 0)
            for j in range(i):
                pascal[j] += pascal[j + 1]
        return pascal

