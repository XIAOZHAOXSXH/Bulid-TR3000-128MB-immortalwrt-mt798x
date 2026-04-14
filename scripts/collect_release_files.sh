#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <openwrt-source-dir> <output-dir>" >&2
    exit 1
fi

SRC_DIR="$(realpath "$1")"
OUT_DIR="$(realpath -m "$2")"

mkdir -p "${OUT_DIR}"

find "${SRC_DIR}/bin/targets" -type f ! -path '*/packages/*' -exec cp -f {} "${OUT_DIR}/" \;
cp -f "${SRC_DIR}/.config" "${OUT_DIR}/tr3000-128mb.config"
