#
# @lc app=leetcode.cn id=9 lang=python3
#
# [9] 回文数
#


class Solution:
    def isPalindrome(self, x: int) -> bool:
        if x < 0:
            return False
        elif x != int(str(x)[::-1]):
            return False
        else:
            return True
