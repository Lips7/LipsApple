#
# @lc app=leetcode.cn id=68 lang=python3
#
# [68] 文本左右对齐
#

# @lc code=start


class Solution:
    def fullJustify(self, words: List[str], maxWidth: int) -> List[str]:
        n = len(words)
        res = []
        i = 0
        while i < n:
            oneLine = [words[i]]
            j = i + 1
            curr = len(words[i])
            pos = 0
            space = maxWidth-len(words[i])
            while j < n and curr + 1 + len(words[j]) <= maxWidth:
                oneLine.append(words[j])
                curr += 1 + len(words[j])
                space -= len(words[j])
                pos += 1
                j += 1
            i = j
            if i < n and pos:
                spaces = [' ' * (space // pos + (k < space % pos)) for k in range(pos)] + ['']
            else:
                spaces = [' '] * pos + [' ' * (maxWidth - curr)]
            res.append(''.join([s for pair in zip(oneLine, spaces) for s in pair]))
        return res
# @lc code=end
