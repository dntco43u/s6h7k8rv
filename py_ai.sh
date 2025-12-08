#!/bin/bash
# py-ai

source /home/dev/.bashrc
source /home/dev/.local/bin/utils.sh

docker run \
  -i --rm --name=py-ai --network=dev --user=0:0 \
  --add-host=host.docker.internal:host-gateway \
  --env-file=/opt/python/.env \
  -v /opt/python/data:/opt/python:rw \
  e7hnr8ov/python:3-slim \
  python /opt/python/ai.py "$@"