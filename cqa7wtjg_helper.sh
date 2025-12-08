#!/bin/bash
# oci oralcedb 유휴 방지

source /home/dev/.bashrc
source /home/dev/.local/bin/utils.sh
log_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').log
msg_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').tmp

user=HR
pass=zRNtVDrKAH1PHw3X9N_7MCHUrMMlze
url="'(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1521)(host=adb.ap-seoul-1.oraclecloud.com))(connect_data=(service_name=g0c3c31b1ace251_cqa7wtjg_tpurgent.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))'"
docker run \
  -i --rm --name=instantclient-cqa7wtjg --network=dev --user=0:0 \
  --env-file /opt/instantclient/.env \
  -e TZ=Asia/Seoul \
  -v /opt/instantclient/config/wallet_cqa7wtjg:/opt/oracle/instantclient/network/admin:ro \
  -v /opt/instantclient/data:/data:rw \
  e7hnr8ov/instantclient:ubuntu \
  /bin/bash -c "exit | sqlplus $user/$pass@$url @/data/hr_schema/drop.sql" > "$log_file"
tail -n4 "$log_file" | head -n1 > "$msg_file"

docker run \
  -i --rm --name=instantclient-cqa7wtjg --network=dev --user=0:0 \
  --env-file /opt/instantclient/.env \
  -e TZ=Asia/Seoul \
  -v /opt/instantclient/config/wallet_cqa7wtjg:/opt/oracle/instantclient/network/admin:ro \
  -v /opt/instantclient/data:/data:rw \
  e7hnr8ov/instantclient:ubuntu \
  /bin/bash -c "exit | sqlplus $user/$pass@$url @/data/hr_schema/make.sql" >> "$log_file"
tail -n4 "$log_file" | head -n1 >> "$msg_file"

send_tel_msg "$TEL_BOT_KEY" "$TEL_CHAT_ID" "$msg_file"
rm "$msg_file"
