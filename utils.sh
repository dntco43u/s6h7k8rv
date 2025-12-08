#!/bin/sh
# 공통 함수
# Dependency packages:
#   rhel    bc
#   dsm     bc
#   openwrt bc, coreutils-numfmt, coreutils-date

########################################
# error 출력
# Arguments:
#   *
########################################
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S')] $*" >&2
}

########################################
# 두 날짜 사이의 유효 날짜 반환
# Arguments:
#   old_date
#   new_date
# Outputs:
#   yyyymmdd
########################################
get_valid_dates() {
  old_date="$1"
  new_date="$2"
  for i in $(seq -w "$old_date" "$new_date"); do
    date -d "$i" +%Y%m%d 2> /dev/null
  done
}

########################################
# 상태 표시줄 출력
# Arguments:
#   current
#   total
#   unit
########################################
show_progress_bar() {
  bar_size=18
  current="$1"
  total="$2"
  unit="$3"
  percent=$(echo "scale=2; 100 * $current / $total" | bc)
  done=$(echo "scale=0; $bar_size * $percent / 100" | bc)
  todo=$(echo "scale=0; $bar_size - $done" | bc)
  done_sub_bar=$(printf "%${done}s" | sed 's/ /█/g')
  todo_sub_bar=$(printf "%${todo}s" | sed 's/ /▒/g')
  if [ "$unit" = "%" ]; then
    printf "%s\n" "${done_sub_bar}${todo_sub_bar} ${percent}${unit}"
  else
    printf "%s\n" "${done_sub_bar}${todo_sub_bar} ${current}/${total}${unit}"
  fi
}

########################################
# stat 요약 출력
# Arguments:
#   file_path
########################################
show_file_stat() {
  file_path="$1"
  file_info=$(stat --printf="%n,%s,%y" "$file_path")
  if [ -z "$file_info" ]; then
    err "FILE NOT FOUND"
    printf "%s\n" "File not found"
    return 1
  fi
  file_info_name=$(basename "$(echo "$file_info" | cut -d ',' -f1)")
  file_info_size=$(numfmt --to=iec "$(echo "$file_info" | cut -d ',' -f2)")"B"
  file_info_mtime=$(echo "$file_info" | cut -d ',' -f3)
  file_info_mtime=$(echo "$file_info_mtime" | cut -d '.' -f1)
  printf "%s\n" "$file_info_name: $file_info_size, $file_info_mtime"
}

########################################
# df 요약 출력
# Arguments:
#   disk_path
########################################
show_disk_stat() {
  disk_path="$1"
  # disk_path 뒤 공백 추가, 앞자리가 동일한 경우
  disk_info=$(df | grep "$disk_path " | awk '{print $1","$2","$3}')
  if [ -z "$disk_info" ]; then
    err "DISK NOT FOUND"
    printf "%s\n" "Disk not found"
    return 1
  fi
  disk_info_filesystem=$(echo "$disk_info" | cut -d ',' -f1)
  disk_info_size=$(($(echo "$disk_info" | cut -d ',' -f2) * 1024))
  disk_info_used=$(($(echo "$disk_info" | cut -d ',' -f3) * 1024))
  disk_info_size_iec=$(numfmt --to=iec "$disk_info_size")"B"
  disk_info_used_iec=$(numfmt --to=iec "$disk_info_used")"B"
  printf "%s\n" "$disk_info_filesystem: $disk_info_used_iec/$disk_info_size_iec"
  show_progress_bar "$disk_info_used" "$disk_info_size" "%"
}

########################################
# telegram 전송
# Arguments:
#   telegram_bot_key
#   telegram_chat_id
########################################
send_tel_msg() {
  telegram_bot_key="$1"
  telegram_chat_id="$2"
  msg_file="$3"
  if [ -z "$(cat "$msg_file")" ]; then
    err "NO MESSAGES"
    return 1
  fi
  msg_head="<b>$0<\/b>\n"
  sed -i "1s|^|$msg_head|g" "$msg_file"
  msg=$(< "$msg_file" head -c 4096)
  curl \
    --data parse_mode=HTML \
    --data disable_web_page_preview=True \
    --data chat_id="$telegram_chat_id" \
    --data-urlencode text="$msg" \
    https://api.telegram.org/bot"$telegram_bot_key"/sendMessage
}

########################################
# secret 마스킹
# Arguments:
#   secret
#   unmask_len
# Outputs:
#   unmasked secret + masked secret
########################################
show_secret() {
  secret="$1"
  unmask_len="$2"
  secret_len=$(("${#secret}" - "$unmask_len"))
  left="$(echo "$secret" | sed -E "s/(\S{0,$unmask_len})(.*)/\1/g")"
  right="$(printf "%${secret_len}s" | sed 's/ /*/g')"
  echo "$left$right"
}

########################################
# 날짜명 기준 이후 file/dir 삭제
# Arguments:
#   base_date
#   base_path
#   cut_option
########################################
delete_over_date() {
  base_date="$1"
  base_path="$2"
  cut_option="$3"
  dates=$(find "$base_path"/ -mindepth 1 -maxdepth 1 -exec basename {} \; \
    | $cut_option)
  for d in $dates; do
    if [ "$base_date" -gt "$d" ]; then
      path="$base_path/$d"
      rm -rf "${path:?}"*
    fi
  done
}

########################################
# user 복사
# Arguments:
#   src_user
#   dest_user
########################################
copy_user() {
  src_user="$1"
  dest_user="$2"
  src_groups=$(id -Gn "$src_user" | sed "s/ /,/g" \
    | sed -r "s/\<$src_user\>\b,?//g")
  src_shell=$(awk -F : -v name="$src_user" '(name == $1) { print $7 }' \
    /etc/passwd)
  useradd --groups "$src_groups" --shell "$src_shell" --create-home "$dest_user"
  passwd "$dest_user"
}

########################################
# 무작위 문자열 생성
# Arguments:
#   len
########################################
rand_string() {
  len="$1"
  tr -dc A-Za-z0-9 </dev/urandom | head -c "$len"
}
