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

source="和讯"
DBHost=10.10.7.36
DBName=db_stock
DBUser=root
DBPwd=Szjty836889
DBPort=3306

mv $index ../src/indexHistory/$nowTime.html

curl "http://stock.hexun.com/qsyjbg/index.html" -o index.html

#url&&name
cat index.html | grep "<a href='http://stock.hexun.com">$urlname
cat index.html | grep "<a href='http://yanbao.stock.hexun.com">>$urlname
cat index.html | grep '<li><span class="sgd01">'>$timeTemp

#url
awk -F "<a href='" 'NF>1{print $2}' $urlname|awk -F ' target' 'NF>1{printf $1}'|sed -e "s/'/\n/g" |sed -e 's/ //g'>$url

#name
awk -F '>' 'NF>1{print $2}' $urlname|awk -F '/a' 'NF>1{printf $1}'|sed -e 's/</\n/g'|sed -e 's/ /#/g' |iconv -f gbk -t utf-8>$name

#time
year=$(date +'%Y')
awk -F '(' 'NF>1{print $2}' $timeTemp|awk -F '</div>' 'NF>1{printf $1}'|sed -e 's/)/\n/g'|sed -e 's/\//-/g'|sed -e "s/^/$year-/g"|sed -e 's/ /#/g'>$time

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
if [ -z $(echo ${aUrl[$i]} | grep "yanbao") ];
then
    strcont=$(cat ../html/$i.html|tr -d '\n' |awk -F 'id="artibody"' 'NF>1{print $2}'|awk -F 'id="arctTailMark"' 'NF>1{print $1}'| sed -e 's/<[^<]*>//g'| iconv -f gbk -t utf-8)
else
    strcont=$(cat ../html/$i.html|tr -d '\n' |awk -F '<p class="text_01">' 'NF>1{print $2}'|awk -F 'getElementById' 'NF>1{print $1}'| sed -e 's/<[^<]*>//g'| iconv -f gbk -t utf-8)
fi
aNameTemp=$(echo ${aName[$i]} | sed -e 's/#/ /g')
aTimeTemp=$(echo ${aTime[$i]} | sed -e 's/#/ /g')
printf "name:[%s]  url:[%s]  time:[%s] strcont:[%s]\n" "${aNameTemp}" "${aUrl[$i]}" "${aTimeTemp}" "${strcont}"
#printf "name:[%s]  url:[%s]  time:[%s]\n" "${aNameTemp}" "${aUrl[$i]}" "${aTimeTemp}"
SQL="set names utf8;insert into db_stock.news_info (type, title, url, time, content, source, state, ctime) values (4, '${aNameTemp}', '${aUrl[$i]}', '${aTimeTemp}', '${strcont}', '${source}', 0, '${cTime}');"
mysql -h$DBHost -u$DBUser -p$DBPwd $DBName -P$DBPort -N -e "${SQL}"
#echo "insert SQL:[${SQL}]"
done
