#
# @lc app=leetcode.cn id=35 lang=python3
#
# [35] 搜索插入位置
#


class Solution:
    def searchInsert(self, nums: List[int], target: int) -> int:
        i = 0
        while nums[i] < target:
            i += 1
            if i == len(nums):
                return i
        return i
