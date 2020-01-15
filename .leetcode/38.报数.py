#
# @lc app=leetcode.cn id=38 lang=python3
#
# [38] 报数
#


class Solution:
    def countAndSay(self, n: int) -> str:
        res = '1'
        for i in range(n - 1):
            res = ''.join([str(len(list(group))) + digit for digit,
                           group in itertools.groupby(res)])
        return res
