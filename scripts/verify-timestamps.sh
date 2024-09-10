#!/bin/env bash

set -e

shopt -s globstar

for original in $(find /usr/src/paperless/media/documents/originals -type f); do
  echo "Examining $original"
  # get the hash
  export TS_FNAME=$(sha512sum ${original} | awk '{print $1}')

  echo "Testing $original with hash in $TS_FNAME"

  openssl ts \
    -verify \
    -in /usr/src/paperless/timestamps/${TS_FNAME}.tsr \
    -data "$original" \
    -CAfile /scripts/cacert.pem \
    -untrusted /scripts/tsa.crt
done

echo "Done testing all files"
