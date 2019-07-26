#!/usr/bin/env bash

# pull service
docker-compose \
  -f "./src/main/docker/docker-compose.yml" \
  -f "./src/main/docker/docker-compose-dev.yml" \
  pull
  
# start service
docker-compose -p discovery \
  -f "./src/main/docker/docker-compose.yml" \
  -f "./src/main/docker/docker-compose-dev.yml" \
  up -d