#!/bin/env bash

set -e
echo "Testing files for work"
docker compose exec -T webserver-work /scripts/verify-timestamps.sh

echo "Testing files for private"
docker compose exec -T webserver-private /scripts/verify-timestamps.sh
