#
# @lc app=leetcode.cn id=67 lang=python3
#
# [67] 二进制求和
#


class Solution:
    def addBinary(self, a: str, b: str) -> str:
        s = str(bin(int(a, 2) + int(b, 2)))
        return s[2:]
