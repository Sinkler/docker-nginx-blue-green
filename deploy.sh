#!/usr/bin/env bash

set -e

kv=http://localhost:8500/v1/kv/deploy/backend

if [[ "$(docker images -q app:latest 2> /dev/null)" == "" ]]
then
    echo 'Build new app:latest image'
    cd app
    docker build . -t app:latest
    cd ..
fi
if [[ "$(docker images -q app:new 2> /dev/null)" == "" ]]
then
    echo 'Build new app:new image'
    cd app
    docker build . -t app:new
    cd ..
fi
docker exec nginx true 2>/dev/null || docker-compose up -d

date > app/index.html

echo 'Build new image'
cd app
docker build . -t app:new
cd ..

echo 'Update green container'
docker-compose up -d green

echo 'Set green container as working'
curl -X PUT -d 'green' ${kv}

echo 'Check new app'
status=$(curl http://localhost -o /dev/null -Isw '%{http_code}\n')
if [[ ${status} != "200" ]]
then
    echo 'Bad HTTP response:';
    echo ${status};

    echo 'Set blue container as working'
    curl -X PUT -d 'blue' ${kv}

    echo 'Remove new container'
    docker tag app:latest app:new

    exit 1;
fi

echo 'Set old container as previous'
docker tag app:latest app:previous

echo 'Set new container as latest'
docker tag app:new app:latest

echo 'Update blue container'
docker-compose up -d blue

echo 'Set blue container as working'
curl -X PUT -d 'blue' ${kv}

echo 'Stop green container'
docker-compose stop green
