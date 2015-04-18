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

curl "http://stock.hexun.com/qsyjbg/index.html" -o index.html

#url&&name
cat index.html | grep "<a href='http://stock.hexun.com">$urlname
cat index.html | grep "<a href='http://yanbao.stock.hexun.com">>$urlname
cat index.html | grep '<li><span class="sgd01">'>$timeTemp

#url
awk -F "<a href='" 'NF>1{print $2}' $urlname|awk -F ' target' 'NF>1{printf $1}'|sed -e "s/'/\n/g" |sed -e 's/ //g'>$url

#name
awk -F '>' 'NF>1{print $2}' $urlname|awk -F '/a' 'NF>1{printf $1}'|sed -e 's/*//g;s/</\n/g'>$name

#time
year=$(date +'%Y')
awk -F '(' 'NF>1{print $2}' $timeTemp|awk -F '</div>' 'NF>1{printf $1}'|sed -e 's/)/\n/g'|sed -e 's/\//-/g'|sed -e "s/^/$year-/g">$time


