#!/bin/bash
# 변경된 구성을 반영하기 위한 서비스 재시작

source /home/dev/.bashrc
source /home/dev/.local/bin/utils.sh
log_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').log
msg_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').tmp

{ if [ -d /opt/nginx ]; then
    docker exec -i nginx nginx -s reload
    echo "nginx: $(docker inspect --format '{{json .State.Status}}' nginx \
      | sed 's/"//g')"
  fi

  if [ -d /opt/jenkins/ ]; then
    cd /opt/jenkins || exit
    docker compose rm -f -s && docker compose pull && docker compose up -d
    echo "jenkins: $(docker inspect --format '{{json .State.Status}}' jenkins \
      | sed 's/"//g')"
  fi

  #FIXME: promtail 15:00 종료 원인 파악될 때까지
  if [ -d /opt/promtail ]; then
    cd /opt/promtail || exit
    docker compose rm -f -s && docker compose pull && docker compose up -d
    echo "promtail: $(docker inspect --format '{{json .State.Status}}' promtail \
      | sed 's/"//g')"
  fi

  if [ -d /etc/vsftpd ]; then
    systemctl restart vsftpd.service
    echo "vsftpd.service: $(systemctl is-active vsftpd.service)"
  fi

  systemctl list-units --type service | grep failed | awk '{print $2 ": failed"}'
} > "$log_file"
cp "$log_file" "$msg_file"
send_tel_msg "$TEL_BOT_KEY" "$TEL_CHAT_ID" "$msg_file"
rm "$msg_file"
