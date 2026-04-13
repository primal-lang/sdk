# Implementation Plan: `debug` Function

## Overview

Implement a new `debug` function that evaluates an expression, prints its value with a label to stdout, and returns the expression's value.

**Signature:** `debug(a: String, b: Any): Any`

---

## Phase 1: Core Implementation

### 1.1 Create the Debug Function File

- [x] Create new directory: `lib/compiler/library/debug/`
- [x] Create new file: `lib/compiler/library/debug/debug.dart`

**Implementation details:**
- Create `Debug` class extending `NativeFunctionTerm`
- Create `DebugTermWithArguments` class extending `NativeFunctionTermWithArguments`
- Parameters:
  - `a`: `Parameter.string('a')` - the label
  - `b`: `Parameter.any('b')` - the value to debug
- Use `PlatformInterface().console.outWriteLn()` for output
- Output format: `[debug] <a>: <deeply-reduced b>`

**Key implementation points:**
1. Evaluate `a` first (left-to-right order for error propagation)
2. Verify `a` is a `StringTerm`; throw `InvalidArgumentTypesError` if not
3. Evaluate `b` and deep-reduce all nested collection elements
4. Print formatted output
5. Return the deeply-reduced `b` term

### 1.2 Implement Deep Reduction

- [x] Create `_deepReduce(Term term)` helper method

**Deep reduction logic:**
```dart
Term _deepReduce(Term term) {
  final Term reduced = term.reduce();
  return switch (reduced) {
    ListTerm() => ListTerm(reduced.value.map(_deepReduce).toList()),
    VectorTerm() => VectorTerm(reduced.value.map(_deepReduce).toList()),
    StackTerm() => StackTerm(reduced.value.map(_deepReduce).toList()),
    QueueTerm() => QueueTerm(reduced.value.map(_deepReduce).toList()),
    SetTerm() => SetTerm(reduced.value.map(_deepReduce).toSet()),
    MapTerm() => MapTerm(Map.fromEntries(
        reduced.value.entries.map((e) => MapEntry(
          _deepReduce(e.key),
          _deepReduce(e.value),
        )),
      )),
    _ => reduced,  // Primitives, functions, etc. are already fully reduced
  };
}
```

### 1.3 Register in Standard Library

- [x] Add import: `import 'package:primal/compiler/library/debug/debug.dart';`
- [x] Add `const Debug()` to the function list in `StandardLibrary.get()`

**File to modify:** `lib/compiler/library/standard_library.dart`

---

## Phase 2: Documentation

### 2.1 Create Reference Documentation

- [x] Create new file: `docs/reference/debug.md`

**Content structure:**
- Signature
- Input/Output description
- Purity: Impure
- Behavior description
- Deep evaluation semantics
- Output format table
- Examples
- Error conditions

### 2.2 Update Reference Index

- [x] Add link to debug documentation in `docs/reference.md`
- [x] Insert in alphabetical order (between "Control" and "Directory" or at appropriate position)

---

## Phase 3: Tests

### 3.1 Runtime Tests

- [x] Create new file: `test/runtime/io/debug_test.dart`

**Test categories:**

#### Basic Functionality Tests
- [x] `debug` with number returns the number
- [x] `debug` with string returns the string
- [x] `debug` with boolean returns the boolean
- [x] `debug` prints correct format: `[debug] label: value\n`

#### Output Format Tests
- [x] Output format with number value
- [x] Output format with string value (no quotes in output)
- [x] Output format with boolean value
- [x] Output format with list
- [x] Output format with map
- [x] Output format with empty collections

#### Deep Evaluation Tests
- [x] `debug("x", [1 + 2])` prints `[debug] x: [3]` and returns `[3]`
- [x] `debug("x", {"sum": 1 + 2})` prints `[debug] x: {sum: 3}` and returns `{"sum": 3}`
- [x] Nested collections: `debug("x", [[1 + 2]])` prints `[debug] x: [[3]]`
- [x] Return value is usable: `list.first(debug("x", [1 + 2]))` returns `3`

#### Return Value Tests
- [x] Return value can be used in expressions
- [x] `num.add(debug("a", 5), debug("b", 10))` returns `15`
- [x] `debug` with function returns callable function
- [x] `debug("abs", num.abs)(-5)` returns `5`
- [x] `debug` with lambda returns callable lambda
- [x] Closures preserve captured bindings

#### Special Values Tests
- [x] `debug("inf", num.infinity())` works correctly
- [x] `debug("t", time.now())` prints Dart DateTime format
- [x] `debug("f", file.fromPath("/tmp/test.txt"))` prints file path
- [x] `debug("d", directory.fromPath("/tmp"))` prints directory path

#### Edge Cases Tests
- [x] Empty label: `debug("", 1)`
- [x] Unicode in labels: `debug("结果", 1)`
- [x] Nested debug: `debug("outer", debug("inner", 1))`
- [x] Empty list: `debug("empty list", [])`
- [x] Empty map: `debug("empty map", {})`
- [x] Empty set: `debug("empty set", set.new())`

#### Higher-Order Function Tests
- [x] `let f = debug in f("x", 1)` works correctly
- [x] `list.map([1, 2], (x) -> debug("item", x))` prints each item

### 3.2 Error Tests

**File to modify:** `test/runtime/core/runtime_errors_test.dart`

#### Type Error Tests (Runtime)
- [x] `debug(123, "value")` throws `InvalidArgumentTypesError`
- [x] `let f = debug in f(123, "value")` throws `InvalidArgumentTypesError`

#### Argument Count Errors (Runtime - indirect calls)
- [x] `let f = debug in f("only one")` throws `InvalidArgumentCountError`

#### Error Propagation Tests
- [x] `debug("label", num.div(1, 0))` throws `DivisionByZeroError`
- [x] `debug(error.throw(0, "fail"), num.div(1, 0))` throws custom error (label fails first)
- [x] `debug("ok", error.throw(0, "fail"))` throws custom error (value evaluated after label)

### 3.3 Semantic Analysis Tests

**File to modify:** `test/compiler/semantic_analyzer_test.dart`

#### Argument Count Errors (Semantic - direct calls)
- [x] `debug()` throws `InvalidNumberOfArgumentsError`
- [x] `debug("only one")` throws `InvalidNumberOfArgumentsError`
- [x] `debug("a", "b", "c")` throws `InvalidNumberOfArgumentsError`

### 3.4 Function Signature Tests

**File to modify:** `test/compiler/function_signature_test.dart`

- [x] Verify `debug` function signature is correctly registered (covered by semantic analysis tests)

---

## Phase 4: Final Verification

### 4.1 Code Quality

- [x] Run delta-review skill after implementation
- [x] Ensure explicit type annotations on all local variables
- [x] Ensure no abbreviations in identifiers

### 4.2 Cross-Reference Checklist

- [x] Implementation matches spec in `docs/roadmap/debugging.md`
- [x] All error messages use "debug" as function name
- [x] Platform support: CLI and web (via platform console abstraction)

---

## File Summary

### New Files
1. `lib/compiler/library/debug/debug.dart` - Main implementation
2. `docs/reference/debug.md` - Reference documentation
3. `test/runtime/io/debug_test.dart` - Runtime tests

### Modified Files
1. `lib/compiler/library/standard_library.dart` - Registration
2. `docs/reference.md` - Documentation index
3. `test/runtime/core/runtime_errors_test.dart` - Error tests
4. `test/compiler/semantic_analyzer_test.dart` - Semantic tests

---

## Implementation Order

1. Create `lib/compiler/library/debug/debug.dart` ✅
2. Register in `lib/compiler/library/standard_library.dart` ✅
3. Create `test/runtime/io/debug_test.dart` ✅
4. Add error tests to `test/runtime/core/runtime_errors_test.dart` ✅
5. Add semantic tests to `test/compiler/semantic_analyzer_test.dart` ✅
6. Create `docs/reference/debug.md` ✅
7. Update `docs/reference.md` ✅
