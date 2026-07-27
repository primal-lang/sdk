---
title: Error
tags:
  - reference
  - error-handling
sources:
  - lib/compiler/library/error/
---

# Error

**TLDR**: Function for throwing custom errors with an error code and message that can be caught using the try function.

Number of functions: 1

## Functions

### Throw Error

- **Signature:** `error.throw(a: Any, b: String): Error`
- **Input:** An error code and a message string
- **Output:** Throws an error that wraps the provided code and message. This function never returns normally.
- **Purity:** Impure
- **Example:**

```
error.throw(404, "Not Found") // throws an error with code 404 and message "Not Found"
```

## Assertion Errors

The assertion functions in [[lang/reference/core/assert]] raise two dedicated
error types instead of `error.throw`'s custom error:

- **`Assertion error`** — an assertion whose expectation was not met. It prints
  as `Assertion error: "assert.equal" failed: expected 2, actual 3`, and the
  `--test` runner classifies it as a **failure**.
- **`Runtime error`** — an assertion given an argument of the wrong type. It
  prints exactly like any other invalid-argument-types error, and the runner
  classifies it as an **error**.

The distinction only exists for assertions. An error raised by hand with
`error.throw` is always an error, never a failure, no matter which code it
carries — including `error.throw("assertion", "…")`.

Both are catchable by `try`, like every other runtime error, so
`try(assert.equal(1, 2), true)` returns `true`.
