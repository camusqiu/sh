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

source="港股公告"
DBHost=10.10.7.36
DBName=db_stock
DBUser=root
DBPwd=Szjty836889
DBPort=3306

mv $index ../src/indexHistory/$day.html

day=$(date +'%Y-%m-%d')

curl "http://www.hkexnews.hk/listedco/listconews/mainindex/SEHK_LISTEDCO_DATETIME_TODAY_C.HTM" -o index.html

#url
cat index.html|sed -e 's/<tr class="row/\n/g'|awk -F 'class="news" href="' 'NF>1{print $2}'|awk -F ' target' 'NF>1{printf $1}'|sed -e 's/"/\n/g'|sed -e 's/^/http:\/\/www.hkexnews.hk/g'>$url



#code
cat index.html | awk -F '<tr class="row' 'NF>1{print $2}'|awk -F '<td class="arial12black">' 'NF>1{print $1}' |awk -F '<td width="54">' 'NF>1{print $2}'|awk -F '</td>' 'NF>1{print $1}'>$code
cat index.html|sed -e 's/<tr class="row/\n/g'|awk -F '<td class="arial12black">' 'NF>1{print $2}'|awk -F '/td>' 'NF>1{printf $1}'|sed -e 's/<BR//g;s/\///g;s/ //g;s/>[0-9][0-9][0-9][0-9][0-9]//g'|awk -F 'PDF)<' 'NF>1{print $2}'|sed -e 's/</\n/g'>>$code

#time
i=0
timeTempArray[0]="1"
cat index.html|sed -e 's/<tr class="row/\n/g'|awk -F 'width="10">' 'NF>1{print $3}'|awk -F '/td>' 'NF>1{printf $1}'|sed -e 's/</\n/g'>./timeTemp.log
for n in $(cat ./timeTemp.log)
do
    timeTempArray[$i]=$n
    i=$((i+1))
done

cat index.html|sed -e 's/<tr class="row/\n/g'|awk -F 'width="10">' 'NF>1{print $2}'|awk -F 'br>' 'NF>1{printf $1}'|sed -e 's/</\n/g;s/\//-/g'>$timeTemp
cat /dev/null>$time
i=0
nameTempArray[0]="1"
for n in $(cat $timeTemp)
do
    timeTempVal=$(echo $n |cut -d '-' -f 3)-$(echo $n |cut -d '-' -f 2)-$(echo $n |cut -d '-' -f 1)_${timeTempArray[$i]}
    echo $timeTempVal>>$time
    nameTempArray[$i]=$timeTempVal
    i=$((i+1))
done

#name
i=0
cat /dev/null>$name
#cat index.html|sed -e 's/<tr class="row/\n/g'|awk -F '<nobr>' 'NF>1{print $2}'|awk -F '/nobr>' 'NF>1{printf $1}'|sed -e 's/<BR//g;s/\///g;s/ //g;s/>*</</g'
cat index.html|sed -e 's/<tr class="row/\n/g'|awk -F '<nobr>' 'NF>1{print $2}'|awk -F '/nobr>' 'NF>1{printf $1}'|sed -e 's/ //g;s/<BR\/>//g'|sed -e 's/</\n/g'|sed -e "s/'//g">$nameTemp

cat index.html|sed -e 's/<tr class="row/\n/g'|awk -F '<nobr>' 'NF>1{print $2}'|awk -F 'target="_new">' 'NF>1{print $2}'|sed 's/="[^"]*[><][^"]*"//g;s/<[^>]*>//g'|sed -e 's/&nbsp;//g;s/;//g;s/,//g;s/ //g;s/-//g'|sed -e 's/PDF//g;s/KB//g;s/(//g;s/)//g;s/[0-9]//g'>$urlnameTemp

i=0
urlnameTempArray[0]="1"
for n in $(cat $urlnameTemp)
do
    urlnameTempArray[$i]=$n
    i=$((i+1))
done

i=0
n=0
for n in $(cat $nameTemp)
do
    timeTempVal=$n:${urlnameTempArray[$i]}
    echo $timeTempVal>>$name
    i=$((i+1))
done


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

let i=0
let j=0
for u in $(cat $code)
do
    tag=${allName[$i]}
    if [ ${#tag} -ne 0 ];
    then
        allCode[$i]=$u
        aCode[$j]=$u
        j=$((j+1))
    else
        allCode[$i]=""
    fi
        i=$((i+1))
done


#download html 下载html
#num=0
#cat $url | while read line
#for line in ${aUrl[@]}
#do
#    curl "${line}">../html/$num.html
#    let num++
#done


#insert db

let i=0
for i in "${!aName[@]}";
do
    #strcont=$(cat ../html/$i.html|tr -d '\n' |awk -F '<span id="spanDateTime">' 'NF>1{print $2}'|awk -F '<div id="divsubnews">' 'NF>1{print $1}'| sed -e 's/<[^<]*>//g')
    aNameTemp=$(echo ${aName[$i]} | sed -e 's/#/ /g')
    aTimeTemp=$(echo ${aTime[$i]} | sed -e 's/#/ /g;s/_/ /g')
    printf "name:[%s]  url:[%s]  time:[%s] code:[%s]\n" "${aNameTemp}" "${aUrl[$i]}" "${aTimeTemp}" "${aCode[$i]}">>log
    SQL="set names utf8;insert into db_stock.news_info (type, title, url, time, content, source, state, ctime, code) values (2, '${aNameTemp}', '${aUrl[$i]}', '${aTimeTemp}', '', '${source}', 0, '${cTime}', '${aCode[$i]}');"
    mysql -h$DBHost -u$DBUser -p$DBPwd $DBName -P$DBPort -N -e "${SQL}"
    #echo "insert SQL:[${SQL}]"
done
