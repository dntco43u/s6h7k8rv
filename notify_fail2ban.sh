#!/bin/sh
# fail2ban 알림

. /home/dev/.bashrc
. /home/dev/.local/bin/utils.sh
log_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').log
msg_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').tmp

action="$1"
name="$2"
ip="$3"
{ if [ "$action" = "actionstart" ]; then
    echo  ["$name"] started
  fi
  if [ "$action" = "actionstop" ]; then
    echo  ["$name"] stopped
  fi
  if [ "$action" = "actionban" ]; then
    echo  ["$name"] Ban "$ip"
    whois "$ip" | grep -iE "^(address|country)" \
      | sed -E 's/^(country|address)(.*:)( +)(.*)/\1: \4/gI'
  fi
  if [ "$action" = "actionunban" ]; then
    echo  ["$name"] Unban "$ip"
  fi
} > "$log_file"
cp "$log_file" "$msg_file"
send_tel_msg "$TEL_BOT_KEY" "$TEL_CHAT_ID" "$msg_file"
rm "$msg_file"
