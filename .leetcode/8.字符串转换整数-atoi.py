#
# @lc app=leetcode.cn id=8 lang=python3
#
# [8] 字符串转换整数 (atoi)
#

# @lc code=start


class Solution:
    def myAtoi(self, str: str) -> int:
        str = str.strip()
        length = len(str)
        if length == 0:
            return 0
        if (str[0] in '-+' and length > 1 and '0' <= str[1] <= '9') or '0' <= str[0] <= '9':
            i = 1
            s = str[0]
            while i < length and '0' <= str[i] <= '9':
                s += str[i]
                i += 1
        else:
            return 0
        s = int(s)
        if s < -2 ** 31:
            return - 2 ** 31
        elif s > 2 ** 31 - 1:
            return 2 ** 31 - 1
        else:
            return s
# @lc code=end
