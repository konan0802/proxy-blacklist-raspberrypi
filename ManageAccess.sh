#!/bin/sh

# ブラックIP
#blackIP[0]=".youtube.com"
#blackIP[1]=".twitter.com"
#blackIP[2]=".facebook.com"
#blackIP[3]=".instagram.com"
#blackIP[4]=".amazonvideo.com"

write_json () {
printf '{
  "state":"%s",
  "time":"%s"
}' "${1}" "${2}" > AccessState.json
}
#time=`date +" %Y-%m-%d %H:%M:%S" -d "1 hour"`

research_log () {
while read ymd hms hostn
do
  ary
} < /var/log/squid/access.log

apply_blacklist () {

}

# AccessState.jsonを読み込み
state=$(cat AccessState.json | jq '.state' | sed 's/^.*"\(.*\)".*$/\1/')

#  開放中の場合
if [ ${state} = "Free" ]; then
    echo "Free"

# 利用時間中の場合
elif [ ${state} = "Able" ]; then
    echo "Able"

# 制限中の場合
else
    strTime=$(cat AccessState.json | jq '.time' | sed 's/^.*"\(.*\)".*$/\1/')
    freeTime=`date -d "${strTime}" +%s`
    nowTime=`date +%s`

    echo ${freeTime}
    echo ${nowTime}

    # 制限終了時間になっていない場合
    if [ ${freeTime} -ge ${nowTime} ]; then
            echo "制限終了時間はまだ"
	        exit 0
    # 制限終了時間になっていた場合
    else
	    echo "制限終了時間が過ぎた"
	    write_json "Free" ""
	    exit 0
    fi
fi

# 過去1時間分のアクセスログを取得
#while read BUF ; do
#do
#    ary=(`echo $BUF`) 
#    echo ${ary[0]}
#done < /var/log/squid/access.log


# sudo systemctl restart squid.service

exit 0