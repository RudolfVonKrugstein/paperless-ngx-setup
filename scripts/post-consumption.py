#!/bin/env python
import requests
import os
from dotenv import load_dotenv
import json

load_dotenv()

sess = requests.Session()
sess.headers.update({"Authorization": "Token c71b424f44926fbb4ed8cc9dc5af29867f1fa697"})
sess.headers.update({"Accept": "application/json"})
print(sess.headers)

# get the customfield ids
custom_fields_response = sess.get("http://localhost:8000/api/custom_fields/")

print(custom_fields_response.json())

custom_fields = {}
for field in custom_fields_response.json()["results"]:
    custom_fields[field["name"]] = field["id"]

assert "timestamp-time" in custom_fields
assert "timestamp-date" in custom_fields
assert "timestamp-server" in custom_fields
assert "timestamp-signature" in custom_fields

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
    + [{"field": custom_fields["timestamp-time"], "value": 202}],
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
