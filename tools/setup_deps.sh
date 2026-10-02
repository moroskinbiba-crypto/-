#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# libtesla 1.3.3 is an old, stable Tesla API. Pair it with the libnx 4.9.x ABI
# used by many known Tesla overlays instead of mixing it with current libnx HID APIs.
LIBTESLA_REF="v1.3.3"
LIBNX_REF="v4.9.0"

mkdir -p "$ROOT/libs" "$ROOT/include/switch"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Build/install a matching libnx instead of using whatever version the
# container currently ships. This keeps the legacy libtesla API compatible.
rm -rf "$TMP/libnx"
git clone --depth 1 --branch "$LIBNX_REF" https://github.com/switchbrew/libnx.git "$TMP/libnx"
make -C "$TMP/libnx" -j2
make -C "$TMP/libnx" install

if [[ ! -f "$ROOT/libs/libtesla/include/tesla.hpp" ]]; then
  rm -rf "$ROOT/libs/libtesla"
  git clone --depth 1 --branch "$LIBTESLA_REF" https://github.com/WerWolv/libtesla.git "$ROOT/libs/libtesla"
fi

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
