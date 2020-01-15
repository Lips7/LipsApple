#
# @lc app=leetcode.cn id=70 lang=python3
#
# [70] 爬楼梯
#


class Solution:
    def climbStairs(self, n: int) -> int:
        from math import sqrt
        fibn = (pow((1 + sqrt(5)) / 2, n + 1) -
                pow((1 - sqrt(5)) / 2, n + 1)) / sqrt(5)
        return int(fibn)
