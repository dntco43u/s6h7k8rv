#!/bin/bash
# .dpasswd 파일 생성

source /home/dev/.bashrc
source /home/dev/.local/bin/utils.sh
log_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').log
msg_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').tmp

db_yn="$1" #db 연계 생성 여부
if [ -z "$db_yn" ]; then
  err "MANDATORY PARAMETER MISSING"
  exit 1
fi

#.dpasswd 하루 1회 생성
file_mtime=$(stat --printf="%y" /home/dev/.local/etc/.dpasswd)
file_date=$(cut -c 1-10 <<< "$file_mtime" | sed 's/-//g')
if [[ $(date +%Y%m%d) == "$file_date" ]]; then
  echo "GENERATED ONLY ONCE PER DAY"
  exit 0
fi
mv /home/dev/.local/etc/.dpasswd "/home/dev/.local/etc/.dpasswd-$file_date"

if [ "$db_yn" == Y ]; then
  docker run \
    -i --rm --name=instantclient-icnex2pa --network=dev --user=0:0 \
    --env-file /opt/instantclient/.env \
    -e TZ=Asia/Seoul \
    -v /opt/instantclient/data:/data:rw \
    e7hnr8ov/instantclient:ubuntu \
    python3 /data/icnex2pa.py > .dpasswd.tmp
  sed 's/key=//g' .dpasswd.tmp | sed -z 's/\n//g' > /home/dev/.local/etc/.dpasswd
  rm .dpasswd.tmp
else
  rand_string 64 > /home/dev/.local/etc/.dpasswd
fi
echo "Secret key updated" > "$log_file"
show_secret "$(< /home/dev/.local/etc/.dpasswd)" 8 >> "$log_file"

#backup to sj9n7air-ftp
if [ -f "/home/dev/.local/etc/.dpasswd-$file_date" ]; then
  rclone copy \
    --config /home/dev/.config/rclone/rclone.conf \
    --log-file /home/dev/.local/log/rclone_dpasswd.log --log-level DEBUG \
    "/home/dev/.local/etc/.dpasswd-$file_date" \
    sj9n7air-ftp:/mnt/d2/backups/fhy8vp3u/etc
fi
rm /home/dev/.local/etc/.dpasswd-*

echo "key=$(< /home/dev/.local/etc/.dpasswd)" > "$msg_file"
send_tel_msg "$TEL_BOT_KEY" "$TEL_CHAT_ID" "$msg_file"
rm "$msg_file"
