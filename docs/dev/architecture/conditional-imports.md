---
title: Conditional Imports
tags: [architecture, platform]
sources: [lib/compiler/platform/]
---

# Conditional Imports

## TLDR

The Primal SDK uses Dart conditional imports with `dart.library.html` to select platform-specific implementations at compile time. A base/cli/web pattern separates interface definitions from platform implementations, enabling the same codebase to target both native CLI and web browser environments.

## How Dart Conditional Imports Work

Dart supports conditional imports that select different source files based on the target platform. The syntax uses the `if` clause after an import statement:

```dart
import 'package:primal/compiler/platform/base/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/base/platform_web.dart';
```

The Dart compiler evaluates these conditions at compile time:

- `dart.library.html` - True when compiling for web (JavaScript or WebAssembly)
- `dart.library.io` - True when compiling for native platforms (CLI, desktop, server)

When targeting the web via `dart compile js`, the compiler selects `platform_web.dart`. When targeting native via `dart compile exe`, it selects `platform_cli.dart`.

## The Base/CLI/Web Pattern

The SDK organizes platform-specific code using a three-file pattern:

### 1. Base (Abstract Interface)

Located at `lib/compiler/platform/<domain>/platform_<domain>_base.dart`, base files define abstract classes specifying the interface contract:

```dart
// lib/compiler/platform/console/platform_console_base.dart
abstract class PlatformConsoleBase {
  void outWrite(String content);
  void outWriteLn(String content);
  void errorWrite(String content);
  void errorWriteLn(String content);
  String readLine();
}
```

### 2. CLI (Native Implementation)

Located at `lib/compiler/platform/<domain>/platform_<domain>_cli.dart`, CLI files provide native implementations using `dart:io`:

```dart
// lib/compiler/platform/console/platform_console_cli.dart
class PlatformConsoleCli extends PlatformConsoleBase {
  @override
  void outWrite(String content) => stdout.write(content);

  @override
  String readLine() => _lineEditor.readLine();
}
```

### 3. Web (Browser Implementation)

Located at `lib/compiler/platform/<domain>/platform_<domain>_web.dart`, web files provide browser-compatible implementations or throw errors for unsupported operations:

```dart
// lib/compiler/platform/console/platform_console_web.dart
class PlatformConsoleWeb extends PlatformConsoleBase {
  @override
  void outWrite(String content) => print(content);

  @override
  String readLine() =>
      throw const UnimplementedFunctionWebError('console.read');
}
```

## Platform Interface Aggregation

The SDK aggregates all platform services through a unified `PlatformInterface` class. Two implementations exist:

**CLI version** (`lib/compiler/platform/base/platform_cli.dart`):

```dart
class PlatformInterface extends PlatformBase {
  @override
  PlatformConsoleBase get console => PlatformConsoleCli();

  @override
  PlatformFileBase get file => PlatformFileCli();

  @override
  PlatformDirectoryBase get directory => PlatformDirectoryCli();
  // ...
}
```

**Web version** (`lib/compiler/platform/base/platform_web.dart`):

```dart
class PlatformInterface extends PlatformBase {
  @override
  PlatformConsoleBase get console => PlatformConsoleWeb();

  @override
  PlatformFileBase get file => PlatformFileWeb();

  @override
  PlatformDirectoryBase get directory => PlatformDirectoryWeb();
  // ...
}
```

Both files export a class named `PlatformInterface`, allowing consuming code to import with conditional selection and use the same class name regardless of platform.

## Usage in Library Functions

Library functions access platform services through `PlatformInterface()`:

```dart
// lib/compiler/library/console/console_write.dart
import 'package:primal/compiler/platform/base/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/base/platform_web.dart';

class TermWithArguments extends NativeFunctionTermWithArguments {
  @override
  Term reduce() {
    final Term a = arguments[0].reduce();
    PlatformInterface().console.outWrite(a.toString());
    return a;
  }
}
```

## Platform Domains

The SDK provides platform abstractions for five domains:

| Domain      | Base Class                | Services                        |
| ----------- | ------------------------- | ------------------------------- |
| Console     | `PlatformConsoleBase`     | stdout, stderr, stdin           |
| File        | `PlatformFileBase`        | Read, write, copy, delete files |
| Directory   | `PlatformDirectoryBase`   | Create, list, copy directories  |
| Environment | `PlatformEnvironmentBase` | Access environment variables    |
| Path        | `PlatformPathBase`        | Path manipulation utilities     |

## Why Platform-Specific Code Is Needed

Several Primal language features require platform-specific behavior:

1. **File system operations** - `file.read`, `file.write`, `directory.list` require `dart:io` APIs unavailable in browsers

2. **Console I/O** - `console.read` requires `stdin` which has no browser equivalent

3. **Environment variables** - `env.get` accesses `Platform.environment` from `dart:io`

4. **Path handling** - Platform-specific path separators and resolution

On the web platform, these operations throw `UnimplementedFunctionWebError` with a descriptive message indicating the unavailable function.

## Source Files

Platform abstraction files are located in `lib/compiler/platform/`:

```
lib/compiler/platform/
  base/
    platform_base.dart      # Abstract aggregate interface
    platform_cli.dart       # CLI aggregate implementation
    platform_web.dart       # Web aggregate implementation
  console/
    platform_console_base.dart
    platform_console_cli.dart
    platform_console_web.dart
  directory/
    platform_directory_base.dart
    platform_directory_cli.dart
    platform_directory_web.dart
  environment/
    platform_environment_base.dart
    platform_environment_cli.dart
    platform_environment_web.dart
  file/
    platform_file_base.dart
    platform_file_cli.dart
    platform_file_web.dart
  path/
    platform_path_base.dart
    platform_path_cli.dart
    platform_path_web.dart
```
