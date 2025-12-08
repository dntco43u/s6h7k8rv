#!/bin/bash
# cloudflare ip 갱신

source /home/dev/.bashrc
source /home/dev/.local/bin/utils.sh
log_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').log
msg_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').tmp

{ echo "# Cloudflare real ip" \
    > /opt/nginx/config/conf.d/include/ip-ranges.conf
  for i in $(curl -s -L https://www.cloudflare.com/ips-v4); do
    echo "set_real_ip_from $i;" \
      >> /opt/nginx/config/conf.d/include/ip-ranges.conf
  done
  for i in $(curl -s -L https://www.cloudflare.com/ips-v6); do
    echo "set_real_ip_from $i;" \
      >> /opt/nginx/config/conf.d/include/ip-ranges.conf
  done
} > "$log_file"
show_file_stat /opt/nginx/config/conf.d/include/ip-ranges.conf > "$msg_file"
send_tel_msg "$TEL_BOT_KEY" "$TEL_CHAT_ID" "$msg_file"
rm "$msg_file"
