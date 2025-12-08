#!/bin/bash
# bdkqpr0x

source /home/dev/.bashrc
source /home/dev/.local/bin/utils.sh
log_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').log
msg_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').tmp

docker run \
  -i --rm --name=bdkqpr0x --network=dev \
  --add-host=host.docker.internal:host-gateway --user=1000:1000 \
  -e TZ=Asia/Seoul \
  -v /opt/bdkqpr0x/log:/usr/share/java/log:rw \
  -v /opt/bdkqpr0x/data:/usr/share/java/data:rw \
  e7hnr8ov/bdkqpr0x:open-17-jre \
  java -Dspring.profiles.active=prod -Xms2G -Xmx2G \
  -jar /usr/share/java/app.jar \
  --job.name="$1" chunkSize="$2" requestDate="$3" > "$log_file"

echo "--job.name=$1 chunkSize=$2 requestDate=$3" > "$msg_file"
tail -n3 "$log_file" | head -n1 >> "$msg_file" #show count
send_tel_msg "$TEL_BOT_KEY" "$TEL_CHAT_ID" "$msg_file"
rm "$msg_file"
