#!/usr/bin/env bash

pid_was=$(docker exec nginx pidof nginx)
echo "Activate the ${1} container, old Nginx pids: ${pid_was}"

echo "Set the ${1} container as working"
docker-compose run --rm nginx curl -X PUT -d $1 $3 > /dev/null

echo 'Check that config was reloaded'
count=0
while [ 1 ]
do
    lines=$(docker exec nginx nginx -T | grep $2 | wc -l | xargs)
    if [[ ${lines} == '0' ]]
    then
        count=$((count + 1))
        if [[ ${count} -eq 10 ]]
        then
            echo 'Timeout'
            ./reset.sh $3
            exit 1
        fi
        echo 'Wait for the new configuration'
        sleep 3
    else
        echo 'The new configuration was loaded'
        break
    fi
done

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
            ./reset.sh $3
            exit 1
        fi
        echo "Wait for reloading, pids: ${pid}"
        sleep 3
    else
        echo "Nginx was reloaded, new pids: ${pid}"
        break
    fi
done
