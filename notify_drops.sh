#!/bin/bash
# esportshelper drop 알림

source /home/dev/.bashrc
source /home/dev/.local/bin/utils.sh
log_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').log
msg_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').tmp

drops_file="$(date -d "1 days ago" +%Y%m%d)"-drops.txt
echo "$drops_file" > "$log_file"
cat "/opt/esportshelper/data/$drops_file" >> "$log_file"
cp "$log_file" "$msg_file"
send_tel_msg "$TEL_BOT_KEY" "$TEL_CHAT_ID" "$msg_file"
rm "$msg_file"
