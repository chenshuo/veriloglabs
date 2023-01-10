#!/bin/sh

QUARTUS="$HOME/intelFPGA_lite/22.1std/quartus/bin"

FAMILY=${FAMILY:-"Cyclone IV E"}
TOP=$1

set -x

"$QUARTUS/quartus_map" --family "$FAMILY" $TOP
"$QUARTUS/quartus_fit" $TOP
"$QUARTUS/quartus_asm" $TOP
"$QUARTUS/quartus_sta" $TOP
