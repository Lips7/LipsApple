#
# @lc app=leetcode.cn id=4 lang=python3
#
# [4] 寻找两个有序数组的中位数
#


class Solution:
    def findMedianSortedArrays(self, nums1, nums2):
        n = len(nums1) + len(nums2)
        if n % 2 == 1:
            return self.findKth(nums1, nums2, n // 2 + 1)
        else:
            return (self.findKth(nums1, nums2, n // 2) + self.findKth(nums1, nums2, n // 2 + 1)) / 2.0

    def findKth(self, a, b, k):
        if len(a) == 0:
            return b[k - 1]
        if len(b) == 0:
            return a[k - 1]
        if k == 1:
            return min(a[0], b[0])

        ia = a[k // 2 - 1] if len(a) >= k / 2 else None
        ib = b[k // 2 - 1] if len(b) >= k / 2 else None

        if ib is None or (ia is not None and ia < ib):
            return self.findKth(a[k // 2:], b, k - k // 2)
        return self.findKth(a, b[k // 2:], k - k // 2)
