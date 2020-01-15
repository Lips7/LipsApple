#
# @lc app=leetcode.cn id=13 lang=python3
#
# [13] 罗马数字转整数
#


class Solution:
    def romanToInt(self, s: str) -> int:
        lookup = {
            'M': 1000,
            'D': 500,
            'C': 100,
            'L': 50,
            'X': 10,
            'V': 5,
            'I': 1
        }
        res = 0
        for i in range(len(s)):
            if i > 0 and lookup[s[i]] > lookup[s[i - 1]]:
                res += lookup[s[i]] - 2 * lookup[s[i - 1]]
            else:
                res += lookup[s[i]]
        return res
