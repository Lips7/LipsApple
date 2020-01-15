#
# @lc app=leetcode.cn id=53 lang=python3
#
# [53] 最大子序和
#


class Solution:
    def maxSubArray(self, nums: List[int]) -> int:
        if not nums:
            return 0
        maxSum = maxEnd = nums[0]
        for num in nums[1:]:
            maxEnd = max(num, maxEnd + num)
            maxSum = max(maxEnd, maxSum)
        return maxSum
