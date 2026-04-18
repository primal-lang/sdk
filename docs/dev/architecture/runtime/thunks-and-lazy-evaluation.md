---
title: Thunks and Lazy Evaluation
tags:
  - architecture
  - evaluation
sources:
  - lib/compiler/runtime/term.dart
  - lib/compiler/library/control/if.dart
  - lib/compiler/library/control/try.dart
  - lib/compiler/library/logic/bool_and.dart
  - lib/compiler/library/logic/bool_or.dart
---

# Thunks and Lazy Evaluation

**TLDR**: Primal achieves lazy evaluation through deferred `reduce()` calls on unevaluated `Term` objects, where certain native functions selectively evaluate their arguments only when needed.

## Overview

Primal primarily uses eager evaluation (call-by-value), but specific constructs defer argument evaluation to support short-circuit operators, conditionals, and error handling. Rather than using an explicit `ThunkTerm` wrapper class, Primal implements lazy evaluation by passing unevaluated `Term` objects to native functions and letting those functions decide when to call `reduce()`.

## How Lazy Evaluation Works

### The Term as Implicit Thunk

In Primal's runtime, any `Term` that has not been reduced functions as a thunk. The `reduce()` method forces evaluation:

```dart
// From lib/compiler/runtime/term.dart
abstract class Term {
  Term reduce() => this;  // Default: already a value
}
```

Value terms (literals, collections) return themselves when reduced. Computation terms (`CallTerm`, `LetTerm`) perform their computation when `reduce()` is called. By holding onto an unreduced `Term` and calling `reduce()` only when needed, native functions implement lazy evaluation.

### Selective Argument Evaluation

The key to lazy evaluation is that `NativeFunctionTerm.substitute()` resolves arguments from bindings but does not reduce them:

```dart
// From lib/compiler/runtime/term.dart
abstract class NativeFunctionTerm extends FunctionTerm {
  @override
  Term substitute(Bindings bindings) {
    final List<Term> arguments = parameters
        .map((e) => bindings.get(e.name))
        .toList();

    return term(arguments);  // Arguments are NOT reduced here
  }

  Term term(List<Term> arguments);
}
```

The `term()` method receives the raw, unreduced arguments. The `NativeFunctionTermWithArguments.reduce()` override then decides which arguments to evaluate and when.

## Where Lazy Evaluation Is Used

### Conditional Expression (`if`)

The `if` function evaluates only the taken branch:

```dart
// From lib/compiler/library/control/if.dart
@override
Term reduce() {
  final Term a = arguments[0].reduce();  // Always evaluate condition
  final Term b = arguments[1];            // Leave then-branch unreduced
  final Term c = arguments[2];            // Leave else-branch unreduced

  if (a is BooleanTerm) {
    if (a.value) {
      return b.reduce();  // Evaluate then-branch only if true
    } else {
      return c.reduce();  // Evaluate else-branch only if false
    }
  } else {
    throw InvalidArgumentTypesError(...);
  }
}
```

This enables safe expressions like `if (n == 0) 0 else 100 / n` where the division is never attempted when `n` is zero.

### Short-Circuit And (`&&`, `bool.and`)

The second operand is evaluated only if the first is `true`:

```dart
// From lib/compiler/library/logic/bool_and.dart
static BooleanTerm execute({
  required FunctionTerm function,
  required List<Term> arguments,
}) {
  final Term a = arguments[0].reduce();  // Evaluate first operand

  if (a is BooleanTerm) {
    if (a.value) {
      final Term b = arguments[1].reduce();  // Evaluate second only if first is true
      if (b is BooleanTerm) {
        return b;
      } else {
        throw InvalidArgumentTypesError(...);
      }
    } else {
      return const BooleanTerm(false);  // Short-circuit: return false immediately
    }
  } else {
    throw InvalidArgumentTypesError(...);
  }
}
```

### Short-Circuit Or (`||`, `bool.or`)

The second operand is evaluated only if the first is `false`:

```dart
// Pattern from lib/compiler/library/logic/bool_or.dart
if (a.value) {
  return const BooleanTerm(true);  // Short-circuit: return true immediately
} else {
  final Term b = arguments[1].reduce();  // Evaluate second only if first is false
  // ...
}
```

### Try-Catch (`try`)

The fallback expression is evaluated only if the primary expression throws:

```dart
// From lib/compiler/library/control/try.dart
@override
Term reduce() {
  final Term a = arguments[0];
  final Term b = arguments[1];

  try {
    return a.reduce();  // Try primary expression
  } catch (_) {
    return b.reduce();  // Evaluate fallback only on error
  }
}
```

## No Caching in This Model

Unlike Haskell-style thunks that memoize their result, Primal's implicit thunks do not cache. Each `reduce()` call recomputes the value. This is acceptable because:

1. **Single evaluation context**: Each argument position is evaluated at most once in the constructs that use lazy evaluation.
2. **Explicit sharing via `let`**: Users who need to share a computation can use `let` bindings, which evaluate once and substitute the value.

```primal
// Without let: expensive() called twice
if (expensive() > 0) expensive() + 1 else 0

// With let: expensive() called once
let result = expensive() in
if (result > 0) result + 1 else 0
```

## Strict Alternatives

Primal provides strict (eager) versions of logical operators for cases where both operands should always be evaluated:

| Lazy (Short-Circuit) | Strict (Eager) |
| -------------------- | -------------- |
| `&&`, `and`          | `&`            |
| `\|\|`, `or`         | `\|`           |

Strict operators use `BoolAndStrict` and `BoolOrStrict`, which reduce both arguments before checking values.

## Evaluation Summary

| Construct     | First Argument | Second Argument        | Third Argument          |
| ------------- | -------------- | ---------------------- | ----------------------- |
| `if`          | Always         | Only if condition true | Only if condition false |
| `&&`, `and`   | Always         | Only if first is true  | N/A                     |
| `\|\|`, `or`  | Always         | Only if first is false | N/A                     |
| `try`         | Always         | Only if first throws   | N/A                     |
| `&`, `\|`     | Always         | Always                 | N/A                     |
| Other natives | Always         | Always                 | Always                  |

## Implementation Pattern

To implement lazy evaluation in a new native function:

1. In `reduce()`, access arguments via the `arguments` list without calling `reduce()`.
2. Call `reduce()` on each argument only when its value is actually needed.
3. Perform type checking after reducing, not before.

```dart
class LazyFunction extends NativeFunctionTermWithArguments {
  @override
  Term reduce() {
    final Term condition = arguments[0].reduce();  // Evaluate immediately

    if (condition is BooleanTerm && condition.value) {
      return arguments[1].reduce();  // Evaluate lazily
    } else {
      return arguments[2].reduce();  // Evaluate lazily
    }
  }
}
```
