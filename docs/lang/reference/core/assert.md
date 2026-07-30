---
title: Assert
tags:
  - reference
  - testing
sources:
  - lib/compiler/library/assert/
  - lib/compiler/errors/runtime_error.dart
  - lib/main/main_cli.dart
---

# Assert

**TLDR**: Five assertion functions that return `true` when their expectation holds and raise an `Assertion error` when it does not, paired with the `primal --test file.prm` runner that discovers and executes zero-argument `test.` functions.

Number of functions: 5

## Functions

### Assert Equal

- **Signature:** `assert.equal(a: Equatable, b: Equatable): Boolean`
- **Input:** The actual value and the expected value
- **Output:** `true` if the two values are equal. Throws an assertion error otherwise
- **Purity:** Pure
- **Description:** Equality is exactly that of `comp.eq` and `==`, including its
  quirks: `1` and `1.0` are equal, collections of different length compare
  unequal rather than erroring, and comparing values of different kinds is an
  error rather than a failure.
- **Example:**

```
assert.equal(1 + 1, 2) // returns true
assert.equal(3, 2)     // Assertion error: "assert.equal" failed: expected 2, actual 3
```

### Assert Not Equal

- **Signature:** `assert.notEqual(a: Equatable, b: Equatable): Boolean`
- **Input:** The actual value and the value it must differ from
- **Output:** `true` if the two values differ. Throws an assertion error otherwise
- **Purity:** Pure
- **Description:** The mirror of `assert.equal`, delegating to `comp.neq`. A
  type mismatch is still an **error**, never a passing "not equal".
- **Example:**

```
assert.notEqual(1, 2) // returns true
assert.notEqual(1, 1) // Assertion error: "assert.notEqual" failed: expected not 1, actual 1
```

### Assert True

- **Signature:** `assert.true(a: Boolean): Boolean`
- **Input:** A boolean condition
- **Output:** `true` if the condition is `true`. Throws an assertion error otherwise
- **Purity:** Pure
- **Description:** A non-boolean argument is a runtime type error, exactly as
  for `if`.
- **Example:**

```
assert.true(str.startsWith("abc", "a")) // returns true
assert.true(false)                      // Assertion error: "assert.true" failed: expected true, actual false
```

### Assert False

- **Signature:** `assert.false(a: Boolean): Boolean`
- **Input:** A boolean condition
- **Output:** `true` if the condition is `false`. Throws an assertion error otherwise
- **Purity:** Pure
- **Example:**

```
assert.false(str.isEmpty("abc")) // returns true
assert.false(true)               // Assertion error: "assert.false" failed: expected false, actual true
```

### Assert Throws

- **Signature:** `assert.throws(a: Any): Boolean`
- **Input:** An expression expected to raise an error
- **Output:** `true` if evaluating the expression raises a runtime error. Throws an assertion error otherwise
- **Purity:** Pure
- **Description:** Narrower than `try`. It absorbs ordinary runtime errors —
  including those raised by `error.throw` — but deliberately re-raises three
  things unchanged: a nested assertion failure, a nested assertion *misuse*
  (such as `assert.throws(assert.true(1))`), and a recursion-limit error. It
  cannot assert *which* error was raised, so an expression that fails for the
  wrong reason still passes.
- **Example:**

```
assert.throws(to.number("not a number")) // returns true
assert.throws(42)                        // Assertion error: "assert.throws" failed: expected a thrown error, actual 42
```

## Composing Assertions

Primal has no statement sequencing, so a test body is a single expression. Every
assertion returns `true` on success, which makes `&&` the natural way to chain
several of them:

```
test.string.basics() =
    assert.equal(str.length("abc"), 3) &&
    assert.notEqual(str.length("abc"), 0) &&
    assert.true(str.startsWith("abc", "a")) &&
    assert.false(str.isEmpty("abc"))
```

Chaining works because evaluation is left to right and assertions never return
`false`; the first assertion to fail throws, so the rest never run. A test
therefore reports one failure at a time.

## Failures Versus Errors

Only the assertion functions raise `Assertion error`. That is what lets the
runner distinguish an unmet expectation from a genuine problem:

| Situation                                            | Reported as |
| ---------------------------------------------------- | ----------- |
| An assertion's expectation is not met                | **fail**    |
| An assertion is given the wrong argument type        | **error**   |
| The code under test raises any other error           | **error**   |
| `error.throw` is called by hand                      | **error**   |

The last row matters in practice: hand-writing
`if (a == b) true else error.throw("assertion", "…")` is *not* equivalent to
`assert.equal(a, b)`. It raises a custom error, so the runner reports an error
rather than a failure, and the message cannot report the actual and expected
values. There is no way to attach a custom message to an assertion.

## Limitations

`assert.throws` cannot be wrapped in a user-defined function. Arguments to
custom functions are evaluated at the call boundary, so the error escapes before
`assert.throws` ever runs — the same limitation that already applies to `if` and
`try`. See [[lang/design/lazy-evaluation]].

```
expectThrow(e) = assert.throws(e)
test.x() = expectThrow(to.number("z"))   // errors; does not pass
```

`try` catches everything, assertion failures included, so
`try(assert.equal(1, 2), true)` passes. See
[[lang/design/error-handling]].

## Running Tests

```
primal --test file.prm
primal -t file.prm
```

The runner compiles the file once, then executes every zero-argument function
whose name starts with `test.`, in declaration order. `main` is not executed.

```
test.math.addition() = assert.equal(1 + 1, 2)
test.stillEqual() = assert.notEqual(1, 1)
test.notBoolean() = assert.true(1)
```

```
PASS  test.math.addition
FAIL  test.stillEqual
      Assertion error: "assert.notEqual" failed: expected not 1, actual 1
ERROR test.notBoolean
      Runtime error: Invalid argument types for function "assert.true". Expected: (Boolean). Actual: (Number)

3 tests: 1 passed, 1 failed, 1 error
```

- A test **passes** when it returns exactly `true`; returning anything else is
  an error. A test with no assertions at all — `test.x() = true` — still passes,
  so the rule catches a mistyped body, not a missing expectation.
- A `test.` function that takes parameters is skipped, reported on stderr, and
  fails the run. Name helper functions outside the `test.` namespace.
- The `test.` prefix is reserved for tests. Other `assert.` names are not
  reserved: `assert.somethingElse()` is a legal user function.
- `--test` combines with `--debug`, which adds the compile time and a per-test
  duration. It cannot be combined with `--watch`.

### Exit codes

| Code | Meaning                                                                  |
| ---- | ------------------------------------------------------------------------ |
| `0`  | every discovered test passed, and nothing was skipped                    |
| `1`  | at least one test failed or errored                                      |
| `2`  | the invocation was wrong: usage error, unreadable file, compile error, no tests discovered, a skipped `test.` function, or an internal abort |

Outside test mode the CLI exits `0` on success and `1` when the program fails to
compile or throws.
