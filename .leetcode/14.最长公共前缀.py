#
# @lc app=leetcode.cn id=14 lang=python3
#
# [14] 最长公共前缀
#
import os


class Solution:
    def longestCommonPrefix(self, strs: List[str]) -> str:
        return os.path.commonprefix(strs)
