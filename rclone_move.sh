#!/bin/bash
# rclone으로 이동

source /home/dev/.bashrc
source /home/dev/.local/bin/utils.sh
log_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').log
msg_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').tmp

cat /dev/null > "$log_file"
flock -n /tmp/rclone.lock \
  rclone move \
  "$1" "$2" \
  --config /home/dev/.config/rclone/rclone.conf \
  --log-file "$log_file" --log-level DEBUG \
  --delete-empty-src-dirs
grep -oE '^Transferred:.*100%.*\/s' "$log_file" \
  | head -n 1 | sed 's/\t//g' | sed 's/  */ /g' > "$msg_file"
send_tel_msg "$TEL_BOT_KEY" "$TEL_CHAT_ID" "$msg_file"
rm "$msg_file"
