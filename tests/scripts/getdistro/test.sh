#!/bin/sh

# nvim/tests/scripts/getdistro/test.sh

set -eu

SCRIPT_DIR="$(cd -- "$(dirname -- "${0}")" >/dev/null 2>&1 && pwd)"
NVIM_DIR="${SCRIPT_DIR}/../../.."

echo "Running test suite for getdistro..."
docker build \
  --build-arg NVIM_DIR="${NVIM_DIR}" \
  --no-cache \
  -t test-getdistro \
  -f "${SCRIPT_DIR}/Dockerfile" \
  "${NVIM_DIR}"

