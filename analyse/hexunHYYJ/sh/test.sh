#!/bin/bash


nowTime=$(date)
#mv ./index.html ./src/indexHistory/$nowTime.html

curl "http://www.sse.com.cn/disclosure/listedinfo/announcement/s_docdatesort_desc.htm?p=${nowTime}" -o index.html


#code
awk -F 'target="_blank">' 'NF>1{print $2}' ./index.html|awk -F ':' 'NF>1{printf $1}'>./temp/codeTemp.txt
code=$(cat ./temp/codeTemp.txt)
echo $code|sed -e 's/ /\n/g'>>./src/code.txt
#name
awk -F ': ' 'NF>1{print $2}' ./index.html|awk -F '/a>' 'NF>1{printf $1}'>./temp/nameTemp.txt
name=$(cat ./temp/nameTemp.txt)
echo $name|sed -e 's/</\n/g'>>./src/name.txt
#url
awk -F '<a href="' 'NF>1{print $2}' ./index.html|awk -F '  target' 'NF>1{printf $1}'>./temp/urlTemp.txt
url=$(cat ./temp/urlTemp.txt)
echo $url|sed -e 's/"/\n/g'>>./src/url.txt

Tag=0
nameArray[0]=""
cat ./src/name.txt|while read line
do
	nameArray[${Tag}]=$line
	echo ${nameArray[${Tag}]}
	let Tag++
done

Tag=0
cat ./src/urltest.txt|while read line
do
	echo ${nameArray[$Tag]}
	curl $line -o ./html/${nameArray[${Tag}]}.pdf
	let Tag++
done
