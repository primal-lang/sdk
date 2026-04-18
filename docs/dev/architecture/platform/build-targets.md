---
title: Build Targets
tags:
  - architecture
  - build
sources:
  - scripts/
  - lib/main/
  - pubspec.yaml
---

# Build Targets

**TLDR**: The Primal SDK supports two primary build targets: native CLI executables via `dart compile exe` and JavaScript bundles via `dart compile js`. Build scripts in `scripts/` automate platform-specific compilation. Each target has a dedicated entry point in `lib/main/`.

## Entry Points

The SDK maintains separate entry points for each target platform:

| Target | Entry Point              | Purpose                                                    |
| ------ | ------------------------ | ---------------------------------------------------------- |
| CLI    | `lib/main/main_cli.dart` | Native executable with REPL, file execution, watch mode    |
| Web    | `lib/main/main_web.dart` | JavaScript library exposing compiler functions to browsers |

### CLI Entry Point

`lib/main/main_cli.dart` provides a full-featured command-line interface:

```dart
void main(List<String> args) => runCli(args);
```

Features include:

- Interactive REPL with line editing
- File execution with argument passing
- Watch mode for automatic re-execution on file changes
- Debug mode with timing and stack traces

### Web Entry Point

`lib/main/main_web.dart` exports compiler functions to JavaScript using `dart:js_interop`:

```dart
@JS('compileInput')
external set compileInput(JSFunction v);

void main(List<String> args) {
  compileInput = (JSString source) {
    final IntermediateRepresentation ir = compiler.compile(source.toDart);
    return _storeCode(ir).toJS;
  }.toJS;
  // ...
}
```

The web target exposes:

- `compileInput(source)` - Compile Primal source to intermediate representation
- `compileExpression(source)` - Parse a single expression
- `runtimeHasMain(codeId)` - Check if compiled code has a main function
- `runtimeExecuteMain(codeId)` - Execute the main function
- `runtimeReduce(codeId, expressionId)` - Evaluate an expression
- `disposeCode(codeId)` / `disposeExpression(expressionId)` - Memory management

## Build Scripts

Build scripts are located in `scripts/`:

### Desktop Build (`scripts/build-desktop.sh`)

Compiles native executables for the current operating system:

```bash
#!/bin/bash
set -e
mkdir -p output

OS="$(uname -s)"
case "$OS" in
  Linux*)   dart compile exe lib/main/main_cli.dart -o bin/primal-linux-x86-64 ;;
  Darwin*)  dart compile exe lib/main/main_cli.dart -o bin/primal-macos-x86-64 ;;
  MINGW*|MSYS*|CYGWIN*) dart compile exe lib/main/main_cli.dart -o bin/primal-windows-x86-64.exe ;;
  *)        echo "Unknown OS: $OS" && exit 1 ;;
esac
```

Output binaries:

- Linux: `bin/primal-linux-x86-64`
- macOS: `bin/primal-macos-x86-64`
- Windows: `bin/primal-windows-x86-64.exe`

### Web Build (`scripts/build-web.sh`)

Compiles to optimized JavaScript:

```bash
#!/bin/bash
set -e
mkdir -p output

dart compile js lib/main/main_web.dart -O2 -o output/primal.js
```

The `-O2` flag enables size and speed optimizations. Output is written to `output/primal.js`.

## Build Commands

### Native Executable

```bash
# Using build script (auto-detects OS)
./scripts/build-desktop.sh

# Direct compilation
dart compile exe lib/main/main_cli.dart -o bin/primal
```

The `dart compile exe` command produces a self-contained native executable that includes the Dart runtime. No Dart SDK is required to run the output binary.

### JavaScript Bundle

```bash
# Using build script
./scripts/build-web.sh

# Direct compilation
dart compile js lib/main/main_web.dart -O2 -o output/primal.js
```

Optimization levels:

- `-O0` - No optimization (fastest compilation)
- `-O1` - Basic optimization
- `-O2` - Recommended for production (size + speed)
- `-O3` - Aggressive optimization (may increase size)
- `-O4` - Aggressive + type trust (may break code)

## Development Scripts

Additional scripts support development workflows:

### Format (`scripts/format.sh`)

```bash
#!/bin/bash
set -e
dart format lib
dart format test
```

### Coverage (`scripts/coverage.sh`)

```bash
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
```

## SDK Requirements

From `pubspec.yaml`:

```yaml
environment:
  sdk: ">=3.11.4 <4.0.0"
```

The SDK requires Dart 3.11.4 or later.

## Release Process Overview

1. **Version Update**: Update version in `pubspec.yaml` and `lib/main/main_cli.dart`

2. **Format and Test**:

   ```bash
   ./scripts/format.sh
   dart test
   ```

3. **Build Targets**:

   ```bash
   ./scripts/build-desktop.sh  # Native executable
   ./scripts/build-web.sh      # JavaScript bundle
   ```

4. **Output Artifacts**:
   - `bin/primal-<os>-x86-64` - Native executables
   - `output/primal.js` - JavaScript bundle

## Platform Considerations

### CLI Target

- Full access to file system, environment variables, and stdin
- Native performance with ahead-of-time compilation
- Self-contained binary with no runtime dependencies

### Web Target

- Sandboxed browser environment
- No file system or stdin access (operations throw `UnimplementedFunctionWebError`)
- Console output via `print()` to browser console
- Memory managed via explicit dispose functions

See [[dev/architecture/platform/conditional-imports]] for details on how platform-specific code is selected at compile time.
