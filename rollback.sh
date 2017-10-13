#!/usr/bin/env bash

set -e

source init.sh

echo 'Set the previous image as latest'
docker tag app:previous app:latest
docker tag app:previous app:new

echo 'Update the green container'
docker-compose up -d green

echo 'Check the green container is ready'
docker-compose run --rm --entrypoint bash green /app/wait-for-it.sh green:80 --timeout=60

./activate.sh 'green' ${gc} ${kv}

echo 'Update the blue container'
docker-compose up -d blue

echo 'Check the blue container is ready'
docker-compose run --rm --entrypoint bash blue /app/wait-for-it.sh blue:80 --timeout=60

./activate.sh 'blue' ${bc} ${kv}

echo 'Stop the green container'
docker-compose stop green
