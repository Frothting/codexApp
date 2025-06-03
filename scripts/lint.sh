#!/usr/bin/env bash
# simple lint: fail on trailing whitespace in .p8 files
set -e
fail=0
for f in runelite_pico.p8; do
  if grep -nP '\s+$' "$f"; then
    fail=1
  fi
done
if [ $fail -eq 0 ]; then
  echo "lint passed"
else
  echo "lint failed"
  exit 1
fi
