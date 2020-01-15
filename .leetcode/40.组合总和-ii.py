#
# @lc app=leetcode.cn id=40 lang=python3
#
# [40] 组合总和 II
#

# @lc code=start


class Solution:
    def combinationSum2(self, candidates: List[int], target: int) -> List[List[int]]:
        res = []
        candidates.sort()
        length = len(candidates)

        def dfs(remain, combo, index):
            if remain == 0 and combo not in res:
                res.append(combo)
                return
            for i in range(index, length):
                if candidates[i] > remain:
                    break
                dfs(remain - candidates[i], combo + [candidates[i]], i + 1)
        dfs(target, [], 0)
        return res
# @lc code=end
