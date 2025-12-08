#!/bin/bash
# py_inven_helper

source /home/dev/.bashrc
source /home/dev/.local/bin/utils.sh
log_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').log
msg_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').tmp

for ((i=1; i<=2; i++)); do
  docker run \
    -i --rm --name=py-inven-helper --network=dev --user=0:0 \
    --env-file=/opt/python/.env \
    -v /home/dev/workspace/inven_helper/inven_helper.py:/data/inven_helper.py:rw \
    e7hnr8ov/python:3-slim \
    python /data/inven_helper.py > "$log_file"
  cp "$log_file" "$msg_file"
  send_tel_msg "$TEL_BOT_KEY" "$TEL_CHAT_ID" "$msg_file"
  rm "$msg_file"
  sleep 5
done
