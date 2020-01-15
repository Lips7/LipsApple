#
# @lc app=leetcode.cn id=207 lang=python3
#
# [207] 课程表
#

# @lc code=start


class Solution:
    def canFinish(self, numCourses: int, prerequisites: List[List[int]]) -> bool:
        graph = [set() for _ in range(numCourses)]
        visit = [0 for _ in range(numCourses)]
        for x, y in prerequisites:
            graph[x].add(y)

        def dfs(i):
            if visit[i] == 2:
                return True
            if visit[i] == 1:
                return False
            visit[i] = 2
            for j in graph[i]:
                if dfs(j):
                    return True
            visit[i] = 1
            return False
        for i in range(numCourses):
            if dfs(i):
                return False
        return True
# @lc code=end
