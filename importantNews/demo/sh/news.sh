#!/bin/bash
#definde
urlTemp=./temp/urlTemp.txt
timeTemp=./temp/timeTemp.txt
nameTemp=./temp/nameTemp.txt
codeTemp=./temp/codeTemp.txt
index=./index.html
url=./src/url.txt
name=./src/name.txt
time=./src/time.txt
code=./src/code.txt
urlHead="http://finance.qq.com/"


nowTime=$(date)
#mv $index ./src/indexHistory/$nowTime.html

curl "http://www.sse.com.cn/disclosure/listedinfo/announcement/s_docdatesort_desc.htm?p=${nowTime}" -o index.html

#url&&name
awk -F '<em class="f20 l26"><a target="_blank" href="' 'NF>1{print $2}' $index|awk -F '/a>' 'NF>1{printf $1}'>$urlTempt 
echo $url|sed -e 's/"//g'|sed -e 's/>/\n/g'|sed -e 's/</\n/g'>$urlTemp

#url
awk 'NR%2' $urlTemp>$url

#name
awk '!(NR%2)' $urlTemp>$name

#time
awk -F '<p class="time l22">' 'NF>1{print $2}' $index|awk -F '/p>' 'NF>1{printf $1}'>$timeTemp
time=$(cat $timeTemp)
echo $time|sed -e 's/</\n/g'>>$time


Tag=0
nameArray[0]=""
cat $name|while read line
do
	nameArray[${Tag}]=$line
	echo ${nameArray[${Tag}]}
	let Tag++
done

Tag=0
cat $urltest|while read line
do
	thisUrl=$urlHead$line
	echo ${nameArray[$Tag]}
	curl $thisUrl -o ./html/${nameArray[${Tag}]}.pdf
	let Tag++
done
