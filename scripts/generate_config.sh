#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <openwrt-source-dir>" >&2
    exit 1
fi

SRC_DIR="$(realpath "$1")"

if [[ ! -d "${SRC_DIR}" ]]; then
    echo "Source directory not found: ${SRC_DIR}" >&2
    exit 1
fi

cd "${SRC_DIR}"

python3 <<'PY'
from pathlib import Path
import re

config_build = Path("config/Config-build.in")
text = config_build.read_text(encoding="utf-8")
text_new, count = re.subn(
    r"(\n\tconfig IPV6\n)\t+def_bool y\n",
    r"\1\t\tdef_bool n\n",
    text,
    count=1,
)
if count != 1:
    raise SystemExit("Unable to patch config/Config-build.in for IPv6 disable")
config_build.write_text(text_new, encoding="utf-8")
PY

cp -f defconfig/mt7981-ax3000.config .config

python3 <<'PY'
from pathlib import Path

config_path = Path(".config")
lines = config_path.read_text(encoding="utf-8").splitlines()

filtered = []
for line in lines:
    if line.startswith("CONFIG_TARGET_DEVICE_mediatek_mt7981_DEVICE_"):
        continue
    if line.startswith("CONFIG_TARGET_DEVICE_PACKAGES_mediatek_mt7981_DEVICE_"):
        continue
    if line.startswith("CONFIG_TARGET_mediatek_mt7981="):
        continue
    if line.startswith("CONFIG_TARGET_mediatek_filogic="):
        continue
    if line.startswith("CONFIG_TARGET_mediatek_filogic_DEVICE_"):
        continue
    if line.startswith("CONFIG_TARGET_MULTI_PROFILE="):
        continue
    if line.startswith("CONFIG_TARGET_ALL_PROFILES="):
        continue
    filtered.append(line)

filtered.extend(
    [
        "# CONFIG_TARGET_MULTI_PROFILE is not set",
        "# CONFIG_TARGET_ALL_PROFILES is not set",
        "CONFIG_TARGET_PER_DEVICE_ROOTFS=y",
        "CONFIG_TARGET_mediatek_filogic=y",
        "CONFIG_TARGET_mediatek_filogic_DEVICE_cudy_tr3000-v1=y",
        "# CONFIG_PACKAGE_ip6tables-extra is not set",
        "# CONFIG_PACKAGE_ip6tables-nft is not set",
        "# CONFIG_PACKAGE_kmod-ebtables-ipv6 is not set",
        "# CONFIG_PACKAGE_kmod-ip6tables-extra is not set",
        "# CONFIG_PACKAGE_kmod-ipt-raw6 is not set",
        "# CONFIG_PACKAGE_odhcp6c is not set",
        "# CONFIG_PACKAGE_odhcpd is not set",
        "# CONFIG_PACKAGE_odhcpd-ipv6only is not set",
        "CONFIG_PACKAGE_kmod-mii=y",
        "CONFIG_PACKAGE_kmod-usb-net-cdc-ether=y",
        "CONFIG_PACKAGE_kmod-usb-net-cdc-ncm=y",
        "CONFIG_PACKAGE_kmod-usb-net-ipheth=y",
        "CONFIG_PACKAGE_kmod-usb-net-rndis=y",
        "CONFIG_PACKAGE_kmod-usb-wdm=y",
    ]
)

config_path.write_text("\n".join(filtered) + "\n", encoding="utf-8")
PY

make defconfig

grep -E "CONFIG_TARGET_mediatek_filogic_DEVICE_cudy_tr3000-v1|CONFIG_IPV6|CONFIG_PACKAGE_kmod-usb-net-|CONFIG_PACKAGE_kmod-usb-wdm|CONFIG_PACKAGE_kmod-mii" .config || true
