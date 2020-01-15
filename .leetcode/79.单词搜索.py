#
# @lc app=leetcode.cn id=79 lang=python3
#
# [79] 单词搜索
#

# @lc code=start


class Solution:
    def exist(self, board: List[List[str]], word: str) -> bool:
        if not board:
            return False
        m, n = len(board), len(board[0])

        def dfs(i, j, w):
            if len(w) == 0:
                return True
            if i < 0 or i >= m or j < 0 or j >= n or w[0] != board[i][j]:
                return False
            temp = board[i][j]
            board[i][j] = '#'
            newword = w[1:]
            res = dfs(i + 1, j, newword) or dfs(i - 1, j,
                                                newword) or dfs(i, j + 1, newword) or dfs(i, j - 1, newword)
            board[i][j] = temp
            return res
        for i in range(m):
            for j in range(n):
                if dfs(i, j, word):
                    return True
        return False


# @lc code=end
