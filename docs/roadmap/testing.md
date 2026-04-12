# Testing Assertions

This document reviews the testing-function draft against the existing Primal
language and compiler, then proposes a revised specification for a focused
assertion library paired with a minimal CLI test runner.

## 1. Short Summary Of Feature Intent

The feature should provide standard-library helpers for writing assertions
directly in Primal code so that test expectations can be expressed in the
language itself.

The library should include these assertion helpers:

- `assert.throws`
- `assert.equal`
- `assert.true`
- `assert.false`

Assertions alone are not enough for a practical testing workflow because
Primal is expression-oriented and does not have statement-style sequencing for
running many tests one after another inside `main()`. The intended execution
model is therefore a CLI test mode that compiles one file, discovers
zero-argument functions whose names start with `test.`, and executes them one
by one.

`assert.throws` is the most implementation-sensitive helper because it must
intercept runtime failures under Primal's eager call model. The CLI runner is
the other important piece because it makes the assertion library usable in
real projects without introducing new test-specific syntax.

## 2. Pros, Costs, And Technical Considerations

### Pros

- Dotted names such as `assert.true`, `assert.equal`, and `test.math.addition`
  are syntactically valid function names in Primal.
- Adding assertions as standard-library functions fits the current
  language philosophy better than introducing assertion syntax.
- A library-based design fits the existing compiler pipeline
  cleanly, because ordinary function calls already pass through lexical,
  syntactic, semantic, lowering, and runtime evaluation stages.
- A CLI runner that discovers `test.*` functions avoids needing new block
  syntax only for testing.
- Convenience helpers can improve test readability even when they mirror
  existing equality or boolean checks.
- A shared failure representation makes assertion behavior predictable across
  all helpers.

### Costs

- Several helpers overlap with functionality that already exists in the
  language.
- The feature is no longer only a library change because it also introduces a
  CLI execution mode.
- Lazy message evaluation means these helpers are not trivial wrappers over
  existing functions under Primal's eager call model.

### Technical Considerations

- The specification must define one common success return value.
- The specification must define one common assertion-failure runtime
  representation.
- The specification must define whether `assert.throws` catches every runtime
  error that `try` catches.
- The specification must define how the CLI discovers test functions.
- The specification must define how test results are classified as pass, fail,
  or error.

## 3. Assumptions And Scope

### Confirmed Observations

- Primal has first-class functions.
- `if` and `try` are special native functions with lazy evaluation behavior.
- Runtime type validation is performed by native functions at evaluation time.
- Existing language and library behavior already provide the underlying
  predicates needed by these helpers, especially ordinary equality and boolean
  expressions.
- Primal programs can define many named functions in one file, so a runner can
  discover tests from function names without requiring new source syntax.

### Scope Of This Proposal

- This proposal includes both an assertion library and a minimal CLI test
  runner.
- Assertion helpers should be available as standard-library functions.
- No new language syntax is added.
- The CLI runner is intentionally small:
  - one file per invocation
  - discovery by `test.` name prefix
  - no filtering, fixtures, tagging, or directory walking in the first version

## 4. Revised Specification

### Final Scope

Add these standard-library functions:

```primal
assert.throws(expression, message)
assert.equal(actual, expected, message)
assert.true(condition, message)
assert.false(condition, message)
```

Add one CLI test mode:

```text
primal --test file.prm
```

### Why This Revision Is Better

- It preserves the goal of keeping assertions inside the language rather than
  adding assertion syntax.
- It gives the assertion library a concrete real-world execution model.
- It keeps the assertion surface small while still covering the main testing
  needs.
- It avoids introducing test-specific language syntax when a CLI runner is
  sufficient.
- It keeps the implementation inside the existing compiler, runtime, and CLI
  model.

### Informal Pseudo-Grammar

No new syntax is added.

```ebnf
assert_call ::= "assert.throws" "(" expression "," expression ")"
              | "assert.equal" "(" expression "," expression "," expression ")"
              | "assert.true" "(" expression "," expression ")"
              | "assert.false" "(" expression "," expression ")"

test_function ::= test_name "(" ")" "=" expression
test_name ::= ordinary_function_name_with_test_prefix
```

These are ordinary function calls and ordinary function declarations with
ordinary identifiers.

### CLI Test Execution Model

#### Invocation

- The CLI should support a test mode:

```text
primal --test file.prm
```

- Test mode accepts exactly one source file argument in the first version.

#### Discovery

- Compile the provided file once.
- Ignore `main()` completely in test mode.
- Discover custom functions whose names start with `test.`.
- Only zero-argument `test.*` functions are valid tests.
- Execute discovered tests in lexicographic order for deterministic output.
- If no matching test functions are found, test mode should report an error.

#### Per-Test Execution

- Each discovered test is invoked as a normal zero-argument function call.
- Each test is evaluated independently through the ordinary runtime pipeline.

#### Result Classification

- If a test returns `true`, it passes.
- If a test throws `CustomError(code = "assertion", message = ...)`, it fails.
- If a test throws any other runtime error, it is an error.
- If a test completes normally but returns any value other than `true`, it is
  an error.

#### Process Exit Behavior

- Exit code `0` if all discovered tests pass.
- Exit code `1` if at least one discovered test fails or errors.
- Exit code `2` for CLI usage errors or compile-time errors in test mode.

### Common Assertion Behavior

- Success return value: `true`
- In every helper, `message` is lazy and is evaluated only on failure.
- On a failing path, `message` must reduce to a string.
- Failed assertions should reuse the existing custom-error mechanism rather
  than introducing a separate assertion-specific runtime error type.
- The recommended failure representation is:

```primal
error.throw("assertion", message)
```

This means a failed assertion is represented as a `CustomError` whose code is
`"assertion"` and whose message is the supplied string.

If evaluating the predicate or helper-specific operation itself throws before
the assertion outcome is known, that error should propagate unchanged unless
the helper explicitly defines that thrown error as success, as `assert.throws`
does.

### Semantic Rules

#### `assert.throws(expression, message)`

- Evaluate `expression` under runtime error interception.
- If evaluating `expression` throws any runtime error that `try` would catch,
  return `true`.
- If evaluating `expression` completes normally, evaluate `message`.
- `message` must reduce to a string.
- Raise an assertion failure with that message.

#### `assert.equal(actual, expected, message)`

- Evaluate `actual`.
- Evaluate `expected`.
- Compare them using Primal's ordinary equality semantics, equivalent to `==`
  or `comp.eq`.
- If the comparison reduces to `true`, return `true`.
- If the comparison reduces to `false`, evaluate `message`.
- `message` must reduce to a string.
- Raise an assertion failure with that message.

#### `assert.true(condition, message)`

- Evaluate `condition`.
- `condition` must reduce to a boolean.
- If `condition` reduces to `true`, return `true`.
- If `condition` reduces to `false`, evaluate `message`.
- `message` must reduce to a string.
- Raise an assertion failure with that message.

This is a readability helper for asserting truth directly.

#### `assert.false(condition, message)`

- Evaluate `condition`.
- `condition` must reduce to a boolean.
- If `condition` reduces to `false`, return `true`.
- If `condition` reduces to `true`, evaluate `message`.
- `message` must reduce to a string.
- Raise an assertion failure with that message.

### Runtime And Type Behavior

- Success return value: `true`
- All assertion helpers use lazy message evaluation.
- `assert.true` and `assert.false` require a boolean condition.
- `assert.equal` follows the same runtime type rules as ordinary equality.
- `assert.throws` catches any runtime error that `try` would catch.

### Error Conditions

- `assert.true` with a non-boolean condition:
  - `InvalidArgumentTypesError`
- `assert.false` with a non-boolean condition:
  - `InvalidArgumentTypesError`
- Any assertion helper with a failing condition and non-string message:
  - `InvalidArgumentTypesError`
- `assert.equal` with arguments rejected by ordinary equality:
  - propagate the underlying runtime error unchanged
- `assert.throws` with a non-throwing expression:
  - assertion failure
- Errors from nested expressions:
  - propagate unchanged unless they are the error being intentionally caught by
    `assert.throws`

### Implementation Impact

#### Lexical Analysis

- No new tokens
- No new keywords
- No keyword conflicts expected

#### Syntactic Analysis

- No grammar changes
- Parsed as ordinary function calls and ordinary function declarations

#### Semantic Analysis

- Add four standard-library signatures
- Preserve ordinary arity checking and function-resolution behavior
- Test discovery should inspect custom functions after successful compilation

#### Lowering

- No structural lowering changes required
- All assertions lower as ordinary calls to standard-library functions
- Test functions lower exactly like any other user-defined zero-argument
  function

#### Runtime Evaluation

- All assertion helpers must be implemented as native functions or an
  equivalent runtime mechanism that preserves lazy message evaluation.
- `assert.throws` must additionally evaluate its first argument under runtime
  error interception.
- The runner must evaluate discovered tests one by one through the existing
  runtime pipeline.
- These helpers cannot be modeled correctly as ordinary eager custom functions
  if lazy failure messages are required.

#### CLI Integration

- Add a `--test` mode to the CLI.
- Test mode compiles one file and does not execute `main()`.
- Test mode discovers zero-argument custom functions whose names start with
  `test.`.
- Test mode prints per-test results and a final summary.

### Performance Considerations

- Runtime overhead is low for `assert.equal`, `assert.true`, and
  `assert.false`.
- Runtime overhead is low to medium for `assert.throws` because it requires
  evaluation under error interception.
- Test mode should compile the source file once, then execute discovered tests
  without recompiling the file for each test.

## 5. Examples

### Minimal Test File

```primal
test.math.addition() =
    assert.equal(1 + 1, 2, "math failed")

test.parse.invalidNumber() =
    assert.throws(to.number("not a number"), "expected parsing to fail")

main() = "ignored in test mode"
```

Running:

```text
primal --test sample.prm
```

Should:

- ignore `main()`
- discover `test.math.addition` and `test.parse.invalidNumber`
- run them in lexicographic order

### Valid Assertion Examples

```primal
assert.equal(1 + 1, 2, "math failed")
```

```primal
assert.true(str.match("hello123", "[a-z]+[0-9]+"), "pattern mismatch")
```

```primal
assert.throws(to.number("not a number"), "expected parsing to fail")
```

```primal
assert.equal(true, true, error.throw(-1, "message should not evaluate"))
```

### Invalid Assertion Examples With Expected Errors

```primal
assert.true(1, "expected boolean")
```

Expected error:

```text
InvalidArgumentTypesError
```

```primal
assert.false(true, 123)
```

Expected error:

```text
InvalidArgumentTypesError
```

```primal
assert.equal("1", 1, "expected equal")
```

Expected error:

```text
InvalidArgumentTypesError
```

```primal
assert.throws(42, "expected failure")
```

Expected result:

```text
Assertion failure via CustomError(code = "assertion", message = "expected failure")
```

### Invalid Test-Mode Example

```primal
helper() = true
main() = 42
```

Running:

```text
primal --test sample.prm
```

Expected result:

```text
Error because no zero-argument custom functions whose names start with "test." were found
```

## 6. Concrete Edge Cases

### Edge Case 1: Lazy Message Evaluation

```primal
assert.equal(true, true, error.throw(-1, "unused"))
```

This must succeed without evaluating the message.

### Edge Case 2: `assert.throws` Around A Successful Expression

```primal
assert.throws(1 + 2, "expected a throw")
```

This must fail with an assertion failure, not succeed.

### Edge Case 3: Underlying Equality Type Error

```primal
assert.equal("1", 1, "should not coerce types")
```

This should propagate `InvalidArgumentTypesError` rather than convert it into
an assertion failure.

### Edge Case 4: `assert.throws` Catches A Custom Error

```primal
assert.throws(error.throw(404, "not found"), "should throw")
```

This should succeed.

### Edge Case 5: `main()` Is Ignored In Test Mode

```primal
test.example() = true
main() = error.throw(-1, "should not run")
```

Running:

```text
primal --test sample.prm
```

This should pass because `main()` is not executed.

### Edge Case 6: Non-True Test Result

```primal
test.bad() = 42
```

Running:

```text
primal --test sample.prm
```

This should be reported as an error, not as a passing test.

## 7. High-Value Open Questions

1. Should a later version support directory-level or project-level discovery in
   addition to single-file test mode?
2. Should lexicographic order remain the permanent execution order, or should
   explicit ordering ever be supported?
3. Should future versions add richer result reporting such as structured JSON
   output or stack traces for failing tests?

## 8. Post-Implementation

- Update documentation in `docs/`
- Implement runtime coverage for all four assertion helpers
- Implement CLI coverage for:
  - discovery of zero-argument `test.*` functions
  - ignored `main()` in test mode
  - no-test-file error behavior
  - pass, fail, and error classification
- Implement tests for lazy message behavior, equality type errors, and
  `assert.throws` error interception

## 9. Implementation Complexity

Medium

Justification:

- No lexer or parser work should be required.
- The assertion surface is small and cohesive.
- The main complexity is preserving lazy message behavior across all helpers,
  implementing error interception for `assert.throws`, and integrating a small
  but well-defined CLI discovery and reporting mode.

## 10. Final Recommendation

Adopt

Adopt the focused four-function assertion library together with a minimal CLI
runner invoked as `primal --test file.prm`. The runner should discover
zero-argument `test.*` functions, ignore `main()` in test mode, and classify
results as pass, fail, or error. This gives Primal a usable testing workflow
without introducing new test-specific syntax.
