#!/bin/bash
set -e
trap 'kill $(jobs -p)' SIGINT SIGTERM EXIT

echo ------------------------------------------
echo Environment:
set
echo ------------------------------------------

rabbitmq-server &

WAIT=1
while [ $WAIT -lt 10 ]; do
  sleep 1
  rabbitmqctl await_startup --timeout=5 && break || echo "Waiting for RabbitMQ to start... ($WAIT)"
  let WAIT=WAIT+1
done

if [ $WAIT -eq 10 ]; then
  echo
  echo RabbitMQ did not start up as expected
  exit 1
else
  echo RabbitMQ started successfully.
fi

echo
echo Ping:
rabbitmqctl ping
echo
echo Status:
rabbitmqctl status
echo
echo Node health check:
rabbitmqctl node_health_check
echo
echo Shutdown:
rabbitmqctl stop
wait

trap - EXIT
