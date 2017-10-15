#!/usr/bin/env bash

key_value_store=http://consul:8500/v1/kv/deploy/backend
blue_upstream=http://blue
green_upstream=http://green

if [[ $(docker images -q app:latest 2> /dev/null) == '' ]]
then
    echo 'Build a new app:latest image'
    cd app
    docker build . -t app:latest
    cd ..
fi

if [[ $(docker images -q app:previous 2> /dev/null) == '' ]]
then
    echo 'Build a new app:previous image'
    cd app
    docker build . -t app:previous
    cd ..
fi

if [[ $(docker exec nginx echo 'yes' 2> /dev/null) == '' ]]
then
    docker tag app:latest app:blue
    docker tag app:latest app:green
    docker-compose up -d
fi
