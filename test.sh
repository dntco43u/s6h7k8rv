#!/bin/bash
# 테스트

source /home/dev/.bashrc
source /home/dev/.local/bin/utils.sh
log_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').log
msg_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').tmp

echo "PATH=$PATH" | tee -a "$log_file"
echo "BASH_ENV=$BASH_ENV" | tee -a "$log_file"
echo "TEL_BOT_KEY=$TEL_BOT_KEY" | tee -a "$log_file"
cp "$log_file" "$msg_file"
send_tel_msg "$TEL_BOT_KEY" "$TEL_CHAT_ID" "$msg_file"
rm "$msg_file"
rm "$log_file"
