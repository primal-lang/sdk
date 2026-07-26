#!/bin/bash

set -e

mkdir -p output

dart compile js lib/main/main_web.dart -O2 -o output/primal.js