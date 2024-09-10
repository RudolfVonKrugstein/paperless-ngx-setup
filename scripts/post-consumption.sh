#!/bin/env bash

set -e

echo "Begin post consumption script"

echo "Creating signing request"
openssl ts \
  -query \
  -data "$DOCUMENT_SOURCE_PATH" \
  -no_nonce \
  -sha512 \
  -cert \
  -out /usr/src/paperless/timestamps/${DOCUMENT_ID}.tsq

echo "Signing"
curl -H "Content-Type: application/timestamp-query" \
  --data-binary "@/usr/src/paperless/timestamps/${DOCUMENT_ID}.tsq" \
  https://freetsa.org/tsr \
  >/usr/src/paperless/timestamps/${DOCUMENT_ID}.tsr

echo "Show timestamp information"
openssl ts -reply \
  -in /usr/src/paperless/timestamps/${DOCUMENT_ID}.tsr \
  -text

echo "Verify it"
openssl ts \
  -verify \
  -in /usr/src/paperless/timestamps/${DOCUMENT_ID}.tsr \
  -data "$DOCUMENT_SOURCE_PATH" \
  -CAfile /scripts/cacert.pem \
  -untrusted /scripts/tsa.crt

echo "End post consumption script"
