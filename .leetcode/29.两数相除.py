#
# @lc app=leetcode.cn id=29 lang=python3
#
# [29] 两数相除
#

# @lc code=start


class Solution:
    def divide(self, dividend: int, divisor: int) -> int:
        count = 0
        positve = (dividend < 0) is (divisor < 0)
        dividend, divisor = abs(dividend), abs(divisor)
        while dividend >= divisor:
            temp, i = divisor, 1
            while dividend >= temp:
                dividend -= temp
                count += i
                i *= 2
                temp *= 2
        if not positve:
            count = -count
        return count if -2**31 <= count <= 2**31-1 else 2**31-1

# @lc code=end
