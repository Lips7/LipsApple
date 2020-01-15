#
# @lc app=leetcode.cn id=125 lang=python3
#
# [125] 验证回文串
#
# https://leetcode-cn.com/problems/valid-palindrome/description/
#
# algorithms
# Easy (40.58%)
# Likes:    116
# Dislikes: 0
# Total Accepted:    53.6K
# Total Submissions: 130.7K
# Testcase Example:  '"A man, a plan, a canal: Panama"'
#
# 给定一个字符串，验证它是否是回文串，只考虑字母和数字字符，可以忽略字母的大小写。
# 
# 说明：本题中，我们将空字符串定义为有效的回文串。
# 
# 示例 1:
# 
# 输入: "A man, a plan, a canal: Panama"
# 输出: true
# 
# 
# 示例 2:
# 
# 输入: "race a car"
# 输出: false
# 
# 
#
class Solution:
    def isPalindrome(self, s: str) -> bool:
        import re
        new = re.sub('[^0-9a-zA-Z]+', '', s)
        return new.lower()==new.lower()[::-1]

