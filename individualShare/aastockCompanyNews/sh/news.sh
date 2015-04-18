#!/bin/bash

#definde
nowTime=$(date +"%Y%m%d%H%M%S")
cTime=$(date +"%Y-%m-%d %H:%M:%S")
day=$(date +'%Y%m%d')

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
nameAll=../../../common/record/name.txt

source="阿斯达克"
DBHost=10.10.7.36
DBName=db_stock
DBUser=root
DBPwd=Szjty836889
DBPort=3306

mv $index ../src/indexHistory/$day.html

day=$(date +'%Y-%m-%d')

curl "http://www.aastocks.com/sc/stocks/news/aafn-company-news" -o index.html

#url&&name
awk -F '<div class="pad4 font-b">' 'NF>1{print $2}' index.html|awk -F '<div class="common_box" id="divLoading"' 'NF>1{printf $1}'>$urlnameTemp
sed -e 's/<a class="h6"/\n<a class="h6"/g' $urlnameTemp|awk -F '<a class="h6"' 'NF>1{print $2}'>$urlname

#url
awk -F 'href="' 'NF>1{print $2}' $urlname| awk -F '" title' 'NF>1{print $1}'|sed -e 's/^/http:\/\/www.aastocks.com/g'|sed -e 's/ /#/g'>$url

#name
sed -e 's/<a class="h6"/\n<a class="h6"/g' $urlname|awk -F ' title="' 'NF>1{print $2}'|awk -F '>' 'NF>1{printf $1}'|sed -e 's/*//g;s/"/\n/g;s/ /#/g'>$name

#time
awk -F '<div class="newstime2">' 'NF>1{print $2}' $urlname|awk -F '/div>' 'NF>1{printf $1}'|sed -e 's/</\n/g;s/\//-/g;s/ /#/g'>$time


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
    if [ ${#tag} -eq 0 ];
    then
        aName[$j]=$n 
        echo "${nowTime}:${aName[$j]}">>$nameAll
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
    strcont=$(cat ../html/$i.html|tr -d '\n' |awk -F '<span id="spanDateTime">' 'NF>1{print $2}'|awk -F '<div id="divsubnews">' 'NF>1{print $1}'| sed -e 's/<[^<]*>//g')
    aNameTemp=$(echo ${aName[$i]} | sed -e 's/#/ /g')
    aTimeTemp=$(echo ${aTime[$i]} | sed -e 's/#/ /g')
    printf "name:[%s]  url:[%s]  time:[%s] strcont:[%s]\n" "${aNameTemp}" "${aUrl[$i]}" "${aTimeTemp}" "${strcont}"
    SQL="set names utf8;insert into db_stock.news_info (type, title, url, time, content, source, state, ctime) values (5, '${aNameTemp}', '${aUrl[$i]}', '${aTimeTemp}', '${strcont}', '${source}', 0, '${cTime}');"
    mysql -h$DBHost -u$DBUser -p$DBPwd $DBName -P$DBPort -N -e "${SQL}"
    #echo "insert SQL:[${SQL}]"
done
