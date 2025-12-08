#!/bin/bash
# geekbench 벤치마크

source /home/dev/.bashrc
source /home/dev/.local/bin/utils.sh
log_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').log
msg_file=/home/dev/.local/log/$(basename "$0" | sed 's/.sh//').tmp

curl -sL https://raw.githubusercontent.com/masonr/yet-another-bench-script/master/yabs.sh \
  | bash -s -- -bi5 > "$log_file"
{ grep -oE "completed in.*" "$log_file" \
    | sed -E 's/(completed in.)(.*)/Elapsed time: \2/g'
  grep -E "Host\s*:" "$log_file" \
    | sed -E 's/(Host)(\s*)(:.*)/\1\3/g'
  grep -E "Distro\s*:" "$log_file" \
    | sed -E 's/(Distro)(\s*)(:.*)/OS\3/g'
  cpu="$(grep -E "Processor\s*:" "$log_file" \
    | sed -E 's/(Processor)(\s*)(:.*)/CPU\3/g')"
  ram="$(grep -E "RAM\s:*" "$log_file" \
    | sed -E 's/(RAM)(\s*)(:.*)/\1\3/g')"
  disk="$(grep -E "Disk\s*:" "$log_file" \
    | sed -E 's/(Disk)(\s*)(:.*)/\1\3/g')"
  echo "$cpu, $ram, $disk"

  single="$(grep -E "Single Core" "$log_file" \
    | sed -E 's/(Single Core)(\s*\| )([0-9]*)(\s*)/\1: \3/g')"
  multi="$(grep -E "Multi Core" "$log_file" \
    | sed -E 's/(Multi Core)(\s*\| )([0-9]*)(\s*)/\1: \3/g')"
  echo "$single, $multi"

  grep "Read" "$log_file" \
    | tail -n 1 \
    | awk '{ print "1M "$1": "$7" "$8",  IOPS: "$9 }' \
    | sed -E 's/\(|\)//g'
  grep "Write" "$log_file" \
    | tail -n 1 \
    | awk '{ print "1M "$1": "$7" "$8",  IOPS: "$9 }' \
    | sed -E 's/\(|\)//g'
  grep "Read" "$log_file" \
    | head -n 1 \
    | awk '{ print "4K "$1": "$3" "$4",  IOPS: "$5 }' \
    | sed -E 's/\(|\)//g'
  grep "Write" "$log_file" \
    | head -n 1 \
    | awk '{ print "4K "$1": "$3" "$4",  IOPS: "$5 }' \
    | sed -E 's/\(|\)//g'
  grep "Full Test" "$log_file" \
    | sed -E 's/(Full Test)(\s*\| )(.*)/\3/g'
  rm /home/dev/geekbench_claim.url
} > "$msg_file"
send_tel_msg "$TEL_BOT_KEY" "$TEL_CHAT_ID" "$msg_file"
rm "$msg_file"
