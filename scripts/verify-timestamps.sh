#!/bin/env bash

set -e

for original in $(find /usr/src/paperless/media/documents/originals); do
  # get the hash
  export TS_FNAME=$(sha512sum ${original} | awk '{print $1}')

  echo "Testing $orignal with hash in $TS_NAME"

  openssl ts \
    -verify \
    -in /usr/src/paperless/timestamps/${TS_FNAME}.tsr \
    -data "$original" \
    -CAfile /scripts/cacert.pem \
    -untrusted /scripts/tsa.crt
done

echo "Done testing all files"
