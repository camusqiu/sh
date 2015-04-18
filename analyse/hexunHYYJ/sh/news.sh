#!/bin/bash
#definde
urlname=../temp/urlname.txt
urlnameTemp=../temp/urlnameTemp.txt
urlTemp=../temp/urlTemp.txt
timeTemp=../temp/timeTemp.txt
nameTemp=../temp/nameTemp.txt
codeTemp=../temp/codeTemp.txt
sourceTemp=../temp/sourceTemp.txt
index=./index.html
url=../src/url.txt
name=../src/name.txt
time=../src/time.txt
code=../src/code.txt
source=../src/source.txt
urlHead="http://finance.qq.com/"


nowTime=$(date)
#mv $index ./src/indexHistory/$nowTime.html

curl "http://yanbao.stock.hexun.com/listnews.aspx?type=2" -o index.html

#url&&name
cat index.html | grep '<td align="left">' | sed -e 's/<td align="left">/\n<td align="left">/g'>$urlnameTemp

#url
awk -F '<td align="left"><a href="' 'NF>1{print $2}' $urlnameTemp| awk -F ' target' 'NF>1{printf $1}'|sed -e 's/"/\n/g'|sed -e 's/^/http:\/\/yanbao.stock.hexun.com\//g'>$url

#name
awk -F 'class="fxx_wb">' 'NF>1{print $2}' $urlnameTemp| awk -F '/a>' 'NF>1{printf $1}'|sed -e 's/*//g;s/</\n/g'>$name

#time
year=$(date +'%Y')
awk -F '<td align="left" style="padding-left:5px">'$year'' 'NF>1{print $2}' $urlnameTemp|awk -F '/td>' 'NF>1{printf $1}'|sed -e 's/</\n/g'|sed -e 's/^/'$year'/g'>$time

#source
cat $urlnameTemp | sed 's/\\/\\\\/g;s/\(%\)\([0-9a-fA-F][0-9a-fA-F]\)/\\x\2/g'>$sourceTemp
awk -F '<a href="dgyj.aspx?' 'NF>1{print $2}' $sourceTemp|awk -F '</a>' 'NF>1{printf $1}'|sed -e 's/sname/\n/g'| awk -F 'target="_blank">' 'NF>1{print $2}'| sed -e 's/?//g'>$source

