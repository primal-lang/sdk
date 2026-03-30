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

## Error 2: IndexOutOfBoundsError

### 2.1 Error Definition

**File:** `lib/compiler/errors/runtime_error.dart`

```dart
class IndexOutOfBoundsError extends RuntimeError {
  IndexOutOfBoundsError({
    required String function,
    required int index,
    required int length,
  }) : super(
         'Index $index is out of bounds for $function (length: $length)',
       );
}

class NegativeIndexError extends RuntimeError {
  NegativeIndexError({
    required String function,
    required int index,
  }) : super(
         'Negative index $index is not allowed for $function',
       );
}
```

### 2.2 Library Files to Modify

#### A. `lib/compiler/library/list/list_at.dart`

**Current (line 36):**

```dart
return a.value[b.value.toInt()];
```

**New:**

```dart
final int index = b.value.toInt();
if (index < 0) {
  throw NegativeIndexError(function: name, index: index);
}
if (index >= a.value.length) {
  throw IndexOutOfBoundsError(function: name, index: index, length: a.value.length);
}
return a.value[index];
```

#### B. `lib/compiler/library/list/list_remove_at.dart`

**Current (lines 37-40):**

```dart
return ListNode(
  a.value.sublist(0, b.value.toInt()) +
      a.value.sublist(b.value.toInt() + 1),
);
```

**New:**

```dart
final int index = b.value.toInt();
if (index < 0) {
  throw NegativeIndexError(function: name, index: index);
}
if (index >= a.value.length) {
  throw IndexOutOfBoundsError(function: name, index: index, length: a.value.length);
}
return ListNode(
  a.value.sublist(0, index) + a.value.sublist(index + 1),
);
```

#### C. `lib/compiler/library/list/list_swap.dart`

**Current (lines 39-40):**

```dart
final Node valueAtB = a.value[b.value.toInt()];
final Node valueAtC = a.value[c.value.toInt()];
```

**New:**

```dart
final int indexB = b.value.toInt();
final int indexC = c.value.toInt();
if (indexB < 0) {
  throw NegativeIndexError(function: name, index: indexB);
}
if (indexC < 0) {
  throw NegativeIndexError(function: name, index: indexC);
}
if (indexB >= a.value.length) {
  throw IndexOutOfBoundsError(function: name, index: indexB, length: a.value.length);
}
if (indexC >= a.value.length) {
  throw IndexOutOfBoundsError(function: name, index: indexC, length: a.value.length);
}
final Node valueAtB = a.value[indexB];
final Node valueAtC = a.value[indexC];
```

#### D. `lib/compiler/library/list/list_sublist.dart`

**Current (line 39):**

```dart
a.value.sublist(b.value.toInt(), c.value.toInt()),
```

**New:**

```dart
final int start = b.value.toInt();
final int end = c.value.toInt();
if (start < 0) {
  throw NegativeIndexError(function: name, index: start);
}
if (end < start) {
  throw IndexOutOfBoundsError(function: name, index: end, length: a.value.length);
}
if (end > a.value.length) {
  throw IndexOutOfBoundsError(function: name, index: end, length: a.value.length);
}
return ListNode(a.value.sublist(start, end));
```

#### E. `lib/compiler/library/list/list_set.dart`

**Current (lines 38-39):**

```dart
final List<Node> head = a.value.sublist(0, b.value.toInt());
final List<Node> rest = a.value.sublist(b.value.toInt(), a.value.length);
```

**New:**

```dart
final int index = b.value.toInt();
if (index < 0) {
  throw NegativeIndexError(function: name, index: index);
}
if (index > a.value.length) {
  throw IndexOutOfBoundsError(function: name, index: index, length: a.value.length);
}
final List<Node> head = a.value.sublist(0, index);
final List<Node> rest = a.value.sublist(index, a.value.length);
```

#### F. `lib/compiler/library/string/str_at.dart`

**Current (line 36):**

```dart
return StringNode(a.value[b.value.toInt()]);
```

**New:**

```dart
final int index = b.value.toInt();
if (index < 0) {
  throw NegativeIndexError(function: name, index: index);
}
if (index >= a.value.length) {
  throw IndexOutOfBoundsError(function: name, index: index, length: a.value.length);
}
return StringNode(a.value[index]);
```

#### G. `lib/compiler/library/string/str_take.dart`

**Current (line 36):**

```dart
return StringNode(a.value.substring(0, b.value.toInt()));
```

**New:**

```dart
final int count = b.value.toInt();
if (count < 0) {
  throw NegativeIndexError(function: name, index: count);
}
if (count > a.value.length) {
  throw IndexOutOfBoundsError(function: name, index: count, length: a.value.length);
}
return StringNode(a.value.substring(0, count));
```

#### H. `lib/compiler/library/string/str_drop.dart`

**Current (line 36):**

```dart
return StringNode(a.value.substring(b.value.toInt(), a.value.length));
```

**New:**

```dart
final int count = b.value.toInt();
if (count < 0) {
  throw NegativeIndexError(function: name, index: count);
}
if (count > a.value.length) {
  throw IndexOutOfBoundsError(function: name, index: count, length: a.value.length);
}
return StringNode(a.value.substring(count, a.value.length));
```

#### I. `lib/compiler/library/string/str_substring.dart`

**Current (line 38):**

```dart
return StringNode(a.value.substring(b.value.toInt(), c.value.toInt()));
```

**New:**

```dart
final int start = b.value.toInt();
final int end = c.value.toInt();
if (start < 0) {
  throw NegativeIndexError(function: name, index: start);
}
if (end < start) {
  throw IndexOutOfBoundsError(function: name, index: end, length: a.value.length);
}
if (end > a.value.length) {
  throw IndexOutOfBoundsError(function: name, index: end, length: a.value.length);
}
return StringNode(a.value.substring(start, end));
```

### 2.3 Test Updates

#### A. Update `test/runtime/collections/list_test.dart`

**Current (lines 539-542):**

```dart
test('list.at throws RangeError for out of bounds index', () {
  final Runtime runtime = getRuntime('main = list.at([1, 2, 3], 10)');
  expect(runtime.executeMain, throwsA(isA<RangeError>()));
});
```

**New:**

```dart
test('list.at throws IndexOutOfBoundsError for out of bounds index', () {
  final Runtime runtime = getRuntime('main = list.at([1, 2, 3], 10)');
  expect(
    runtime.executeMain,
    throwsA(
      isA<IndexOutOfBoundsError>().having(
        (e) => e.toString(),
        'message',
        allOf(
          contains('10'),
          contains('length: 3'),
          contains('list.at'),
        ),
      ),
    ),
  );
});

test('list.at throws NegativeIndexError for negative index', () {
  final Runtime runtime = getRuntime('main = list.at([1, 2, 3], -1)');
  expect(
    runtime.executeMain,
    throwsA(
      isA<NegativeIndexError>().having(
        (e) => e.toString(),
        'message',
        allOf(
          contains('-1'),
          contains('list.at'),
        ),
      ),
    ),
  );
});
```

#### B. Update `test/runtime/core/boundary_test.dart`

Update all RangeError expectations to IndexOutOfBoundsError or NegativeIndexError:

- Lines 43-48: list.at empty list
- Lines 55-60: list index operator out of bounds
- Lines 65-70: list.at out of bounds
- Lines 77-82: list.removeAt out of bounds
- Lines 82-87: list.swap out of bounds
- Lines 87-94: list.sublist out of bounds
- Lines 94-99: str.substring out of bounds
- Lines 99-104: list.at negative index

#### C. Update `test/runtime/primitives/string_test.dart`

Update existing tests (lines 346-354, 400-408):

```dart
test('str.take throws IndexOutOfBoundsError when count exceeds length', () {
  final Runtime runtime = getRuntime('main = str.take("Hi", 10)');
  expect(
    runtime.executeMain,
    throwsA(
      isA<IndexOutOfBoundsError>().having(
        (e) => e.toString(),
        'message',
        allOf(
          contains('10'),
          contains('length: 2'),
          contains('str.take'),
        ),
      ),
    ),
  );
});

test('str.drop throws IndexOutOfBoundsError when count exceeds length', () {
  final Runtime runtime = getRuntime('main = str.drop("Hi", 10)');
  expect(
    runtime.executeMain,
    throwsA(
      isA<IndexOutOfBoundsError>().having(
        (e) => e.toString(),
        'message',
        allOf(
          contains('10'),
          contains('length: 2'),
          contains('str.drop'),
        ),
      ),
    ),
  );
});

test('str.at throws IndexOutOfBoundsError for out of bounds index', () {
  final Runtime runtime = getRuntime('main = str.at("Hello", 10)');
  expect(
    runtime.executeMain,
    throwsA(
      isA<IndexOutOfBoundsError>().having(
        (e) => e.toString(),
        'message',
        allOf(
          contains('10'),
          contains('length: 5'),
          contains('str.at'),
        ),
      ),
    ),
  );
});

test('str.at throws NegativeIndexError for negative index', () {
  final Runtime runtime = getRuntime('main = str.at("Hello", -1)');
  expect(
    runtime.executeMain,
    throwsA(
      isA<NegativeIndexError>().having(
        (e) => e.toString(),
        'message',
        allOf(
          contains('-1'),
          contains('str.at'),
        ),
      ),
    ),
  );
});
```

### 2.4 Files Summary

| Action            | File Path                                        |
| ----------------- | ------------------------------------------------ |
| Add error classes | `lib/compiler/errors/runtime_error.dart`         |
| Modify            | `lib/compiler/library/list/list_at.dart`         |
| Modify            | `lib/compiler/library/list/list_remove_at.dart`  |
| Modify            | `lib/compiler/library/list/list_swap.dart`       |
| Modify            | `lib/compiler/library/list/list_sublist.dart`    |
| Modify            | `lib/compiler/library/list/list_set.dart`        |
| Modify            | `lib/compiler/library/string/str_at.dart`        |
| Modify            | `lib/compiler/library/string/str_take.dart`      |
| Modify            | `lib/compiler/library/string/str_drop.dart`      |
| Modify            | `lib/compiler/library/string/str_substring.dart` |
| Update tests      | `test/runtime/collections/list_test.dart`        |
| Update tests      | `test/runtime/core/boundary_test.dart`           |
| Update tests      | `test/runtime/primitives/string_test.dart`       |

---

## Error 3: DivisionByZeroError

### 3.1 Error Definition

**File:** `lib/compiler/errors/runtime_error.dart`

```dart
class DivisionByZeroError extends RuntimeError {
  DivisionByZeroError({
    required String function,
  }) : super(
         'Division by zero is not allowed in "$function"',
       );
}
```

### 3.2 Library Files to Modify

#### A. `lib/compiler/library/operators/operator_mod.dart`

**Current (line 36):**

```dart
return NumberNode(a.value % b.value);
```

**New:**

```dart
if (b.value == 0) {
  throw DivisionByZeroError(function: name);
}
return NumberNode(a.value % b.value);
```

#### B. `lib/compiler/library/arithmetic/num_mod.dart`

**Current (line 36):**

```dart
return NumberNode(a.value % b.value);
```

**New:**

```dart
if (b.value == 0) {
  throw DivisionByZeroError(function: name);
}
return NumberNode(a.value % b.value);
```

### 3.3 Test Updates

#### A. Update `test/runtime/primitives/arithmetic_test.dart`

**Current (lines 378-391):**

```dart
test('modulo by zero', () {
  final Runtime runtime = getRuntime('main = 5 % 0');
  expect(runtime.executeMain, throwsA(isA<UnsupportedError>()));
});

test('num.mod by zero', () {
  final Runtime runtime = getRuntime('main = num.mod(5, 0)');
  expect(runtime.executeMain, throwsA(isA<UnsupportedError>()));
});
```

**New:**

```dart
test('modulo by zero throws DivisionByZeroError', () {
  final Runtime runtime = getRuntime('main = 5 % 0');
  expect(
    runtime.executeMain,
    throwsA(
      isA<DivisionByZeroError>().having(
        (e) => e.toString(),
        'message',
        allOf(
          contains('Division by zero'),
          contains('%'),
        ),
      ),
    ),
  );
});

test('num.mod by zero throws DivisionByZeroError', () {
  final Runtime runtime = getRuntime('main = num.mod(5, 0)');
  expect(
    runtime.executeMain,
    throwsA(
      isA<DivisionByZeroError>().having(
        (e) => e.toString(),
        'message',
        allOf(
          contains('Division by zero'),
          contains('num.mod'),
        ),
      ),
    ),
  );
});
```

#### B. Update `test/runtime/core/runtime_errors_test.dart`

**Current (lines 26-29):**

```dart
test('modulo by zero', () {
  final Runtime runtime = getRuntime('main = 1 % 0');
  // ignore: deprecated_member_use
  expect(runtime.executeMain, throwsA(isA<IntegerDivisionByZeroException>()));
});
```

**New:**

```dart
test('modulo by zero throws DivisionByZeroError', () {
  final Runtime runtime = getRuntime('main = 1 % 0');
  expect(
    runtime.executeMain,
    throwsA(
      isA<DivisionByZeroError>().having(
        (e) => e.toString(),
        'message',
        contains('Division by zero'),
      ),
    ),
  );
});
```

### 3.4 Files Summary

| Action          | File Path                                          |
| --------------- | -------------------------------------------------- |
| Add error class | `lib/compiler/errors/runtime_error.dart`           |
| Modify          | `lib/compiler/library/operators/operator_mod.dart` |
| Modify          | `lib/compiler/library/arithmetic/num_mod.dart`     |
| Update tests    | `test/runtime/primitives/arithmetic_test.dart`     |
| Update tests    | `test/runtime/core/runtime_errors_test.dart`       |

---

## Error 4: InvalidNumericOperationError

### 4.1 Error Definition

**File:** `lib/compiler/errors/runtime_error.dart`

```dart
class InvalidNumericOperationError extends RuntimeError {
  InvalidNumericOperationError({
    required String function,
    required String reason,
  }) : super(
         'Invalid numeric operation in "$function": $reason',
       );
}
```

### 4.2 Library Files to Modify

#### A. `lib/compiler/library/arithmetic/num_sqrt.dart`

**Current (lines 35-36):**

```dart
final num value = sqrt(a.value);
final num result = (value == value.toInt()) ? value.toInt() : value;
```

**New:**

```dart
if (a.value < 0) {
  throw InvalidNumericOperationError(
    function: name,
    reason: 'cannot compute square root of negative number ${a.value}',
  );
}
final num value = sqrt(a.value);
final num result = (value == value.toInt()) ? value.toInt() : value;
```

### 4.3 Test Updates

#### A. Update `test/runtime/primitives/arithmetic_test.dart`

**Current (lines 395-398):**

```dart
test('num.sqrt negative throws', () {
  final Runtime runtime = getRuntime('main = num.sqrt(-1)');
  expect(runtime.executeMain, throwsA(isA<UnsupportedError>()));
});
```

**New:**

```dart
test('num.sqrt throws InvalidNumericOperationError for negative input', () {
  final Runtime runtime = getRuntime('main = num.sqrt(-1)');
  expect(
    runtime.executeMain,
    throwsA(
      isA<InvalidNumericOperationError>().having(
        (e) => e.toString(),
        'message',
        allOf(
          contains('num.sqrt'),
          contains('square root'),
          contains('negative'),
          contains('-1'),
        ),
      ),
    ),
  );
});

test('num.sqrt throws InvalidNumericOperationError for negative decimal', () {
  final Runtime runtime = getRuntime('main = num.sqrt(-4.5)');
  expect(
    runtime.executeMain,
    throwsA(
      isA<InvalidNumericOperationError>().having(
        (e) => e.toString(),
        'message',
        allOf(
          contains('num.sqrt'),
          contains('negative'),
        ),
      ),
    ),
  );
});
```

### 4.4 Files Summary

| Action          | File Path                                       |
| --------------- | ----------------------------------------------- |
| Add error class | `lib/compiler/errors/runtime_error.dart`        |
| Modify          | `lib/compiler/library/arithmetic/num_sqrt.dart` |
| Update tests    | `test/runtime/primitives/arithmetic_test.dart`  |

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
