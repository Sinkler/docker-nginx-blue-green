#!/usr/bin/env bash

set -e

kv=http://localhost:8500/v1/kv/deploy/backend

docker exec nginx true 2>/dev/null || docker-compose up -d

echo 'Set previous container as latest'
docker tag app:previous app:latest
docker tag app:previous app:new

echo 'Update green container'
docker-compose up -d green

echo 'Set green container as working'
curl -X PUT -d 'green' ${kv}

echo 'Update blue container'
docker-compose up -d blue

echo 'Set blue container as working'
curl -X PUT -d 'blue' ${kv}

echo 'Stop green container'
docker-compose stop green
