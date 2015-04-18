#!/bin/bash

#definde
nowTime=$(date +"%Y%m%d%H%M%S")
cTime=$(date +"%Y-%m-%d %H:%M:%S")
day=$(date +'%Y%m%d')
year=$(date +'%Y')

urlname=../temp/urlname.txt
urlnameTemp=../temp/urlnameTemp.txt
urlTemp=../temp/urlTemp.txt
timeTemp=../temp/timeTemp.txt
timeTempVal=../temp/timeTempVal.txt
nameTemp=../temp/nameTemp.txt
codeTemp=../temp/codeTemp.txt
index=./index.html
url=../src/url.txt
name=../src/name.txt
time=../src/time.txt
code=../src/code.txt
urlHead="http://finance.qq.com/"
nameAll=../../../common/record/name.txt

source="港股那点事"
DBHost=10.10.7.36
DBName=db_stock
DBUser=root
DBPwd=Szjty836889
DBPort=3306

mv $index ../src/indexHistory/$day.html

curl "http://www.guuzhang.com/portal.php?diy=yes" -o index.html

#time
cat index.html | grep '<div style="height:10px"><font color="#3366FF"><span title'>$timeTemp
sed -e 's/<div style="height:10px"><font color="#3366FF">//g' $timeTemp|awk -F '>' 'NF>1{print $2}'| grep "&nbsp;小时前\|&nbsp;分钟前\|半小时前" |sed -e 's/&nbsp;小时前<\/span//g'| sed -e 's/&nbsp;分钟前<\/span/min/g'|sed -e 's/半小时前<\/span/min/g'>$timeTempVal

h=$(date +'%H')
echo "">$time
cat $timeTempVal | while read line
do
if [ -z $(echo $line|grep "min") ];
then
hTemp=$[($h-$line)]
echo $(date +'%Y-%m-%d ')$hTemp":00:00"|sed -e 's/ /#/g'>>$time
else
echo $(date +'%Y-%m-%d %H')":00:00"|sed -e 's/ /#/g'>>$time
fi
done

lineNum=$(cat $time|wc -l)

#url&&name
cat index.html | grep '<dd class="m"><a href="portal.php'>$urlnameTemp

#url
awk -F 'href="' 'NF>1{print $2}' $urlnameTemp|awk -F ' target' 'NF>1{printf $1}' |sed -e 's/"/\n/g'|sed 's/^/http:\/\/www.gelonghui.com\//g'|sed -e 's/ /#/g'>$urlTemp
head -n$lineNum $urlTemp>$url

#name
awk -F 'alt="' 'NF>1{print $2}' $urlnameTemp|awk -F ' />' 'NF>1{printf $1}' |sed -e 's/"/\n/g'|sed -e 's/*//g;s/ /#/g'>$nameTemp
head -n$lineNum $nameTemp>$name


i=0
j=0

if [ -f $nameAll ];
then
echo " ">>$nameAll
fi

for n in $(cat $name)
do
allName[$i]=$n
i=$((i+1))
done

#遍历name数组，去重
let i=0
let j=0
let n=0
for n in $(cat $name)
do
tag=$(cat $nameAll | grep ${allName[$i]})
echo "[${nameAll}] ${i}:[${allName[$i]}]:[${tag}]:[${#tag}]:[${n}]"
if [ ${#tag} -eq 0 ];
then
aName[$j]=$n
echo "${nowTime}:${aName[$j]}">>$nameAll
#echo "${nowTime}:${aName[$j]}:${n}"
j=$((j+1))
else
allName[$i]=""
fi
i=$((i+1))
done

let i=0
let j=0
for t in $(cat $time)
do
tag=${allName[$i]}
if [ ${#tag} -ne 0 ];
then
allTime[$i]=$t
aTime[$j]=$t
j=$((j+1))
else
allTime[$i]=""
fi
i=$((i+1))
done

let i=0
let j=0
for u in $(cat $url)
do
tag=${allName[$i]}
if [ ${#tag} -ne 0 ];
then
allUrl[$i]=$u
aUrl[$j]=$u
j=$((j+1))
else
allUrl[$i]=""
fi
i=$((i+1))
done


#download html 下载html
num=0
#cat $url | while read line
for line in ${aUrl[@]}
do
curl "${line}">../html/$num.html
let num++
done


#insert db

let i=0
for i in "${!aName[@]}";
do
strcont=$(cat ../html/$i.html|tr -d '\n' |awk -F '<td class="t_f" id="postmessage_' 'NF>1{print $2}'|awk -F 'div id="comment_' 'NF>1{print $1}'| sed -e 's/<[^<]*>//g')
aNameTemp=$(echo ${aName[$i]} | sed -e 's/#/ /g')
aTimeTemp=$(echo ${aTime[$i]} | sed -e 's/#/ /g')
printf "name:[%s]  url:[%s]  time:[%s] strcont:[%s]\n" "${aNameTemp}" "${aUrl[$i]}" "${aTimeTemp}" "${strcont}"
#printf "name:[%s]  url:[%s]  time:[%s]\n" "${aNameTemp}" "${aUrl[$i]}" "${aTimeTemp}"
#SQL="set names utf8;insert into db_stock.news_info (type, title, url, time, content, source, state, ctime) values (4, '${aNameTemp}', '${aUrl[$i]}', '${aTimeTemp}', '${strcont}', '${source}', 0, '${cTime}');"
#mysql -h$DBHost -u$DBUser -p$DBPwd $DBName -P$DBPort -N -e "${SQL}"
#echo "insert SQL:[${SQL}]"
done
