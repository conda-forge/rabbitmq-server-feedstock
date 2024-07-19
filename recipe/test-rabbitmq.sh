#!/bin/bash
set -e
trap 'kill $(jobs -p)' SIGINT SIGTERM EXIT

# Remove a conda build environment variable that will
# otherwise be picked up as RabbitMQ configuration file
unset CONFIG_FILE

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
# TODO: Health-check
# https://www.rabbitmq.com/docs/monitoring#health-checks
echo
echo Shutdown:
rabbitmqctl stop
wait

trap - EXIT
