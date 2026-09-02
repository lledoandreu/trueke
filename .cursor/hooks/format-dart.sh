#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
import json
import os
import subprocess
import sys

try:
    payload = json.load(sys.stdin)
except json.JSONDecodeError:
    payload = {}

path = (
    payload.get("file_path")
    or payload.get("path")
    or payload.get("filePath")
    or ""
)

if isinstance(path, str) and path.endswith(".dart") and os.path.isfile(path):
    subprocess.run(["dart", "format", path], check=False)
PY

echo '{}'
