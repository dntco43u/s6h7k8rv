#!/bin/bash
# geoip2 데이터베이스 갱신

source /home/dev/.bashrc
source /home/dev/.local/bin/utils.sh
log_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').log
msg_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').tmp

docker run \
  -i --rm --name=geoipupdate --network=dev --user=0:0 \
  --env-file /opt/geoipupdate/.env \
  -e GEOIPUPDATE_EDITION_IDS="GeoLite2-Country" \
  -v /opt/geoipupdate/data:/usr/share/GeoIP:rw \
  maxmindinc/geoipupdate:latest > "$log_file"
show_file_stat /opt/geoipupdate/data/GeoLite2-Country.mmdb > "$msg_file"
send_tel_msg "$TEL_BOT_KEY" "$TEL_CHAT_ID" "$msg_file"
rm "$msg_file"
