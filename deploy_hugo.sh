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

#rm -rf /opt/$container_name/data/public/*
cd /opt/$container_name && docker compose rm -f -s && docker compose up -d && docker exec -it $container_name date +"%Z"
sudo tail -fn0 /var/lib/docker/containers/"$(docker inspect --format="{{.Id}}" $container_name)/local-logs/container.log" | \
# 정적 파일 생성까지 대기
while read -r line; do
  echo "$line"
  if [[ "$line" == *"Web Server is available"* ]]; then
    break
  fi
done

# prod-server에서 참조하도록 dev-server 기준의 .env를 생성
echo "HUGO_VERSION=$hugo_version" > /opt/$container_name/data/.env
echo "HUGO_EXTENDED=$hugo_extended" >> /opt/$container_name/data/.env
cat /opt/$container_name/data/.env

# github pages는 속도를 위해 history 항상 삭제
cd /opt/$container_name/data/public || exit
#git rm -r --cached .
rm -rf .git && git init
git remote add origin git@github.com:dntco43u/dntco43u.github.io.git
git add . && git commit -m "update #$HOSTNAME" && git push -u -f origin main
