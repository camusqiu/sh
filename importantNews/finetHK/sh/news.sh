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

curl "http://www.finet.hk/mainsite/newscenter/FINETHK/" -o index.html

#url
cat index.html |grep '<a href="/mainsite/newscenter/FINETHK/0/'|awk -F '<a href="' 'NF>1{print $2}' |awk -F '>' 'NF>1{printf $1}'|sed -e 's/"/\n/g'|sed -e 's/^/http:\/\/www.finet.hk/g'>$url

#name
cat index.html |grep '<a href="/mainsite/newscenter/FINETHK/0/'|awk -F '>' 'NF>1{print $2}' |sed -e 's/<\/a//g'>$name

#time
awk -F '<font color="#000000" style="font-size:11px">' 'NF>1{print $2}' ./index.html|awk -F '/font></td>' 'NF>1{printf $1}'|sed -e 's/</\n/g'>$time


