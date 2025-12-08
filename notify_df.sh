#!/bin/bash
# disk free 알림

source /home/dev/.bashrc
source /home/dev/.local/bin/utils.sh
log_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').log
msg_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').tmp

if [ -z "$1" ]; then
  err "MANDATORY PARAMETER MISSING"
  exit 1
fi
{ for i in $1; do
    show_disk_stat "$i";
  done;
} > "$log_file"
cp "$log_file" "$msg_file"
send_tel_msg "$TEL_BOT_KEY" "$TEL_CHAT_ID" "$msg_file"
rm "$msg_file"
