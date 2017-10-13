#!/usr/bin/env bash

set -e

source init.sh

echo 'Set the previous image as latest'
docker tag app:previous app:latest
docker tag app:previous app:new

echo 'Update the green container'
docker-compose up -d green

./activate.sh 'green' ${gc} ${kv}

echo 'Update the blue container'
docker-compose up -d blue

./activate.sh 'blue' ${bc} ${kv}

echo 'Stop the green container'
docker-compose stop green
