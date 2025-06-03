#!/usr/bin/env bash
# naive token counter for PICO-8 carts
set -e
file=${1:-runelite_pico.p8}
# extract lua section
lua=$(awk '/__lua__/ {flag=1; next} /__gfx__/ {flag=0} flag {print}' "$file")
count=$(echo "$lua" | wc -w)
echo "token count for $file: $count"
