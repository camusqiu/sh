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

source="新浪"
DBHost=10.10.7.36
DBName=db_stock
DBUser=root
DBPwd=Szjty836889
DBPort=3306

mv $index ../src/indexHistory/$day.html

curl "http://roll.news.sina.com.cn/interface/rollnews_ch_out_interface.php?col=49&spec=&type=&ch=03&k=&offset_page=0&offset_num=0&num=60&asc=&page=1" -o index.html

#name
awk -F '},title : "' 'NF>1{print $2}' $index|awk -F ',url' 'NF>1{printf $1}'|sed 's/"/\n/g'|sed -e 's/*//g;s/ /#/g'|iconv -f gbk -t utf-8>$name

#url
awk -F '},title : "' 'NF>1{print $2}' $index|awk -F 'type' 'NF>1{printf $1}'|iconv -f gbk -t utf-8>$urlnameTemp
sed -e 's/url :/\nurl :/g' $urlnameTemp| awk -F 'url : "' 'NF>1{print $2}' |awk -F ',' 'NF>1{printf $1}'>$urlTemp
echo $(cat $urlTemp)|sed -e 's/"/\n/g'|sed -e 's/ /#/g'>$url

#time
awk -F ',time : ' 'NF>1{print $2}' $index|awk -F ',' 'NF>1{printf $1}'>$timeTemp
#the last line
awk -F ',time : ' 'NF>1{print $2}' $index|awk -F ']' 'NF>1{printf $1}'>>$timeTemp
echo $(cat $timeTemp)|sed -e 's/}/\n/g'>../temp/timeUnix.txt

rm -rf $time
cat ../temp/timeUnix.txt|while read line
do
if [ "$line" != "" ];
then
date -d '1970-01-01 UTC '$line' seconds' +'%Y-%m-%d %T'|sed -e 's/ /#/g'>>$time
fi
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
strcont=$(cat ../html/$i.html|tr -d '\n' |awk -F '<div class="blkContainerSblkCon BSHARE_POP" id="artibody">' 'NF>1{print $2}'|awk -F '<p class="art_keywords"' 'NF>1{print $1}'| sed -e 's/<[^<]*>//g'|sed -e "s/'//g" | iconv -f gbk -t utf-8)
aNameTemp=$(echo ${aName[$i]} | sed -e "s/#/ /g;s/'//g")
aTimeTemp=$(echo ${aTime[$i]} | sed -e "s/#/ /g;s/'//g")
printf "name:[%s]  url:[%s]  time:[%s] strcont:[%s]\n" "${aNameTemp}" "${aUrl[$i]}" "${aTimeTemp}" "${strcont}"
#printf "name:[%s]  url:[%s]  time:[%s]\n" "${aNameTemp}" "${aUrl[$i]}" "${aTimeTemp}"
SQL="set names utf8;insert into db_stock.news_info (type, title, url, time, content, source, state, ctime) values (3, '${aNameTemp}', '${aUrl[$i]}', '${aTimeTemp}', '${strcont}', '${source}', 0, '${cTime}');"
mysql -h$DBHost -u$DBUser -p$DBPwd $DBName -P$DBPort -N -e "${SQL}"
#echo "insert SQL:[${SQL}]"
done
