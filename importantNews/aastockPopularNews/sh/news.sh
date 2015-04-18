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

#curl "http://www.aastocks.com/sc/stocks/news/aafn-company-news" -o index.html
curl "http://www.aastocks.com/sc/stocks/news/aafn/popular-news" -o index.html

#url&&name
awk -F '<div class="pad4 font-b">' 'NF>1{print $2}' index.html|awk -F '<div class="common_box" id="divLoading"' 'NF>1{printf $1}'>$urlnameTemp
sed -e 's/<a class="h6"/\n<a class="h6"/g' $urlnameTemp|awk -F '<a class="h6"' 'NF>1{print $2}'>$urlname

#url
awk -F 'href="' 'NF>1{print $2}' $urlname| awk -F '" title' 'NF>1{print $1}'|sed -e 's/^/http:\/\/www.aastocks.com/g'>$url

#name
sed -e 's/<a class="h6"/\n<a class="h6"/g' $urlname|awk -F ' title="' 'NF>1{print $2}'|awk -F '>' 'NF>1{printf $1}'|sed -e 's/"/\n/g'>$name

#time
awk -F '<div class="newstime2">' 'NF>1{print $2}' $urlname|awk -F '/div>' 'NF>1{printf $1}'|sed -e 's/</\n/g'>$time


