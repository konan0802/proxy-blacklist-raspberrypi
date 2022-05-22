#!/bin/sh

# ブラックIP
blackIPs=(
    ".youtube.com"
    ".googlevideo.com"
    ".twitter.com"
    ".facebook.com"
    ".instagram.com"
    ".amazonvideo.com"
)

# jsonに書き込み
writeJson () {
    printf '{"state":"%s","time":"%s"}' "${1}" "${2}" > AccessState.json
}
#time=`date +" %Y-%m-%d %H:%M:%S" -d "1 hour"`

# 過去10分間のログにブラックIPが含まれるかを確認
isBlackIPInAccessLog () {
    inBlackIP=0
    while read ymd hms x hostn
    do
        logDatetime=`date -d "${ymd} ${hms}" +%s`
        if [ ${logDatetime} -ge ${1} ]; then
            for blackIP in "${blackIPs[@]}" ; do
                if [[ ${hostn} == *${blackIP}* ]]; then
                    inBlackIP=1
                fi
            done
        fi
    done < /var/log/squid/access.log

    echo ${inBlackIP}
}

applyBlacklist () {
    : > blacklist
    for blackIP in "${blackIPs[@]}" ; do
        echo ${blackIP} >> blacklist
    done
    sudo systemctl restart squid.service
}

removeBlacklist () {
    : > blacklist
    sudo systemctl restart squid.service
}

sendMesToLine () {
    curl -X POST https://api.line.me/v2/bot/message/push \
        -H 'Content-Type: application/json' \
        -H 'Authorization: Bearer チャネルアクセストークン' \
        -d @${1}
}


#-----------------------------------------------------------------

# stateを取得
state=$(cat AccessState.json | jq '.state' | sed 's/^.*"\(.*\)".*$/\1/')

# 現時刻を取得
nowTime=`date +%s`

# 終了時刻を取得
strEndTime=$(cat AccessState.json | jq '.time' | sed 's/^.*"\(.*\)".*$/\1/')


#  Free(開放中)の場合
if [ ${state} = "Free" ]; then
    echo "Free"
    
    before10mTime=`date -d "1 minute ago" +%s`
    inBlackIP=`isBlackIPInAccessLog ${before10mTime}`
    echo ${inBlackIP}
    if [ ${inBlackIP} == 1 ]; then
        after5mTime=`date +" %Y-%m-%d %H:%M:%S" -d "5 minute"`
        writeJson "Able" "${after5mTime}"
        sendMesToLine Able.json
        exit 0
    else
        exit 0
    fi

# Able(利用時間中)の場合
elif [ ${state} = "Able" ]; then
    echo "Able"
    
    # 制限終了時間になっていない場合
    endTime=`date -d "${strEndTime}" +%s`
    if [ ${endTime} -ge ${nowTime} ]; then
            echo "制限終了時間はまだ"
	        exit 0
    # 制限終了時間になっていた場合
    else
	    echo "制限終了時間が過ぎた"
	    applyBlacklist
        after1hourTime=`date +" %Y-%m-%d %H:%M:%S" -d "1 hour"`
        writeJson "Block" "${after1hourTime}"
        sendMesToLine Block.json
	    exit 0
    fi

# Block(制限中)の場合
else
    echo "Block"

    # 制限終了時間になっていない場合
    endTime=`date -d "${strEndTime}" +%s`
    if [ ${endTime} -ge ${nowTime} ]; then
            echo "制限終了時間はまだ"
	        exit 0
    # 制限終了時間になっていた場合
    else
	    echo "制限終了時間が過ぎた"
        removeBlacklist
        writeJson "Free" ""
        sendMesToLine Free.json
	    exit 0
    fi
fi

exit 0