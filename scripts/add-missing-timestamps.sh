#!/bin/env bash

set -e

echo "Timestamping all files, that dont have a timestamp yet"

for original in $(find /usr/src/paperless/media/documents/originals -type f); do
  echo "Examining $original"
  # get the hash
  export TS_FNAME=$(sha512sum ${original} | awk '{print $1}')

  echo "Testing $original with hash in $TS_FNAME"
  export FULL_TS_PATH="/usr/src/paperless/timestamps/${TS_FNAME}.tsr"

  if [ -f "$FULL_TS_PATH" ]; then
    echo "Timestamp for $orignal exists!"
  else
    echo "Timestamp for $orignal does not exists, creating it now!"
    DOCUMENT_SOURCE_PATH=$original /scripts/post-consumption.sh
  fi
done

echo "Done timestamping all files"
