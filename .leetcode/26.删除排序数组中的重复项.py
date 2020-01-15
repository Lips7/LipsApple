#
# @lc app=leetcode.cn id=26 lang=python3
#
# [26] 删除排序数组中的重复项
#


class Solution:
    def removeDuplicates(self, nums: List[int]) -> int:
        i = 0
        while i < (len(nums) - 1):
            if nums[i] == nums[i + 1]:
                nums.remove(nums[i])
            else:
                i += 1
        return len(nums)
