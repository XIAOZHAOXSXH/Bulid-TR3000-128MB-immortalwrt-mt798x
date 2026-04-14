#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <openwrt-source-dir>" >&2
    exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$(realpath "$1")"

mkdir -p "${SRC_DIR}/files"
rsync -a --delete "${REPO_ROOT}/files/" "${SRC_DIR}/files/"
