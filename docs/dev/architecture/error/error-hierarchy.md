---
title: Error Hierarchy
tags:
  - architecture
  - error-handling
sources:
  - lib/compiler/errors/
  - lib/compiler/warnings/
---

# Error Hierarchy

**TLDR**: All errors extend `GenericError`, which branches into `CompilationError` (for lexical, syntactic, and semantic errors caught at compile time), `RuntimeError` (for errors detected during evaluation), and `GenericWarning` (for non-fatal diagnostics).

## Base Class

All diagnostics in Primal extend from `GenericError`:

```dart
class GenericError implements Exception {
  final String errorType;
  final String message;

  const GenericError(this.errorType, this.message);

  @override
  String toString() => '$errorType: $message';
}
```

**Properties**:

- `errorType` - a category label used in the string representation (e.g., `"Error"`, `"Runtime error"`, `"Warning"`)
- `message` - descriptive text explaining what went wrong

---

## Hierarchy Overview

```
GenericError
├── CompilationError .......... Errors detected during compilation
│   ├── LexicalError .......... Tokenization errors
│   │   ├── InvalidCharacterError
│   │   ├── UnterminatedStringError
│   │   ├── UnterminatedCommentError
│   │   ├── InvalidEscapeSequenceError
│   │   ├── InvalidHexEscapeError
│   │   ├── InvalidBracedEscapeError
│   │   └── InvalidCodePointError
│   ├── SyntacticError ........ Parsing errors
│   │   ├── InvalidTokenError
│   │   ├── ExpectedTokenError
│   │   ├── UnexpectedEndOfFileError
│   │   └── UnexpectedTokenError
│   └── SemanticError ......... Validation errors
│       ├── DuplicatedFunctionError
│       ├── DuplicatedParameterError
│       ├── UndefinedIdentifierError
│       ├── UndefinedFunctionError
│       ├── InvalidNumberOfArgumentsError
│       ├── NotCallableError
│       ├── NotIndexableError
│       ├── CannotRedefineStandardLibraryError
│       ├── CannotDeleteStandardLibraryError
│       ├── FunctionNotFoundError
│       ├── CannotRenameStandardLibraryError
│       ├── FunctionAlreadyExistsError
│       ├── ShadowedLetBindingError
│       ├── DuplicatedLetBindingError
│       ├── DuplicatedLambdaParameterError
│       └── ShadowedLambdaParameterError
├── RuntimeError .............. Errors detected during evaluation
│   ├── InvalidArgumentTypesError
│   ├── InvalidArgumentCountError
│   ├── IterablesWithDifferentLengthError
│   ├── InvalidLiteralValueError
│   ├── InvalidValueError
│   ├── InvalidMapIndexError
│   ├── ElementNotFoundError
│   ├── NotFoundInScopeError
│   ├── InvalidFunctionError
│   ├── UnimplementedFunctionWebError
│   ├── EmptyCollectionError
│   ├── IndexOutOfBoundsError
│   ├── NegativeIndexError
│   ├── DivisionByZeroError
│   ├── InvalidNumericOperationError
│   ├── ParseError
│   ├── JsonParseError
│   ├── Base64ParseError
│   ├── RecursionLimitError
│   ├── NegativeDurationError
│   ├── AssertionFailedError ... renders as "Assertion error"
│   ├── AssertionArgumentError
│   └── CustomError
└── GenericWarning ............ Non-fatal diagnostics
```

---

## Compilation Errors

`CompilationError` is the base class for all errors detected during the compilation pipeline. These errors abort compilation and prevent execution.

**File**: `lib/compiler/errors/generic_error.dart`

```dart
class CompilationError extends GenericError {
  const CompilationError(String message) : super('Error', message);
}
```

### Lexical Errors

Detected by the lexical analyzer (tokenizer). These occur when the source text cannot be converted into valid tokens.

**File**: `lib/compiler/errors/lexical_error.dart`

| Error                        | When Thrown                                            |
| ---------------------------- | ------------------------------------------------------ |
| `InvalidCharacterError`      | Unrecognized character in source (e.g., `@`, `$`)      |
| `UnterminatedStringError`    | String literal missing closing quote                   |
| `UnterminatedCommentError`   | Multi-line comment missing closing `*/`                |
| `InvalidEscapeSequenceError` | Unrecognized escape sequence (e.g., `\z`)              |
| `InvalidHexEscapeError`      | Malformed hex escape (e.g., `\xGG`, incomplete `\u00`) |
| `InvalidBracedEscapeError`   | Malformed braced Unicode escape (e.g., `\u{GGGG}`)     |
| `InvalidCodePointError`      | Code point exceeds maximum U+10FFFF                    |

### Syntactic Errors

Detected by the syntactic analyzer (parser). These occur when the token sequence does not form a valid program structure.

**File**: `lib/compiler/errors/syntactic_error.dart`

| Error                      | When Thrown                                                    |
| -------------------------- | -------------------------------------------------------------- |
| `InvalidTokenError`        | Unexpected token in context                                    |
| `ExpectedTokenError`       | Missing required token (e.g., missing `=` after function name) |
| `UnexpectedEndOfFileError` | Premature end of input while parsing                           |
| `UnexpectedTokenError`     | Trailing tokens after a complete expression                    |

### Semantic Errors

Detected by the semantic analyzer. These occur when the program structure is syntactically valid but violates semantic rules.

**File**: `lib/compiler/errors/semantic_error.dart`

| Error                                | When Thrown                                             |
| ------------------------------------ | ------------------------------------------------------- |
| `DuplicatedFunctionError`            | Two functions with identical names                      |
| `DuplicatedParameterError`           | Parameter name repeated in function signature           |
| `UndefinedIdentifierError`           | Reference to unknown variable or function               |
| `UndefinedFunctionError`             | Call to unknown function                                |
| `InvalidNumberOfArgumentsError`      | Argument count mismatch at compile time                 |
| `NotCallableError`                   | Attempting to call a non-callable literal (e.g., `5()`) |
| `NotIndexableError`                  | Attempting to index a non-indexable literal             |
| `CannotRedefineStandardLibraryError` | Redefining a standard library function in REPL          |
| `CannotDeleteStandardLibraryError`   | Attempting to delete a standard library function        |
| `FunctionNotFoundError`              | Function not found during REPL `:delete` or `:rename`   |
| `CannotRenameStandardLibraryError`   | Attempting to rename a standard library function        |
| `FunctionAlreadyExistsError`         | Target name already in use during `:rename`             |
| `ShadowedLetBindingError`            | Let binding shadows a function parameter                |
| `DuplicatedLetBindingError`          | Same name bound twice in one let expression             |
| `DuplicatedLambdaParameterError`     | Lambda parameter name repeated                          |
| `ShadowedLambdaParameterError`       | Lambda parameter shadows an outer binding               |

---

## Runtime Errors

`RuntimeError` is the base class for errors detected during program evaluation. These errors occur after successful compilation when a specific operation fails.

**File**: `lib/compiler/errors/runtime_error.dart`

```dart
class RuntimeError extends GenericError {
  const RuntimeError(String message, {String category = 'Runtime error'})
    : super(category, message);
}
```

The optional `category` parameter means the hierarchy is no longer "one category
per base class": a `RuntimeError` subclass can render under its own label. Only
`AssertionFailedError` uses it today; every other subclass takes the default and
still prints `Runtime error: …`.

### Type and Argument Errors

| Error                               | When Thrown                                        |
| ----------------------------------- | -------------------------------------------------- |
| `InvalidArgumentTypesError`         | Wrong argument types for a native function         |
| `InvalidArgumentCountError`         | Wrong number of arguments at runtime               |
| `IterablesWithDifferentLengthError` | Mismatched collection lengths (e.g., `vector_add`) |

### Value Errors

| Error                      | When Thrown                                    |
| -------------------------- | ---------------------------------------------- |
| `InvalidLiteralValueError` | Invalid literal value during term construction |
| `InvalidValueError`        | Invalid computed value during formatting       |

### Collection Access Errors

| Error                   | When Thrown                                   |
| ----------------------- | --------------------------------------------- |
| `InvalidMapIndexError`  | Key not found in map via `map_at`             |
| `ElementNotFoundError`  | Element not found at index                    |
| `EmptyCollectionError`  | Accessing first/last/peek on empty collection |
| `IndexOutOfBoundsError` | Index outside valid range                     |
| `NegativeIndexError`    | Negative index where not allowed              |

### Function Errors

| Error                           | When Thrown                                   |
| ------------------------------- | --------------------------------------------- |
| `NotFoundInScopeError`          | Function reference not found in runtime scope |
| `InvalidFunctionError`          | Callee is not a function                      |
| `UnimplementedFunctionWebError` | I/O function called on web platform           |

### Numeric Errors

| Error                          | When Thrown                                |
| ------------------------------ | ------------------------------------------ |
| `DivisionByZeroError`          | Division by zero in `num_div`, `num_mod`   |
| `InvalidNumericOperationError` | Domain error (e.g., `log(-1)`, `sqrt(-1)`) |

### Parsing Errors

| Error              | When Thrown                                          |
| ------------------ | ---------------------------------------------------- |
| `ParseError`       | Failed string conversion (e.g., `to_integer("abc")`) |
| `JsonParseError`   | Invalid JSON string in `json_decode`                 |
| `Base64ParseError` | Invalid Base64 string in `base64_decode`             |

### Recursion Error

| Error                 | When Thrown                             |
| --------------------- | --------------------------------------- |
| `RecursionLimitError` | Maximum recursion depth (1000) exceeded |

### User-Thrown Error

| Error         | When Thrown                                        |
| ------------- | -------------------------------------------------- |
| `CustomError` | Explicitly raised via `error_throw(code, message)` |

**File**: `lib/compiler/library/error/throw.dart`

`CustomError` extends `RuntimeError` and adds a `code` field:

```dart
class CustomError extends RuntimeError {
  final Term code;

  const CustomError(this.code, super.message);
}
```

The `code` can be any value (number, string, list, etc.), allowing users to attach structured error identifiers.

### Assertion Errors

| Error                    | When Thrown                                          |
| ------------------------ | ---------------------------------------------------- |
| `AssertionFailedError`   | An assertion's expectation was not met               |
| `AssertionArgumentError` | An assertion was given an argument of the wrong type |

**File**: `lib/compiler/errors/runtime_error.dart`, raised from `lib/compiler/library/assert/`

`AssertionFailedError` is the only subclass that overrides the category:

```dart
class AssertionFailedError extends RuntimeError {
  AssertionFailedError({
    required String function,
    required String actual,
    required String expected,
  }) : super(
         '"$function" failed: expected $expected, actual $actual',
         category: 'Assertion error',
       );
}
```

It stores none of its three arguments — nothing reads them back, so it keeps
only the composed message. Rendering under its own category is what lets the
`--test` runner and the reader tell an unmet expectation apart from a genuine
error. Values are rendered with `Runtime.render`, so a string keeps its quotes.

`AssertionArgumentError` is the opposite: a pure recognisability wrapper that
adds no message of its own.

```dart
class AssertionArgumentError extends RuntimeError {
  AssertionArgumentError(InvalidArgumentTypesError cause)
    : super(cause.message);
}
```

It forwards `cause.message` verbatim and keeps the inherited `Runtime error`
category, so it renders byte-identically to the `InvalidArgumentTypesError` it
wraps. It exists solely so `assert_throws` can refuse to absorb it: a misused
nested assertion (`assert_throws(assert_true(1))`) must be an error, while a
type error raised by the code under test (`assert_throws(num_add(1, "x"))`)
must still pass. The two are the same Dart class, so they can only be
distinguished by who raised them.

That is also why `InvalidArgumentTypesError` retains a `function` field. The
assertion helpers wrap only errors whose `function` is their own name: an
`assert_equal` over collections reduces its elements lazily inside `CompEq`, so
a type error from the _expression under test_ surfaces at exactly the same
`catch` as a genuine element-kind mismatch. Comparing the name is what separates
`assert_equal([1], ["x"])` (the assertion's own error, wrapped) from
`assert_equal([num_add(1, "x")], [2])` (the code under test's error, rethrown
unchanged).

---

## Warnings

`GenericWarning` extends `GenericError` for non-fatal diagnostics that do not abort compilation.

**File**: `lib/compiler/warnings/generic_warning.dart`

```dart
class GenericWarning extends GenericError {
  const GenericWarning(String message) : super('Warning', message);
}
```

Warnings are collected during semantic analysis and reported to the user without stopping execution. Currently used for detecting unused parameters and other style issues.

---

## Error Properties Summary

All error classes share these characteristics:

| Property    | Type     | Description                                                              |
| ----------- | -------- | ------------------------------------------------------------------------ |
| `errorType` | `String` | Category label (e.g., `"Error"`, `"Runtime error"`, `"Assertion error"`) |
| `message`   | `String` | Human-readable description of the error                                  |

Additionally:

- `CustomError` adds `code: Term` for user-defined error identifiers
- `InvalidArgumentTypesError` adds `function: String`, so a caller can tell an
  error it raised itself apart from one that propagated through it
- All errors implement `Exception` for Dart interoperability
- The `toString()` method returns `'$errorType: $message'`

---

## See Also

- [[dev/architecture/error/error-propagation]] - How errors bubble through the runtime
- [[dev/architecture/pipeline/pipeline]] - Compiler pipeline overview
- [[dev/architecture/pipeline/runtime]] - Runtime evaluation model
- [[lang/reference/core/assert]] - The assertions that raise the two assertion error types
