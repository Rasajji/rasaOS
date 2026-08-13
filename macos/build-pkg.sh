#!/usr/bin/env bash
# Build a macOS one-click installer: install/RasaOS-<version>.pkg
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STAGE="$ROOT/install/scripts/stage.sh"
PKG_SRC="$ROOT/install/payload"
VERSION="$(grep '^version' "$ROOT/Cargo.toml" | head -1 | cut -d'"' -f2)"

bash "$STAGE" /usr/local

ARCH="$(uname -m)"
OUT="$ROOT/install/RasaOS-${VERSION}-macos-${ARCH}.pkg"

pkgbuild --identifier io.rasa.os \
  --version "$VERSION" \
  --root "$PKG_SRC" \
  --scripts "$ROOT/install/macos" \
  "$OUT"

echo "built: $OUT"
echo "double-click to install (components under /usr/local/bin + /usr/local/share/rasa)"