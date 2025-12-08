#!/bin/bash
# 디스크 정리

source /home/dev/.bashrc
source /home/dev/.local/bin/utils.sh
log_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').log
msg_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').tmp

disk="$1"
days="$2"
if [ -z "$disk" ] || [ -z "$days" ]; then
  err "MANDATORY PARAMETER MISSING"
  exit 1
fi
{ #$days 이상 지난 log 삭제
  varlog_cnt=$(find /var/log/ -type f -mtime +"$days" | wc -l)
  usrlog_cnt=$(find /home/dev/.local/log/ -type f -mtime +"$days" | wc -l)
  docker_cnt=$(find /opt/ -type f \
    -regex ".*\.\(log\|log\.[0-9]*.*\|log\.bak.*\)" \
    -mtime +"$days" | wc -l)
  find /var/log/ -type f -mtime +"$days" -exec rm {} \;
  find /home/dev/.local/log/ -type f -mtime +"$days" -exec rm {} \;
  find /opt/ -type f \
    -regex ".*\.\(log\|log\.[0-9]*.*\|log\.bak.*\)" \
    -mtime +"$days" -exec rm {} \;

  #docker code-server 디렉토리 로그 삭제
  if [ -d /opt/code-server ]; then
    base_date=$(date +%Y%m%d -d "$days day ago")
    delete_over_date "$base_date" "/opt/code-server/config/data/logs" \
      "cut -c 1-8"
  fi

  #docker 미사용 이미지 삭제
  read -ra args < <(docker images -q -f dangling=true)
  docker rmi "${args[@]}"
  
  #prrometheus wal 삭제 (임시)
  #rm -rf /opt/prometheus/data/wal/*
  #rm -rf /opt/prometheus/data/chuncks_head/*  
  #nginx log 삭제 (임시)
  truncate -s 0 /opt/nginx/log/*.log

  #xfs 조각 모음
  /usr/sbin/xfs_fsr "$disk";
  /usr/sbin/hdparm -Tt "$disk"
} > "$log_file"

{ echo "$disk"
  #xfs 조각화 수준 검사
  /usr/sbin/xfs_db -c frag -r "$disk" | grep -o "fragmentation factor.*" \
    | sed -E 's/(fragmentation) (factor) (.*)/\1: \3/g'
  grep "reads" "$log_file" -a \
    | sed -E 's/^(.*)(cached|disk)( reads: )(.* = )(.*)/\2\3\5/g' \
    | sed 's/  */ /g'
  echo "mtime +$days logs: $(("$docker_cnt"+"$varlog_cnt"+"$usrlog_cnt"))"
} > "$msg_file"
send_tel_msg "$TEL_BOT_KEY" "$TEL_CHAT_ID" "$msg_file"
rm "$msg_file"
