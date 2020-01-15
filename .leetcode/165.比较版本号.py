#
# @lc app=leetcode.cn id=165 lang=python3
#
# [165] 比较版本号
#

# @lc code=start


class Solution:
    def compareVersion(self, version1: str, version2: str) -> int:
        v1, v2 = ([*map(int, v.split('.'))] for v in (version1, version2))
        d = len(v2) - len(v1)
        v11, v22 = v1 + [0] * d, v2 + [0] * -d
        if v11 > v22:
            return 1
        elif v11 < v22:
            return -1
        return 0

# @lc code=end
