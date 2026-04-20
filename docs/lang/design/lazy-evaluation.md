---
title: Lazy Evaluation
tags:
  - design
  - evaluation
sources:
  - lib/compiler/library/operators/
  - lib/compiler/library/control/
---

# Lazy Evaluation

**TLDR**: Primal uses lazy evaluation (thunks) for specific constructs like short-circuit operators and conditionals, where values are computed only when needed and cached for subsequent access.

## Overview

Primal primarily uses **eager evaluation** (also called strict or call-by-value), where function arguments are fully evaluated before being passed to a function. However, certain constructs use **lazy evaluation**, where expressions are wrapped in thunks and only evaluated when their value is actually needed.

## What is a Thunk?

A thunk is an unevaluated expression that is stored for later computation. When you write an expression that uses lazy evaluation, Primal wraps that expression in a thunk instead of immediately computing its value. The first time the thunk's value is needed, it is evaluated and the result is cached. Subsequent accesses return the cached value without re-evaluation.

## Short-Circuit Operators

The primary example of lazy evaluation in Primal is the short-circuit logical operators `&&` (and) and `||` (or).

### And Operator (`&&`)

The second operand is only evaluated if the first operand is `true`:

```
true && expensive() // expensive() is evaluated
false && expensive() // expensive() is NOT evaluated, returns false immediately
```

This is useful for guarding expressions that should only run under certain conditions:

```
list.isNotEmpty(items) && list.first(items) > 0
```

If `items` is empty, `list.first(items)` would throw an error. But because `&&` uses lazy evaluation, the second expression is never evaluated when the list is empty.

### Or Operator (`||`)

The second operand is only evaluated if the first operand is `false`:

```
false || expensive() // expensive() is evaluated
true || expensive() // expensive() is NOT evaluated, returns true immediately
```

This is useful for providing fallback values or alternative conditions:

```
cache.exists(key) || database.fetch(key)
```

The database fetch only happens if the cache check returns `false`.

### Demonstrating Short-Circuit Behavior

You can observe lazy evaluation by using `error.throw` as the second operand:

```
false && error.throw(-1, "Never thrown") // returns false (no error)
true || error.throw(-1, "Never thrown")  // returns true (no error)
```

If the second operand were eagerly evaluated, these expressions would throw errors. Instead, they return immediately because the second operand is never needed.

## Strict Alternatives

Primal also provides strict (eager) versions of logical operators for cases where you want both operands evaluated regardless of the first operand's value:

| Lazy (Short-Circuit) | Strict (Eager) |
| -------------------- | -------------- |
| `&&`, `and`          | `&`            |
| `\|\|`, `or`         | `\|`           |

Use strict operators when both operands have side effects that must occur, or when you explicitly want eager evaluation semantics.

```
true & logAndReturnTrue()  // logAndReturnTrue() is always called
true && logAndReturnTrue() // logAndReturnTrue() is always called (first is true)

false & logAndReturnTrue()  // logAndReturnTrue() is always called
false && logAndReturnTrue() // logAndReturnTrue() is NOT called (short-circuits)
```

## Conditionals

The `if-else` expression also uses lazy evaluation for its branches:

```
if (condition) thenBranch else elseBranch
```

Only one branch is evaluated based on the condition:

```
if (true) "yes" else error.throw(-1, "Never thrown")  // returns "yes"
if (false) error.throw(-1, "Never thrown") else "no"  // returns "no"
```

This allows you to safely write expressions that would fail in the non-taken branch:

```
if (n == 0) 0 else 100 / n
```

When `n` is zero, the division is never attempted because the `else` branch is not evaluated.

## When Evaluation Applies

| Construct                 | Evaluation Strategy           |
| ------------------------- | ----------------------------- |
| Function arguments        | Eager (call-by-value)         |
| `&&`, `and`, `\|\|`, `or` | Lazy (second operand)         |
| `&`, `\|`                 | Eager (both operands)         |
| `if-else` branches        | Lazy (non-taken branch)       |
| `let` bindings            | Eager (sequential)            |
| `try` arguments           | Lazy (fallback only on error) |

## Practical Applications

### Guard Patterns

Protect against invalid operations:

```
hasValue(x) && process(x)
```

### Default Values

Provide fallbacks that are only computed when needed:

```
getUserSetting(key) || getDefaultSetting(key)
```

### Conditional Computation

Avoid expensive computations when unnecessary:

```
if (useCache) cachedResult else computeExpensiveResult()
```

### Error Handling with Try

The `try` function lazily evaluates its fallback:

```
try(riskyOperation(), safeDefault())
```

The `safeDefault()` is only evaluated if `riskyOperation()` throws an error.

## Related Topics

- [[lang/reference/operators]] - Operator reference including lazy and strict variants
- [[lang/reference/logic]] - Boolean logic functions with evaluation details
- [[lang/reference/control]] - Control flow constructs
