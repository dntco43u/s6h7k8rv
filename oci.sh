#!/bin/bash
# oci arm 인스턴스 생성

source /home/dev/.bashrc
source /home/dev/.local/bin/utils.sh
log_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').log

for (( ; ; )); do
  docker run \
    -i --rm --name=oci-capacity --network=dev --user=0:0 \
    -e TZ=Asia/Seoul \
    -v /opt/oci-capacity/config/dev@oci_api_key.pem:/opt/oci-arm-host-capacity/dev@oci_api_key.pem:ro \
    -v /opt/oci-capacity/config/.env:/opt/oci-arm-host-capacity/.env:ro \
    e7hnr8ov/oci-capacity:alpine \
    php82 /opt/oci-arm-host-capacity/index.php > "$log_file"
  sleep 10
done
