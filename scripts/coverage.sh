#!/bin/bash

set -e

echo "Running tests with coverage..."
dart test --coverage=coverage

echo "Formatting coverage data..."
dart run coverage:format_coverage \
  --lcov \
  --in=coverage \
  --out=coverage/lcov.info \
  --report-on=lib

if command -v genhtml &> /dev/null; then
  echo "Generating HTML report..."
  genhtml coverage/lcov.info -o coverage/html --quiet
  echo "Coverage report: coverage/html/index.html"
else
  echo "Install lcov for HTML reports: sudo apt install lcov"
  echo "Raw LCOV data: coverage/lcov.info"
fi
