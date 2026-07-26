#!/bin/bash

set -e

mkdir -p bin

OS="$(uname -s)"
ARCHITECTURE="$(uname -m)"

case "$ARCHITECTURE" in
  x86_64|amd64)  ARCHITECTURE="x86-64" ;;
  arm64|aarch64) ARCHITECTURE="arm64" ;;
  *)             echo "Unknown architecture: $ARCHITECTURE" >&2 && exit 1 ;;
esac

# The Windows binary deliberately has no .exe extension: the installer at
# primal-lang.org/install.sh downloads bin/primal-windows-<architecture> from the
# release tag and adds the extension locally. Adding it here would break that URL.
case "$OS" in
  Linux*)               OUTPUT="bin/primal-linux-$ARCHITECTURE" ;;
  Darwin*)              OUTPUT="bin/primal-macos-$ARCHITECTURE" ;;
  MINGW*|MSYS*|CYGWIN*) OUTPUT="bin/primal-windows-$ARCHITECTURE" ;;
  *)                    echo "Unknown OS: $OS" >&2 && exit 1 ;;
esac

dart compile exe lib/main/main_cli.dart -o "$OUTPUT"
