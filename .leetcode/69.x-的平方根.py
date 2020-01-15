#
# @lc app=leetcode.cn id=69 lang=python3
#
# [69] x 的平方根
#


class Solution:
    def mySqrt(self, x: int) -> int:
        res = 1.0
        while abs(res * res - x) > 0.1:
            res = (res + x / res) / 2
        return int(res)
