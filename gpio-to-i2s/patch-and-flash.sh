#!/usr/bin/env bash

set -e

# Required Linux_for_tegra folder path ...
if [ -z "$1" ]; then
    echo "Pass Linux_for_Tegra folder location"
    exit -1
fi
LFT="$1"

# Check that patch exists ...
BASE=$(dirname "${BASH_SOURCE}")
DTS_PATCH="${BASE}/01-p3448-0000-a02-gpio-to-i2s.patch"

if ! [ -f "${DTS_PATCH}" ]; then
    echo "Missing (DTS) patch at ${DTS_PATCH}"
    exit -1
fi

# Check DTC & DTB existence ...
DTC="${LFT}/kernel/dtc"
DTB="${LFT}/kernel/dtb/tegra210-p3448-0000-p3449-0000-a02.dtb"
DTB_BASE=$(dirname "${DTB}")
DTS="${LFT}/kernel/dtb/tegra210-p3448-0000-p3449-0000-a02.dts"

if ! [ -f "${DTC}" ]; then
    echo "Missing device tree compiler at ${DTC}"
    exit -1
fi

if ! [ -f "${DTB}" ]; then
    echo "Missing (DTB) at ${DTB}"
    exit -1
fi

# Decompile, patch & compile
echo "Decompiling DTS ..."
${DTC} -I dtb -O dts -o ${DTS} ${DTB}
echo "Patching DTS ..."
patch ${DTS} < ${DTS_PATCH}
echo "Compiling DTS ..."
${DTC} -I dts -O dtb -o ${DTB} ${DTS}
echo "DTS compiled"

# Ask if we should flash
read -p "Do you want to flash it now?" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
CUR_PWD=$(pwd)
cd ${LFT}
sudo ./flash.sh --no-systemimg -k DTB jetson-nano-qspi-sd mmcblk0p1
cd ${CUR_PWD}
fi

echo "Done, happy I2S & SPI!"
