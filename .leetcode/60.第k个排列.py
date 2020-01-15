#
# @lc app=leetcode.cn id=60 lang=python3
#
# [60] 第k个排列
#

# @lc code=start
class Solution:
    def getPermutation(self, n: int, k: int) -> str:
        import math
        nums = list(range(1, n + 1))
        perm = ''
        k -= 1
        while n > 0:
            n -= 1
            index, k = divmod(k, math.factorial(n))
            perm += str(nums[index])
            nums.remove(nums[index])
        return perm
# @lc code=end

