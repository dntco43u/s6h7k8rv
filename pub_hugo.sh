#!/bin/bash
# hugo clean -> build -> publsh

source /home/dev/.bashrc
source /home/dev/.local/bin/utils.sh

container_name=hugo
hugo_env=$(docker exec -it $container_name hugo version)
hugo_version=$(echo "$hugo_env" | grep -o "hugo v[0-9.]*" | grep -o "[0-9.]*")
if echo "$hugo_env" | grep -q "+extended"; then
  hugo_extended=true
else
  hugo_extended=false
fi

rm -rf /opt/$container_name/data/public/*
cd /opt/$container_name && docker compose rm -f -s && docker compose up -d && docker exec -it $container_name date +"%Z"
sudo tail -fn0 /var/lib/docker/containers/"$(docker inspect --format="{{.Id}}" $container_name)/local-logs/container.log" | \
# 정적 파일 생성까지 대기
while read -r line; do
  echo "$line"
  if [[ "$line" == *"Web Server is available"* ]]; then
    break
  fi
done

echo "HUGO_VERSION=$hugo_version" > /opt/$container_name/data/public/.env
echo "HUGO_EXTENDED=$hugo_extended" >> /opt/$container_name/data/public/.env
cat /opt/$container_name/data/public/.env
cd /opt/$container_name/data/public || exit
#git rm -r --cached .
git add . && git commit -m "update" && git push -u origin main
