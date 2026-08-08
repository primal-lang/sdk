---
title: Test Organization
tags:
  - architecture
  - testing
sources:
  - test/
---

# Test Organization

**TLDR**: The test suite mirrors the `lib/` structure with separate directories for compiler stages, runtime behaviors, and utilities. Tests use helper modules for pipeline setup, assertions, and resource loading. Run tests with `dart test` or filter by tag.

The Primal SDK test suite is organized to mirror the source code structure, making it easy to locate tests for specific components. The suite contains approximately 80 test files covering compiler stages, runtime evaluation, and supporting utilities.

## Directory Structure

```
test/
  compiler/         # Compiler stage tests (lexer, parser, semantic, etc.)
    platform/       # Platform-specific CLI tests
  runtime/          # Runtime evaluation tests
    collections/    # List, map, set, stack, queue tests
    core/           # Control flow, bindings, samples, errors
    functions/      # Higher-order function tests
    io/             # File, directory, console, environment tests
    primitives/     # Number, string, boolean operations
    types/          # Type casting and checking
  errors/           # Error formatting tests
  extensions/       # String extension tests
  helpers/          # Test utilities (pipeline, assertions, fakes)
  models/           # Data model tests (Location, Parameter, Type, State)
  resources/        # Test fixtures (sample programs, files)
    samples/        # Sample Primal programs for integration tests
    files/          # File system test fixtures
  utils/            # Utility class tests (Stack, ListIterator, etc.)
```

## Mirror Structure

The test directory structure mirrors `lib/compiler/` to maintain discoverability:

| Source Directory        | Test Directory     | Coverage                                |
| ----------------------- | ------------------ | --------------------------------------- |
| `lib/compiler/`         | `test/compiler/`   | Compilation pipeline stages             |
| `lib/compiler/runtime/` | `test/runtime/`    | Runtime evaluation and standard library |
| `lib/utils/`            | `test/utils/`      | Utility classes                         |
| `lib/extensions/`       | `test/extensions/` | String extensions                       |
| `lib/compiler/models/`  | `test/models/`     | Shared data models                      |
| `lib/compiler/errors/`  | `test/errors/`     | Error formatting                        |

## File Naming Conventions

Test files follow the `<module>_test.dart` naming convention:

- `lexical_analyzer_test.dart` - Tests for the lexical analyzer
- `compiler_test.dart` - Tests for the main `Compiler` class
- `file_test.dart` - Tests for `file_*` standard library functions
- `samples_test.dart` - Integration tests using sample programs

Tests are grouped by logical units rather than individual classes when multiple classes work together.

## Test Tags

Tests use `@Tags` annotations to enable filtered execution:

```dart
@Tags(['compiler'])
library;

// Tests for compiler stages
```

```dart
@Tags(['runtime'])
library;

// Tests for runtime evaluation
```

```dart
@Tags(['runtime', 'io'])
@TestOn('vm')
library;

// Tests requiring I/O (file system, console)
```

```dart
@Tags(['compiler', 'cli'])
@TestOn('vm')
library;

// Tests the build workflow runs on Linux, macOS and Windows
```

```dart
@Tags(['binary'])
@TestOn('vm')
library;

// Smoke tests for a compiled binary, which PRIMAL_BINARY must point at
```

The `@TestOn('vm')` annotation restricts tests to the Dart VM (excludes web targets), used for tests requiring file system or process access.

The `cli` tag marks what behaves differently per platform — the entrypoint, the
`dart:io` platform layer and the installer. `Build Desktop` runs those on all
three runners, so a platform-specific regression is caught before its binary is
built. Tests that assert POSIX-only behaviour, such as permission bits or
symbolic links, carry `testOn: '!windows'`.

## Running Tests

Execute all tests:

```bash
dart test
```

Run tests by tag:

```bash
dart test --tags compiler      # Compiler stage tests only
dart test --tags runtime       # Runtime tests only
dart test --tags io            # I/O tests only
dart test --tags cli           # Tests that run on every desktop platform
```

Run the smoke tests for a compiled binary, which do nothing until pointed at
one:

```bash
bash scripts/build_desktop.sh
PRIMAL_BINARY=bin/primal-linux-x86-64 dart test test/compiler/binary_test.dart
```

They are deliberately not defaulted to the artifacts committed in `bin/`: those
belong to the last release rather than the current sources, and would fail the
version assertion for the whole stretch of a release between the version being
bumped and the new binaries being committed.

Run a specific test file:

```bash
dart test test/compiler/lexical_analyzer_test.dart
```

Run tests matching a pattern:

```bash
dart test --name "factorial"   # Tests with "factorial" in name
```

## Test Helper Modules

The `test/helpers/` directory provides reusable test infrastructure:

| Helper File              | Purpose                                                            |
| ------------------------ | ------------------------------------------------------------------ |
| `helpers.dart`           | Barrel export for all helpers                                      |
| `pipeline_helpers.dart`  | Functions to run compilation stages (`getTokens`, `getRuntime`)    |
| `assertion_helpers.dart` | Custom matchers (`checkTokens`, `checkResult`, `checkTypedResult`) |
| `resource_helpers.dart`  | Load test fixtures (`loadFile`, `resourcesPath`)                   |
| `token_factories.dart`   | Factories for creating tokens with locations                       |
| `temp_helpers.dart`      | Temporary directory management with cleanup                        |
| `console_fakes.dart`     | Fake console implementations for I/O tests                         |

Import helpers in test files:

```dart
import '../helpers/helpers.dart';       // All helpers
import '../helpers/pipeline_helpers.dart';  // Pipeline only
```

## Test Resources

The `test/resources/` directory contains test fixtures:

- `sample.prm` - A sample Primal program with various language features, plus a
  suite of `test_` functions exercised by the `--test` runner
- `samples/` - Complete Primal programs for integration tests (factorial, fibonacci, quicksort, etc.)
- `files/` - Test files for file system operations

Sample programs serve as integration tests that exercise the full compilation and execution pipeline.
