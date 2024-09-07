#!/bin/env bash

echo "Begin post consumption script"

echo "Install pipx"
python -m pip install --user -U pipx
export PATH="$PATH:$HOME/.local/bin"
pipx ensurepath

echo "Install poetry"
pipx install poetry

cd "$(dirname "$0")/add-timestamp-signature"
poetry install
poetry run python add-timestamp-signature.py

echo "End post consumption script"
