#
# @lc app=leetcode.cn id=63 lang=python3
#
# [63] 不同路径 II
#

# @lc code=start


class Solution:
    def uniquePathsWithObstacles(self, obstacleGrid: List[List[int]]) -> int:
        m, n = len(obstacleGrid), len(obstacleGrid[0])
        if obstacleGrid[0][0] == 1:
            return 0
        # initialize
        obstacleGrid[0][0] = 1
        for i in range(1, m):
            obstacleGrid[i][0] = obstacleGrid[i-1][0]*(1-obstacleGrid[i][0])
        for j in range(1, n):
            obstacleGrid[0][j] = obstacleGrid[0][j-1]*(1-obstacleGrid[0][j])
        for i in range(1, m):
            for j in range(1, n):
                obstacleGrid[i][j] = (
                    obstacleGrid[i-1][j]+obstacleGrid[i][j-1])*(1-obstacleGrid[i][j])
        return obstacleGrid[-1][-1]
# @lc code=end
