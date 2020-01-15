#
# @lc app=leetcode.cn id=27 lang=python3
#
# [27] 移除元素
#


class Solution:
    def removeElement(self, nums: List[int], val: int) -> int:
        while val in nums:
            nums.remove(val)
        return len(nums)
