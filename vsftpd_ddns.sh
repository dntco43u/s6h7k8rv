#!/bin/bash
# vsftpd 동적 ip 구성

source /home/dev/.bashrc
source /home/dev/.local/bin/utils.sh
log_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').log
msg_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').tmp

ftp_ip=$(grep -E "(^pasv_address=)(.*)" /etc/vsftpd/vsftpd.conf \
  | sed -E "s/(^pasv_address=)(.*)/\2/g")
real_ip=$(dig +short txt ch whoami.cloudflare @1.1.1.1 | sed 's/"//g')

if [ "$ftp_ip" != "$real_ip" ]; then
  sed -Ei "s/(^pasv_address=)(.*)/\1$real_ip/g" /etc/vsftpd/vsftpd.conf
  systemctl restart vsftpd.service
  echo "vsftpd: pasv_address=$real_ip" > "$log_file"
  cp "$log_file" "$msg_file"
  send_tel_msg "$TEL_BOT_KEY" "$TEL_CHAT_ID" "$msg_file"
  rm "$msg_file"
fi
