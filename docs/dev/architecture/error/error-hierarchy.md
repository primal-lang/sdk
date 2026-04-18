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
  const RuntimeError(String message) : super('Runtime error', message);
}
```

### Type and Argument Errors

| Error                               | When Thrown                                        |
| ----------------------------------- | -------------------------------------------------- |
| `InvalidArgumentTypesError`         | Wrong argument types for a native function         |
| `InvalidArgumentCountError`         | Wrong number of arguments at runtime               |
| `IterablesWithDifferentLengthError` | Mismatched collection lengths (e.g., `vector.add`) |

### Value Errors

| Error                      | When Thrown                                    |
| -------------------------- | ---------------------------------------------- |
| `InvalidLiteralValueError` | Invalid literal value during term construction |
| `InvalidValueError`        | Invalid computed value during formatting       |

### Collection Access Errors

| Error                   | When Thrown                                   |
| ----------------------- | --------------------------------------------- |
| `InvalidMapIndexError`  | Key not found in map via `map.at`             |
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
| `DivisionByZeroError`          | Division by zero in `num.div`, `num.mod`   |
| `InvalidNumericOperationError` | Domain error (e.g., `log(-1)`, `sqrt(-1)`) |

### Parsing Errors

| Error              | When Thrown                                          |
| ------------------ | ---------------------------------------------------- |
| `ParseError`       | Failed string conversion (e.g., `to.integer("abc")`) |
| `JsonParseError`   | Invalid JSON string in `json.decode`                 |
| `Base64ParseError` | Invalid Base64 string in `base64.decode`             |

### Recursion Error

| Error                 | When Thrown                             |
| --------------------- | --------------------------------------- |
| `RecursionLimitError` | Maximum recursion depth (1000) exceeded |

### User-Thrown Error

| Error         | When Thrown                                        |
| ------------- | -------------------------------------------------- |
| `CustomError` | Explicitly raised via `error.throw(code, message)` |

**File**: `lib/compiler/library/error/throw.dart`

`CustomError` extends `RuntimeError` and adds a `code` field:

```dart
class CustomError extends RuntimeError {
  final Term code;

  const CustomError(this.code, super.message);
}
```

The `code` can be any value (number, string, list, etc.), allowing users to attach structured error identifiers.

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

| Property    | Type     | Description                                         |
| ----------- | -------- | --------------------------------------------------- |
| `errorType` | `String` | Category label (e.g., `"Error"`, `"Runtime error"`) |
| `message`   | `String` | Human-readable description of the error             |

Additionally:

- `CustomError` adds `code: Term` for user-defined error identifiers
- All errors implement `Exception` for Dart interoperability
- The `toString()` method returns `'$errorType: $message'`

---

## See Also

- [[dev/architecture/error/error-propagation]] - How errors bubble through the runtime
- [[dev/compiler]] - Compiler pipeline overview
- [[dev/compiler/runtime]] - Runtime evaluation model
