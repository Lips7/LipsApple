#
# @lc app=leetcode.cn id=57 lang=python3
#
# [57] 插入区间
#

# @lc code=start


class Solution:
    def insert(self, intervals: List[List[int]], newInterval: List[int]) -> List[List[int]]:
        if intervals:
            i = 0
            while i <= len(intervals) - 1 and intervals[i][0] <= newInterval[0]:
                i += 1
            intervals.insert(i, newInterval)
        else:
            return [newInterval]
        res = []
        for interval in intervals:
            if res and interval[0] <= res[-1][1]:
                res[-1][1] = max(res[-1][1], interval[1])
            else:
                res.append(interval)
        return res
# @lc code=end
