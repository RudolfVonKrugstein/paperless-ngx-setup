#!/bin/env bash

set -e
docker compose exec -T webserver-work /scripts/verify-timestamps.sh
docker compose exec -T webserver-private /scripts/verify-timestamps.sh
