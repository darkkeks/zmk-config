#!/bin/bash

set -e

ZMK_CONFIG_ROOT=$(pwd)
ZMK_ROOT=$(pwd)/../zmk

MATRIX_FILE=$ZMK_CONFIG_ROOT/build.yaml

export ZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb
export GNUARMEMB_TOOLCHAIN_PATH=/usr/local/Cellar/arm-gcc-bin\@8/8-2019-q3-update_3/

function matrix {
    yq -r '.include[] | (.board + " " + .shield)' "$MATRIX_FILE"
}

mkdir -p "$ZMK_CONFIG_ROOT/build"

matrix | while read -r board shield; do
    echo Building board=$board shield=$shield ...
    (cd "$ZMK_ROOT"; west build -s app -d "build/$board/$shield" -b "$board" -- -DSHIELD="$shield" -DZMK_CONFIG="$ZMK_CONFIG_ROOT/config")
    cp "$ZMK_ROOT/build/$board/$shield/zephyr/zmk.uf2" "$ZMK_CONFIG_ROOT/build/$board-$shield.uf2"
done 
