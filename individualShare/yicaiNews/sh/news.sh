#!/bin/bash
#definde
urlname=../temp/urlname.txt
urlnameTemp=../temp/urlnameTemp.txt
urlTemp=../temp/urlTemp.txt
timeTemp=../temp/timeTemp.txt
nameTemp=../temp/nameTemp.txt
codeTemp=../temp/codeTemp.txt
index=./index.html
url=../src/url.txt
name=../src/name.txt
time=../src/time.txt
code=../src/code.txt
urlHead="http://finance.qq.com/"


nowTime=$(date)
#mv $index ./src/indexHistory/$nowTime.html

curl "http://www.yicai.com/stock/hk/" -o index.html

#url&&name
awk -F '<li class="newsStyleLine01"><h2>' 'NF>1{print $2}' $index|awk -F '<p>' 'NF>1{printf $1}'>$urlnameTemp
awk -F '<li><h2><a' 'NF>1{print $2}' $index|awk -F '<p>' 'NF>1{printf $1}'>>$urlnameTemp

sed -e 's/\/h3>/\n/g' $urlnameTemp>$urlname

#url
awk -F 'href="' 'NF>1{print $2}' $urlname|awk -F '"' 'NF>1{printf $1}'|sed -e 's/html/html\n/g'|sed -e 's/^/http:\/\/www.yicai.com/g'>$url
row=$(cat $url|wc -l)

#name
awk -F '">' 'NF>1{print $2}' $urlname |awk -F '/a>' 'NF>1{printf $1}'|sed -e 's/[&amp;amp;quot]//g'|sed -e 's/</\n/g'>$name

#time
sed -e 's/</<(/g' $urlname|awk -F '发布时间：' 'NF>1{print $2}' |awk -F '(' 'NF>1{printf $1}'|sed -e 's/</\n/g'>$time
