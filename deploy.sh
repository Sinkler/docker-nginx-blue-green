#!/usr/bin/env bash

set -e

source init.sh

date > app/index.html

echo 'Build the new image'
cd app
docker build . -t app:new
cd ..

echo 'Check the current state'
blue_is_run=$(docker exec blue echo 'yes' 2> /dev/null || echo 'no')

state='blue'
new_state='green'
new_upstream=${green_upstream}
if [[ ${blue_is_run} != 'yes' ]]
then
    state='green'
    new_state='blue'
    new_upstream=${blue_upstream}
fi

echo "Create the app:${new_state} image"
docker tag app:new app:${new_state}

echo "Update the ${new_state} container"
docker-compose up -d ${new_state}

echo "Check the ${new_state} container is ready"
docker-compose run --rm --entrypoint bash ${new_state} /app/wait-for-it.sh ${new_state}:80 --timeout=60

echo 'Check the new app'
status=$(docker-compose run --rm nginx curl ${new_upstream} -o /dev/null -Isw '%{http_code}')
if [[ ${status} != '200' ]]
then
    echo "Bad HTTP response in the ${new_state} app: ${status}"
    ./reset.sh ${key_value_store} ${state}
    exit 1
fi

./activate.sh ${new_state} ${state} ${new_upstream} ${key_value_store}

echo "Set the ${new_state} image as ${state}"
docker tag app:${new_state} app:${state}

echo 'Set the old image as previous'
docker tag app:latest app:previous

echo 'Set the new image as latest'
docker tag app:new app:latest

echo "Stop the ${state} container"
docker-compose stop ${state}
