#!/usr/bin/env bash

echo 'Set the default container as working'
docker-compose run --rm nginx curl -X PUT -d blue $1 > /dev/null

echo 'Pause'
sleep 10

echo 'Stop the green container'
docker-compose stop green

echo 'Remove the new image'
docker tag app:latest app:new
