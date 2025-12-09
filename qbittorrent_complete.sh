#!/bin/bash
# qbittorrent 다운로드 알림

source /config/utils.sh
log_file=/tmp/$(basename "$0" | sed 's/.sh//').log
msg_file=/tmp/$(basename "$0" | sed 's/.sh//').tmp

gib=$(awk 'BEGIN {printf "%.2f", '"$2"' / (1024 * 1024 * 1024)}')

echo "$1, $gib GiB download completed" > "$log_file"
cp "$log_file" "$msg_file"
send_tel_msg "$TEL_BOT_KEY" "$TEL_CHAT_ID" "$msg_file"
rm "$msg_file"

#do not download 디렉토리, 파일 삭제
find "/downloads/watched" -type d -name ".unwanted" | sed 's/\/.unwanted/"/' |  sed 's/^/"/g' | xargs rm -rf
find "/downloads/watched" -type f -name "*.\!qB"
find "/downloads/complete" -type d -name ".unwanted" | sed 's/\/.unwanted/"/' |  sed 's/^/"/g' | xargs rm -rf
find "/downloads/complete" -type f -name "*.\!qB"
