#!/bin/bash
# immich-go로 로컬 폴더에서 immich 서버로 업로드
source /home/dev/.bashrc
source /home/dev/.local/bin/utils.sh
log_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').log
msg_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').tmp

WORK_DIR="$1"
cat /dev/null > "$log_file"
flock -n /tmp/immich-go.lock \
  /usr/local/bin/immich-go upload from-folder \
    --no-ui \
    --skip-verify-ssl \
    --server http://localhost:2283 \
    --api-key 46N2SwhdMBzbc95uER8YULIeGSyLEpK8VMvjc6A9C4 \
    --log-file="$log_file" \
    "$WORK_DIR"
touch "$msg_file"
{ grep -oE "uploaded\s*:\s*[0-9]*" "$log_file" | sed 's/  */ /g'
  grep -oE "upload error\s*:\s*[0-9]*" "$log_file" | sed 's/  */ /g'
  grep -oE "file not selected\s*:\s*[0-9]*" "$log_file" | sed 's/  */ /g'
  grep -oE "server's asset upgraded with the input\s*:\s*[0-9]*" "$log_file" | sed  's/  */ /g'
  grep -oE "server has same asset\s*:\s*[0-9]*" "$log_file" | sed 's/  */ /g'
  grep -oE "server has a better asset\s*:\s*[0-9]*" "$log_file" | sed 's/  */ /g'
} >> "$msg_file"

# 마이그레이션된 파일 갯수가 일치하면 원본 삭제
file_cnt=$(find "$WORK_DIR" -type f | wc -l)
dup_cnt=$(grep -oE "server has same asset\s*:\s*[0-9]*" "$log_file" | grep -oE "[0-9]*")
if [[ $file_cnt -gt 0 && $file_cnt -eq $dup_cnt ]]; then
  if [ ! -d /tmp/immich-go ]; then
    mkdir -p /tmp/immich-go
  fi
  mv -f "$WORK_DIR"/* /tmp/immich-go
  rm -rf /tmp/immich-go
  sed -i "1i\Deletion of files ($file_cnt) successfully migrated completed" "$msg_file"
  send_tel_msg "$TEL_BOT_KEY" "$TEL_CHAT_ID" "$msg_file"
fi
rm "$msg_file"