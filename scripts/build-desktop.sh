#!/bin/bash

set -e

mkdir -p output

OS="$(uname -s)"
case "$OS" in
  Linux*)   dart compile exe lib/main/main_cli.dart -o output/primal-linux-x86-64 ;;
  Darwin*)  dart compile exe lib/main/main_cli.dart -o output/primal-macos-x86-64 ;;
  MINGW*|MSYS*|CYGWIN*) dart compile exe lib/main/main_cli.dart -o output/primal-windows-x86-64.exe ;;
  *)        echo "Unknown OS: $OS" && exit 1 ;;
esac
