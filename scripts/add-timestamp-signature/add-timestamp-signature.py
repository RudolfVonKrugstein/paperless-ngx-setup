#!/bin/env python
import requests
import os
import json
import hashlib
from tsp_client import TSPSigner, TSPVerifier
import base64

sess = requests.Session()
sess.headers.update({"Authorization": "Token xx"})
sess.headers.update({"Accept": "application/json"})
print(sess.headers)

# get the customfield ids
custom_fields_response = sess.get("http://localhost:8000/api/custom_fields/")

custom_fields = {}
for field in custom_fields_response.json()["results"]:
    custom_fields[field["name"]] = field["id"]

assert "timestamp-time" in custom_fields
assert "timestamp-date" in custom_fields
assert "timestamp-server" in custom_fields
assert "timestamp-signature" in custom_fields
assert "timestamp-sha512" in custom_fields

# get the hash of the current document
sha512 = hashlib.sha512()
with open(os.getenv("DOCUMENT_SOURCE_PATH"), "rb") as f:
    while True:
        data = f.read(65536)
        if not data:
            break
        sha512.update(data)

sha512_digest = sha512.digest()

# get the current timestamp signature
signer = TSPSigner()
tsp_signature = signer.sign(message_digest=sha512_digest)
# verify that this worked
verified = TSPVerifier().verify(tsp_signature, message_digest=sha512_digest)
signing_time_dict = next(
    filter(lambda a: a["type"] == "signing_time", verified.signed_attrs)
)
signing_time = signing_time_dict["values"][0]

response = sess.get(f"http://localhost:8000/api/documents/{os.getenv('DOCUMENT_ID')}/")
response.raise_for_status()

current_state = response.json()
doc = dict(
    added=current_state["added"],
    archive_serial_number=current_state["archive_serial_number"],
    archived_file_name=current_state["archived_file_name"],
    content=current_state["content"],
    correspondent=current_state["correspondent"],
    created_date=current_state["created_date"],
    custom_fields=current_state.get("custom_fields", [])
    + [
        {
            "field": custom_fields["timestamp-sha512"],
            "value": base64.b64encode(sha512_digest).decode(),
        },
        {
            "field": custom_fields["timestamp-signature"],
            "value": base64.b64encode(tsp_signature).decode(),
        },
        {
            "field": custom_fields["timestamp-time"],
            "value": int(signing_time.timestamp()),
        },
        {
            "field": custom_fields["timestamp-date"],
            "value": signing_time.strftime("%Y-%m-%d"),
        },
    ],
    deleted_at=current_state["deleted_at"],
    document_type=current_state["document_type"],
    id=current_state["id"],
    modified=current_state["modified"],
    notes=current_state["notes"],
    original_file_name=current_state["original_file_name"],
    owner=current_state["owner"],
    storage_path=current_state["storage_path"],
    tags=current_state["tags"],
    title=current_state["title"],
)

print(json.dumps(doc))

response = sess.put(
    f"http://localhost:8000/api/documents/{os.getenv('DOCUMENT_ID')}/", json=doc
)
response.raise_for_status()
