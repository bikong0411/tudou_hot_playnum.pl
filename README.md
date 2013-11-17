tudou_hot_playnum.pl
====================

扒取土豆每天热门视频播放数

<pre>
Usage: perl tudou.pl   #播放量信息保存在tudou.log的文本，有重复（懒得过滤了）
sort -u tudou.log > tudow.uniq.log
awk -F '=>' '{sum+=$NF;}END{print sum}' tudow.uniq.log
</pre>
