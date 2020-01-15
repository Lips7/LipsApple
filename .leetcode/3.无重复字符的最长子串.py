#
# @lc app=leetcode.cn id=3 lang=python3
#
# [3] 无重复字符的最长子串
#


class Solution:
    def lengthOfLongestSubstring(self, s: str) -> int:
        lenth, start = 0, 0
        used = {}
        for i in range(len(s)):
            if s[i] in used and start <= used[s[i]]:
                start = used[s[i]] + 1
            else:
                lenth = max(lenth, i - start + 1)
            used[s[i]] = i
        return lenth
