#
# @lc app=leetcode.cn id=64 lang=python3
#
# [64] 最小路径和
#

# @lc code=start
class Solution:
    def minPathSum(self, grid: List[List[int]]) -> int:
        if not grid:
            return 0
        m, n = len(grid), len(grid[0])
        for i in range(1, m):
            grid[i][0] += grid[i - 1][0]
        for j in range(1, n):
            grid[0][j] += grid[0][j - 1]
        for i in range(1, m):
            for j in range(1, n):
                grid[i][j] += min(grid[i][j - 1], grid[i - 1][j])
        return grid[-1][-1]
# @lc code=end

