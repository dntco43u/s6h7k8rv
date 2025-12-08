#!/bin/bash
# py_ai_tel_bot

source /home/dev/.bashrc
source /home/dev/.local/bin/utils.sh

container="py-ai-tel-bot"
docker ps -q --filter "name=$container" | xargs -r docker stop
sleep 1
docker run \
  -i --rm --name="$container" --network=dev --user=0:0 \
  --add-host=host.docker.internal:host-gateway \
  --env-file=/opt/python/.env \
  -v /opt/python/data:/opt/python:rw \
  e7hnr8ov/python:3-slim \
  python /opt/python/ai_tel_bot.py