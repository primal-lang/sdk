---
title: Build Targets
tags:
  - architecture
  - build
sources:
  - scripts/
  - lib/main/
  - pubspec.yaml
  - .github/workflows/build_desktop.yml
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

### Desktop Build (`scripts/build_desktop.sh`)

Compiles a native executable for the current operating system and architecture:

```bash
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

case "$OS" in
  Linux*)               OUTPUT="bin/primal-linux-$ARCHITECTURE" ;;
  Darwin*)              OUTPUT="bin/primal-macos-$ARCHITECTURE" ;;
  MINGW*|MSYS*|CYGWIN*) OUTPUT="bin/primal-windows-$ARCHITECTURE" ;;
  *)                    echo "Unknown OS: $OS" >&2 && exit 1 ;;
esac

dart compile exe lib/main/main_cli.dart -o "$OUTPUT"
```

The binary name always reflects the machine it was built on. Released binaries:

- Linux: `bin/primal-linux-x86-64`
- macOS: `bin/primal-macos-arm64`
- Windows: `bin/primal-windows-x86-64`

The Windows binary carries no `.exe` extension because the installer at
`primal-lang.org/install.sh` downloads `bin/primal-windows-<architecture>` from the
release tag and appends the extension when writing the file locally.

### Web Build (`scripts/build_web.sh`)

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
# Using build script (auto-detects OS and architecture)
./scripts/build_desktop.sh

# Direct compilation
dart compile exe lib/main/main_cli.dart -o bin/primal
```

The `dart compile exe` command produces a self-contained native executable that includes the Dart runtime. No Dart SDK is required to run the output binary.

### JavaScript Bundle

```bash
# Using build script
./scripts/build_web.sh

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
   ./scripts/build_desktop.sh  # Native executable for the current machine
   ./scripts/build_web.sh      # JavaScript bundle
   ```

   Release binaries for all three desktop platforms come from the `Build Desktop`
   GitHub Actions workflow (`.github/workflows/build_desktop.yml`), triggered manually
   from the Actions tab. It runs `scripts/build_desktop.sh` on a Linux, macOS and
   Windows runner, and publishes one artifact per platform.

   Each runner is gated twice. Before building it runs `dart test -t cli`, the
   tests covering what differs per platform, so a regression is caught on the
   platform it affects. After building it runs `test/compiler/binary_test.dart`
   against the artifact it has just produced, with `PRIMAL_BINARY` pointing at
   it, so that whatever only ahead-of-time compilation breaks is caught before
   the binary is uploaded. A failure at either point leaves that platform
   without an artifact and does not stop the other two, which build
   independently.

4. **Output Artifacts**:
   - `bin/primal-linux-x86-64`, `bin/primal-macos-arm64`, `bin/primal-windows-x86-64` - Native executables
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
