#!/usr/bin/env bash

kv=http://consul:8500/v1/kv/deploy/backend
bc=http://blue
gc=http://green

if [[ $(docker images -q app:latest 2> /dev/null) == '' ]]
then
    echo 'Build a new app:latest image'
    cd app
    docker build . -t app:latest
    cd ..
fi
if [[ $(docker images -q app:new 2> /dev/null) == '' ]]
then
    echo 'Build a new app:new image'
    cd app
    docker build . -t app:new
    cd ..
fi
docker exec nginx true 2>/dev/null || docker-compose up -d
