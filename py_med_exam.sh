#!/bin/bash
# py_med_exam

source /home/dev/.bashrc
source /home/dev/.local/bin/utils.sh

container="py-med-exam"
docker ps -q --filter "name=$container" | xargs -r docker stop
sleep 1
docker run \
  -i --rm --name="$container" --network=dev --user=0:0 \
  --add-host=host.docker.internal:host-gateway \
  --env-file=/opt/python/.env \
  -v /home/dev/workspace/med_exam:/opt/python:rw \
  e7hnr8ov/python:3-slim \
  python /opt/python/med_exam.py "$@"