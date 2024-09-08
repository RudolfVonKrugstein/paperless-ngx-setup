#!/bin/env bash

set -e

echo "Load passwords from .env"

# load .env file
set -a
source .env
set +a

# ensure passwords are set
if [ -z "$DB_ROOT_PASSWORD" ]; then
  echo "DB_ROOT_PASSWORD not set"
  exit 1
fi
if [ -z "$PAPERLESS_WORK_DB_PASSWORD" ]; then
  echo "PAPERLESS_WORK_DB_PASSWORD not set"
  exit 1
fi
if [ -z "$PAPERLESS_PRIVATE_DB_PASSWORD" ]; then
  echo "PAPERLESS_PRIVATE_DB_PASSWORD not set"
  exit 1
fi

echo "starting database withdocker-cpomose"
docker-compose up --no-start
docker-compose start db

echo "creating dbs and users"
docker-compose exec -T db psql <<-EOSQL
SELECT 'CREATE DATABASE paperless_work'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'paperless_work')\gexec
EOSQL
docker-compose exec -T db psql <<-EOSQL
SELECT 'CREATE USER paperless_work'
WHERE NOT EXISTS (SELECT FROM pg_user WHERE usename = 'paperless_work')\gexec
EOSQL
docker-compose exec -T db psql <<-EOSQL
ALTER USER paperless_work PASSWORD '${PAPERLESS_WORK_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON DATABASE paperless_work TO paperless_work;
\c paperless_work;
GRANT ALL ON SCHEMA public TO paperless_work;
EOSQL

docker-compose exec -T db psql <<-EOSQL
SELECT 'CREATE DATABASE paperless_private'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'paperless_private')\gexec
EOSQL
docker-compose exec -T db psql <<-EOSQL
SELECT 'CREATE USER paperless_private'
WHERE NOT EXISTS (SELECT FROM pg_user WHERE usename = 'paperless_private')\gexec
EOSQL
docker-compose exec -T db psql <<-EOSQL
ALTER USER paperless_private PASSWORD '${PAPERLESS_PRIVATE_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON DATABASE paperless_private TO paperless_private;
\c paperless_private;
GRANT ALL ON SCHEMA public TO paperless_private;
EOSQL

echo "Stopping the system"

docker-compose down
