#!/bin/bash

LINE_NOTIFY_ACCESS_TOKEN="MRKqIY2hW6GrjZ5PGlzNIKrP2sZMzqoYPYZVicE9RAJ"

# Read the JSON file
json=$(cat importance_days_list.json)

# Define an array of importance_day messages
messages=("สุขสันต์วันเกิดนะค่ะ ขอnicknameให้มีสุขภาพแข็งแรงเสมอ มีความสุขในชีวิตนะค่ะ" "ขอให้nicknameมีความสุขมากๆนะ ขอให้สุขสมหวังในสิ่งที่อยากได้นะ สุขสันต์วันเกิดนะ" "ขอnicknameให้รวยๆ เฮงๆ กิจการรุ่งเรือง เป็น แม่เลี้ยง พ่อเลี้ยง ขอให้ได้เป็นเจ้าคนนายคนนะเพื่อนรัก" "สุขสันต์วันเกิดนะnickname ขอให้โชคดีมีชัย คิดสิ่งหนึ่งสิ่งใด ขอให้สมปรารถนา" "ขอให้มีความสุขมากๆ สุขสันต์วันเกิดนะnickname ปะ!! วันนี้ฉลองไหนดี" "ขอให้nicknameมีสุขภาพที่ผ่องใส ขอให้สวยๆหล่อๆ มีเงินใช้ตลอดทั้งปี")

# Loop through each record in the JSON array
for record in $(echo "${json}" | jq -c '.[]'); do

    # Extract the fields from the record
    importance_day=$(echo "${record}" | jq -r '.importance_day')
    nickname=$(echo "${record}" | jq -r '.nickname')
    type=$(echo "${record}" | jq -r '.type')
    importance_message=$(echo "${record}" | jq -r '.importance_message')

    # Extract the month and day fields from the importance_day date
    month=$(echo "${importance_day}" | awk -F'-' '{print $2}')
    day=$(echo "${importance_day}" | awk -F'-' '{print $3}')
    year=$(echo "${importance_day}" | awk -F'-' '{print $1}')

    # Format the month and day fields as "MM-DD"
    importance_day_month_day="${month}-${day}"
    importance_day_month_year="${year}-${month}-${day}"

    # Check if today is the person's importance_day
    today=$(date +'%m-%d')
    todayFull=$(date +'%Y-%m-%d')
    echo $todayFull
    echo $importance_day_month_year

    if [ "${today}" == "${importance_day_month_day}" ]; then

        final_message=""

        if [ "${type}" == "birthday" ]; then

            random_index=$((RANDOM % ${#messages[@]}))
            message="${messages[random_index]}"
            message=$(echo "${message}" | sed "s/nickname/${nickname}/g")
            final_message="🎉🎉🎉 วันนี้เป็นวันเกิดของ ${nickname} 🎁 🎂 ${message}"

        elif [ "${type}" == "alert" ]; then
            if [ "${todayFull}" == "${importance_day_month_year}" ]; then
                final_message="🚨🚨🚨 แจ้งเตือน : ${importance_message} 🚨🚨🚨"
            fi
        else

            final_message="🎉🎉🎉 วันนี้เป็นวันหยุดงาน เนื่องจาก เป็น : ${nickname} 🎉🎉🎉 "

        fi

        # Check if the string is empty
        if [ -z "${final_message}" ]; then
            # If the string is empty, print a message
            echo "The string is empty"
        else
            curl -X POST \
                -H "Authorization: Bearer $LINE_NOTIFY_ACCESS_TOKEN" \
                -F "message=$final_message" \
                https://notify-api.line.me/api/notify
        fi

        final_message=""
    fi
done
