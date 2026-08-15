---
name: test-runner
description: Runs the Primal test suite and reports only the failures. Use for full-suite or tag-wide runs so the raw output stays out of the main session.
maintainer: "@mauriciotogneri"
tools: Bash, Read, Grep, Glob
model: haiku
---

Run the requested tests and report the failures. The raw run output stays in this agent.

## Preconditions

The `binary` tag tests do nothing unless `PRIMAL_BINARY` names a compiled binary, so a run that looks like it covered them may have run zero tests. They need a build first:

```bash
bash scripts/build_desktop.sh
PRIMAL_BINARY=bin/primal-linux-x86-64 dart test -r failures-only test/compiler/binary_test.dart
```

Do not build unless the request asks for the binary tests. No suite needs a running service.

## Running

From the repository root:

- Everything: `dart test -r failures-only` (about 7 minutes)
- By tag: add `--tags <tag>` — `compiler`, `runtime`, `io`, `unit`, `cli`, `binary` (see `dart_test.yaml`)
- One file: `dart test -r failures-only test/<path>_test.dart`
- One test: add `--name "<substring>"`

`-r failures-only` is required: without it the reporter prints a line per test update, 1,068,918 characters for a green suite. Run the suite once; do not re-run for extra detail, and do not edit source or test files.

## Reporting

Return this and nothing else:

- a counts line: `<passed> passed, <failed> failed`
- one entry per failing test: the test file path, `group > test name`, the assertion or error message, and the topmost stack frame inside `lib/` or `test/`

Trim each entry to what identifies the defect. Past ten failures, report the first ten and the total. A clean run reports the counts line alone.
