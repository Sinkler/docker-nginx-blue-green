#!/usr/bin/env bash

set -e

key_value_store=$1
state=$2

echo 'Set the previous container as working'
docker-compose run --rm nginx curl -X PUT -d ${state} ${key_value_store} > /dev/null

echo 'Stop the ${old_state} container'
docker-compose stop ${state}

echo 'Remove the new image'
docker tag app:latest app:new
