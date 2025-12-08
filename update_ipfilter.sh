#!/bin/bash
# ipfilter.dat 데이터베이스 갱신

source /home/dev/.bashrc
source /home/dev/.local/bin/utils.sh
log_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').log
msg_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').tmp

{ curl http://upd.emule-security.org/ipfilter.zip \
    -o /opt/qbittorrent/config/ipfilter.zip
  7z e /opt/qbittorrent/config/ipfilter.zip \
    -o/opt/qbittorrent/config
  mv /opt/qbittorrent/config/guarding.p2p \
    /opt/qbittorrent/config/ipfilter.dat
  rm /opt/qbittorrent/config/ipfilter.zip
} > "$log_file"
show_file_stat /opt/qbittorrent/config/ipfilter.dat > "$msg_file"
send_tel_msg "$TEL_BOT_KEY" "$TEL_CHAT_ID" "$msg_file"
rm "$msg_file"
