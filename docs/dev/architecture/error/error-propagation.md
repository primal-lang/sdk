---
title: Error Propagation
tags:
  - architecture
  - error-handling
sources:
  - lib/compiler/library/control/try.dart
  - lib/compiler/library/error/throw.dart
  - lib/main/main_cli.dart
  - lib/main/main_web.dart
---

# Error Propagation

**TLDR**: Errors propagate through the Dart exception mechanism. The `try()` function intercepts any error during evaluation and returns a fallback value. `CustomError` wraps user-thrown errors with a code and message. The CLI catches all errors at the top level and prints them; the web platform lets errors propagate to the JavaScript host.

## Error Flow Overview

Primal errors are Dart exceptions that propagate up the call stack until caught. The runtime does not use a separate error channel or result types; evaluation either succeeds and returns a `Term`, or throws an exception.

```
User code evaluation
        |
        v
   term.reduce()  ──throws──>  RuntimeError (or subclass)
        |                              |
        v                              v
    Result value              Caught by try() OR
                              propagates to top level
```

---

## The `try()` Function

The `try()` function provides error interception at the expression level.

**File**: `lib/compiler/library/control/try.dart`

```dart
class Try extends NativeFunctionTerm {
  const Try()
    : super(
        name: 'try',
        parameters: const [
          Parameter.any('a'),
          Parameter.any('b'),
        ],
      );

  @override
  Term term(List<Term> arguments) => TermWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );
}

class TermWithArguments extends NativeFunctionTermWithArguments {
  // ...

  @override
  Term reduce() {
    final Term a = arguments[0];
    final Term b = arguments[1];

    try {
      return a.reduce();
    } catch (_) {
      return b.reduce();
    }
  }
}
```

### Evaluation Semantics

1. The first argument `a` is evaluated (reduced).
2. If evaluation succeeds, its result is returned.
3. If evaluation throws **any** exception, it is caught and the second argument `b` is evaluated instead.
4. The fallback `b` is only evaluated if `a` fails (lazy evaluation).

### Key Characteristics

- **Catches all exceptions**: The `catch (_)` clause intercepts any Dart exception, not just Primal errors. This includes `RuntimeError`, `CompilationError`, and even unexpected `StateError` or `TypeError`.
- **Lazy fallback**: The second argument is not evaluated unless needed.
- **Expression-level**: `try()` is a function that returns a value, not a statement construct.

### Example

```primal
// Safe division with fallback
try(num.div(10, 0), 0)  // Returns 0 instead of throwing DivisionByZeroError

// Chain of fallbacks
try(map.at(config, "port"), try(env.get("PORT"), 8080))
```

---

## The `error.throw()` Function

The `error.throw()` function allows user code to raise custom errors.

**File**: `lib/compiler/library/error/throw.dart`

```dart
class Throw extends NativeFunctionTerm {
  const Throw()
    : super(
        name: 'error.throw',
        parameters: const [
          Parameter.any('a'),
          Parameter.string('b'),
        ],
      );

  // ...
}

class TermWithArguments extends NativeFunctionTermWithArguments {
  // ...

  @override
  Term reduce() {
    final Term a = arguments[0].reduce();
    final Term b = arguments[1].reduce();

    if (b is StringTerm) {
      throw CustomError(a, b.value);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
```

### CustomError Structure

`CustomError` extends `RuntimeError` and carries additional context:

```dart
class CustomError extends RuntimeError {
  final Term code;

  const CustomError(this.code, super.message);
}
```

- `code` - any value (number, string, list, etc.) serving as an error identifier
- `message` - the error description (inherited from `RuntimeError`)

### Example

```primal
// Throw an error with a numeric code
error.throw(404, "Resource not found")

// Throw an error with a string code
error.throw("VALIDATION_ERROR", "Email must contain @")

// Catch and provide fallback
try(error.throw(1, "fail"), "recovered")  // Returns "recovered"
```

---

## Top-Level Error Handling

### CLI Mode

**File**: `lib/main/main_cli.dart`

The CLI wraps all execution in a `try-catch` block:

```dart
void runCli(List<String> args, ...) {
  // ...
  try {
    // Compilation and execution
    final IntermediateRepresentation intermediateRepresentation = ...;
    final RuntimeFacade runtime = ...;

    if (runtime.hasMain) {
      _executeMain(...);
    } else {
      _runRepl(...);
    }
  } catch (e, stackTrace) {
    currentConsole.error(e);
    if (debug) {
      currentConsole.print('[debug] Stack trace:\n$stackTrace');
    }
  }
}
```

For REPL mode, each input evaluation is also wrapped:

```dart
void _runRepl(...) {
  console.prompt((input) {
    try {
      // Parse and evaluate
      final String result = runtime.evaluate(expression);
      console.print(result);
    } catch (e, stackTrace) {
      console.error(e);
      if (debugMode) {
        console.print('[debug] Stack trace:\n$stackTrace');
      }
    }
  });
}
```

#### Behavior Differences

| Mode  | Error Behavior                                                |
| ----- | ------------------------------------------------------------- |
| Batch | Error terminates the program after printing the error message |
| REPL  | Error is printed and the prompt continues                     |

In debug mode (`--debug` or `-d`), the full Dart stack trace is also printed.

### Web Mode

**File**: `lib/main/main_web.dart`

The web entry point does **not** wrap execution in try-catch. Errors propagate to the JavaScript host:

```dart
runtimeExecuteMain = (JSNumber codeId) {
  final IntermediateRepresentation intermediateRepresentation = ...;
  final RuntimeFacade runtime = ...;
  return runtime.executeMain().toJS;  // May throw
}.toJS;
```

This allows JavaScript code to catch and handle Primal errors using standard JavaScript `try-catch`:

```javascript
try {
  const result = runtimeExecuteMain(codeId);
} catch (e) {
  console.error("Primal error:", e);
}
```

---

## Error Propagation Through the Runtime

### Reduction Chain

When a term is reduced, errors propagate through the reduction chain:

```
CallTerm.reduce()
    |
    v
FunctionTerm.apply()
    |
    v
Body term substitution and reduction
    |
    v
Nested term.reduce() calls
    |
    v
Native function throws ──> Exception propagates up
```

### Example: Division by Zero

```primal
// Expression: num.div(10, num.div(5, 0))
```

1. Outer `num.div` receives arguments `10` and `num.div(5, 0)`
2. Arguments are reduced (call-by-value)
3. Inner `num.div(5, 0)` throws `DivisionByZeroError`
4. Error propagates up through the outer `num.div`
5. Error propagates up through `CallTerm.reduce()`
6. Error reaches `RuntimeFacade.evaluate()` or `try()` boundary

### Recursion Limit

**File**: `lib/compiler/runtime/term.dart`

Function calls track recursion depth:

```dart
abstract class FunctionTerm extends Term {
  static const int maxRecursionDepth = 1000;
  static int _currentDepth = 0;

  static bool incrementDepth() {
    if (_currentDepth >= maxRecursionDepth) {
      throw RecursionLimitError(limit: maxRecursionDepth);
    }
    _currentDepth++;
    return true;
  }

  static void decrementDepth() {
    _currentDepth--;
  }
}
```

`CustomFunctionTerm.apply()` and `LambdaTerm.apply()` use `try-finally` to ensure the depth is decremented even on error:

```dart
@override
Term apply(List<Term> arguments) {
  // ...
  FunctionTerm.incrementDepth();
  try {
    // ... evaluate ...
  } finally {
    FunctionTerm.decrementDepth();
  }
}
```

This prevents depth counter corruption when errors propagate.

---

## Depth Reset on Evaluation Start

Before each evaluation in `RuntimeFacade.evaluateToTerm()`:

```dart
Term evaluateToTerm(Expression expression) {
  // Reset recursion depth at the start to clear any stale state from
  // previous failed evaluations.
  FunctionTerm.resetDepth();

  // ... semantic analysis and lowering ...

  return lowered.reduce();
}
```

This ensures a failed evaluation (e.g., caught by `try()`) does not leave the depth counter in a corrupted state for subsequent evaluations.

---

## Error Handling Patterns

### Pattern 1: Fail-Fast

Let errors propagate and handle them at the top level:

```primal
// If validation fails, error propagates and terminates
validateInput(x) =
  if (x < 0) error.throw("INVALID", "x must be non-negative")
  else x

processData(x) =
  let validated = validateInput(x)
  in validated * 2

main() = processData(-1)  // Terminates with error
```

### Pattern 2: Local Recovery

Catch errors close to the source and provide defaults:

```primal
safeGet(map, key, default) = try(map.at(map, key), default)

main() =
  let config = {"port": 8080}
  in safeGet(config, "host", "localhost")  // Returns "localhost"
```

### Pattern 3: Error Transformation

Catch and re-throw with more context:

```primal
loadConfig(path) =
  try(
    json.decode(file.read(path)),
    error.throw("CONFIG_ERROR", str.concat("Failed to load: ", path))
  )
```

---

## Implementation Notes

### Why `catch (_)` in `try()`?

The `try()` function uses a catch-all clause to ensure it intercepts all failure modes:

- `RuntimeError` and subclasses (expected user-facing errors)
- `CompilationError` (shouldn't occur at runtime, but defensive)
- Dart internal errors like `StateError`, `TypeError` (shouldn't occur, but defensive)

This makes `try()` a robust recovery mechanism regardless of error source.

### Single-Threaded Assumption

The static recursion depth counter assumes single-threaded execution. The comment in `FunctionTerm`:

> **Threading assumption**: The static recursion tracking (`_currentDepth`) assumes single-threaded execution. The Primal runtime is designed for single-threaded use only.

Sharing a `RuntimeFacade` across threads would cause incorrect recursion limit enforcement.

---

## See Also

- [[dev/architecture/error/error-hierarchy]] - Error class hierarchy and types
- [[dev/architecture/pipeline/runtime]] - Runtime evaluation model
- [[dev/architecture/pipeline/pipeline]] - Compiler pipeline overview
