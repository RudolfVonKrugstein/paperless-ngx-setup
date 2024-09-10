#!/bin/env bash

set -e

echo "Begin post consumption script"

echo "Get the timestamp filename"
# we use the sha512 for the timestamp file name,
# because all other names may change.
export TS_FNAME=$(sha512sum ${DOCUMENT_SOURCE_PATH} | awk '{print $1}')

echo "Creating signing request"
openssl ts \
  -query \
  -data "$DOCUMENT_SOURCE_PATH" \
  -no_nonce \
  -sha512 \
  -cert \
  -out /usr/src/paperless/timestamps/${TS_FNAME}.tsq

echo "Signing"
curl -H "Content-Type: application/timestamp-query" \
  --data-binary "@/usr/src/paperless/timestamps/${TS_FNAME}.tsq" \
  https://freetsa.org/tsr \
  >/usr/src/paperless/timestamps/${TS_FNAME}.tsr

echo "Show timestamp information"
openssl ts -reply \
  -in /usr/src/paperless/timestamps/${TS_FNAME}.tsr \
  -text

echo "Verify it"
openssl ts \
  -verify \
  -in /usr/src/paperless/timestamps/${TS_FNAME}.tsr \
  -data "$DOCUMENT_SOURCE_PATH" \
  -CAfile /scripts/cacert.pem \
  -untrusted /scripts/tsa.crt

echo "End post consumption script"
