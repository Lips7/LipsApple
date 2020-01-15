#
# @lc app=leetcode.cn id=59 lang=python3
#
# [59] 螺旋矩阵 II
#

# @lc code=start
class Solution:
    def generateMatrix(self, n: int) -> List[List[int]]:
        matrix = []
        l = n ** 2 + 1
        while l > 1:
            l, r = l - len(matrix), l
            matrix = [range(l, r)] + [*zip(*matrix[::-1])]
        return matrix
# @lc code=end

