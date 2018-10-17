#!/usr/bin/env bash

set -e

new_state=$1
old_state=$2
new_upstream=$3
key_value_store=$4
was_state=$(docker-compose run --rm nginx curl ${key_value_store}?raw)

pid_was=$(docker exec nginx pidof nginx 2> /dev/null || echo '-')
echo "Activate the ${new_state} container, old Nginx pids: ${pid_was}"

echo "Set the ${new_state} container as working"
docker-compose run --rm nginx curl -X PUT -d ${new_state} ${key_value_store} > /dev/null

if [[ ${pid_was} != '-' ]]
then
    echo 'Check that config was reloaded'
    count=0
    while [ 1 ]
    do
        lines=$(docker exec nginx nginx -T | grep ${new_upstream} | wc -l | xargs)
        if [[ ${lines} == '0' ]]
        then
            count=$((count + 1))
            if [[ ${count} -eq 10 ]]
            then
                echo 'Timeout'
                ./reset.sh ${key_value_store} ${old_state}
                exit 1
            fi
            echo 'Wait for the new configuration'
            sleep 3
        else
            echo 'The new configuration was loaded'
            break
        fi
    done

    if [[ ${was_state} != ${new_state} ]]
    then
        echo 'Check that Nginx was reload'
        count=0
        while [ 1 ]
        do
            pid=$(docker exec nginx pidof nginx)
            if [[ ${pid} == ${pid_was} ]]
            then
                count=$((count + 1))
                if [[ ${count} -eq 10 ]]
                then
                    echo 'Timeout'
                    ./reset.sh ${key_value_store} ${old_state}
                    exit 1
                fi
                echo "Wait for reloading, pids: ${pid}"
                sleep 3
            else
                echo "Nginx was reloaded, new pids: ${pid}"
                break
            fi
        done
    fi
fi
