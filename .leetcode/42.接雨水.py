#
# @lc app=leetcode.cn id=42 lang=python3
#
# [42] 接雨水
#

# @lc code=start


class Solution:
    def trap(self, height: List[int]) -> int:
        if not height or len(height) < 3:
            return 0
        res = 0
        l, r = 0, len(height) - 1
        lmax, rmax = height[l], height[r]
        while l < r:
            lmax, rmax = max(height[l], lmax), max(height[r], rmax)
            if lmax <= rmax:
                res += lmax - height[l]
                l += 1
            else:
                res += rmax - height[r]
                r -= 1
        return res

# @lc code=end
