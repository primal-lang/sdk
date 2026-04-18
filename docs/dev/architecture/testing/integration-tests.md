---
title: Integration Tests
tags:
  - architecture
  - testing
sources:
  - test/
---

# Integration Tests

**TLDR**: Integration tests validate the full compilation and execution pipeline using sample Primal programs and helper functions. The `getRuntime()` helper compiles source code through all stages and returns a `RuntimeFacade` for execution and result verification.

Integration tests exercise the complete Primal compilation and execution pipeline, from source code to evaluated results. These tests verify that all compiler stages work together correctly and that programs produce expected outputs.

## Pipeline Helpers

The `test/helpers/pipeline_helpers.dart` module provides functions to run source code through compilation stages:

```dart
// Tokenize source code
List<Token> getTokens(String source)

// Parse source into function definitions
List<FunctionDefinition> getFunctions(String source)

// Compile to intermediate representation
IntermediateRepresentation getIntermediateRepresentation(String source)

// Compile and create runtime for execution
RuntimeFacade getRuntime(String source)

// Parse a single expression
Expression getExpression(String source)
```

The `getRuntime()` function is the primary entry point for integration tests. It runs the full pipeline and returns a `RuntimeFacade` that can execute the `main()` function.

**Source**: `test/helpers/pipeline_helpers.dart`

## Result Verification

The `test/helpers/assertion_helpers.dart` module provides assertion functions:

```dart
// Check that main() returns the expected result
void checkResult(RuntimeFacade runtime, Object result)

// Check result with type verification
void checkTypedResult<T extends Term>(RuntimeFacade runtime, Object result)

// Check date/time results (fuzzy matching)
void checkDates(RuntimeFacade runtime, DateTime result)

// Verify token sequences
void checkTokens(List<Token> actual, List<Token> expected)

// Verify function definitions
void checkFunctions(List<FunctionDefinition> actual, List<FunctionDefinition> expected)

// Verify expression trees
void checkExpressions(Expression actual, Expression expected)
```

**Source**: `test/helpers/assertion_helpers.dart`

## Writing Integration Tests

A typical integration test:

```dart
import 'package:test/test.dart';
import '../helpers/helpers.dart';

void main() {
  test('factorial computes correctly', () {
    final RuntimeFacade runtime = getRuntime('''
      factorial(n) = if (n <= 1) 1 else n * factorial(n - 1)
      main() = factorial(5)
    ''');
    checkResult(runtime, 120);
  });
}
```

For typed result verification (distinguishes `NumberTerm(1)` from `StringTerm("1")`):

```dart
test('addition returns number', () {
  final RuntimeFacade runtime = getRuntime('main() = 1 + 2');
  checkTypedResult<NumberTerm>(runtime, 3);
});
```

## Sample Program Tests

The `test/runtime/core/samples_test.dart` file runs integration tests against sample programs in `test/resources/samples/`:

```dart
test('factorial', () {
  final RuntimeFacade runtime = getRuntime(
    loadFile('samples/factorial.prm'),
  );
  checkResult(runtime, 120);
});

test('fibonacci', () {
  final RuntimeFacade runtime = getRuntime(
    loadFile('samples/fibonacci.prm'),
  );
  checkResult(runtime, [1, 1, 2, 3, 5, 8, 13, 21, 34, 55]);
});
```

The `loadFile()` helper (from `test/helpers/resource_helpers.dart`) reads test fixtures from `test/resources/`.

**Sample programs**: `test/resources/samples/` contains complete Primal programs:

| Program                    | Tests                               |
| -------------------------- | ----------------------------------- |
| `factorial.prm`            | Recursive factorial computation     |
| `fibonacci.prm`            | Fibonacci sequence generation       |
| `quicksort.prm`            | Quicksort algorithm                 |
| `binary_search.prm`        | Binary search in sorted list        |
| `is_palindrome.prm`        | Palindrome detection                |
| `matrix_multiply.prm`      | Matrix multiplication               |
| `balanced_parentheses.prm` | Parentheses balancing check         |
| `to_roman_numerals.prm`    | Integer to Roman numeral conversion |

## CLI Integration Tests

The `test/compiler/cli_test.dart` file tests the command-line interface by spawning actual Primal processes:

```dart
test('executes a file and returns result', () async {
  final ProcessResult result = await runCli([
    'test/resources/samples/factorial.prm',
  ]);
  expect(result.exitCode, equals(0));
  expect(result.stdout.toString().trim(), isNotEmpty);
});

test('passes arguments to main function', () async {
  final File tmpFile = writeProgram('args.prm', 'main(x) = x');
  final ProcessResult result = await runCli([tmpFile.path, 'hello']);
  expect(result.exitCode, equals(0));
  expect(result.stdout.toString().trim(), equals('"hello"'));
});
```

These tests use temporary directories (via `createTempTestDirectory()`) that are automatically cleaned up.

**Source**: `test/compiler/cli_test.dart`

## Temporary File Management

For tests requiring temporary files or directories, use `temp_helpers.dart`:

```dart
import '../helpers/temp_helpers.dart';

test('file operations', () {
  final Directory tempDir = createTempTestDirectory('primal_test_');
  final File testFile = File(path.join(tempDir.path, 'test.txt'));
  testFile.writeAsStringSync('content');

  // ... test code ...

  // Directory is automatically deleted after test
});
```

The `createTempTestDirectory()` function registers a teardown callback to clean up the directory.

**Source**: `test/helpers/temp_helpers.dart`

## Fake Implementations

For testing I/O operations without side effects, use `console_fakes.dart`:

```dart
import '../helpers/console_fakes.dart';

test('console output', () {
  final FakePlatformConsole console = FakePlatformConsole(
    inputs: ['user input'],
  );

  // ... test code using console ...

  expect(console.outLines, contains('expected output'));
});
```

`FakePlatformConsole` captures writes and provides scripted inputs.

**Source**: `test/helpers/console_fakes.dart`

## Error Testing Patterns

Integration tests verify that invalid programs produce expected errors:

```dart
test('undefined function throws UndefinedFunctionError', () {
  expect(
    () => getIntermediateRepresentation('main() = unknown_function()'),
    throwsA(isA<UndefinedFunctionError>()),
  );
});

test('runtime error is thrown for division by zero', () {
  final RuntimeFacade runtime = getRuntime('main() = 1 / 0');
  expect(
    () => runtime.executeMain(),
    throwsA(isA<DivisionByZeroError>()),
  );
});
```

Compilation errors are caught during `getRuntime()` or `getIntermediateRepresentation()`, while runtime errors occur during `executeMain()`.

## Main Function Testing

Tests can verify programs with different `main()` signatures:

```dart
// Parameterless main
test('constant main', () {
  final RuntimeFacade runtime = getRuntime('main() = 42');
  checkResult(runtime, 42);
});

// Main with arguments
test('main with arguments', () {
  final RuntimeFacade runtime = getRuntime('main(a, b) = a + b');
  expect(runtime.executeMain(['hello', 'world']), '"helloworld"');
});

// Check if main exists
test('hasMain detection', () {
  final RuntimeFacade runtime = getRuntime('f(x) = x');
  expect(runtime.hasMain, isFalse);
});
```

**Source**: `test/runtime/core/main_test.dart`
