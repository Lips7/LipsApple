#
# @lc app=leetcode.cn id=7 lang=python3
#
# [7] 整数反转
#


class Solution:
    def reverse(self, x: int) -> int:
        sign = 1 if x >= 0 else - 1
        result = sign * int(str(abs(x))[::-1])
        return result if - 2 ** 31 <= result <= 2 ** 31 - 1 else 0
