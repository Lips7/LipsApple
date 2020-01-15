#
# @lc app=leetcode.cn id=20 lang=python3
#
# [20] 有效的括号
#


class Solution:
    def isValid(self, s: str) -> bool:
        stack = []
        match = {')': '(', ']': '[', '}': '{'}
        for ch in s:
            if ch in match:
                top = stack.pop() if stack else '#'
                if match[ch] != top:
                    return False
            else:
                stack.append(ch)
        return not stack
