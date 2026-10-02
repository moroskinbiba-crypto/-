#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Use current libtesla master because old v1.3.x releases are not compatible with
# the current libnx HID API shipped by the devkitPro container.
LIBTESLA_REF="master"

mkdir -p "$ROOT/libs" "$ROOT/include/switch"

if [[ ! -f "$ROOT/libs/libtesla/include/tesla.hpp" ]]; then
  rm -rf "$ROOT/libs/libtesla"
  git clone --depth 1 --branch "$LIBTESLA_REF" https://github.com/WerWolv/libtesla.git "$ROOT/libs/libtesla"
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# dmnt:cht is currently consumed as a small prebuilt static library + header.
# The CI verifies both artifacts before compilation. We print the source commit
# so CI logs retain an audit trail of the fetched dependency.
git clone --depth 1 https://github.com/Insektaure/Shiny-Stash-Live-Map.git "$TMP/dmnt"

echo "dmnt source commit: $(git -C "$TMP/dmnt" rev-parse HEAD)"

install -m 0644 "$TMP/dmnt/lib/libdmntcht.a" "$ROOT/libs/libdmntcht.a"
install -m 0644 "$TMP/dmnt/include/switch/dmntcht.h" "$ROOT/include/switch/dmntcht.h"

test -s "$ROOT/libs/libdmntcht.a"
test -s "$ROOT/include/switch/dmntcht.h"
test -s "$ROOT/libs/libtesla/include/tesla.hpp"

echo "libtesla commit: $(git -C "$ROOT/libs/libtesla" rev-parse HEAD)"
echo "Dependencies ready."
