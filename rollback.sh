#!/usr/bin/env bash

set -e

source init.sh

echo 'Set the previous image as latest'
docker tag app:previous app:latest
docker tag app:previous app:new

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

./activate.sh ${new_state} ${state} ${new_upstream} ${key_value_store}

echo "Set the ${new_state} image as ${state}"
docker tag app:${new_state} app:${state}

echo "Stop the ${state} container"
docker-compose stop ${state}
