#!/usr/bin/env bash

set -e

source init.sh

date > app/index.html

echo 'Build the new image'
cd app
docker build . -t app:new
cd ..

echo 'Update the green container'
docker-compose up -d green

echo 'Check the green container is ready'
docker-compose run --rm --entrypoint bash green /app/wait-for-it.sh green:80 --timeout=60

echo 'Check the new app'
status=$(docker-compose run --rm nginx curl ${gc} -o /dev/null -Isw '%{http_code}')
if [[ ${status} != '200' ]]
then
    echo "Bad HTTP response in the green app: ${status}"
    ./reset.sh
    exit 1
fi

./activate.sh 'green' ${gc} ${kv}

echo 'Set the old image as previous'
docker tag app:latest app:previous

echo 'Set the new image as latest'
docker tag app:new app:latest

echo 'Update the blue container'
docker-compose up -d blue

echo 'Check the blue container is ready'
docker-compose run --rm --entrypoint bash blue /app/wait-for-it.sh blue:80 --timeout=60

./activate.sh 'blue' ${bc} ${kv}

echo 'Stop the green container'
docker-compose stop green
