# Implementation Plan: Replace Dart-Native Errors with Primal Errors

This plan details the implementation of 5 new Primal error types to replace Dart-native errors. Each error is designed to be implemented independently.

---

## Overview

| Error Type                     | Replaces           | Files to Modify  | Test Cases |
| ------------------------------ | ------------------ | ---------------- | ---------- |
| `EmptyCollectionError`         | `StateError`       | 4 library files  | 8 tests    |
| `IndexOutOfBoundsError`        | `RangeError`       | 12 library files | 24 tests   |
| `DivisionByZeroError`          | `UnsupportedError` | 2 library files  | 4 tests    |
| `InvalidNumericOperationError` | `UnsupportedError` | 1 library file   | 2 tests    |
| `ParseError`                   | `FormatException`  | 4 library files  | 8 tests    |

**Total: 23 library files, 46 test cases**

---

## Error 5: ParseError

### 5.1 Error Definitions

**File:** `lib/compiler/errors/runtime_error.dart`

```dart
class ParseError extends RuntimeError {
  ParseError({
    required String function,
    required String input,
    required String targetType,
  }) : super(
         'Cannot parse "$input" as $targetType in "$function"',
       );
}

class JsonParseError extends RuntimeError {
  JsonParseError({
    required String input,
    required String details,
  }) : super(
         'Invalid JSON: $details. Input: "${_truncate(input)}"',
       );

  static String _truncate(String s) => s.length > 50 ? '${s.substring(0, 50)}...' : s;
}
```

### 5.2 Library Files to Modify

#### A. `lib/compiler/library/casting/to_number.dart`

**Current (line 34):**

```dart
return NumberNode(num.parse(a.value));
```

**New:**

```dart
try {
  return NumberNode(num.parse(a.value));
} on FormatException {
  throw ParseError(function: name, input: a.value, targetType: 'number');
}
```

#### B. `lib/compiler/library/casting/to_integer.dart`

**Current (line 34):**

```dart
return NumberNode(int.parse(a.value));
```

**New:**

```dart
try {
  return NumberNode(int.parse(a.value));
} on FormatException {
  throw ParseError(function: name, input: a.value, targetType: 'integer');
}
```

#### C. `lib/compiler/library/casting/to_decimal.dart`

**Current (line 34):**

```dart
return NumberNode(double.parse(a.value));
```

**New:**

```dart
try {
  return NumberNode(double.parse(a.value));
} on FormatException {
  throw ParseError(function: name, input: a.value, targetType: 'decimal');
}
```

#### D. `lib/compiler/library/json/json_decode.dart`

**Current (line 35):**

```dart
final dynamic json = jsonDecode(a.value);
```

**New:**

```dart
final dynamic json;
try {
  json = jsonDecode(a.value);
} on FormatException catch (e) {
  throw JsonParseError(input: a.value, details: e.message);
}
```

### 5.3 Test Updates

#### A. Update `test/runtime/types/casting_test.dart`

**Current (lines 261-269, 286-289):**

```dart
test('to.number throws FormatException for non-numeric string', () {
  final Runtime runtime = getRuntime('main = to.number("hello")');
  expect(runtime.executeMain, throwsA(isA<FormatException>()));
});

test('to.integer throws FormatException for non-numeric string', () {
  final Runtime runtime = getRuntime('main = to.integer("hello")');
  expect(runtime.executeMain, throwsA(isA<FormatException>()));
});

test('to.decimal throws FormatException for non-numeric string', () {
  final Runtime runtime = getRuntime('main = to.decimal("hello")');
  expect(runtime.executeMain, throwsA(isA<FormatException>()));
});
```

**New:**

```dart
test('to.number throws ParseError for non-numeric string', () {
  final Runtime runtime = getRuntime('main = to.number("hello")');
  expect(
    runtime.executeMain,
    throwsA(
      isA<ParseError>().having(
        (e) => e.toString(),
        'message',
        allOf(
          contains('hello'),
          contains('number'),
          contains('to.number'),
        ),
      ),
    ),
  );
});

test('to.integer throws ParseError for non-numeric string', () {
  final Runtime runtime = getRuntime('main = to.integer("hello")');
  expect(
    runtime.executeMain,
    throwsA(
      isA<ParseError>().having(
        (e) => e.toString(),
        'message',
        allOf(
          contains('hello'),
          contains('integer'),
          contains('to.integer'),
        ),
      ),
    ),
  );
});

test('to.integer throws ParseError for decimal string', () {
  final Runtime runtime = getRuntime('main = to.integer("3.14")');
  expect(
    runtime.executeMain,
    throwsA(
      isA<ParseError>().having(
        (e) => e.toString(),
        'message',
        allOf(
          contains('3.14'),
          contains('integer'),
        ),
      ),
    ),
  );
});

test('to.decimal throws ParseError for non-numeric string', () {
  final Runtime runtime = getRuntime('main = to.decimal("hello")');
  expect(
    runtime.executeMain,
    throwsA(
      isA<ParseError>().having(
        (e) => e.toString(),
        'message',
        allOf(
          contains('hello'),
          contains('decimal'),
          contains('to.decimal'),
        ),
      ),
    ),
  );
});
```

#### B. Update `test/runtime/io/json_test.dart`

**Current (lines 80-83, 120-134):**

```dart
test('json.decode throws FormatException for invalid JSON', () {
  final Runtime runtime = getRuntime('main = json.decode("not json")');
  expect(runtime.executeMain, throwsA(isA<FormatException>()));
});
```

**New:**

```dart
test('json.decode throws JsonParseError for invalid JSON string', () {
  final Runtime runtime = getRuntime('main = json.decode("not json")');
  expect(
    runtime.executeMain,
    throwsA(
      isA<JsonParseError>().having(
        (e) => e.toString(),
        'message',
        allOf(
          contains('Invalid JSON'),
          contains('not json'),
        ),
      ),
    ),
  );
});

test('json.decode throws JsonParseError for malformed object', () {
  final Runtime runtime = getRuntime('main = json.decode("{invalid}")');
  expect(
    runtime.executeMain,
    throwsA(
      isA<JsonParseError>().having(
        (e) => e.toString(),
        'message',
        contains('Invalid JSON'),
      ),
    ),
  );
});

test('json.decode throws JsonParseError for incomplete array', () {
  final Runtime runtime = getRuntime(r'main = json.decode("[1, 2,")');
  expect(
    runtime.executeMain,
    throwsA(
      isA<JsonParseError>().having(
        (e) => e.toString(),
        'message',
        contains('Invalid JSON'),
      ),
    ),
  );
});
```

#### C. Update `test/runtime/core/runtime_errors_test.dart`

**Current (lines 156-169):**

```dart
test('to.number throws FormatException', () {
  final Runtime runtime = getRuntime('main = to.number("abc")');
  expect(runtime.executeMain, throwsA(isA<FormatException>()));
});

test('to.integer throws FormatException', () {
  final Runtime runtime = getRuntime('main = to.integer("abc")');
  expect(runtime.executeMain, throwsA(isA<FormatException>()));
});

test('to.decimal throws FormatException', () {
  final Runtime runtime = getRuntime('main = to.decimal("abc")');
  expect(runtime.executeMain, throwsA(isA<FormatException>()));
});
```

**New:**

```dart
test('to.number throws ParseError for invalid input', () {
  final Runtime runtime = getRuntime('main = to.number("abc")');
  expect(
    runtime.executeMain,
    throwsA(
      isA<ParseError>().having(
        (e) => e.toString(),
        'message',
        allOf(
          contains('abc'),
          contains('number'),
        ),
      ),
    ),
  );
});

test('to.integer throws ParseError for invalid input', () {
  final Runtime runtime = getRuntime('main = to.integer("abc")');
  expect(
    runtime.executeMain,
    throwsA(
      isA<ParseError>().having(
        (e) => e.toString(),
        'message',
        allOf(
          contains('abc'),
          contains('integer'),
        ),
      ),
    ),
  );
});

test('to.decimal throws ParseError for invalid input', () {
  final Runtime runtime = getRuntime('main = to.decimal("abc")');
  expect(
    runtime.executeMain,
    throwsA(
      isA<ParseError>().having(
        (e) => e.toString(),
        'message',
        allOf(
          contains('abc'),
          contains('decimal'),
        ),
      ),
    ),
  );
});
```

### 5.4 Files Summary

| Action            | File Path                                      |
| ----------------- | ---------------------------------------------- |
| Add error classes | `lib/compiler/errors/runtime_error.dart`       |
| Modify            | `lib/compiler/library/casting/to_number.dart`  |
| Modify            | `lib/compiler/library/casting/to_integer.dart` |
| Modify            | `lib/compiler/library/casting/to_decimal.dart` |
| Modify            | `lib/compiler/library/json/json_decode.dart`   |
| Update tests      | `test/runtime/types/casting_test.dart`         |
| Update tests      | `test/runtime/io/json_test.dart`               |
| Update tests      | `test/runtime/core/runtime_errors_test.dart`   |

---

## Verification

After implementing each error, run:

```bash
# Run all tests
dart test

# Run specific test files for the error being implemented
dart test test/runtime/collections/list_test.dart
dart test test/runtime/primitives/string_test.dart
dart test test/runtime/primitives/arithmetic_test.dart
dart test test/runtime/types/casting_test.dart
dart test test/runtime/io/json_test.dart
dart test test/runtime/core/boundary_test.dart
dart test test/runtime/core/runtime_errors_test.dart

# Run error formatting tests
dart test test/errors/error_formatting_test.dart
```

---

## Implementation Order (Recommended)

1. **Error 3: DivisionByZeroError** - Smallest scope (2 files)
2. **Error 4: InvalidNumericOperationError** - Small scope (1 file)
3. **Error 1: EmptyCollectionError** - Medium scope (4 files)
4. **Error 5: ParseError** - Medium scope (4 files)
5. **Error 2: IndexOutOfBoundsError** - Largest scope (9 files)

Each error can be implemented independently - just add the error class to `runtime_error.dart` and modify the relevant library files.
