#
# @lc app=leetcode.cn id=16 lang=python3
#
# [16] 最接近的三数之和
#
# https://leetcode-cn.com/problems/3sum-closest/description/
#
# algorithms
# Medium (41.39%)
# Likes:    272
# Dislikes: 0
# Total Accepted:    47.6K
# Total Submissions: 114.1K
# Testcase Example:  '[-1,2,1,-4]\n1'
#
# 给定一个包括 n 个整数的数组 nums 和 一个目标值 target。找出 nums 中的三个整数，使得它们的和与 target
# 最接近。返回这三个数的和。假定每组输入只存在唯一答案。
#
# 例如，给定数组 nums = [-1，2，1，-4], 和 target = 1.
#
# 与 target 最接近的三个数的和为 2. (-1 + 2 + 1 = 2).
#
#
#

# @lc code=start


class Solution:
    def threeSumClosest(self, nums: List[int], target: int) -> int:
        nums.sort()
        res = nums[0] + nums[1] + nums[2]
        for i in range(len(nums) - 2):
            L, R = i + 1, len(nums) - 1
            while L < R:
                s = nums[i] + nums[R] + nums[L]
                if s == target:
                    return s
                if abs(s - target) < abs(res - target):
                    res = s

                if s < target:
                    L += 1
                else:
                    R -= 1
        return res

# @lc code=end
